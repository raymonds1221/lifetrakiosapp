//
//  SFAServerAccountManager.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/7/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "UserEntity.h"

#import <Foundation/Foundation.h>

@interface SFAServerAccountManager : NSObject

@property (readonly, nonatomic) NSString  *emailAddress;
@property (readonly, nonatomic) NSString  *password;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString  *refreshToken;
@property (strong, nonatomic) NSDate    *expiration;
@property (readonly, nonatomic) BOOL isLoggedIn;
@property (readonly, nonatomic) BOOL isFacebookLogIn;

@property (strong, nonatomic) UserEntity *user;

// Singleton Instance

+ (instancetype)sharedManager;

// Log In

- (void)logInWithEmailAddress:(NSString *)emailAddress
                     password:(NSString *)password
                      success:(void (^)())success
                      failure:(void (^)(NSError *error))failure;

// Facebook Log In

- (void)logInWithFacebookAccessToken:(NSString *)accessToken
                             success:(void (^)())success
                             failure:(void (^)(NSError *error))failure;

// Profile

- (void)getProfileWithSuccess:(void (^)())success
                      failure:(void (^)(NSError *error))failure;

- (void)updateProfileWithFirstName:(NSString *)firstName
                          lastName:(NSString *)lastName
                          password:(NSString *)password
                       oldPassword:(NSString *)oldPassword
                         userImage:(UIImage *)userImage
                           success:(void (^)())success
                           failure:(void (^)(NSError *))failure;

// Forgot Password

- (void)resetPasswordWithEmailAddress:(NSString *)emailAddress
                              success:(void (^)())success
                              failure:(void (^)(NSError *error))failure;

// Register

- (void)registerWithEmailAddress:(NSString *)emailAddress
                        password:(NSString *)password
                       firstName:(NSString *)firstName
                        lastName:(NSString *)lastName
                       userImage:(UIImage *)userImage
                         success:(void (^)())success
                         failure:(void (^)(NSError *error))failure;

// OAuth
- (void)refreshAccessTokenWithSuccess:(void (^)())success
                              failure:(void (^)(NSError *))failure;

- (BOOL)isAccessTokenExpired;

// Log Out

- (void)logOut;

@end
