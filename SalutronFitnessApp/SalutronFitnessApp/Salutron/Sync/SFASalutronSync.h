//
//  SFASalutronSync.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 6/13/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronSync.h"
#import "ErrorCodeToStringConverter.h"
#import "SFASalutronSyncDelegate.h"
#import "SFASalutronLibrary.h"
#import "SFASalutronSaveData.h"

static float const discoverTimeout = 3.0f;

typedef NS_ENUM(NSInteger, SyncType) {
    SyncTypeAll = 0,
    SyncTypeInitial,
    SyncTypeBackground
};

@interface SFASalutronSync : NSObject

@property (strong, nonatomic) SalutronSDK                       *salutronSDK;
@property (strong, nonatomic) SFASalutronSaveData               *salutronSaveData;
@property (strong, nonatomic) SFAUserDefaultsManager            *userDefaultsManager;
@property (strong, nonatomic) DeviceEntity                      *deviceEntity;
@property (assign, nonatomic) BOOL                              syncingFinished;
@property (assign, nonatomic) int                               indexOfRetrievedDevice;
@property (nonatomic) SyncType                                  syncType;
@property (strong, nonatomic) DeviceDetail                      *connectedDevice;
@property (assign, nonatomic, getter=isConnectDevice) BOOL      connectDevice;
@property (assign, nonatomic, getter=isDeviceFound) BOOL        deviceFound;

// Dont forget to set the values of these properties before syncing

@property (weak, nonatomic)   id<SFASalutronSyncDelegate>       delegate;
@property (assign, nonatomic) WatchModel                        selectedWatchModel;
@property (assign, nonatomic) WatchModel                        watchModel;

- (void)startBackgroundSyncWithErrorHandler:(void(^)(Status status))errorHandler;

- (void)startSync;

- (void)stopSync;

//- (void)useWatchSettings;

- (void)useAppSettingsWithDelegate:(id)delegate;
- (void)useWatchSettingsWithDelegate:(id)delegate;

- (void)deleteDevice;

- (void)searchConnectedDevice;

- (void)setRModelSyncType:(SyncType) syncType;

- (NSString *)convertAndroidToiOSMacAddress:(NSString*) macAddress;

@end
