//
//  SalutronSDK.h
//  BLEManager
//
//  Created by Herman on 2/21/13.
//  Copyright (c) 2013 GV Concepts Inc. All rights reserved.
//
//  All information and materials contained herein are owned by GV Concepts, Inc.
//  and is protected by U.S. and international copyright laws.
//  All use, disclosure, dissemination, transfer, publication or reproduction
//  of these materials, in whole or in part, is prohibited, unless authorized
//  in writing by GV Concepts, Inc.
//  If copies of these materials are made with written authorization of
//  GV Concepts, Inc, all copies must contain this notice.
//

/*
 Abstract: This class is used to setup and communicate with C400 device.
 */

#import <Foundation/Foundation.h>
#import "DeviceDetail.h"
#import "ErrorCodes.h"
#import "TimeDate.h"
#import "SalutronUserProfile.h"
#import "Sleep_Setting.h"
#import "Calibration_Data.h"
#import "SalutronVibra.h"
#import "Wakeup.h"
#import "Notification.h"
#import "R500.h"
#import "ModelNumber.h"
#import "Timing.h"
#import "InactiveAlert.h"
#import "DayLightAlert.h"
#import "NightLightAlert.h"
#import "LightCoeff.h"
#import "FatigueAlert.h"
#import "AlertnessResetsDB.h"
#import "WorkoutSetting.h"

@protocol SalutronSDKDelegate <NSObject>

@required
- (void)didDiscoverDevice:(int)numDevice withStatus:(Status)status;
- (void)didConnectAndSetupDeviceWithStatus:(Status)status;
- (void)didDisconnectDevice:(Status)status;
- (void)didRetrieveConnectedDevice:(int)numDevice withStatus:(Status)status;

@optional
//- (void)didGetBattLevel:(NSString *)battLevelString withStatus:(Status)status;
- (void)didGetModelNumber:(ModelNumber *)modelNumber withStatus:(Status)status;
- (void)didGetStatisticalDataHeaders:(NSArray *)statisticalDataHeaders withStatus:(Status)status;
- (void)didGetStatisticalSleepDataHeaders:(NSArray *)statisticalDataHeaders withStatus:(Status)status;
- (void)didGetSleepDatabase:(NSArray *)sleepdatabase withStatus:(Status)status;                         //kevin 18/07/13
- (void)didGetWorkoutStopDatabase:(NSArray *)workoutstopdatabase withStatus:(Status)status;                         //kevin 28/03/14
- (void)didGetDataPointsOfSelectedDateStamp:(NSArray *)dataPoints withStatus:(Status)status;
- (void)didGetDataPointsOfSelectedDateStampFromDataPoint:(NSArray *)dataPoints withStatus:(Status)status;
- (void)didGetWeightTrackDatabase:(NSArray *)weightTrackDatabase withStatus:(Status)status;
- (void)didGetAlertnessResetsDatabase:(NSArray *)alertnessResets withStatus:(Status)status;
- (void)didGetWorkoutDatabase:(NSArray *)workoutDatabase withStatus:(Status)status;
- (void)didGetUserProfile:(SalutronUserProfile *)userProfile withStatus:(Status)status;
- (void)didUpdateUserProfileWithStatus:(Status)status;
- (void)didGetVibra:(int)vibra withStatus:(Status)status;
- (void)didUpdateVibraWithStatus:(Status)status;
- (void)didGetWakeup:(Wakeup *)wakeup withStatus:(Status)status;
- (void)didUpdateWakeupWithStatus:(Status)status;
- (void)didGetSleepSetting:(SleepSetting *)sleepSetting withStatus:(Status)status;
- (void)didUpdateSleepSettingWithStatus:(Status)status;
- (void)didGetCalibrationData:(CalibrationData *)calibrationData withStatus:(Status)status;
- (void)didUpdateCalibrationDataWithStatus:(Status)status;
- (void)didGetDistanceGoal:(double)distanceGoal withStatus:(Status)status;
- (void)didUpdateDistanceGoalWithStatus:(Status)status;
- (void)didGetCalorieGoal:(int)calorieGoal withStatus:(Status)status;
- (void)didUpdateCalorieGoalWithStatus:(Status)status;
- (void)didGetStepGoal:(int)stepGoal withStatus:(Status)status;
- (void)didUpdateStepGoalWithStatus:(Status)status;
- (void)didGetCurrentTimeAndDate:(TimeDate *)timeDate withStatus:(Status)status;
- (void)didUpdateTimeAndDateWithStatus:(Status)status;

- (void)didGetNotification:(Notification *)notify withStatus:(Status)status;
- (void)didUpdateNotificationWithStatus:(Status)status;
- (void)didSetNotiStatusWithStatus:(Status)status;

- (void)didGetHeartRate:(NSString *)heartrate withStatus:(Status)status;
- (void)didGetRRInterval:(NSData *)RRInterval withStatus:(Status)status;

- (void)didGetTiming:(Timing *)timing withStatus:(Status)status;
- (void)didUpdateTimingWithStatus:(Status)status;

- (void)didGetInactiveAlert:(InactiveAlert *)inactiveAlert withStatus:(Status)status;
- (void)didUpdateInactiveAlertWithStatus:(Status)status;
- (void)didGetDayLightAlert:(DayLightAlert *)dayLightAlert withStatus:(Status)status;
- (void)didUpdateDayLightAlertWithStatus:(Status)status;
- (void)didGetNightLightAlert:(NightLightAlert *)nightLightAlert withStatus:(Status)status;
- (void)didUpdateNightLightAlertWithStatus:(Status)status;

- (void)didGetFatigueAlertSetting:(FatigueAlert *)fatigueAlert withStatus:(Status)status;
- (void)didUpdateFatigueAlertSettingWithStatus:(Status)status;

- (void)didGetLightData:(NSArray *)dataPoints withStatus:(Status)status;
- (void)didGetLightCoeff:(LightCoeff *)lightCoeff withStatus:(Status)status;
- (void)didUpdateLightCoeffWithStatus:(Status)status;

- (void)didGetWorkoutSetting:(WorkoutSetting *)workoutSetting withStatus:(Status)status;    // LEO
- (void)didUpdateWorkoutSettingWithStatus:(Status)status;           // LEO

- (void)didUpdateManufacturingWithStatus:(Status)status;
@end

@interface SalutronSDK : NSObject
{
    NSData *modelnumber;
    NSString *modelNumberString;
}

@property (weak, nonatomic) id<SalutronSDKDelegate> delegate;
@property( nonatomic, assign ) NSTimeInterval loopInterval;
@property( nonatomic, retain ) NSTimer *timerLoop;
@property( nonatomic, assign ) int vibra_repeat;
@property( nonatomic, assign ) int vibra_end;
@property( nonatomic, assign ) int vibra_type;
@property( nonatomic, assign ) int vibra_init;


+ (id)sharedInstance;

+ (NSString*)getVersion;
//- (NSString*)getModelNumberString;
//- (int)getModelNumber;
- (Status)discoverDevice:(int)timeout;
- (Status)getNumDiscoveredDevice:(int *)num;
- (Status)clearDiscoveredDevice;
- (Status)getDeviceDetail:(int)index with:(DeviceDetail **)deviceDetail;
- (Status)connectDevice:(int)index;
- (Status)disconnectDevice;
- (Status)retrieveConnectedDevice;
- (Status)commDone;
- (Status)getModelNumber;
- (Status)getBattLevel;
- (DeviceDetail*)getConnectedDeviceDetail;

- (Status)getBattLevel:(NSString **)battLevel;
- (Status)getFirmwareRevision:(NSString **)firmwareRevision;
- (Status)getSoftwareRevision:(NSString **)softwareRevision;
- (Status)getMacAddress:(NSString **)macAddress;
- (Status)getModelNumber:(NSString **)modelNumber;
- (Status)getStatisticalDataHeaders;
- (Status)getSleepDatabase;                                                                             //kevin 18/07/13
- (Status)getWorkoutStopDatabase:(int)workoutIndex;                                                      //kevin 28/03/14
- (Status)getDataPointsOfSelectedDateStamp:(int)headerIndex;
- (Status)getDataPointsOfSelectedDateStamp:(int)headerIndex fromDataPoint:(int)dataPointIndex;
- (Status)getWeightTrackDatabase;
- (Status)getAlertnessResetsDatabase;       // Kevin 11/11/14
- (Status)getWorkoutDatabase;
- (Status)getUserProfile;
- (Status)updateUserProfile:(SalutronUserProfile *)userProfile;
- (Status)getVibra:(int)datatype;
- (Status)testVibra:(int)datatype;
- (Status)updateVibra:(int)datatype;
- (Status)getWakeup:(int)datatype;
- (Status)updateWakeup:(Wakeup *)wakeup;
- (Status)getInactiveAlert:(int)datatype;
- (Status)updateInactiveAlert:(InactiveAlert *)inactiveAlert;
- (Status)getDayLightAlert:(int)datatype;
- (Status)updateDayLightAlert:(DayLightAlert *)dayLightAlert;
- (Status)getNightLightAlert:(int)datatype;
- (Status)updateNightLightAlert:(NightLightAlert *)nightLightAlert;

- (Status)getWorkoutSetting:(int)datatype;                          // LEO
- (Status)updateWorkoutSetting:(WorkoutSetting *)workoutSetting;    // LEO

- (Status)getFatigueAlertSetting:(int)datatype;                         // Kevin 11/11/14
- (Status)updateFatigueAlertSetting:(FatigueAlert *)fatigueAlert;       // Kevin 11/11/14

- (Status)getSleepSetting;
- (Status)updateSleepSetting:(SleepSetting *)sleepSetting;
- (Status)getCalibrationData:(int)datatype;
- (Status)updateCalibrationData:(CalibrationData *)calibrationData;
- (Status)getDistanceGoal;
- (Status)updateDistanceGoal:(double)distanceGoal;
- (Status)getCalorieGoal;
- (Status)updateCalorieGoal:(int)calorieGoal;
- (Status)getStepGoal;
- (Status)updateStepGoal:(int)stepGoal;
- (Status)getCurrentTimeAndDate;
- (Status)updateTimeAndDate:(TimeDate *)timeDate;

- (Status)getNotification;
- (Status)updateNotification:(Notification *)notify;
- (Status)setNotiStatus:(int)status;

- (Status)enableR500demo;
- (Status)disableR500demo;

- (Status)getTiming:(int)datatype;
- (Status)updateTiming:(Timing *)timing;

- (Status)updateManufacturing:(int)type;

- (Status)updateRawData:(NSData *)raw;

- (Status)getLightData:(int)headerIndex;
- (Status)getLightCoeff:(int)lightCoeffIndex;
- (Status)updateLightCoeff:(LightCoeff *)lightCoeff;
@end
