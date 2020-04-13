//
//  SFAFacebookManager.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/15/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "SFAFacebookManager.h"

@interface SFAFacebookManager ()

@end

@implementation SFAFacebookManager

#pragma mark - Singleton Instance

+ (SFAFacebookManager *)sharedManager
{
    static SFAFacebookManager *instance = nil;
    
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

#pragma mark - Public Methods

- (void)logInWithFacebookWithSuccess:(void (^)(NSString *accessToken))success
                             failure:(void (^)(NSError *error))failure
{
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_birthday"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            NSString *accessToken = session.accessTokenData.accessToken;
            
            if (success) {
                success(accessToken);
            }
        } else {
            if (failure && error) {
                failure(error);
            }
        }
    }];
}

@end
