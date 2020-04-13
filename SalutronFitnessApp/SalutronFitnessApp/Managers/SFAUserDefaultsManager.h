//
//  SFAUserDefaultsManager.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 6/16/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Wakeup.h"
#import "Timing.h"
#import "WorkoutSetting+Coding.h"

typedef NS_ENUM(NSUInteger, SyncOption) {
    SyncOptionNone = 0,
    SyncOptionApp,
    SyncOptionWatch
};

@interface SFAUserDefaultsManager : NSObject

@property (strong, nonatomic) NSUserDefaults *userDefaults;

+ (instancetype)sharedManager;

- (void)clearUserDefaults;

@property (strong, nonatomic) CalibrationData       *calibrationData;
@property (strong, nonatomic) Notification          *notification;
@property (strong, nonatomic) SalutronUserProfile   *salutronUserProfile;
@property (strong, nonatomic) SleepSetting          *sleepSetting;
@property (strong, nonatomic) TimeDate              *timeDate;
@property (assign, nonatomic) WatchModel            watchModel;
@property (strong, nonatomic) Wakeup                *wakeUp;
@property (strong, nonatomic) InactiveAlert         *inactiveAlert;
@property (strong, nonatomic) DayLightAlert         *dayLightAlert;
@property (strong, nonatomic) NightLightAlert       *nightLightAlert;
@property (strong, nonatomic) Timing                *timing;
@property (strong, nonatomic) WorkoutSetting        *workoutSetting;
@property (assign, nonatomic) int                   watchFace;
@property (strong, nonatomic) NSDate                *selectedDateFromCalendar;

@property (strong, nonatomic) NSDate                *lastSyncedDate;
@property (strong, nonatomic) NSString              *deviceUUID;
@property (strong, nonatomic) NSString              *firmwareRevision;
@property (strong, nonatomic) NSString              *macAddress;
@property (strong, nonatomic) NSString              *softwareRevision;
@property (strong, nonatomic) NSString              *signUpDeviceMacAddress;
@property (assign, nonatomic) double                distanceGoal;
@property (assign, nonatomic) int                   calorieGoal;
@property (assign, nonatomic) int                   sleepGoal;
@property (assign, nonatomic) int                   stepGoal;
@property (assign, nonatomic) BOOL                  cloudSyncEnabled;
@property (assign, nonatomic) BOOL                  hasPaired;
@property (assign, nonatomic) BOOL                  promptChangeSettings;
@property (assign, nonatomic) BOOL                  autoSyncToWatchEnabled;
@property (assign, nonatomic) BOOL                  notificationStatus;
@property (assign, nonatomic) BOOL                  autoSyncTimeEnabled;
@property (assign, nonatomic, getter=isBlueToothOn) BOOL                  bluetoothOn;
@property (assign, nonatomic) SyncOption            syncOption;

@end
