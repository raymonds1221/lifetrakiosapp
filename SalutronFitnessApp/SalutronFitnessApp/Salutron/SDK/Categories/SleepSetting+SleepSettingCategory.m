//
//  SleepSetting+SleepSettingCategory.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/18/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SleepSetting+SleepSettingCategory.h"

@implementation SleepSetting (SleepSettingCategory)

- (id) initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.sleep_goal_lo = [aDecoder decodeIntForKey:SLEEP_GOAL_LO];
        self.sleep_goal_hi = [aDecoder decodeIntForKey:SLEEP_GOAL_HI];
        self.sleep_mode = [aDecoder decodeIntForKey:SLEEP_MODE];
        
        return self;
    }
    return nil;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.sleep_goal_lo forKey:SLEEP_GOAL_LO];
    [aCoder encodeInt:self.sleep_goal_hi forKey:SLEEP_GOAL_HI];
    [aCoder encodeInt:self.sleep_mode forKey:SLEEP_MODE];
}

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    
    [copy setSleep_goal_hi:self.sleep_goal_hi];
    [copy setSleep_goal_lo:self.sleep_goal_lo];
    [copy setSleep_mode:self.sleep_mode];
    
    return copy;
}

@end
