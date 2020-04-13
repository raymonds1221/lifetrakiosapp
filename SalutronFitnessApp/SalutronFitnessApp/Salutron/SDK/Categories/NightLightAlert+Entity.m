//
//  NightLightAlert+Entity.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 3/19/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "NightLightAlert+Entity.h"

@implementation NightLightAlert (Entity)

- (instancetype)initWithEntity:(NightLightAlertEntity *)nightLightAlertEntity
{
    self = [super init];
    
    if(self) {
        self.type = 0;
        self.type           = nightLightAlertEntity.type.integerValue;
        self.status         = nightLightAlertEntity.status.integerValue;
        self.level          = nightLightAlertEntity.level.integerValue;
        self.duration       = nightLightAlertEntity.duration.integerValue;
        self.start_hour     = nightLightAlertEntity.startHour.integerValue;
        self.start_min      = nightLightAlertEntity.startMin.integerValue;
        self.end_hour       = nightLightAlertEntity.endHour.integerValue;
        self.end_min        = nightLightAlertEntity.endMin.integerValue;
        self.level_low      = nightLightAlertEntity.levelLow.intValue;
        self.level_mid      = nightLightAlertEntity.levelMid.intValue;
        self.level_hi       = nightLightAlertEntity.levelHigh.intValue;
    }
    
    return self;
}

@end
