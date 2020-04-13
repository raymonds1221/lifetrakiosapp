//
//  NightLightAlert+Data.m
//  SalutronFitnessApp
//
//  Created by Aci Cartagena on 9/5/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NightLightAlert+Data.h"
#import "SFAUserDefaultsManager.h"

@implementation NightLightAlert (Data)

+ (NightLightAlert *)nightLightAlert
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSData *data                    = [userDefaults dataForKey:NIGHT_LIGHT_ALERT];
    NightLightAlert *alert            = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (!alert) {
        alert = [[NightLightAlert alloc] init];
    }
    
    return alert;
}

+ (NightLightAlert *)nightLightAlertWithDefaultValues
{
    NightLightAlert *alert = [[NightLightAlert alloc] init];
    alert.status = 0;
    alert.level = 1; //medium
    alert.duration = 10;
    alert.start_hour = 22;
    alert.start_min = 0;
    alert.end_hour = 24;
    alert.end_min = 0;
    alert.level_low = 100;
    alert.level_mid = 250;
    alert.level_hi = 500;
    return alert;
}

+ (NightLightAlert *)nightLightAlertWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        NSNumber *endHour = [dictionary objectForKey:API_LIGHT_ALERT_END_HOUR];
        NSNumber *endMin = [dictionary objectForKey:API_LIGHT_ALERT_END_MIN];
        NSNumber *startHour = [dictionary objectForKey:API_LIGHT_ALERT_START_HOUR];
        NSNumber *startMin = [dictionary objectForKey:API_LIGHT_ALERT_START_MIN];
        NSNumber *type = [dictionary objectForKey:API_LIGHT_ALERT_START_TYPE];
        NSNumber *status = [dictionary objectForKey:API_LIGHT_ALERT_START_STATUS];
        NSNumber *duration = [dictionary objectForKey:API_LIGHT_ALERT_DURATION];
        NSNumber *level = [dictionary objectForKey:API_LIGHT_ALERT_LEVEL];
        NSNumber *low = [dictionary objectForKey:API_LIGHT_ALERT_LEVEL_LOW];
        NSNumber *mid = [dictionary objectForKey:API_LIGHT_ALERT_LEVEL_MID];
        NSNumber *high = [dictionary objectForKey:API_LIGHT_ALERT_LEVEL_HIGH];
        
        
        NightLightAlert *alert        = [[NightLightAlert alloc] init];
        alert.end_hour = endHour.intValue;
        alert.end_min = endMin.intValue;
        alert.start_hour = startHour.intValue;
        alert.start_min = startMin.intValue;
        alert.type = type.intValue;
        alert.status = status.intValue;
        alert.duration = duration.intValue;
        alert.level = level.intValue;
        alert.level_low = low.intValue;
        alert.level_mid = mid.intValue;
        alert.level_hi = high.intValue;
        
        
        
        [SFAUserDefaultsManager sharedManager].nightLightAlert = alert;
        
        return alert;
    }
    
    return nil;
}

- (BOOL)isEqualToNightLightAlert:(NightLightAlert *)nightLightAlert
{
    if (self.type != nightLightAlert.type || self.status != nightLightAlert.status ||
        self.level != nightLightAlert.level || self.duration != nightLightAlert.duration ||
        self.start_hour != nightLightAlert.start_hour || self.start_min != nightLightAlert.start_min ||
        self.end_hour != nightLightAlert.end_hour || self.end_min != nightLightAlert.end_min ||
        self.level_low != nightLightAlert.level_low || self.level_mid != nightLightAlert.level_mid ||
        self.level_hi != nightLightAlert.level_hi){
        return NO;
    }
    return YES;
}

- (NSDictionary *)dictionary
{
    NSDictionary *dictionary    = @{API_LIGHT_ALERT_END_HOUR        : @(self.end_hour),
                                    API_LIGHT_ALERT_END_MIN         : @(self.end_min),
                                    API_LIGHT_ALERT_START_HOUR      : @(self.start_hour),
                                    API_LIGHT_ALERT_START_MIN       : @(self.start_min),
                                    API_LIGHT_ALERT_SETTINGS        : @"night",
                                    API_LIGHT_ALERT_DURATION        : @(self.duration),
                                    API_LIGHT_ALERT_START_TYPE      : @(self.type),
                                    API_LIGHT_ALERT_START_STATUS    : @(self.status),
                                    API_LIGHT_ALERT_LEVEL           : @(self.level),
                                    API_LIGHT_ALERT_LEVEL_LOW       : @(self.level_low),
                                    API_LIGHT_ALERT_LEVEL_MID       : @(self.level_mid),
                                    API_LIGHT_ALERT_LEVEL_HIGH      : @(self.level_hi),
                                    API_LIGHT_ALERT_INTERVAL        : @(0)};
    return dictionary;
}

@end
