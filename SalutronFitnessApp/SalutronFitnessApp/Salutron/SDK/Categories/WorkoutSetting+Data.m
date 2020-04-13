//
//  WorkoutSetting+Data.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/10/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import "WorkoutSetting+Data.h"
#import "WorkoutSetting+Coding.h"

@implementation WorkoutSetting (Data)

+ (WorkoutSetting *)workoutSettingWithDictionary:(NSDictionary *)dictionary
{
    WorkoutSetting *workoutSetting = [[WorkoutSetting alloc] init];
    
    NSNumber *hrLogRate             = [dictionary objectForKey:API_WORKOUT_SETTING_HR_LOG_RATE];
    NSNumber *databaseUsage         = [dictionary objectForKey:API_WORKOUT_SETTING_DATABASE_USAGE];
    NSNumber *databaseUsageMax      = [dictionary objectForKey:API_WORKOUT_SETTING_DATABASE_USAGE_MAX];
    NSNumber *reconnectionTimeout   = [dictionary objectForKey:API_WORKOUT_SETTING_RECONNECT_TIMEOUT];
    
    workoutSetting.HRLogRate        = hrLogRate.intValue;
    workoutSetting.databaseUsage    = databaseUsage.intValue;
    workoutSetting.databaseUsageMax = databaseUsageMax.intValue;
    workoutSetting.reconnectTimeout = reconnectionTimeout.intValue;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:workoutSetting];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:WORKOUT_SETTING];
    [userDefaults synchronize];
    
    return workoutSetting;
}

- (NSDictionary *)dictionary
{
    NSDictionary *dictionary = @{
                                 API_WORKOUT_SETTING_HR_LOG_RATE        : @(self.HRLogRate),
                                 API_WORKOUT_SETTING_DATABASE_USAGE     : @(self.databaseUsage),
                                 API_WORKOUT_SETTING_DATABASE_USAGE_MAX : @(self.databaseUsageMax),
                                 API_WORKOUT_SETTING_RECONNECT_TIMEOUT  : @(self.reconnectTimeout)
                                 };
    
    return dictionary;
}

@end
