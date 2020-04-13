//
//  SFASalutronSync+Utilities.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 6/17/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronSync+Utilities.h"
#import "StatisticalDataHeaderEntity.h"
#import "DeviceEntity+Data.h"
#import "TimeDate+Data.h"
#import "SalutronUserProfile+Data.h"
#import "SalutronUserProfile+SalutronUserProfileCategory.h"
#import "SFAGoalsData.h"
#import "JDACoreData.h"
#import "SleepSetting+Data.h"
#import "Notification+Data.h"
#import "WorkoutSettingEntity+CoreDataProperties.h"
#import "WorkoutSetting+Coding.h"

#import "InactiveAlert+Data.h"
#import "DayLightAlert+Data.h"
#import "NightLightAlert+Data.h"
#import "Wakeup+Data.h"

@implementation SFASalutronSync (Utilities)

#pragma mark - Checker

- (BOOL)isWatchModelR450:(int)numDevice
{
    DDLogInfo(@" ---> %@", numDevice ? BUTTON_TITLE_YES_ALL_CAPS : BUTTON_TITLE_NO_ALL_CAPS);
    return numDevice ? YES : NO;
}

- (BOOL)isMacAddressEmpty
{
    DDLogInfo(@" ---> %@", self.userDefaultsManager.macAddress != nil ? BUTTON_TITLE_YES_ALL_CAPS : BUTTON_TITLE_NO_ALL_CAPS);
    return self.userDefaultsManager.macAddress != nil ? YES : NO;
}

- (BOOL)isConnectedToWatchWithMacAddress:(NSString *)macAddress
{
    DDLogInfo(@"");
    NSArray *deviceEntities = [DeviceEntity deviceEntities];
    
    for (DeviceEntity *deviceEntity in deviceEntities) {
        if ([macAddress isEqualToString:deviceEntity.macAddress]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isConnectedToWatchWithUUID:(NSString *)uuid
{
    //DDLogInfo(@"");
    NSArray *deviceEntities = [DeviceEntity deviceEntities];
    
    for (DeviceEntity *deviceEntity in deviceEntities) {
        if ([uuid isEqualToString:deviceEntity.uuid]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isDataPointComplete:(StatisticalDataHeaderEntity *)headerEntity
{
    if ([headerEntity.dataPoint count] < 144) {
        return NO;
    }
    return YES;
}

#pragma mark - Device Index

- (NSInteger)deviceIndexForNumDevice:(int)numDevice
{
    //DDLogInfo(@"");
    for (NSInteger deviceIndex = 0; deviceIndex < numDevice; deviceIndex++) {
        
        DeviceDetail *deviceDetail = nil;
        Status deviceDetailStatus = [self.salutronSDK getDeviceDetail:deviceIndex with:&deviceDetail];
        DDLogError(@"DEVICE DETAIL : %@", deviceDetail);
        if (deviceDetailStatus == NO_ERROR && ![self isConnectedToWatchWithUUID:deviceDetail.peripheral.identifier.UUIDString]) {
            
            return deviceIndex;
            
        } else if (deviceIndex == numDevice - 1) {
            
            return deviceNotFoundInCoreData;
        }
    }
    return deviceNotFoundInCoreData;
}

#pragma mark - Settings Prompt

float doubleToFloat(float number){
    return floorf((float)number * 100 + 0.5) / 100;
}

- (BOOL)settingsChangedWithWatchTimeDate:(TimeDate *)timeDate salutronuserProfile:(SalutronUserProfile *)salutronUserProfile stepGoal:(int)stepGoal distanceGoal:(double)distanceGoal calorieGoal:(int)calorieGoal sleepSettings:(SleepSetting *)sleepSetting notification:(Notification *)notification
{
    if (self.userDefaultsManager.timeDate == nil || self.userDefaultsManager.salutronUserProfile == nil) {
        return NO;
    }
    
    if (![self.userDefaultsManager.notification isEqualToNotification:notification]) {
        DDLogInfo(@"settingsChanged: NOTIFICATION");
        return YES;
    }
    
    SleepSetting *appSleepSetting = [SleepSetting sleepSettingWithSleepSettingEntity:self.deviceEntity.sleepSetting];
    
    if (appSleepSetting.sleep_goal_hi != sleepSetting.sleep_goal_hi || appSleepSetting.sleep_goal_lo != sleepSetting.sleep_goal_lo) {
        DDLogInfo(@"settingsChanged: SLEEP SETTING");
        return YES;
    }
    
    
//    GoalsEntity *appGoalsEntity = [SFAGoalsData goalsFromNearestDate:[NSDate date] macAddress:self.userDefaultsManager.macAddress managedObject:[JDACoreData sharedManager].context];
    
    CGFloat watchDistanceGoal   = floorf((float)distanceGoal * 100 + 0.5) / 100;
    CGFloat watchCaloriesGoal   = floorf((float)calorieGoal * 100 + 0.5) / 100;
    CGFloat watchStepsGoal      = floorf((float)stepGoal * 100 + 0.5) / 100;
    
    CGFloat appDistanceGoal     = floorf((float)self.userDefaultsManager.distanceGoal * 100 + 0.5) / 100;
    CGFloat appCaloriesGoal     = floorf((float)self.userDefaultsManager.calorieGoal * 100 + 0.5) / 100;
    CGFloat appStepsGoal     = floorf((float)self.userDefaultsManager.stepGoal * 100 + 0.5) / 100;
    
    CGFloat roundedWatchDistanceGoal    = [[NSString stringWithFormat:@"%.1f", watchDistanceGoal] doubleValue];//floorf(savedDistanceGoal * 100 + 0.5) / 100;
    CGFloat roundedAppDistanceGoal         = [[NSString stringWithFormat:@"%.1f", appDistanceGoal] doubleValue];//floorf(self.distanceGoal *
    
    
    if (watchCaloriesGoal != appCaloriesGoal ||
        !(roundedWatchDistanceGoal - roundedAppDistanceGoal <= 0.1 && roundedWatchDistanceGoal - roundedAppDistanceGoal >= -0.1) ||
        //roundedWatchDistanceGoal != roundedAppDistanceGoal ||
        watchStepsGoal != appStepsGoal){
        DDLogInfo(@"settingsChanged: GOALS DATA");
        return YES;
    }
    
    SalutronUserProfile *appUserProfile = [SalutronUserProfile userProfileWithUserProfileEntity:self.deviceEntity.userProfile];
    SalutronUserProfile *watchUserProfile = salutronUserProfile;
    
    if (![appUserProfile isEqualToUserProfile:watchUserProfile] && appUserProfile != nil) {
        DDLogInfo(@"settingsChanged: SALUTRON USER PROFILE");
        return YES;
    }

    TimeDate *appTimeDate   = [TimeDate timeDateWithTimeDateEntity:self.deviceEntity.timeDate];
    TimeDate *watchTimeDate = timeDate;
    
    if (appTimeDate.hourFormat != watchTimeDate.hourFormat ||
        appTimeDate.dateFormat != watchTimeDate.dateFormat ||
        appTimeDate.watchFace  != watchTimeDate.watchFace/*![appTimeDate isEqualToTimeDate:watchTimeDate] && appTimeDate != nil*/) {
        DDLogInfo(@"settingsChanged: TIME DATE app - %@ ?= watch - %@", appTimeDate, watchTimeDate);
        return YES;
    }
    
    return NO;
}

- (BOOL)settingsChangedWithWatchTimeDate:(TimeDate *)timeDate salutronuserProfile:(SalutronUserProfile *)salutronUserProfile stepGoal:(int)stepGoal distanceGoal:(double)distanceGoal calorieGoal:(int)calorieGoal sleepSettings:(SleepSetting *)sleepSetting notification:(Notification *)notification inactiveAlert:(InactiveAlert *)inactiveAlert dayLightAlert:(DayLightAlert *)dayLightAlert nightLightAlert:(NightLightAlert *)nightLightAlert wakeupAlert:(Wakeup *)wakeupAlert
{
    if (self.userDefaultsManager.timeDate == nil || self.userDefaultsManager.salutronUserProfile == nil) {
        return NO;
    }
    
    if (![self.userDefaultsManager.notification isEqualToNotification:notification]) {
        DDLogInfo(@"settingsChanged: NOTIFICATION");
        return YES;
    }
    
    SleepSetting *appSleepSetting = [SleepSetting sleepSettingWithSleepSettingEntity:self.deviceEntity.sleepSetting];
    
    if (appSleepSetting.sleep_goal_hi != sleepSetting.sleep_goal_hi || appSleepSetting.sleep_goal_lo != sleepSetting.sleep_goal_lo) {
        DDLogInfo(@"settingsChanged: SLEEP SETTING");
        return YES;
    }
    
    //    GoalsEntity *appGoalsEntity = [SFAGoalsData goalsFromNearestDate:[NSDate date] macAddress:self.userDefaultsManager.macAddress managedObject:[JDACoreData sharedManager].context];
    
    CGFloat watchDistanceGoal   = floorf((float)distanceGoal * 100 + 0.5) / 100;
    CGFloat watchCaloriesGoal   = floorf((float)calorieGoal * 100 + 0.5) / 100;
    CGFloat watchStepsGoal      = floorf((float)stepGoal * 100 + 0.5) / 100;
    
    CGFloat appDistanceGoal     = floorf((float)self.userDefaultsManager.distanceGoal * 100 + 0.5) / 100;
    CGFloat appCaloriesGoal     = floorf((float)self.userDefaultsManager.calorieGoal * 100 + 0.5) / 100;
    CGFloat appStepsGoal     = floorf((float)self.userDefaultsManager.stepGoal * 100 + 0.5) / 100;
    
    CGFloat roundedWatchDistanceGoal    = [[NSString stringWithFormat:@"%.1f", watchDistanceGoal] doubleValue];//floorf(savedDistanceGoal * 100 + 0.5) / 100;
    CGFloat roundedAppDistanceGoal         = [[NSString stringWithFormat:@"%.1f", appDistanceGoal] doubleValue];//floorf(self.distanceGoal *
    if (watchCaloriesGoal != appCaloriesGoal ||
        !(roundedWatchDistanceGoal - roundedAppDistanceGoal <= 0.1 && roundedWatchDistanceGoal - roundedAppDistanceGoal >= -0.1)
        || watchStepsGoal != appStepsGoal){
        ///*roundedAppDistanceGoal != roundedWatchDistanceGoal*/
        DDLogInfo(@"settingsChanged: GOALS DATA");
        return YES;
    }
    
    SalutronUserProfile *appUserProfile = [SalutronUserProfile userProfileWithUserProfileEntity:self.deviceEntity.userProfile];
    SalutronUserProfile *watchUserProfile = salutronUserProfile;
    
    if ((appUserProfile.birthday.month != watchUserProfile.birthday.month ||
        appUserProfile.birthday.day != watchUserProfile.birthday.day ||
        appUserProfile.birthday.year != watchUserProfile.birthday.year ||
        appUserProfile.gender != watchUserProfile.gender ||
        appUserProfile.unit != watchUserProfile.unit ||
        appUserProfile.weight != watchUserProfile.weight ||
        appUserProfile.height != watchUserProfile.height)
        && appUserProfile != nil) {
        DDLogInfo(@"settingsChanged: SALUTRON USER PROFILE");
        return YES;
    }
    /*
    if (![appUserProfile isEqualToUserProfile:watchUserProfile] && appUserProfile != nil) {
        DDLogInfo(@"SALUTRON USER PROFILE");
        return YES;
    }
    */
    TimeDate *appTimeDate   = [TimeDate timeDateWithTimeDateEntity:self.deviceEntity.timeDate];
    TimeDate *watchTimeDate = timeDate;
    
    if (appTimeDate.hourFormat != watchTimeDate.hourFormat ||
        appTimeDate.dateFormat != watchTimeDate.dateFormat ||
        appTimeDate.watchFace  != watchTimeDate.watchFace/*![appTimeDate isEqualToTimeDate:watchTimeDate] && appTimeDate != nil*/) {
        DDLogInfo(@"settingsChanged: TIME DATE app - %@ ?= watch - %@", appTimeDate, watchTimeDate);
        return YES;
    }
    
    InactiveAlert *appInactiveAlert = self.userDefaultsManager.inactiveAlert;

    if (![appInactiveAlert isEqualToInactiveAlert:inactiveAlert] && inactiveAlert != nil){
        DDLogInfo(@"settingsChanged: INACTIVE ALERT");
        return YES;
    }
    
    DayLightAlert *appDayLightAlert = self.userDefaultsManager.dayLightAlert;
    if (![appDayLightAlert isEqualToDayLightAlert:dayLightAlert] && dayLightAlert != nil){
        DDLogInfo(@"settingsChanged: DAY LIGHT ALERT");
        return YES;
    }
    
    NightLightAlert *appNightLightAlert = self.userDefaultsManager.nightLightAlert;
    if (![appNightLightAlert isEqualToNightLightAlert:nightLightAlert] && nightLightAlert != nil){
        DDLogInfo(@"settingsChanged: NIGHT LIGHT ALERT");
        return YES;
    }
    
    Wakeup *wakeupValue = self.userDefaultsManager.wakeUp;
    if (wakeupValue != nil && ![wakeupValue isEqualToWakeupAlert:wakeupAlert]) {
        DDLogInfo(@"settingsChanged: WAKEUP ALERT");
        return YES;
    }
    
    return NO;
}

- (BOOL)settingsChangedWithWatchTimeDate:(TimeDate *)timeDate salutronuserProfile:(SalutronUserProfile *)salutronUserProfile stepGoal:(int)stepGoal distanceGoal:(double)distanceGoal calorieGoal:(int)calorieGoal sleepSettings:(SleepSetting *)sleepSetting workoutSetting:(WorkoutSetting *)workoutSetting
{
    if (self.userDefaultsManager.timeDate == nil || self.userDefaultsManager.salutronUserProfile == nil) {
        return NO;
    }
    
    SleepSetting *appSleepSetting = [SleepSetting sleepSettingWithSleepSettingEntity:self.deviceEntity.sleepSetting];
    
    if (appSleepSetting.sleep_goal_hi != sleepSetting.sleep_goal_hi || appSleepSetting.sleep_goal_lo != sleepSetting.sleep_goal_lo) {
        DDLogInfo(@"settingsChanged: SLEEP SETTING");
        return YES;
    }
    
    CGFloat watchDistanceGoal   = floorf((float)distanceGoal * 100 + 0.5) / 100;
    CGFloat watchCaloriesGoal   = floorf((float)calorieGoal * 100 + 0.5) / 100;
    CGFloat watchStepsGoal      = floorf((float)stepGoal * 100 + 0.5) / 100;
    
    CGFloat appDistanceGoal     = floorf((float)self.userDefaultsManager.distanceGoal * 100 + 0.5) / 100;
    CGFloat appCaloriesGoal     = floorf((float)self.userDefaultsManager.calorieGoal * 100 + 0.5) / 100;
    CGFloat appStepsGoal     = floorf((float)self.userDefaultsManager.stepGoal * 100 + 0.5) / 100;
    
    CGFloat roundedWatchDistanceGoal    = [[NSString stringWithFormat:@"%.1f", watchDistanceGoal] doubleValue];//floorf(savedDistanceGoal * 100 + 0.5) / 100;
    CGFloat roundedAppDistanceGoal         = [[NSString stringWithFormat:@"%.1f", appDistanceGoal] doubleValue];//floorf(self.distanceGoal *
    if (watchCaloriesGoal != appCaloriesGoal ||
        !(roundedWatchDistanceGoal - roundedAppDistanceGoal <= 0.1 && roundedWatchDistanceGoal - roundedAppDistanceGoal >= -0.1)
        || watchStepsGoal != appStepsGoal){
        ///*roundedAppDistanceGoal != roundedWatchDistanceGoal*/
        DDLogInfo(@"settingsChanged: GOALS DATA");
        return YES;
    }
    
    SalutronUserProfile *appUserProfile = [SalutronUserProfile userProfileWithUserProfileEntity:self.deviceEntity.userProfile];
    SalutronUserProfile *watchUserProfile = salutronUserProfile;
    
    if ((appUserProfile.birthday.month != watchUserProfile.birthday.month ||
         appUserProfile.birthday.day != watchUserProfile.birthday.day ||
         appUserProfile.birthday.year != watchUserProfile.birthday.year ||
         appUserProfile.gender != watchUserProfile.gender ||
         appUserProfile.unit != watchUserProfile.unit ||
         appUserProfile.weight != watchUserProfile.weight ||
         appUserProfile.height != watchUserProfile.height)
        && appUserProfile != nil) {
        DDLogInfo(@"settingsChanged: SALUTRON USER PROFILE");
        return YES;
    }
    
    TimeDate *appTimeDate   = [TimeDate timeDateWithTimeDateEntity:self.deviceEntity.timeDate];
    TimeDate *watchTimeDate = timeDate;
    
    if (appTimeDate.hourFormat != watchTimeDate.hourFormat ||
        appTimeDate.dateFormat != watchTimeDate.dateFormat ||
        appTimeDate.watchFace  != watchTimeDate.watchFace/*![appTimeDate isEqualToTimeDate:watchTimeDate] && appTimeDate != nil*/) {
        DDLogInfo(@"settingsChanged: TIME DATE app - %@ ?= watch - %@", appTimeDate, watchTimeDate);
        return YES;
    }
    
    WorkoutSettingEntity *workoutSettingEntity = self.deviceEntity.workoutSetting;
    
    if (workoutSettingEntity.hrLogRate.integerValue != workoutSetting.HRLogRate) {
        DDLogInfo(@"settingsChanged: hrlograte");
        return YES;
    }
    if (![workoutSettingEntity.reconnectTimeout isEqualToNumber:[NSNumber numberWithChar:workoutSetting.reconnectTimeout]]) {
        DDLogInfo(@"settingsChanged: reconnecttimeout %@ != %@", workoutSettingEntity.reconnectTimeout, [NSNumber numberWithChar:workoutSetting.reconnectTimeout]);
        return YES;
    }
    
    return NO;
}

#pragma mark - SFASalutronSync delegate methods

- (void)establishConnection
{
    DDLogInfo(@"");
    
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(syncStartedWithDeviceEntity:)]) {
            [self.delegate syncStartedWithDeviceEntity:self.deviceEntity];
        }
        if ([self.delegate respondsToSelector:@selector(didPairWatch)]) {
            [self.delegate didPairWatch];
        }
    }
}

- (void)startSyncing
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didDeviceConnected)]) {
            [self.delegate didDeviceConnected];
        }
        if ([self.delegate respondsToSelector:@selector(didSyncStarted)]) {
            [self.delegate didSyncStarted];
        }
        if([self.delegate respondsToSelector:@selector(didSyncOnDataHeaders)]) {
            [self.delegate didSyncOnDataHeaders];
        }
    }
}

- (void)startSyncOnDataHeaders
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnDataHeaders)]) {
            [self.delegate didSyncOnDataHeaders];
        }
    }
}

- (void)startSyncOnDataPoints
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnDataPoints)]) {
            [self.delegate didSyncOnDataPoints];
        }
    }
}

- (void)startSyncOnLightDataPoints
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnLightDataPoints)]) {
            [self.delegate didSyncOnLightDataPoints];
        }
    }
}

- (void)startSyncOnStepGoal
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnStepGoal)]) {
            [self.delegate didSyncOnStepGoal];
        }
    }
}

- (void)startSyncOnDistanceGoal
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnDistanceGoal)]) {
            [self.delegate didSyncOnDistanceGoal];
        }
    }
}

- (void)startSyncOnCalorieGoal
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnCalorieGoal)]) {
            [self.delegate didSyncOnCalorieGoal];
        }
    }
}

- (void)startSyncOnNotification
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnNotification)]) {
            [self.delegate didSyncOnNotification];
        }
    }
}

- (void)startSyncOnAlerts
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnAlerts)]) {
            [self.delegate didSyncOnAlerts];
        }
    }
}


- (void)startSyncOnSleepSettings
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnSleepSettings)]) {
            [self.delegate didSyncOnSleepSettings];
        }
    }
}

- (void)startSyncOnCalibrationData
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnCalibrationData)]) {
            [self.delegate didSyncOnCalibrationData];
        }
    }
}

- (void)startSyncOnWorkoutDatabase
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnWorkoutDatabase)]) {
            [self.delegate didSyncOnWorkoutDatabase];
        }
    }
}

- (void)startSyncOnWorkoutStopDatabase
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnWorkoutStopDatabase)]) {
            [self.delegate didSyncOnWorkoutStopDatabase];
        }
    }
}

- (void)startSyncOnSleepDatabase
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnSleepDatabase)]) {
            [self.delegate didSyncOnSleepDatabase];
        }
    }
}

- (void)startSyncOnUserProfile
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnUserProfile)]) {
            [self.delegate didSyncOnUserProfile];
        }
    }
}

- (void)startSyncOnTimeAndDate
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncOnTimeAndDate)]) {
            [self.delegate didSyncOnTimeAndDate];
        }
    }
}

- (void)finishedSyncing
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didSyncFinished:profileUpdated:)]) {
            [self.delegate didSyncFinished:self.deviceEntity profileUpdated:YES];
        }
    }
    self.delegate = nil;
    self.syncingFinished  = YES;
}

- (void)settingsChanged
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(didChangeSettings)]) {
            [self.delegate didChangeSettings];
        }
    }
    //self.delegate = nil;
}

- (void)startSearchConnectedDevice:(BOOL)found
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
        [self.delegate respondsToSelector:@selector(didSearchConnectedWatch:)]) {
        [self.delegate didSearchConnectedWatch:found];
    }
}

- (void)startDeviceConnectedFromSearching
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
        [self.delegate respondsToSelector:@selector(didDeviceConnectedFromSearching)]) {
        [self.delegate didDeviceConnectedFromSearching];
    }
}

- (void)startRetrieveConnectedDeviceFromSearching
{
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
        [self.delegate respondsToSelector:@selector(didRetrieveDeviceFromSearching)]) {
        [self.delegate didRetrieveDeviceFromSearching];
    }
}

@end
