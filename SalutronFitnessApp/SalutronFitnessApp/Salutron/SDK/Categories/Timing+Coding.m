//
//  Timing+Coding.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 9/9/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "Timing+Coding.h"

#define TYPE                @"type_notif"
#define PERIODIC_INTERVAL   @"periodic_interval"
#define SCAN_TIME           @"scan_time"
#define LIMIT_TIME          @"limit_time"
#define SMART_FOR_SLEEP     @"smart_for_sleep"
#define SMART_FOR_WRIST     @"smart_for_wrist"

@implementation Timing (Coding)

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.type               = [aDecoder decodeIntForKey:TYPE];
        self.periodic_interval  = [aDecoder decodeIntForKey:PERIODIC_INTERVAL];
        self.scan_time          = [aDecoder decodeIntForKey:SCAN_TIME];
        self.limit_time         = [aDecoder decodeIntForKey:LIMIT_TIME];
        self.smartForSleep      = [aDecoder decodeBoolForKey:SMART_FOR_SLEEP];
        self.smartForWrist      = [aDecoder decodeBoolForKey:SMART_FOR_WRIST];
        return self;
    }
    return nil;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self.type forKey:TYPE];
    [aCoder encodeInt:self.periodic_interval forKey:PERIODIC_INTERVAL];
    [aCoder encodeInt:self.scan_time forKey:SCAN_TIME];
    [aCoder encodeInt:self.limit_time forKey:LIMIT_TIME];
    [aCoder encodeBool:self.smartForSleep forKey:SMART_FOR_SLEEP];
    [aCoder encodeBool:self.smartForWrist forKey:SMART_FOR_WRIST];
}


@end
