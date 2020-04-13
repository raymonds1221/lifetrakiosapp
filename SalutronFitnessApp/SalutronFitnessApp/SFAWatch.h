//
//  SFAWatch.h
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 4/4/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WatchModel_Not_Set   = 0,
    WatchModel_Move_C300 = 300,
    WatchModel_Core_C200 = 200,
    WatchModel_Zone_C410 = 410,
    WatchModel_R420 = 420,
    WatchModel_R450 = 415,
    WatchModel_R500 = 500
    
} WatchModel;

static NSString *const WatchModel_R450_DeviceId = @"<00009f01>";
static NSString *const WatchModel_C410_DeviceId = @"<00009a01>";
static NSString *const WatchModel_C300_DeviceId = @"<00009001>";
static NSString *const WatchModel_R420_DeviceId = @"<0000a401>";

@interface SFAWatch : NSObject

+ (NSString *)watchModelStringForWatchModel:(WatchModel)watchModel;
+ (BOOL)isAutoSyncForWatchModel:(WatchModel)watchModel;
+ (BOOL)isDeviceId:(NSString *)deviceId SameWithWatchModel:(WatchModel)watchModel;

@end
