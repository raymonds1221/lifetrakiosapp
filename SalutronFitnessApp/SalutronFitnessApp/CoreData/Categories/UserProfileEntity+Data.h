//
//  UserProfileEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "UserProfileEntity.h"
#import "SalutronUserProfile+Data.h"

@interface UserProfileEntity (Data)

+ (UserProfileEntity *)userProfileWithSalutronUserProfile:(SalutronUserProfile *)userProfile forDeviceEntity:(DeviceEntity *)device;

@end
