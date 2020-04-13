//
//  DayLightAlert+Entity.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 3/19/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "DayLightAlert+Entity.h"

@implementation DayLightAlert (Entity)

- (instancetype)initWithEntity:(DayLightAlertEntity *)dayLightAlertEntity
{
    self = [super init];
    
    if(self) {
        self.type = 0;
        self.duration       = dayLightAlertEntity.duration.integerValue;
        self.end_hour       = dayLightAlertEntity.endHour.integerValue;
        self.end_min        = dayLightAlertEntity.endMin.integerValue;
        self.interval       = dayLightAlertEntity.interval.integerValue;
        self.level          = dayLightAlertEntity.level.integerValue;
        self.start_hour     = dayLightAlertEntity.startHour.integerValue;
        self.start_min      = dayLightAlertEntity.startMin.integerValue;
        self.status         = dayLightAlertEntity.status.integerValue;
        self.type           = dayLightAlertEntity.type.integerValue;
        self.level_low      = dayLightAlertEntity.levelLow.intValue;
        self.level_mid      = dayLightAlertEntity.levelMid.intValue;
        self.level_hi       = dayLightAlertEntity.levelHigh.intValue;
    }
    
    return self;
}


@end
