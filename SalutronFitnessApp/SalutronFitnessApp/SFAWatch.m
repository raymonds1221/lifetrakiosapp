//
//  SFAWatch.m
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 4/4/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAWatch.h"

@implementation SFAWatch

+ (NSString *)watchModelStringForWatchModel:(WatchModel)watchModel
{
    if (watchModel == WatchModel_Core_C200)
    {
        return WATCHNAME_CORE_C200;
    }
    else if (watchModel == WatchModel_Move_C300 || watchModel == WatchModel_Move_C300_Android)
    {
        return WATCHNAME_MOVE_C300;
    }
    else if (watchModel == WatchModel_Zone_C410)
    {
        return WATCHNAME_ZONE_C410;
    }
    else if (watchModel == WatchModel_R420)
    {
        return WATCHNAME_R420;
    }
    else if (watchModel == WatchModel_R450)
    {
        return WATCHNAME_BRITE_R450;
    }
    else if (watchModel == WatchModel_R500)
    {
        return WATCHNAME_R500;
    }
    else {
        return WATCHNAME_DEFAULT;
    }
    
    return nil;
}

+ (BOOL)isAutoSyncForWatchModel:(WatchModel)watchModel
{
    if (watchModel == WatchModel_Core_C200)
    {
        return NO;
    }
    else if (watchModel == WatchModel_Move_C300 || watchModel == WatchModel_Move_C300_Android)
    {
        return NO;
    }
    else if (watchModel == WatchModel_Zone_C410 || watchModel == WatchModel_R420)
    {
        return NO;
    }
    else if (watchModel == WatchModel_R450)
    {
        return YES;
    }
    else if (watchModel == WatchModel_R500)
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isDeviceId:(NSString *)deviceId SameWithWatchModel:(WatchModel)watchModel
{
    if ((watchModel == WatchModel_Move_C300 && [deviceId isEqualToString:WatchModel_C300_DeviceId]) ||
        (watchModel == WatchModel_Move_C300_Android && [deviceId isEqualToString:WatchModel_C300_DeviceId]) ||
        (watchModel == WatchModel_Zone_C410 && [deviceId isEqualToString:WatchModel_C410_DeviceId]) ||
        (watchModel == WatchModel_R420 && [deviceId isEqualToString:WatchModel_R420_DeviceId]) ||
        (watchModel == WatchModel_R450 && [deviceId isEqualToString:WatchModel_R450_DeviceId])){
        return YES;
    }else{
        return NO;
    }
        
}

@end
