//
//  SFASalutronSyncC300.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/19/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronSyncC300.h"
#import "SFASalutronLibrary.h"
#import "SFAGoalsData.h"

#import "SFAServerSyncManager.h"

//#import "Logger.h"
#import "ErrorCodeToStringConverter.h"
#import "WorkoutInfo.h"
#import "WorkoutStopDatabase.h"
#import "SleepDatabase.h"
#import "SalutronUserProfile+SalutronUserProfileCategory.h"
#import "ModelNumber.h"
#import "WakeupEntity+Data.h"
#import "TimeDate+Data.h"
#import "TimeDate+Encoder.h"

#import "UserProfileEntity+Data.h"
#import "TimeDateEntity+Data.h"
#import "NotificationEntity+Data.h"
#import "SleepSettingEntity+Data.h"
#import "CalibrationDataEntity+Data.h"

#import "DateEntity.h"
#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "WorkoutInfoEntity+Data.h"
#import "WorkoutStopDatabaseEntity+Data.h"
#import "SleepDatabaseEntity+SleepDatabaseEntityCategory.h"
#import "SleepDatabaseEntity+Data.h"

#import "CalibrationData+Data.h"

#import "SFAWatchManager.h"
#import "SFAServerAccountManager.h"

#import "SFAHealthKitManager.h"
#import "HKUnit+Custom.h"
#import "NSDate+Format.h"

#import "Flurry.h"

#define DISCOVER_TIMEOUT 10
#define SELECTOR_DELAY 0
#define SEARCH_TIMEOUT 10

typedef struct {
    unsigned short int index;
    unsigned short int modelNumber;
    char *modelName;
} DeviceInfo;

@interface SFASalutronSyncC300() <SalutronSDKDelegate, SFAHealthKitManagerDelegate, UIAlertViewDelegate>

@property (assign, nonatomic) WatchModel                    watchModel;
@property (assign, nonatomic) NSUInteger                    numberOfDiscoveredDevice;
@property (assign, nonatomic) NSUInteger                    discoveredDeviceIndex;
@property (assign, nonatomic) NSUInteger                    calibrationType;
@property (strong, nonatomic) DeviceDetail                  *deviceDetail;
@property (strong, nonatomic) NSManagedObjectContext        *managedObjectContext;
@property (strong, nonatomic) SFASalutronLibrary            *salutronLibrary;
@property (strong, nonatomic) DeviceEntity                  *deviceEntity;
@property (strong, nonatomic) NSMutableArray                *headerIndexes;
@property (strong, nonatomic) NSMutableArray                *statisticalDataHeaderEntities;
@property (assign, nonatomic) NSUInteger                    headerIndex;
@property (strong, nonatomic) StatisticalDataHeaderEntity   *statisticalDataHeaderEntity;
@property (strong, nonatomic) NSUserDefaults                *userDefaults;
@property (readwrite, nonatomic) BOOL                       retrievingDevice;
@property (readwrite, nonatomic) BOOL                       deviceRetrieved;
@property (assign, nonatomic) BOOL                          isSyncFinished;
@property (strong, nonatomic) ModelNumber                   *modelNumber;
@property (strong, nonatomic) NSMutableArray                *deviceDetails;
@property (strong, nonatomic) NSString                      *uuid;
@property (strong, nonatomic) NSString                      *macAddress;
@property (assign, nonatomic) NSInteger                     wakeupType;
@property (strong, nonatomic) WakeupEntity                  *wakeupEntity;

// Workout Info
@property (strong, nonatomic) NSMutableArray                *workoutInfoEntities;
@property (readwrite, nonatomic) NSInteger                  workoutInfoIndex;


@property (strong, nonatomic) SalutronUserProfile   *watchUserProfile;
@property (strong, nonatomic) TimeDate              *watchTimeDate;
@property (strong, nonatomic) SalutronUserProfile   *appUserProfile;
@property (strong, nonatomic) TimeDate              *appTimeDate;
@property (readwrite, nonatomic) BOOL               timeDateChanged;

// Goals
@property (readwrite, nonatomic) NSInteger      calorieGoal;
@property (readwrite, nonatomic) NSInteger      stepGoal;
@property (readwrite, nonatomic) CGFloat        distanceGoal;
@property (readwrite, nonatomic) SleepSetting   *sleepSetting;

//@property (strong, nonatomic) CalibrationData   *watchCalibrationData;
@property (strong, nonatomic) NSMutableArray    *watchCalibrationData;
@property (strong, nonatomic) NSMutableArray    *retrievedDataHeadersForCurrentSync;
@property (readwrite, nonatomic) BOOL watchSettingsSyncingDone;
@property (readwrite, nonatomic) BOOL singleCommandExecution; //delegate must only call SFASalutronCModelSync sdk delegate, without continuous syncing flow

@end

@implementation SFASalutronSyncC300

static bool hasDeviceFound = NO;
static bool isDeviceConnected = NO;
static bool enableNotifyChecksum = YES;
static bool connectedFromRetrievedDevice = YES;

@synthesize sleepSetting = _sleepSetting;

- (id) initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    if(self = [super init]) {
        _managedObjectContext   = managedObjectContext;
    }
    return self;
}

#pragma mark - Public Properties

- (SalutronSDK *)salutronSDK {
    if(!_salutronSDK) {
        _salutronSDK = [SalutronSDK sharedInstance];
    }
    
    return _salutronSDK;
}

- (NSMutableArray *)retrievedDataHeadersForCurrentSync{
    if (!_retrievedDataHeadersForCurrentSync) {
        _retrievedDataHeadersForCurrentSync = [[NSMutableArray alloc] init];
    }
    return _retrievedDataHeadersForCurrentSync;
}

#pragma mark - Setters

- (void)setSleepSetting:(SleepSetting *)sleepSetting
{
    if (sleepSetting) {
        _sleepSetting = sleepSetting;
    }
}

#pragma mark - Getters

- (SleepSetting *)sleepSetting
{
    if (!_sleepSetting) {
        NSData *sleepSettingData = [self.userDefaults objectForKey:SLEEP_SETTING];
        
        if (sleepSettingData) {
            _sleepSetting = [NSKeyedUnarchiver unarchiveObjectWithData:sleepSettingData];
        } else {
            _sleepSetting = [[SleepSetting alloc] init];
            _sleepSetting.sleep_goal_hi = (480&0xff00)>>8;
            _sleepSetting.sleep_goal_lo = 480&0x00ff;
            _sleepSetting.sleep_mode    = AUTO;
        }
    }
    
    return _sleepSetting;
}

#pragma mark - Public Methods

- (void)startSyncWithWatchModel:(WatchModel)watchModel
{
    DDLogInfo(@"\n---------------> WATCHMODEL: %d\n", watchModel);
    self.watchModel = watchModel;
    self.salutronSDK.delegate = self;
    [self checkConnectedDevice];
    
    /*if (self.watchModel == WatchModel_Move_C300 ||
        self.watchModel == WatchModel_Core_C200 ||
        self.watchModel == WatchModel_Zone_C410) {
        [[SFAWatchManager sharedManager] disableAutoSync];
    }*/

}

- (void)startSyncWithDeviceEntity:(DeviceEntity *)deviceEntity watchModel:(WatchModel)watchModel
{
    DDLogInfo(@"\n---------------> WATCHMODEL: %d\n", watchModel);
    self.deviceEntity = deviceEntity;
    [self startSyncWithWatchModel:watchModel];
}

- (void)checkConnectedDevice
{
    DDLogInfo(@"");
    _retrievingDevice = YES;
    _deviceRetrieved = NO;
    
    [self.salutronSDK clearDiscoveredDevice];
   // Status status = [self.salutronSDK retrieveConnectedDevice];
   // DDLogInfo(@"RETRIEVE CONNECTED DEVICE");
    //[self performSelector:@selector(discoverTimeout) withObject:nil afterDelay:00];
    
   // if(status != NO_ERROR){
        [self discoverDevice];
   // }
}

- (void)disconnectWatch
{
    DDLogInfo(@"");
    self.watchSettingsSelected = NO;
    [self.salutronSDK commDone];
}

- (void)deleteDevice
{
    if (self.deviceEntity) {
        [self.managedObjectContext deleteObject:self.deviceEntity];
        [self.managedObjectContext save:nil];
        
        self.deviceEntity = nil;
    }
}

- (void)useAppSettings
{
    DDLogInfo(@"");
    [SleepSettingEntity sleepSettingWithSleepSetting:self.sleepSetting forDeviceEntity:self.deviceEntity];
    [UserProfileEntity userProfileWithSalutronUserProfile:self.watchUserProfile forDeviceEntity:self.deviceEntity];
    [TimeDateEntity timeDateWithTimeDate:self.watchTimeDate forDeviceEntity:self.deviceEntity];

    NSData *sleepSettingData    = [self.userDefaults objectForKey:SLEEP_SETTING];
    NSData *userProfileData     = [NSKeyedArchiver archivedDataWithRootObject:self.appUserProfile];
    NSData *timeDateData        = [NSKeyedArchiver archivedDataWithRootObject:self.appTimeDate];
    self.calorieGoal            = [self.userDefaults integerForKey:CALORIE_GOAL];
    self.stepGoal               = [self.userDefaults integerForKey:STEP_GOAL];
    self.distanceGoal           = [self.userDefaults floatForKey:DISTANCE_GOAL];
    self.sleepSetting           = [NSKeyedUnarchiver unarchiveObjectWithData:sleepSettingData];
    NSInteger sleepGoal         = self.sleepSetting.sleep_goal_lo;
    sleepGoal                   += self.sleepSetting.sleep_goal_hi << 8;
    
    [SFAGoalsData addGoalsWithSteps:self.stepGoal
                           distance:self.distanceGoal
                           calories:self.calorieGoal
                              sleep:sleepGoal
                             device:self.deviceEntity
                      managedObject:_managedObjectContext];
    
    
    [self.userDefaults setObject:userProfileData forKey:USER_PROFILE];
    [self.userDefaults setObject:timeDateData forKey:TIME_DATE];
    [self.userDefaults synchronize];
    
    
    //[self performSelector:@selector(saveCalorieGoalToWatch) withObject:nil afterDelay:SELECTOR_DELAY];
//    [self performSelector:@selector(saveTimeDateToWatch) withObject:nil afterDelay:SELECTOR_DELAY];
//    [self saveTimeDateToWatch];
    [self performSelector:@selector(saveUserProfileToWatch) withObject:nil afterDelay:0];
    //[self performSelector:@selector(saveTimeDateToWatch) withObject:nil afterDelay:0];
    
    /*
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
        [self.delegate respondsToSelector:@selector(didSaveSettings)]) {
        [self.delegate didSaveSettings];
    }*/
}

- (void)saveTimeDateToWatch
{
    DDLogInfo(@"");
    /*
    TimeDate *timeDate = [[TimeDate alloc] initWithDate:[NSDate date]];
    timeDate.hourFormat = self.appTimeDate.hourFormat;
    timeDate.dateFormat = self.appTimeDate.dateFormat;
    
    */
    //TimeDate *timeDate      = self.appTimeDate;
    TimeDate *timeDate      = [[TimeDate alloc] initWithDate:[NSDate new]];
    //TimeDate *tempTimeDate  = [TimeDate getUpdatedData];
    
    //timeDate.time           = tempTimeDate.time;
    //timeDate.date           = tempTimeDate.date;
    timeDate.hourFormat     = self.appTimeDate.hourFormat;
    timeDate.dateFormat     = self.appTimeDate.dateFormat;
    timeDate.watchFace      = self.appTimeDate.watchFace;
    

    //[_salutronSDK updateTimeAndDate:self.appTimeDate];
    //if(self.isUpdateTimeAndDate)
    [_salutronSDK updateTimeAndDate:timeDate];
//    [self saveUserProfileToWatch];
    
    //[self performSelector:@selector(saveUserProfileToWatch) withObject:nil afterDelay:0];
   [self performSelector:@selector(saveCalorieGoalToWatch) withObject:nil afterDelay:0];
}

- (void)saveUserProfileToWatch
{
    DDLogInfo(@"");
    NSData *userProfileData             = [self.userDefaults objectForKey:USER_PROFILE];
    SalutronUserProfile *_userProfile   = [NSKeyedUnarchiver unarchiveObjectWithData:userProfileData];
    Status status = [self.salutronSDK updateUserProfile:_userProfile];
    DDLogInfo(@"saveUserProfileToWatch status - %@", [ErrorCodeToStringConverter convertToString:status]);
    
    self.calibrationType = 0;
    self.wakeupType = 0;
    
//    [self performSelector:@selector(saveCalorieGoalToWatch) withObject:nil afterDelay:SELECTOR_DELAY];
    //[self saveCalorieGoalToWatch];
    
//    [self performSelector:@selector(saveTimeDateToWatch) withObject:nil afterDelay:3.0f];
    
    /*[self performSelector:@selector(disconnectWatch) withObject:nil afterDelay:SELECTOR_DELAY];
     
     if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
     [self.delegate respondsToSelector:@selector(didSaveSettings)]) {
     [self.delegate didSaveSettings];
     }*/
}

- (void)saveCalorieGoalToWatch
{
    DDLogInfo(@"");
    [_salutronSDK updateCalorieGoal:self.calorieGoal];
    [self performSelector:@selector(saveStepGoalToWatch) withObject:nil afterDelay:0];
}

- (void)saveStepGoalToWatch
{
    DDLogInfo(@"");
    [_salutronSDK updateStepGoal:self.stepGoal];
    //[self saveDistanceGoalToWatch];
    [self performSelector:@selector(saveDistanceGoalToWatch) withObject:nil afterDelay:0];
}

- (void)saveDistanceGoalToWatch
{
    DDLogInfo(@"");
    [_salutronSDK updateDistanceGoal:self.distanceGoal];
    [self performSelector:@selector(saveSleepSettingsToWatch) withObject:nil afterDelay:0];
    //[self saveSleepSettingsToWatch];
}

- (void)saveSleepSettingsToWatch
{
    DDLogInfo(@"");
    [_salutronSDK updateSleepSetting:self.sleepSetting];
    //[self performSelector:@selector(saveTimeDateToWatch) withObject:nil afterDelay:SELECTOR_DELAY];
    
    [SleepSettingEntity sleepSettingWithSleepSetting:self.sleepSetting forDeviceEntity:self.deviceEntity];
    [UserProfileEntity userProfileWithSalutronUserProfile:self.appUserProfile forDeviceEntity:self.deviceEntity];
    [TimeDateEntity timeDateWithTimeDate:self.appTimeDate forDeviceEntity:self.deviceEntity];
    
//    [self performSelector:@selector(disconnectWatch) withObject:nil afterDelay:SELECTOR_DELAY];
//    [self disconnectWatch];
    
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
        [self.delegate respondsToSelector:@selector(didSaveSettings)]) {
        [self.delegate didSaveSettings];
    }
    
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncFinished:profileUpdated:)]) {
        self.isSyncFinished = YES;
        self.deviceEntity.lastDateSynced = [NSDate date];
        [self.managedObjectContext save:nil];
        [self.delegate didSyncFinished:self.deviceEntity profileUpdated:YES];
    }
    [self.userDefaults setObject:self.deviceDetail.peripheral.identifier.UUIDString forKey:DEVICE_UUID];
    [self.userDefaults synchronize];
    
    self.salutronSDK.delegate = nil;
    self.salutronSDK = nil;
    _salutronSDK = nil;
    
    //[self syncToServer];
}

- (void)useWatchSettings
{
    DDLogInfo(@"");
    self.watchSettingsSelected = YES;
    
    TimeDate *timeDate      = [[TimeDate alloc] initWithDate:[NSDate new]];
    timeDate.hourFormat     = self.watchTimeDate.hourFormat;
    timeDate.dateFormat     = self.watchTimeDate.dateFormat;
    timeDate.watchFace      = self.watchTimeDate.watchFace;
    
    //[_salutronSDK updateTimeAndDate:self.watchTimeDate];
    [_salutronSDK updateTimeAndDate:timeDate];
    //[_salutronSDK updateUserProfile:self.watchUserProfile];
    
    NSInteger sleepGoal         = self.sleepSetting.sleep_goal_lo;
    sleepGoal                   += self.sleepSetting.sleep_goal_hi << 8;
    NSData *sleepSettingData    = [NSKeyedArchiver archivedDataWithRootObject:self.sleepSetting];
    NSData *userProfileData     = [NSKeyedArchiver archivedDataWithRootObject:self.watchUserProfile];
    NSData *timeDateData        = [NSKeyedArchiver archivedDataWithRootObject:self.watchTimeDate];
    
    [SFAGoalsData addGoalsWithSteps:self.stepGoal
                           distance:self.distanceGoal
                           calories:self.calorieGoal
                              sleep:sleepGoal
                             device:self.deviceEntity
                      managedObject:_managedObjectContext];
    
    [self.userDefaults setInteger:sleepGoal forKey:SLEEP_GOAL];
    [self.userDefaults setInteger:self.calorieGoal forKey:CALORIE_GOAL];
    [self.userDefaults setInteger:self.stepGoal forKey:STEP_GOAL];
    [self.userDefaults setFloat:self.distanceGoal forKey:DISTANCE_GOAL];
    [self.userDefaults setObject:sleepSettingData forKey:SLEEP_SETTING];
    [self.userDefaults setObject:userProfileData forKey:USER_PROFILE];
    [self.userDefaults setObject:timeDateData forKey:TIME_DATE];
    
    
    
    [SleepSettingEntity sleepSettingWithSleepSetting:self.sleepSetting forDeviceEntity:self.deviceEntity];
    [UserProfileEntity userProfileWithSalutronUserProfile:self.watchUserProfile forDeviceEntity:self.deviceEntity];
    [TimeDateEntity timeDateWithTimeDate:self.watchTimeDate forDeviceEntity:self.deviceEntity];
    
    for (CalibrationData *data in self.watchCalibrationData){
        [CalibrationDataEntity calibrationDataWithCalibrationData:data forDeviceEntity:self.deviceEntity];
    }

    
//    [self performSelector:@selector(disconnectWatch) withObject:nil afterDelay:SELECTOR_DELAY];
//    [self disconnectWatch];
    
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
        [self.delegate respondsToSelector:@selector(didSaveSettings)]) {
        [self.delegate didSaveSettings];
    }
    
    //[self syncToServer];
}

- (void)syncToServer
{
    DDLogInfo(@"");
    SFAServerSyncManager *manager = [SFAServerSyncManager sharedManager];
    [manager syncDeviceEntity:self.deviceEntity withSuccess:^(NSString *macAddress) {
        DDLogError(@"Sync to server success.");
        [self storeToServerWithMacAddress:macAddress];
    } failure:^(NSError *error) {
        DDLogError(@"Sync to server error: %@", error.localizedDescription);
    }];
}

- (void)storeToServerWithMacAddress:(NSString *)macAddress
{
    DDLogInfo(@"");
    SFAServerSyncManager *manager = [SFAServerSyncManager sharedManager];
    [manager storeWithMacAddress:macAddress success:^{
        DDLogError(@"Store to server success.");
    } failure:^(NSError *error) {
        DDLogError(@"Store to server error: %@", error.localizedDescription);
    }];
}

#pragma mark - Private Methods

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
    DDLogInfo(@"");
    NSArray *deviceEntities = [DeviceEntity deviceEntities];
    
    for (DeviceEntity *deviceEntity in deviceEntities) {
        if ([uuid isEqualToString:deviceEntity.uuid]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isExistingInUserSyncedListWatchWithUUID:(NSString *)uuid
{
    DDLogInfo(@"");
    NSArray *deviceEntities = [DeviceEntity deviceEntities];
    
    UserEntity *userEntity = [[SFAServerAccountManager sharedManager] user];
    
    for (DeviceEntity *deviceEntity in deviceEntities) {
        if ([uuid isEqualToString:deviceEntity.uuid] && [userEntity isEqual:deviceEntity.user]) {
            return YES;
        }
    }
    
    return NO;
}

- (SFASalutronLibrary *)salutronLibrary {
    if(!_salutronLibrary) {
        _salutronLibrary = [[SFASalutronLibrary alloc] initWithManagedObjectContext:self.managedObjectContext];
    }
    return _salutronLibrary;
}

- (NSMutableArray *)headerIndexes {
    if(!_headerIndexes)
        _headerIndexes = [[NSMutableArray alloc] init];
    return _headerIndexes;
}

- (NSMutableArray *)statisticalDataHeaderEntities {
    if(!_statisticalDataHeaderEntities)
        _statisticalDataHeaderEntities = [[NSMutableArray alloc] init];
    return _statisticalDataHeaderEntities;
}

- (NSUserDefaults *)userDefaults {
    if(!_userDefaults)
        _userDefaults = [NSUserDefaults standardUserDefaults];
    return _userDefaults;
}

- (NSMutableArray *)deviceDetails
{
    if(!_deviceDetails)
        _deviceDetails = [[NSMutableArray alloc] init];
    return _deviceDetails;
}

- (NSMutableArray *)workoutInfoEntities
{
    if (!_workoutInfoEntities) {
        _workoutInfoEntities = [NSMutableArray new];
    }
    
    return _workoutInfoEntities;
}

- (void)raiseError
{
    DDLogInfo(@"");
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didRaiseError)]) {
        [self.delegate didRaiseError];
    }
}

- (void)discoverDevice
{
    DDLogInfo(@"");
    _retrievingDevice = NO;
    self.discoveredDeviceIndex = 0;
    self.numberOfDiscoveredDevice = 0;
    self.calibrationType = 0;
    self.deviceDetail = nil;
    self.deviceDetail = nil;
    [self.headerIndexes removeAllObjects];
    [self.statisticalDataHeaderEntities removeAllObjects];
    [self.workoutInfoEntities removeAllObjects];
    self.headerIndex = 0;
    self.workoutInfoIndex = 0;
    [self.salutronSDK clearDiscoveredDevice];
    Status s = [self.salutronSDK discoverDevice:DISCOVER_TIMEOUT];
    //[self performSelector:@selector(discoverTimeout) withObject:nil afterDelay:SEARCH_TIMEOUT];
    if(s != NO_ERROR)
        DDLogError(@"discoverDevice error: %@", [ErrorCodeToStringConverter convertToString:s]);
}

- (void)getDataPoints:(StatisticalDataHeaderEntity *) dataHeaderEntity
{
    DDLogInfo(@"");
    self.statisticalDataHeaderEntity = dataHeaderEntity;
    NSUInteger index = [[self.headerIndexes objectAtIndex:self.headerIndex] integerValue];
    Status status = [self.salutronSDK getDataPointsOfSelectedDateStamp:index];
    
    DDLogError(@"getDataPoints: %@", [ErrorCodeToStringConverter convertToString:status]);
    
    if(status != NO_ERROR) {
        //[self performSelector:@selector(getStepGoal) withObject:nil afterDelay:SELECTOR_DELAY];
        [self raiseError];
    }
}

- (void)_getCurrentTimeAndDate
{
    DDLogInfo(@"");
    Status _status = [self.salutronSDK getCurrentTimeAndDate];
    
    if(_status != NO_ERROR) {
        //[self performSelector:@selector(updateDateTime) withObject:nil afterDelay:SELECTOR_DELAY];
        [self raiseError];
    }
}

- (void)updateDateTime
{
    DDLogInfo(@"");
    if(self.isUpdateTimeAndDate) {
        //TimeDate *timeDate = [TimeDate getUpdatedData];
        //TimeDate *timeDateForWatch = self.watchTimeDate;
        TimeDate *timeDateForWatch = [[TimeDate alloc] initWithDate:[NSDate new]];
        //timeDateForWatch.time = timeDate.time;
        //timeDateForWatch.date = timeDate.date;
        timeDateForWatch.hourFormat = self.watchTimeDate.hourFormat;
        timeDateForWatch.dateFormat = self.watchTimeDate.dateFormat;
        timeDateForWatch.watchFace  = self.watchTimeDate.watchFace;
        Status status = [_salutronSDK updateTimeAndDate:timeDateForWatch];
        
        if(status != NO_ERROR) {
            //[self performSelector:@selector(getStatisticalDataHeaders) withObject:nil afterDelay:SELECTOR_DELAY];
            [self raiseError];
        }
    } else {
        //        [self performSelector:@selector(getDataHeaders) withObject:nil afterDelay:SELECTOR_DELAY];
        [Flurry logEvent:DEVICE_START_SYNC timed:YES];
        [Flurry logEvent:DEVICE_GET_DATA_HEADER timed:YES];
        [self performSelector:@selector(getDataHeaders) withObject:nil afterDelay:0];
    }
}

- (void) getUserProfile
{
    Status status = [_salutronSDK getUserProfile];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status != NO_ERROR) {
        [self raiseError];
    }
}

- (void) getStepGoal
{
    Status status = [_salutronSDK getStepGoal];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status != NO_ERROR) {
        //[self performSelector:@selector(getDistanceGoal) withObject:nil afterDelay:SELECTOR_DELAY];
        [self raiseError];
    }
}

- (void) getDistanceGoal
{
    Status status = [_salutronSDK getDistanceGoal];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status != NO_ERROR) {
        //[self performSelector:@selector(getCalorieGoal) withObject:nil afterDelay:SELECTOR_DELAY];
        [self raiseError];
    }
}

- (void) getCalorieGoal
{
    Status status = [_salutronSDK getCalorieGoal];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status != NO_ERROR) {
        [self raiseError];
    }
}

- (void) getNotification
{
    Status status = [self.salutronSDK getNotification];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_DEVICE_NOT_SUPPORTED) {
        [self getSleepSet];
    }
    else if (status != NO_ERROR)
    {
        //[self performSelector:@selector(getSleepSet) withObject:nil afterDelay:SELECTOR_DELAY];
        [self raiseError];
    }
}

- (void) getSleepSet
{
    Status status = [self.salutronSDK getSleepSetting];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_DEVICE_NOT_SUPPORTED)
    {
//        [self performSelector:@selector(getCalibrationData) withObject:nil afterDelay:SELECTOR_DELAY];
        [self getCalibrationData];
    }
    else if(status != NO_ERROR)
    {
        //[self performSelector:@selector(getCalibrationData) withObject:nil afterDelay:SELECTOR_DELAY];
        [self raiseError];
    }
}

- (void) getCalibrationData
{
    //    if (self.calibrationType < 4) {
    DDLogError(@"CALIBRATION TYPE: %i", self.calibrationType);
    Status status = [self.salutronSDK getCalibrationData:self.calibrationType];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    //        self.calibrationType++;
    if(status == ERROR_DEVICE_NOT_SUPPORTED)
    {
//        [self performSelector:@selector(getWorkoutDatabase) withObject:nil afterDelay:SELECTOR_DELAY];
        [self getWorkoutDatabase];
    }
    else if(status != NO_ERROR /*&& self.calibrationType > 3*/)
    {
        //[self performSelector:@selector(getWorkoutDatabase) withObject:nil afterDelay:SELECTOR_DELAY];
        [self raiseError];
    }
    //        else if (status == NO_ERROR && self.calibrationType < 4) {
    //            [self getCalibrationData];
    //        } else if(status != NO_ERROR) {
    //            [self raiseError];
    //        }
    //    }
    //    else {
    //        [self performSelector:@selector(getWorkoutDatabase) withObject:nil afterDelay:SELECTOR_DELAY];
    //    }
}

- (void) getWorkoutDatabase
{
    Status status = [self.salutronSDK  getWorkoutDatabase];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_DEVICE_NOT_SUPPORTED)
    {
//        [self performSelector:@selector(getSleepDatabase) withObject:nil afterDelay:SELECTOR_DELAY];
        [self getSleepDatabase];
        //[self performSelector:@selector(getWorkoutStopDatabaseForWorkoutInfoEntity:) withObject:self.workoutInfoEntity afterDelay:SELECTOR_DELAY];
    }
    else if(status != NO_ERROR)
    {
        //[self performSelector:@selector(getSleepDatabase) withObject:nil afterDelay:SELECTOR_DELAY];
        [self raiseError];
    }
}

- (void)getWorkoutStopDatabaseForWorkoutID:(NSNumber *)workoutID
{
    Status status = [self.salutronSDK getWorkoutStopDatabase:workoutID.integerValue];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if (status == NO_ERROR) {
        if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
            [self.delegate respondsToSelector:@selector(didSyncOnWorkoutStopDatabase)]) {
            [self.delegate didSyncOnWorkoutStopDatabase];
        }
    } else if(status == ERROR_DEVICE_NOT_SUPPORTED) {
//        [self performSelector:@selector(getSleepDatabase) withObject:nil afterDelay:SELECTOR_DELAY];
        [self getSleepDatabase];
    } else if(status != NO_ERROR) {
        [self raiseError];
    }
}

- (void) getSleepDatabase
{
    Status status = [self.salutronSDK  getSleepDatabase];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_DEVICE_NOT_SUPPORTED)
    {
//        [self performSelector:@selector(getWakeup) withObject:nil afterDelay:SELECTOR_DELAY];
        [self getWakeup];
    }
    else if(status != NO_ERROR)
    {
        [self raiseError];
    }
}

- (void)getWakeup
{
    Status status = [self.salutronSDK getWakeup:self.wakeupType];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_DEVICE_NOT_SUPPORTED) {
        //[self performSelector:@selector(getUserProfile) withObject:nil afterDelay:SELECTOR_DELAY];
        
        if(self.isUpdateTimeAndDate) {
//            [self performSelector:@selector(_updateUserProfile) withObject:nil afterDelay:SELECTOR_DELAY];
            [self _updateUserProfile];
        } else {
//            [self performSelector:@selector(getUserProfile) withObject:nil afterDelay:SELECTOR_DELAY];
            [self getUserProfile];
        }
    } else if(status != NO_ERROR) {
        [self raiseError];
    }
}

- (void) getDataHeaders
{
    Status status = [self.salutronSDK getStatisticalDataHeaders];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == WARNING_NOT_CONNECTED) {
        Status status2 = [self.salutronSDK connectDevice:self.discoveredDeviceIndex];
        
        if(status2 != NO_ERROR) {
            DDLogError(@"getStatistxicalDataHeaders error: %@", [ErrorCodeToStringConverter convertToString:status2]);
            [self raiseError];
        }
    } else if(status != NO_ERROR) {
        DDLogError(@"getStatisticalDataHeaders error: %@", [ErrorCodeToStringConverter convertToString:status]);
        [self raiseError];
    }
}

- (void)discoverTimeout
{
    DDLogInfo(@"");
    if (_retrievingDevice)
    {
        [self discoverDevice];
    }
    else
    {
        if(!hasDeviceFound)
            if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)])
                [self.delegate didDiscoverTimeout];
    }
}

- (void)retrieveConnectedDevice
{
    DDLogInfo(@"");
    [self.salutronSDK retrieveConnectedDevice];
    DDLogInfo(@"RETRIEVE CONNECTED DEVICE");
}

- (void)connectAndSetupTimeout
{
    DDLogInfo(@"");
    if(!isDeviceConnected) {
        _deviceRetrieved = YES;
        self.watchModel = [self.userDefaults integerForKey:CONNECTED_WATCH_MODEL];
        [self didConnectAndSetupDeviceWithStatus:0];
    }
}

- (void)didSyncDataPoints:(NSNumber*)percent
{
    DDLogInfo(@"\n---------------> SYNC PERCENT: %@\n", percent);
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnDataPoints:)]) {
        [self.delegate didSyncOnDataPoints:percent.integerValue];
    }
}


/**
 * Methods for restoring settings
 */

- (void)_updateUserProfile
{
    NSData *data = [self.userDefaults objectForKey:USER_PROFILE];
    SalutronUserProfile *userProfile = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    Status status = [self.salutronSDK updateUserProfile:userProfile];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    self.calibrationType = 0;
    self.wakeupType = 0;
    
    if(status != NO_ERROR) {
        [self performSelector:@selector(_updateCalibrationData) withObject:nil afterDelay:SELECTOR_DELAY];
//        [self updateDateTime];
    }
}

- (void)_updateCalibrationData
{
    DDLogInfo(@"");
    static CalibrationData *calibrationData;
    if(self.calibrationType < 5) {
        if(!calibrationData || self.calibrationType == 0) {
            NSData *data = [self.userDefaults objectForKey:CALIBRATION_DATA];
            calibrationData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        if(self.calibrationType == 0 || self.calibrationType == 1 || self.calibrationType == 3) {
            calibrationData.type = self.calibrationType;
            DDLogInfo(@" ------------> CALIBRATION DATA <------------");
            DDLogInfo(@"calibrationData: %@",calibrationData);
            Status _status = [self.salutronSDK updateCalibrationData:calibrationData];
            if(_status != NO_ERROR) {
                self.calibrationType = 0;
                calibrationData = nil;
                [self performSelector:@selector(_updateWakeup) withObject:nil afterDelay:0.75f];
//                [self _updateWakeup];
            }
            self.calibrationType++;
        }else{
            [self performSelector:@selector(_updateCalibrationData) withObject:Nil afterDelay:0.75f];
            self.calibrationType++;
        }
    }else {
        self.calibrationType = 0;
        calibrationData = nil;
        [self performSelector:@selector(_updateWakeup) withObject:nil afterDelay:0.75f];
    }
}

- (void)_updateWakeup
{
    DDLogInfo(@"");
    static WakeupEntity *wakeupEntity;
    static Wakeup *wakeup;
    
    if(!wakeupEntity)
        wakeupEntity = [WakeupEntity getWakeup];
    
    if(!wakeup) {
        wakeup = [[Wakeup alloc] init];
        wakeup.wakeup_mode      = wakeupEntity.wakeupMode.integerValue;
        wakeup.wakeup_hr        = wakeupEntity.wakeupHour.integerValue;
        wakeup.wakeup_min       = wakeupEntity.wakeupMinute.integerValue;
        wakeup.wakeup_window    = wakeupEntity.wakeupWindow.integerValue;
        wakeup.snooze_mode      = wakeupEntity.snoozeMode.integerValue;
        wakeup.snooze_min       = wakeupEntity.snoozeMin.integerValue;
    }
    
    wakeup.type = self.wakeupType;
    
    if(self.wakeupType < 5) {
        wakeup.type = self.wakeupType;
        Status _status = [self.salutronSDK updateWakeup:wakeup];
        self.wakeupType++;
        
        if(_status != NO_ERROR) {
//            [self performSelector:@selector(_updateDistanceGoal) withObject:nil afterDelay:SELECTOR_DELAY];
            [self _updateDistanceGoal];
        }
    }
}

- (void)_updateDistanceGoal
{
    CGFloat distanceGoal = [self.userDefaults floatForKey:DISTANCE_GOAL];
    Status status = [self.salutronSDK updateDistanceGoal:distanceGoal];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status != NO_ERROR) {
//        [self performSelector:@selector(_updateCalorieGoal) withObject:nil afterDelay:SELECTOR_DELAY];
        [self _updateCalorieGoal];
    }
}

- (void)_updateCalorieGoal
{
    NSInteger calorieGoal = [self.userDefaults integerForKey:CALORIE_GOAL];
    Status status = [self.salutronSDK updateCalorieGoal:calorieGoal];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status != NO_ERROR) {
//        [self performSelector:@selector(_updateStepGoal) withObject:nil afterDelay:SELECTOR_DELAY];
        [self _updateStepGoal];
    }
}

- (void)_updateStepGoal
{
    NSInteger stepGoal = [self.userDefaults integerForKey:STEP_GOAL];
    Status status = [self.salutronSDK updateStepGoal:stepGoal];
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status != NO_ERROR) {
        
    }
}

- (void)saveMacAddress
{
    [self.userDefaults setObject:self.macAddress forKey:MAC_ADDRESS];
    [self.userDefaults synchronize];
}

#pragma mark - SalutronSDKDelegate

- (void)didDisconnectDevice:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
        [self.delegate didDeviceDisconnected:self.watchSettingsSyncingDone];
        self.watchSettingsSyncingDone = NO;
    }
}

- (void)didGetBattLevel:(NSString *)battLevelString withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
}

- (void)didGetModelNumber:(ModelNumber *)modelNumber withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@ MODEL NUMBER: %d WATCH MODEL: %d\n", Status_toString[status], modelNumber.number, (NSInteger)self.watchModel);
    
    self.modelNumber = modelNumber;
    
    void (^rediscoverDevice)(void) = ^(void){
        self.discoveredDeviceIndex++;
        
        if(self.discoveredDeviceIndex < self.numberOfDiscoveredDevice) {
            [self.salutronSDK commDone];
            DeviceInfo deviceInfo;
            deviceInfo.index = self.discoveredDeviceIndex;
            deviceInfo.modelName = (char*)[modelNumber.string UTF8String];
            deviceInfo.modelNumber = modelNumber.number;
            
            [self.deviceDetails addObject:[NSValue value:&deviceInfo withObjCType:@encode(DeviceInfo)]];
            [self discoverDevice];
        } else {
            if(([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
                [self.delegate respondsToSelector:@selector(didDiscoverTimeout)]) ||
               ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
                [self.delegate respondsToSelector:@selector(didDiscoverTimeoutWithDiscoveredDevices:)])) {
                   connectedFromRetrievedDevice = NO;
                   [self.salutronSDK commDone];
                   
                   if(self.deviceDetails.count > 0) {
                       [self.delegate didDiscoverTimeoutWithDiscoveredDevices:self.deviceDetails];
                   } else {
                       [self.delegate didDiscoverTimeout];
                   }
               }
        }
    };
    
    NSString *storedMacAddress = [self.userDefaults objectForKey:MAC_ADDRESS];
    
    if ([storedMacAddress rangeOfString:@":"].location != NSNotFound) {
        storedMacAddress = [self convertAndroidToiOSMacAddress:storedMacAddress];
    }
    
    if(modelNumber.number != (NSInteger) self.watchModel) {
        [self disconnectWatch];
        
        if(connectedFromRetrievedDevice) {
            [self discoverDevice];
        } else {
            rediscoverDevice();
        }
    } else if(storedMacAddress != nil &&
              ![self.macAddress isEqualToString:storedMacAddress] &&
              [self.userDefaults boolForKey:HAS_PAIRED]) {
        [self disconnectWatch];
        
        if(connectedFromRetrievedDevice) {
            [self discoverDevice];
        } else {
            rediscoverDevice();
        }
    } else if (storedMacAddress == nil &&
               ![self.userDefaults boolForKey:HAS_PAIRED] &&
               [self isConnectedToWatchWithMacAddress:self.macAddress]) {
        [self disconnectWatch];
        
        if(connectedFromRetrievedDevice) {
            [self discoverDevice];
        } else {
            rediscoverDevice();
        }
    } else {
        [self.userDefaults setObject:[NSNumber numberWithInteger:self.watchModel] forKey:CONNECTED_WATCH_MODEL];
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didDeviceConnected)])
            [self.delegate didDeviceConnected];
        
        if((self.watchModel == WatchModel_R450 || self.watchModel == WatchModel_R500) && !_deviceRetrieved)
            return;
        
        DeviceDetail *deviceDetail = nil;
        Status s = [self.salutronSDK getDeviceDetail:self.discoveredDeviceIndex with:&deviceDetail];
        
        if(s == NO_ERROR) {
            self.deviceDetail = deviceDetail;
            
            //NSString *macAddress = nil;
            NSString *deviceName = [self.deviceDetail.peripheral name];
            
            /*Status s0 = [self.salutronSDK getMacAddress:&macAddress];
             DDLogError(@"macAddress status: %@", [ErrorCodeToStringConverter convertToString:s0]);*/
            
            if(self.macAddress != nil) {
                isDeviceConnected = YES;
                
                if (![self.userDefaults stringForKey:MAC_ADDRESS]) {
                    [self.userDefaults setObject:self.macAddress forKey:MAC_ADDRESS];
                    [self.userDefaults synchronize];
                }
                
                NSUndoManager *undoManager = [[NSUndoManager alloc] init];
                self.managedObjectContext.undoManager = undoManager;
                [undoManager beginUndoGrouping];
                
                if(self.deviceEntity == nil)
                    self.deviceEntity = [self.salutronLibrary deviceEntityWithMacAddress:self.macAddress];
                
                if(self.deviceEntity == nil) {
                    self.deviceEntity = [self.salutronLibrary newDeviceEntityWithUUID:deviceDetail.peripheral.identifier.UUIDString
                                                                                 name:deviceName
                                                                           macAddress:self.macAddress
                                                                    modelNumberString:modelNumber.string
                                                                       modelNumberInt:[NSNumber numberWithInt:modelNumber.number]];
                } else {
                    self.deviceEntity.uuid = deviceDetail.peripheral.identifier.UUIDString;
                }
                
                [[SFAUserDefaultsManager sharedManager] setSignUpDeviceMacAddress:self.deviceEntity.macAddress];
                
                NSError *error = nil;
                
                if([self.salutronLibrary saveChanges:&error]) {
                    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
                       [self.delegate respondsToSelector:@selector(didSyncStarted)])
                        [self.delegate didSyncStarted];
                    
                    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
                       [self.delegate respondsToSelector:@selector(syncStartedWithDeviceEntity:)])
                        [self.delegate syncStartedWithDeviceEntity:self.deviceEntity];
                    
                    if (modelNumber.number == WatchModel_R450 || modelNumber.number == WatchModel_R500)
//                        [self performSelector:@selector(_getCurrentTimeAndDate) withObject:nil afterDelay:5];
                        [self _getCurrentTimeAndDate];
                    else
//                        [self performSelector:@selector(_getCurrentTimeAndDate) withObject:nil afterDelay:SELECTOR_DELAY];
                        [self _getCurrentTimeAndDate];
                } else {
                    DDLogError(@"didConnectAndSetupDeviceWithStatus coredata: %@", [error localizedDescription]);
                }
            } else {
                if (modelNumber.number == WatchModel_R450 || modelNumber.number == WatchModel_R500)
//                    [self performSelector:@selector(_getCurrentTimeAndDate) withObject:nil afterDelay:5];
                    [self _getCurrentTimeAndDate];
                else
//                    [self performSelector:@selector(_getCurrentTimeAndDate) withObject:nil afterDelay:SELECTOR_DELAY];
                    [self _getCurrentTimeAndDate];
            }
        } else {
            DDLogError(@"didConnectAndSetupDeviceWithStatus error: %@", [ErrorCodeToStringConverter convertToString:s]);
        }
    }
}

- (void)didDiscoverDevice:(int)numDevice withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@ NUM DEVICE : %d\n", Status_toString[status], numDevice);
    
    BOOL invalidDevice = NO;
    
    if (numDevice > 0)
    {
        if(status == UPDATE) {
            
            self.numberOfDiscoveredDevice = numDevice;
            
            NSString *deviceUUID = [self.userDefaults stringForKey:DEVICE_UUID];
            
            if (deviceUUID) {
                for (NSInteger a = 0; a < numDevice; a ++) {
                    DeviceDetail *deviceDetail = nil;
                    Status s = [self.salutronSDK getDeviceDetail:a with:&deviceDetail];
                    NSString *deviceId = deviceDetail.deviceID.description;
                    DDLogInfo(@"deviceUUID: %@\ndeviceDetail: %@", deviceUUID, deviceDetail);
                    if ([deviceId isEqual:WatchModel_R450_DeviceId] || ![SFAWatch isDeviceId:deviceId SameWithWatchModel:self.watchModel]){
                        invalidDevice = YES;
                        break;
                    }
                    
                    
                    if (s == NO_ERROR/* &&
                        [deviceUUID isEqualToString:deviceDetail.peripheral.identifier.UUIDString]*/) {
                        self.discoveredDeviceIndex = a;
                        [Flurry logEvent:DEVICE_INITIALIZE_CONNECT timed:YES];
                        s = [self.salutronSDK connectDevice:self.discoveredDeviceIndex];
                        
                        if(s != NO_ERROR) {
                            DDLogError(@"didDiscoverDevice: %@", [ErrorCodeToStringConverter convertToString:s]);
                        }
                        
                        break;
                    } else if (a == numDevice - 1) {
                        [self discoverDevice];
                    }
                }
                if(invalidDevice && [self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
                   [self.delegate respondsToSelector:@selector(didDiscoverTimeout)]){
                    //fix for pairVC not dismissing, delay force timeout
                    [self performSelector:@selector(forceDiscoverDeviceTimeOut) withObject:self afterDelay:0.5f];
                }
            } else {
                for (NSInteger a = 0; a < numDevice; a ++) {
                    DeviceDetail *deviceDetail = nil;
                    Status s = [self.salutronSDK getDeviceDetail:a with:&deviceDetail];
                    NSString *deviceId = deviceDetail.deviceID.description;
                    
                    if ([deviceId isEqual:WatchModel_R450_DeviceId] || ![SFAWatch isDeviceId:deviceId SameWithWatchModel:self.watchModel]){
                        invalidDevice = YES;
                        break;
                    }
                
                    if (s == NO_ERROR/* && ![self isExistingInUserSyncedListWatchWithUUID:deviceDetail.peripheral.identifier.UUIDString]*/) {
                        self.discoveredDeviceIndex = a;
                        s = [self.salutronSDK connectDevice:self.discoveredDeviceIndex];
                        
                        if(s != NO_ERROR) {
                            DDLogError(@"didDiscoverDevice: %@", [ErrorCodeToStringConverter convertToString:s]);
                        }
                        
                        break;
                    } else if (a == numDevice - 1) {
                        [self discoverDevice];
                    }
                }
                if(invalidDevice && [self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
                   [self.delegate respondsToSelector:@selector(didDiscoverTimeout)]){
                    //fix for pairvc not dismissing, delay force timeout
                    [self performSelector:@selector(forceDiscoverDeviceTimeOut) withObject:self afterDelay:0.5f];
                }
                
                
                /*Status s = [self.salutronSDK connectDevice:self.discoveredDeviceIndex];
                 
                 if(s != NO_ERROR) {
                 DDLogError(@"didDiscoverDevice: %@", [ErrorCodeToStringConverter convertToString:s]);
                 }*/
            }
        }
    } else {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didDiscoverTimeout)])
            [self.delegate didDiscoverTimeout];
    }
}

- (void)forceDiscoverDeviceTimeOut
{
    [self didDiscoverDevice:0 withStatus:NO_ERROR];
}

- (void)didConnectAndSetupDeviceWithStatus:(Status)status
{
    [Flurry endTimedEvent:DEVICE_INITIALIZE_CONNECT withParameters:nil];
    [Flurry logEvent:DEVICE_CONNECTED];
    NSString *macAddress = nil;
    Status s0 = [self.salutronSDK getMacAddress:&macAddress];
    DDLogInfo(@"\n---------------> STATUS: %@ ---> MAC ADDRESS : %@ ---> MAC ADDRESS STATUS : %@\n", Status_toString[status], macAddress, [ErrorCodeToStringConverter convertToString:s0]);
    
    self.macAddress = macAddress.copy;
    
    if (![self.userDefaults stringForKey:MAC_ADDRESS])
        [self saveMacAddress];
    
    DDLogError(@"didConnectAndSetupDeviceWithStatus status: %@", [ErrorCodeToStringConverter convertToString:s0]);
    
    NSString *firmwareRevision = @"";
    Status _status = [self.salutronSDK getFirmwareRevision:&firmwareRevision];
    
    if (_status == NO_ERROR) {
        [[NSUserDefaults standardUserDefaults] setObject:firmwareRevision forKey:FIRMWARE_REVISION];
    }
    
    NSString *softwareRevision = @"";
    _status = [self.salutronSDK getSoftwareRevision:&softwareRevision];
    
    if (_status == NO_ERROR) {
        [[NSUserDefaults standardUserDefaults] setObject:softwareRevision forKey:SOFTWARE_REVISION];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];

    if(self.macAddress != nil && status == NO_ERROR) {
        _deviceRetrieved = YES;
        Status modelNumber = [self.salutronSDK getModelNumber];
        DDLogError(@"getModelNumber: %@", [ErrorCodeToStringConverter convertToString:modelNumber]);
    }
}

- (void)didRetrieveConnectedDevice:(int)numDevice withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    _retrievingDevice = NO;
    DeviceDetail *deviceDetail = nil;
    [self.salutronSDK getDeviceDetail:0 with:&deviceDetail];
    
    if(numDevice > 0 && deviceDetail.deviceID) {
        
        _deviceRetrieved = YES;
        
        NSInteger numDeviceDiscovered = 0;
        Status s1 = [self.salutronSDK getNumDiscoveredDevice:&numDeviceDiscovered];
        DDLogError(@"getNumDiscoveredDevice status: %@", [ErrorCodeToStringConverter convertToString:s1]);
        self.numberOfDiscoveredDevice = numDeviceDiscovered;
        
        NSString *macAddress = nil;
        Status s2 = [self.salutronSDK getMacAddress:&macAddress];
        //DDLogError(@"macAddress status: %@", [ErrorCodeToStringConverter convertToString:s2]);
        DDLogInfo(@"\n---------------> STATUS: %@ ---> MAC ADDRESS : %@ ---> MAC ADDRESS STATUS : %@\n", Status_toString[status], macAddress, [ErrorCodeToStringConverter convertToString:s2]);
        
        
        if(macAddress == nil) {
            Status _status = [_salutronSDK connectDevice:0];
            
            if (_status != NO_ERROR)
            {
                [self didConnectAndSetupDeviceWithStatus:0];
            } else {
                connectedFromRetrievedDevice = YES;
            }
        } else {
            [self didConnectAndSetupDeviceWithStatus:0];
        }
        isDeviceConnected = NO;
        //[self performSelector:@selector(connectAndSetupTimeout) withObject:nil afterDelay:5];
    } else {
        [self discoverDevice];
        //[self performSelector:@selector(discoverTimeout) withObject:nil afterDelay:SEARCH_TIMEOUT];
    }
    
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didRetrieveDevice:)]) {
        [self.delegate didRetrieveDevice:numDevice];
    }
}

- (void)didGetStatisticalDataHeaders:(NSArray *)statisticalDataHeaders withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    static NSUInteger dataHeaderRetryCount;
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        if(dataHeaderRetryCount < 1) {
//            [self performSelector:@selector(getDataHeaders) withObject:nil afterDelay:SELECTOR_DELAY];
            [self getDataHeaders];
            return;
        } else {
            if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
               [self.delegate respondsToSelector:@selector(didChecksumError)]) {
                dataHeaderRetryCount = 0;
                [self.delegate didChecksumError];
                return;
            }
        }
    }
    
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    self.managedObjectContext.undoManager = undoManager;
    [undoManager beginUndoGrouping];
    
    NSUInteger index = 0;
    
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnDataHeaders)]) {
        [self.delegate didSyncOnDataHeaders];
    }
    
    for(StatisticalDataHeader *statisticalDataHeader in statisticalDataHeaders)
    {
        DDLogInfo(@" statistical data header!: %@",statisticalDataHeader);
        StatisticalDataHeaderEntity *statisticalDataHeaderEntity = nil;
        
        if(![self.salutronLibrary isStatisticalDataHeaderExists:statisticalDataHeader entity:&statisticalDataHeaderEntity])
        {
            statisticalDataHeaderEntity = [StatisticalDataHeaderEntity
                                           statisticalForInsertDataHeader:statisticalDataHeader
                                           inManagedObjectContext:self.managedObjectContext];
            [self.deviceEntity addHeaderObject:statisticalDataHeaderEntity];
            [self.statisticalDataHeaderEntities addObject:statisticalDataHeaderEntity];
            [self.headerIndexes addObject:[NSNumber numberWithInt:index]];
        } else {
            if([statisticalDataHeaderEntity.dataPoint count] < 144) {
                if(!self.isUpdateTimeAndDate) {
                    [StatisticalDataHeaderEntity updateEntityWithStatisticalDataHeader:statisticalDataHeader
                                                                                entity:statisticalDataHeaderEntity
                                                                inManagedObjectContext:self.managedObjectContext];
                }
                
                [self.statisticalDataHeaderEntities addObject:statisticalDataHeaderEntity];
                [self.headerIndexes addObject:[NSNumber numberWithInt:index]];
            }
        }
        
        index++;
    }
    
    DDLogError(@"statistical data header: %@", [self.statisticalDataHeaderEntities lastObject]);
    
    NSError *error = nil;
    
    if(self.headerIndexes.count > 0) {
        if([self.salutronLibrary saveChanges:&error]) {
            if(self.statisticalDataHeaderEntities.count > 0) {
                self.headerIndex = 0;
                //                index = [[self.headerIndexes objectAtIndex:self.headerIndex] integerValue];
                [self.retrievedDataHeadersForCurrentSync removeAllObjects];
                [Flurry endTimedEvent:DEVICE_GET_DATA_HEADER withParameters:nil];
                [Flurry logEvent:DEVICE_GET_DATA_POINTS timed:YES];
                [self performSelector:@selector(getDataPoints:)
                           withObject:[self.statisticalDataHeaderEntities objectAtIndex:self.headerIndex]
                           afterDelay:SELECTOR_DELAY];
                [self performSelector:@selector(didSyncDataPoints:) withObject:[NSNumber numberWithInt:0]];
            }
        } else {
            DDLogError(@"didGetStatisticalDataHeaders: %@", [error localizedDescription]);
        }
    } else {
        [self performSelector:@selector(getStepGoal) withObject:nil afterDelay:SELECTOR_DELAY];
    }
}

- (void) didGetDataPointsOfSelectedDateStamp:(NSArray *)dataPoints withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    DDLogInfo(@"DataPoints = %@", dataPoints);
    
    static NSUInteger dataPointRetryCount;
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        if(dataPointRetryCount < 3) {
            dataPointRetryCount++;
            [self performSelector:@selector(getDataPoints:)
                       withObject:[self.statisticalDataHeaderEntities
                                   objectAtIndex:self.headerIndex] afterDelay:SELECTOR_DELAY];
            return;
        } else {
            if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
               [self.delegate respondsToSelector:@selector(didChecksumError)]) {
                dataPointRetryCount = 0;
                [self.delegate didChecksumError];
                return;
            }
        }
    }
    
    /*static NSThread *thread;
     
     if(thread) {
     [thread cancel];
     thread = nil;
     }*/
    
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    self.managedObjectContext.undoManager = undoManager;
    [undoManager beginUndoGrouping];
    
    NSMutableArray *dataPointEntities = [[NSMutableArray alloc] init];
    
    CGFloat dpTotalCalories = 0.0f;
    NSString *savedMacAddress = [SFAUserDefaultsManager sharedManager].macAddress;
   
    //If account is created on Android
    if ([savedMacAddress rangeOfString:@":"].location != NSNotFound) {
        for(StatisticalDataPoint *dataPoint in dataPoints) {
            DDLogError(@"index of datapoint = %i", [dataPoints indexOfObject:dataPoint]+1);
            DDLogInfo(@"index of datapoint = %i", [dataPoints indexOfObject:dataPoint]+1);
            DDLogInfo(@"headerEntity.dataPoint.count = %i", self.statisticalDataHeaderEntity.dataPoint.count);
            
            if([dataPoints indexOfObject:dataPoint]+1 > self.statisticalDataHeaderEntity.dataPoint.count) {
                StatisticalDataPointEntity *statisticalDataPointEntity = nil;
                statisticalDataPointEntity = [StatisticalDataPointEntity
                                              statisticalForInsertDataPoint:dataPoint
                                              index:[dataPoints indexOfObject:dataPoint]+1
                                              inManagedObjectContext:_managedObjectContext];
                [dataPointEntities addObject:statisticalDataPointEntity];
            } else if ([dataPoints indexOfObject:dataPoint]+1 == self.statisticalDataHeaderEntity.dataPoint.count || [dataPoints indexOfObject:dataPoint]+1 == self.statisticalDataHeaderEntity.dataPoint.count-1) {
                for (StatisticalDataPointEntity *dataPointEntity in self.statisticalDataHeaderEntity.dataPoint) {
                    if (dataPointEntity.dataPointID.integerValue == [dataPoints indexOfObject:dataPoint]+1) {
                        
                        
                        [StatisticalDataPointEntity dataPointEntityWithDataPoint:dataPoint
                                                                 dataPointEntity:dataPointEntity];
                    }
                }
            }
            
            dpTotalCalories += dataPoint.calorie;
        }
    }
    else{
        for(StatisticalDataPoint *dataPoint in dataPoints) {
            DDLogError(@"index of datapoint = %i", [dataPoints indexOfObject:dataPoint]);
            
            if([dataPoints indexOfObject:dataPoint] >= self.statisticalDataHeaderEntity.dataPoint.count) {
                StatisticalDataPointEntity *statisticalDataPointEntity = nil;
                statisticalDataPointEntity = [StatisticalDataPointEntity
                                              statisticalForInsertDataPoint:dataPoint
                                              index:[dataPoints indexOfObject:dataPoint]
                                              inManagedObjectContext:_managedObjectContext];
                [dataPointEntities addObject:statisticalDataPointEntity];
            } else if ([dataPoints indexOfObject:dataPoint] == self.statisticalDataHeaderEntity.dataPoint.count - 1) {
                for (StatisticalDataPointEntity *dataPointEntity in self.statisticalDataHeaderEntity.dataPoint) {
                    if (dataPointEntity.dataPointID.integerValue == [dataPoints indexOfObject:dataPoint]) {
                        
                        
                        [StatisticalDataPointEntity dataPointEntityWithDataPoint:dataPoint
                                                                 dataPointEntity:dataPointEntity];
                    }
                }
            }
            
            dpTotalCalories += dataPoint.calorie;
        }
    }
    
    
    DDLogError(@"data point calories %f = %f total calories", dpTotalCalories, self.statisticalDataHeaderEntity.totalCalorie.floatValue);
    
    [self.statisticalDataHeaderEntity addDataPoint:[NSSet setWithArray:dataPointEntities.copy]];
    [self.retrievedDataHeadersForCurrentSync addObject:self.statisticalDataHeaderEntity];

    NSError *error = nil;
    
    if([self.salutronLibrary saveChanges:&error]) {
        CGFloat percent = ((CGFloat)self.headerIndex / (CGFloat) self.statisticalDataHeaderEntities.count) * 100;
        /*thread = [[NSThread alloc] initWithTarget:self
         selector:@selector(didSyncDataPoints:)
         object:[NSNumber numberWithInteger:percent]];
         [thread start];*/
        
        [self performSelector:@selector(didSyncDataPoints:) withObject:[NSNumber numberWithInteger:percent]];
        
        self.headerIndex++;
        
        DDLogError(@"header index: %i", self.headerIndex);
        
        if(self.headerIndex < [self.headerIndexes count]) {
            [self performSelector:@selector(getDataPoints:)
                       withObject:[self.statisticalDataHeaderEntities
                                   objectAtIndex:self.headerIndex] afterDelay:0];
        } else {
            [self.statisticalDataHeaderEntities removeAllObjects];
            [self.headerIndexes removeAllObjects];
            
            if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
               [self.delegate respondsToSelector:@selector(didSyncOnStepGoal)]) {
                [self.delegate didSyncOnStepGoal];
            }
            
            [Flurry endTimedEvent:DEVICE_GET_DATA_POINTS withParameters:nil];
            [Flurry logEvent:DEVICE_GET_STEP_GOAL timed:YES];
            [self performSelector:@selector(getStepGoal) withObject:nil afterDelay:SELECTOR_DELAY];
        }
    } else {
        DDLogError(@"didGetDataPointsOfSelectedDateStamp error: %@", [error localizedDescription]);
    }
}

- (void)didGetStepGoal:(int)stepGoal withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didChecksumError)]) {
            [self.delegate didChecksumError];
            return;
        }
    }
    
    self.stepGoal = stepGoal;
    
    //[self.userDefaults setInteger:stepGoal forKey:STEP_GOAL];
    //[self.userDefaults synchronize];
    
    /*[SFAGoalsData addGoalsWithSteps:stepGoal
     distance:0
     calories:0
     sleep:0
     device:self.deviceEntity
     managedObject:self.managedObjectContext];*/
    
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnDistanceGoal)]) {
        [self.delegate didSyncOnDistanceGoal];
    }
    
    [Flurry endTimedEvent:DEVICE_GET_STEP_GOAL withParameters:nil];
    [Flurry logEvent:DEVICE_GET_DISTANCE_GOAL timed:YES];
    [self performSelector:@selector(getDistanceGoal) withObject:nil afterDelay:SELECTOR_DELAY];
}

- (void)didGetDistanceGoal:(double)distanceGoal withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didChecksumError)]) {
            [self.delegate didChecksumError];
            return;
        }
    }
    
    self.distanceGoal = distanceGoal;
    if (self.distanceGoal < 0) {
        self.distanceGoal = 3.2;
    }
    
    //[self.userDefaults setDouble:distanceGoal forKey:DISTANCE_GOAL];
    //[self.userDefaults synchronize];
    
    /*NSInteger steps = [_userDefaults integerForKey:STEP_GOAL];
     [SFAGoalsData addGoalsWithSteps:steps
     distance:distanceGoal
     calories:0
     sleep:0
     device:self.deviceEntity
     managedObject:self.managedObjectContext];*/
    
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnCalorieGoal)]) {
        [self.delegate didSyncOnCalorieGoal];
    }
    [Flurry endTimedEvent:DEVICE_GET_STEP_GOAL withParameters:nil];
    [Flurry logEvent:DEVICE_GET_CALORIES_GOAL timed:YES];
    [self performSelector:@selector(getCalorieGoal) withObject:nil afterDelay:SELECTOR_DELAY];
}

- (void)didGetCalorieGoal:(int)calorieGoal withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didChecksumError)]) {
            [self.delegate didChecksumError];
            return;
        }
    }
    
    self.calorieGoal = calorieGoal;
    
    //[self.userDefaults setInteger:calorieGoal forKey:CALORIE_GOAL];
    //[self.userDefaults synchronize];
    
    /*NSInteger steps = [_userDefaults integerForKey:STEP_GOAL];
     CGFloat distance = [_userDefaults floatForKey:DISTANCE_GOAL];
     [SFAGoalsData addGoalsWithSteps:steps
     distance:distance
     calories:calorieGoal
     sleep:0
     device:self.deviceEntity
     managedObject:self.managedObjectContext];*/
    /*
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnNotification)]) {
        [self.delegate didSyncOnNotification];
    }
    [Flurry endTimedEvent:DEVICE_GET_CALORIES_GOAL withParameters:nil];
    [Flurry logEvent:DEVICE_GET_NOTIFICATION timed:YES];
    [self performSelector:@selector(getNotification) withObject:nil afterDelay:SELECTOR_DELAY];*/
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnSleepSettings)]) {
        [self.delegate didSyncOnSleepSettings];
    }
    //[Flurry endTimedEvent:DEVICE_GET_NOTIFICATION withParameters:nil];
    [Flurry logEvent:DEVICE_GET_SLEEP_SETTING timed:YES];
    [self performSelector:@selector(getSleepSet) withObject:nil afterDelay:SELECTOR_DELAY];
}

- (void)didGetNotification:(Notification *)notify withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didChecksumError)]) {
            [self.delegate didChecksumError];
            return;
        }
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:notify];
    [self.userDefaults setObject:data forKey:NOTIFICATION];
    [self.userDefaults synchronize];
    
    [NotificationEntity notificationWithNotification:notify notificationStatus:[SFAUserDefaultsManager sharedManager].notificationStatus forDeviceEntity:self.deviceEntity];
    
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnSleepSettings)]) {
        [self.delegate didSyncOnSleepSettings];
    }
    [Flurry endTimedEvent:DEVICE_GET_NOTIFICATION withParameters:nil];
    [Flurry logEvent:DEVICE_GET_SLEEP_SETTING timed:YES];
    [self performSelector:@selector(getSleepSet) withObject:nil afterDelay:SELECTOR_DELAY];
}

- (void)didGetSleepSetting:(SleepSetting *)sleepSetting withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didChecksumError)]) {
            [self.delegate didChecksumError];
            return;
        }
    }
    
    self.sleepSetting = sleepSetting;
    
    /*NSData *data = [NSKeyedArchiver archivedDataWithRootObject:sleepSetting];
     [self.userDefaults setObject:data forKey:SLEEP_SETTING];
     
     NSInteger steps = [_userDefaults integerForKey:STEP_GOAL];
     CGFloat distance = [_userDefaults floatForKey:DISTANCE_GOAL];
     NSInteger calorie = [_userDefaults integerForKey:CALORIE_GOAL];
     
     NSInteger sleepGoal = sleepSetting.sleep_goal_lo;
     sleepGoal           += sleepSetting.sleep_goal_hi << 8;
     
     [self.userDefaults setInteger:sleepGoal forKey:SLEEP_GOAL];
     [self.userDefaults synchronize];
     
     [SFAGoalsData addGoalsWithSteps:steps
     distance:distance
     calories:calorie
     sleep:sleepGoal
     device:self.deviceEntity
     managedObject:_managedObjectContext];*/
    
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnCalibrationData)]) {
        [self.delegate didSyncOnCalibrationData];
    }
    [Flurry endTimedEvent:DEVICE_GET_SLEEP_SETTING withParameters:nil];
    [Flurry logEvent:DEVICE_GET_CALIBRATION_DATA timed:YES];
    [self performSelector:@selector(getCalibrationData) withObject:nil afterDelay:SELECTOR_DELAY];
}

- (void)didGetCalibrationData:(CalibrationData *)calibrationData withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    static CalibrationData *calibData;
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didChecksumError)]) {
            [self.delegate didChecksumError];
            return;
        }
    }
    
    if(!calibData)
        calibData = [[CalibrationData alloc] init];
    
    switch (self.calibrationType) {
        case 0:
            calibData.calib_step = calibrationData.calib_step;
            break;
        case 1:
            calibData.calib_walk = calibrationData.calib_walk;
            break;
        case 3:
            calibData.autoEL = calibrationData.autoEL;
            break;
        default:
            break;
    }
    
    if (!_watchCalibrationData){
        _watchCalibrationData = [[NSMutableArray alloc] init];
    }
    
    if (calibData){
        [_watchCalibrationData addObject:calibData];
    }

    if (self.calibrationType < 4) {
        self.calibrationType++;
        [self performSelector:@selector(getCalibrationData) withObject:nil afterDelay:SELECTOR_DELAY];
    }
    else {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didSyncOnWorkoutDatabase)]) {
            [self.delegate didSyncOnWorkoutDatabase];
        }
        self.calibrationType = 0;
        [Flurry endTimedEvent:DEVICE_GET_CALIBRATION_DATA withParameters:nil];
        [Flurry logEvent:DEVICE_GET_WORKOUT timed:YES];
        [self performSelector:@selector(getWorkoutDatabase) withObject:nil afterDelay:SELECTOR_DELAY];
    }
}

- (void)didGetWorkoutDatabase:(NSArray *)workoutDatabase withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didChecksumError)]) {
            [self.delegate didChecksumError];
            return;
        }
    }
    
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    self.managedObjectContext.undoManager = undoManager;
    [undoManager beginUndoGrouping];
    
    NSMutableArray *workoutInfoEntities = [[NSMutableArray alloc] init];
    
    for (WorkoutInfo *_workoutInfo in workoutDatabase)
    {
        DDLogError(@"%@", _workoutInfo);
        
        WorkoutInfoEntity *workoutInfoEntity = [WorkoutInfoEntity
                                                insertWorkoutInfoWithSteps:[NSNumber numberWithLong:_workoutInfo.steps]
                                                distance:[NSNumber numberWithDouble:_workoutInfo.distance]
                                                calories:[NSNumber numberWithDouble:_workoutInfo.calories]
                                                minute:[NSNumber numberWithInteger:_workoutInfo.minute]
                                                second:[NSNumber numberWithInteger:_workoutInfo.second]
                                                hour:[NSNumber numberWithInteger:_workoutInfo.hour]
                                                distanceUnitFlag:[NSNumber numberWithBool:_workoutInfo.distance_unit_flag]
                                                hundredth:[NSNumber numberWithInteger:_workoutInfo.hundredths]
                                                stampSecond:[NSNumber numberWithInteger:_workoutInfo.stamp_second]
                                                stampMinute:[NSNumber numberWithInteger:_workoutInfo.stamp_minute]
                                                stampHour:[NSNumber numberWithInteger:_workoutInfo.stamp_hour]
                                                stampDay:[NSNumber numberWithInteger:_workoutInfo.stamp_day]
                                                stampMonth:[NSNumber numberWithInteger:_workoutInfo.stamp_month]
                                                stampYear:[NSNumber numberWithInteger:_workoutInfo.stamp_year + DATE_YEAR_ADDER]
                                                workoutID:[NSNumber numberWithInteger:_workoutInfo.workoutID]];
        [workoutInfoEntities addObject:workoutInfoEntity];
    }
    
    [self.deviceEntity addWorkout:[NSSet setWithArray:workoutInfoEntities]];
    
    self.workoutInfoEntities = workoutInfoEntities;
    
    NSError *error = nil;
    
    if([self.salutronLibrary saveChanges:&error]) {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didSyncOnWorkoutStopDatabase)]) {
            [self.delegate didSyncOnWorkoutStopDatabase];
        }
        
        // Check if there are WorkoutInfoEntities
        /*
        if (self.workoutInfoEntities.count > 0 &&
            self.workoutInfoIndex < self.workoutInfoEntities.count) {
            // Proceed to WorkoutStopDatabase Sync
            WorkoutInfoEntity *workoutInfoEntity = self.workoutInfoEntities[self.workoutInfoIndex];
            
            [Flurry endTimedEvent:DEVICE_GET_WORKOUT withParameters:nil];
            [Flurry logEvent:DEVICE_GET_WORKOUT_STOP timed:YES];
            [self performSelector:@selector(getWorkoutStopDatabaseForWorkoutID:)
                       withObject:workoutInfoEntity.workoutID
                       afterDelay:SELECTOR_DELAY];
        } else {*/
            // Proceed to SleepDatabase Sync
            if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
               [self.delegate respondsToSelector:@selector(didSyncOnSleepDatabase)]) {
                [self.delegate didSyncOnSleepDatabase];
            }
            
            [Flurry endTimedEvent:DEVICE_GET_WORKOUT withParameters:nil];
            [Flurry logEvent:DEVICE_GET_SLEEP_DATABASE timed:YES];
            [self performSelector:@selector(getSleepDatabase) withObject:nil afterDelay:SELECTOR_DELAY];
        //}
        
        /*if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
         [self.delegate respondsToSelector:@selector(didSyncOnSleepDatabase)]) {
         [self.delegate didSyncOnSleepDatabase];
         }
         
         [self performSelector:@selector(getSleepDatabase) withObject:nil afterDelay:SELECTOR_DELAY];*/
    }
}

- (void)didGetWorkoutStopDatabase:(NSArray *)workoutstopdatabase withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didChecksumError)]) {
            [self.delegate didChecksumError];
            return;
        }
    }
    
    self.managedObjectContext.undoManager = [NSUndoManager new];
    [self.managedObjectContext.undoManager beginUndoGrouping];
    
    for (WorkoutStopDatabase *workoutStop in workoutstopdatabase) {
        // Convert WorkoutStopDatabase to WorkoutStopDatabaseEntity and
        // Insert it to workoutStopDatabase of workoutInfoEntity
        
        NSInteger index = [workoutstopdatabase indexOfObject:workoutStop];
        
        [WorkoutStopDatabaseEntity workoutStopDatabaseEntityWithWorkoutStopDatabase:workoutStop
                                                           workoutStopDatabaseIndex:index
                                                                  workoutInfoEntity:self.workoutInfoEntities[self.workoutInfoIndex]
                                                               managedObjectContext:self.managedObjectContext];
    }
    
    [self.managedObjectContext.undoManager endUndoGrouping];
    
    NSError *error = nil;
    
    if ([self.managedObjectContext save:&error]) {
        // Check if workoutInfoIndex + 1 is less than workoutInfoEntities count
        /*if (++ self.workoutInfoIndex < self.workoutInfoEntities.count) {
            // Get WorkoutStopDatabase for the workoutInfoEntity
            WorkoutInfoEntity *workoutInfoEntity = self.workoutInfoEntities[self.workoutInfoIndex];
            
            [self performSelector:@selector(getWorkoutStopDatabaseForWorkoutID:)
                       withObject:workoutInfoEntity.workoutID
                       afterDelay:SELECTOR_DELAY];
        } else {*/
            // Proceed to SleepDatabase Sync
            if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
               [self.delegate respondsToSelector:@selector(didSyncOnSleepDatabase)]) {
                [self.delegate didSyncOnSleepDatabase];
            }
            
            [Flurry endTimedEvent:DEVICE_GET_WORKOUT_STOP withParameters:nil];
            [Flurry logEvent:DEVICE_GET_SLEEP_DATABASE timed:YES];
            [self performSelector:@selector(getSleepDatabase) withObject:nil afterDelay:SELECTOR_DELAY];
       // }
    } else {
        DDLogError(@"Save Workout Stop Database Entity Error: %@", error.localizedDescription);
        
        [self.managedObjectContext undo];
    }
}

- (void)didGetSleepDatabase:(NSArray *)sleepdatabases withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didChecksumError)]) {
            [self.delegate didChecksumError];
            return;
        }
    }
    
    NSMutableArray *sleepDatabases = [[NSMutableArray alloc] init];
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    self.managedObjectContext.undoManager = undoManager;
    [undoManager beginUndoGrouping];
    
    for(SleepDatabase *sleepDatabase in sleepdatabases) {
        SleepDatabaseEntity *sleepDatabaseEntity = [SleepDatabaseEntity sleepDatabaseEntityWithRecord:sleepDatabase
                                                                                        managedObject:self.managedObjectContext];
        [sleepDatabases addObject:sleepDatabaseEntity];
    }
    
    [self.deviceEntity addSleepdatabase:[NSSet setWithArray:sleepDatabases]];
    
    NSError *error = nil;
    
    if([self.salutronLibrary saveChanges:&error]) {
        
        [Flurry endTimedEvent:DEVICE_GET_SLEEP_DATABASE withParameters:nil];
        if(self.isUpdateTimeAndDate) {
            [self performSelector:@selector(_updateUserProfile) withObject:nil afterDelay:SELECTOR_DELAY];//+1.25];
        } else {
            [Flurry endTimedEvent:DEVICE_GET_WAKEUP_SETTING withParameters:nil];
            [Flurry logEvent:DEVICE_GET_USER_PROFILE timed:YES];
            [self performSelector:@selector(getUserProfile) withObject:nil afterDelay:SELECTOR_DELAY];
        }
        /*
        [Flurry logEvent:DEVICE_GET_WAKEUP_SETTING timed:YES];
        [self performSelector:@selector(getWakeup) withObject:nil afterDelay:SELECTOR_DELAY];
         */
    }
}

- (void)didGetWakeup:(Wakeup *)wakeup withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(self.wakeupType < 5) {
        WakeupEntity *wakeupEntity = nil;
        
        switch (self.wakeupType) {
            case 0: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.macAddress
                                             wakeupMode:@(wakeup.wakeup_mode)
                                             wakeupHour:@0
                                           wakeupMinute:@0
                                           wakeupWindow:@0
                                             snoozeMode:@0
                                              snoozeMin:@0
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&wakeupEntity];
                self.wakeupEntity = wakeupEntity;
                break;
            }
            case 1: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.macAddress
                                             wakeupMode:self.wakeupEntity.wakeupMode
                                             wakeupHour:@(wakeup.wakeup_hr)
                                           wakeupMinute:@(wakeup.wakeup_min)
                                           wakeupWindow:@0
                                             snoozeMode:@0
                                              snoozeMin:@0
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&wakeupEntity];
                self.wakeupEntity = wakeupEntity;
                break;
            }
            case 2: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.macAddress
                                             wakeupMode:self.wakeupEntity.wakeupMode
                                             wakeupHour:self.wakeupEntity.wakeupHour
                                           wakeupMinute:self.wakeupEntity.wakeupMinute
                                           wakeupWindow:@(wakeup.wakeup_window)
                                             snoozeMode:@0
                                              snoozeMin:@0
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&wakeupEntity];
                self.wakeupEntity = wakeupEntity;
                break;
            }
            case 3: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.macAddress
                                             wakeupMode:self.wakeupEntity.wakeupMode
                                             wakeupHour:self.wakeupEntity.wakeupHour
                                           wakeupMinute:self.wakeupEntity.wakeupMinute
                                           wakeupWindow:self.wakeupEntity.wakeupWindow
                                             snoozeMode:@(wakeup.snooze_mode)
                                              snoozeMin:@0
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&wakeupEntity];
                self.wakeupEntity = wakeupEntity;
                break;
            }
            case 4: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.macAddress
                                             wakeupMode:self.wakeupEntity.wakeupMode
                                             wakeupHour:self.wakeupEntity.wakeupHour
                                           wakeupMinute:self.wakeupEntity.wakeupMinute
                                           wakeupWindow:self.wakeupEntity.wakeupWindow
                                             snoozeMode:self.wakeupEntity.snoozeMode
                                              snoozeMin:@(wakeup.snooze_min)
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&wakeupEntity];
                self.wakeupEntity = wakeupEntity;
                break;
            }
            default:
                break;
        }
        self.wakeupType++;
        [self performSelector:@selector(getWakeup) withObject:nil afterDelay:SELECTOR_DELAY];
    } else {
        //[self performSelector:@selector(getUserProfile) withObject:nil afterDelay:SELECTOR_DELAY];
        if(self.isUpdateTimeAndDate) {
            [self performSelector:@selector(_updateUserProfile) withObject:nil afterDelay:SELECTOR_DELAY];//+1.25];
        } else {
            [Flurry endTimedEvent:DEVICE_GET_WAKEUP_SETTING withParameters:nil];
            [Flurry logEvent:DEVICE_GET_USER_PROFILE timed:YES];
            [self performSelector:@selector(getUserProfile) withObject:nil afterDelay:SELECTOR_DELAY];
        }
    }
}

- (void)didGetCurrentTimeAndDate:(TimeDate *)timeDate withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    NSData *data = [self.userDefaults objectForKey:TIME_DATE];
    
    if (data) {
        TimeDate *savedTimeDate = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.appTimeDate        = savedTimeDate;
        self.watchTimeDate      = timeDate;
        
        if ([self.userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]) {
            self.watchTimeDate      = timeDate;
            
            if(savedTimeDate == nil ||
               savedTimeDate.hourFormat != timeDate.hourFormat ||
               savedTimeDate.dateFormat != timeDate.dateFormat) {
                
                // Alert Here.
                // saveUserProfile();
                
                self.timeDateChanged = YES;
            }
        } else {
            [self.userDefaults setObject:data forKey:TIME_DATE];
            [self.userDefaults synchronize];
        }
    } else {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:timeDate];
        [self.userDefaults setObject:data forKey:TIME_DATE];
        [self.userDefaults synchronize];
    }
    
    [self performSelector:@selector(updateDateTime) withObject:nil afterDelay:SELECTOR_DELAY];
    
    
    //if((timeDate.date.day == 1 && timeDate.date.month == 1 && timeDate.date.year == 113) ||
    //   (timeDate.date.day == 1 && timeDate.date.month == 1 && timeDate.date.year == 114)) {
    //    self.updateTimeAndDate = YES;
    //    [self performSelector:@selector(updateDateTime) withObject:nil afterDelay:SELECTOR_DELAY];
    //} else {
    //    [self performSelector:@selector(getDataHeaders) withObject:nil afterDelay:2];
    //}
}

- (void)didUpdateTimeAndDateWithStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    self.updateTimeAndDate = NO;
    
    if (self.watchSettingsSelected) {
        //self.watchSettingsSyncingDone = YES;
        //[self disconnectWatch];
        //self.watchSettingsSelected = NO;
        [_salutronSDK performSelectorOnMainThread:@selector(updateUserProfile:) withObject:self.watchUserProfile waitUntilDone:NO];
    }
    else {
        [Flurry logEvent:DEVICE_START_SYNC];
        [Flurry logEvent:DEVICE_GET_DATA_HEADER timed:YES];
        [self performSelector:@selector(getDataHeaders) withObject:nil afterDelay:3.0];
    }
}

- (void)didGetUserProfile:(SalutronUserProfile *)userProfile withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didChecksumError)]) {
            [self.delegate didChecksumError];
            return;
        }
    }
    
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnUserProfile)]) {
        [self.delegate didSyncOnUserProfile];
    }
    
    NSData *data = [self.userDefaults objectForKey:USER_PROFILE];
    BOOL profileUpdated = NO;
    
    void (^saveUserProfile)(void) = ^(void){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userProfile];
        [self.userDefaults setObject:data forKey:USER_PROFILE];
        [self.userDefaults synchronize];
    };
    
    if (data) {
        if ([self.userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]) {
            
            SalutronUserProfile *savedProfile   = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            self.watchUserProfile               = userProfile;
            self.appUserProfile                 = savedProfile;
            NSData *sleepSettingData            = [self.userDefaults objectForKey:SLEEP_SETTING];
            NSInteger savedCalorieGoal          = [self.userDefaults integerForKey:CALORIE_GOAL];
            NSInteger savedStepGoal             = [self.userDefaults integerForKey:STEP_GOAL];
            CGFloat savedDistanceGoal           = [self.userDefaults floatForKey:DISTANCE_GOAL];
            SleepSetting *savedSleepSetting     = [NSKeyedUnarchiver unarchiveObjectWithData:sleepSettingData];
            
            CGFloat roundedSavedDistanceGoal    = [[NSString stringWithFormat:@"%.1f",savedDistanceGoal] doubleValue];//floorf(savedDistanceGoal * 100 + 0.5) / 100;
            CGFloat roundedDistanceGoal         = [[NSString stringWithFormat:@"%.1f",self.distanceGoal] doubleValue];//floorf(self.distanceGoal * 100 + 0.5) / 100;
            //float new = [[NSString stringWithFormat:@"%.2f",old]floatValue];
            
            if(savedProfile == nil ||
               savedProfile.birthday.month      != userProfile.birthday.month ||
               savedProfile.birthday.day        != userProfile.birthday.day ||
               savedProfile.birthday.year       != userProfile.birthday.year ||
               savedProfile.gender              != userProfile.gender ||
               savedProfile.unit                != userProfile.unit ||
               //savedProfile.sensitivity         != userProfile.sensitivity ||
               savedProfile.weight              != userProfile.weight ||
               savedProfile.height              != userProfile.height ||
               savedCalorieGoal                 != self.calorieGoal ||
               savedStepGoal                    != self.stepGoal ||
               !(roundedSavedDistanceGoal - roundedDistanceGoal <= 0.1 && roundedSavedDistanceGoal - roundedDistanceGoal >= -0.1) ||
               //roundedSavedDistanceGoal         != roundedDistanceGoal ||
               savedSleepSetting.sleep_goal_hi  != self.sleepSetting.sleep_goal_hi ||
               savedSleepSetting.sleep_goal_lo  != self.sleepSetting.sleep_goal_lo ||
               //savedSleepSetting.sleep_mode     != self.sleepSetting.sleep_mode ||
               self.timeDateChanged) {
                
                // Alert Here.
                // saveUserProfile();
                self.updatedSettings    = YES;
                self.timeDateChanged    = NO;
                DDLogInfo(@"settingsChanged");
                
                if (self.initialSync) {
                    [self useWatchSettings];
                }
                else {
                    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
                        [self.delegate respondsToSelector:@selector(didChangeSettings)]) {
                        
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PROMPT_CHANGE_SETTINGS];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [self.delegate didChangeSettings];
                    } else {
                        if (!self.watchSettingsSelected) {
                            [self useAppSettings];
                        }
                        
                    }
                }
                profileUpdated = NO;
            } else {
                profileUpdated = YES;
                if (!self.watchSettingsSelected) {
                    [self useAppSettings];
                }
            }
        } else {
            SalutronUserProfile *savedProfile   = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            self.appUserProfile                 = savedProfile;
            if (![self.watchUserProfile isEqualToUserProfile:userProfile]){
                self.watchUserProfile               = userProfile;
            }
       //     if (!self.watchSettingsSelected && self.appUserProfile) {
       //         [self useAppSettings];
       //     }else{
                [self useWatchSettings];
       //     }
            profileUpdated = YES;
        }
        
        
        
        /*
         @property (strong, nonatomic) SH_Date *birthday;
         @property (assign, nonatomic) Gender gender;
         @property (assign, nonatomic) Unit unit;
         @property (assign, nonatomic) AccelSensorSensitivity sensitivity;
         @property (assign, nonatomic) int weight;                           // 44 - 440 (lbs)
         @property (assign, nonatomic) int height;                           // 100 - 220 (cm)
         
         if(savedProfile == nil ||
         [savedProfile isEqualToUserProfile:userProfile]) {
         saveUserProfile();
         } else {
         profileUpdated = YES;
         }
         
         */
    } else {
        saveUserProfile();
        
        profileUpdated = YES;
        
        NSInteger sleepGoal         = self.sleepSetting.sleep_goal_lo;
        sleepGoal                   += self.sleepSetting.sleep_goal_hi << 8;
        NSData *sleepSettingData    = [NSKeyedArchiver archivedDataWithRootObject:self.sleepSetting];
        
        [SFAGoalsData addGoalsWithSteps:self.stepGoal
                               distance:self.distanceGoal
                               calories:self.calorieGoal
                                  sleep:sleepGoal
                                 device:self.deviceEntity
                          managedObject:_managedObjectContext];
        
        [self.userDefaults setInteger:sleepGoal forKey:SLEEP_GOAL];
        [self.userDefaults setInteger:self.calorieGoal forKey:CALORIE_GOAL];
        [self.userDefaults setInteger:self.stepGoal forKey:STEP_GOAL];
        [self.userDefaults setFloat:self.distanceGoal forKey:DISTANCE_GOAL];
        [self.userDefaults setObject:sleepSettingData forKey:SLEEP_SETTING];
        [self.userDefaults synchronize];
        
        [SleepSettingEntity sleepSettingWithSleepSetting:self.sleepSetting forDeviceEntity:self.deviceEntity];
        [UserProfileEntity userProfileWithSalutronUserProfile:userProfile forDeviceEntity:self.deviceEntity];
        [TimeDateEntity timeDateWithTimeDate:self.watchTimeDate forDeviceEntity:self.deviceEntity];
        
        //[self syncToServer];
        
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didSyncFinished:profileUpdated:)]) {
            self.isSyncFinished = YES;
            self.deviceEntity.lastDateSynced = [NSDate date];
            [self.managedObjectContext save:nil];
            [self.delegate didSyncFinished:self.deviceEntity profileUpdated:profileUpdated];
        }
        
        
        
        [self.userDefaults setObject:self.deviceDetail.peripheral.identifier.UUIDString forKey:DEVICE_UUID];
        [self.userDefaults synchronize];
        
        self.salutronSDK.delegate = nil;
        self.salutronSDK = nil;
        _salutronSDK = nil;
    }
    
    [Flurry endTimedEvent:DEVICE_GET_USER_PROFILE withParameters:nil];
    [Flurry endTimedEvent:DEVICE_START_SYNC withParameters:nil];
    
    [self checkAndSaveToHealthKit];
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
            [[SFAHealthKitManager sharedManager] requestAuthorizationWithSuccess:^(BOOL success) {
                if (success) {
                    [[SFAHealthKitManager sharedManager] saveAllDataToHealthStoreFromDataHeaders:self.retrievedDataHeadersForCurrentSync];
                }
            } failure:^(NSError *error) {
                
            }];
            
        }
    });
    */

    /*if (_watchModel == WatchModel_Core_C200 || _watchModel == WatchModel_Move_C300 || _watchModel == WatchModel_Zone_C410)
     [[SalutronSDK sharedInstance] disconnectDevice];*/
    
    /*
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncFinished:profileUpdated:)]) {
        self.isSyncFinished = YES;
        self.deviceEntity.lastDateSynced = [NSDate date];
        [self.managedObjectContext save:nil];
        [self.delegate didSyncFinished:self.deviceEntity profileUpdated:profileUpdated];
    }
    
    [self.userDefaults setObject:self.deviceDetail.peripheral.identifier.UUIDString forKey:DEVICE_UUID];
    [self.userDefaults synchronize];
    
    self.salutronSDK.delegate = nil;
    self.salutronSDK = nil;
    _salutronSDK = nil;
     */
}

/**
 * methods for restoring settings
 */

- (void)didUpdateUserProfileWithStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    [self performSelector:@selector(_updateCalibrationData) withObject:nil afterDelay:SELECTOR_DELAY];
}

- (void)didUpdateCalibrationDataWithStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    DDLogInfo(@" ------------> DID UPDATE CALIBRATION DATA WITH STATUS <------------ ");
    if(self.calibrationType < 5) {
        DDLogInfo(@"self.calibrationType: %i",self.calibrationType);
        [self performSelector:@selector(_updateCalibrationData) withObject:nil afterDelay:SELECTOR_DELAY];
    } else {
        self.calibrationType = 0;
        [self performSelector:@selector(_updateWakeup) withObject:nil afterDelay:SELECTOR_DELAY];
    }
}

- (void)didUpdateWakeupWithStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if(self.wakeupType < 4) {
        [self performSelector:@selector(_updateWakeup) withObject:nil afterDelay:SELECTOR_DELAY];
    } else {
        [self performSelector:@selector(_updateDistanceGoal) withObject:nil afterDelay:SELECTOR_DELAY];
    }
}

- (void)didUpdateDistanceGoalWithStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    [self performSelector:@selector(_updateCalorieGoal) withObject:nil afterDelay:SELECTOR_DELAY];
}

- (void)didUpdateCalorieGoalWithStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    [self performSelector:@selector(_updateStepGoal) withObject:nil afterDelay:SELECTOR_DELAY];
}

- (void)didUpdateStepGoalWithStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
//    [self performSelector:@selector(getUserProfile) withObject:nil afterDelay:SELECTOR_DELAY];
    [self performSelector:@selector(saveTimeDateToWatch) withObject:nil afterDelay:0];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 200) {
        if (buttonIndex == 1) {
            [self saveRetrievedDataToHealthStoreWithRequestPermission];
        }
        else{
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"HealthKitEnabled"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)saveRetrievedDataToHealthStore{
    DDLogInfo(@"");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //});
        //dispatch_async(dispatch_get_main_queue(), ^{
        if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
            //[[SFAHealthKitManager sharedManager] requestAuthorizationWithSuccess:^(BOOL success) {
            //    if (success) {
                    if ([SFAHealthKitManager sharedManager].isHealthKitSyncOngoing) {
                        [SFAHealthKitManager sharedManager].delegate = self;
                    }
                    else{
                        [SFAHealthKitManager sharedManager].delegate = nil;
                        [[SFAHealthKitManager sharedManager] saveAllDataToHealthStoreFromDataHeaders:self.retrievedDataHeadersForCurrentSync];
                    }
           //     }
          //  } failure:^(NSError *error) {
          //  }];
        }
    });
}

- (void)saveRetrievedDataToHealthStoreWithRequestPermission{
    DDLogInfo(@"");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //});
        //dispatch_async(dispatch_get_main_queue(), ^{
        if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
            [[SFAHealthKitManager sharedManager] requestAuthorizationWithSuccess:^(BOOL success) {
                if (success) {
                    if ([SFAHealthKitManager sharedManager].isHealthKitSyncOngoing) {
                        [SFAHealthKitManager sharedManager].delegate = self;
                    }
                    else{
                        [SFAHealthKitManager sharedManager].delegate = nil;
                        [[SFAHealthKitManager sharedManager] saveAllDataToHealthStoreFromDataHeaders:self.retrievedDataHeadersForCurrentSync];
                    }
                }
            } failure:^(NSError *error) {
                
            }];
            
        }
    });
}

- (void)syncingToHealthKitFinished{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //});
        //
    [SFAHealthKitManager sharedManager].delegate = nil;
    [[SFAHealthKitManager sharedManager] saveAllDataToHealthStoreFromDataHeaders:self.retrievedDataHeadersForCurrentSync];
    });
}

#pragma mark - Convert Android to iOS Mac Address

- (NSString *)convertAndroidToiOSMacAddress:(NSString *)macAddress
{
    NSArray *macAddressParts = [macAddress componentsSeparatedByString:@":"];
    NSInteger middle = [macAddressParts count] / 2;
    NSMutableString *convertedMacAddress = [NSMutableString new];
    
    for (NSInteger i = [macAddressParts count] - 1; i>=0; i--) {
        [convertedMacAddress appendString:[macAddressParts objectAtIndex:i]];
        
        if (middle == i) {
            [convertedMacAddress appendString:@"0000"];
        }
    }
    return [convertedMacAddress lowercaseString];
}

- (void)checkAndSaveToHealthKit{
    if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]){
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"InitialWatchToAppSync"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"InitialWatchToAppSync"] isEqual:@(0)]) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HealthKitEnabled"]) {
                [self saveRetrievedDataToHealthStore];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:HEALTHAPP_ACCESS_MESSAGE
                                                               delegate:nil
                                                      cancelButtonTitle:BUTTON_TITLE_NO
                                                      otherButtonTitles:BUTTON_TITLE_CONTINUE, nil];
                alert.tag =  200;
                alert.delegate = self;
                [alert show];
            }
            //[self saveRetrievedDataToHealthStore];
        }
    }
}

@end
