//
//  SFASalutronSaveData.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 7/18/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronSaveData.h"
#import "SFASalutronSync+Utilities.h"

#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "StatisticalDataHeaderEntity+Data.h"
#import "DeviceEntity.h"
#import "WorkoutInfo.h"
#import "WorkoutStopDatabase.h"
#import "WorkoutInfoEntity+Data.h"
#import "WorkoutStopDatabaseEntity+Data.h"
#import "SleepDatabase.h"
#import "SleepDatabaseEntity+SleepDatabaseEntityCategory.h"
#import "LightDataPoint.h"
#import "LightDataPointEntity+Data.h"
#import "InactiveAlertEntity+Data.h"
#import "DayLightAlertEntity+Data.h"
#import "NightLightAlertEntity+Data.h"
#import "WakeupEntity+Data.h"
#import "SFAGoalsData.h"
#import "GoalsEntity+Data.h"
#import "SleepSettingEntity+Data.h"
#import "TimeDateEntity+Data.h"
#import "UserProfileEntity+Data.h"
#import "TimingEntity+Data.h"
#import "NotificationEntity+Data.h"
#import "CalibrationDataEntity+Data.h"
#import "JDACoreData.h"
#import "SFASalutronSync+Utilities.h"

#import "InactiveAlert+Coding.h"
#import "DayLightAlert+Coding.h"
#import "NightLightAlert+Coding.h"
#import "TimeDate+Encoder.h"

#import <HealthKit/HealthKit.h>
#import "SFAHealthKitManager.h"
#import "HKUnit+Custom.h"
#import "DateEntity.h"
#import "WorkoutSettingEntity+CoreDataProperties.h"
#import "WorkoutHeaderEntity+CoreDataProperties.h"
#import "WorkoutRecordEntity+CoreDataProperties.h"
#import "WorkoutHeartRateDataEntity+CoreDataProperties.h"
#import "DynamicWorkoutInfo.h"

@interface SFASalutronSaveData () <SFAHealthKitManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext    *managedObjectContext;
@property (strong, nonatomic) SFAUserDefaultsManager    *userDefaultsManager;
@property (strong, nonatomic) SalutronSDK               *salutronSDK;
@property (strong, nonatomic) SFASalutronLibrary        *salutronLibrary;
@property (strong, nonatomic) DeviceEntity              *deviceEntity;
@property (strong, nonatomic) SFASalutronSync          *salutronSync;

@end

@implementation SFASalutronSaveData

- (SFASalutronSync *)salutronSync
{
    if (!_salutronSync) {
        _salutronSync = [[SFASalutronSync alloc] init];
    }
    return _salutronSync;
}

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

- (SalutronSDK *)salutronSDK
{
    if (!_salutronSDK) {
        _salutronSDK = [SalutronSDK sharedInstance];
    }
    return _salutronSDK;
}

- (SFASalutronLibrary *)salutronLibrary
{
    if (!_salutronLibrary) {
        _salutronLibrary = [[SFASalutronLibrary alloc] initWithManagedObjectContext:[JDACoreData sharedManager].context];
    }
    return _salutronLibrary;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        _managedObjectContext = [JDACoreData sharedManager].context;
    }
    return _managedObjectContext;
}

#pragma mark - Save

- (Status)saveMacAddress
{
    NSString *macAddress                = nil;
    Status status = [self.salutronSDK getMacAddress:&macAddress];
    if (macAddress != nil) {
        self.userDefaultsManager.macAddress = macAddress;
    }
    DDLogInfo(@" ---> %@", self.userDefaultsManager.macAddress);
    return status;
}

- (Status)saveFirmwareVersion
{
    NSString *firmwareVersion                   = nil;
    Status status = [self.salutronSDK getFirmwareRevision:&firmwareVersion];
    self.userDefaultsManager.firmwareRevision   = firmwareVersion;
    DDLogInfo(@" ---> %@", self.userDefaultsManager.firmwareRevision);
    return status;
}

- (Status)saveSoftwareVersion
{
    NSString *softwareRevision                  = nil;
    Status status = [self.salutronSDK getSoftwareRevision:&softwareRevision];
    self.userDefaultsManager.softwareRevision   = softwareRevision;
    DDLogInfo(@" ---> %@", self.userDefaultsManager.softwareRevision);
    return status;
}

- (void)saveDeviceEntityWithDeviceDetail:(DeviceDetail *)deviceDetail
{
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    self.managedObjectContext.undoManager = undoManager;
    [undoManager beginUndoGrouping];
    
    if(self.deviceEntity == nil) {
        WatchModel watchModel = WatchModel_R450;
        NSString *deviceId = [NSString stringWithFormat:@"%@", deviceDetail.deviceID];
        
        if ([deviceId isEqualToString:WatchModel_R420_DeviceId]) {
            watchModel = WatchModel_R420;
        }
        
        self.deviceEntity = [self.salutronLibrary newDeviceEntityWithUUID:deviceDetail.peripheral.identifier.UUIDString
                                                                     name:deviceDetail.peripheral.name
                                                               macAddress:self.userDefaultsManager.macAddress
                                                        modelNumberString:deviceDetail.peripheral.identifier.UUIDString
                                                           modelNumberInt:[NSNumber numberWithInt:watchModel]];
    } else {
        self.deviceEntity.uuid = deviceDetail.peripheral.identifier.UUIDString;
    }
    
    self.userDefaultsManager.deviceUUID = self.deviceEntity.uuid;
    
    NSError *error = nil;
    [self.salutronLibrary saveChanges:&error];
}

- (void)saveStatisticalDataHeaders:(NSArray *)statisticalDataHeaders dataHeaderEntityArray:(NSMutableArray *__autoreleasing *)dataHeaderEntityArray
{
    if (statisticalDataHeaders == nil) {
        return;
    }
    
    NSMutableArray *dataHeaderEntities = [[NSMutableArray alloc] init];
    
    NSUInteger headerIndex = 0;
    
    for (StatisticalDataHeader *statisticalDataHeader in statisticalDataHeaders) {
        
        StatisticalDataHeaderEntity *statisticalDataHeaderEntity = nil;
        
        if(![self.salutronLibrary isStatisticalDataHeaderExists:statisticalDataHeader entity:&statisticalDataHeaderEntity]) {
            // Insert
            statisticalDataHeaderEntity = [StatisticalDataHeaderEntity
                                           statisticalForInsertDataHeader:statisticalDataHeader
                                           inManagedObjectContext:self.managedObjectContext];
            [self.deviceEntity addHeaderObject:statisticalDataHeaderEntity];
            [dataHeaderEntities addObject:statisticalDataHeaderEntity];
        }
        else {
            // Update
            
            /*if([self.salutronLibrary isStatisticalDataHeaderUpdated:statisticalDataHeader entity:statisticalDataHeaderEntity]) {
                
            }*/
            
            [StatisticalDataHeaderEntity updateEntityWithStatisticalDataHeader:statisticalDataHeader
                                                                        entity:statisticalDataHeaderEntity
                                                        inManagedObjectContext:self.managedObjectContext];
            [dataHeaderEntities addObject:statisticalDataHeaderEntity];
        }
        
        headerIndex++;
    }
    
    *dataHeaderEntityArray = dataHeaderEntities;
}

- (void)saveDatapoints:(NSArray *)dataPointsArray lightDataPoints:(NSArray *)lightDataPointsArray statisticalDataHeaderEntity:(NSArray *)statisticalDataHeaderEntityArray
{
    NSMutableArray *dataPointEntities = [[NSMutableArray alloc] init];
    NSMutableArray *lightDataPointEntities = [[NSMutableArray alloc] init];
	
	if (dataPointsArray.count == 0) {
		return;
	}

    DDLogInfo(@"dataPointsArray count: %d lightDataPointsArray: %d", dataPointsArray.count, lightDataPointsArray.count);
    for (StatisticalDataHeaderEntity *statisticalDataHeaderEntity in statisticalDataHeaderEntityArray) {
        NSInteger headerIndex = [statisticalDataHeaderEntityArray indexOfObject:statisticalDataHeaderEntity];
        DDLogInfo(@"candidate headerIndex = %d", headerIndex);
        
        int i = 0;
        if (headerIndex < dataPointsArray.count || headerIndex < lightDataPointsArray.count) {
            if (headerIndex >= dataPointsArray.count) {
                headerIndex = dataPointsArray.count - 1;
            }
            DDLogInfo(@"actual headerIndex = %d", headerIndex);
            for(StatisticalDataPoint *dataPoint in dataPointsArray[headerIndex]) {
                NSInteger dataPointIndex = [dataPointsArray[headerIndex] indexOfObject:dataPoint];
                
                if (dataPointIndex >= statisticalDataHeaderEntity.dataPoint.count) {
                    StatisticalDataPointEntity *statisticalDataPointEntity = nil;
                    statisticalDataPointEntity = [StatisticalDataPointEntity
                                                  statisticalForInsertDataPoint:dataPoint
                                                  index:dataPointIndex
                                                  inManagedObjectContext:self.managedObjectContext];
                    
                    [dataPointEntities addObject:statisticalDataPointEntity];
                    
                    NSArray *lightDataPoints = lightDataPointsArray[headerIndex];
                    if (i < lightDataPoints.count) {
                        LightDataPoint *lightDataPoint = lightDataPoints[i];
                        LightDataPointEntity *lightDataPointEntity = nil;
                        
                        lightDataPointEntity = [LightDataPointEntity
                                                insertLightDataPoint:lightDataPoint statisticalDataPointEntity:statisticalDataPointEntity
                                                index:dataPointIndex
                                                inManagedObjectContext:self.managedObjectContext];
                        
                        [lightDataPointEntities addObject:lightDataPointEntity];
                        
                        statisticalDataPointEntity.lightDataPoint = lightDataPointEntity;
                    }
                } else if (dataPointIndex == statisticalDataHeaderEntity.dataPoint.count - 1) {
                    NSArray *lightDataPoints = lightDataPointsArray[headerIndex];
                    
                    if (self.userDefaultsManager.watchModel == WatchModel_R450) {
                        if (i < lightDataPoints.count) {
                            LightDataPoint *lightDataPoint = lightDataPoints[i];
                            for (LightDataPointEntity *dataPointEntity in statisticalDataHeaderEntity.lightDataPoint) {
                                
                                if (dataPointEntity.dataPointID.integerValue == dataPointIndex) {
                                    StatisticalDataPointEntity *sdp = [StatisticalDataPointEntity dataPointEntityWithDataPoint:dataPoint
                                                                                                               dataPointEntity:dataPointEntity.dataPoint];
                                    [LightDataPointEntity updateLightDataPointEntityWithDataPoint:lightDataPoint statisticalDataPointEntity:sdp dataPointEntity:dataPointEntity];
                                }
                            }
                        }
                    } else if (self.userDefaultsManager.watchModel == WatchModel_R420) {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dataPointID == %i", dataPointIndex];
                        NSSet *filteredDataPoints = [statisticalDataHeaderEntity.dataPoint filteredSetUsingPredicate:predicate];
                        
                        for (StatisticalDataPointEntity *sdp in filteredDataPoints) {
                            [StatisticalDataPointEntity dataPointEntityWithDataPoint:dataPoint dataPointEntity:sdp];
                        }
                    }
                }
                i++;
            }
            
            [statisticalDataHeaderEntity addDataPoint:[NSSet setWithArray:dataPointEntities.copy]];
            statisticalDataHeaderEntity.isSyncedToServer = [NSNumber numberWithBool:NO];
            [dataPointEntities removeAllObjects];
            
            [statisticalDataHeaderEntity addLightDataPoint:[NSSet setWithArray:lightDataPointEntities.copy]];
            [lightDataPointEntities removeAllObjects];
        }
    }
}

//- (void)saveDatapoints:(NSArray *)dataPointsArray statisticalDataHeaderEntity:(NSArray *)statisticalDataHeaderEntityArray
//{
//    NSMutableArray *dataPointEntities = [[NSMutableArray alloc] init];
//    
//    CGFloat dpTotalCalories = 0.0f;
//    
//    for (StatisticalDataHeaderEntity *statisticalDataHeaderEntity in statisticalDataHeaderEntityArray) {
//        
//        NSInteger headerIndex = [statisticalDataHeaderEntityArray indexOfObject:statisticalDataHeaderEntity];
//        for(StatisticalDataPoint *dataPoint in dataPointsArray[headerIndex]) {
//            
//            NSInteger dataPointIndex = [dataPointsArray[headerIndex] indexOfObject:dataPoint];
//            if(dataPointIndex >= statisticalDataHeaderEntity.dataPoint.count) {
//                StatisticalDataPointEntity *statisticalDataPointEntity = nil;
//                statisticalDataPointEntity = [StatisticalDataPointEntity
//                                              statisticalForInsertDataPoint:dataPoint
//                                              index:dataPointIndex
//                                              inManagedObjectContext:self.managedObjectContext];
//                [dataPointEntities addObject:statisticalDataPointEntity];
//            } else if (dataPointIndex == statisticalDataHeaderEntity.dataPoint.count - 1) {
//                for (StatisticalDataPointEntity *dataPointEntity in statisticalDataHeaderEntity.dataPoint) {
//                    if (dataPointEntity.dataPointID.integerValue == dataPointIndex) {
//                        [StatisticalDataPointEntity dataPointEntityWithDataPoint:dataPoint
//                                                                 dataPointEntity:dataPointEntity];
//                    }
//                }
//            }
//            
//            dpTotalCalories += dataPoint.calorie;
//        }
//        [statisticalDataHeaderEntity addDataPoint:[NSSet setWithArray:dataPointEntities.copy]];
//        [dataPointEntities removeAllObjects];
//    }
//}

#pragma mark - Light

//- (void)saveLightDatapoints:(NSArray *)lightDataPointsArray statisticalDataHeaderEntity:(NSArray *)statisticalDataHeaderEntityArray
//{
//    NSMutableArray *lightDataPointEntities = [[NSMutableArray alloc] init];
//    
//    for (StatisticalDataHeaderEntity *statisticalDataHeaderEntity in statisticalDataHeaderEntityArray) {
//        
//        NSInteger headerIndex = [statisticalDataHeaderEntityArray indexOfObject:statisticalDataHeaderEntity];
//        
//        for(LightDataPoint *dataPoint in lightDataPointsArray[headerIndex]) {
//            
//            NSInteger dataPointIndex = [lightDataPointsArray[headerIndex] indexOfObject:dataPoint];
//           
//            if(dataPointIndex >= statisticalDataHeaderEntity.lightDataPoint.count) {
//                LightDataPointEntity *lightDataPointEntity = nil;
//                
//                lightDataPointEntity = [LightDataPointEntity
//                                              insertLightDataPoint:dataPoint
//                                                index:dataPointIndex
//                                              inManagedObjectContext:self.managedObjectContext];
//                [lightDataPointEntities addObject:lightDataPointEntity];
//                
//            } else if (dataPointIndex == statisticalDataHeaderEntity.lightDataPoint.count - 1) {
//                for (LightDataPointEntity *dataPointEntity in statisticalDataHeaderEntity.lightDataPoint) {
//                    if (dataPointEntity.dataPointID.integerValue == dataPointIndex) {
//                        [LightDataPointEntity updateLightDataPointEntityWithDataPoint:dataPoint dataPointEntity:dataPointEntity];
//                    }
//                }
//            }
//        }
//        [statisticalDataHeaderEntity addLightDataPoint:[NSSet setWithArray:lightDataPointEntities.copy]];
//        [lightDataPointEntities removeAllObjects];
//    }
//}

- (void)saveInactiveAlertArray:(NSArray *)inactiveAlertArray inactiveAlert:(InactiveAlert *__autoreleasing *)inactiveAlert
{
    InactiveAlert *newInactiveAlert = [[InactiveAlert alloc] init];
    
    // 0 - Status 1 - Time Duration 2 - Steps Threshold 3 - Start Time 4 - End Time
    for (InactiveAlert *alert in inactiveAlertArray){
        switch (alert.type) {
            case 0:
                newInactiveAlert.status = alert.status;
                break;
            case 1:
                newInactiveAlert.time_duration = alert.time_duration;
                break;
            case 2:
                newInactiveAlert.steps_threshold = alert.steps_threshold;
                break;
            case 3:
                newInactiveAlert.start_min = alert.start_min;
                newInactiveAlert.start_hour = alert.start_hour;
                break;
            case 4:
                newInactiveAlert.end_hour = alert.end_hour;
                newInactiveAlert.end_min = alert.end_min;
                break;
            default:
                break;
        }
    }
    
    *inactiveAlert = newInactiveAlert;
    [InactiveAlertEntity inactiveAlertWithInactiveAlert:newInactiveAlert forDeviceEntity:self.deviceEntity];
}

- (void)saveDayLightAlertArray:(NSArray *)dayLightAlertArray dayLightAlert:(DayLightAlert *__autoreleasing *)dayLightAlert
{
    DayLightAlert *newDayLightAlert = [[DayLightAlert alloc] init];
    
    // 0 - Status 1 - level 2 - duration 3 - Start Time 4 - End Time 5 - interval
    for (DayLightAlert *alert in dayLightAlertArray){
        switch (alert.type) {
            case 0:
                newDayLightAlert.status = alert.status;
                break;
            case 1:
                newDayLightAlert.level = alert.level;
                break;
            case 2:
                newDayLightAlert.duration = alert.duration;
                break;
            case 3:
                newDayLightAlert.start_min = alert.start_min;
                newDayLightAlert.start_hour = alert.start_hour;
                break;
            case 4:
                newDayLightAlert.end_hour = alert.end_hour;
                newDayLightAlert.end_min = alert.end_min;
                break;
            case 5:
                newDayLightAlert.interval = alert.interval;
                break;
            default:
                break;
        }
    }
    
    *dayLightAlert = newDayLightAlert;
    [DayLightAlertEntity dayLightAlertWithDayLightAlert:newDayLightAlert forDeviceEntity:self.deviceEntity];
}

- (void)saveNightLightAlertArray:(NSArray *)nightLightAlertArray nightLightAlert:(NightLightAlert *__autoreleasing *)nightLightAlert
{
    NightLightAlert *newNightLightAlert = [[NightLightAlert alloc] init];
    
    // 0 - Status 1 - level 2 - duration 3 - Start Time 4 - End Time
    for (NightLightAlert *alert in nightLightAlertArray){
        switch (alert.type) {
            case 0:
                newNightLightAlert.status = alert.status;
                break;
            case 1:
                newNightLightAlert.level = alert.level;
                break;
            case 2:
                newNightLightAlert.duration = alert.duration;
                break;
            case 3:
                newNightLightAlert.start_min = alert.start_min;
                newNightLightAlert.start_hour = alert.start_hour;
                break;
            case 4:
                newNightLightAlert.end_hour = alert.end_hour;
                newNightLightAlert.end_min = alert.end_min;
                break;
            default:
                break;
        }
    }
    
    *nightLightAlert = newNightLightAlert;
    [NightLightAlertEntity nightLightAlertWithNightLightAlert:newNightLightAlert forDeviceEntity:self.deviceEntity];
}

- (void)saveWakeupAlertArray:(NSArray *)wakeupAlertSetting wakeupAlert:(Wakeup *__autoreleasing *)wakeupAlert
{
    WakeupEntity *wakeupEntity = nil;
    WakeupEntity *newWakeUpEntity = nil;
    
    Wakeup *wakeupValue = [[Wakeup alloc] init];
    
    for (int i = 0; i < wakeupAlertSetting.count; i++) {
        
        Wakeup *wakeup = wakeupAlertSetting[i];
        
        switch (i) {
            case 0: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.userDefaultsManager.macAddress
                                             wakeupMode:@(wakeup.wakeup_mode)
                                             wakeupHour:@0
                                           wakeupMinute:@0
                                           wakeupWindow:@0
                                             snoozeMode:@0
                                              snoozeMin:@0
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&newWakeUpEntity];
                wakeupEntity = newWakeUpEntity;
                wakeupValue.wakeup_mode = wakeup.wakeup_mode;
                break;
            }
            case 1: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.userDefaultsManager.macAddress
                                             wakeupMode:wakeupEntity.wakeupMode
                                             wakeupHour:@(wakeup.wakeup_hr)
                                           wakeupMinute:@(wakeup.wakeup_min)
                                           wakeupWindow:@0
                                             snoozeMode:@0
                                              snoozeMin:@0
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&newWakeUpEntity];
                wakeupEntity = newWakeUpEntity;
                wakeupValue.wakeup_hr = wakeup.wakeup_hr;
                wakeupValue.wakeup_min = wakeup.wakeup_min;
                break;
            }
            case 2: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.userDefaultsManager.macAddress
                                             wakeupMode:wakeupEntity.wakeupMode
                                             wakeupHour:wakeupEntity.wakeupHour
                                           wakeupMinute:wakeupEntity.wakeupMinute
                                           wakeupWindow:@(wakeup.wakeup_window)
                                             snoozeMode:@0
                                              snoozeMin:@0
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&newWakeUpEntity];
                wakeupEntity = newWakeUpEntity;
                wakeupValue.wakeup_window = wakeup.wakeup_window;
                break;
            }
            case 3: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.userDefaultsManager.macAddress
                                             wakeupMode:wakeupEntity.wakeupMode
                                             wakeupHour:wakeupEntity.wakeupHour
                                           wakeupMinute:wakeupEntity.wakeupMinute
                                           wakeupWindow:wakeupEntity.wakeupWindow
                                             snoozeMode:@(wakeup.snooze_mode)
                                              snoozeMin:@0
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&newWakeUpEntity];
                wakeupEntity = newWakeUpEntity;
                wakeupValue.snooze_mode = wakeup.snooze_mode;
                break;
            }
            case 4: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.userDefaultsManager.macAddress
                                             wakeupMode:wakeupEntity.wakeupMode
                                             wakeupHour:wakeupEntity.wakeupHour
                                           wakeupMinute:wakeupEntity.wakeupMinute
                                           wakeupWindow:wakeupEntity.wakeupWindow
                                             snoozeMode:wakeupEntity.snoozeMode
                                              snoozeMin:@(wakeup.snooze_min)
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&newWakeUpEntity];
                wakeupEntity = newWakeUpEntity;
                wakeupValue.snooze_min = wakeup.snooze_min;
                break;
            }
            default:
                break;
        }
    }
    
    *wakeupAlert = wakeupValue;
}

#pragma mark - Workout database

- (void)saveWorkoutDatabase:(NSArray *)workoutDatabase workoutStopDatabase:(NSDictionary *)workoutstopdatabase
{
    NSMutableArray *workoutInfoEntities = [[NSMutableArray alloc] init];
    
    DDLogInfo(@"Workout db: %@ | Workout stop db", workoutDatabase , workoutstopdatabase);
    for (WorkoutInfo *workoutInfo in workoutDatabase) {
        WorkoutInfoEntity *workoutInfoEntity = [WorkoutInfoEntity
                                                insertWorkoutInfoWithSteps:[NSNumber numberWithLong:workoutInfo.steps]
                                                distance:[NSNumber numberWithDouble:workoutInfo.distance]
                                                calories:[NSNumber numberWithDouble:workoutInfo.calories]
                                                minute:[NSNumber numberWithInteger:workoutInfo.minute]
                                                second:[NSNumber numberWithInteger:workoutInfo.second]
                                                hour:[NSNumber numberWithInteger:workoutInfo.hour]
                                                distanceUnitFlag:[NSNumber numberWithBool:workoutInfo.distance_unit_flag]
                                                hundredth:[NSNumber numberWithInteger:workoutInfo.hundredths]
                                                stampSecond:[NSNumber numberWithInteger:workoutInfo.stamp_second]
                                                stampMinute:[NSNumber numberWithInteger:workoutInfo.stamp_minute]
                                                stampHour:[NSNumber numberWithInteger:workoutInfo.stamp_hour]
                                                stampDay:[NSNumber numberWithInteger:workoutInfo.stamp_day]
                                                stampMonth:[NSNumber numberWithInteger:workoutInfo.stamp_month]
                                                stampYear:[NSNumber numberWithInteger:workoutInfo.stamp_year + DATE_YEAR_ADDER]
                                                workoutID:[NSNumber numberWithInteger:workoutInfo.workoutID]];
        workoutInfoEntity.isSyncedToServer = [NSNumber numberWithBool:NO];
        [workoutInfoEntities addObject:workoutInfoEntity];
        
        
        for (WorkoutStopDatabase *workoutStop in workoutstopdatabase[@(workoutInfo.workoutID)]) {
            NSInteger index = [workoutstopdatabase[@(workoutInfo.workoutID)] indexOfObject:workoutStop];
            
            [WorkoutStopDatabaseEntity workoutStopDatabaseEntityWithWorkoutStopDatabase:workoutStop
                                                               workoutStopDatabaseIndex:index
                                                                      workoutInfoEntity:workoutInfoEntity
                                                                   managedObjectContext:self.managedObjectContext];
        }
        
    }
    
    [self.deviceEntity addWorkout:[NSSet setWithArray:workoutInfoEntities]];
}

#pragma mark - Dynamic Workout database

- (void)saveDynamicWorkoutDatabase:(NSArray *)workoutDatabase
{
    NSMutableArray *workoutHeaderEntities = [[NSMutableArray alloc] init];
    
    
    for (DynamicWorkoutInfo *workoutInfo in workoutDatabase) {
        NSMutableOrderedSet<WorkoutHeartRateDataEntity *> *workoutHeartRateDataEntities = [[NSMutableOrderedSet<WorkoutHeartRateDataEntity *> alloc] init];
        WorkoutHeaderEntity *workoutHeaderEntity = [WorkoutHeaderEntity entityWithWorkoutHeader:workoutInfo.header];
        
        NSMutableArray *workoutRecordEntities = [[NSMutableArray alloc] init];
        
        for (WorkoutRecord *workoutRecord in workoutInfo.records) {
            WorkoutRecordEntity *workoutRecordEntity = [WorkoutRecordEntity entityWithWorkoutRecord:workoutRecord];
            [workoutRecordEntities addObject:workoutRecordEntity];
        }
        
        for (WorkoutStopDatabase *workoutStopDatabase in workoutInfo.stopDatabase) {
            NSInteger index = [workoutInfo.stopDatabase indexOfObject:workoutStopDatabase];
            
            [WorkoutStopDatabaseEntity entityWithWorkoutHeaderEntity:workoutHeaderEntity index:index workoutStopDatabase:workoutStopDatabase];
        }
        
        NSInteger index = 0;
        
        for (NSNumber *hrData in workoutInfo.hrData) {
            NSInteger hrValue = [hrData integerValue];
            
            NSInteger count = workoutHeaderEntity.workoutHeartRateData.count - 1;
            
            if (index > count) {
                WorkoutHeartRateDataEntity *workoutHeartRateDataEntity = [WorkoutHeartRateDataEntity entityWithHrData:hrValue index:index];
                [workoutHeartRateDataEntities addObject:workoutHeartRateDataEntity];
            }
            
            index++;
        }
        
        if (workoutRecordEntities.count > 0) {
            [workoutHeaderEntity addWorkoutRecord:[NSSet setWithArray:workoutRecordEntities]];
        }
        
        if (workoutHeartRateDataEntities.count > 0) {
            [workoutHeaderEntity addWorkoutHeartRateData:workoutHeartRateDataEntities];
        }
        
        [workoutHeaderEntities addObject:workoutHeaderEntity];
    }
    
    [self.deviceEntity addWorkoutHeader:[NSSet setWithArray:workoutHeaderEntities]];
}

#pragma mark - Sleep database

- (void)saveSleepDatabase:(NSArray *)sleepDatabaseArray
{
    NSMutableArray *sleepDatabases = [[NSMutableArray alloc] init];
    
    for(SleepDatabase *sleepDatabase in sleepDatabaseArray) {
        SleepDatabaseEntity *sleepDatabaseEntity = [SleepDatabaseEntity sleepDatabaseEntityWithRecord:sleepDatabase
                                                                                        managedObject:self.managedObjectContext];
        [sleepDatabases addObject:sleepDatabaseEntity];
    }
    
    [self.deviceEntity addSleepdatabase:[NSSet setWithArray:sleepDatabases]];
}

#pragma mark - Wake up

- (void)saveWakeUp:(NSArray *)wakeUpArray
{
    WakeupEntity *wakeupEntity = nil;
    WakeupEntity *newWakeUpEntity = nil;
    
    for (int i = 0; i < wakeUpArray.count; i++) {
        
        Wakeup *wakeup = wakeUpArray[i];
        
        switch (i) {
            case 0: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.userDefaultsManager.macAddress
                                             wakeupMode:@(wakeup.wakeup_mode)
                                             wakeupHour:@0
                                           wakeupMinute:@0
                                           wakeupWindow:@0
                                             snoozeMode:@0
                                              snoozeMin:@0
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&newWakeUpEntity];
                wakeupEntity = newWakeUpEntity;
                break;
            }
            case 1: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.userDefaultsManager.macAddress
                                             wakeupMode:wakeupEntity.wakeupMode
                                             wakeupHour:@(wakeup.wakeup_hr)
                                           wakeupMinute:@(wakeup.wakeup_min)
                                           wakeupWindow:@0
                                             snoozeMode:@0
                                              snoozeMin:@0
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&newWakeUpEntity];
                wakeupEntity = newWakeUpEntity;
                break;
            }
            case 2: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.userDefaultsManager.macAddress
                                             wakeupMode:wakeupEntity.wakeupMode
                                             wakeupHour:wakeupEntity.wakeupHour
                                           wakeupMinute:wakeupEntity.wakeupMinute
                                           wakeupWindow:@(wakeup.wakeup_window)
                                             snoozeMode:@0
                                              snoozeMin:@0
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&newWakeUpEntity];
                wakeupEntity = newWakeUpEntity;
                break;
            }
            case 3: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.userDefaultsManager.macAddress
                                             wakeupMode:wakeupEntity.wakeupMode
                                             wakeupHour:wakeupEntity.wakeupHour
                                           wakeupMinute:wakeupEntity.wakeupMinute
                                           wakeupWindow:wakeupEntity.wakeupWindow
                                             snoozeMode:@(wakeup.snooze_mode)
                                              snoozeMin:@0
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&newWakeUpEntity];
                wakeupEntity = newWakeUpEntity;
                break;
            }
            case 4: {
                [WakeupEntity addWakeupEntityWithDevice:self.deviceEntity
                                             macAddress:self.userDefaultsManager.macAddress
                                             wakeupMode:wakeupEntity.wakeupMode
                                             wakeupHour:wakeupEntity.wakeupHour
                                           wakeupMinute:wakeupEntity.wakeupMinute
                                           wakeupWindow:wakeupEntity.wakeupWindow
                                             snoozeMode:wakeupEntity.snoozeMode
                                              snoozeMin:@(wakeup.snooze_min)
                                          managedObject:self.managedObjectContext
                                           wakeupEntity:&newWakeUpEntity];
                wakeupEntity = newWakeUpEntity;
                break;
            }
            default:
                break;
        }
    }
}

- (void)saveGoalsWithStepGoal:(int)stepGoal distanceGoal:(double)distanceGoal calorieGoal:(int)calorieGoal sleepSettings:(SleepSetting *)sleepSetting
{
    NSInteger sleepGoal         = sleepSetting.sleep_goal_lo;
    sleepGoal                   += sleepSetting.sleep_goal_hi << 8;
    
    [SFAGoalsData addGoalsWithSteps:stepGoal
                           distance:distanceGoal
                           calories:calorieGoal
                              sleep:sleepGoal
                             device:self.deviceEntity
                      managedObject:self.managedObjectContext];
    
    [SleepSettingEntity sleepSettingWithSleepSetting:sleepSetting forDeviceEntity:self.deviceEntity];
}

- (void)saveNotification:(Notification *)notification notificationStatus:(BOOL)notificationStatus
{
    [NotificationEntity notificationWithNotification:notification notificationStatus:notificationStatus forDeviceEntity:self.deviceEntity];
}

- (void)saveTiming:(Timing *)timing
{
    [TimingEntity timingWithTiming:timing forDeviceEntity:self.deviceEntity];
}

- (void)saveCalibrationDataArray:(NSArray *)calibratonDataArray calibrationData:(CalibrationData *__autoreleasing *)calibrationData
{
    CalibrationData *newCalibrationData = [[CalibrationData alloc] init];
    
    for (int i = 0; i < [calibratonDataArray count]; i++) {
        
        CalibrationData *calibData = calibratonDataArray[i];
        
        switch (calibData.type) {
            case 0:
                newCalibrationData.calib_step = calibData.calib_step;
                break;
            case 1:
                newCalibrationData.calib_walk = calibData.calib_walk;
                break;
            case 2:
                newCalibrationData.calib_run = calibData.calib_run;
                break;
            case 3:
                newCalibrationData.autoEL = calibData.autoEL;
                break;
            case 4:
                newCalibrationData.calib_calo = calibData.calib_calo;
            default:
                break;
        }
    }
    
    *calibrationData = newCalibrationData;
    [CalibrationDataEntity calibrationDataWithCalibrationData:newCalibrationData forDeviceEntity:self.deviceEntity];
}

- (void)saveWorkoutSettingArray:(NSArray *)workoutSettingArray workoutSetting:(WorkoutSetting *__autoreleasing *)workoutSetting
{
    WorkoutSetting *newWorkoutSetting = [[WorkoutSetting alloc] init];
    
    for (WorkoutSetting *workoutSetting in workoutSettingArray) {
        switch (workoutSetting.type) {
            case 0:
                newWorkoutSetting.HRLogRate         = workoutSetting.HRLogRate;
                break;
            case 13:
                newWorkoutSetting.databaseUsage     = workoutSetting.databaseUsage;
                break;
            case 14:
                newWorkoutSetting.databaseUsageMax  = workoutSetting.databaseUsageMax;
                break;
            case 15:
                newWorkoutSetting.reconnectTimeout  = workoutSetting.reconnectTimeout;
                break;
            default:
                break;
        }
    }
    
    *workoutSetting = newWorkoutSetting;
    [WorkoutSettingEntity entityWithWorkoutSetting:newWorkoutSetting forDeviceEntity:self.deviceEntity];
}

- (void)saveTimeDate:(TimeDate *)timeDate
{
    TimeDate *newTimeDate = [[TimeDate alloc] initWithDate:[NSDate date]];
    newTimeDate.hourFormat = timeDate.hourFormat;
    newTimeDate.dateFormat = timeDate.dateFormat;
    newTimeDate.watchFace = timeDate.watchFace;
    
    self.userDefaultsManager.timeDate = newTimeDate;
    [TimeDateEntity timeDateWithTimeDate:newTimeDate forDeviceEntity:self.deviceEntity];
}

- (void)saveSalutronUserProfile:(SalutronUserProfile *)salutronUserProfile
{
    [UserProfileEntity userProfileWithSalutronUserProfile:salutronUserProfile forDeviceEntity:self.deviceEntity];
}

- (DeviceEntity *)saveWatchDataWithDeviceEntity:(DeviceEntity *)deviceEntity statisticalDataHeaders:(NSArray *)statisticalDataHeaders dataPoints:(NSArray *)dataPoints lightDataPoints:(NSArray *)lightDataPoints workoutDB:(NSArray *)workoutDatabase workoutStopDB:(NSDictionary *)workoutStopDatabase sleepDB:(NSArray *)sleepDatabase
{
    DDLogInfo(@"");
    self.deviceEntity = deviceEntity;
    
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    self.managedObjectContext.undoManager = undoManager;
    [undoManager beginUndoGrouping];
    
    NSMutableArray *dataHeaderEntityArray = [[NSMutableArray alloc] init];
    [self saveStatisticalDataHeaders:statisticalDataHeaders dataHeaderEntityArray:&dataHeaderEntityArray];
    
    [self saveDatapoints:dataPoints lightDataPoints:lightDataPoints statisticalDataHeaderEntity:dataHeaderEntityArray];

    if (deviceEntity.modelNumber.integerValue == WatchModel_R420) {
        [self saveDynamicWorkoutDatabase:workoutDatabase];
    } else {
        [self saveWorkoutDatabase:workoutDatabase workoutStopDatabase:workoutStopDatabase];
    }
    
    [self saveSleepDatabase:sleepDatabase];
    
    NSError *error = nil;
    [self.salutronLibrary saveChanges:&error];
    
    DDLogInfo(@"DEVICE ENTITY : %@", self.deviceEntity);
    if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]){
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HealthKitEnabled"]) {
        [self saveDataToHealthStore];
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
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return self.deviceEntity;
}

- (DeviceEntity *)saveWatchDataWithDeviceEntity:(DeviceEntity *)deviceEntity statisticalDataHeaders:(NSArray *)statisticalDataHeaders dataPoints:(NSArray *)dataPoints workoutDB:(NSArray *)workoutDatabase workoutStopDB:(NSDictionary *)workoutStopDatabase sleepDB:(NSArray *)sleepDatabase wakeUpArray:(NSArray *)wakeUpArray stepGoal:(NSInteger)stepGoal distanceGoal:(CGFloat)distanceGoal calorieGoal:(NSInteger)calorieGoal notification:(Notification *)notification sleepSetting:(SleepSetting *)sleepSetting calibrationDataArray:(NSArray *)calibrationDataArray salutronUserProfile:(SalutronUserProfile *)salutronUserProfile timeDate:(TimeDate *)timeDate lightDataPoints:(NSArray *)lightDataPoints inactiveAlertArray:(NSMutableArray *)inactiveAlertArray dayLightAlertArray:(NSMutableArray *)dayLightAlertArray nightLightAlertArray:(NSMutableArray *)nightLightAlertArray notificationStatus:(BOOL)notificationStatus timing:(Timing *)timing
{
    DDLogInfo(@"");
    self.deviceEntity = deviceEntity;
    
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    self.managedObjectContext.undoManager = undoManager;
    [undoManager beginUndoGrouping];
    
    [self saveSalutronUserProfile:salutronUserProfile];
    
    NSMutableArray *dataHeaderEntityArray = [[NSMutableArray alloc] init];
    [self saveStatisticalDataHeaders:statisticalDataHeaders dataHeaderEntityArray:&dataHeaderEntityArray];
    
    [self saveDatapoints:dataPoints lightDataPoints:lightDataPoints statisticalDataHeaderEntity:dataHeaderEntityArray];
    
//    [self saveLightDatapoints:lightDataPoints statisticalDataHeaderEntity:dataHeaderEntityArray];
    
    [self saveWorkoutDatabase:workoutDatabase workoutStopDatabase:workoutStopDatabase];
    
    [self saveSleepDatabase:sleepDatabase];
    
    Wakeup *wakeupAlert = nil;
    //[self saveWakeUp:wakeUpArray];
    [self saveWakeupAlertArray:wakeUpArray wakeupAlert:&wakeupAlert];
    
    [self saveGoalsWithStepGoal:stepGoal distanceGoal:distanceGoal calorieGoal:calorieGoal sleepSettings:sleepSetting];
    
    [self saveNotification:notification notificationStatus:notificationStatus];
    
    [self saveTiming:timing];
    
    CalibrationData *calibrationData = nil;
    [self saveCalibrationDataArray:calibrationDataArray calibrationData:&calibrationData];
    
    [self saveTimeDate:timeDate];
    
    InactiveAlert *inactiveAlert = nil;
    [self saveInactiveAlertArray:inactiveAlertArray inactiveAlert:&inactiveAlert];
    
    DayLightAlert *dayLightAlert = nil;
    [self saveDayLightAlertArray:dayLightAlertArray dayLightAlert:&dayLightAlert];
    
    NightLightAlert *nightLightAlert = nil;
    [self saveNightLightAlertArray:nightLightAlertArray nightLightAlert:&nightLightAlert];
    
    NSError *error = nil;
    [self.salutronLibrary saveChanges:&error];
    
    NSInteger sleepGoal = sleepSetting.sleep_goal_lo;
    sleepGoal           += sleepSetting.sleep_goal_hi << 8;
    
    self.userDefaultsManager.stepGoal               = stepGoal;
    self.userDefaultsManager.distanceGoal           = distanceGoal;
    self.userDefaultsManager.calorieGoal            = calorieGoal;
    self.userDefaultsManager.notification           = notification;
    self.userDefaultsManager.sleepSetting           = sleepSetting;
    self.userDefaultsManager.calibrationData        = calibrationData;
    self.userDefaultsManager.sleepGoal              = sleepGoal;
    self.userDefaultsManager.timeDate               = timeDate;
    self.userDefaultsManager.inactiveAlert          = inactiveAlert;
    self.userDefaultsManager.dayLightAlert          = dayLightAlert;
    self.userDefaultsManager.nightLightAlert        = nightLightAlert;
    self.userDefaultsManager.notificationStatus     = notificationStatus;
    self.userDefaultsManager.timing                 = timing;
    self.userDefaultsManager.wakeUp                 = wakeupAlert;
    
    DDLogInfo(@"DEVICE ENTITY : %@", self.deviceEntity);
    if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]){
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"InitialWatchToAppSync"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"InitialWatchToAppSync"] isEqual:@(0)]) {
        //[self saveDataToHealthStore];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HealthKitEnabled"]) {
            [self saveDataToHealthStore];
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

    }
    }
    return self.deviceEntity;
}

- (DeviceEntity *)saveWatchDataWithDeviceEntity:(DeviceEntity *)deviceEntity statisticalDataHeaders:(NSArray *)statisticalDataHeaders dataPoints:(NSArray *)dataPoints workoutDB:(NSArray *)workoutDatabase sleepDB:(NSArray *)sleepDatabase stepGoal:(NSInteger)stepGoal distanceGoal:(CGFloat)distanceGoal calorieGoal:(NSInteger)calorieGoal sleepSetting:(SleepSetting *)sleepSetting calibrationDataArray:(NSArray *)calibrationDataArray salutronUserProfile:(SalutronUserProfile *)salutronUserProfile timeDate:(TimeDate *)timeDate notificationStatus:(BOOL)notificationStatus workoutSetting:(NSArray *)workoutSettingArray
{
    DDLogInfo(@"");
    self.deviceEntity = deviceEntity;
    
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    self.managedObjectContext.undoManager = undoManager;
    [undoManager beginUndoGrouping];
    
    [self saveSalutronUserProfile:salutronUserProfile];
    
    NSMutableArray *dataHeaderEntityArray = [[NSMutableArray alloc] init];
    [self saveStatisticalDataHeaders:statisticalDataHeaders dataHeaderEntityArray:&dataHeaderEntityArray];
    
    [self saveDatapoints:dataPoints lightDataPoints:nil statisticalDataHeaderEntity:dataHeaderEntityArray];
    
    //    [self saveLightDatapoints:lightDataPoints statisticalDataHeaderEntity:dataHeaderEntityArray];
    
    //[self saveWorkoutDatabase:workoutDatabase workoutStopDatabase:nil];
    [self saveDynamicWorkoutDatabase:workoutDatabase];
    
    [self saveSleepDatabase:sleepDatabase];
    
    
    [self saveGoalsWithStepGoal:stepGoal distanceGoal:distanceGoal calorieGoal:calorieGoal sleepSettings:sleepSetting];
    
    CalibrationData *calibrationData = nil;
    [self saveCalibrationDataArray:calibrationDataArray calibrationData:&calibrationData];
    
    [self saveTimeDate:timeDate];
    
    WorkoutSetting *workoutSetting = nil;
    [self saveWorkoutSettingArray:workoutSettingArray workoutSetting:&workoutSetting];
    
    NSError *error = nil;
    [self.salutronLibrary saveChanges:&error];
    
    NSInteger sleepGoal = sleepSetting.sleep_goal_lo;
    sleepGoal           += sleepSetting.sleep_goal_hi << 8;
    
    self.userDefaultsManager.stepGoal               = stepGoal;
    self.userDefaultsManager.distanceGoal           = distanceGoal;
    self.userDefaultsManager.calorieGoal            = calorieGoal;
    self.userDefaultsManager.sleepSetting           = sleepSetting;
    self.userDefaultsManager.calibrationData        = calibrationData;
    self.userDefaultsManager.sleepGoal              = sleepGoal;
    self.userDefaultsManager.timeDate               = timeDate;
    self.userDefaultsManager.notificationStatus     = notificationStatus;
    self.userDefaultsManager.workoutSetting         = workoutSetting;
    self.userDefaultsManager.salutronUserProfile    = salutronUserProfile;
    
    DDLogInfo(@"DEVICE ENTITY : %@", self.deviceEntity);
    if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]){
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"InitialWatchToAppSync"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"InitialWatchToAppSync"] isEqual:@(0)]) {
            //[self saveDataToHealthStore];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HealthKitEnabled"]) {
                [self saveDataToHealthStore];
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
            
        }
    }
    return self.deviceEntity;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 200) {
        if (buttonIndex == 1) {
            [self saveDataToHealthStoreWithRequestPermission];
        }
        else{
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"HealthKitEnabled"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)saveDataToHealthStore{
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
                        [[SFAHealthKitManager sharedManager] saveAllDataToHealthStoreFromDataHeaders:[StatisticalDataHeaderEntity dataHeadersForDeviceEntity:self.deviceEntity]];
                    }
                    
            //    }
            //} failure:^(NSError *error) {
                
            //}];
            
        }
    });
}

- (void)saveDataToHealthStoreWithRequestPermission{
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
                        [[SFAHealthKitManager sharedManager] saveAllDataToHealthStoreFromDataHeaders:[StatisticalDataHeaderEntity dataHeadersForDeviceEntity:self.deviceEntity]];
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
    [[SFAHealthKitManager sharedManager] saveAllDataToHealthStoreFromDataHeaders:[StatisticalDataHeaderEntity dataHeadersForDeviceEntity:self.deviceEntity]];
    });
}
@end
