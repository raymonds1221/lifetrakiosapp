//
//  SleepSettingEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "JDACoreData.h"

#import "DeviceEntity.h"

#import "Sleep_Setting.h"

#import "SleepSettingEntity+Data.h"

@implementation SleepSettingEntity (Data)

+ (SleepSettingEntity *)sleepSettingWithSleepSetting:(SleepSetting *)sleepSetting forDeviceEntity:(DeviceEntity *)device
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    
    if (!device.sleepSetting) {
        device.sleepSetting = [coreData insertNewObjectWithEntityName:SLEEP_SETTING_ENTITY];
    }
    
    device.sleepSetting.sleepGoalLo = @(sleepSetting.sleep_goal_lo);
    device.sleepSetting.sleepGoalHi = @(sleepSetting.sleep_goal_hi);
    device.sleepSetting.sleepMode   = @(sleepSetting.sleep_mode);
    
    [coreData save];
    
    return device.sleepSetting;
}

@end
