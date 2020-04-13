//
//  SFASalutronSync.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 6/13/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronSync.h"
#import "SFASalutronSync+Utilities.h"
#import "SFASalutronSyncRModel.h"
#import "SFASalutronRModelSync.h"
#import "JDACoreData.h"
#import "SFASalutronUpdateManager.h"
#import "WakeupEntity+Data.h"
#import "Wakeup+Entity.h"
#import "TimeDate+Data.h"

@interface SFASalutronSync ()

@property (strong, nonatomic) SFASalutronRModelSync     *salutronSyncRModel;
@property (strong, nonatomic) NSManagedObjectContext    *managedObjectContext;
@property (strong, nonatomic) SFASalutronUpdateManager  *updateManager;
@property (assign, nonatomic,getter=isSyncStopped) BOOL  syncStopped;
@property (strong, nonatomic) NSOperationQueue          *operationQueue;

@end

@implementation SFASalutronSync

#pragma mark - Lazy loading of properties

- (SalutronSDK *)salutronSDK
{
    if (!_salutronSDK) {
        _salutronSDK = [SalutronSDK sharedInstance];
    }
    return _salutronSDK;
}

- (SFASalutronRModelSync *)salutronSyncRModel
{
    if (!_salutronSyncRModel) {
        _salutronSyncRModel = [[SFASalutronRModelSync alloc] init];
        _salutronSyncRModel.initialSync = NO;
        _salutronSyncRModel.syncType = SyncTypeAll;
    }
    return _salutronSyncRModel;
}

- (SFASalutronUpdateManager *)updateManager
{
    if (!_updateManager) {
        _updateManager  = [SFASalutronUpdateManager sharedInstance];
    }
    return _updateManager;
}

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

- (SFASalutronSaveData *)salutronSaveData
{
    if (!_salutronSaveData) {
        _salutronSaveData  = [[SFASalutronSaveData alloc] init];
    }
    return _salutronSaveData;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        _managedObjectContext = [JDACoreData sharedManager].context;
    }
    return _managedObjectContext;
}

- (DeviceDetail *) connectedDevice
{
    return [self.salutronSDK getConnectedDeviceDetail];
}

- (NSOperationQueue *)operationQueue
{
    if (!_operationQueue) {
        _operationQueue = [NSOperationQueue mainQueue];
    }
    return _operationQueue;
}

#pragma mark - Sync

- (void)startBackgroundSyncWithErrorHandler:(void(^)(Status status))errorHandler
{
    DDLogInfo(@"");
    
    if (self.selectedWatchModel == WatchModel_R450) {
        self.indexOfRetrievedDevice = 0;
        self.salutronSyncRModel.syncType = SyncTypeBackground;
        self.salutronSDK.delegate = self.salutronSyncRModel;
        [self.salutronSDK clearDiscoveredDevice];
        Status status = [self.salutronSDK retrieveConnectedDevice];
        
        if (status != NO_ERROR) {
            errorHandler(status);
            DDLogInfo(@"%@", [ErrorCodeToStringConverter convertToString:status]);
        }
    }
    else {
        errorHandler(ERROR_DISCOVER);
        DDLogInfo(@"Watch is not R415 : Discover Error");
    }
}

- (void)startSync
{
    DDLogInfo(@"");
    
    self.syncStopped = NO;
    self.watchModel = WatchModel_Not_Set;
    self.indexOfRetrievedDevice = 0;
    
    if (self.selectedWatchModel == WatchModel_R450 || self.selectedWatchModel == WatchModel_R500) {
        
        // Calling get mac address just to prepare the SDK
        // this is kind of a hack, but who cares... works for all cases ;)
        self.salutronSDK.delegate = self.salutronSyncRModel;
        self.salutronSyncRModel.syncType = self.syncType;
        self.salutronSyncRModel.syncStopped = self.syncStopped;
        NSString *macAddress                = nil;
        [self.salutronSDK getMacAddress:&macAddress];
        [self performSelector:@selector(RModelFetch) withObject:nil afterDelay:0.5f];
    }
    else {
        self.salutronSDK.delegate = nil; //salutronSyncCModel
        [self CModelFetch];
    }
}

- (void)stopSync
{
    self.syncStopped                    = YES;
    self.salutronSyncRModel.syncStopped = self.syncStopped;
    self.salutronSyncRModel.delegate     = nil;
    self.salutronSDK.delegate           = nil;
    
    [self.salutronSyncRModel stopSync];
    [self.operationQueue cancelAllOperations];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
}

- (void)RModelFetch
{
    Status status;
    
    //self.salutronSyncRModel.searchConnectedDevice = NO;
    self.salutronSyncRModel.syncType = self.syncType;
    self.salutronSyncRModel.retryCount = 0;
    //self.salutronSyncRModel.retryRetrieveCount = 0;
    //self.salutronSyncRModel.searchConnectedDevice = NO;
   
    [self.salutronSDK clearDiscoveredDevice];
    
    if (self.syncType == SyncTypeInitial) {
        [self.salutronSDK clearDiscoveredDevice];
        status = [self.salutronSDK discoverDevice:discoverTimeout];
        DDLogInfo(@"DISCOVER DEVICE STATUS : %@", [ErrorCodeToStringConverter convertToString:status]);
    } else {
        [self.salutronSDK clearDiscoveredDevice];
        
        if (self.isDeviceFound) {
            status = [self.salutronSDK retrieveConnectedDevice];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if (!self.isSyncStopped) {
                    [self.operationQueue addOperationWithBlock:^{
                        [self.salutronSyncRModel retrieveConnectedDevice];
                    }];
                }
            });
        } else {
            status = [self.salutronSDK discoverDevice:discoverTimeout];
        }
        
        DDLogInfo(@"RETRIEVE DEVICE STATUS : %@", [ErrorCodeToStringConverter convertToString:status]);
        
        if (status != NO_ERROR) {
            [self.salutronSDK disconnectDevice];
            [self.salutronSDK clearDiscoveredDevice];
            [self.salutronSDK discoverDevice:discoverTimeout];
        }
    }

    self.salutronSyncRModel.delegate                 = self.delegate;
    self.salutronSyncRModel.syncingFinished          = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
}

- (void)CModelFetch
{
    DDLogInfo(@"");
    [self.salutronSDK discoverDevice:discoverTimeout];
}
/*
- (void)useWatchSettings
{
    DDLogInfo(@"");
    if (self.selectedWatchModel == WatchModel_R450 || self.selectedWatchModel == WatchModel_R500) {
        [self.salutronSyncRModel saveWatchData];
    }
    else {
        
    }
}
*/
- (void)useWatchSettingsWithDelegate:(id)delegate
{
    DDLogInfo(@"");
    if (self.selectedWatchModel == WatchModel_R450 || self.selectedWatchModel == WatchModel_R500) {
        self.salutronSyncRModel.delegate = delegate;
        [self.salutronSyncRModel saveWatchData];
    }
    else {
        
    }
}

- (void)useAppSettingsWithDelegate:(id)delegate
{
    DDLogInfo(@"");
    
    if (self.selectedWatchModel == WatchModel_R450 || self.selectedWatchModel == WatchModel_R500) {

        self.updateManager.delegate = delegate;
        
        [self.updateManager startUpdateAllWithWatchModel:self.userDefaultsManager.watchModel salutronUserProfile:self.userDefaultsManager.salutronUserProfile sleepSetting:self.userDefaultsManager.sleepSetting distanceGoal:self.userDefaultsManager.distanceGoal calorieGoal:self.userDefaultsManager.calorieGoal stepGoal:self.userDefaultsManager.stepGoal sleepGoal:self.userDefaultsManager.sleepGoal timeDate:[TimeDate getUpdatedData] wakeUp:[[Wakeup alloc] initWithEntity:[WakeupEntity getWakeup]] calibrationData:self.userDefaultsManager.calibrationData notification:self.userDefaultsManager.notification inactiveAlert:self.userDefaultsManager.inactiveAlert dayLightAlert:self.userDefaultsManager.dayLightAlert nightLightAlert:self.userDefaultsManager.nightLightAlert notificationStatus:self.userDefaultsManager.notificationStatus timing:self.userDefaultsManager.timing];
        
        [self.salutronSyncRModel saveDashboardData];
    }
    else {
        
    }
}

#pragma mark - Delete device

- (void)deleteDevice
{
    DDLogInfo(@"");
    
    self.deviceEntity = [DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress];

    if (self.deviceEntity.modelNumber.integerValue == WatchModel_R450) {
        [[JDACoreData sharedManager].context deleteObject:self.deviceEntity];
        [[JDACoreData sharedManager].context save:nil];
        self.deviceEntity = nil;
    }
    
    if (self.deviceEntity) {
        [self.managedObjectContext deleteObject:self.deviceEntity];
        [self.managedObjectContext save:nil];
        self.deviceEntity = nil;
    }
}

#pragma mark - Search Connected Device

- (void)searchConnectedDevice
{
    self.salutronSyncRModel.searchConnectedDevice       = YES;
    self.salutronSyncRModel.delegate                    = self.delegate;
    self.salutronSDK.delegate                           = self.salutronSyncRModel;
    self.salutronSyncRModel.retryRetrieveCount          = 0;
    self.salutronSyncRModel.connectDevice               = self.connectDevice;
    
    [self.salutronSDK clearDiscoveredDevice];
    
    [self startRetrieveConnectedDeviceFromSearching];
    
    [self.salutronSDK retrieveConnectedDevice];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (!self.isSyncStopped) {
            [self.operationQueue addOperationWithBlock:^{
                [self.salutronSyncRModel retrieveConnectedDevice];
            }];
        }
    });
}

- (void) setRModelSyncType:(SyncType)syncType
{
    self.salutronSyncRModel.syncType = syncType;
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

@end
