//
//  SFASalutronUpdateGoals.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 7/18/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronUpdateManager.h"
#import "ErrorCodeToStringConverter.h"
#import "SFASalutronSaveData.h"
#import "TimeDate+Data.h"
#import "DeviceEntity+Data.h"
#import "WorkoutSetting+Coding.h"

#import "InactiveAlert+Coding.h"
#import "DayLightAlert+Coding.h"
#import "NightLightAlert+Coding.h"

static float const discoverTimeout = 15.0f;

@interface SFASalutronUpdateManager () <SalutronSDKDelegate>

@property (strong, nonatomic) SalutronSDK               *salutronSDK;
@property (strong, nonatomic) SFASalutronSaveData       *salutronSaveData;
@property (strong, nonatomic) SFAUserDefaultsManager    *userDefaultsManager;
@property (assign, nonatomic) WatchModel                watchModel;
@property (assign, nonatomic) NSInteger                 deviceIndex;
@property (assign, nonatomic) NSInteger                 calibrationType;
@property (assign, nonatomic) NSInteger                 notificationType;
@property (assign, nonatomic) NSInteger                 wakeupType;
@property (assign, nonatomic) NSInteger                 inactiveAlertType;
@property (assign, nonatomic) NSInteger                 dayLightAlertType;
@property (assign, nonatomic) NSInteger                 nightLightAlertType;
@property (assign, nonatomic) BOOL                      notificationStatus;
@property (assign, nonatomic, getter=isSyncing) BOOL    syncing;
@property (assign, nonatomic) NSInteger                 indexOfWorkoutSetting;

@property (assign, nonatomic) double                    distanceGoal;
@property (assign, nonatomic) int                       calorieGoal;
@property (assign, nonatomic) int                       sleepGoal;
@property (assign, nonatomic) int                       stepGoal;
@property (strong, nonatomic) CalibrationData           *calibrationData;
@property (strong, nonatomic) Notification              *notification;
@property (strong, nonatomic) SalutronUserProfile       *salutronUserProfile;
@property (strong, nonatomic) SleepSetting              *sleepSetting;
@property (strong, nonatomic) TimeDate                  *timeDate;
@property (strong, nonatomic) Wakeup                    *wakeup;
@property (strong, nonatomic) InactiveAlert             *inactiveAlertData;
@property (strong, nonatomic) DayLightAlert             *dayLightAlertData;
@property (strong, nonatomic) NightLightAlert           *nightLightAlertData;
@property (strong, nonatomic) Timing                    *timing;
@property (strong, nonatomic) WorkoutSetting            *workoutSetting;

@property (strong, nonatomic) NSMutableArray            *arrayOfSelector;
@property (nonatomic) int retryCount;
@property (nonatomic) BOOL isIndividualNotification;

@end

@implementation SFASalutronUpdateManager

#pragma mark - Singleton method

+ (instancetype)sharedInstance
{
    static SFASalutronUpdateManager *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

#pragma mark - Lazy loading of properties

- (SalutronSDK *)salutronSDK
{
    if (!_salutronSDK)
        _salutronSDK = [SalutronSDK sharedInstance];
    return _salutronSDK;
}

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

- (NSMutableArray *)arrayOfSelector
{
    if (!_arrayOfSelector) {
        _arrayOfSelector = [[NSMutableArray alloc] init];
    }
    return _arrayOfSelector;
}

- (SFASalutronSaveData *)salutronSaveData
{
    if (!_salutronSaveData) {
        _salutronSaveData = [[SFASalutronSaveData alloc] init];
    }
    return _salutronSaveData;
}

#pragma mark - Queue

- (void)enqueueSelector:(SEL)selector
{
    [self.arrayOfSelector addObject:[NSValue valueWithPointer:selector]];
}

- (void)dequeueSelector
{
    if (self.arrayOfSelector.count > 0) {
        [self.arrayOfSelector removeObjectAtIndex:0];
    }
}

- (SEL)nextSelectorOnQueue
{
    SEL sel = [[self.arrayOfSelector firstObject] pointerValue];
    
    //if (self.isSyncing)
        [self performSelector:sel];
    
    return sel;
}

#pragma mark - Public Methods

- (void)startUpdateGoalsWithWatchModel:(WatchModel)watchModel salutronUserProfile:(SalutronUserProfile *)salutronUserProfile sleepSetting:(SleepSetting *)sleepSetting distanceGoal:(double)distanceGoal calorieGoal:(int)calorieGoal stepGoal:(int)stepGoal sleepGoal:(int)sleepGoal daylightAlert:(DayLightAlert*)daylightAlert timeDate:(TimeDate *)timeDate
{
    self.watchModel = watchModel;
    self.syncing    = YES;
    
    /*if ([self.delegate respondsToSelector:@selector(didSyncStarted)]) {
        [self.delegate didSyncStarted];
    }*/
    
    self.salutronUserProfile    = salutronUserProfile;
    self.sleepSetting           = sleepSetting;
    self.distanceGoal           = distanceGoal;
    self.calorieGoal            = calorieGoal;
    self.stepGoal               = stepGoal;
    
    self.sleepGoal              = sleepGoal;
    self.dayLightAlertData      = daylightAlert;
    //self.timeDate               = timeDate;
    //self.timeDate.watchFace     = self.userDefaultsManager.watchFace;
    
    self.dayLightAlertData.level_low    = SFAAllLightDailyThresholdLow;
    self.dayLightAlertData.level_mid    = SFAAllLightDailyThresholdMed;
    self.dayLightAlertData.level_hi     = SFAAllLightDailyThresholdHigh;
    
    [self.arrayOfSelector removeAllObjects];
    //[self enqueueSelector:@selector(updateTimeAndDate)];
    [self enqueueSelector:@selector(updateUserProfile)];
    [self enqueueSelector:@selector(updateSleepSetting)];
    [self enqueueSelector:@selector(updateDistanceGoal)];
    [self enqueueSelector:@selector(updateCalorieGoal)];
    [self enqueueSelector:@selector(updateStepGoal)];
    [self enqueueSelector:@selector(updateDayLightAlert)];
    [self enqueueSelector:@selector(updateFinished)];
    
   // if (self.watchModel == WatchModel_R450) {
        [self startUpdateWithoutDelegate];
   // }
   // else{
   //     [self startUpdate];
   // }
}

- (void)startUpdateSettingsWithWatchModel:(WatchModel)watchModel salutronUserProfile:(SalutronUserProfile *)salutronUserProfile timeDate:(TimeDate *)timeDate sleepSettings:(SleepSetting *)sleepSettings wakeUp:(Wakeup *)wakeUp calibrationData:(CalibrationData *)calibrationData notification:(Notification *)notification inactiveAlert:(InactiveAlert *)inactiveAlert dayLightAlert:(DayLightAlert *)dayLightAlert nightLightAlert:(NightLightAlert *)nightLightAlert notificationStatus:(BOOL)notificationStatus timing:(Timing *)timing
{
    self.watchModel = watchModel;
    self.syncing    = YES;
    
    /*if ([self.delegate respondsToSelector:@selector(didSyncStarted)]) {
        [self.delegate didSyncStarted];
    }*/
    
    self.wakeupType             = 0;
    self.calibrationType        = 0;
    self.inactiveAlertType      = 0;
    self.dayLightAlertType      = 0;
    self.nightLightAlertType    = 0;
    self.notificationType       = 0;
    self.notification           = notification;
    self.notificationStatus     = notificationStatus;
    self.timing                 = timing;
    
    self.salutronUserProfile    = salutronUserProfile;
    self.timeDate               = timeDate;
    //self.sleepSetting           = sleepSettings;
    self.timeDate.watchFace     = self.userDefaultsManager.watchFace;
    self.wakeup                 = wakeUp;
    self.calibrationData        = calibrationData;
    self.inactiveAlertData      = inactiveAlert;
    self.dayLightAlertData      = dayLightAlert;
    self.nightLightAlertData    = nightLightAlert;
    
    self.dayLightAlertData.level_low    = SFAAllLightDailyThresholdLow;
    self.dayLightAlertData.level_mid    = SFAAllLightDailyThresholdMed;
    self.dayLightAlertData.level_hi     = SFAAllLightDailyThresholdHigh;
    
    self.nightLightAlertData.level_low  = SFABlueLightDailyThresholdLow;
    self.nightLightAlertData.level_mid  = SFABlueLightDailyThresholdMed;
    self.nightLightAlertData.level_hi   = SFABlueLightDailyThresholdHigh;
    
    [self.arrayOfSelector removeAllObjects];
    [self enqueueSelector:@selector(updateTimeAndDate)];
    [self enqueueSelector:@selector(updateUserProfile)];
    
    if (self.inactiveAlertData)
        [self enqueueSelector:@selector(updateInactiveAlert)];
    if (self.dayLightAlertData)
        [self enqueueSelector:@selector(updateDayLightAlert)];
    if (self.nightLightAlertData)
        [self enqueueSelector:@selector(updateNightLightAlert)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    
    if (self.wakeup)
        [self enqueueSelector:@selector(updateWakeup)];
    //[self enqueueSelector:@selector(updateSleepSetting)];
    if (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) {
        [self enqueueSelector:@selector(updateNotificationStatus)];
        [self enqueueSelector:@selector(updateNotification)];
    }
    [self enqueueSelector:@selector(updateTiming)];
    [self enqueueSelector:@selector(updateFinished)];
    
    [self startUpdateWithoutDelegate];
}

- (void)startUpdateSettingsWithWatchModel:(WatchModel)watchModel salutronUserProfile:(SalutronUserProfile *)salutronUserProfile timeDate:(TimeDate *)timeDate sleepSettings:(SleepSetting *)sleepSettings wakeUp:(Wakeup *)wakeUp calibrationData:(CalibrationData *)calibrationData notification:(Notification *)notification inactiveAlert:(InactiveAlert *)inactiveAlert dayLightAlert:(DayLightAlert *)dayLightAlert nightLightAlert:(NightLightAlert *)nightLightAlert notificationStatus:(BOOL)notificationStatus timing:(Timing *)timing workoutSetting:(WorkoutSetting *)workoutSetting
{
    self.watchModel = watchModel;
    self.syncing    = YES;
    
    /*if ([self.delegate respondsToSelector:@selector(didSyncStarted)]) {
     [self.delegate didSyncStarted];
     }*/
    
    self.wakeupType             = 0;
    self.calibrationType        = 0;
    self.inactiveAlertType      = 0;
    self.dayLightAlertType      = 0;
    self.nightLightAlertType    = 0;
    self.notificationType       = 0;
    self.notification           = notification;
    self.notificationStatus     = notificationStatus;
    self.timing                 = timing;
    self.workoutSetting         = workoutSetting;
    self.indexOfWorkoutSetting  = 0;
    
    self.salutronUserProfile    = salutronUserProfile;
    self.timeDate               = timeDate;
    //self.sleepSetting           = sleepSettings;
    self.timeDate.watchFace     = self.userDefaultsManager.watchFace;
    self.wakeup                 = wakeUp;
    self.calibrationData        = calibrationData;
    self.inactiveAlertData      = inactiveAlert;
    self.dayLightAlertData      = dayLightAlert;
    self.nightLightAlertData    = nightLightAlert;
    
    self.dayLightAlertData.level_low    = SFAAllLightDailyThresholdLow;
    self.dayLightAlertData.level_mid    = SFAAllLightDailyThresholdMed;
    self.dayLightAlertData.level_hi     = SFAAllLightDailyThresholdHigh;
    
    self.nightLightAlertData.level_low  = SFABlueLightDailyThresholdLow;
    self.nightLightAlertData.level_mid  = SFABlueLightDailyThresholdMed;
    self.nightLightAlertData.level_hi   = SFABlueLightDailyThresholdHigh;
    
    self.indexOfWorkoutSetting          = 0;
    
    [self.arrayOfSelector removeAllObjects];
    [self enqueueSelector:@selector(updateTimeAndDate)];
    [self enqueueSelector:@selector(updateUserProfile)];
    
    if (self.inactiveAlertData)
        [self enqueueSelector:@selector(updateInactiveAlert)];
    if (self.dayLightAlertData)
        [self enqueueSelector:@selector(updateDayLightAlert)];
    if (self.nightLightAlertData)
        [self enqueueSelector:@selector(updateNightLightAlert)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    
    if (self.wakeup)
        [self enqueueSelector:@selector(updateWakeup)];
    //[self enqueueSelector:@selector(updateSleepSetting)];
    if (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) {
        [self enqueueSelector:@selector(updateNotificationStatus)];
        [self enqueueSelector:@selector(updateNotification)];
    }
    [self enqueueSelector:@selector(updateTiming)];
    
    if (watchModel == WatchModel_R420) {
        self.workoutSetting.type = 0;
        [self enqueueSelector:@selector(updateWorkoutSetting)];
        [self enqueueSelector:@selector(updateWorkoutSetting)];
        [self enqueueSelector:@selector(getWorkoutSetting)];
        [self enqueueSelector:@selector(getWorkoutSetting)];
        [self enqueueSelector:@selector(getWorkoutSetting)];
        [self enqueueSelector:@selector(getWorkoutSetting)];
    }
    
    [self enqueueSelector:@selector(updateFinished)];
    
    [self startUpdateWithoutDelegate];
}

- (void)startUpdateAllWithWatchModel:(WatchModel)watchModel salutronUserProfile:(SalutronUserProfile *)salutronUserProfile sleepSetting:(SleepSetting *)sleepSetting distanceGoal:(double)distanceGoal calorieGoal:(int)calorieGoal stepGoal:(int)stepGoal sleepGoal:(int)sleepGoal  timeDate:(TimeDate *)timeDate wakeUp:(Wakeup *)wakeUp calibrationData:(CalibrationData *)calibrationData notification:(Notification *)notification inactiveAlert:(InactiveAlert *)inactiveAlert dayLightAlert:(DayLightAlert *)dayLightAlert nightLightAlert:(NightLightAlert *)nightLightAlert notificationStatus:(BOOL)notificationStatus timing:(Timing *)timing
{
    self.watchModel = watchModel;
    self.syncing    = YES;
    self.wakeupType             = 0;
    self.calibrationType        = 0;
    self.inactiveAlertType      = 0;
    self.dayLightAlertType      = 0;
    self.nightLightAlertType    = 0;
    self.notificationType       = 0;
    self.notification           = notification;
    self.notificationStatus     = notificationStatus;
    self.timing                 = timing;
    
    self.salutronUserProfile    = salutronUserProfile;
    self.sleepSetting           = sleepSetting;
    self.distanceGoal           = distanceGoal;
    self.calorieGoal            = calorieGoal;
    self.stepGoal               = stepGoal;
    self.sleepGoal              = sleepGoal;
    self.timeDate               = timeDate;
    self.timeDate.watchFace     = self.userDefaultsManager.watchFace;
    self.wakeup                 = wakeUp;
    self.calibrationData        = calibrationData;
    self.notification           = notification;
    self.inactiveAlertData      = inactiveAlert;
    self.dayLightAlertData      = dayLightAlert;
    self.nightLightAlertData    = nightLightAlert;
    
    self.dayLightAlertData.level_low    = SFAAllLightDailyThresholdLow;
    self.dayLightAlertData.level_mid    = SFAAllLightDailyThresholdMed;
    self.dayLightAlertData.level_hi     = SFAAllLightDailyThresholdHigh;
    
    self.nightLightAlertData.level_low  = SFABlueLightDailyThresholdLow;
    self.nightLightAlertData.level_mid  = SFABlueLightDailyThresholdMed;
    self.nightLightAlertData.level_hi   = SFABlueLightDailyThresholdHigh;
    
    [self.arrayOfSelector removeAllObjects];
    [self enqueueSelector:@selector(updateTimeAndDate)];
    [self enqueueSelector:@selector(updateUserProfile)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    [self enqueueSelector:@selector(updateCalibrationData)];
    [self enqueueSelector:@selector(updateWakeup)];
    if (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) {
        [self enqueueSelector:@selector(updateNotificationStatus)];
        [self enqueueSelector:@selector(updateNotification)];
    }
	[self enqueueSelector:@selector(updateTiming)];
    [self enqueueSelector:@selector(updateSleepSetting)];
    [self enqueueSelector:@selector(updateDistanceGoal)];
    [self enqueueSelector:@selector(updateCalorieGoal)];
    [self enqueueSelector:@selector(updateStepGoal)];
    [self enqueueSelector:@selector(updateInactiveAlert)];
    [self enqueueSelector:@selector(updateDayLightAlert)];
    [self enqueueSelector:@selector(updateNightLightAlert)];
    [self enqueueSelector:@selector(updateFinished)];
    
    [self startUpdate];
}


- (void)startUpdateAllNotificationsWithWatchModel:(WatchModel)watchModel notification:(Notification *)notification notificationStatus:(BOOL)notificationStatus
{
    self.watchModel = watchModel;
    self.syncing    = YES;
    self.notificationType       = 0;
    self.notification           = notification;
    self.notificationStatus     = notificationStatus;
    self.notification           = notification;
    
    [self.arrayOfSelector removeAllObjects];
     if (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) {
         [self enqueueSelector:@selector(updateNotificationStatus)];
         [self enqueueSelector:@selector(updateNotification)];
     }
	[self enqueueSelector:@selector(updateFinished)];
    
    [self startUpdate];
}

- (void)startUpdateNotificationStatusWithWatchModel:(WatchModel)watchModel
                                 notificationStatus:(BOOL)notificationStatus
{
    self.watchModel         = watchModel;
    self.notificationStatus = notificationStatus;
    self.syncing            = YES;
    
    [self.arrayOfSelector removeAllObjects];
     if (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) {
         [self enqueueSelector:@selector(updateNotificationStatus)];
     }
    if([self.delegate respondsToSelector:@selector(didUpdateFinish)]){
        [self enqueueSelector:@selector(updateFinished)];
    }
    
    NSString *macAddress = nil;
    Status status = [self.salutronSDK getMacAddress:&macAddress];
    if (status == NO_ERROR) {
        DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
        
        self.salutronSDK.delegate   = self;
        /*
        if ([self.delegate respondsToSelector:@selector(didSyncStarted)]) {
            [self.delegate didSyncStarted];
        }
        */
        if ([self.managerDelegate respondsToSelector:@selector(updateStarted)]){
            [self.managerDelegate updateStarted];
        }
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
    else{
        [self startUpdate];
    }
}


- (void)startUpdateNotificationWithWatchModel:(WatchModel)watchModel
                                 withNotification:(Notification *)notification
{
    self.watchModel         = watchModel;
    self.notification       = notification;
    self.notificationType   = notification.type;
    self.syncing            = YES;
    
    [self.arrayOfSelector removeAllObjects];
    [self enqueueSelector:@selector(updateIndividualNotification)];
    [self enqueueSelector:@selector(updateFinished)];
    
    NSString *macAddress = nil;
    Status status = [self.salutronSDK getMacAddress:&macAddress];
    if (status == NO_ERROR) {
        DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
        
        self.salutronSDK.delegate   = self;
        /*
        if ([self.delegate respondsToSelector:@selector(didSyncStarted)]) {
            [self.delegate didSyncStarted];
        }
         */
        if ([self.managerDelegate respondsToSelector:@selector(updateStarted)]){
            [self.managerDelegate updateStarted];
        }
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
    else{
        [self startUpdate];
    }
}

- (void)startResetWorkoutDatabase:(WatchModel)watchModel workoutSetting:(WorkoutSetting *)workoutSetting
{
    self.watchModel             = watchModel;
    self.syncing                = YES;
    self.workoutSetting         = workoutSetting;
    self.indexOfWorkoutSetting  = 0;
    
    [self.arrayOfSelector removeAllObjects];
    
    if (watchModel == WatchModel_R420) {
        self.workoutSetting.type = 12;
        self.workoutSetting.reserved = 0;
        [self enqueueSelector:@selector(updateWorkoutSetting)];
        [self enqueueSelector:@selector(getWorkoutSetting)];
        [self enqueueSelector:@selector(getWorkoutSetting)];
        [self enqueueSelector:@selector(getWorkoutSetting)];
        [self enqueueSelector:@selector(getWorkoutSetting)];
    }
    
    [self enqueueSelector:@selector(updateFinished)];
    
    [self startUpdateWithoutDelegate];
}

- (void)cancelSyncing
{
    DDLogInfo(@"");
    self.syncing = NO;
}

#pragma mark - Start update

- (void)startUpdate
{
    DDLogInfo(@"");
    self.salutronSDK.delegate   = self;
    self.deviceIndex            = @(0).integerValue;
    self.syncing                = YES;
    
    if ([self.delegate respondsToSelector:@selector(didSyncStarted)]) {
        [self.delegate didSyncStarted]; 
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextSelectorOnQueue];
    });
    
    /*if (self.watchModel == WatchModel_R450)
        [self.salutronSDK retrieveConnectedDevice];*/
}


- (void)startUpdateWithoutDelegate
{
    DDLogInfo(@"");
    self.salutronSDK.delegate   = self;
    self.deviceIndex            = @(0).integerValue;
    self.syncing                = YES;
    
   // if ([self.delegate respondsToSelector:@selector(didSyncStarted)]) {
   //     [self.delegate didSyncStarted];
   // }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextSelectorOnQueue];
    });
    
    /*if (self.watchModel == WatchModel_R450)
        [self.salutronSDK retrieveConnectedDevice];*/
}

#pragma mark - SalutronSDKDelegate @required

- (void)didRetrieveConnectedDevice:(int)numDevice withStatus:(Status)status
{
    DDLogInfo(@"NUM DEVICE: %d | %@", numDevice, [ErrorCodeToStringConverter convertToString:status]);
    if (numDevice > 0 && self.watchModel == WatchModel_R450) {
        
        Status status = [self.salutronSDK connectDevice:0];
        
        if (status == WARNING_CONNECTED) {
            [self didConnectAndSetupDeviceWithStatus:0];
        }
    }
    else {
        [self.salutronSDK discoverDevice:discoverTimeout];
    }
}

- (void)didDisconnectDevice:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
        [self.delegate didDeviceDisconnected:NO];
    }
    if ([self.delegate respondsToSelector:@selector(updateFinishedWithStatus:)]){
        [self.managerDelegate updateFinishedWithStatus:ERROR_DISCONNECT];
    }
}

- (void)didDiscoverDevice:(int)numDevice withStatus:(Status)status
{
    DDLogInfo(@"NUM DEVICE: %d | %@", numDevice, [ErrorCodeToStringConverter convertToString:status]);
    
    if (self.deviceIndex < numDevice) {
        [self.salutronSDK connectDevice:self.deviceIndex];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(didDiscoverTimeout)]) {
            [self.delegate didDiscoverTimeout];
        }
        if ([self.delegate respondsToSelector:@selector(updateFinishedWithStatus:)]){
            [self.managerDelegate updateFinishedWithStatus:ERROR_DISCOVER];
        }

    }
}

- (void)didConnectAndSetupDeviceWithStatus:(Status)status
{
    
    NSString *savedMacAddres = self.userDefaultsManager.macAddress;
    NSString *newMacAddress = nil;
    [self.salutronSDK getMacAddress:&newMacAddress];
    
    if (![newMacAddress isEqualToString:savedMacAddres]) {
        [self.salutronSDK disconnectDevice];
        self.deviceIndex++;
        [self.salutronSDK discoverDevice:discoverTimeout];
    }
    
    
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    if ([self.delegate respondsToSelector:@selector(didSyncStarted)]) {
        [self.delegate didSyncStarted];
    }
    //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextSelectorOnQueue];
    });
}

#pragma mark - Did update methods

- (void)didUpdateCalibrationDataWithStatus:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    [self dequeueSelector];
    //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextSelectorOnQueue];
    });
}

- (void)didUpdateCalorieGoalWithStatus:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    [self dequeueSelector];
    //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextSelectorOnQueue];
    });
}
- (void)didUpdateDistanceGoalWithStatus:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    [self dequeueSelector];
    //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextSelectorOnQueue];
    });
}

- (void)didSetNotiStatusWithStatus:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    if (status == NO_ERROR) {
        self.userDefaultsManager.notificationStatus = self.notificationStatus;
    }
    //[self.managerDelegate updateFinishedWithStatus:status];
    
    if([self.delegate respondsToSelector:@selector(didUpdateFinish)]){
        if (self.arrayOfSelector.count > 0) {
            [self dequeueSelector];
            //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self nextSelectorOnQueue];
            });
        }
    }
}

- (void)didUpdateNotificationWithStatus:(Status)status
{
	/*
	 DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
	 [self dequeueSelector];
	 [self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
	 */
		//	if (self.isIndividualNotification == YES) {
		//		self.notificationType = 0;
		//		[self.managerDelegate updateFinishedWithStatus:status];
		//		[self dequeueSelector];
		//		[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
		//	}
		//	else{
		//	}
	DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
	
	if (status == NO_ERROR) {
		
		self.notificationType++;
		
		if (self.notificationType < notifTypeCount) {
			[self updateNotification];
		}
		else {
			[self dequeueSelector];
			//[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self nextSelectorOnQueue];
            });
		}
	}
	else{
		[self performSelector:@selector(updateNotification) withObject:nil afterDelay:selectorTimeout];
	}
}

- (void)didUpdateSleepSettingWithStatus:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    [self dequeueSelector];
    //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextSelectorOnQueue];
    });
}

- (void)didUpdateStepGoalWithStatus:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    [self dequeueSelector];
    //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextSelectorOnQueue];
    });
}

- (void)didUpdateTimeAndDateWithStatus:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    [self dequeueSelector];
    //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextSelectorOnQueue];
    });
}

- (void)didUpdateTimingWithStatus:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    [self dequeueSelector];
    //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextSelectorOnQueue];
    });
}

- (void)didUpdateWorkoutSettingWithStatus:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    [self dequeueSelector];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextSelectorOnQueue];
    });
}

- (void)didGetWorkoutSetting:(WorkoutSetting *)workoutSetting withStatus:(Status)status
{
    switch (workoutSetting.type) {
        case 0:
            self.workoutSetting.HRLogRate = workoutSetting.HRLogRate;
            break;
        case 13:
            self.workoutSetting.databaseUsage = workoutSetting.databaseUsage;
            break;
        case 14:
            self.workoutSetting.databaseUsageMax = workoutSetting.databaseUsageMax;
            break;
        case 15:
            self.workoutSetting.reconnectTimeout = workoutSetting.reconnectTimeout;
            break;
        default:
            break;
    }
    
    [self dequeueSelector];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextSelectorOnQueue];
    });
}

- (void)didUpdateUserProfileWithStatus:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    [self dequeueSelector];
    //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextSelectorOnQueue];
    });
}

- (void)didUpdateWakeupWithStatus:(Status)status
{
    DDLogInfo(@"%@ INDEX: %d", [ErrorCodeToStringConverter convertToString:status], self.wakeupType);
    if (self.wakeupType < 3) {
        //[self performSelector:@selector(updateWakeup) withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
    else {
        self.wakeup = nil;
        self.wakeupType = 0;
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)didUpdateInactiveAlertWithStatus:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    if (self.inactiveAlertType < 5) {
        //[self performSelector:@selector(updateInactiveAlert) withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self updateInactiveAlert];
        });
    }
    else {
        self.inactiveAlertData = nil;
        self.inactiveAlertType = 0;
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)didUpdateDayLightAlertWithStatus:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    if (self.dayLightAlertType < 9) {
        //[self performSelector:@selector(updateDayLightAlert) withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self updateDayLightAlert];
        });
    }
    else {
        self.dayLightAlertData = nil;
        self.dayLightAlertType = 0;
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)didUpdateNightLightAlertWithStatus:(Status)status
{
    
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    if (self.nightLightAlertType < 9) {
        //[self performSelector:@selector(updateNightLightAlert) withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self updateNightLightAlert];
        });
    }
    else {
        self.nightLightAlertData = nil;
        self.nightLightAlertType = 0;
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)didGetBattLevel:(NSString *)battLevelString withStatus:(Status)status { }

#pragma mark - Update methods

- (void)updateCalibrationData
{
    DDLogInfo(@"%@", self.calibrationData);
    
    if (self.calibrationData != nil) {
        
        if (self.calibrationType < 5) {
            if (self.calibrationType < 5 && (self.calibrationType != 2 && self.calibrationType != 3)) {
                self.calibrationData.type = self.calibrationType;
                DDLogInfo(@"stype: %i", self.calibrationData.type);
                Status status = [self.salutronSDK updateCalibrationData:self.calibrationData];
                
                if (status != NO_ERROR) {
                    if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
                        if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                            [self.delegate didDeviceDisconnected:NO];
                        }
                    } else {
                        [self dequeueSelector];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self nextSelectorOnQueue];
                        });
                    }
                }
                self.calibrationType++;
            }
            else {
                self.calibrationType++;
                [self dequeueSelector];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self nextSelectorOnQueue];
                });
            }
        }
        else {
            self.calibrationData = nil;
            self.calibrationType = 0;
            [self dequeueSelector];
            //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self nextSelectorOnQueue];
            });
        }
    }
    else {
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)updateCalorieGoal
{
    DDLogInfo(@"%d", self.calorieGoal);
    
    if (self.calorieGoal != 0) {
        Status status = [self.salutronSDK updateCalorieGoal:self.calorieGoal];
        
        if (status != NO_ERROR) {
            if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
                if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                    [self.delegate didDeviceDisconnected:NO];
                }
            } else {
                [self dequeueSelector];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self nextSelectorOnQueue];
                });
            }
        }
        else {
            self.calorieGoal = 0;
        }
    }
    else {
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)updateDistanceGoal
{
    DDLogInfo(@"%d", self.distanceGoal);
    
    if (self.distanceGoal != 0) {
        
        CGFloat roundedSavedDistanceGoal    = floorf(self.distanceGoal * 100 + 0.5) / 100;
        Status status = [self.salutronSDK updateDistanceGoal:roundedSavedDistanceGoal];
        
        if (status != NO_ERROR) {
            if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
                if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                    [self.delegate didDeviceDisconnected:NO];
                }
            } else {
                [self dequeueSelector];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self nextSelectorOnQueue];
                });
            }
        }
        else {
            self.distanceGoal = 0;
        }
    }
    else {
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)updateFinished
{
    DDLogInfo(@"");
    // For R450 watch, call commDone if notification is disabled
    // Always call commDone after update if watch is CModel
    
    if (self.userDefaultsManager.notificationStatus == NO ||
        self.userDefaultsManager.watchModel == WatchModel_Move_C300 ||
        self.userDefaultsManager.watchModel == WatchModel_Move_C300_Android ||
        self.userDefaultsManager.watchModel == WatchModel_Zone_C410 ||
        self.userDefaultsManager.watchModel == WatchModel_R420) {
        [self.salutronSDK commDone];
    }
    
    self.salutronSDK.delegate = nil;
    self.userDefaultsManager.workoutSetting = self.workoutSetting;
    
    if ([self.delegate respondsToSelector:@selector(didUpdateFinish)]) {
        [self.delegate didUpdateFinish];
    }
}

static NSInteger const notifTypeCount = 10;

- (void)updateNotification
{
	DDLogInfo(@"TYPE: %d %@", self.notificationType, self.notification);
	
	if (self.notification != nil) {
		
		if (self.notificationType < notifTypeCount) {
			
			self.notification.type = self.notificationType;
			[self.salutronSDK updateNotification:self.notification];
			
		}
		else {
			self.notification = nil;
			self.notificationType = 0;
			[self dequeueSelector];
			//[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self nextSelectorOnQueue];
            });
		}
	}
	else {
		[self dequeueSelector];
		//[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
	}
}

- (void)updateIndividualNotification
{
    DDLogInfo(@"type: %d %@", self.notificationType, self.notification);
    
    if ([self.managerDelegate respondsToSelector:@selector(updateStarted)]){
        [self.managerDelegate updateStarted];
    }
            self.notification.type = self.notificationType;
            self.isIndividualNotification = YES;
            [self.salutronSDK updateNotification:self.notification];
}

- (void)updateNotificationStatus
{
    DDLogInfo(@"%d", self.notificationStatus);
    
    if ([self.managerDelegate respondsToSelector:@selector(updateStarted)]){
        [self.managerDelegate updateStarted];
    }
    [self.salutronSDK setNotiStatus:self.notificationStatus];
}

- (void)updateSleepSetting
{
    DDLogInfo(@"%@", self.sleepSetting);
    
    if (self.sleepSetting != nil) {
        Status status = [self.salutronSDK updateSleepSetting:self.sleepSetting];
        
        if (status != NO_ERROR) {
            if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
                if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                    [self.delegate didDeviceDisconnected:NO];
                }
            } else {
                [self dequeueSelector];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self nextSelectorOnQueue];
                });
            }
        }
        else {
            self.sleepSetting = nil;
        }
    }
    else {
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)updateStepGoal
{
    if (self.stepGoal != 0) {
        Status status = [self.salutronSDK updateStepGoal:self.stepGoal];
        
        if (status != NO_ERROR) {
            if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
                if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                    [self.delegate didDeviceDisconnected:NO];
                }
            } else {
                [self dequeueSelector];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self nextSelectorOnQueue];
                });
            }
        }
        else {
            self.stepGoal = 0;
        }
    }
    else {
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)updateTimeAndDate
{
    DDLogInfo(@"%@", self.timeDate);
    
    if (self.timeDate != nil && self.userDefaultsManager.autoSyncTimeEnabled) {
        TimeDate *tempTimeDate      = [[TimeDate alloc] initWithDate:[NSDate new]];
        tempTimeDate.hourFormat     = self.timeDate.hourFormat;
        tempTimeDate.dateFormat     = self.timeDate.dateFormat;
        tempTimeDate.watchFace      = self.timeDate.watchFace;
        Status status = [self.salutronSDK updateTimeAndDate:tempTimeDate];
        
        if (status != NO_ERROR) {
            if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
                if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                    [self.delegate didDeviceDisconnected:NO];
                }
            } else {
                [self dequeueSelector];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self nextSelectorOnQueue];
                });
            }
        }
        else {
            self.timeDate = nil;
        }
    }
    else {
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)updateTiming
{
    DDLogInfo(@"%@", self.timing);
    
    if (self.timing != nil) {
        
        self.timing.type = 3;
        Status status = [self.salutronSDK updateTiming:self.timing];
        
        if (status != NO_ERROR) {
            if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
                if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                    [self.delegate didDeviceDisconnected:NO];
                }
            } else {
                [self dequeueSelector];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self nextSelectorOnQueue];
                });
            }
        }
        else {
            self.timing = nil;
        }
    }
    else {
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)updateWorkoutSetting
{
    DDLogInfo(@"%@", self.workoutSetting);
    
    if (self.workoutSetting) {
        //self.workoutSetting.type = 0;
        
        Status status = [self.salutronSDK updateWorkoutSetting:self.workoutSetting];
        
        self.workoutSetting.type = 15;
        
        if (status != NO_ERROR) {
            if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
                if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                    [self.delegate didDeviceDisconnected:NO];
                } else {
                    [self dequeueSelector];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(selectorTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self nextSelectorOnQueue];
                    });
                }
            }
        }
    } else {
        [self dequeueSelector];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_MSEC), dispatch_get_main_queue(), ^ {
            [self nextSelectorOnQueue];
        });
    }
}

- (void)getWorkoutSetting
{
    Status status = [self.salutronSDK getWorkoutSetting:[self workoutTypeForIndex:self.indexOfWorkoutSetting]];
    
    if (status != NO_ERROR) {
        if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
            if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                [self.delegate didDeviceDisconnected:NO];
            } else {
                [self dequeueSelector];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(selectorTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self nextSelectorOnQueue];
                });
            }
        }
    } else {
        self.indexOfWorkoutSetting++;
    }
}

- (void)updateUserProfile
{
    if (self.salutronUserProfile != nil) {
        Status status = [self.salutronSDK updateUserProfile:self.salutronUserProfile];
        
        if (status != NO_ERROR) {
            if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
                if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                    [self.delegate didDeviceDisconnected:NO];
                }
            } else {
                [self dequeueSelector];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self nextSelectorOnQueue];
                });
            }
        }
        else {
            self.salutronUserProfile = nil;
        }
    }
    else {
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)updateWakeup
{
    if (self.wakeup != nil) {
        if (self.wakeupType < 3) {
            self.wakeup.type = self.wakeupType;
            Status status = [self.salutronSDK updateWakeup:self.wakeup];
            self.wakeupType++;
            
            if (status != NO_ERROR) {
                if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
                    if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                        [self.delegate didDeviceDisconnected:NO];
                    }
                } else {
                    [self dequeueSelector];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self nextSelectorOnQueue];
                    });
                }
            }
        }
        else {
            self.wakeup = nil;
            self.wakeupType = 0;
            [self dequeueSelector];
            //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self nextSelectorOnQueue];
            });
        }
    }
    else {
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)updateInactiveAlert
{
    if (self.inactiveAlertData != nil) {
        
        if (self.inactiveAlertType < 5) {
            
            self.inactiveAlertData.type = self.inactiveAlertType;
            Status status = [self.salutronSDK updateInactiveAlert:self.inactiveAlertData];
            
            if (status != NO_ERROR){
                if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
                    if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                        [self.delegate didDeviceDisconnected:NO];
                    }
                } else {
                    [self dequeueSelector];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self nextSelectorOnQueue];
                    });
                }
            }
            self.inactiveAlertType++;

        }
        else {
            self.inactiveAlertData = nil;
            self.inactiveAlertType = 0;
            [self dequeueSelector];
            //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self nextSelectorOnQueue];
            });
        }
    }
    else {
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)updateDayLightAlert
{
    if (self.dayLightAlertData != nil) {
        
        if (self.dayLightAlertType < 6) {
            
            
            self.dayLightAlertData.type = self.dayLightAlertType;
            Status status = [self.salutronSDK updateDayLightAlert:self.dayLightAlertData];
            
            if (status != NO_ERROR){
                if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
                    if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                        [self.delegate didDeviceDisconnected:NO];
                    }
                } else {
                    [self dequeueSelector];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self nextSelectorOnQueue];
                    });
                }
            }
            self.dayLightAlertType++;
            
            
        }
        else {
            self.dayLightAlertData = nil;
            self.dayLightAlertType = 0;
            [self dequeueSelector];
            //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self nextSelectorOnQueue];
            });
        }
    }
    else {
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (void)updateNightLightAlert
{
    if (self.nightLightAlertData != nil) {
        
        if (self.nightLightAlertType < 6) {
            
            self.nightLightAlertData.type = self.nightLightAlertType;
            Status status = [self.salutronSDK updateNightLightAlert:self.nightLightAlertData];
            
            if (status != NO_ERROR){
                if (status == WARNING_NOT_CONNECTED || status == ERROR_NOT_CONNECTED) {
                    if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                        [self.delegate didDeviceDisconnected:NO];
                    }
                } else {
                    [self dequeueSelector];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self nextSelectorOnQueue];
                    });
                }
            }
            self.nightLightAlertType++;
        }
        else {
            self.nightLightAlertData = nil;
            self.nightLightAlertType = 0;
            [self dequeueSelector];
            //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self nextSelectorOnQueue];
            });
        }
    }
    else {
        [self dequeueSelector];
        //[self performSelector:[self nextSelectorOnQueue] withObject:nil afterDelay:selectorTimeout];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, selectorTimeout * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self nextSelectorOnQueue];
        });
    }
}

- (NSInteger)workoutTypeForIndex:(NSInteger)index
{
    switch (index) {
        case 1:     return 13;
        case 2:     return 14;
        case 3:     return 15;
        default:    return 0;
    }
}

@end
