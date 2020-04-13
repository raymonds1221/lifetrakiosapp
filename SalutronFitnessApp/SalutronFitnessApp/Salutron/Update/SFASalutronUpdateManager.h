//
//  SFASalutronUpdateGoals.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 7/18/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronSyncDelegate.h"


@protocol SFASalutronUpdateManagerDelegate <NSObject>
@optional
- (void)updateStarted;
- (void)updateFinishedWithStatus:(Status)status;
@end

typedef void(^UpdateManagerFinishedUpdate)(BOOL );
static float const selectorTimeout = 0.75;

@interface SFASalutronUpdateManager : NSObject

@property (weak, nonatomic) id<SFASalutronSyncDelegate> delegate;
@property (strong, nonatomic) id<SFASalutronUpdateManagerDelegate> managerDelegate;

+ (instancetype)sharedInstance;

- (void)startUpdateGoalsWithWatchModel:(WatchModel)watchModel salutronUserProfile:(SalutronUserProfile *)salutronUserProfile sleepSetting:(SleepSetting *)sleepSetting distanceGoal:(double)distanceGoal calorieGoal:(int)calorieGoal stepGoal:(int)stepGoal sleepGoal:(int)sleepGoal daylightAlert:(DayLightAlert*)daylightAlert timeDate:(TimeDate *)timeDate;

- (void)startUpdateSettingsWithWatchModel:(WatchModel)watchModel salutronUserProfile:(SalutronUserProfile *)salutronUserProfile timeDate:(TimeDate *)timeDate sleepSettings:(SleepSetting *)sleepSettings wakeUp:(Wakeup *)wakeUp calibrationData:(CalibrationData *)calibrationData notification:(Notification *)notification inactiveAlert:(InactiveAlert *)inactiveAlert dayLightAlert:(DayLightAlert *)dayLightAlert nightLightAlert:(NightLightAlert *)nightLightAlert notificationStatus:(BOOL)notificationStatus timing:(Timing *)timing;

- (void)startUpdateAllWithWatchModel:(WatchModel)watchModel salutronUserProfile:(SalutronUserProfile *)salutronUserProfile sleepSetting:(SleepSetting *)sleepSetting distanceGoal:(double)distanceGoal calorieGoal:(int)calorieGoal stepGoal:(int)stepGoal sleepGoal:(int)sleepGoal  timeDate:(TimeDate *)timeDate wakeUp:(Wakeup *)wakeUp calibrationData:(CalibrationData *)calibrationData notification:(Notification *)notification inactiveAlert:(InactiveAlert *)inactiveAlert dayLightAlert:(DayLightAlert *)dayLightAlert nightLightAlert:(NightLightAlert *)nightLightAlert notificationStatus:(BOOL)notificationStatus timing:(Timing *)timing;

- (void)startUpdateSettingsWithWatchModel:(WatchModel)watchModel salutronUserProfile:(SalutronUserProfile *)salutronUserProfile timeDate:(TimeDate *)timeDate sleepSettings:(SleepSetting *)sleepSettings wakeUp:(Wakeup *)wakeUp calibrationData:(CalibrationData *)calibrationData notification:(Notification *)notification inactiveAlert:(InactiveAlert *)inactiveAlert dayLightAlert:(DayLightAlert *)dayLightAlert nightLightAlert:(NightLightAlert *)nightLightAlert notificationStatus:(BOOL)notificationStatus timing:(Timing *)timing workoutSetting:(WorkoutSetting *)workoutSetting;



- (void)startUpdateNotificationStatusWithWatchModel:(WatchModel)watchModel notificationStatus:(BOOL)notificationStatus;

- (void)startUpdateNotificationWithWatchModel:(WatchModel)watchModel withNotification:(Notification *)notification;

- (void)startUpdateAllNotificationsWithWatchModel:(WatchModel)watchModel notification:(Notification *)notification notificationStatus:(BOOL)notificationStatus;

- (void)startResetWorkoutDatabase:(WatchModel)watchModel workoutSetting:(WorkoutSetting *)workoutSetting;

- (void)cancelSyncing;

@end


