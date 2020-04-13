//
//  InactiveAlert+Entity.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 3/19/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "InactiveAlert+Entity.h"

@implementation InactiveAlert (Entity)

- (instancetype)initWithEntity:(InactiveAlertEntity *)inactivityAlertEntity
{
    self = [super init];
    
    if(self) {
        self.type = 0;
        self.type              = inactivityAlertEntity.type.integerValue;
        self.status            = inactivityAlertEntity.status.integerValue;
        self.time_duration     = inactivityAlertEntity.timeDuration.intValue;
        self.steps_threshold   = inactivityAlertEntity.stepsThreshold.intValue;
        self.start_hour        = inactivityAlertEntity.startHour.integerValue;
        self.start_min         = inactivityAlertEntity.startMin.integerValue;
        self.end_hour          = inactivityAlertEntity.endHour.integerValue;
        self.end_min           = inactivityAlertEntity.endMin.integerValue;
    }
    
    return self;
}

@end
