//
//  SFAWatchManager.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFAWatchManager : NSObject

// Temporary Fix for Auto Sync
@property (readwrite, nonatomic) BOOL autoSyncTriggered;

// Singleton Instance

+ (SFAWatchManager *)sharedManager;

// Auto Sync

- (void)rescheduleAutoSyncNotifications;

- (void)disableAutoSync;
- (void)enableAutoSync;

@end
