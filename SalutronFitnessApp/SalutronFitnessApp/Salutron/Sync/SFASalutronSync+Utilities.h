//
//  SFASalutronSync+Utilities.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 6/17/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronSync.h"

@class StatisticalDataHeaderEntity;

static NSUInteger const deviceNotFoundInCoreData = -1;

@interface SFASalutronSync (Utilities)

- (BOOL)isWatchModelR450:(int)numDevice;

// Check if mac address in NSUserDefaults is not empty
- (BOOL)isMacAddressEmpty;

- (BOOL)isConnectedToWatchWithMacAddress:(NSString *)macAddress;

- (BOOL)isConnectedToWatchWithUUID:(NSString *)uuid;

- (BOOL)isDataPointComplete:(StatisticalDataHeaderEntity *)headerEntity;

// return deviceNotFoundInCoreData = -1 if device uuid not found in CoreData
- (NSInteger)deviceIndexForNumDevice:(int)numDevice;

- (BOOL)settingsChangedWithWatchTimeDate:(TimeDate *)timeDate salutronuserProfile:(SalutronUserProfile *)salutronUserProfile stepGoal:(int)stepGoal distanceGoal:(double)distanceGoal calorieGoal:(int)calorieGoal sleepSettings:(SleepSetting *)sleepSetting notification:(Notification *)notification;

- (BOOL)settingsChangedWithWatchTimeDate:(TimeDate *)timeDate salutronuserProfile:(SalutronUserProfile *)salutronUserProfile stepGoal:(int)stepGoal distanceGoal:(double)distanceGoal calorieGoal:(int)calorieGoal sleepSettings:(SleepSetting *)sleepSetting notification:(Notification *)notification inactiveAlert:(InactiveAlert *)inactiveAlert dayLightAlert:(DayLightAlert *)dayLightAlert nightLightAlert:(NightLightAlert *)nightLightAlert wakeupAlert:(Wakeup *)wakeupAlert;

- (BOOL)settingsChangedWithWatchTimeDate:(TimeDate *)timeDate salutronuserProfile:(SalutronUserProfile *)salutronUserProfile stepGoal:(int)stepGoal distanceGoal:(double)distanceGoal calorieGoal:(int)calorieGoal sleepSettings:(SleepSetting *)sleepSetting workoutSetting:(WorkoutSetting *)workoutSetting;

// salutron sync delegate methods

- (void)establishConnection;

- (void)startSyncing;

- (void)startSyncOnDataHeaders;

- (void)startSyncOnDataPoints;

- (void)startSyncOnLightDataPoints;

- (void)startSyncOnStepGoal;

- (void)startSyncOnDistanceGoal;

- (void)startSyncOnCalorieGoal;

- (void)startSyncOnNotification;

- (void)startSyncOnAlerts;

- (void)startSyncOnSleepSettings;

- (void)startSyncOnCalibrationData;

- (void)startSyncOnWorkoutDatabase;

- (void)startSyncOnWorkoutStopDatabase;

- (void)startSyncOnSleepDatabase;

- (void)startSyncOnUserProfile;

- (void)startSyncOnTimeAndDate;

- (void)finishedSyncing;

- (void)settingsChanged;

- (void)startSearchConnectedDevice:(BOOL)found;

- (void)startDeviceConnectedFromSearching;

- (void)startRetrieveConnectedDeviceFromSearching;

@end
