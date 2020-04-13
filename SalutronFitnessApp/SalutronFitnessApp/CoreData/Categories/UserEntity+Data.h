//
//  UserEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/19/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "UserEntity.h"

@interface UserEntity (Data)

+ (UserEntity *)insertUserEntityWithEmailAddress:(NSString *)emailAddress
                                       firstName:(NSString *)firstName
                                        lastName:(NSString *)lastName
                                        imageURL:(NSString *)imageURL
                                     accessToken:(NSString *)accessToken
                                          userID:(NSString *)userID
                                 newlyRegistered:(NSNumber *)newlyRegistered;

+ (UserEntity *)userEntityWithEmailAddress:(NSString *)emailAddress;

@end
