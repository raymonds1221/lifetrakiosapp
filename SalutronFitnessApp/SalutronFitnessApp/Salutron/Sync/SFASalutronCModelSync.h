//
//  SFASalutronCModelSync.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/8/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFASalutronSyncDelegate.h"

#import "DeviceEntity.h"
#import "SalutronSDK.h"

@protocol SFASalutronSyncDelegate;

@interface SFASalutronCModelSync : NSObject<SalutronSDKDelegate>

@property (strong, nonatomic) SalutronSDK *salutronSDK;
@property (assign, nonatomic, getter = isUpdateTimeAndDate) BOOL updateTimeAndDate;
@property (readwrite, nonatomic) BOOL updatedSettings;
@property (assign, nonatomic) BOOL watchSettingsSelected;@property (readwrite, nonatomic) BOOL initialSync; //delegate must only call SFASalutronCModelSync sdk delegate, without continuous syncing flow

@property (weak, nonatomic) id<SFASalutronSyncDelegate> delegate;

- (id) initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)startSyncWithWatchModel:(WatchModel)watchModel;
- (void)startSyncWithDeviceEntity:(DeviceEntity *)deviceEntity watchModel:(WatchModel)watchModel;
//- (void)connectToDeviceWithIndex:(int)deviceIndex withStatus:(Status)status;
- (void)startSyncWithWatchModel:(WatchModel)watchModel withDeviceIndex:(int)deviceIndex;
- (void)syncDataWithWatchModel:(WatchModel)watchmodel andStatus:(Status)status;
//- (void)checkConnectedDevice;
- (void)disconnectWatch;

- (void)deleteDevice;

- (void)useAppSettings;
- (void)useWatchSettings;

//Added by Tin
- (Status)discoverDevicesWithTimeout:(int)timeout;
- (Status)getDeviceDetailAt:(int)index with:(DeviceDetail **)deviceDetails;
- (Status)retrieveConnectedDevices;
- (Status)connectDeviceAt:(int)index;

@end