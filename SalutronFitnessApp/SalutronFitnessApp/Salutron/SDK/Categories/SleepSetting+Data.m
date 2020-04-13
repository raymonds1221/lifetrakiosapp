//
//  SleepSetting+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SleepSettingEntity.h"

#import "SleepSetting+Data.h"

@implementation SleepSetting (Data)

#pragma mark - Private Methods

- (NSString *)sleepModeString
{
    /*
    if (self.sleep_mode == MANUAL) {
        return @"manual";
    } else if (self.sleep_mode == AUTO) {
        return @"auto";
    }
    */
    return @"manual";
}

#pragma mark - Public Methods

+ (SleepSetting *)sleepSetting
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSData *data                    = [userDefaults dataForKey:SLEEP_SETTING];
    SleepSetting *sleepSetting      = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (!sleepSetting) {
        sleepSetting = [SleepSetting new];
    }
    
    return sleepSetting;
}

+ (SleepSetting *)sleepSettingWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
       // NSString *sleepModeString   = [dictionary objectForKey:API_SLEEP_SETTINGS_SLEEP_MODE];
        SleepSetting *sleepSetting  = [[SleepSetting alloc] init];
        sleepSetting.sleep_goal_lo  = [[dictionary objectForKey:API_SLEEP_SETTINGS_SLEEP_GOAL_LO] integerValue];
        sleepSetting.sleep_goal_hi  = [[dictionary objectForKey:API_SLEEP_SETTINGS_SLEEP_GOAL_HI] integerValue];
        sleepSetting.sleep_mode     = MANUAL;//[sleepModeString isEqualToString:@"manual"] ? MANUAL : AUTO;
        
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:sleepSetting];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:data forKey:SLEEP_SETTING];
        
        return sleepSetting;
    }
    
    return nil;
}

+ (SleepSetting *)sleepSettingWithSleepSettingEntity:(SleepSettingEntity *)entity
{
    SleepSetting *sleepSetting  = [SleepSetting new];
    sleepSetting.sleep_goal_lo  = entity.sleepGoalLo.integerValue;
    sleepSetting.sleep_goal_hi  = entity.sleepGoalHi.integerValue;
    sleepSetting.sleep_mode     = entity.sleepMode.integerValue;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sleepSetting];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:SLEEP_SETTING];
    
    return sleepSetting;
}
    
- (NSDictionary *)dictionary
{
    NSDictionary *dictionary = @{API_SLEEP_SETTINGS_SLEEP_GOAL_LO   : @(self.sleep_goal_lo),
                                 API_SLEEP_SETTINGS_SLEEP_GOAL_HI   : @(self.sleep_goal_hi),
                                 API_SLEEP_SETTINGS_SLEEP_MODE      : [self sleepModeString]};
    
    return dictionary;
}

@end
