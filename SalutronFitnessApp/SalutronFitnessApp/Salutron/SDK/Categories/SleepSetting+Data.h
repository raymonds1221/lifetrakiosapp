//
//  SleepSetting+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

@class SleepSettingEntity;

#import "Sleep_Setting.h"

@interface SleepSetting (Data)

+ (SleepSetting *)sleepSetting;
+ (SleepSetting *)sleepSettingWithDictionary:(NSDictionary *)dictionary;
+ (SleepSetting *)sleepSettingWithSleepSettingEntity:(SleepSettingEntity *)entity;

- (NSDictionary *)dictionary;

@end
