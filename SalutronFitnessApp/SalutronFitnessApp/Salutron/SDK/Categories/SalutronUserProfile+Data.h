//
//  SalutronUserProfile+Data.h
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/18/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SalutronUserProfile.h"

@class UserProfileEntity;

@interface SalutronUserProfile (Data)

+ (void)saveWithSalutronUserProfile:(SalutronUserProfile *)userProfile;
+ (SalutronUserProfile *)getData;
+ (NSInteger)maxBPM;

+ (SalutronUserProfile *)userProfile;
+ (SalutronUserProfile *)userProfileWithDictionary:(NSDictionary *)dictionary;
+ (SalutronUserProfile *)userProfileWithUserProfileEntity:(UserProfileEntity *)userProfile;

- (NSDictionary *)dictionary;

@end