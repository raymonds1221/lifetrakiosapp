//
//  SFASalutronSyncDelegate.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 1/27/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceEntity+Data.h"

@protocol SFASalutronSyncDelegate <NSObject>

@required
- (void)didSyncStarted;
- (void)didSyncFinished:(DeviceEntity *)deviceEntity
         profileUpdated:(BOOL)profileUpdated;

- (void)didChangeSettings;
- (void)didSaveSettings;

@optional
- (void)didUpdateFinish;
- (void)didDeviceConnected;
- (void)didDeviceDisconnected:(BOOL)isSyncFinished;
- (void)didDiscoverTimeout;
- (void)didDiscoverTimeoutWithDiscoveredDevices:(NSArray *)discoveredDevices;
- (void)didSearchFinished;
- (void)didRetrieveDevice:(NSInteger)numDevice;
- (void)didRaiseError;
- (void)didRaiseErrorWithStatus:(Status)status;
- (void)didChecksumError;

- (void)didPairWatch;
- (void)didSyncOnDataHeaders;
- (void)didSyncOnDataPoints:(NSInteger)percent;
- (void)didSyncOnDataPoints;
- (void)didSyncOnLightDataPoints;
- (void)didSyncOnLightDataPoints:(NSInteger)percent;
- (void)didSyncOnStepGoal;
- (void)didSyncOnDistanceGoal;
- (void)didSyncOnCalorieGoal;
- (void)didSyncOnNotification;
- (void)didSyncOnAlerts;
- (void)didSyncOnSleepSettings;
- (void)didSyncOnCalibrationData;
- (void)didSyncOnWorkoutDatabase;
- (void)didSyncOnWorkoutStopDatabase;
- (void)didSyncOnSleepDatabase;
- (void)didSyncOnUserProfile;
- (void)didSyncOnTimeAndDate;
- (void)didSyncFinishOnUserProfile;

- (void)didRestoreSettings;

// Added by Bong
- (void)syncStartedWithDeviceEntity:(DeviceEntity *)deviceEntity;

// Added by Raymond
- (void)didSearchConnectedWatch:(BOOL)found;
- (void)didDeviceConnectedFromSearching;
- (void)didRetrieveDeviceFromSearching;

// Added by Tin
- (void)didDeviceDiscovered:(NSInteger)numDevice withStatus:(Status)status;
- (void)didDeviceRetrieved:(NSInteger)numDevice withStatus:(Status)status;
- (void)didDeviceConnectedWithStatus:(Status)status;

// Added by Raymond 11/10/15
- (void)didSyncOnWatchSetting;

@end
