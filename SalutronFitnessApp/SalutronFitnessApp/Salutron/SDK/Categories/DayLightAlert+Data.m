//
//  DayLightAlert+Data.m
//  SalutronFitnessApp
//
//  Created by Aci Cartagena on 9/5/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "DayLightAlert+Data.h"
#import "SFAUserDefaultsManager.h"

@implementation DayLightAlert (Data)

+ (DayLightAlert *)dayLightAlert
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSData *data                    = [userDefaults dataForKey:DAY_LIGHT_ALERT];
    DayLightAlert *alert            = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (!alert) {
        alert = [[DayLightAlert alloc] init];
    }
    
    return alert;
}

+ (DayLightAlert *)dayLightAlertWithDefaultValues
{
    DayLightAlert *alert = [[DayLightAlert alloc] init];
    alert.status = 0;
    alert.level = 1; //medium
    alert.duration = 10;
    alert.start_hour = 7;
    alert.start_min = 0;
    alert.end_hour = 12;
    alert.end_min = 0;
    alert.interval = 60;
    alert.level_low = 350;
    alert.level_mid = 1000;
    alert.level_hi = 2000;
    return alert;
}

+ (DayLightAlert *)dayLightAlertWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        NSNumber *endHour = [dictionary objectForKey:API_LIGHT_ALERT_END_HOUR];
        NSNumber *endMin = [dictionary objectForKey:API_LIGHT_ALERT_END_MIN];
        NSNumber *startHour = [dictionary objectForKey:API_LIGHT_ALERT_START_HOUR];
        NSNumber *startMin = [dictionary objectForKey:API_LIGHT_ALERT_START_MIN];
        NSNumber *type = [dictionary objectForKey:API_LIGHT_ALERT_START_TYPE];
        NSNumber *status = [dictionary objectForKey:API_LIGHT_ALERT_START_STATUS];
        NSNumber *duration = [dictionary objectForKey:API_LIGHT_ALERT_DURATION];
        NSNumber *interval = [dictionary objectForKey:API_LIGHT_ALERT_INTERVAL];
        NSNumber *level = [dictionary objectForKey:API_LIGHT_ALERT_LEVEL];
        NSNumber *low = [dictionary objectForKey:API_LIGHT_ALERT_LEVEL_LOW];
        NSNumber *mid = [dictionary objectForKey:API_LIGHT_ALERT_LEVEL_MID];
        NSNumber *high = [dictionary objectForKey:API_LIGHT_ALERT_LEVEL_HIGH];
        
        
        DayLightAlert *alert        = [[DayLightAlert alloc] init];
        alert.end_hour = endHour.intValue;
        alert.end_min = endMin.intValue;
        alert.start_hour = startHour.intValue;
        alert.start_min = startMin.intValue;
        alert.type = type.intValue;
        alert.status = status.intValue;
        alert.duration = duration.intValue;
        alert.interval = interval.intValue;
        alert.level = level.intValue;
        alert.level_low = low.intValue;
        alert.level_mid = mid.intValue;
        alert.level_hi = high.intValue;
        
        
        [SFAUserDefaultsManager sharedManager].dayLightAlert = alert;
        
        return alert;
    }
    
    return nil;
}

- (BOOL)isEqualToDayLightAlert:(DayLightAlert *)dayLightAlert
{
    if (self.type != dayLightAlert.type || self.status != dayLightAlert.status ||
        self.level != dayLightAlert.level || self.duration != dayLightAlert.duration ||
        self.start_hour != dayLightAlert.start_hour || self.start_min != dayLightAlert.start_min ||
        self.end_hour != dayLightAlert.end_hour || self.end_min != dayLightAlert.end_min ||
        self.interval != dayLightAlert.interval || self.level_low != dayLightAlert.level_low ||
        self.level_mid != dayLightAlert.level_mid || self.level_hi != dayLightAlert.level_hi){
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
                                    API_LIGHT_ALERT_SETTINGS        : @"day",
                                    API_LIGHT_ALERT_DURATION        : @(self.duration),
                                    API_LIGHT_ALERT_INTERVAL        : @(self.interval),
                                    API_LIGHT_ALERT_START_TYPE      : @(self.type),
                                    API_LIGHT_ALERT_START_STATUS    : @(self.status),
                                    API_LIGHT_ALERT_LEVEL           : @(self.level),
                                    API_LIGHT_ALERT_LEVEL_LOW       : @(self.level_low),
                                    API_LIGHT_ALERT_LEVEL_MID       : @(self.level_mid),
                                    API_LIGHT_ALERT_LEVEL_HIGH      : @(self.level_hi)};
    return dictionary;
}

@end
