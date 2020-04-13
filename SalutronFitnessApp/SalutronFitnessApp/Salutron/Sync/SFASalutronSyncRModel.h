//
//  SFASalutronSyncRModel.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 6/13/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronSync.h"
#import "SFASalutronSyncDelegate.h"

@protocol SFASalutronSyncDelegate;

@class DeviceEntity, StatisticalDataHeader, StatisticalDataHeaderEntity;

@interface SFASalutronSyncRModel : SFASalutronSync <SalutronSDKDelegate>

@property (assign, nonatomic) int retryCount;
@property (assign, nonatomic, getter=isSearchConnectedDevice) BOOL searchConnectedDevice;
@property (assign, nonatomic) int retryRetrieveCount;
@property (assign, nonatomic,getter=isSyncStopped) BOOL syncStopped;


- (void)saveWatchData;

- (void)saveDashboardData;

- (void)retrieveConnectedDevice;

- (void)stopSync;

@end

