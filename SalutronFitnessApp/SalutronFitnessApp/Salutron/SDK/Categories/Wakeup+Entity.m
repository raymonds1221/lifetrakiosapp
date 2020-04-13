//
//  Wakeup+Entity.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 2/6/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "Wakeup+Entity.h"

@implementation Wakeup (Entity)

- (instancetype)initWithEntity:(WakeupEntity *)wakeupEntity
{
    self = [super init];
    
    if(self) {
        self.type = 0;
        self.wakeup_mode = wakeupEntity.wakeupMode.integerValue;
        self.wakeup_hr = wakeupEntity.wakeupHour.integerValue;
        self.wakeup_min = wakeupEntity.wakeupMinute.integerValue;
        self.wakeup_window = wakeupEntity.wakeupWindow.integerValue;
        self.snooze_mode = wakeupEntity.snoozeMode.integerValue;
        self.snooze_min = wakeupEntity.snoozeMin.integerValue;
    }
    
    return self;
}

@end
