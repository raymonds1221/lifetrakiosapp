//
//  SFASalutronSaveData.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 7/18/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SalutronSDK.h"
#import "SFAHealthKitManager.h"

@class DeviceEntity, DeviceDetail, SleepSetting, Notification, CalibrationData, TimeDate, SalutronUserProfile;

@interface SFASalutronSaveData : NSObject

// Save mac address to NSUserDefaults
- (Status)saveMacAddress;

// Save firmware version to NSUserDefaults
- (Status)saveFirmwareVersion;

// Save software version to NSUserDefaults
- (Status)saveSoftwareVersion;

// Device entity
- (void)saveDeviceEntityWithDeviceDetail:(DeviceDetail *)deviceDetail;

// Statistical data headers
- (void)saveStatisticalDataHeaders:(NSArray *)statisticalDataHeaders dataHeaderEntityArray:(NSMutableArray *__autoreleasing *)dataHeaderEntityArray;

// Data points
- (void)saveDatapoints:(NSArray *)dataPointsArray lightDataPoints:(NSArray *)lightDataPointsArray statisticalDataHeaderEntity:(NSArray *)statisticalDataHeaderEntityArray;
//- (void)saveDatapoints:(NSArray *)dataPointsArray statisticalDataHeaderEntity:(NSArray *)statisticalDataHeaderEntityArray;

// Light Data points
//- (void)saveLightDatapoints:(NSArray *)lightDataPointsArray rgbCoefficientDictionary:(NSDictionary *)rgbCoefficientDictionary statisticalDataHeaderEntity:(NSArray *)statisticalDataHeaderEntityArray;

// Workout database
- (void)saveWorkoutDatabase:(NSArray *)workoutDatabase workoutStopDatabase:(NSDictionary *)workoutstopdatabase;

// Sleep database
- (void)saveSleepDatabase:(NSArray *)sleepDatabaseArray;

// Wake up
- (void)saveWakeUp:(NSArray *)wakeUpArray;

// Goals : step, distance, calorie, sleepsettings
- (void)saveGoalsWithStepGoal:(int)stepGoal distanceGoal:(double)distanceGoal calorieGoal:(int)calorieGoal sleepSettings:(SleepSetting *)sleepSetting;

- (void)saveNotification:(Notification *)notification notificationStatus:(BOOL)notificationStatus;

- (void)saveTiming:(Timing *)timing;

// Calibration data
- (void)saveCalibrationDataArray:(NSArray *)calibratonDataArray calibrationData:(CalibrationData *__autoreleasing *)calibrationData;

// Time and Date
- (void)saveTimeDate:(TimeDate *)timeDate;

// Salutron User Profile
- (void)saveSalutronUserProfile:(SalutronUserProfile *)salutronUserProfile;

- (void)saveInactiveAlertArray:(NSArray *)inactiveAlertArray inactiveAlert:(InactiveAlert *__autoreleasing *)inactiveAlert;

- (void)saveDayLightAlertArray:(NSArray *)dayLightAlertArray dayLightAlert:(DayLightAlert *__autoreleasing *)dayLightAlert;

- (void)saveNightLightAlertArray:(NSArray *)nightLightAlertArray nightLightAlert:(NightLightAlert *__autoreleasing *)nightLightAlert;

- (void)saveWakeupAlertArray:(NSArray *)wakeupAlertSetting wakeupAlert:(Wakeup *__autoreleasing *)wakeupAlert;

// Save watchData

- (DeviceEntity *)saveWatchDataWithDeviceEntity:(DeviceEntity *)deviceEntity statisticalDataHeaders:(NSArray *)statisticalDataHeaders dataPoints:(NSArray *)dataPoints lightDataPoints:(NSArray *)lightDataPoints workoutDB:(NSArray *)workoutDatabase workoutStopDB:(NSDictionary *)workoutStopDatabase sleepDB:(NSArray *)sleepDatabase;

- (DeviceEntity *)saveWatchDataWithDeviceEntity:(DeviceEntity *)deviceEntity statisticalDataHeaders:(NSArray *)statisticalDataHeaders dataPoints:(NSArray *)dataPoints workoutDB:(NSArray *)workoutDatabase workoutStopDB:(NSDictionary *)workoutStopDatabase sleepDB:(NSArray *)sleepDatabase wakeUpArray:(NSArray *)wakeUpArray stepGoal:(NSInteger)stepGoal distanceGoal:(CGFloat)distanceGoal calorieGoal:(NSInteger)calorieGoal notification:(Notification *)notification sleepSetting:(SleepSetting *)sleepSetting calibrationDataArray:(NSArray *)calibrationDataArray salutronUserProfile:(SalutronUserProfile *)salutronUserProfile timeDate:(TimeDate *)timeDate lightDataPoints:(NSArray *)lightDataPoints inactiveAlertArray:(NSMutableArray *)inactiveAlertArray dayLightAlertArray:(NSMutableArray *)dayLightAlertArray nightLightAlertArray:(NSMutableArray *)nightLightAlertArray notificationStatus:(BOOL)notificationStatus timing:(Timing *)timing;

- (DeviceEntity *)saveWatchDataWithDeviceEntity:(DeviceEntity *)deviceEntity statisticalDataHeaders:(NSArray *)statisticalDataHeaders dataPoints:(NSArray *)dataPoints workoutDB:(NSArray *)workoutDatabase sleepDB:(NSArray *)sleepDatabase stepGoal:(NSInteger)stepGoal distanceGoal:(CGFloat)distanceGoal calorieGoal:(NSInteger)calorieGoal sleepSetting:(SleepSetting *)sleepSetting calibrationDataArray:(NSArray *)calibrationDataArray salutronUserProfile:(SalutronUserProfile *)salutronUserProfile timeDate:(TimeDate *)timeDate notificationStatus:(BOOL)notificationStatus workoutSetting:(NSArray *)workoutSettingArray;

@end
