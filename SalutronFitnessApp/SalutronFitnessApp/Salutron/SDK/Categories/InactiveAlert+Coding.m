//
//  InactiveAlert+Coding.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/2/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "InactiveAlert+Coding.h"

#define TYPE                @"type"
#define STATUS              @"status"
#define TIME_DURATION       @"timeDuration"
#define STEPS_THRESHOLD     @"stepsThreshold"
#define START_HOUR          @"startHour"
#define START_MIN           @"startMin"
#define END_HOUR            @"endHour"
#define END_MIN             @"endMin"

@implementation InactiveAlert (Coding)

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        
        self.type       = [aDecoder decodeIntForKey:TYPE];
        self.status     = [aDecoder decodeIntForKey:STATUS];
        self.time_duration = [aDecoder decodeIntForKey:TIME_DURATION];
        self.steps_threshold = [aDecoder decodeIntForKey:STEPS_THRESHOLD];
        self.start_hour = [aDecoder decodeIntForKey:START_HOUR];
        self.start_min = [aDecoder decodeIntForKey:START_MIN];
        self.end_hour = [aDecoder decodeIntForKey:END_HOUR];
        self.end_min = [aDecoder decodeIntForKey:END_MIN];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeInt:self.type forKey:TYPE];
    [aCoder encodeInt:self.status forKey:STATUS];
    [aCoder encodeInt:self.time_duration forKey:TIME_DURATION];
    [aCoder encodeInt:self.steps_threshold forKey:STEPS_THRESHOLD];
    [aCoder encodeInt:self.start_hour forKey:START_HOUR];
    [aCoder encodeInt:self.start_min forKey:START_MIN];
    [aCoder encodeInt:self.end_hour forKey:END_HOUR];
    [aCoder encodeInt:self.end_min forKey:END_MIN];
    
}

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    
    [copy setType:self.type];
    [copy setStatus:self.status];
    [copy setTime_duration:self.time_duration];
    [copy setSteps_threshold:self.steps_threshold];
    [copy setStart_hour:self.start_hour];
    [copy setStart_min:self.start_min];
    [copy setEnd_hour:self.end_hour];
    [copy setEnd_min:self.end_min];
    
    return copy;
}




@end
