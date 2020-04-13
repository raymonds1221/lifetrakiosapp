//
//  SFASalutronSyncCModel.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 1/27/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronSyncCModel.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFASalutronLibrary.h"

#import "ErrorCodeToStringConverter.h"
#import "TimeDate+Data.h"
#import "Notification+Coding.h"
#import "SleepSetting+SleepSettingCategory.h"
#import "CalibrationData+CalibrationDataCategory.h"
#import "SalutronUserProfile+SalutronUserProfileCategory.h"
#import "StatisticalDataHeader.h"
#import "ModelNumber+NSCopying.h"

#define DISCOVER_TIMEOUT 3.0f

@interface SFASalutronSyncCModel () <SalutronSDKDelegate>

@property (strong, nonatomic) SalutronSDK                                   *salutronSDK;
@property (strong, nonatomic) SFASalutronLibrary                            *salutronLibrary;
@property (strong, nonatomic) NSMutableArray                                *statisticalDataHeaders;
@property (strong, nonatomic) NSMutableArray                                *dataPoints;
@property (strong, nonatomic) Notification                                  *notification;
@property (strong, nonatomic) SleepSetting                                  *sleepSetting;
@property (strong, nonatomic) CalibrationData                               *calibrationData;
@property (strong, nonatomic) NSArray                                       *workoutDatabases;
@property (strong, nonatomic) NSArray                                       *sleepDatabases;
@property (strong, nonatomic) SalutronUserProfile                           *userProfile;
@property (strong, nonatomic) NSMutableArray                                *headerIndexes;
@property (strong, nonatomic) NSString                                      *macAddress;
@property (strong, nonatomic) ModelNumber                                   *modelNumber;

@property (assign, nonatomic, setter = setUpdateTimeAndDate:) BOOL          isUpdateTimeAndDate;
@property (assign, nonatomic) NSInteger                                     stepGoal;
@property (assign, nonatomic) NSInteger                                     distanceGoal;
@property (assign, nonatomic) NSInteger                                     calorieGoal;
@property (assign, nonatomic) WatchModel                                    currentWatchModel;

@end

@implementation SFASalutronSyncCModel

@synthesize salutronSDK;
@synthesize salutronLibrary;
@synthesize isUpdateTimeAndDate;
@synthesize currentWatchModel;
@synthesize macAddress;

static bool const enableNotifyChecksum = YES;
static bool const enableNotifyError = YES;
static bool const selectorDelay = 0;
static short int deviceIndex = 0;

+ (SFASalutronSyncCModel *)salutronSyncC300 {
    @synchronized(self) {
        static SFASalutronSyncCModel *salutronSyncC300CModel;
        
        if(salutronSyncC300CModel == nil)
            salutronSyncC300CModel = [[SFASalutronSyncCModel alloc] init];
        
        return salutronSyncC300CModel;
    }
}

- (id)init
{
    if(self = [super init]) {
        salutronSDK = [SalutronSDK sharedInstance];
        
        SFASalutronFitnessAppDelegate *appDelegate = (SFASalutronFitnessAppDelegate *) [UIApplication sharedApplication].delegate;
        salutronLibrary = [[SFASalutronLibrary alloc] initWithManagedObjectContext:appDelegate.managedObjectContext];
        
        _statisticalDataHeaders = [[NSMutableArray alloc] init];
        _dataPoints = [[NSMutableArray alloc] init];
        _headerIndexes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)startSyncWithWatchModel:(WatchModel)watchModel
{
    salutronSDK.delegate = self;
    currentWatchModel = watchModel;
    
    if(currentWatchModel == WatchModel_Move_C300 ||
       currentWatchModel == WatchModel_Move_C300_Android ||
       currentWatchModel == WatchModel_Zone_C410 ||
       currentWatchModel == WatchModel_R420) {
        [salutronSDK discoverDevice:DISCOVER_TIMEOUT];
    } else {
        [salutronSDK retrieveConnectedDevice];
        DDLogInfo(@"RETRIEVE CONNECTED DEVICE");
    }
}

#pragma mark - Private Methods

- (void)_didChecksumError
{
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didChecksumError)]) {
        [self.delegate didChecksumError];
    }
}

- (void)_didRaiseError:(Status)status
{
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didRaiseErrorWithStatus:)]) {
        [self.delegate didRaiseErrorWithStatus:status];
    }
}

- (void)_updateTimeAndDate
{
    Status s1 = ERROR_UPDATE;
    
    if(isUpdateTimeAndDate) {
        TimeDate *now = [[TimeDate alloc] initWithDate:[NSDate date]];
        Status s0 = [salutronSDK updateTimeAndDate:now];
        
        if(s0 != NO_ERROR) {
            s1 = [salutronSDK getStatisticalDataHeaders];
        }
    } else {
        s1 = [salutronSDK getStatisticalDataHeaders];
    }
    
    if(s1 != NO_ERROR) {
        DDLogError(@"getStatisticalDataHeaders status: %@", [ErrorCodeToStringConverter convertToString:s1]);
        [self _didRaiseError:s1];
    }
}

- (void)_getStatisticalDataHeaders
{
    Status s0 = [salutronSDK getStatisticalDataHeaders];
    
    if(s0 != NO_ERROR) {
        DDLogError(@"getStatisticalDataHeaders status: %@", [ErrorCodeToStringConverter convertToString:s0]);
        [self _didRaiseError:s0];
    }
}

- (void)_getDataPoints:(NSNumber *) index
{
    Status s0 = [salutronSDK getDataPointsOfSelectedDateStamp:index.integerValue];
    
    if(s0 != NO_ERROR) {
        DDLogError(@"getDataPointsOfSelectedDateStamp status: %@", [ErrorCodeToStringConverter convertToString:s0]);
        [self _didRaiseError:s0];
    }
}

- (void)_getStepGoal
{
    Status s0 = [salutronSDK getStepGoal];
    
    if(s0 != NO_ERROR) {
        DDLogError(@"getStepGoal status: %@", [ErrorCodeToStringConverter convertToString:s0]);
        [self _didRaiseError:s0];
    }
}

- (void)_getDistanceGoal
{
    Status s0 = [salutronSDK getDistanceGoal];
    
    if(s0 != NO_ERROR) {
        DDLogError(@"getDistanceGoal status: %@", [ErrorCodeToStringConverter convertToString:s0]);
        [self _didRaiseError:s0];
    }
}

- (void)_getCalorieGoal
{
    Status s0 = [salutronSDK getCalorieGoal];
    
    if(s0 != NO_ERROR) {
        DDLogError(@"getCalorieGoal status: %@", [ErrorCodeToStringConverter convertToString:s0]);
        [self _didRaiseError:s0];
    }
}

- (void)_getNotification
{
    Status s0 = [salutronSDK getNotification];
    
    if(s0 == ERROR_DEVICE_NOT_SUPPORTED) {
        [self _getSleepSetting];
    } else if(s0 != NO_ERROR) {
        DDLogError(@"getNotification status: %@", [ErrorCodeToStringConverter convertToString:s0]);
        [self _didRaiseError:s0];
    }
}

- (void)_getSleepSetting
{
    Status s0 = [salutronSDK getSleepSetting];
    
    if(s0 == ERROR_DEVICE_NOT_SUPPORTED) {
        [self _getCalibrationData:0];
    } else if(s0 != NO_ERROR) {
        DDLogError(@"getSleepSetting status: %@", [ErrorCodeToStringConverter convertToString:s0]);
        [self _didRaiseError:s0];
    }
}

- (void)_getCalibrationData:(NSNumber *)calibrationType
{
    Status s0 = [salutronSDK getCalibrationData:calibrationType.integerValue];
    
    if(s0 == ERROR_DEVICE_NOT_SUPPORTED) {
        [self _getWorkoutDatabase];
    } else if(s0 != NO_ERROR) {
        DDLogError(@"getCalibrationData status: %@", [ErrorCodeToStringConverter convertToString:s0]);
        [self _didRaiseError:s0];
    }
}

- (void)_getWorkoutDatabase
{
    Status s0 = [salutronSDK getWorkoutDatabase];
    
    if(s0 == ERROR_DEVICE_NOT_SUPPORTED) {
        [self _getSleepDatabase];
    } else if(s0 != NO_ERROR) {
        DDLogError(@"getWorkoutDatabase status: %@", [ErrorCodeToStringConverter convertToString:s0]);
        [self _didRaiseError:s0];
    }
}

- (void)_getSleepDatabase {
    Status s0 = [salutronSDK getSleepDatabase];
    
    if(s0 == ERROR_DEVICE_NOT_SUPPORTED) {
        [self _getUserProfile];
    } else if(s0 != NO_ERROR) {
        DDLogError(@"getSleepDatabase status: %@", [ErrorCodeToStringConverter convertToString:s0]);
        [self _didRaiseError:s0];
    }
}

- (void)_getUserProfile {
    Status s0 = [salutronSDK getUserProfile];
    
    if(s0 != NO_ERROR) {
        DDLogError(@"getUserProfile status: %@", [ErrorCodeToStringConverter convertToString:s0]);
        [self _didRaiseError:s0];
    }
}


#pragma mark - SalutronSDKDelegate (required)

- (void)didDisconnectDevice:(Status)status
{
    DDLogError(@"device disconnected");
}

- (void)didDiscoverDevice:(int)numDevice withStatus:(Status)status
{
    if(numDevice > 0) {
        if(status == UPDATE) {
            Status s0 = [salutronSDK connectDevice:deviceIndex];
            
            if(s0 != NO_ERROR) {
                DDLogError(@"connectDevice status: %@", [ErrorCodeToStringConverter convertToString:s0]);
                [self _didRaiseError:s0];
            }
            deviceIndex++;
        }
    } else {
        if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
           [self.delegate respondsToSelector:@selector(didDiscoverTimeout)]) {
            [self.delegate didDiscoverTimeout];
        }
    }
}

- (void)didRetrieveConnectedDevice:(int)numDevice withStatus:(Status)status
{
    if(numDevice > 0) {
        
    } else {
        [salutronSDK discoverDevice:DISCOVER_TIMEOUT];
    }
}

- (void)didConnectAndSetupDeviceWithStatus:(Status)status
{
    NSString *tempMacAddress = nil;
    
    Status s0 = [salutronSDK getMacAddress:&tempMacAddress];
    DDLogInfo(@"\n---------------> STATUS: %@ ---> MAC ADDRESS : %@ ---> MAC ADDRESS STATUS : %@\n", Status_toString[status], tempMacAddress, [ErrorCodeToStringConverter convertToString:s0]);
    
    DDLogError(@"getMacAddress status: %@", [ErrorCodeToStringConverter convertToString:s0]);
    
    NSString *firmwareRevision = @"";
    Status _status = [self.salutronSDK getFirmwareRevision:&firmwareRevision];
    
    if (_status == NO_ERROR) {
        DDLogError(@"%@", firmwareRevision);
    }
    
    NSString *softwareRevision = @"";
    _status = [self.salutronSDK getSoftwareRevision:&softwareRevision];
    
    if (_status == NO_ERROR) {
        DDLogError(@"%@", softwareRevision);
    }

    if(status == NO_ERROR && tempMacAddress != nil) {
        macAddress = tempMacAddress.copy;
        
        Status s1 = [salutronSDK getModelNumber];
        
        if(s1 != NO_ERROR) {
            DDLogError(@"getModelNumber status: %@", [ErrorCodeToStringConverter convertToString:s1]);
            [self _didRaiseError:s1];
        }
    }
}

- (void)didGetModelNumber:(ModelNumber *)modelNumber withStatus:(Status)status
{
    self.modelNumber = [modelNumber copy];
    [self performSelector:@selector(_updateTimeAndDate) withObject:nil afterDelay:selectorDelay];
}

- (void)didGetBattLevel:(NSString *)battLevelString withStatus:(Status)status
{
    
}

#pragma mark - SalutronSDKDelegate (optional)

- (void)didUpdateTimeAndDateWithStatus:(Status)status
{
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        [self _didChecksumError];
        return;
    }
    if(status != NO_ERROR && enableNotifyError) {
        [self _didRaiseError:status];
        return;
    }
    
    Status s0 = [salutronSDK getStatisticalDataHeaders];
    
    if(s0 == NO_ERROR) {
        [self performSelector:@selector(getStatisticalDataHeaders) withObject:Nil afterDelay:selectorDelay];
    } else {
        [self _didRaiseError:status];
    }
}

- (void)didGetStatisticalDataHeaders:(NSArray *)statisticalDataHeaders withStatus:(Status)status
{
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        [self _didChecksumError];
        return;
    }
    if(status != NO_ERROR && enableNotifyError) {
        [self _didRaiseError:status];
        return;
    }
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnDataHeaders)]) {
        [self.delegate didSyncOnDataHeaders];
    }
    
    for(StatisticalDataHeader *statisticalDataHeader in statisticalDataHeaders) {
        StatisticalDataHeaderEntity *dataHeaderEntity = nil;
        
        if([salutronLibrary isStatisticalDataHeaderExists:statisticalDataHeader entity:&dataHeaderEntity] ||
           dataHeaderEntity.dataPoint.count < 144) {
            [_statisticalDataHeaders addObject:dataHeaderEntity];
            [_headerIndexes addObject:[NSNumber numberWithInteger:[statisticalDataHeaders indexOfObject:statisticalDataHeader]]];
        }
    }
    
    if(_headerIndexes.count > 0) {
        NSNumber *headerIndex = [_headerIndexes objectAtIndex:0];
        [self performSelector:@selector(_getDataPoints:) withObject:headerIndex afterDelay:selectorDelay];
    }
}

- (void)didGetDataPointsOfSelectedDateStamp:(NSArray *)dataPoints withStatus:(Status)status
{
    static NSInteger index = 1;
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        [self _didChecksumError];
        return;
    }
    if(status != NO_ERROR && enableNotifyError) {
        [self _didRaiseError:status];
        return;
    }
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnDataPoints:)]) {
        [self.delegate didSyncOnDataPoints:0];
    }
    
    [_dataPoints addObject:[dataPoints copy]];
    
    if(index < _headerIndexes.count) {
        NSNumber *headerIndex = [_headerIndexes objectAtIndex:index];
        [self performSelector:@selector(_getDataPoints:) withObject:headerIndex afterDelay:selectorDelay];
        index++;
    } else {
        [self performSelector:@selector(_getStepGoal) withObject:nil afterDelay:selectorDelay];
    }
}

- (void)didGetStepGoal:(int)stepGoal withStatus:(Status)status
{
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        [self _didChecksumError];
        return;
    }
    if(status != NO_ERROR && enableNotifyError) {
        [self _didRaiseError:status];
        return;
    }
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnStepGoal)]) {
        [self.delegate didSyncOnStepGoal];
    }
    _stepGoal = stepGoal;
    
    [self performSelector:@selector(_getDistanceGoal) withObject:nil afterDelay:selectorDelay];
}

- (void)didGetDistanceGoal:(double)distanceGoal withStatus:(Status)status
{
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        [self _didChecksumError];
        return;
    }
    if(status != NO_ERROR && enableNotifyError) {
        [self _didRaiseError:status];
        return;
    }
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnDistanceGoal)]) {
        [self.delegate didSyncOnDistanceGoal];
    }
    _distanceGoal = distanceGoal;
    if (_distanceGoal < 0) {
        _distanceGoal = 3.2;
    }
    
    [self performSelector:@selector(_getCalorieGoal) withObject:nil afterDelay:selectorDelay];
}

- (void)didGetCalorieGoal:(int)calorieGoal withStatus:(Status)status
{
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        [self _didChecksumError];
        return;
    }
    if(status != NO_ERROR && enableNotifyError) {
        [self _didRaiseError:status];
        return;
    }
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnCalorieGoal)]) {
        [self.delegate didSyncOnCalorieGoal];
    }
    _calorieGoal = calorieGoal;
    
    [self performSelector:@selector(_getNotification) withObject:nil afterDelay:selectorDelay];
}

- (void)didGetNotification:(Notification *)notify withStatus:(Status)status
{
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        [self _didChecksumError];
        return;
    }
    if(status != NO_ERROR && enableNotifyError) {
        [self _didRaiseError:status];
        return;
    }
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnNotification)]) {
        [self.delegate didSyncOnNotification];
    }
    _notification = [notify copy];
    
    [self performSelector:@selector(_getSleepSetting) withObject:nil afterDelay:selectorDelay];
}

- (void)didGetSleepSetting:(SleepSetting *)sleepSetting withStatus:(Status)status
{
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        [self _didChecksumError];
        return;
    }
    if(status != NO_ERROR && enableNotifyError) {
        [self _didRaiseError:status];
        return;
    }
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnSleepSettings)]) {
        [self.delegate didSyncOnSleepSettings];
    }
    _sleepSetting = [sleepSetting copy];
    
    [self performSelector:@selector(_getCalibrationData:) withObject:[NSNumber numberWithInteger:1] afterDelay:selectorDelay];
}

- (void)didGetCalibrationData:(CalibrationData *)calibrationData withStatus:(Status)status
{
    static NSUInteger calibrationType = 1;
    
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        [self _didChecksumError];
        return;
    }
    if(status != NO_ERROR && enableNotifyError) {
        [self _didRaiseError:status];
        return;
    }
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnCalibrationData)]) {
        [self.delegate didSyncOnCalibrationData];
    }
    
    _calibrationData = [calibrationData copy];
    
    if(calibrationType < 4) {
        [self performSelector:@selector(_getCalibrationData:) withObject:[NSNumber numberWithInteger:calibrationType] afterDelay:selectorDelay];
        calibrationType++;
    } else {
        [self performSelector:@selector(_getWorkoutDatabase) withObject:nil afterDelay:selectorDelay];
    }
}

- (void)didGetWorkoutDatabase:(NSArray *)workoutDatabase withStatus:(Status)status
{
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        [self _didChecksumError];
        return;
    }
    if(status != NO_ERROR && enableNotifyError) {
        [self _didRaiseError:status];
        return;
    }
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnWorkoutDatabase)]) {
        [self.delegate didSyncOnWorkoutDatabase];
    }
    _workoutDatabases = [workoutDatabase copy];
    
    [self performSelector:@selector(_getSleepDatabase) withObject:nil afterDelay:selectorDelay];
}

- (void)didGetSleepDatabase:(NSArray *)sleepdatabase withStatus:(Status)status
{
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        [self _didChecksumError];
        return;
    }
    if(status != NO_ERROR && enableNotifyError) {
        [self _didRaiseError:status];
        return;
    }
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnSleepDatabase)]) {
        [self.delegate didSyncOnSleepDatabase];
    }
    _sleepDatabases = [sleepdatabase copy];
    
    [self performSelector:@selector(_getUserProfile) withObject:nil afterDelay:selectorDelay];
}

- (void)didGetUserProfile:(SalutronUserProfile *)userProfile withStatus:(Status)status
{
    if(status == ERROR_CHECKSUM && enableNotifyChecksum) {
        [self _didChecksumError];
        return;
    }
    if(status != NO_ERROR && enableNotifyError) {
        [self _didRaiseError:status];
        return;
    }
    if([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)] &&
       [self.delegate respondsToSelector:@selector(didSyncOnUserProfile)]) {
        [self.delegate didSyncOnUserProfile];
    }
    _userProfile = [userProfile copy];
    
    NSString *firmwareRevision = @"";
    Status _status = [self.salutronSDK getFirmwareRevision:&firmwareRevision];
    
    if (_status == NO_ERROR) {
        DDLogError(@"%@", firmwareRevision);
    }
    
    NSString *softwareRevision = @"";
    _status = [self.salutronSDK getSoftwareRevision:&softwareRevision];
    
    if (_status == NO_ERROR) {
        DDLogError(@"%@", softwareRevision);
    }

    [salutronSDK commDone];
    salutronSDK.delegate = nil;
}

@end
