//
//  SFAWalgreensManager.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 6/17/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAWalgreensManager.h"

#import "SFAServerManager+RefreshAccessToken.h"
#import "SFAServerAccountManager.h"
#import "AFHTTPRequestOperationManager.h"

#define MY_LIFETRAK_DOMAIN @"my.lifetrakusa.com"

@interface SFAWalgreensManager ()

@property (strong, nonatomic) NSOperation *currentOperation;

@end

@implementation SFAWalgreensManager

+ (SFAWalgreensManager *)sharedManager
{
    static SFAWalgreensManager *instance = nil;
    
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

#pragma mark - public methods
- (void)getConnectURLWithSuccess:(void (^)(NSURL *url, BOOL isConnected, BOOL isSynced))success
                         failure:(void (^)(NSError *error))failure
{
    SFAServerManager *serverManager         = [SFAServerManager sharedManager];
    SFAServerAccountManager *accountManager = [SFAServerAccountManager sharedManager];
    
    NSString *accessToken                   = accountManager.accessToken;
    NSString *macAddress                    = [[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS];
    
    NSDictionary *parameters                = @{API_OAUTH_ACCESS_TOKEN  : accessToken,
                                                API_SYNC_MAC_ADDRESS    : macAddress,
                                                API_WALGREENS_CHANNEL   : @"mobile"};
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    NSHTTPCookie *accessTokenCookie = [[NSHTTPCookie alloc] initWithProperties:@{NSHTTPCookieDomain : MY_LIFETRAK_DOMAIN,
                                                                                 NSHTTPCookieName : @"access_token",
                                                                                 NSHTTPCookieValue : accessToken,
                                                                                 NSHTTPCookiePath : @"/"}];
    NSHTTPCookie *macAddressCookie = [[NSHTTPCookie alloc] initWithProperties:@{NSHTTPCookieDomain : MY_LIFETRAK_DOMAIN,
                                                                                 NSHTTPCookieName : @"mac_address",
                                                                                 NSHTTPCookieValue : macAddress,
                                                                                 NSHTTPCookiePath : @"/"}];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:accessTokenCookie];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:macAddressCookie];
    
    self.currentOperation = [serverManager getRequestWithRefreshAccessTokenToURL:API_WALGREENS_LOGIN_URL parameters:parameters success:^(NSDictionary *response) {
        NSDictionary *result    = [response objectForKey:API_RESULT];
        NSString *urlString     = [result objectForKey:@"url"];
        NSURL *url              = [NSURL URLWithString:urlString];
        BOOL isConnected        = [[result objectForKey:@"is_connected"] boolValue];
        BOOL isSynced           = [[result objectForKey:@"is_synced"] boolValue];
        
        if (success) {
            success(url,isConnected,isSynced);
        }
    } failure:failure];

}

- (void)disconnectWithSuccess:(void (^)())success
                      failure:(void (^)(NSError *error))failure
{
    SFAServerManager *serverManager         = [SFAServerManager sharedManager];
    SFAServerAccountManager *accountManager = [SFAServerAccountManager sharedManager];
    
    NSString *accessToken                   = accountManager.accessToken;
    NSString *macAddress                    = [[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS];
    
    NSDictionary *parameters                = @{API_OAUTH_ACCESS_TOKEN  : accessToken,
                                                API_SYNC_MAC_ADDRESS    : macAddress,
                                                API_WALGREENS_CHANNEL   : @"mobile"};
        
    self.currentOperation = [serverManager getRequestWithRefreshAccessTokenToURL:API_WALGREENS_DISCONNECT parameters:parameters success:^(NSDictionary *response) {
        if (success) {
            success();
        }
    } failure:failure];
}

- (void)cancelCurrentOperation
{
    if (self.currentOperation){
        [self.currentOperation cancel];
    }
}



@end
