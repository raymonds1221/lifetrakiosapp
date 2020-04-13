//
//  UserProfileEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Format.h"

#import "JDACoreData.h"

#import "DeviceEntity.h"

#import "SH_Date.h"

#import "UserProfileEntity+Data.h"

@implementation UserProfileEntity (Data)

+ (UserProfileEntity *)userProfileWithSalutronUserProfile:(SalutronUserProfile *)userProfile forDeviceEntity:(DeviceEntity *)device
{
    // Birthday
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.month                = userProfile.birthday.month;
    components.day                  = userProfile.birthday.day;
    components.year                 = userProfile.birthday.year + DATE_YEAR_ADDER;
    NSDate *birthday                = [calendar dateFromComponents:components];
    JDACoreData *coreData           = [JDACoreData sharedManager];
    
    if (!device.userProfile) {
        device.userProfile = [coreData insertNewObjectWithEntityName:USER_PROFILE_ENTITY];
    }
    
    device.userProfile.birthday     = birthday;
    device.userProfile.gender       = @(userProfile.gender);
    device.userProfile.unit         = @(userProfile.unit);
    device.userProfile.sensitivity  = @(userProfile.sensitivity);
    device.userProfile.weight       = @(userProfile.weight);
    device.userProfile.height       = @(userProfile.height);
    
    [coreData save];
    
    return device.userProfile;
}

@end
