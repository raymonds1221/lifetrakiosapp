//
//  SFASalutronSyncC300.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/19/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFASalutronSyncDelegate.h"

#import "DeviceEntity.h"
#import "SalutronSDK.h"

@protocol SFASalutronSyncDelegate;

@interface SFASalutronSyncC300 : NSObject<SalutronSDKDelegate>

@property (strong, nonatomic) SalutronSDK *salutronSDK;
@property (assign, nonatomic, getter = isUpdateTimeAndDate) BOOL updateTimeAndDate;
@property (readwrite, nonatomic) BOOL updatedSettings;
@property (assign, nonatomic) BOOL watchSettingsSelected;
@property (assign, nonatomic) BOOL initialSync;

@property (weak, nonatomic) id<SFASalutronSyncDelegate> delegate;

- (id) initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)startSyncWithWatchModel:(WatchModel)watchModel;
- (void)startSyncWithDeviceEntity:(DeviceEntity *)deviceEntity watchModel:(WatchModel)watchModel;
//- (void)checkConnectedDevice;
- (void)disconnectWatch;

- (void)deleteDevice;

- (void)useAppSettings;
- (void)useWatchSettings;

@end