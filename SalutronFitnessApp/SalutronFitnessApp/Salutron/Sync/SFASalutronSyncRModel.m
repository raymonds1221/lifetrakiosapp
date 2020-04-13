//
//  SFASalutronSyncRModel.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 6/13/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronSyncRModel.h"
#import "SFASalutronSync+ErrorHandler.h"
#import "SFASalutronSync+Utilities.h"

#import "WorkoutInfo.h"
#import "WorkoutInfoEntity+Data.h"
#import "JDACoreData.h"
#import "SFASalutronSaveData.h"
#import "TimeDate+Data.h"
#import "LightDataPoint.h"
#import "SleepDatabaseEntity+Data.h"
#import "StatisticalDataHeaderEntity+Data.h"

#import "SFAServerAccountManager.h"

#import "Flurry.h"

static float const getStatisticalHeaderDelay    = 5.0f;
static int   const retryLimit                   = 2;
static int   const retrieveDelay                = 3;

@interface SFASalutronSyncRModel ()

@property (assign, nonatomic) NSUInteger            indexOfDiscoveredDevice;
@property (assign, nonatomic) NSInteger             indexOfWorkoutInfo;
@property (assign, nonatomic) NSInteger             currentWorkoutIndex;
@property (assign, nonatomic) BOOL                  pairButtonPressed;
@property (assign, nonatomic) int                   indexOfDataHeader;
@property (assign, nonatomic) int                   indexOfDataHeaderForLightDataPoint;
@property (assign, nonatomic) int                   indexOfCalibrationData;
@property (assign, nonatomic) int                   indexOfInactiveAlert;
@property (assign, nonatomic) int                   indexOfDayLightAlert;
@property (assign, nonatomic) int                   indexOfNightLightAlert;
@property (assign, nonatomic) int                   indexOfWakeup;
@property (assign, nonatomic) int                   indexOfLightCoeff;
@property (assign, nonatomic) int                   checksumErrorRetryCount;
@property (strong, nonatomic) DeviceDetail          *deviceDetail;
@property (strong, nonatomic) SFASalutronLibrary    *salutronLibrary;

@property (assign, nonatomic) BOOL                  currentlyConnecting;
@property (assign, nonatomic) int                   numberOfRetrievedConnectedDevices;

// SDK values will be saved here
@property (strong, nonatomic) NSMutableArray        *statisticalDataHeaders;
@property (strong, nonatomic) NSMutableArray        *filteredStatisticalDataHeaders;
@property (strong, nonatomic) NSMutableArray        *dataPointsArray;
@property (strong, nonatomic) NSMutableArray        *lightDataPointsArray;
@property (strong, nonatomic) NSArray               *workoutDatabase;
@property (strong, nonatomic) NSMutableDictionary   *workoutStopDatabase;
@property (strong, nonatomic) NSArray               *sleepDatabase;
@property (strong, nonatomic) NSMutableArray        *wakeUpArray;
@property (assign, nonatomic) NSInteger             stepGoal;
@property (assign, nonatomic) CGFloat               distanceGoal;
@property (assign, nonatomic) NSInteger             calorieGoal;
@property (strong, nonatomic) Notification          *notification;
@property (strong, nonatomic) SleepSetting          *sleepSetting;
@property (strong, nonatomic) NSMutableArray        *calibrationDataArray;
@property (strong, nonatomic) NSMutableArray        *inactiveAlertDataArray;
@property (strong, nonatomic) NSMutableArray        *dayLightAlertDataArray;
@property (strong, nonatomic) NSMutableArray        *nightLightAlertDataArray;
@property (strong, nonatomic) SalutronUserProfile   *salutronUserProfile;
@property (strong, nonatomic) TimeDate              *timeDate;
@property (strong, nonatomic) Timing                *timing;
@property (strong, nonatomic) NSMutableArray        *headerIndexes;
@property (assign, nonatomic) NSInteger             retrieveDeviceCounter;
@property (strong, nonatomic) NSMutableArray        *deviceDetails;
@property (strong, nonatomic) NSOperationQueue      *operationQueue;


// Everytime you add a mutable array, set, dictionary
// always remember to removeAllObjects for each property
// you can put it inside filterStatisticalDataHeaders: method
// not doing so might cause discepancy on the values display

@end

@implementation SFASalutronSyncRModel

#pragma mark - Lazy loading of properties

- (NSMutableArray *)filteredStatisticalDataHeaders
{
    if (!_filteredStatisticalDataHeaders) {
        _filteredStatisticalDataHeaders = [[NSMutableArray alloc] init];
    }
    return _filteredStatisticalDataHeaders;
}

- (NSMutableArray *)statisticalDataHeaders
{
    if (!_statisticalDataHeaders) {
        _statisticalDataHeaders = [[NSMutableArray alloc] init];
    }
    return _statisticalDataHeaders;
}

- (NSMutableArray *)dataPointsArray
{
    if (!_dataPointsArray){
        _dataPointsArray = [[NSMutableArray alloc] init];
    }
    return _dataPointsArray;
}

- (NSMutableArray *)inactiveAlertDataArray
{
    if (!_inactiveAlertDataArray) {
        _inactiveAlertDataArray = [[NSMutableArray alloc] init];
    }
    return _inactiveAlertDataArray;
}

- (NSMutableArray *)dayLightAlertDataArray
{
    if (!_dayLightAlertDataArray) {
        _dayLightAlertDataArray = [[NSMutableArray alloc] init];
    }
    return _dayLightAlertDataArray;
}

- (NSMutableArray *)nightLightAlertDataArray
{
    if (!_nightLightAlertDataArray) {
        _nightLightAlertDataArray = [[NSMutableArray alloc] init];
    }
    return _nightLightAlertDataArray;
}

- (NSMutableArray *)calibrationDataArray
{
    if (!_calibrationDataArray){
        _calibrationDataArray = [[NSMutableArray alloc] init];
    }
    return _calibrationDataArray;
}

- (NSArray *)workoutDatabase
{
    if (!_workoutDatabase) {
        _workoutDatabase = [[NSArray alloc] init];
    }
    return _workoutDatabase;
}

- (NSMutableDictionary *)workoutStopDatabase
{
    if (!_workoutStopDatabase) {
        _workoutStopDatabase = [[NSMutableDictionary alloc] init];
    }
    return _workoutStopDatabase;
}

- (NSMutableArray *)lightDataPointsArray
{
    if (!_lightDataPointsArray) {
        _lightDataPointsArray = [[NSMutableArray alloc] init];
    }
    return _lightDataPointsArray;
}

- (NSMutableArray *)wakeUpArray
{
    if (!_wakeUpArray) {
        _wakeUpArray = [[NSMutableArray alloc] init];
    }
    return _wakeUpArray;
}

- (NSMutableArray *)headerIndexes
{
    if (!_headerIndexes) {
        _headerIndexes = [[NSMutableArray alloc] init];
    }
    return _headerIndexes;
}

- (NSMutableArray *)deviceDetails
{
    if (!_deviceDetails) {
        _deviceDetails = [[NSMutableArray alloc] init];
    }
    return _deviceDetails;
}

- (SFASalutronLibrary *)salutronLibrary
{
    if (!_salutronLibrary) {
        _salutronLibrary = [[SFASalutronLibrary alloc] initWithManagedObjectContext:[JDACoreData sharedManager].context];
    }
    return _salutronLibrary;
}

- (NSOperationQueue *)operationQueue
{
    if (!_operationQueue) {
        _operationQueue = [NSOperationQueue mainQueue];
    }
    return _operationQueue;
}

#pragma mark - Salutron SDK delegate methods



- (void)didRetrieveConnectedDevice:(int)numDevice withStatus:(Status)status
{
    DDLogInfo(@"NUM DEVICE: %d | %@", numDevice, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"NUM DEVICE: %d | %@", numDevice, [ErrorCodeToStringConverter convertToString:status]);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self.salutronSDK selector:@selector(retrieveConnectedDevice) object:nil];
    
    self.numberOfRetrievedConnectedDevices = numDevice;
    [self.deviceDetails removeAllObjects];
    
    for (int i=0;i<numDevice;i++) {
        DeviceDetail *deviceDetail = nil;
        [self.salutronSDK getDeviceDetail:i with:&deviceDetail];
        [self.deviceDetails addObject:deviceDetail];
    }
}

- (void)retrieveConnectedDevice
{
    DDLogInfo(@"device details: %@", self.deviceDetails);
    
    self.watchModel = WatchModel_R450;
    
    if (self.isSearchConnectedDevice) {
        if (self.deviceDetails.count > 0) {
            self.searchConnectedDevice = NO;
            
            NSInteger index = -1;
            [self filterDeviceDetail:self.deviceDetails watchIndex:&index];
            
            if (self.isConnectDevice && index != -1) {
                [self.salutronSDK connectDevice:(int)index];
            }
            
            if (index > - 1) {
                [self startSearchConnectedDevice:YES];
            } else {
                [self startSearchConnectedDevice:NO];
            }
        } else {
            if (self.retryRetrieveCount < 2) {
                [self startSearchConnectedDevice:NO];
                self.retryRetrieveCount++;
            } else {
                [self handleError:ERROR_NOT_FOUND];
            }
        }
    } else {
        [Flurry logEvent:DEVICE_INITIALIZE_CONNECT timed:YES];
        
        NSInteger index = -1;
        [self filterDeviceDetail:self.deviceDetails watchIndex:&index];
        
        if (index > -1) {
            Status connectStatus = [self.salutronSDK connectDevice:(int)index];
            DDLogInfo(@"connect device: ", [ErrorCodeToStringConverter convertToString:connectStatus]);
        } else {
            if (self.retryRetrieveCount < 2) {
                //[self startSearchConnectedDevice:NO];
                [self.salutronSDK clearDiscoveredDevice];
                [self.salutronSDK discoverDevice:discoverTimeout];
                self.retryRetrieveCount++;
            } else {
                [self handleError:ERROR_NOT_FOUND];
            }
        }
    }
}

- (void)stopSync
{
    [self.operationQueue cancelAllOperations];
}

/*- (void)tempRetrieveConnectedDevice
{
    int numDevice = 0;
    
    self.watchModel = WatchModel_R450;
    if (self.isSearchConnectedDevice) {
        if (numDevice) {
            self.searchConnectedDevice = NO;
            
            if (self.isConnectDevice)
                [self.salutronSDK connectDevice:0];
            [self startSearchConnectedDevice:YES];
        } else {
            //[self startSearchConnectedDevice:NO];
            if (self.retryRetrieveCount < 2) {
                
                if (self.retryRetrieveCount == 0)
                    [self startSearchConnectedDevice:NO];
                
                self.retryRetrieveCount++;
                //[self.salutronSDK performSelector:@selector(retrieveConnectedDevice) withObject:nil afterDelay:7];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 7 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                    [self.salutronSDK retrieveConnectedDevice];
                });
            } else if (self.retryRetrieveCount > 1) {
                self.retryRetrieveCount = 0;
                self.searchConnectedDevice = NO;
                
                [self.salutronSDK clearDiscoveredDevice];
                Status status = [self.salutronSDK discoverDevice:discoverTimeout];
            }
        }
        return;
    }
    else{
        //self.indexOfDiscoveredDevice = [self deviceIndexForNumDevice:numDevice];
        
        if(numDevice <= 0) {
            
            if (self.syncType == SyncTypeBackground) {
                [self.salutronSDK disconnectDevice];
                return;
            }
            else {
                [self.salutronSDK clearDiscoveredDevice];
                Status discoverStatus = [self.salutronSDK discoverDevice:discoverTimeout];
                
                DDLogInfo(@"DISCOVER DEVICE STATUS : %@", [ErrorCodeToStringConverter convertToString:discoverStatus]);
                DDLogError(@"DISCOVER DEVICE STATUS : %@", [ErrorCodeToStringConverter convertToString:discoverStatus]);
                if (discoverStatus != NO_ERROR) {
                    [self handleError:ERROR_DISCOVER];
                    return;
                }
            }
            
        } else {
            self.numberOfRetrievedConnectedDevices = numDevice;
            
            if (self.currentlyConnecting && numDevice > 1){
                DDLogInfo(@"CURRENTLY CONNECTING: RETURN");
                DDLogError(@"CURRENTLY CONNECTING: RETURN");
                return;
            }
            
            self.currentlyConnecting = YES;
            self.indexOfRetrievedDevice = numDevice - 1;
            DDLogInfo(@"index of retrieved device: %i",self.indexOfRetrievedDevice);
            DDLogError(@"index of retrieved device: %i",self.indexOfRetrievedDevice);
            
            [Flurry logEvent:DEVICE_INITIALIZE_CONNECT timed:YES];
            
            //Status connectStatus = [self.salutronSDK connectDevice:self.indexOfRetrievedDevice];
            Status connectStatus = WARNING_NOT_CONNECTED;
            
            NSInteger index = 0;
            [self filterDeviceDetail:numDevice watchIndex:&index];
            //connectStatus = [self.salutronSDK connectDevice:self.indexOfRetrievedDevice];
            
            if (![self.salutronSDK getConnectedDeviceDetail]) {
                connectStatus = [self.salutronSDK connectDevice:(int)index];
                self.retrieveDeviceCounter++;
            } else {
                if (self.retrieveDeviceCounter == 0) {
                    connectStatus = [self.salutronSDK connectDevice:(int)index];
                }
                self.retrieveDeviceCounter++;
            }
            
            if (connectStatus != NO_ERROR) {
                self.currentlyConnecting = NO;
            }
            
        }
    }
}*/

- (void)didDiscoverDevice:(int)numDevice withStatus:(Status)status
{
    DDLogInfo(@"NUM DEVICE: %d | %@", numDevice, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"NUM DEVICE: %d | %@", numDevice, [ErrorCodeToStringConverter convertToString:status]);
    
    NSString *deviceUUID = [[NSUserDefaults standardUserDefaults] stringForKey:DEVICE_UUID];
    self.indexOfRetrievedDevice = 0;
    
    Status connectDeviceStatus = WARNING_NOT_CONNECTED;
    
    [self.deviceDetails removeAllObjects];
    
    for (int i=0;i<numDevice;i++) {
        DeviceDetail *deviceDetail = nil;
        [self.salutronSDK getDeviceDetail:i with:&deviceDetail];
        
        if (deviceDetail) {
            [self.deviceDetails addObject:deviceDetail];
        }
    }
    
    
    NSInteger index = -1;
    [self filterDeviceDetail:self.deviceDetails watchIndex:&index];
    
    if(index > -1) { //if(numDevice > 0) {
        DeviceDetail *deviceDetail = nil;
        Status s = [self.salutronSDK getDeviceDetail:0 with:&deviceDetail];
        NSString *deviceId = deviceDetail.deviceID.description;
        
        DDLogInfo(@"deviceUUID: %@\ndeviceDetail: %@", deviceUUID, deviceDetail);
        DDLogError(@"deviceUUID: %@\ndeviceDetail: %@", deviceUUID, deviceDetail);
        if (self.syncType != SyncTypeInitial) {
            //DeviceEntity *entity = [DeviceEntity deviceEntityForUUID:deviceDetail.peripheral.identifier];
            
            if (s!= NO_ERROR || ![deviceId isEqual:WatchModel_R450_DeviceId]) {
                [self handleError:ERROR_DISCOVER];
                return;
            }
        } else {
            if (s!= NO_ERROR || ![deviceId isEqual:WatchModel_R450_DeviceId]){
                [self handleError:ERROR_DISCOVER];
                return;
            }
        }
        
        
        [Flurry logEvent:DEVICE_INITIALIZE_CONNECT timed:YES];
        //Status connectDeviceStatus = [self.salutronSDK connectDevice:0];
        
        if (index > -1) {
            connectDeviceStatus = [self.salutronSDK connectDevice:(int)index];
        }
        
        DDLogInfo(@"CONNECT DEVICE STATUS : %@", [ErrorCodeToStringConverter convertToString:connectDeviceStatus]);
        DDLogError(@"CONNECT DEVICE STATUS : %@", [ErrorCodeToStringConverter convertToString:connectDeviceStatus]);
        if (connectDeviceStatus != NO_ERROR) {
            [self handleError:ERROR_DISCOVER];
            return;
        }
    }
    else { //else if (numDevice == 0) {
        
        self.indexOfRetrievedDevice = 0;
        self.retryCount++;
        
        if (self.retryCount >= retryLimit) {
            [self handleError:ERROR_DISCOVER];
            self.retryCount = 0;
            return;
        }
        else {
            [self.salutronSDK clearDiscoveredDevice];
            //[self performSelector:@selector(delayedRetrievedConnectedDevice) withObject:nil afterDelay:6];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, retrieveDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self delayedRetrievedConnectedDevice];
            });
        }
    }
    /*else {
        [self handleError:ERROR_DISCOVER];
        return;
    }*/
}

- (void)delayedRetrievedConnectedDevice{
    [self.salutronSDK clearDiscoveredDevice];
    [self.salutronSDK retrieveConnectedDevice];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, retrieveDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (!self.isSyncStopped) {
            [self retrieveConnectedDevice];
        }
    });
}

- (void)didConnectAndSetupDeviceWithStatus:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    
    self.retrieveDeviceCounter = 0;
    DDLogError(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    
    [Flurry endTimedEvent:DEVICE_INITIALIZE_CONNECT withParameters:nil];
    [Flurry logEvent:DEVICE_CONNECTED];
    
    int retry = 0;
    
    while (retry < 5) {
        
        NSString *macAddress                = nil;
        Status macAddressStatus = [self.salutronSDK getMacAddress:&macAddress];
        DDLogInfo(@"macAddressStatus = %@", [ErrorCodeToStringConverter convertToString:macAddressStatus]);
        DDLogError(@"macAddressStatus = %@", [ErrorCodeToStringConverter convertToString:macAddressStatus]);
        
        if (macAddressStatus != WARNING_NOT_READY) {
            //if initial sync and macaddress already exists, disconnect current and retrieve other connected device
            BOOL existingMacAddress = [[[DeviceEntity deviceEntitiesForUser:[SFAServerAccountManager sharedManager].user] valueForKey:@"macAddress"] containsObject:macAddress];
            
            NSString *savedMacAddress = [SFAUserDefaultsManager sharedManager].macAddress;
            /*
             if ([savedMacAddress containsString:@":"]) {
             savedMacAddress = [self convertAndroidToiOSMacAddress:savedMacAddress];
             }
             */
            if ([savedMacAddress rangeOfString:@":"].location != NSNotFound) {
                savedMacAddress = [self convertAndroidToiOSMacAddress:savedMacAddress];
            }
            
            if ((self.syncType == SyncTypeInitial && existingMacAddress) ||
                //(self.syncType != SyncTypeInitial && ![macAddress isEqualToString:[SFAUserDefaultsManager sharedManager].macAddress])
                (self.syncType != SyncTypeInitial && ![macAddress isEqualToString:savedMacAddress])){
                DDLogInfo(@"FORCE DISCONNECT");
                DDLogError(@"FORCE DISCONNECT");
                
                DDLogInfo(@"EXISTING MAC ADDRESS: %@ INITIAL SYNC: %@", existingMacAddress ? BUTTON_TITLE_YES_ALL_CAPS : BUTTON_TITLE_NO_ALL_CAPS , self.syncType == SyncTypeInitial ? BUTTON_TITLE_YES_ALL_CAPS : BUTTON_TITLE_NO_ALL_CAPS);
                
                DDLogError(@"EXISTING MAC ADDRESS: %@ INITIAL SYNC: %@", existingMacAddress ? BUTTON_TITLE_YES_ALL_CAPS : BUTTON_TITLE_NO_ALL_CAPS , self.syncType == SyncTypeInitial ? BUTTON_TITLE_YES_ALL_CAPS : BUTTON_TITLE_NO_ALL_CAPS);
                
                DDLogInfo(@"COMPARE SDK MAC ADDRESS: %@ USERDEFAULTS MAC ADDRESS: %@",macAddress, [SFAUserDefaultsManager sharedManager].macAddress);
                
                DDLogError(@"COMPARE SDK MAC ADDRESS: %@ USERDEFAULTS MAC ADDRESS: %@",macAddress, [SFAUserDefaultsManager sharedManager].macAddress);
                
                [self.salutronSDK disconnectDevice];
                self.currentlyConnecting = NO;
                self.indexOfRetrievedDevice += 1;
                if (self.indexOfRetrievedDevice <= self.numberOfRetrievedConnectedDevices -1) {
                    
                    /*DeviceDetail *deviceDetail = nil;
                    Status s = [self.salutronSDK getDeviceDetail:self.indexOfRetrievedDevice with:&deviceDetail];
                    NSString *deviceId = deviceDetail.deviceID.description;
                    
                    if (s!= NO_ERROR || ![deviceId isEqual:WatchModel_R450_DeviceId]){
                        [self handleError:ERROR_DISCOVER];
                        return;
                    }*/
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self.salutronSDK connectDevice:self.indexOfRetrievedDevice];
                    });
                } else {
                    self.indexOfRetrievedDevice = 0;
                    [self handleError:ERROR_DISCOVER];
                }
                return;
            }
            
            [self startDeviceConnectedFromSearching];
            [self establishConnection];
            self.checksumErrorRetryCount = 0;
            [Flurry logEvent:DEVICE_START_SYNC timed:YES];
            [Flurry logEvent:DEVICE_GET_TIME timed:YES];
            //[self performSelector:@selector(delayedGetStatisticalDataHeaders) withObject:nil afterDelay:getStatisticalHeaderDelay];
            
            [self startSyncOnTimeAndDate];
            [self.salutronSDK getCurrentTimeAndDate];
            break;
        }
        else {
            retry++;
        }
    }
    if (retry >= 5) {
        [self handleError:status];
    }
}

- (void)delayedUpdateTimeAndDate
{
    DDLogInfo(@"");
    [self startSync];
    
    TimeDate *tempTimeDate      = [TimeDate getUpdatedData];
    TimeDate *nowTimeDate       = [[TimeDate alloc] initWithDate:[NSDate new]];
    
    nowTimeDate.hourFormat      = tempTimeDate.hourFormat;
    nowTimeDate.dateFormat      = tempTimeDate.dateFormat;
    nowTimeDate.watchFace       = tempTimeDate.watchFace;
    
    Status status = [self.salutronSDK updateTimeAndDate:nowTimeDate];
    
    DDLogInfo(@"updateTimeAndDate = %@", [ErrorCodeToStringConverter convertToString:status]);
    if (status != NO_ERROR) {
        [self handleError:status];
        return;
    }
}

- (void)delayedGetStatisticalDataHeaders
{
    DDLogInfo(@"");
    self.currentlyConnecting = NO;
    [self startSyncing];
    self.retrieveDeviceCounter = 0;
    
    Status statisticalDataHeadersStatus = [self.salutronSDK getStatisticalDataHeaders];
    
    DDLogInfo(@"statisticalDataHeadersStatus = %@", [ErrorCodeToStringConverter convertToString:statisticalDataHeadersStatus]);
    DDLogError(@"statisticalDataHeadersStatus = %@", [ErrorCodeToStringConverter convertToString:statisticalDataHeadersStatus]);
    if (statisticalDataHeadersStatus != NO_ERROR) {
        [self handleError:statisticalDataHeadersStatus];
        return;
    }
    
    DeviceDetail *devDetail = [self.salutronSDK getConnectedDeviceDetail];
    
    DDLogInfo(@"devDetail = %@", devDetail);
    DDLogError(@"devDetail = %@", devDetail);
    if (devDetail) {
        self.deviceDetail = devDetail;
    }
}

- (void)didDisconnectDevice:(Status)status
{
    DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"%@", [ErrorCodeToStringConverter convertToString:status]);
    self.syncingFinished = NO;
    [self handleError:ERROR_DISCONNECT];
    return;
}

- (void)didGetStatisticalDataHeaders:(NSArray *)statisticalDataHeaders withStatus:(Status)status
{
    DDLogInfo(@"-----> STATISTICAL HEADERS COUNT:%d | %@ \n STATISTICAL DATAHEADERS: %@", statisticalDataHeaders.count, [ErrorCodeToStringConverter convertToString:status], statisticalDataHeaders);
    DDLogError(@"-----> STATISTICAL HEADERS COUNT:%d | %@ \n STATISTICAL DATAHEADERS: %@", statisticalDataHeaders.count, [ErrorCodeToStringConverter convertToString:status], statisticalDataHeaders);
    
    if (status == NO_ERROR) {
        
        [self.statisticalDataHeaders removeAllObjects];
        
        self.statisticalDataHeaders     = [statisticalDataHeaders mutableCopy];
        self.indexOfDataHeader          = 0;
        self.indexOfDataHeaderForLightDataPoint = 0;
        
        if(statisticalDataHeaders.count > 0) {
            
            [self startSyncOnDataPoints];
            [self.filteredStatisticalDataHeaders removeAllObjects];
            [self filterStatisticalDataHeaders:statisticalDataHeaders];
            
            if (self.indexOfDataHeader < self.statisticalDataHeaders.count && self.headerIndexes.count > 0) {
                self.checksumErrorRetryCount = 0;
                [Flurry endTimedEvent:DEVICE_GET_DATA_HEADER withParameters:nil];
                [Flurry logEvent:DEVICE_GET_DATA_POINTS timed:YES];
				//Status getStatus = [self.salutronSDK getDataPointsOfSelectedDateStamp:self.indexOfDataHeader];
                Status getStatus = [self.salutronSDK getDataPointsOfSelectedDateStamp:[self.headerIndexes[0] intValue]];
                DDLogInfo(@"getDataPointsOfSelectedDateStamp status: %@", [ErrorCodeToStringConverter convertToString:getStatus]);
                DDLogError(@"getDataPointsOfSelectedDateStamp status: %@", [ErrorCodeToStringConverter convertToString:getStatus]);
                if (getStatus != NO_ERROR) {
                    [self handleError:status];
                    return;
                }
            }
            else {
                [self startSyncOnWorkoutDatabase];
                
                [Flurry endTimedEvent:DEVICE_GET_DATA_HEADER withParameters:nil];
                [Flurry logEvent:DEVICE_GET_WORKOUT timed:YES];
                Status getStatus = [self.salutronSDK getWorkoutDatabase];
                if (getStatus != NO_ERROR) {
                    [self handleError:status];
                    return;
                }
            }
            
        }
        else {
            [self startSyncOnWorkoutDatabase];
            
            [Flurry endTimedEvent:DEVICE_GET_DATA_HEADER withParameters:nil];
            [Flurry logEvent:DEVICE_GET_WORKOUT timed:YES];
            Status getStatus = [self.salutronSDK getWorkoutDatabase];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
        }
    }
    else if (self.checksumErrorRetryCount < 5 && (status == ERROR_TIMEOUT || status == ERROR_CHECKSUM)){
        self.checksumErrorRetryCount++;
        //[self performSelector:@selector(delayedGetStatisticalDataHeaders) withObject:nil afterDelay:getStatisticalHeaderDelay];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, getStatisticalHeaderDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self delayedGetStatisticalDataHeaders];
        });
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didGetDataPointsOfSelectedDateStamp:(NSArray *)dataPoints withStatus:(Status)status
{
    static NSInteger headerIndexForDataPoint;
    DDLogInfo(@"");
    
    DDLogInfo(@"-----> INDEX:%d COUNT:%d | %@ \nDATAPOINTS:%@ ", self.indexOfDataHeader, dataPoints.count, [ErrorCodeToStringConverter convertToString:status], dataPoints);
    DDLogError(@"-----> INDEX:%d COUNT:%d", self.indexOfDataHeader, dataPoints.count, [ErrorCodeToStringConverter convertToString:status]);
   //   DDLogInfo(@"-----> INDEX:%d COUNT:%d | %@ \nDATAPOINTS: ", self.indexOfDataHeader, dataPoints.count, [ErrorCodeToStringConverter convertToString:status]);
    
    DDLogInfo(@"HeaderIndexes count = %d headerIndex = %d", self.headerIndexes.count, headerIndexForDataPoint);
    DDLogError(@"HeaderIndexes count = %d headerIndex = %d", self.headerIndexes.count, headerIndexForDataPoint);
    
    if (status == NO_ERROR) {
        [self.dataPointsArray addObject:dataPoints];
    }
    
    if (status != ERROR_CHECKSUM && status != ERROR_TIMEOUT) {
        self.indexOfDataHeader++;
        headerIndexForDataPoint++;
    }
    
    //if (self.indexOfDataHeader < self.statisticalDataHeaders.count) {
    if (headerIndexForDataPoint < self.headerIndexes.count) {
        self.checksumErrorRetryCount = 0;
        //Status getStatus = [self.salutronSDK getDataPointsOfSelectedDateStamp:self.indexOfDataHeader];
        Status getStatus = [self.salutronSDK getDataPointsOfSelectedDateStamp:[self.headerIndexes[headerIndexForDataPoint] intValue
                                                                               ]];
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }
    }
    else {
        [self startSyncOnWorkoutDatabase];
        headerIndexForDataPoint = 0;
        [Flurry endTimedEvent:DEVICE_GET_DATA_POINTS withParameters:nil];
        [Flurry logEvent:DEVICE_GET_WORKOUT timed:YES];
        Status getStatus = [self.salutronSDK getWorkoutDatabase];
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }
    }
    
    if (status != NO_ERROR) {
        if (self.checksumErrorRetryCount < 5 && (status == ERROR_CHECKSUM || status == ERROR_TIMEOUT)) {
            self.checksumErrorRetryCount++;
            if (self.headerIndexes.count == 0) {
                [self handleError:ERROR_DATA];
                return;
            }
            else{
            //Status getStatus = [self.salutronSDK getDataPointsOfSelectedDateStamp:self.indexOfDataHeader];
            //Status getStatus =
                [self.salutronSDK getDataPointsOfSelectedDateStamp:[self.headerIndexes[headerIndexForDataPoint] integerValue]];
            }
            /*   if (getStatus != NO_ERROR) {
             [self handleError:status];
             return;
             }
             */
        }
        else{
            [self handleError:status];
            return;
        }
    }
}

- (void)didGetWorkoutDatabase:(NSArray *)workoutDatabase withStatus:(Status)status
{
    DDLogInfo(@"-----> WORKOUT DB COUNT:%d | WORKOUT DB: %@ | %@", workoutDatabase.count, workoutDatabase, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> WORKOUT DB COUNT:%d | WORKOUT DB: %@ | %@", workoutDatabase.count, workoutDatabase, [ErrorCodeToStringConverter convertToString:status]);
    
    if (status == NO_ERROR) {
        
        self.workoutDatabase    = workoutDatabase;
        
        if (self.workoutDatabase.count <= 0) {
            Status getStatus = [self.salutronSDK getSleepDatabase];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
        }
        else {
            WorkoutInfo *workoutInfo = [workoutDatabase firstObject];
            self.currentWorkoutIndex = 0;
            [Flurry endTimedEvent:DEVICE_GET_WORKOUT withParameters:nil];
            [Flurry logEvent:DEVICE_GET_WORKOUT_STOP timed:YES];
            Status getStatus = [self.salutronSDK getWorkoutStopDatabase:@(workoutInfo.workoutID).intValue];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
            [self startSyncOnWorkoutStopDatabase];
        }
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didGetWorkoutStopDatabase:(NSArray *)workoutstopdatabase withStatus:(Status)status
{
    DDLogInfo(@"-----> WORKOUTSTOP DB COUNT:%d | %@", workoutstopdatabase.count, [ErrorCodeToStringConverter convertToString:status]);
    //DDLogInfo(@"workout stop for workout id %i: %@",[(WorkoutInfo *)self.workoutDatabase[self.currentWorkoutIndex] workoutID],workoutstopdatabase);
    
    DDLogError(@"-----> WORKOUTSTOP DB COUNT:%d | %@", workoutstopdatabase.count, [ErrorCodeToStringConverter convertToString:status]);
    if (status == NO_ERROR) {
        DDLogError(@"workout stop for workout id %i: %@",[(WorkoutInfo *)self.workoutDatabase[self.currentWorkoutIndex] workoutID],workoutstopdatabase);
        [self.workoutStopDatabase setObject:workoutstopdatabase forKey:@([(WorkoutInfo *)self.workoutDatabase[self.currentWorkoutIndex] workoutID])];
        self.currentWorkoutIndex += 1;
        if (self.currentWorkoutIndex < self.workoutDatabase.count){
            self.checksumErrorRetryCount = 0;
            WorkoutInfo *workoutInfo = [self.workoutDatabase objectAtIndex:self.currentWorkoutIndex];
            Status getStatus = [self.salutronSDK getWorkoutStopDatabase:@(workoutInfo.workoutID).intValue];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
        }else{
            [self startSyncOnSleepDatabase];
            
            [Flurry endTimedEvent:DEVICE_GET_WORKOUT_STOP withParameters:nil];
            [Flurry logEvent:DEVICE_GET_SLEEP_DATABASE timed:YES];
            Status getStatus = [self.salutronSDK getSleepDatabase];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
        }
    }
    else {
        if (self.checksumErrorRetryCount < 5 && (status == ERROR_TIMEOUT || status == ERROR_CHECKSUM)) {
            self.checksumErrorRetryCount++;
            WorkoutInfo *workoutInfo = [self.workoutDatabase objectAtIndex:self.currentWorkoutIndex];
            Status getStatus = [self.salutronSDK getWorkoutStopDatabase:@(workoutInfo.workoutID).intValue];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
        }
        else{
            [self handleError:status];
            return;
        }
    }
}

- (void)didGetSleepDatabase:(NSArray *)sleepdatabase withStatus:(Status)status
{
    DDLogInfo(@"-----> SLEEP DB COUNT:%d | %@", sleepdatabase.count, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> SLEEP DB COUNT:%d | %@", sleepdatabase.count, [ErrorCodeToStringConverter convertToString:status]);
    
    if (status == NO_ERROR) {
        self.sleepDatabase      = sleepdatabase;
        self.indexOfWakeup      = 0;
        
        [self startSyncOnLightDataPoints];
        
        [self.lightDataPointsArray removeAllObjects];
        
        self.checksumErrorRetryCount = 0;
        //Status getStatus = [self.salutronSDK getLightData:self.indexOfDataHeaderForLightDataPoint];
//#warning if headerindex is empty, use 0 as the index of getlightdata
        Status getStatus;
        
        if (self.headerIndexes.count == 0) {
            getStatus = [self.salutronSDK getLightData:0];
        }
        else{
            getStatus = [self.salutronSDK getLightData:[self.headerIndexes[0] integerValue]];
            
        }
        
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }
        
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didGetLightData:(NSArray *)dataPoints withStatus:(Status)status
{
    static NSInteger headerIndexForLight;
    
    //DDLogInfo(@"-----> INDEX:%d COUNT:%d | %@ \nLIGHT DATAPOINTS:%@ ", self.indexOfDataHeaderForLightDataPoint, dataPoints.count, [ErrorCodeToStringConverter convertToString:status], dataPoints);
    //DDLogInfo(@"-----> INDEX:%d COUNT:%d | %@ \nLIGHT DATAPOINTS:", self.indexOfDataHeaderForLightDataPoint, dataPoints.count, [ErrorCodeToStringConverter convertToString:status]);
    DDLogInfo(@"HeaderIndexes count = %d headerIndex = %d", self.headerIndexes.count, headerIndexForLight);
    
    //DDLogError(@"-----> INDEX:%d COUNT:%d | %@ \nLIGHT DATAPOINTS:%@ ", self.indexOfDataHeaderForLightDataPoint, dataPoints.count, [ErrorCodeToStringConverter convertToString:status], dataPoints);
    //DDLogInfo(@"-----> INDEX:%d COUNT:%d | %@ \nLIGHT DATAPOINTS:", self.indexOfDataHeaderForLightDataPoint, dataPoints.count, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"HeaderIndexes count = %d headerIndex = %d", self.headerIndexes.count, headerIndexForLight);
    
    if (status == NO_ERROR) {
        [self.lightDataPointsArray addObject:dataPoints];
    }
    
    if (status != ERROR_CHECKSUM && status != ERROR_TIMEOUT) {
        self.indexOfDataHeaderForLightDataPoint++;
        headerIndexForLight++;
    }
    
    
    //if (self.indexOfDataHeaderForLightDataPoint < self.statisticalDataHeaders.count) {
    if (headerIndexForLight < self.headerIndexes.count) {
        
        self.checksumErrorRetryCount = 0;
        //Status getStatus = [self.salutronSDK getLightData:self.indexOfDataHeaderForLightDataPoint];
        Status getStatus = [self.salutronSDK getLightData:[self.headerIndexes[headerIndexForLight] integerValue]];
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }
    }
    else {
        headerIndexForLight = 0;
        [Flurry endTimedEvent:DEVICE_GET_LIGHT_DATA_POINTS withParameters:nil];
        [Flurry logEvent:DEVICE_GET_WAKEUP_SETTING timed:YES];
        Status getStatus = [self.salutronSDK getWakeup:self.indexOfWakeup];
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }
    }
    
    if (status != NO_ERROR) {
        if (self.checksumErrorRetryCount < 5 && (status == ERROR_CHECKSUM || status == ERROR_TIMEOUT)) {
            self.checksumErrorRetryCount++;
            Status getStatus = [self.salutronSDK getLightData:[self.headerIndexes[headerIndexForLight] integerValue]];
            if (getStatus != NO_ERROR) {
             //   [self handleError:status];
             //   return;
            }
        }
        else{
            [self handleError:status];
            return;
        }
    }
}

- (void)didGetWakeup:(Wakeup *)wakeup withStatus:(Status)status
{
    DDLogInfo(@"-----> INDEX:%d WAKEUP:%@ | %@", self.indexOfWakeup, wakeup, [ErrorCodeToStringConverter convertToString:status]);
    
    DDLogError(@"-----> INDEX:%d WAKEUP:%@ | %@", self.indexOfWakeup, wakeup, [ErrorCodeToStringConverter convertToString:status]);
    
    self.indexOfWakeup++;
    
    if (status == ERROR_CHECKSUM) {
        self.indexOfWakeup--;
    }
    else {
        if (status == NO_ERROR) {
            [self.wakeUpArray addObject:wakeup];
        }
        else {
            if (status != ERROR_DATA) {
                [self handleError:status];
                return;
            }
        }
    }
    
    if (self.indexOfWakeup < 5) {
        Status getStatus = [self.salutronSDK getWakeup:self.indexOfWakeup];
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }
    }
    else {
        [self startSyncOnStepGoal];
        
        [Flurry endTimedEvent:DEVICE_GET_WAKEUP_SETTING withParameters:nil];
        [Flurry logEvent:DEVICE_GET_STEP_GOAL timed:YES];
        Status getStatus = [self.salutronSDK getStepGoal];
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }
    }
}

- (void)didGetStepGoal:(int)stepGoal withStatus:(Status)status
{
    DDLogInfo(@"-----> STEP GOAL:%d | %@", stepGoal, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> STEP GOAL:%d | %@", stepGoal, [ErrorCodeToStringConverter convertToString:status]);
    
    if (status == NO_ERROR) {
        self.stepGoal           = stepGoal;
        [self startSyncOnDistanceGoal];
        
        [Flurry endTimedEvent:DEVICE_GET_STEP_GOAL withParameters:nil];
        [Flurry logEvent:DEVICE_GET_DISTANCE_GOAL timed:YES];
        Status getStatus = [self.salutronSDK getDistanceGoal];
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didGetDistanceGoal:(double)distanceGoal withStatus:(Status)status
{
    DDLogInfo(@"-----> DISTANCE GOAL:%f | %@", distanceGoal, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> DISTANCE GOAL:%f | %@", distanceGoal, [ErrorCodeToStringConverter convertToString:status]);
    
    if (status == NO_ERROR) {
        self.distanceGoal       = distanceGoal;
        if (self.distanceGoal < 0) {
            self.distanceGoal = 3.2;
        }
        [self startSyncOnCalorieGoal];
        
        [Flurry endTimedEvent:DEVICE_GET_DISTANCE_GOAL withParameters:nil];
        [Flurry logEvent:DEVICE_GET_CALORIES_GOAL timed:YES];
        Status getStatus = [self.salutronSDK getCalorieGoal];
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didGetCalorieGoal:(int)calorieGoal withStatus:(Status)status
{
    DDLogInfo(@"-----> CALORIE GOAL:%d | %@", calorieGoal, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> CALORIE GOAL:%d | %@", calorieGoal, [ErrorCodeToStringConverter convertToString:status]);
    
    if (status == NO_ERROR) {
        self.calorieGoal        = calorieGoal;
        
        [Flurry endTimedEvent:DEVICE_GET_CALORIES_GOAL withParameters:nil];
        Status getStatus = [self.salutronSDK getTiming:3]; // get smartForSleep only
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didGetTiming:(Timing *)timing withStatus:(Status)status
{
    DDLogInfo(@"-----> TIMING:%@ | %@", timing, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> TIMING:%@ | %@", timing, [ErrorCodeToStringConverter convertToString:status]);
    if (status == NO_ERROR) {
        self.timing        = timing;
        [self startSyncOnNotification];
        
        [Flurry logEvent:DEVICE_GET_NOTIFICATION timed:YES];
        Status getStatus = [self.salutronSDK getNotification]; // get smartForSleep only
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didGetNotification:(Notification *)notify withStatus:(Status)status
{
    DDLogInfo(@"-----> NOTIFICATION:%@ | %@", notify, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> NOTIFICATION:%@ | %@", notify, [ErrorCodeToStringConverter convertToString:status]);
    
    if (status == NO_ERROR) {
        self.notification       = notify;
        
        [self startSyncOnAlerts];
        
        self.indexOfInactiveAlert = 0;
        
        [Flurry endTimedEvent:DEVICE_GET_NOTIFICATION withParameters:nil];
        [Flurry logEvent:DEVICE_GET_ACTIVITY_ALERT timed:YES];
        Status getStatus = [self.salutronSDK getInactiveAlert:self.indexOfInactiveAlert];
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didGetInactiveAlert:(InactiveAlert *)inactiveAlert withStatus:(Status)status
{
    DDLogInfo(@"-----> INACTIVE ALERT:%@ | %@", inactiveAlert, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> INACTIVE ALERT:%@ | %@", inactiveAlert, [ErrorCodeToStringConverter convertToString:status]);
    
    if (status == NO_ERROR) {
        // 0 - Status 1 - Time Duration 2 - Steps Threshold 3 - Start Time 4 - End Time
        self.indexOfInactiveAlert++;
        
        [self.inactiveAlertDataArray addObject:inactiveAlert];
        
        if (self.indexOfInactiveAlert < 5) {
            
            Status getStatus = [self.salutronSDK getInactiveAlert:self.indexOfInactiveAlert];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
        }
        else {
            self.indexOfDayLightAlert = 0;
            
            [Flurry endTimedEvent:DEVICE_GET_ACTIVITY_ALERT withParameters:nil];
            [Flurry logEvent:DEVICE_GET_DAYLIGHT_SETTING timed:YES];
            Status getStatus = [self.salutronSDK getDayLightAlert:self.indexOfDayLightAlert];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
        }
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didGetDayLightAlert:(DayLightAlert *)dayLightAlert withStatus:(Status)status
{
    DDLogInfo(@"-----> DAY LIGHT ALERT:%@ | %@", dayLightAlert, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> DAY LIGHT ALERT:%@ | %@", dayLightAlert, [ErrorCodeToStringConverter convertToString:status]);
    
    if (status == NO_ERROR) {
        // 0 - Status 1 - level 2 - duration 3 - Start Time 4 - End Time 5 - interval
        self.indexOfDayLightAlert++;
        
        [self.dayLightAlertDataArray addObject:dayLightAlert];
        
        if (self.indexOfDayLightAlert < 6) {
            
            Status getStatus = [self.salutronSDK getDayLightAlert:self.indexOfDayLightAlert];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
        }
        else {
            self.indexOfNightLightAlert = 0;
            
            [Flurry endTimedEvent:DEVICE_GET_DAYLIGHT_SETTING withParameters:nil];
            [Flurry logEvent:DEVICE_GET_NIGHTLIGHT_SETTING timed:YES];
            Status getStatus = [self.salutronSDK getNightLightAlert:self.indexOfNightLightAlert];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
        }
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didGetNightLightAlert:(NightLightAlert *)nightLightAlert withStatus:(Status)status
{
    DDLogInfo(@"-----> NIGHT LIGHT ALERT:%@ | %@", nightLightAlert, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> NIGHT LIGHT ALERT:%@ | %@", nightLightAlert, [ErrorCodeToStringConverter convertToString:status]);
    
    if (status == NO_ERROR) {
        // 0 - Status 1 - level 2 - duration 3 - Start Time 4 - End Time
        self.indexOfNightLightAlert++;
        
        [self.nightLightAlertDataArray addObject:nightLightAlert];
        
        if (self.indexOfNightLightAlert < 5) {
            
            Status getStatus = [self.salutronSDK getNightLightAlert:self.indexOfNightLightAlert];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
        }
        else {
            [self startSyncOnSleepSettings];
            
            [Flurry endTimedEvent:DEVICE_GET_NIGHTLIGHT_SETTING withParameters:nil];
            [Flurry logEvent:DEVICE_GET_SLEEP_SETTING timed:YES];
            Status getStatus = [self.salutronSDK getSleepSetting];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
        }
    }
    else {
        [self handleError:status];
        return;
    }
    
}

- (void)didGetSleepSetting:(SleepSetting *)sleepSetting withStatus:(Status)status
{
    DDLogInfo(@"-----> SLEEP SETTING:%@ | %@", sleepSetting, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> SLEEP SETTING:%@ | %@", sleepSetting, [ErrorCodeToStringConverter convertToString:status]);
    
    if (status == NO_ERROR) {
        self.sleepSetting           = sleepSetting;
        self.indexOfCalibrationData = 0;
        [self startSyncOnCalibrationData];
        
        [Flurry endTimedEvent:DEVICE_GET_SLEEP_SETTING withParameters:nil];
        [Flurry logEvent:DEVICE_GET_CALIBRATION_DATA timed:YES];
        Status getStatus = [self.salutronSDK getCalibrationData:self.indexOfCalibrationData];
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didGetCalibrationData:(CalibrationData *)calibrationData withStatus:(Status)status
{
    DDLogInfo(@"-----> INDEX:%d CALIBRATION:%@ | %@", self.indexOfCalibrationData, calibrationData, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> INDEX:%d CALIBRATION:%@ | %@", self.indexOfCalibrationData, calibrationData, [ErrorCodeToStringConverter convertToString:status]);
    
    if (status == NO_ERROR) {
        // Get Type 1, Type 2, and Type 4 Calibration data (index 0, 1, 3)
        // Increment until 3
        self.indexOfCalibrationData++;
        
        if (self.indexOfCalibrationData == 2) {
            self.indexOfCalibrationData++;
        }
        
        [self.calibrationDataArray addObject:calibrationData];
        
        if (self.indexOfCalibrationData < 5) {
            
            Status getStatus = [self.salutronSDK getCalibrationData:self.indexOfCalibrationData];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
        }
        else {
            [self startSyncOnUserProfile];
            
            [Flurry endTimedEvent:DEVICE_GET_CALIBRATION_DATA withParameters:nil];
            [Flurry logEvent:DEVICE_GET_USER_PROFILE timed:YES];
            Status getStatus = [self.salutronSDK getUserProfile];
            if (getStatus != NO_ERROR) {
                [self handleError:status];
                return;
            }
        }
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didGetUserProfile:(SalutronUserProfile *)userProfile withStatus:(Status)status
{
    DDLogInfo(@"-----> USER PROFILE:%@ | %@", userProfile, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> USER PROFILE:%@ | %@", userProfile, [ErrorCodeToStringConverter convertToString:status]);
    
    if (status == NO_ERROR) {
        self.salutronUserProfile = userProfile;
        //[self startSyncOnTimeAndDate];
        
        [Flurry endTimedEvent:DEVICE_GET_USER_PROFILE withParameters:nil];
        [Flurry logEvent:DEVICE_GET_TIME timed:YES];
        
        /*Status getStatus = [self.salutronSDK getCurrentTimeAndDate];
        if (getStatus != NO_ERROR) {
            [self handleError:status];
            return;
        }*/
        
        [Flurry endTimedEvent:DEVICE_START_SYNC withParameters:nil];
        
        if (!self.userDefaultsManager.macAddress) {
            [self.salutronSaveData saveMacAddress];
        }
        
        [self.salutronSaveData saveFirmwareVersion];
        [self.salutronSaveData saveSoftwareVersion];
        [self syncingCompleted];
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didGetCurrentTimeAndDate:(TimeDate *)timeDate withStatus:(Status)status
{
    DDLogInfo(@"-----> TIME DATE:%@ | %@", timeDate, [ErrorCodeToStringConverter convertToString:status]);
    DDLogError(@"-----> TIME DATE:%@ | %@", timeDate, [ErrorCodeToStringConverter convertToString:status]);
    [Flurry endTimedEvent:DEVICE_GET_TIME withParameters:nil];
    //[Flurry endTimedEvent:DEVICE_START_SYNC withParameters:nil];
    if (status == NO_ERROR) {
        self.timeDate = timeDate;
        
        /*if (!self.userDefaultsManager.macAddress) {
            [self.salutronSaveData saveMacAddress];
        }
        
        [self.salutronSaveData saveFirmwareVersion];
        [self.salutronSaveData saveSoftwareVersion];
        [self syncingCompleted];*/
        
        if (self.userDefaultsManager.autoSyncTimeEnabled) {
            TimeDate *tempTimeDate      = [[TimeDate alloc] initWithDate:[NSDate date]];
            tempTimeDate.hourFormat     = timeDate.hourFormat;
            tempTimeDate.dateFormat     = timeDate.dateFormat;
            tempTimeDate.watchFace      = timeDate.watchFace;
            
            [self.salutronSDK updateTimeAndDate:tempTimeDate];
        }
        
        [Flurry logEvent:DEVICE_START_SYNC timed:YES];
        //[Flurry logEvent:DEVICE_GET_DATA_HEADER timed:YES];
        //[self performSelector:@selector(delayedGetStatisticalDataHeaders) withObject:nil afterDelay:getStatisticalHeaderDelay];
        /*dispatch_after(dispatch_time(DISPATCH_TIME_NOW, getStatisticalHeaderDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self delayedGetStatisticalDataHeaders];
        });*/
    }
    else {
        [self handleError:status];
        return;
    }
}

- (void)didUpdateTimeAndDateWithStatus:(Status)status
{
    DDLogInfo(@"");
    [Flurry logEvent:DEVICE_GET_DATA_HEADER timed:YES];
    [self delayedGetStatisticalDataHeaders];
}

#pragma mark - Filter Statistical Data Headers

- (void)filterStatisticalDataHeaders:(NSArray *)statisticalDataHeaderArray
{
    self.filteredStatisticalDataHeaders = [statisticalDataHeaderArray mutableCopy];
    [self.dataPointsArray removeAllObjects];
    [self.wakeUpArray removeAllObjects];
    [self.calibrationDataArray removeAllObjects];
    [self.workoutStopDatabase removeAllObjects];
    [self.inactiveAlertDataArray removeAllObjects];
    [self.nightLightAlertDataArray removeAllObjects];
    [self.dayLightAlertDataArray removeAllObjects];
    
    DDLogError(@"data headers: %@", statisticalDataHeaderArray);
    
    [self.headerIndexes removeAllObjects];
    
    /*if (self.userDefaultsManager.macAddress) {
        
        StatisticalDataHeaderEntity *headerEntity = nil;
        
        for (NSInteger i = 0; i < statisticalDataHeaderArray.count; i++) {
            
            id dataHeader = statisticalDataHeaderArray[i];
            
            BOOL headerExists = [self.salutronLibrary isStatisticalDataHeaderExists:self.statisticalDataHeaders[i]
                                                                             entity:&headerEntity];
            
            if (!headerExists ||
                (headerExists && ![self isDataPointComplete:headerEntity])) {
                self.indexOfDataHeader = i;
                self.indexOfDataHeaderForLightDataPoint = i;
                [self.headerIndexes addObject:@(i)];
                //break;
            }
            else {
                [self.filteredStatisticalDataHeaders removeObject:dataHeader];
            }
        }
    }*/
    
    StatisticalDataHeaderEntity *headerEntity = nil;
    
    for (NSInteger i = 0; i < statisticalDataHeaderArray.count; i++) {
        
        id dataHeader = statisticalDataHeaderArray[i];
        
        if (self.userDefaultsManager.macAddress) {
            BOOL headerExists = [self.salutronLibrary isStatisticalDataHeaderExists:self.statisticalDataHeaders[i]
                                                                             entity:&headerEntity];
            
            if (!headerExists ||
                (headerExists && ![self isDataPointComplete:headerEntity])) {
                self.indexOfDataHeader = i;
                self.indexOfDataHeaderForLightDataPoint = i;
                [self.headerIndexes addObject:@(i)];
                //break;
            }
            else {
                [self.filteredStatisticalDataHeaders removeObject:dataHeader];
            }
        } else {
            [self.headerIndexes addObject:@(i)];
        }
    }
    
    DDLogError(@"header index count: %i", self.headerIndexes.count);
}

#pragma mark - Filter Device name

- (void)filterDeviceDetail:(NSArray*) deviceDetails watchIndex:(NSInteger*)index
{
    for (DeviceDetail *deviceDetail in deviceDetails) {
        NSString *deviceName = deviceDetail.peripheral.name;
        
        if (deviceName) {
            BOOL value1 = [deviceName rangeOfString:@"lifetrak" options:NSCaseInsensitiveSearch].location != NSNotFound;
            BOOL value2 = [deviceName rangeOfString:@"r450" options:NSCaseInsensitiveSearch].location != NSNotFound;
            
            if (value1 || value2) {
                *index = [deviceDetails indexOfObject:deviceDetail];
                return;
            }
        }
    }
    *index = -1;
}

#pragma mark - Syncing completed

- (void)syncingCompleted
{
    // Save device entity
    [self.salutronSaveData saveDeviceEntityWithDeviceDetail:self.deviceDetail];
    self.deviceEntity = [self.salutronLibrary deviceEntityWithMacAddress:self.userDefaultsManager.macAddress];
    
    if (self.syncType == SyncTypeBackground) {
        [self saveDashboardData];
    }
    else {
        // Compare the app and watch settings before saving other data
        InactiveAlert *inactiveAlert = nil;
        [self.salutronSaveData saveInactiveAlertArray:self.inactiveAlertDataArray inactiveAlert:&inactiveAlert];
        
        DayLightAlert *dayLightAlert = nil;
        [self.salutronSaveData saveDayLightAlertArray:self.dayLightAlertDataArray dayLightAlert:&dayLightAlert];
        
        NightLightAlert *nightLightAlert = nil;
        [self.salutronSaveData saveNightLightAlertArray:self.nightLightAlertDataArray nightLightAlert:&nightLightAlert];
        
        Wakeup *wakeup = nil;
        [self.salutronSaveData saveWakeupAlertArray:self.wakeUpArray wakeupAlert:&wakeup];
        
        BOOL settingsChanged = [self settingsChangedWithWatchTimeDate:self.timeDate salutronuserProfile:self.salutronUserProfile stepGoal:self.stepGoal distanceGoal:self.distanceGoal calorieGoal:self.calorieGoal sleepSettings:self.sleepSetting notification:self.notification inactiveAlert:inactiveAlert dayLightAlert:dayLightAlert nightLightAlert:nightLightAlert wakeupAlert:wakeup];
        
        if (settingsChanged && self.syncType != SyncTypeInitial) {
            [self settingsChanged];
        }
        else {
            [self saveWatchData];
        }
    }
}

#pragma mark - Save methods

- (void)saveDashboardData
{
    self.deviceEntity = [self.salutronSaveData saveWatchDataWithDeviceEntity:self.deviceEntity statisticalDataHeaders:self.filteredStatisticalDataHeaders dataPoints:self.dataPointsArray lightDataPoints:self.lightDataPointsArray workoutDB:self.workoutDatabase workoutStopDB:self.workoutStopDatabase sleepDB:self.sleepDatabase];
    self.syncingFinished  = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
}

- (void)saveWatchData
{
    DDLogInfo(@"");
    
    // Save salutron user profile before performing didSyncFinished
    [self.salutronSaveData saveSalutronUserProfile:self.salutronUserProfile];
    self.userDefaultsManager.salutronUserProfile = self.salutronUserProfile;
    
    /*if (self.userDefaultsManager.autoSyncTimeEnabled) {
        TimeDate *timeDate      = [[TimeDate alloc] initWithDate:[NSDate date]];
        timeDate.hourFormat     = self.timeDate.hourFormat;
        timeDate.dateFormat     = self.timeDate.dateFormat;
        
        [self.salutronSDK updateTimeAndDate:timeDate];
    }*/
    
    
    self.deviceEntity = [self.salutronSaveData saveWatchDataWithDeviceEntity:self.deviceEntity statisticalDataHeaders:self.filteredStatisticalDataHeaders dataPoints:self.dataPointsArray workoutDB:self.workoutDatabase workoutStopDB:self.workoutStopDatabase sleepDB:self.sleepDatabase wakeUpArray:self.wakeUpArray stepGoal:self.stepGoal distanceGoal:self.distanceGoal calorieGoal:self.calorieGoal notification:self.notification sleepSetting:self.sleepSetting calibrationDataArray:self.calibrationDataArray salutronUserProfile:self.salutronUserProfile timeDate:self.timeDate lightDataPoints:self.lightDataPointsArray inactiveAlertArray:self.inactiveAlertDataArray dayLightAlertArray:self.dayLightAlertDataArray nightLightAlertArray:self.nightLightAlertDataArray notificationStatus:self.userDefaultsManager.notificationStatus timing:self.timing];
    
    //[self performSelector:@selector(finishedSyncing) withObject:nil afterDelay:0.5f];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_USEC), dispatch_get_main_queue(), ^{
        [self finishedSyncing];
    });
}

- (void)didGetBattLevel:(NSString *)battLevelString withStatus:(Status)status
{
    DDLogInfo(@"");
}

- (BOOL)isLifeTrakWatch:(int)index
{
    DeviceDetail *deviceDetail = nil;
    [self.salutronSDK clearDiscoveredDevice];
    [self.salutronSDK getDeviceDetail:index with:&deviceDetail];
    
    if (deviceDetail) {
        NSString *deviceName = deviceDetail.peripheral.name;
        
        if (deviceName) {
            BOOL value = [deviceName rangeOfString:@"lifetrak" options:NSCaseInsensitiveSearch].length > -1;
            return value;
        }
    }
    
    return NO;
}

@end
