//
//  SFAServerAccountManager.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/7/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDictionary+String.h"

#import "UserEntity+Data.h"
#import "DeviceEntity+Data.h"
#import "UserProfileEntity+Data.h"

#import "SFAServerManager+RefreshAccessToken.h"
#import "SFAServerAccountManager.h"
#import "SFAWatchManager.h"
#import "SFASalutronUpdateManager.h"
#import "JDACoreData.h"

#import "Flurry.h"

@interface SFAServerAccountManager ()

@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (readwrite, nonatomic) NSString  *emailAddress;
@property (readwrite, nonatomic) NSString  *password;
@property (readwrite, nonatomic) BOOL   isLoggedIn;
@property (readwrite, nonatomic) BOOL   isFacebookLogIn;

@end

@implementation SFAServerAccountManager

@synthesize isFacebookLogIn = _isFacebookLogIn;
@synthesize accessToken     = _accessToken;
@synthesize emailAddress    = _emailAddress;
@synthesize expiration      = _expiration;
@synthesize refreshToken    = _refreshToken;

#pragma mark - Singleton Instance

+ (instancetype)sharedManager
{
    static SFAServerAccountManager *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

#pragma mark - Setters

- (void)setIsFacebookLogIn:(BOOL)isFacebookLogIn
{
    if (_isFacebookLogIn != isFacebookLogIn) {
        _isFacebookLogIn = isFacebookLogIn;
    }
    [self.userDefaults setBool:isFacebookLogIn forKey:API_IS_FACEBOOK_LOGIN];
}

- (void)setAccessToken:(NSString *)accessToken
{
    if (![_accessToken isEqualToString:accessToken]) {
        _accessToken            = accessToken;
        self.user.accessToken   = accessToken;
        NSError *error = nil;
        [self.user.managedObjectContext save:&error];
        [self.userDefaults setObject:accessToken forKey:API_OAUTH_ACCESS_TOKEN];
    }
}

- (void)setEmailAddress:(NSString *)emailAddress
{
    if (![_emailAddress isEqualToString:emailAddress]) {
        _emailAddress = emailAddress;
        [self.userDefaults setObject:emailAddress forKey:API_OAUTH_EMAIL_ADDRESS];
    }
}

- (void)setExpiration:(NSDate *)expiration
{
    if (![_expiration isEqualToDate:expiration]) {
        _expiration = expiration;
        [self.userDefaults setInteger:expiration.timeIntervalSince1970 forKey:API_OAUTH_EXPIRATION];
    }
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    if (![_refreshToken isEqualToString:refreshToken]){
        _refreshToken = refreshToken;
        [self.userDefaults setObject:refreshToken forKey:API_OAUTH_REFRESH_TOKEN];
    }
}

#pragma mark - Getters

- (NSString *)accessToken
{
    if (!_accessToken) {
        _accessToken = [self.userDefaults stringForKey:API_OAUTH_ACCESS_TOKEN];
    }
    
    return _accessToken;
}

- (BOOL)isLoggedIn
{
    if (self.user) {
        return YES;
    }
    return NO;
}

- (BOOL)isFacebookLogIn
{
    return [self.userDefaults boolForKey:API_IS_FACEBOOK_LOGIN];
}

- (NSUserDefaults *)userDefaults
{
    if (!_userDefaults) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    [_userDefaults synchronize];
    
    return _userDefaults;
}

- (NSString *)emailAddress
{
    if (!_emailAddress) {
        _emailAddress = [self.userDefaults stringForKey:API_OAUTH_EMAIL_ADDRESS];
    }
    
    return _emailAddress;
}

- (NSDate *)expiration
{
    if (!_expiration) {
        NSInteger timeStamp = [self.userDefaults integerForKey:API_OAUTH_EXPIRATION];
        _expiration         = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    }
    
    return _expiration;
}

- (NSString *)refreshToken
{
    if (!_refreshToken){
        _refreshToken = [self.userDefaults stringForKey:API_OAUTH_REFRESH_TOKEN];
    }
    return _refreshToken;
}

- (UserEntity *)user
{
    if (!_user) {
        _user = [UserEntity userEntityWithEmailAddress:self.emailAddress];
    }
    
    return _user;
}

#pragma mark - Public Methods

- (BOOL)isAccessTokenExpired
{
    NSComparisonResult result = [self.expiration compare:[NSDate date]];
    if ( result == NSOrderedAscending || result == NSOrderedSame){
        return YES;
    }else{
        return NO;
    }
}

- (void)logInWithEmailAddress:(NSString *)emailAddress
                     password:(NSString *)password
                      success:(void (^)())success
                      failure:(void (^)(NSError *))failure
{
    SFAServerManager *serverManager = [SFAServerManager sharedManager];
    NSDictionary *parameters        = @{API_LOGIN_EMAIL_ADDRESS    : emailAddress,
                                        API_LOGIN_PASSWORD         : password,
                                        API_OAUTH_CLIENT_ID        : API_CLIENT_ID,
                                        API_OAUTH_CLIENT_SECRET    : API_CLIENT_SECRET};
    
    [serverManager postRequestToURL:API_LOGIN_URL parameters:parameters success:^(NSDictionary *response) {
        NSString *errorString = [response objectForKey:API_ERROR_CODE];
        
        if (errorString) {
            NSString *bundleIdentifier  = [NSBundle mainBundle].bundleIdentifier;
            NSString *errorMessage      = [response objectForKey:API_ERROR_MESSAGE];
            NSDictionary *userInfo      = @{NSLocalizedDescriptionKey : errorMessage};
            NSError *error              = [NSError errorWithDomain:bundleIdentifier code:ERROR_CODE_API userInfo:userInfo];
            
            if (failure) {
                failure(error);
            }
        } else {
            NSInteger timeStamp = [[response objectForKey:API_OAUTH_EXPIRATION] integerValue];
            self.accessToken    = [response stringObjectForKey:API_OAUTH_ACCESS_TOKEN];
            self.refreshToken   = [response stringObjectForKey:API_OAUTH_REFRESH_TOKEN];
            self.expiration     = [NSDate dateWithTimeIntervalSince1970:timeStamp];
            self.emailAddress   = emailAddress;
            self.password       = password;
            if (success) {
                success();
            }
        }
    } failure:failure];
}

- (void)logInWithFacebookAccessToken:(NSString *)accessToken
                             success:(void (^)())success
                             failure:(void (^)(NSError *error))failure
{
    SFAServerManager *serverManager = [SFAServerManager sharedManager];
    NSDictionary *parameters        = @{API_FACEBOOK_LOGIN_FACEBOOK_TOKEN   : accessToken,
                                        API_OAUTH_CLIENT_ID                 : API_CLIENT_ID,
                                        API_OAUTH_CLIENT_SECRET             : API_CLIENT_SECRET};
    
    [serverManager postRequestToURL:API_FACEBOOK_LOGIN_URL parameters:parameters success:^(NSDictionary *response) {
        NSString *errorString = [response objectForKey:API_ERROR_CODE];
        
        if (errorString) {
            NSString *bundleIdentifier  = [NSBundle mainBundle].bundleIdentifier;
            NSString *errorMessage      = [response objectForKey:API_ERROR_MESSAGE];
            NSDictionary *userInfo      = @{NSLocalizedDescriptionKey : errorMessage};
            NSError *error              = [NSError errorWithDomain:bundleIdentifier code:ERROR_CODE_API userInfo:userInfo];
            
            if (failure) {
                failure(error);
            }
        } else {
            NSInteger timeStamp = [[response objectForKey:API_OAUTH_EXPIRATION] integerValue];
            self.accessToken    = [response stringObjectForKey:API_OAUTH_ACCESS_TOKEN];
            self.refreshToken   = [response stringObjectForKey:API_OAUTH_REFRESH_TOKEN];
            self.expiration     = [NSDate dateWithTimeIntervalSince1970:timeStamp];
            self.isFacebookLogIn = YES;
            
            if (success) {
                success();
            }
        }
    } failure:failure];
}

- (void)getProfileWithSuccess:(void (^)())success
                      failure:(void (^)(NSError *))failure
{
    SFAServerManager *serverManager = [SFAServerManager sharedManager];
    NSDictionary *parameters        = @{API_OAUTH_ACCESS_TOKEN  : self.accessToken,
                                        @"dummy_data"           : @"dummy"};
    
    [serverManager getRequestWithRefreshAccessTokenToURL:API_PROFILE_URL parameters:parameters success:^(NSDictionary *response) {
        NSDictionary *result    = [response objectForKey:API_RESULT];
        self.emailAddress       = [result stringObjectForKey:API_OAUTH_EMAIL_ADDRESS];
        NSString *firstName     = [result stringObjectForKey:API_USER_FIRST_NAME];
        NSString *lastName      = [result stringObjectForKey:API_USER_LAST_NAME];
        NSString *imageURL      = [result stringObjectForKey:API_USER_IMAGE_URL];
        NSString *userID        = [result stringObjectForKey:API_USER_ID];
        NSNumber *isActivated   = @([[result stringObjectForKey:API_USER_ACTIVATED] intValue]);
        imageURL                = [imageURL isKindOfClass:[NSString class]] ? imageURL : @"";
        
        self.user               = [UserEntity insertUserEntityWithEmailAddress:self.emailAddress
                                                                     firstName:firstName
                                                                      lastName:lastName
                                                                      imageURL:imageURL
                                                                   accessToken:self.accessToken
                                                                        userID:userID
                                                               newlyRegistered:[NSNumber numberWithBool:NO]];
        DDLogError(@"user = %@", self.user);
        /*
        if ([[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]) {
            NSString *macAddress = [self.userDefaults objectForKey:MAC_ADDRESS];
            DeviceEntity *device = [DeviceEntity deviceEntityForMacAddress:macAddress];
            if (device){
                [self.user addDeviceObject:device];
            }
        }
        else if ([[DeviceEntity deviceEntitiesWithNoUser] count] > 0) {
            NSArray *devices = [DeviceEntity deviceEntitiesWithNoUser];
            self.user.device = [NSSet setWithArray:devices];
            SalutronUserProfile *userProfile = [SalutronUserProfile userProfile];
			[SFAUserDefaultsManager sharedManager].salutronUserProfile = userProfile;
            for (DeviceEntity *device in devices) {
                device.user = self.user;
                device.userProfile = [UserProfileEntity userProfileWithSalutronUserProfile:userProfile forDeviceEntity:device];
            }
        }
         */
        
        [[NSUserDefaults standardUserDefaults] setBool:[isActivated boolValue] forKey:API_USER_ACTIVATED];
        [[NSUserDefaults standardUserDefaults] synchronize];

        if (success) {
            success();
        }
    } failure:failure];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)updateProfileWithFirstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                          password:(NSString *)password
                      oldPassword:(NSString *)oldPassword
                        userImage:(UIImage *)userImage
                          success:(void (^)())success
                          failure:(void (^)(NSError *))failure
{
    SFAServerManager *serverManager = [SFAServerManager sharedManager];
    NSMutableDictionary *parameters = [@{API_REGISTER_FIRST_NAME    : firstName,
                                         API_REGISTER_LAST_NAME     : lastName,
                                         API_OAUTH_ACCESS_TOKEN     : self.accessToken} mutableCopy];
    
    if (password.length > 0) {
        [parameters setObject:password forKey:API_REGISTER_PASSWORD];
        [parameters setObject:oldPassword forKey:API_PROFILE_OLD_PASSWORD];
    }
    
    if (userImage) {
        userImage = [self imageWithImage:userImage scaledToSize:CGSizeMake(300, 300)];
        
        NSData *data = UIImageJPEGRepresentation(userImage, 0.3f);
        
        [serverManager postRequestWithRefreshAccessTokenToURL:API_UPDATE_PROFILE_URL parameters:parameters data:data dataName:API_REGISTER_USER_IMAGE fileName:@"profile_pic.jpg" mimeType:@"image/jpeg"  success:^(NSDictionary *response) {
            NSDictionary *result    = [response objectForKey:API_RESULT];
            self.emailAddress       = [result stringObjectForKey:API_OAUTH_EMAIL_ADDRESS];
            self.user.firstName     = [result stringObjectForKey:API_USER_FIRST_NAME];
            self.user.lastName      = [result stringObjectForKey:API_USER_LAST_NAME];
            self.user.imageURL      = [result stringObjectForKey:API_USER_IMAGE_URL];
            
            if (success) {
                JDACoreData *coreData   = [JDACoreData sharedManager];
                [coreData save];
                success();
            }
        } failure:failure];
    } else {
        [serverManager postRequestWithRefreshAccessTokenToURL:API_UPDATE_PROFILE_URL parameters:parameters success:^(NSDictionary *response) {
            NSDictionary *result    = [response objectForKey:API_RESULT];
            self.emailAddress       = [result stringObjectForKey:API_OAUTH_EMAIL_ADDRESS];
            self.user.firstName     = [result stringObjectForKey:API_USER_FIRST_NAME];
            self.user.lastName      = [result stringObjectForKey:API_USER_LAST_NAME];
            self.user.imageURL      = [result stringObjectForKey:API_USER_IMAGE_URL];
            
            if (success) {
                JDACoreData *coreData   = [JDACoreData sharedManager];
                [coreData save];
                success();
            }
        } failure:failure];
    }
}


- (void)resetPasswordWithEmailAddress:(NSString *)emailAddress
                              success:(void (^)())success
                              failure:(void (^)(NSError *))failure
{
    SFAServerManager *serverManager = [SFAServerManager sharedManager];
    NSDictionary *parameters        = @{API_FORGOT_PASSWORD_EMAIL_ADDRESS   : emailAddress,
                                        @"dummy_data"                       : @"dummy"};
    
    [serverManager postRequestToURL:API_FORGOT_PASSWORD_URL parameters:parameters success:^(NSDictionary *response) {
        if (success) {
            success();
        }
    } failure:failure];
}

- (void)registerWithEmailAddress:(NSString *)emailAddress
                        password:(NSString *)password
                       firstName:(NSString *)firstName
                        lastName:(NSString *)lastName
                       userImage:(UIImage *)userImage
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure
{
    
    SFAServerManager *serverManager = [SFAServerManager sharedManager];
    NSDictionary *parameters        = @{API_REGISTER_EMAIL_ADDRESS : emailAddress,
                                        API_REGISTER_PASSWORD      : password,
                                        API_REGISTER_FIRST_NAME    : firstName,
                                        API_REGISTER_LAST_NAME     : lastName,
                                        API_REGISTER_ROLE          : API_USER_ROLE,
                                        API_OAUTH_CLIENT_ID        : API_CLIENT_ID,
                                        API_OAUTH_CLIENT_SECRET    : API_CLIENT_SECRET};
    
    if (userImage) {
        NSData *data = UIImageJPEGRepresentation(userImage, 0.3f);
        
        [serverManager postRequestToURL:API_REGISTER_URL parameters:parameters data:data dataName:API_REGISTER_USER_IMAGE fileName:@"profile_pic.jpg" mimeType:@"image/jpeg" success:^(NSDictionary *response) {
            
            NSInteger timeStamp = [[response objectForKey:API_OAUTH_EXPIRATION] integerValue];
            self.emailAddress   = emailAddress;
            self.accessToken    = [response stringObjectForKey:API_OAUTH_ACCESS_TOKEN];
            self.refreshToken   = [response stringObjectForKey:API_OAUTH_REFRESH_TOKEN];
            self.expiration     = [NSDate dateWithTimeIntervalSince1970:timeStamp];
            self.user           = [UserEntity insertUserEntityWithEmailAddress:emailAddress
                                                                     firstName:firstName
                                                                      lastName:lastName
                                                                      imageURL:nil
                                                                   accessToken:self.accessToken
//#warning change userID:@""
                                                                        userID:@""
                                                               newlyRegistered:[NSNumber numberWithBool:YES]];

            //NSString *macAddress = [self.userDefaults objectForKey:MAC_ADDRESS];
            //DeviceEntity *device = [DeviceEntity deviceEntityForMacAddress:macAddress];
            
            //[self.user addDeviceObject:device];
            
            if (success) {
                success();
            }
        } failure:failure];
    } else {
        NSString *url = API_REGISTER_URL;
        DDLogError(@"Url: %@", url);
        
        [serverManager postRequestToURL:API_REGISTER_URL parameters:parameters success:^(NSDictionary *response) {
            NSInteger timeStamp = [[response objectForKey:API_OAUTH_EXPIRATION] integerValue];
            self.emailAddress   = emailAddress;
            self.accessToken    = [response stringObjectForKey:API_OAUTH_ACCESS_TOKEN];
            self.refreshToken   = [response stringObjectForKey:API_OAUTH_REFRESH_TOKEN];
            self.expiration     = [NSDate dateWithTimeIntervalSince1970:timeStamp];
            self.user           = [UserEntity insertUserEntityWithEmailAddress:emailAddress
                                                                     firstName:firstName
                                                                      lastName:lastName
                                                                      imageURL:nil
                                                                   accessToken:self.accessToken
//#warning change userID:@""
                                                                        userID:@""
                                                               newlyRegistered:[NSNumber numberWithBool:YES]];
            
            /*
            if ([self.userDefaults objectForKey:MAC_ADDRESS]) {
                NSString *macAddress = [self.userDefaults objectForKey:MAC_ADDRESS];
                DeviceEntity *device = [DeviceEntity deviceEntityForMacAddress:macAddress];
            
                [self.user addDeviceObject:device];
            }
            else {
                NSArray *devices = [DeviceEntity deviceEntities];
                self.user.device = [NSSet setWithArray:devices];
                SalutronUserProfile *userProfile = [SalutronUserProfile userProfile];
                for (DeviceEntity *device in devices) {
                    device.user = self.user;
                    device.userProfile = [UserProfileEntity userProfileWithSalutronUserProfile:userProfile forDeviceEntity:device];
                }
            }
             */
            if (success) {
                success();
            }
        } failure:failure];
    }
}

- (void)refreshAccessTokenWithSuccess:(void (^)())success
                              failure:(void (^)(NSError *))failure
{
    //[self logInWithEmailAddress:self.emailAddress password:self.password success:success failure:failure];
}

- (void)logOut
{
    [Flurry logEvent:SIGNOUT_PAGE];
    self.accessToken        = nil;
    self.emailAddress       = nil;
    self.expiration         = nil;
    self.user               = nil;
    self.password           = nil;
    self.isFacebookLogIn    = NO;
    self.isLoggedIn         = NO;
    [[SFAUserDefaultsManager sharedManager] clearUserDefaults];
    [[SFAWatchManager sharedManager] disableAutoSync];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //[[SFASalutronUpdateManager sharedInstance] startUpdateNotificationStatusWithWatchModel:[SFAUserDefaultsManager sharedManager].watchModel notificationStatus:NO];
    /*NSString *appDomain             = [[NSBundle mainBundle] bundleIdentifier];
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    [userDefaults removePersistentDomainForName:appDomain];*/
    
    //SFASalutronFitnessAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //[appDelegate resetCoreData];
}

@end
