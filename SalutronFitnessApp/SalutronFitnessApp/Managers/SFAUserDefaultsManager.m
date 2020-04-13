//
//  SFAUserDefaultsManager.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 6/16/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAUserDefaultsManager.h"

#import "NightLightAlert+Data.h"
#import "DayLightAlert+Data.h"
#import "InactiveAlert+Data.h"
#import "Wakeup+Data.h"
#import "WorkoutSetting+Coding.h"

@interface SFAUserDefaultsManager ()

@end

@implementation SFAUserDefaultsManager

@synthesize calibrationData = _calibrationData;
@synthesize notification = _notification;
@synthesize salutronUserProfile = _salutronUserProfile;
@synthesize sleepSetting = _sleepSetting;
@synthesize timeDate = _timeDate;
@synthesize watchFace = _watchFace;
@synthesize watchModel = _watchModel;
@synthesize selectedDateFromCalendar = _selectedDateFromCalendar;

@synthesize lastSyncedDate = _lastSyncedDate;
@synthesize deviceUUID = _deviceUUID;
@synthesize firmwareRevision = _firmwareRevision;
@synthesize macAddress = _macAddress;
@synthesize softwareRevision = _softwareRevision;
@synthesize distanceGoal = _distanceGoal;
@synthesize calorieGoal = _calorieGoal;
@synthesize sleepGoal = _sleepGoal;
@synthesize stepGoal = _stepGoal;
@synthesize timing = _timing;

@synthesize cloudSyncEnabled = _cloudSyncEnabled;
@synthesize hasPaired = _hasPaired;
@synthesize promptChangeSettings = _promptChangeSettings;
@synthesize autoSyncToWatchEnabled = _autoSyncToWatchEnabled;
@synthesize autoSyncTimeEnabled = _autoSyncTimeEnabled;
@synthesize bluetoothOn = _bluetoothOn;
@synthesize notificationStatus = _notificationStatus;

@synthesize wakeUp        = _wakeUp;
@synthesize inactiveAlert = _inactiveAlert;
@synthesize dayLightAlert = _dayLightAlert;
@synthesize nightLightAlert = _nightLightAlert;

@synthesize workoutSetting = _workoutSetting;


@synthesize syncOption = _syncOption;

#pragma mark - Singleton method

+ (instancetype)sharedManager
{
    static SFAUserDefaultsManager *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

#pragma mark - Clear

- (void)clearUserDefaults
{
    self.calibrationData = nil;
    self.notification = nil;
    self.salutronUserProfile = nil;
    self.sleepSetting = nil;
    self.timeDate = nil;
    self.watchModel = WatchModel_Not_Set;
    self.selectedDateFromCalendar = nil;
    self.lastSyncedDate = nil;
    self.deviceUUID = nil;
    self.firmwareRevision = nil;
    self.macAddress = nil;
    self.softwareRevision = nil;
    self.signUpDeviceMacAddress = nil;
    self.distanceGoal = 0;
    self.calorieGoal = 0;
    self.sleepGoal = 0;
    self.cloudSyncEnabled = NO;
    self.hasPaired = NO;
    self.promptChangeSettings = YES;
    self.syncOption = SyncOptionNone;
    self.notificationStatus = NO;
    self.wakeUp = nil;
    self.inactiveAlert = nil;
    self.dayLightAlert = nil;
    self.nightLightAlert = nil;
    self.timing = nil;
}

#pragma mark - Lazy loading of user defaults

- (NSUserDefaults *)userDefaults
{
    if (!_userDefaults) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return _userDefaults;
}

#pragma mark - Calibration data

- (void)setCalibrationData:(CalibrationData *)calibrationData
{
    _calibrationData = calibrationData;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:calibrationData];
    [self.userDefaults setObject:data forKey:CALIBRATION_DATA];
    [self.userDefaults synchronize];
}

- (CalibrationData *)calibrationData
{
    NSData *data = [self.userDefaults dataForKey:CALIBRATION_DATA];
    
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

#pragma mark - Notification

- (void)setNotification:(Notification *)notification
{
    _notification = notification;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:notification];
    [self.userDefaults setObject:data forKey:NOTIFICATION];
    [self.userDefaults synchronize];
}

- (Notification *)notification
{
    NSData *data = [self.userDefaults dataForKey:NOTIFICATION];
    
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

#pragma mark - Salutron User Profile

- (void)setSalutronUserProfile:(SalutronUserProfile *)salutronUserProfile
{
    _salutronUserProfile = salutronUserProfile;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:salutronUserProfile];
    [self.userDefaults setObject:data forKey:USER_PROFILE];
    [self.userDefaults synchronize];
}

- (SalutronUserProfile *)salutronUserProfile
{
    NSData *data = [self.userDefaults dataForKey:USER_PROFILE];
    
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

#pragma mark - Sleep settings

- (void)setSleepSetting:(SleepSetting *)sleepSetting
{
    _sleepSetting = sleepSetting;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sleepSetting];
    [self.userDefaults setObject:data forKey:SLEEP_SETTING];
    [self.userDefaults synchronize];
}

- (SleepSetting *)sleepSetting
{
    NSData *data = [self.userDefaults dataForKey:SLEEP_SETTING];
    
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

#pragma mark - Timing

- (void)setTiming:(Timing *)timing
{
    _timing = timing;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:timing];
    [self.userDefaults setObject:data forKey:TIMING];
    [self.userDefaults synchronize];
}

- (Timing *)timing
{
    NSData *data = [self.userDefaults dataForKey:TIMING];
    
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

#pragma mark - Time date

- (void)setTimeDate:(TimeDate *)timeDate
{
    _timeDate = timeDate;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_timeDate];
    
    [self.userDefaults setObject:data forKey:TIME_DATE];
    [self.userDefaults synchronize];
}

- (TimeDate *)timeDate
{
    NSData *data = [self.userDefaults dataForKey:TIME_DATE];
    
    if (data) {
        TimeDate *timeDate = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return timeDate;
    }
    return nil;
}

#pragma mark - Workout Settings

- (void)setWorkoutSetting:(WorkoutSetting *)workoutSetting
{
    _workoutSetting = workoutSetting;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_workoutSetting];
    
    [self.userDefaults setObject:data forKey:WORKOUT_SETTING];
    [self.userDefaults synchronize];
}

- (WorkoutSetting *)workoutSetting
{
    NSData *data = [self.userDefaults dataForKey:WORKOUT_SETTING];
    
    if (data) {
        WorkoutSetting *workoutSetting = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return workoutSetting;
    }
    return nil;
}

#pragma mark - Watch face

- (void)setWatchFace:(int)watchFace
{
    _watchFace = watchFace;
    [self.userDefaults setInteger:watchFace forKey:WATCH_FACE];
    [self.userDefaults synchronize];
}

- (int)watchFace
{
    return [self.userDefaults integerForKey:WATCH_FACE];
}


#pragma mark - Last synced date

- (void)setLastSyncedDate:(NSDate *)lastSyncedDate
{
    _lastSyncedDate = lastSyncedDate;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:lastSyncedDate];
    [self.userDefaults setObject:data forKey:LAST_SYNC_DATE];
    [self.userDefaults synchronize];
}

- (NSDate *)lastSyncedDate
{
    NSData *data = [self.userDefaults dataForKey:LAST_SYNC_DATE];
    
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

#pragma mark - Watch model

- (void)setWatchModel:(WatchModel)watchModel
{
    _watchModel = watchModel;
    [self.userDefaults setInteger:watchModel forKey:CONNECTED_WATCH_MODEL];
    [self.userDefaults synchronize];
}

- (WatchModel)watchModel
{
    return [self.userDefaults integerForKey:CONNECTED_WATCH_MODEL];
}

#pragma mark - Selected date from Calendar

- (void)setSelectedDateFromCalendar:(NSDate *)selectedDateFromCalendar
{
    _selectedDateFromCalendar = selectedDateFromCalendar;
    [self.userDefaults setObject:selectedDateFromCalendar forKey:SELECTED_DATE];
    [self.userDefaults synchronize];
}

- (NSDate *)selectedDateFromCalendar
{
    return [self.userDefaults objectForKey:SELECTED_DATE];
}

#pragma mark - Device id

- (void)setDeviceUUID:(NSString *)deviceUUID
{
    _deviceUUID = deviceUUID;
    [self.userDefaults setObject:deviceUUID forKey:DEVICE_UUID];
    [self.userDefaults synchronize];
}

- (NSString *)deviceUUID
{
    return [self.userDefaults stringForKey:DEVICE_UUID];
}

#pragma mark - Firmware revision getter and setter methods

- (void)setFirmwareRevision:(NSString *)firmwareRevision
{
    _firmwareRevision = firmwareRevision;
    [self.userDefaults setObject:firmwareRevision forKey:FIRMWARE_REVISION];
    [self.userDefaults synchronize];
}

- (NSString *)firmwareRevision
{
    return [self.userDefaults stringForKey:FIRMWARE_REVISION];
}

#pragma mark - Mac Address getter and setter methods

- (void)setMacAddress:(NSString *)macAddress
{
    _macAddress = macAddress;
    [self.userDefaults setObject:macAddress forKey:MAC_ADDRESS];
    [self.userDefaults synchronize];
}

- (NSString *)macAddress
{
    return [self.userDefaults stringForKey:MAC_ADDRESS];
}

#pragma mark - Software revision getter and setter methods

- (void)setSoftwareRevision:(NSString *)softwareRevision
{
    _softwareRevision = softwareRevision;
    [self.userDefaults setObject:softwareRevision forKey:SOFTWARE_REVISION];
    [self.userDefaults synchronize];
}

- (NSString *)softwareRevision
{
    return [self.userDefaults stringForKey:SOFTWARE_REVISION];
}

#pragma mark - Distance goal

- (void)setDistanceGoal:(double)distanceGoal
{
    _distanceGoal = distanceGoal;
    [self.userDefaults setDouble:distanceGoal forKey:DISTANCE_GOAL];
    [self.userDefaults synchronize];
}

- (double)distanceGoal
{
    return [self.userDefaults doubleForKey:DISTANCE_GOAL];
}

#pragma mark - Calorie goal

- (void)setCalorieGoal:(int)calorieGoal
{
    _calorieGoal = calorieGoal;
    [self.userDefaults setInteger:calorieGoal forKey:CALORIE_GOAL];
    [self.userDefaults synchronize];
}

- (int)calorieGoal
{
    return [self.userDefaults integerForKey:CALORIE_GOAL];
}

#pragma mark - Sleep goal

- (void)setSleepGoal:(int)sleepGoal
{
    _sleepGoal = sleepGoal;
    [self.userDefaults setInteger:sleepGoal forKey:SLEEP_GOAL];
    [self.userDefaults synchronize];
}

- (int)sleepGoal
{
    return [self.userDefaults integerForKey:SLEEP_GOAL];
}

#pragma mark - Step goal

- (void)setStepGoal:(int)stepGoal
{
    _stepGoal = stepGoal;
    [self.userDefaults setInteger:stepGoal forKey:STEP_GOAL];
    [self.userDefaults synchronize];
}

- (int)stepGoal
{
    return [self.userDefaults integerForKey:STEP_GOAL];
}

#pragma mark - Cloud sync enabled

- (void)setCloudSyncEnabled:(BOOL)cloudSyncEnabled
{
    _cloudSyncEnabled = cloudSyncEnabled;
    [self.userDefaults setBool:cloudSyncEnabled forKey:ENABLE_CLOUD_SYNC];
    [self.userDefaults synchronize];
}

- (BOOL)cloudSyncEnabled
{
    return [self.userDefaults boolForKey:ENABLE_CLOUD_SYNC];
}

#pragma mark - Has paired

- (void)setHasPaired:(BOOL)hasPaired
{
    _hasPaired = hasPaired;
    [self.userDefaults setBool:hasPaired forKey:HAS_PAIRED];
    [self.userDefaults synchronize];
}

- (BOOL)hasPaired
{
    return [self.userDefaults boolForKey:HAS_PAIRED];
}

#pragma mark - Match settings

- (void)setPromptChangeSettings:(BOOL)promptChangeSettings
{
    _promptChangeSettings = promptChangeSettings;
    [self.userDefaults setBool:promptChangeSettings forKey:PROMPT_CHANGE_SETTINGS];
    [self.userDefaults synchronize];
}

- (BOOL)promptChangeSettings
{
    return [self.userDefaults boolForKey:PROMPT_CHANGE_SETTINGS];
}

#pragma mark - Watch settings

- (void)setAutoSyncToWatchEnabled:(BOOL)autoSyncToWatchEnabled
{
    _autoSyncToWatchEnabled = autoSyncToWatchEnabled;
    [self.userDefaults setBool:autoSyncToWatchEnabled forKey:AUTO_SYNC_ALERT];
    [self.userDefaults synchronize];
}

- (BOOL)autoSyncToWatchEnabled
{
    return [self.userDefaults boolForKey:AUTO_SYNC_ALERT];
}

#pragma mark - Auto Sync Time

- (void) setAutoSyncTimeEnabled:(BOOL)autoSyncTimeEnabled
{
    _autoSyncTimeEnabled = autoSyncTimeEnabled;
    [self.userDefaults setBool:autoSyncTimeEnabled forKey:AUTO_SYNC_TIME];
    [self.userDefaults synchronize];
}

- (BOOL) autoSyncTimeEnabled
{
    return [self.userDefaults boolForKey:AUTO_SYNC_TIME];
}

#pragma mark - Bluetooth On

- (void)setBluetoothOn:(BOOL)bluetoothOn
{
    _bluetoothOn = bluetoothOn;
    [self.userDefaults setBool:bluetoothOn forKey:BLUETOOTH_ON];
    [self.userDefaults synchronize];
}

- (BOOL)isBlueToothOn
{
    return [self.userDefaults boolForKey:BLUETOOTH_ON];
}

#pragma mark -  Notification Status

- (void)setNotificationStatus:(BOOL)isNotificationStatusEnabled
{
    _notificationStatus = isNotificationStatusEnabled;
    [self.userDefaults setBool:isNotificationStatusEnabled forKey:NOTIFICATION_STATUS];
    [self.userDefaults synchronize];
}

- (BOOL)notificationStatus
{
    return [self.userDefaults boolForKey:NOTIFICATION_STATUS];
}

#pragma mark - Sync option

- (void)setSyncOption:(SyncOption)syncOption
{
    _syncOption = syncOption;
    [self.userDefaults setInteger:syncOption forKey:SYNC_OPTION];
    [self.userDefaults synchronize];
}

- (SyncOption)syncOption
{
    return [self.userDefaults integerForKey:SYNC_OPTION];
}

#pragma mark - Mac Address of Device during Sign up getter and setter methods

- (void)setSignUpDeviceMacAddress:(NSString *)signUpDeviceMacAddress
{
    [self.userDefaults setObject:signUpDeviceMacAddress forKey:SIGNUP_MACADDRESS];
    [self.userDefaults synchronize];
}

- (NSString *)signUpDeviceMacAddress
{
    if ([[self.userDefaults objectForKey:SIGNUP_MACADDRESS] isEqualToString:@""]){
        return nil;
    }
    return [self.userDefaults objectForKey:SIGNUP_MACADDRESS];
}

#pragma mark - light settings

- (void)setInactiveAlert:(InactiveAlert *)inactiveAlert
{
    _inactiveAlert = inactiveAlert;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:inactiveAlert];
    [self.userDefaults setObject:data forKey:INACTIVE_ALERT];
    [self.userDefaults synchronize];
}

- (InactiveAlert *)inactiveAlert
{
    NSData *data = [self.userDefaults objectForKey:INACTIVE_ALERT];
    
    if (data) {
        InactiveAlert *alert = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (!alert){
            return [InactiveAlert inactiveAlertWithDefaultValues];
        }
        else{
            return alert;
        }
    }
    else{
        return [InactiveAlert inactiveAlertWithDefaultValues];
    }
    
    return nil;
    
}

- (void)setWakeUp:(Wakeup *)wakeUp
{
    _wakeUp = wakeUp;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:wakeUp];
    [self.userDefaults setObject:data forKey:WAKEUP_KEY];
    [self.userDefaults synchronize];
}

- (Wakeup *)wakeUp
{
    NSData *data = [self.userDefaults objectForKey:WAKEUP_KEY];
    
    if (data) {
        Wakeup *wakeup = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (!wakeup){
            return [Wakeup wakeupDefaultValues];
        }
        else{
            return wakeup;
        }
    }
    else{
        return [Wakeup wakeupDefaultValues];
    }
    
    return nil;
}

- (void)setDayLightAlert:(DayLightAlert *)dayLightAlert
{
    _dayLightAlert = dayLightAlert;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dayLightAlert];
    [self.userDefaults setObject:data forKey:DAY_LIGHT_ALERT];
    [self.userDefaults synchronize];
}

- (DayLightAlert *)dayLightAlert
{
    NSData *data = [self.userDefaults objectForKey:DAY_LIGHT_ALERT];
    
    if (data) {
        DayLightAlert *alert = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (!alert){
            return [DayLightAlert dayLightAlertWithDefaultValues];
        }
        else{
            return alert;
        }
    }
    else{
        return [DayLightAlert dayLightAlertWithDefaultValues];
    }
    
    return nil;
}

- (void)setNightLightAlert:(NightLightAlert *)nightLightAlert
{
    _nightLightAlert = nightLightAlert;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:nightLightAlert];
    [self.userDefaults setObject:data forKey:NIGHT_LIGHT_ALERT];
    [self.userDefaults synchronize];
}

- (NightLightAlert *)nightLightAlert
{
    NSData *data = [self.userDefaults objectForKey:NIGHT_LIGHT_ALERT];
    
    if (data) {
        NightLightAlert *alert = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (!alert){
            return [NightLightAlert nightLightAlertWithDefaultValues];
        }
        else{
            return alert;
        }
    }
    else{
        return [NightLightAlert nightLightAlertWithDefaultValues];
    }
    
    return nil;
}



@end
