//
//  InactiveAlert+Data.m
//  SalutronFitnessApp
//
//  Created by Aci Cartagena on 9/5/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "InactiveAlert+Data.h"
#import "SFAUserDefaultsManager.h"

@implementation InactiveAlert (Data)

+ (InactiveAlert *)inactiveAlert
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSData *data                    = [userDefaults dataForKey:INACTIVE_ALERT];
    InactiveAlert *inactiveAlert      = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (!inactiveAlert) {
        inactiveAlert = [[InactiveAlert alloc] init];
    }
    
    return inactiveAlert;
}

+ (InactiveAlert *)inactiveAlertWithDefaultValues
{
    InactiveAlert *alert = [[InactiveAlert alloc] init];
    alert.status = 0;
    alert.time_duration = 60;
    alert.steps_threshold = 200;
    alert.start_hour = 7;
    alert.start_min = 0;
    alert.end_hour = 18;
    alert.end_min = 0;

    return alert;
}

+ (InactiveAlert *)inactiveAlertWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        NSNumber *endHour = [dictionary objectForKey:API_INACTIVE_ALERT_END_HOUR];
        NSNumber *endMin = [dictionary objectForKey:API_INACTIVE_ALERT_END_MIN];
        NSNumber *startHour = [dictionary objectForKey:API_INACTIVE_ALERT_START_HOUR];
        NSNumber *startMin = [dictionary objectForKey:API_INACTIVE_ALERT_START_MIN];
        NSNumber *threshold = [dictionary objectForKey:API_INACTIVE_ALERT_STEPS_THRESHOLD];
        NSNumber *duration = [dictionary objectForKey:API_INACTIVE_ALERT_TIME_DURATION];
        NSNumber *type = [dictionary objectForKey:API_INACTIVE_ALERT_TYPE];
        NSNumber *status = [dictionary objectForKey:API_INACTIVE_ALERT_STATUS];
        
        InactiveAlert *inactiveAlert        = [[InactiveAlert alloc] init];
        inactiveAlert.end_hour = endHour.intValue;
        inactiveAlert.end_min = endMin.intValue;
        inactiveAlert.start_hour = startHour.intValue;
        inactiveAlert.start_min = startMin.intValue;
        inactiveAlert.steps_threshold = threshold.intValue;
        inactiveAlert.time_duration = duration.intValue;
        inactiveAlert.type = type.intValue;
        inactiveAlert.status = status.intValue;
        
        [SFAUserDefaultsManager sharedManager].inactiveAlert = inactiveAlert;
        return inactiveAlert;
    }
    
    return nil;
}

- (BOOL)isEqualToInactiveAlert:(InactiveAlert *)inactiveAlert
{
    if (self.type != inactiveAlert.type || self.status != inactiveAlert.status ||
        self.time_duration != inactiveAlert.time_duration || self.steps_threshold != inactiveAlert.steps_threshold ||
        self.start_hour != inactiveAlert.start_hour || self.start_min != inactiveAlert.start_min ||
        self.end_hour != inactiveAlert.end_hour || self.end_min != inactiveAlert.end_min){
        return NO;
    }
    return YES;
}

- (NSDictionary *)dictionary
{
    NSDictionary *dictionary    = @{API_INACTIVE_ALERT_END_HOUR         : @(self.end_hour),
                                    API_INACTIVE_ALERT_END_MIN          : @(self.end_min),
                                    API_INACTIVE_ALERT_START_HOUR       : @(self.start_hour),
                                    API_INACTIVE_ALERT_START_MIN        : @(self.start_min),
                                    API_INACTIVE_ALERT_STEPS_THRESHOLD  : @(self.steps_threshold),
                                    API_INACTIVE_ALERT_TIME_DURATION    : @(self.time_duration),
                                    API_INACTIVE_ALERT_TYPE             : @(self.type),
                                    API_INACTIVE_ALERT_STATUS           : @(self.status)};
    return dictionary;
}

@end
