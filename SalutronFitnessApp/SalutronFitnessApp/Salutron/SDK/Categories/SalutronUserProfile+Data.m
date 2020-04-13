//
//  SalutronUserProfile+Data.m
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/18/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Format.h"

#import "UserProfileEntity.h"

#import "SalutronUserProfile+Data.h"

#import "SFAHealthKitManager.h"

@implementation SalutronUserProfile (Data)

#pragma mark - Public class save methods

+ (void)saveWithSalutronUserProfile:(SalutronUserProfile *)userProfile
{
    //save user profile
    [SFAUserDefaultsManager sharedManager].salutronUserProfile = userProfile;
    [self saveHeightAndWeightToHealthStore];
    DDLogInfo(@"----------> USERPROFILE : %@", userProfile);
}

#pragma mark - Public class select methods
+ (SalutronUserProfile *)getData
{
    //get user profile
    return [SFAUserDefaultsManager sharedManager].salutronUserProfile;
}

+ (NSInteger)maxBPM
{
    SalutronUserProfile *userProfile    = [self getData];
    NSCalendar *calendar                = [NSCalendar currentCalendar];
    NSDate *birthday                    = userProfile.birthdayDate;
    NSDate *now                         = [NSDate date];
    NSDateComponents* ageComponents     = [calendar components:NSYearCalendarUnit
                                                      fromDate:birthday
                                                        toDate:now
                                                       options:0];
    NSInteger age                       = [ageComponents year];
    NSInteger maxBPM                    = userProfile.gender == MALE ? 220 : 226;
    maxBPM                              -= age;
    
    return maxBPM;
}

#pragma mark - Private Methods

- (NSDate *)birthdayDate
{
    NSCalendar *calendar                = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents    = [NSDateComponents new];
    dateComponents.month                = self.birthday.month;
    dateComponents.day                  = self.birthday.day;
    dateComponents.year                 = self.birthday.year + 1900;
    NSDate *birthday                    = [calendar dateFromComponents:dateComponents];
    
    return birthday;
}

- (NSString *)genderString
{
    if (self.gender == MALE) {
        return @"male";
    } else if (self.gender == FEMALE) {
        return @"female";
    }
    
    return @"male";
}

- (NSString *)unitString
{
    if (self.unit == METRIC) {
        return @"metric";
    } else if (self.unit == IMPERIAL) {
        return @"imperial";
    }
    
    return @"metric";
}

- (NSString *)sensitivityString
{
    if (self.sensitivity == LOW) {
        return @"low";
    } else if (self.sensitivity == MEDIUM) {
        return @"medium";
    } else if (self.sensitivity == HIGH) {
        return @"high";
    }
    
    return @"low";
}

- (AccelSensorSensitivity)sensitivityWithSensitivityString:(NSString *)string
{
    if ([string isEqualToString:[LS_LOW lowercaseString]]) {
        return LOW;
    } else if ([string isEqualToString:[LS_MEDIUM lowercaseString]]) {
        return MEDIUM;
    } else if ([string isEqualToString:[LS_HIGH lowercaseString]]) {
        return HIGH;
    }
    
    return LOW;
}

#pragma mark - Public Methods

+ (SalutronUserProfile *)userProfile
{
    NSUserDefaults *userDefaults        = [NSUserDefaults standardUserDefaults];
    NSData *data                        = [userDefaults objectForKey:USER_PROFILE];
    SalutronUserProfile *userProfile    = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (!userProfile) {
        userProfile = [SalutronUserProfile new];
    }
    
    return userProfile;
}

+ (SalutronUserProfile *)userProfileWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        NSString *birthdayString    = [dictionary objectForKey:API_USER_PROFILE_BIRTHDAY];
        NSString *genderString      = [dictionary objectForKey:API_USER_PROFILE_GENDER];
        NSString *unitString        = [dictionary objectForKey:API_USER_PROFILE_UNIT];
        NSString *sensitivityString = [dictionary objectForKey:API_USER_PROFILE_SENSITIVITY];
        NSNumber *height            = @([[dictionary objectForKey:API_USER_PROFILE_HEIGHT] floatValue]);
        NSNumber *weight            = @([[dictionary objectForKey:API_USER_PROFILE_WEIGHT] floatValue]);
        NSDate *birthday            = [NSDate dateFromString:birthdayString withFormat:API_DATE_FORMAT];
        
        SH_Date *date               = [[SH_Date alloc] init];
        date.month                  = birthday.dateComponents.month;
        date.day                    = birthday.dateComponents.day;
        date.year                   = birthday.dateComponents.year - DATE_YEAR_ADDER;
        
        SalutronUserProfile *userProfile    = [[SalutronUserProfile alloc] init];
        userProfile.birthday                = date;
        userProfile.gender                  = [genderString isEqualToString:[LS_MALE_CAPS lowercaseString]] ? MALE : FEMALE;
        userProfile.unit                    = [unitString isEqualToString:[LS_METRIC_CAPS lowercaseString]] ? METRIC : IMPERIAL;
        userProfile.sensitivity             = [userProfile sensitivityWithSensitivityString:sensitivityString];
        userProfile.height                  = height.integerValue;
        userProfile.weight                  = weight.integerValue;
        
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:userProfile];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:data forKey:USER_PROFILE];
        
        return userProfile;
    }
    
    return nil;
}

+ (SalutronUserProfile *)userProfileWithUserProfileEntity:(UserProfileEntity *)userProfile
{
    SalutronUserProfile *profile    = [SalutronUserProfile new];
    profile.birthday                = [SH_Date new];
    profile.birthday.month          = userProfile.birthday.dateComponents.month;
    profile.birthday.day            = userProfile.birthday.dateComponents.day;
    profile.birthday.year           = userProfile.birthday.dateComponents.year - DATE_YEAR_ADDER;
    profile.gender                  = userProfile.gender.integerValue;
    profile.unit                    = userProfile.unit.integerValue;
    profile.sensitivity             = userProfile.sensitivity.integerValue;
    profile.weight                  = userProfile.weight.integerValue;
    profile.height                  = userProfile.height.integerValue;
    
    NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:profile];
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:data forKey:USER_PROFILE];
    [userDefaults synchronize];
    return profile;
}

- (NSDictionary *)dictionary
{
    NSString *birthdayString = [self.birthdayDate stringWithFormat:@"yyyy-MM-dd"];
    NSDictionary *dictionary = @{API_USER_PROFILE_BIRTHDAY      : birthdayString,
                                 API_USER_PROFILE_GENDER        : self.genderString,
                                 API_USER_PROFILE_UNIT          : self.unitString,
                                 API_USER_PROFILE_SENSITIVITY   : self.sensitivityString,
                                 API_USER_PROFILE_HEIGHT        : @(self.height),
                                 API_USER_PROFILE_WEIGHT        : @(self.weight)};
    
    return dictionary;
}

+ (void)saveHeightAndWeightToHealthStore{
    DDLogInfo(@"");
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"InitialWatchToAppSync"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"InitialWatchToAppSync"] isEqual:@(0)]) {
        if([[SFAHealthKitManager sharedManager] isHealthKitAvailable]){
            //[[SFAHealthKitManager sharedManager] requestAuthorizationWithSuccess:^(BOOL success) {
            //    if (success) {
                    SalutronUserProfile *userProfile = [SalutronUserProfile userProfile];
                    [[SFAHealthKitManager sharedManager] saveHeight:(double)(userProfile.height/100.0)];
                    [[SFAHealthKitManager sharedManager] saveWeight:round(userProfile.weight / 2.20462)];
           //     }
           // } failure:^(NSError *error) {
                
           // }];
        }
    }
}

@end
