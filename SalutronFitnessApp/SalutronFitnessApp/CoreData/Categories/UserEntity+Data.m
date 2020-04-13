//
//  UserEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/19/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "JDACoreData.h"

#import "UserEntity+Data.h"

@implementation UserEntity (Data)

+ (UserEntity *)insertUserEntityWithEmailAddress:(NSString *)emailAddress
                                       firstName:(NSString *)firstName
                                        lastName:(NSString *)lastName
                                        imageURL:(NSString *)imageURL
                                     accessToken:(NSString *)accessToken
                                          userID:(NSString *)userID
                                 newlyRegistered:(NSNumber *)newlyRegistered
{
    JDACoreData *coreData   = [JDACoreData sharedManager];
    UserEntity *user        = [UserEntity userEntityWithEmailAddress:emailAddress];
    
    if (!user) {
        user                = [coreData insertNewObjectWithEntityName:USER_ENTITY];
        user.emailAddress   = emailAddress;
        user.firstName      = firstName;
        user.lastName       = lastName;
        user.accessToken    = accessToken;
        user.newlyRegistered = newlyRegistered;
        user.userID         = userID;
    }
    if (user.userID.length == 0) {
        user.userID         = userID;
    }
    user.imageURL           = imageURL;
    
    [coreData save];
    
    return user;
}

+ (UserEntity *)userEntityWithEmailAddress:(NSString *)emailAddress
{
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"emailAddress == %@", emailAddress];
    JDACoreData *coreData   = [JDACoreData sharedManager];
    NSArray *result         = [coreData fetchEntityWithEntityName:USER_ENTITY predicate:predicate limit:1];
    
    return result.firstObject;
}

@end
