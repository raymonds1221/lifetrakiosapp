//
//  Wakeup+Coding.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 3/30/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "Wakeup+Coding.h"

#define WAKEUP_MODE         @"wakeupMode"
#define WAKEUP_HOUR         @"wakeupHour"
#define WAKEUP_MINUTE       @"wakeupMinute"
#define WAKEUP_WINDOW       @"wakeupWindow"
#define SNOOZE_MODE         @"snoozeMode"
#define SNOOZE_MIN          @"snoozeMin"

@implementation Wakeup (Coding)

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        
        self.wakeup_mode       = [aDecoder decodeIntForKey:WAKEUP_MODE];
        self.wakeup_hr     = [aDecoder decodeIntForKey:WAKEUP_HOUR];
        self.wakeup_min = [aDecoder decodeIntForKey:WAKEUP_MINUTE];
        self.wakeup_window = [aDecoder decodeIntForKey:WAKEUP_WINDOW];
        self.snooze_mode = [aDecoder decodeIntForKey:SNOOZE_MODE];
        self.snooze_min = [aDecoder decodeIntForKey:SNOOZE_MIN];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeInt:self.wakeup_mode forKey:WAKEUP_MODE];
    [aCoder encodeInt:self.wakeup_hr forKey:WAKEUP_HOUR];
    [aCoder encodeInt:self.wakeup_min forKey:WAKEUP_MINUTE];
    [aCoder encodeInt:self.wakeup_window forKey:WAKEUP_WINDOW];
    [aCoder encodeInt:self.snooze_mode forKey:SNOOZE_MODE];
    [aCoder encodeInt:self.snooze_min forKey:SNOOZE_MIN];
    
}

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    
    [copy setWakeup_mode:self.wakeup_mode];
    [copy setWakeup_hr:self.wakeup_hr];
    [copy setWakeup_min:self.wakeup_min];
    [copy setWakeup_window:self.wakeup_window];
    [copy setSnooze_mode:self.snooze_mode];
    [copy setSnooze_min:self.snooze_min];
    
    return copy;
}





@end
