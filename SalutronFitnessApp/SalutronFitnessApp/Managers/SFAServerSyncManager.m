  //
//  SFAServerSyncManager.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/7/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDictionary+JSON.h"

#import "DeviceEntity+Data.h"
#import "WorkoutInfoEntity+Data.h"
#import "SleepDatabaseEntity+Data.h"
#import "StatisticalDataHeaderEntity+Data.h"
#import "StatisticalDataPointEntity+Data.h"
#import "SalutronUserProfile+Data.h"
#import "GoalsEntity+Data.h"
#import "SleepSetting+Data.h"
#import "WakeupEntity+Data.h"
#import "NSDate+Format.h"

#import "UserProfileEntity+Data.h"
#import "TimeDateEntity+Data.h"
#import "NotificationEntity+Data.h"
#import "SleepSettingEntity+Data.h"
#import "CalibrationDataEntity+Data.h"

#import "JDACoreData.h"

#import "SFASettingsManager.h"
#import "SFAServerManager+RefreshAccessToken.h"
#import "SFAServerAccountManager.h"
#import "SFAServerSyncManager.h"
#import "SFASalutronFitnessAppDelegate.h"

#import "InactiveAlert+Data.h"
#import "DayLightAlert+Data.h"
#import "NightLightAlert+Data.h"
#import "Wakeup+Data.h"

#import "InactiveAlertEntity+Data.h"
#import "DayLightAlertEntity+Data.h"
#import "NightLightAlertEntity+Data.h"

#import "WorkoutHeaderEntity+CoreDataProperties.h"

#import "SFAHealthKitManager.h"
#import "ZipArchive.h"
#import <AWSS3/AWSS3.h>


@interface SFAServerSyncManager () <SFAHealthKitManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *dataForHealthStore;
@property (strong, nonatomic) NSArray *retrievedDataHeaders;
@property (strong, nonatomic) NSOperation *operation;
@property (strong, nonatomic) NSMutableArray *allDataHeaders;

@end

@implementation SFAServerSyncManager

#pragma mark - Singleton Instance

+ (SFAServerSyncManager *)sharedManager
{
    static SFAServerSyncManager *instance = nil;
    
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

#pragma mark - Getters

- (NSUserDefaults *)userDefaults
{
    if (!_userDefaults) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    return _userDefaults;
}

- (NSOperationQueue *)operationQueue
{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    
    return _operationQueue;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if(!_managedObjectContext) {
        SFASalutronFitnessAppDelegate *appDelegate = (SFASalutronFitnessAppDelegate *) [UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}


- (NSMutableArray *)allDataHeaders
{
    if (!_allDataHeaders) {
        _allDataHeaders = [[NSMutableArray alloc] init];
    }
    
    return _allDataHeaders;
}

#pragma mark - Private Methods

- (NSString *)jsonStringWithDeviceEntity:(DeviceEntity *)device
{
    NSArray *dataHeaders = [StatisticalDataHeaderEntity dataHeadersDictionaryWithContext:self.managedObjectContext device:device];
    //DDLogError(@"data headers: %@", dataHeaders);
    
    SFASettingsManager *settingsManager = [SFASettingsManager sharedManager];
    SalutronUserProfile *userProfile    = [SalutronUserProfile userProfile];
    SleepSetting *sleepSetting          = [SleepSetting sleepSetting];
    Wakeup *wakeup                      = [Wakeup wakeup];//wakeupEntityForDeviceEntity:device];
    InactiveAlert *inactiveAlert        = [InactiveAlert inactiveAlert];
    DayLightAlert *dayLightAlert        = [DayLightAlert dayLightAlert];
    NightLightAlert *nightLightAlert    = [NightLightAlert nightLightAlert];

    
    NSDictionary *dictionary            = @{API_SYNC_DEVICE             : device.dictionary,
                                            API_SYNC_WORKOUT            : [WorkoutInfoEntity workoutsDictionaryForDeviceEntity:device],
                                            API_SYNC_WORKOUT_HEADER     : [WorkoutHeaderEntity workoutHeaderDictionaryWithDevice:device],
                                            API_SYNC_SLEEP              : [SleepDatabaseEntity sleepDatabasesDictionaryForDeviceEntity:device],
                                            API_SYNC_DATA_HEADER        : dataHeaders,
                                            API_SYNC_DEVICE_SETTINGS    : settingsManager.dictionary,
                                            API_SYNC_USER_PROFILE       : userProfile.dictionary,
                                            API_SYNC_GOAL               : [GoalsEntity goalsEntitiesDictionaryForDeviceEntity:device],
                                            API_SYNC_SLEEP_SETTINGS     : sleepSetting.dictionary,
                                            API_SYNC_WAKEUP_INFO        : wakeup.dictionary,
                                            API_SYNC_INACTIVE_ALERT     : inactiveAlert.dictionary,
                                            API_SYNC_LIGHT_SETTINGS     : @[dayLightAlert.dictionary,nightLightAlert.dictionary]};
    
    return [dictionary JSONString];
}

- (NSString *)jsonStringWithDeviceEntityWithSpecificDate:(DeviceEntity *)device
{
    NSArray *dataHeaders = [StatisticalDataHeaderEntity dataHeadersWithStartedDateDictionaryWithContext:self.managedObjectContext device:device];
    DDLogError(@"");
    //DDLogError(@"data headers: %@", dataHeaders);
    
    SFASettingsManager *settingsManager = [SFASettingsManager sharedManager];
    SalutronUserProfile *userProfile    = [SalutronUserProfile userProfile];
    SleepSetting *sleepSetting          = [SleepSetting sleepSetting];
    Wakeup *wakeup                      = [Wakeup wakeup];//[WakeupEntity wakeupEntityForDeviceEntity:device];
    InactiveAlert *inactiveAlert        = [InactiveAlert inactiveAlert];
    DayLightAlert *dayLightAlert        = [DayLightAlert dayLightAlert];
    NightLightAlert *nightLightAlert    = [NightLightAlert nightLightAlert];
    
    
    NSDictionary *dictionary            = @{API_SYNC_DEVICE             : device.dictionary,
                                            API_SYNC_WORKOUT            : [WorkoutInfoEntity workoutsDictionaryWithStartingDateForDeviceEntity:device],
                                            API_SYNC_WORKOUT_HEADER     : [WorkoutHeaderEntity workoutHeaderDictionaryWithDevice:device],
                                            API_SYNC_SLEEP              : [SleepDatabaseEntity sleepDatabasesWithStartingDateDictionaryForDeviceEntity:device],
                                            API_SYNC_DATA_HEADER        : dataHeaders,
                                            API_SYNC_DEVICE_SETTINGS    : settingsManager.dictionary,
                                            API_SYNC_USER_PROFILE       : userProfile.dictionary,
                                            API_SYNC_GOAL               : [GoalsEntity goalsEntitiesDictionaryForDeviceEntity:device],
                                            API_SYNC_SLEEP_SETTINGS     : sleepSetting.dictionary,
                                            API_SYNC_WAKEUP_INFO        : wakeup.dictionary,
                                            API_SYNC_INACTIVE_ALERT     : inactiveAlert.dictionary,
                                            API_SYNC_LIGHT_SETTINGS     : @[dayLightAlert.dictionary,nightLightAlert.dictionary]};
    
    return [dictionary JSONString];
}

- (NSArray *)jsonStringWithDeviceEntityForMultipleDays:(DeviceEntity *)device
{
    NSArray *dataHeaders = [StatisticalDataHeaderEntity dataHeadersWithStartedDateDictionaryWithContext:self.managedObjectContext device:device];
    DDLogError(@"");
    
    NSMutableArray *jsonDictionaryOfDays = [[NSMutableArray alloc] init];
    
    //DDLogError(@"data headers: %@", dataHeaders);
    
    //Loop for per day dictionary will be based on dataHeaders retrieved
    for (NSDictionary *dataHeaderDict in dataHeaders) {
        NSString *dateString                = dataHeaderDict[API_DATA_HEADER_CREATED_DATE];
        NSDate *date                        = [NSDate dateFromString:dateString withFormat:API_DATE_FORMAT];
        SFASettingsManager *settingsManager = [SFASettingsManager sharedManager];
        SalutronUserProfile *userProfile    = [SalutronUserProfile userProfile];
        SleepSetting *sleepSetting          = [SleepSetting sleepSetting];
        Wakeup *wakeup                      = [Wakeup wakeup];//[WakeupEntity wakeupEntityForDeviceEntity:device];
        InactiveAlert *inactiveAlert        = [InactiveAlert inactiveAlert];
        DayLightAlert *dayLightAlert        = [DayLightAlert dayLightAlert];
        NightLightAlert *nightLightAlert    = [NightLightAlert nightLightAlert];
        
        NSDateFormatter *dateFormatter      = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat            = API_DATE_FORMAT;
        dateFormatter.timeZone              = [NSTimeZone timeZoneForSecondsFromGMT:0];
        NSDate *workoutHeaderDate           = [dateFormatter dateFromString:dateString];
        
        
        NSDictionary *dictionary            = @{API_SYNC_DEVICE             : device.dictionary,
                                                API_SYNC_WORKOUT            : [WorkoutInfoEntity workoutsDictionaryForDeviceEntity:device forDate:date],
                                                API_SYNC_WORKOUT_HEADER     : [WorkoutHeaderEntity workoutHeaderDictionaryWithDevice:device forDate:workoutHeaderDate],
                                                API_SYNC_SLEEP              : [SleepDatabaseEntity sleepDatabasesDictionaryForDeviceEntity:device forDate:date],
                                                API_SYNC_DATA_HEADER        : @[dataHeaderDict],
                                                API_SYNC_DEVICE_SETTINGS    : settingsManager.dictionary,
                                                API_SYNC_USER_PROFILE       : userProfile.dictionary,
                                                API_SYNC_GOAL               : [GoalsEntity goalsEntitiesDictionaryForDeviceEntity:device],
                                                API_SYNC_SLEEP_SETTINGS     : sleepSetting.dictionary,
                                                API_SYNC_WAKEUP_INFO        : wakeup.dictionary,
                                                API_SYNC_INACTIVE_ALERT     : inactiveAlert.dictionary,
                                                API_SYNC_LIGHT_SETTINGS     : @[dayLightAlert.dictionary,nightLightAlert.dictionary]};
        
        [jsonDictionaryOfDays addObject:@{@"stringData" : [dictionary JSONString],
                                          @"date"       : dateString,
                                          @"macAddress" : device.macAddress}];
    }
    
    return jsonDictionaryOfDays;
    
}


- (void)convertResult:(NSDictionary *)result forDeviceEntity:(DeviceEntity *)deviceEntity
{
    NSArray *workout                = [result objectForKey:API_SYNC_WORKOUT];
    NSArray *sleep                  = [result objectForKey:API_SYNC_SLEEP];
    NSArray *dataHeader             = [result objectForKey:API_SYNC_DATA_HEADER];
    //if ([deviceEntity.modelNumber isEqualToNumber:@(WatchModel_R420)]) {
        dataHeader                  = @[[result objectForKey:API_SYNC_DATA_HEADER]];
    //}
    NSDictionary *deviceSettings    = [result objectForKey:API_SYNC_DEVICE_SETTINGS];
    NSDictionary *userProfile       = [result objectForKey:API_SYNC_USER_PROFILE];
    NSArray *goals                  = [result objectForKey:API_SYNC_GOAL];
    NSDictionary *sleepSettings     = [result objectForKey:API_SYNC_SLEEP_SETTINGS];
    NSDictionary *wakeupInfo        = [result objectForKey:API_SYNC_WAKEUP_INFO];
    NSDictionary *device            = [result objectForKey:API_SYNC_DEVICE];
    
    NSDictionary *inactiveAlertDict = [result objectForKey:API_SYNC_INACTIVE_ALERT];
    NSArray *lightSettingsArray = [result objectForKey:API_SYNC_LIGHT_SETTINGS];
    NSDictionary *dayLightAlertDict;
    NSDictionary *nightLightAlertDict;
    for (NSDictionary *lightSetting in lightSettingsArray){
        if ([[lightSetting objectForKey:API_LIGHT_ALERT_SETTINGS] isEqualToString:@"day"]){
            dayLightAlertDict = lightSetting;
        }else{
            nightLightAlertDict = lightSetting;
        }
    }
    
    NSArray *workoutHeader     = [result objectForKey:API_SYNC_WORKOUT_HEADER];

    SFASettingsManager *manager     = [SFASettingsManager sharedManager];
    
    [WorkoutInfoEntity workoutsWithArray:workout forDeviceEntity:deviceEntity];
    [SleepDatabaseEntity sleepDatabasesWithArray:sleep forDeviceEntity:deviceEntity];
    NSArray *dataHeaders = [StatisticalDataHeaderEntity dataHeadersWithArray:dataHeader forDeviceEntity:deviceEntity];
    [manager settingsWithDictionary:deviceSettings forDeviceEntity:deviceEntity];
    [GoalsEntity goalsEntitiesWithArray:goals forDeviceEnitity:deviceEntity];
    [WakeupEntity wakeupEntityWithDictionary:wakeupInfo forDeviceEntity:deviceEntity];
    [DeviceEntity deviceEntityWithDictionary:device];
    
    [InactiveAlertEntity inactiveAlertWithInactiveAlert:[InactiveAlert inactiveAlertWithDictionary:inactiveAlertDict] forDeviceEntity:deviceEntity];
    [DayLightAlertEntity dayLightAlertWithDayLightAlert:[DayLightAlert dayLightAlertWithDictionary:dayLightAlertDict] forDeviceEntity:deviceEntity];
    [NightLightAlertEntity nightLightAlertWithNightLightAlert:[NightLightAlert nightLightAlertWithDictionary:nightLightAlertDict] forDeviceEntity:deviceEntity];
    
    SalutronUserProfile *profile    = [SalutronUserProfile userProfileWithDictionary:userProfile];
    SleepSetting *sleepSetting      = [SleepSetting sleepSettingWithDictionary:sleepSettings];
    
    [UserProfileEntity userProfileWithSalutronUserProfile:profile forDeviceEntity:deviceEntity];
    [SleepSettingEntity sleepSettingWithSleepSetting:sleepSetting forDeviceEntity:deviceEntity];
    
    [WorkoutHeaderEntity workoutHeadersWithArray:workoutHeader forDeviceEntity:deviceEntity];
    
    [[JDACoreData sharedManager] save];
    
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate *date                    = [dateFormatter dateFromString:[device objectForKey:API_DEVICE_UPDATED_AT]];
    if (date) {
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:data forKey:deviceEntity.macAddress];
        [userDefaults synchronize];
    }
    //Save data from cloud to healthKit
    if ([deviceEntity.modelNumber isEqualToNumber:@(WatchModel_R420)] &&
        [[SFAHealthKitManager sharedManager] isHealthKitAvailable] &&
        [[NSUserDefaults standardUserDefaults] objectForKey:@"InitialWatchToAppSync"] &&
        [[[NSUserDefaults standardUserDefaults] objectForKey:@"InitialWatchToAppSync"] isEqual:@(1)]) {
    
    }else if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]){
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HealthKitEnabled"]) {
            [self saveDataToHealthApp:dataHeaders];
        }
        else{
            self.retrievedDataHeaders = dataHeaders;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:HEALTHAPP_ACCESS_MESSAGE
                                                           delegate:nil
                                                  cancelButtonTitle:BUTTON_TITLE_NO
                                                  otherButtonTitles:BUTTON_TITLE_CONTINUE, nil];
            alert.tag =  200;
            alert.delegate = self;
            [alert show];
        }
    }
}


- (void)convertResultPerDay:(NSDictionary *)result forDeviceEntity:(DeviceEntity *)deviceEntity isLastDay:(BOOL)isLastDay
{
    NSArray *workout                = [result objectForKey:API_SYNC_WORKOUT];
    NSArray *sleep                  = [result objectForKey:API_SYNC_SLEEP];
    NSArray *dataHeader             = [result objectForKey:API_SYNC_DATA_HEADER];
    //if ([deviceEntity.modelNumber isEqualToNumber:@(WatchModel_R420)]) {
        dataHeader                  = @[[result objectForKey:API_SYNC_DATA_HEADER]];
    //}
    NSDictionary *deviceSettings    = [result objectForKey:API_SYNC_DEVICE_SETTINGS];
    NSDictionary *userProfile       = [result objectForKey:API_SYNC_USER_PROFILE];
    NSArray *goals                  = [result objectForKey:API_SYNC_GOAL];
    NSDictionary *sleepSettings     = [result objectForKey:API_SYNC_SLEEP_SETTINGS];
    NSDictionary *wakeupInfo        = [result objectForKey:API_SYNC_WAKEUP_INFO];
    NSDictionary *device            = [result objectForKey:API_SYNC_DEVICE];
    
    NSDictionary *inactiveAlertDict = [result objectForKey:API_SYNC_INACTIVE_ALERT];
    NSArray *lightSettingsArray = [result objectForKey:API_SYNC_LIGHT_SETTINGS];
    NSDictionary *dayLightAlertDict;
    NSDictionary *nightLightAlertDict;
    for (NSDictionary *lightSetting in lightSettingsArray){
        if ([[lightSetting objectForKey:API_LIGHT_ALERT_SETTINGS] isEqualToString:@"day"]){
            dayLightAlertDict = lightSetting;
        }else{
            nightLightAlertDict = lightSetting;
        }
    }
    
    NSArray *workoutHeader     = [result objectForKey:API_SYNC_WORKOUT_HEADER];
    
    SFASettingsManager *manager     = [SFASettingsManager sharedManager];
    
    [WorkoutInfoEntity workoutsWithArray:workout forDeviceEntity:deviceEntity];
    [SleepDatabaseEntity sleepDatabasesWithArray:sleep forDeviceEntity:deviceEntity];
    NSArray *dataHeaders = [StatisticalDataHeaderEntity dataHeadersWithArray:dataHeader forDeviceEntity:deviceEntity];
    [manager settingsWithDictionary:deviceSettings forDeviceEntity:deviceEntity];
    [GoalsEntity goalsEntitiesWithArray:goals forDeviceEnitity:deviceEntity];
    [WakeupEntity wakeupEntityWithDictionary:wakeupInfo forDeviceEntity:deviceEntity];
    [DeviceEntity deviceEntityWithDictionary:device];
    
    [InactiveAlertEntity inactiveAlertWithInactiveAlert:[InactiveAlert inactiveAlertWithDictionary:inactiveAlertDict] forDeviceEntity:deviceEntity];
    [DayLightAlertEntity dayLightAlertWithDayLightAlert:[DayLightAlert dayLightAlertWithDictionary:dayLightAlertDict] forDeviceEntity:deviceEntity];
    [NightLightAlertEntity nightLightAlertWithNightLightAlert:[NightLightAlert nightLightAlertWithDictionary:nightLightAlertDict] forDeviceEntity:deviceEntity];
    
    SalutronUserProfile *profile    = [SalutronUserProfile userProfileWithDictionary:userProfile];
    SleepSetting *sleepSetting      = [SleepSetting sleepSettingWithDictionary:sleepSettings];
    
    [UserProfileEntity userProfileWithSalutronUserProfile:profile forDeviceEntity:deviceEntity];
    [SleepSettingEntity sleepSettingWithSleepSetting:sleepSetting forDeviceEntity:deviceEntity];
    
    [WorkoutHeaderEntity workoutHeadersWithArray:workoutHeader forDeviceEntity:deviceEntity];
    
    [[JDACoreData sharedManager] save];
    
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date                    = [dateFormatter dateFromString:[device objectForKey:API_DEVICE_UPDATED_AT]];
    if (date) {
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:data forKey:deviceEntity.macAddress];
        [userDefaults synchronize];
    }
    //Save data from cloud to healthKit
    if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable] && !isLastDay){
        [self.allDataHeaders addObject:dataHeaders[0]];
    }
        
    if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable] && isLastDay){
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HealthKitEnabled"]) {
            [self saveDataToHealthApp:[self.allDataHeaders copy]];
        }
        else{
            self.retrievedDataHeaders = [self.allDataHeaders copy];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:HEALTHAPP_ACCESS_MESSAGE
                                                           delegate:nil
                                                  cancelButtonTitle:BUTTON_TITLE_NO
                                                  otherButtonTitles:BUTTON_TITLE_CONTINUE, nil];
            alert.tag =  200;
            alert.delegate = self;
            [alert show];
        }
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 200) {
        if (buttonIndex == 1) {
            [self saveDataToHealthAppWithPermission:self.retrievedDataHeaders];
        }
        else{
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"HealthKitEnabled"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)saveDataToHealthApp:(NSArray *)dataHeaders{
    DDLogInfo(@"");
    [self.allDataHeaders removeAllObjects];
    if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
       // [[SFAHealthKitManager sharedManager] requestAuthorizationWithSuccess:^(BOOL success) {
        //    if (success) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //});
            //dispatch_async(dispatch_get_main_queue(), ^{
                    if ([SFAHealthKitManager sharedManager].isHealthKitSyncOngoing) {
                        [SFAHealthKitManager sharedManager].delegate = self;
                        self.dataForHealthStore = dataHeaders;
                    }
                    else{
                        [SFAHealthKitManager sharedManager].delegate = nil;
                        [[SFAHealthKitManager sharedManager] saveAllDataToHealthStoreFromDataHeaders:dataHeaders];
                    }
                });
            //}
        //} failure:^(NSError *error) {
            
        //}];
    }
}

- (void)saveDataToHealthAppWithPermission:(NSArray *)dataHeaders{
    DDLogInfo(@"");
    
    if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
        [[SFAHealthKitManager sharedManager] requestAuthorizationWithSuccess:^(BOOL success) {
            if (success) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    //});
                    // dispatch_async(dispatch_get_main_queue(), ^{
                    if ([SFAHealthKitManager sharedManager].isHealthKitSyncOngoing) {
                        [SFAHealthKitManager sharedManager].delegate = self;
                        self.dataForHealthStore = dataHeaders;
                    }
                    else{
                        [SFAHealthKitManager sharedManager].delegate = nil;
                        [[SFAHealthKitManager sharedManager] saveAllDataToHealthStoreFromDataHeaders:dataHeaders];
                    }
                });
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)convertResultWithoutSettings:(NSDictionary *)result forDeviceEntity:(DeviceEntity *)deviceEntity
{
    NSArray *workout                = [result objectForKey:API_SYNC_WORKOUT];
    NSArray *sleep                  = [result objectForKey:API_SYNC_SLEEP];
    NSArray *dataHeader             = [result objectForKey:API_SYNC_DATA_HEADER];
    /*
    NSDictionary *deviceSettings    = [result objectForKey:API_SYNC_DEVICE_SETTINGS];
    NSDictionary *userProfile       = [result objectForKey:API_SYNC_USER_PROFILE];
    NSArray *goals                  = [result objectForKey:API_SYNC_GOAL];
    NSDictionary *sleepSettings     = [result objectForKey:API_SYNC_SLEEP_SETTINGS];
    NSDictionary *wakeupInfo        = [result objectForKey:API_SYNC_WAKEUP_INFO];
    NSDictionary *device            = [result objectForKey:API_SYNC_DEVICE];
    
    NSDictionary *inactiveAlertDict = [result objectForKey:API_SYNC_INACTIVE_ALERT];
    NSArray *lightSettingsArray = [result objectForKey:API_SYNC_LIGHT_SETTINGS];
    NSDictionary *dayLightAlertDict;
    NSDictionary *nightLightAlertDict;
    for (NSDictionary *lightSetting in lightSettingsArray){
        if ([[lightSetting objectForKey:API_LIGHT_ALERT_SETTINGS] isEqualToString:@"day"]){
            dayLightAlertDict = lightSetting;
        }else{
            nightLightAlertDict = lightSetting;
        }
    }
    
    SFASettingsManager *manager     = [SFASettingsManager sharedManager];
    */
    
    NSDictionary *device            = [result objectForKey:API_SYNC_DEVICE];

    [WorkoutInfoEntity workoutsWithArray:workout forDeviceEntity:deviceEntity];
    [SleepDatabaseEntity sleepDatabasesWithArray:sleep forDeviceEntity:deviceEntity];
    [StatisticalDataHeaderEntity dataHeadersWithArray:dataHeader forDeviceEntity:deviceEntity];
    /*
    [manager settingsWithDictionary:deviceSettings forDeviceEntity:deviceEntity];
    [GoalsEntity goalsEntitiesWithArray:goals forDeviceEnitity:deviceEntity];
    [WakeupEntity wakeupEntityWithDictionary:wakeupInfo forDeviceEntity:deviceEntity];
    [DeviceEntity deviceEntityWithDictionary:device];
    
    [InactiveAlertEntity inactiveAlertWithInactiveAlert:[InactiveAlert inactiveAlertWithDictionary:inactiveAlertDict] forDeviceEntity:deviceEntity];
    [DayLightAlertEntity dayLightAlertWithDayLightAlert:[DayLightAlert dayLightAlertWithDictionary:dayLightAlertDict] forDeviceEntity:deviceEntity];
    [NightLightAlertEntity nightLightAlertWithNightLightAlert:[NightLightAlert nightLightAlertWithDictionary:nightLightAlertDict] forDeviceEntity:deviceEntity];
    
    SalutronUserProfile *profile    = [SalutronUserProfile userProfileWithDictionary:userProfile];
    SleepSetting *sleepSetting      = [SleepSetting sleepSettingWithDictionary:sleepSettings];
    
    [UserProfileEntity userProfileWithSalutronUserProfile:profile forDeviceEntity:deviceEntity];
    [SleepSettingEntity sleepSettingWithSleepSetting:sleepSetting forDeviceEntity:deviceEntity];
    */
    [[JDACoreData sharedManager] save];
    
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date                    = [dateFormatter dateFromString:[device objectForKey:API_DEVICE_UPDATED_AT]];
    if (date) {
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:data forKey:deviceEntity.macAddress];
        [userDefaults synchronize];
    }
}

#pragma mark - Public Methods

- (NSOperation *)syncDeviceEntity:(DeviceEntity *)deviceEntity
             withSuccess:(void (^)(NSString *macAddress))success
                 failure:(void (^)(NSError *error))failure
{
    SFAServerManager *serverManager                 = [SFAServerManager sharedManager];
    SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
    NSDictionary *parameters                        = @{API_OAUTH_ACCESS_TOKEN : serverAccountManager.accessToken,
                                                        API_SYNC_DATA          : [self jsonStringWithDeviceEntity:deviceEntity]};
    
    /*NSOperation *operation = [serverManager postRequestWithRefreshAccessTokenToURL:API_SYNC_URL parameters:parameters success:^(NSDictionary *response) {
        NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
        NSString *macAddress = [result objectForKey:API_SYNC_MAC_ADDRESS];
        
        if (success) {
            success(macAddress);
        }
    } failure:failure];*/
    //if (deviceEntity.modelNumber.integerValue == WatchModel_R420) {
    self.operation = [serverManager postRequestWithRefreshAccessTokenToURL:API_SYNC_URL_V2 parameters:parameters success:^(NSDictionary *response) {
        DDLogInfo(@"%@", response);
            if (![self.operation isCancelled]) {
                NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
                NSString *macAddress = [result objectForKey:API_SYNC_MAC_ADDRESS];
                
                if (success) {
                    success(macAddress);
                }
            }
        } failure:failure];
        
//    }
//    else{
//        self.operation = [serverManager postRequestWithRefreshAccessTokenToURL:API_SYNC_URL parameters:parameters success:^(NSDictionary *response) {
//            if (![self.operation isCancelled]) {
//                NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
//                NSString *macAddress = [result objectForKey:API_SYNC_MAC_ADDRESS];
//                
//                if (success) {
//                    success(macAddress);
//                }
//            }
//        } failure:failure];
//    }
    return self.operation;
}

- (NSOperation *)syncDeviceEntityWithParameters:(NSDictionary *)parameters
                                    withSuccess:(void (^)(NSString *macAddress))success
                                        failure:(void (^)(NSError *error))failure
{
    SFAServerManager *serverManager                 = [SFAServerManager sharedManager];
    self.operation = [serverManager postRequestWithRefreshAccessTokenToURL:API_SYNC_URL parameters:parameters success:^(NSDictionary *response) {
        if (![self.operation isCancelled]) {
            //NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
            //NSString *macAddress = [result objectForKey:API_SYNC_MAC_ADDRESS];
            
            //NSString *message = [response objectForKey:@"message"];
            //int status = [response objectForKey:@"status"];
            if (success) {
                //if (status == 202) {
                NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
                NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
                
                [self updateDataHeaderStatus:macAddress];
                success(macAddress);
                //}
            }
        }
    } failure:failure];
    return self.operation;
}


- (NSOperation *)syncDeviceEntityWithParametersAPIV2:(NSDictionary *)parameters
                                    withSuccess:(void (^)(NSString *macAddress))success
                                        failure:(void (^)(NSError *error))failure
{
    SFAServerManager *serverManager                 = [SFAServerManager sharedManager];
    self.operation = [serverManager postRequestWithRefreshAccessTokenToURL:API_STORE_URL_V2 parameters:parameters success:^(NSDictionary *response) {
        DDLogError(@"response - %@", response);
        if (![self.operation isCancelled]) {
            //NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
            //NSString *macAddress = [result objectForKey:API_SYNC_MAC_ADDRESS];
            
            //NSString *message = [response objectForKey:@"message"];
            //int status = [response objectForKey:@"status"];
            if (success) {
                //if (status == 202) {
                NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
                NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
                
                [self updateDataHeaderStatus:macAddress];
                success(macAddress);
                //}
            }
        }
    } failure:failure];
    DDLogError(@"operation - %@", self.operation);
    
    return self.operation;
}




- (NSOperation *)syncDeviceEntity:(DeviceEntity *)deviceEntity
						startDate:(NSDate *)startDate
						  endDate:(NSDate *)endDate
					  withSuccess:(void (^)(NSString *macAddress))success
						  failure:(void (^)(NSError *error))failure
{
    BOOL shouldSyncWithDate = NO; //(startDate == nil || endDate == nil) ? NO: YES;
	
	SFAServerManager *serverManager                 = [SFAServerManager sharedManager];
	SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
	
	NSMutableDictionary *parameters					= [@{API_OAUTH_ACCESS_TOKEN : serverAccountManager.accessToken,
														API_SYNC_DATA          : [self jsonStringWithDeviceEntityWithSpecificDate:deviceEntity]} mutableCopy];

	if (shouldSyncWithDate) {
		[parameters setObject:startDate forKey:API_SYNC_START_DATE];
		[parameters setObject:endDate forKey:API_SYNC_END_DATE];
	}
	
	/*NSOperation *operation = [serverManager postRequestWithRefreshAccessTokenToURL:shouldSyncWithDate ? API_SYNC_URL: API_SYNC_URL parameters:parameters success:^(NSDictionary *response) {
		NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
		NSString *macAddress = [result objectForKey:API_SYNC_MAC_ADDRESS];
		
		if (success) {
			success(macAddress);
		}
	} failure:failure];*/
    //if (deviceEntity.modelNumber.integerValue == WatchModel_R420) {
        self.operation = [serverManager postRequestWithRefreshAccessTokenToURL:shouldSyncWithDate ? API_SYNC_URL_V2: API_SYNC_URL_V2 parameters:parameters success:^(NSDictionary *response) {
            if (![self.operation isCancelled]) {
                NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
                NSString *macAddress = [result objectForKey:API_SYNC_MAC_ADDRESS];
                
                if (success) {
                    success(macAddress);
                }
            }
        } failure:failure];
//    }
//    else{
//        self.operation = [serverManager postRequestWithRefreshAccessTokenToURL:shouldSyncWithDate ? API_SYNC_URL: API_SYNC_URL parameters:parameters success:^(NSDictionary *response) {
//            if (![self.operation isCancelled]) {
//                NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
//                NSString *macAddress = [result objectForKey:API_SYNC_MAC_ADDRESS];
//                
//                if (success) {
//                    success(macAddress);
//                }
//            }
//        } failure:failure];
//    }
    return self.operation;
}

- (NSOperation *)storeWithMacAddress:(NSString *)macAddress
                    success:(void (^)())success
                    failure:(void (^)(NSError *))failure
{
    SFAServerManager *serverManager                 = [SFAServerManager sharedManager];
    SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
    NSDictionary *parameters                        = @{API_SYNC_MAC_ADDRESS   : macAddress,
                                                        API_OAUTH_ACCESS_TOKEN : serverAccountManager.accessToken};
    
    /*NSOperation *operation = [serverManager postRequestWithRefreshAccessTokenToURL:API_STORE_URL parameters:parameters success:^(NSDictionary *response) {
        
        if ([[response objectForKey:@"result"] isEqualToString:API_WALGREENS_EXPIRED_TOKEN]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:WALGREENS_EXPIRED_TOKEN];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:WALGREENS_EXPIRED_TOKEN];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (success) {
            success();
        }
    } failure:failure];*/
    //__weak __block __typeof(self) weakSelf = self;
    
    self.operation = [serverManager postRequestWithRefreshAccessTokenToURL:API_STORE_URL parameters:parameters success:^(NSDictionary *response) {
        if (![self.operation isCancelled]) {
            if ([[response objectForKey:@"result"] isEqualToString:API_WALGREENS_EXPIRED_TOKEN]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:WALGREENS_EXPIRED_TOKEN];
            }
            else {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:WALGREENS_EXPIRED_TOKEN];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (success) {
                [self updateDataHeaderStatus:macAddress];
                
                success();
            }
        }
    } failure:failure];
    return self.operation;
}

- (void)deleteWithMacAddress:(NSString *)macAddress
                     success:(void (^)())success
                     failure:(void (^)(NSError *))failure
{
    SFAServerManager *serverManager                 = [SFAServerManager sharedManager];
    SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
    NSDictionary *parameters                        = @{API_SYNC_MAC_ADDRESS   : macAddress,
                                                        API_OAUTH_ACCESS_TOKEN : serverAccountManager.accessToken};
    
    [serverManager postRequestWithRefreshAccessTokenToURL:API_DELETE_DEVICE parameters:parameters success:^(NSDictionary *response) {
        if (success) {
            success();
        }
    } failure:failure];
}

- (void)getDevicesWithSuccess:(void (^)(NSArray *deviceEntities))success
                      failure:(void (^)(NSError *error))failure
{
    SFAServerManager *serverManager                 = [SFAServerManager sharedManager];
    SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
    NSDictionary *parameters                        = @{API_OAUTH_ACCESS_TOKEN : serverAccountManager.accessToken};
    
    [serverManager getRequestWithRefreshAccessTokenToURL:API_DEVICES_URL parameters:parameters success:^(NSDictionary *response) {
        NSArray *array          = [response objectForKey:API_RESULT];
        NSArray *deviceEntites  = [DeviceEntity deviceEntitesForArray:array];
        
        [serverAccountManager.user addDevice:[NSSet setWithArray:deviceEntites]];
        [[JDACoreData sharedManager] save];
        
        if (success) {
            success(deviceEntites);
        }
    } failure:failure];
}

- (void)restoreDeviceEntity:(DeviceEntity *)deviceEntity
				  startDate:(NSDate *)startDate
					endDate:(NSDate *)endDate
					success:(void (^)())success
					failure:(void (^)(NSError *))failure

{
    BOOL shouldSyncWithDate = YES;//NO; //(startDate == nil || endDate == nil) ? NO: YES;
	
	SFAServerManager *serverManager                 = [SFAServerManager sharedManager];
	SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];

	NSMutableDictionary *parameters					= [@{API_OAUTH_ACCESS_TOKEN : serverAccountManager.accessToken,
														 API_SYNC_DATA          : [self jsonStringWithDeviceEntity:deviceEntity]} mutableCopy];
	
	if (shouldSyncWithDate) {
		[parameters setObject:[NSDate dateToString:startDate withFormat:API_DATE_FORMAT] forKey:API_SYNC_START_DATE];
		[parameters setObject:[NSDate dateToString:endDate withFormat:API_DATE_FORMAT] forKey:API_SYNC_END_DATE];
	}
    
    NSString *restoreURL = API_RESTORE_URL_V2;//(deviceEntity.modelNumber.integerValue == WatchModel_R420) ? API_RESTORE_URL_V2 : API_RESTORE_URL;
	
	[serverManager getRequestWithRefreshAccessTokenToURL:shouldSyncWithDate? restoreURL: restoreURL parameters:parameters success:^(NSDictionary *response) {
		NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
		
		[self convertResult:result forDeviceEntity:deviceEntity];
		
		if (success) {
			success();
		}
	} failure:failure];
	
}


- (void)restoreDeviceEntity:(DeviceEntity *)deviceEntity
                    success:(void (^)())success
                    failure:(void (^)(NSError *error))failure
{
    SFAServerManager *serverManager                 = [SFAServerManager sharedManager];
    SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
    NSDictionary *parameters                        = @{API_SYNC_MAC_ADDRESS   : deviceEntity.macAddress,
                                                        API_OAUTH_ACCESS_TOKEN : serverAccountManager.accessToken};
    
    NSString *restoreURL = API_RESTORE_URL_V2;//(deviceEntity.modelNumber.integerValue == WatchModel_R420) ? API_RESTORE_URL_V2 : API_RESTORE_URL;
    
    [serverManager getRequestWithRefreshAccessTokenToURL:restoreURL parameters:parameters success:^(NSDictionary *response) {
        NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
        
        [self convertResult:result forDeviceEntity:deviceEntity];
        
        if (success) {
            success();
        }
    } failure:failure];
}

- (void)restoreDeviceEntity:(DeviceEntity *)deviceEntity
            startDateString:(NSString *)startDate
              endDateString:(NSString *)endDate
                    success:(void (^)())success
                    failure:(void (^)(NSError *error))failure
{
    SFAServerManager *serverManager                 = [SFAServerManager sharedManager];
    SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
    NSDictionary *parameters                        = @{API_SYNC_MAC_ADDRESS   : deviceEntity.macAddress,
                                                        API_OAUTH_ACCESS_TOKEN : serverAccountManager.accessToken};
    NSString *restoreURL = API_RESTORE_URL_V2;//(deviceEntity.modelNumber.integerValue == WatchModel_R420) ? API_RESTORE_URL_V2 : API_RESTORE_URL;
    NSString *urlWithStartAndEndDate = [NSString stringWithFormat:@"%@/%@/%@", restoreURL, startDate, endDate];
    [serverManager getRequestWithRefreshAccessTokenToURL:urlWithStartAndEndDate parameters:parameters success:^(NSDictionary *response) {
        NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
        
        //[self convertResultWithoutSettings:result forDeviceEntity:deviceEntity];
        [self convertResult:result forDeviceEntity:deviceEntity];
        
        if (success) {
            success();
        }
    } failure:failure];
}

- (void)getDeviceDataFromServerWithDevice:(DeviceEntity *)deviceEntity
            userID:(NSString *)startDate
                    success:(void (^)(BOOL shouldRestoreFromServer))success
                    failure:(void (^)(NSError *error))failure
{
    SFAServerManager *serverManager                 = [SFAServerManager sharedManager];
    SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
    NSDictionary *parameters                        = @{API_SYNC_MAC_ADDRESS   : deviceEntity.macAddress,
                                                        API_OAUTH_ACCESS_TOKEN : serverAccountManager.accessToken};;
    NSString *urlWithUserID = [NSString stringWithFormat:@"%@/%@/%@", API_DEVICE_DATA_URL, deviceEntity.user.userID, deviceEntity.macAddress];
    [serverManager getRequestWithRefreshAccessTokenToURL:urlWithUserID parameters:parameters success:^(NSDictionary *response) {
        NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
        NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateFormatter.timeZone  = [NSTimeZone localTimeZone];
        
        NSDate *date                    = [dateFormatter dateFromString:[result objectForKey:API_SYNC_LAST_DATE_SYNCED]];
        
        DDLogInfo(@"cloudSyncedDate - %@", date);
        
        BOOL shouldRestoreFromServer = YES;
        
        if (date) {
            deviceEntity.updatedSynced = date;
            if ([self isLateOrEqualForDates:deviceEntity.lastDateSynced andDate:date]) {
                shouldRestoreFromServer = NO;
            }
        }
        else{
            shouldRestoreFromServer = NO;
        }
        if (success) {
            success(shouldRestoreFromServer);
        }
    } failure:failure];
}

- (BOOL)isLateOrEqualForDates:(NSDate *)date1 andDate:(NSDate *)date2
{
    
    if ([date1 isEqualToDate:date2] || [date1 compare:date2] == NSOrderedDescending) {
        return YES;
    }
    return NO;
}


- (void)syncingToHealthKitFinished{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //});
        //
    [SFAHealthKitManager sharedManager].delegate = nil;
    [[SFAHealthKitManager sharedManager] saveAllDataToHealthStoreFromDataHeaders:self.dataForHealthStore];
    });
}

- (void)cancelOperation
{
    if (self.operation) {
        [self.operation cancel];
    }
}

- (void)updateDataHeaderStatus: (NSString *)macAddress
{
    UserEntity *user = [SFAServerAccountManager sharedManager].user;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"device.macAddress == %@ and isSyncedToServer == %@ and device.user == %@" argumentArray:[NSArray arrayWithObjects:macAddress, [NSNumber numberWithBool:NO], user, nil]];
    
    NSArray *dataHeaders = [[JDACoreData sharedManager] fetchEntityWithEntityName:STATISTICAL_DATA_HEADER_ENTITY predicate:predicate];
    
    for (StatisticalDataHeaderEntity *dataHeader in dataHeaders) {
        dataHeader.isSyncedToServer = [NSNumber numberWithBool:YES];
    }
    
    [[JDACoreData sharedManager] save];
}


//Restore functions for R420 S3
- (void)restoreDeviceEntityAPIV2:(DeviceEntity *)deviceEntity
                    success:(void (^)(NSDictionary *response))success
                    failure:(void (^)(NSError *error))failure
{
    SFAServerManager *serverManager                 = [SFAServerManager sharedManager];
    SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
    NSDictionary *parameters                        = @{API_SYNC_MAC_ADDRESS   : deviceEntity.macAddress,
                                                        API_OAUTH_ACCESS_TOKEN : serverAccountManager.accessToken};
    
    NSString *restoreURL = API_RESTORE_URL_V2;//(deviceEntity.modelNumber.integerValue == WatchModel_R420) ? API_RESTORE_URL_V2 : API_RESTORE_URL;
    
    [serverManager getRequestWithRefreshAccessTokenToURL:restoreURL parameters:parameters success:^(NSDictionary *response) {
        //NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
        
        //[self convertResult:result forDeviceEntity:deviceEntity];
        
        DDLogInfo(@"%@", response);
        if (success) {
            success(response[API_SYNC_RESULT]);
        }
    } failure:failure];
}

- (void)restoreDeviceEntityAPIV2:(DeviceEntity *)deviceEntity
            startDateString:(NSString *)startDate
              endDateString:(NSString *)endDate
                    success:(void (^)(NSDictionary *response))success
                    failure:(void (^)(NSError *error))failure
{
    SFAServerManager *serverManager                 = [SFAServerManager sharedManager];
    SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
    NSDictionary *parameters                        = @{API_SYNC_MAC_ADDRESS   : deviceEntity.macAddress,
                                                        API_OAUTH_ACCESS_TOKEN : serverAccountManager.accessToken};
    NSString *restoreURL = API_RESTORE_URL_V2;//(deviceEntity.modelNumber.integerValue == WatchModel_R420) ? API_RESTORE_URL_V2 : API_RESTORE_URL;
    NSString *urlWithStartAndEndDate = [NSString stringWithFormat:@"%@/%@/%@", restoreURL, startDate, endDate];
    [serverManager getRequestWithRefreshAccessTokenToURL:urlWithStartAndEndDate parameters:parameters success:^(NSDictionary *response) {
        //NSDictionary *result = [response objectForKey:API_SYNC_RESULT];
        
        //[self convertResultWithoutSettings:result forDeviceEntity:deviceEntity];
        //[self convertResult:result forDeviceEntity:deviceEntity];
        DDLogInfo(@"%@", response);
        if (success) {
            success(response[API_SYNC_RESULT]);
        }
    } failure:failure];
}

@end
