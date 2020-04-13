//
//  DeviceEntity+WatchName.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/10/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "DeviceEntity+WatchName.h"

@implementation DeviceEntity (WatchName)

- (NSString *)defaultWatchName
{
    WatchModel watchModel = self.modelNumber.integerValue;
    
    if (watchModel == WatchModel_Core_C200) {
        return WATCHNAME_CORE_C200;
    } else if (watchModel == WatchModel_Move_C300 || watchModel == WatchModel_Move_C300_Android) {
        return WATCHNAME_MOVE_C300;
    } else if (watchModel == WatchModel_Zone_C410) {
        return WATCHNAME_ZONE_C410;
    } else if (watchModel == WatchModel_R420) {
        return WATCHNAME_R420;
    } else if (watchModel == WatchModel_R450) {
        return WATCHNAME_BRITE_R450;
    } else if (watchModel == WatchModel_R500) {
        return WATCHNAME_R500;
    }
    else {
        return WATCHNAME_DEFAULT;
    }
    return @"";
}

@end
