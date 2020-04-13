//
//  SFASettingsManager.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "CalibrationData+Data.h"
#import "Notification+Data.h"
#import "TimeDate+Data.h"
#import "SalutronUserProfile+Data.h"

#import "CalibrationDataEntity+Data.h"
#import "NotificationEntity+Data.h"
#import "TimeDateEntity+Data.h"

#import "Timing+Data.h"
#import "TimingEntity+Data.h"

#import "DeviceEntity.h"

#import "SFASettingsManager.h"
#import "SFAUserDefaultsManager.h"
#import "WorkoutSetting+Data.h"
#import "WorkoutSettingEntity+CoreDataProperties.h"

@interface SFASettingsManager ()

@property (strong, nonatomic) SFAUserDefaultsManager *userDefaultsManager;

@end

@implementation SFASettingsManager

#pragma mark - Singleton Instance

+ (SFASettingsManager *)sharedManager
{
    static SFASettingsManager *instance = nil;
    
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

#pragma mark - Lazy Loading

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [[SFAUserDefaultsManager alloc] init];
    }
    
    return _userDefaultsManager;
}

#pragma mark - Public Methods

- (void)settingsWithDictionary:(NSDictionary *)dictionary forDeviceEntity:(DeviceEntity *)device
{
    CalibrationData *calibrationData    = [CalibrationData calibrationDataWithDictionary:dictionary];
    Notification *notification          = [Notification notificationWithDictionary:dictionary];
    TimeDate *timeDate                  = [TimeDate timeDateWithDictionary:dictionary];
    Timing *timing                      = [Timing timingWithDictionary:dictionary];
    WorkoutSetting *workoutSetting      = [WorkoutSetting workoutSettingWithDictionary:dictionary];
    
    [CalibrationDataEntity calibrationDataWithCalibrationData:calibrationData forDeviceEntity:device];
    [NotificationEntity notificationWithNotification:notification notificationStatus:[SFAUserDefaultsManager sharedManager].notificationStatus forDeviceEntity:device];
    [TimeDateEntity timeDateWithTimeDate:timeDate forDeviceEntity:device];
    [TimingEntity timingWithTiming:timing forDeviceEntity:device];
    [WorkoutSettingEntity entityWithWorkoutSetting:workoutSetting forDeviceEntity:device];
}

- (NSDictionary *)dictionary
{
    CalibrationData *calibrationData            = [CalibrationData calibrationData];
    Notification *notification                  = [Notification notification];
    TimeDate *timeDate                          = [TimeDate timeDate];
    SalutronUserProfile *salutronUserProfile    = [SalutronUserProfile userProfile];
    
    Timing *timing                              = [SFAUserDefaultsManager sharedManager].timing;
    WorkoutSetting *workoutSetting              = self.userDefaultsManager.workoutSetting;
    
    
    NSMutableDictionary *dictionary             = [NSMutableDictionary new];
    
    
    [dictionary addEntriesFromDictionary:calibrationData.dictionary];
    [dictionary addEntriesFromDictionary:notification.dictionary];
    [dictionary addEntriesFromDictionary:timeDate.dictionary];
    [dictionary addEntriesFromDictionary:salutronUserProfile.dictionary];
    [dictionary addEntriesFromDictionary:timing.dictionary];
    [dictionary addEntriesFromDictionary:workoutSetting.dictionary];
    
    return dictionary;
}

@end
