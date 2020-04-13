//
//  SleepSettingEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SleepSettingEntity.h"

@class SleepSetting;

@interface SleepSettingEntity (Data)

+ (SleepSettingEntity *)sleepSettingWithSleepSetting:(SleepSetting *)sleepSetting forDeviceEntity:(DeviceEntity *)device;

@end
