//
//  SFASalutronRModelSync.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/8/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFASalutronSync.h"
#import "SFASalutronSyncDelegate.h"

@protocol SFASalutronSyncDelegate;

@class DeviceEntity, StatisticalDataHeader, StatisticalDataHeaderEntity;

@interface SFASalutronRModelSync : SFASalutronSync <SalutronSDKDelegate>

@property (assign, nonatomic) int retryCount;
@property (assign, nonatomic, getter=isSearchConnectedDevice) BOOL searchConnectedDevice;
@property (assign, nonatomic) int retryRetrieveCount;
@property (assign, nonatomic,getter=isSyncStopped) BOOL syncStopped;
@property (assign, nonatomic) BOOL initialSync;

- (void)saveWatchData;

- (void)saveDashboardData;

- (void)retrieveConnectedDevice;

- (void)stopSync;

@end

