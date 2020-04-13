//
//  SFAFacebookManager.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/15/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFAFacebookManager : NSObject

// Singleton Instance

+ (SFAFacebookManager *)sharedManager;

// Facebook Log In

- (void)logInWithFacebookWithSuccess:(void (^)(NSString *accessToken))success
                             failure:(void (^)(NSError *error))failure;

@end
