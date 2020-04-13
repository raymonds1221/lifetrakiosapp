//
//  DayLightAlert+Coding.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/2/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "DayLightAlert+Coding.h"

#define TYPE                @"type"
#define STATUS              @"status"
#define LEVEL               @"level"
#define DURATION            @"duration"
#define START_HOUR          @"startHour"
#define START_MIN           @"startMin"
#define END_HOUR            @"endHour"
#define END_MIN             @"endMin"
#define INTERVAL            @"interval"

#define LEVEL_LOW           @"level_low"
#define LEVEL_MID           @"level_mid"
#define LEVEL_HIGH          @"level_hi"

@implementation DayLightAlert (Coding)

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        
        self.type       = [aDecoder decodeIntForKey:TYPE];
        self.status     = [aDecoder decodeIntForKey:STATUS];
        self.level      = [aDecoder decodeIntForKey:LEVEL];
        self.duration   = [aDecoder decodeIntForKey:DURATION];

        self.start_hour = [aDecoder decodeIntForKey:START_HOUR];
        self.start_min = [aDecoder decodeIntForKey:START_MIN];
        self.end_hour = [aDecoder decodeIntForKey:END_HOUR];
        self.end_min = [aDecoder decodeIntForKey:END_MIN];
        
        self.interval = [aDecoder decodeIntForKey:INTERVAL];
        
        self.level_low = [aDecoder decodeIntForKey:LEVEL_LOW];
        self.level_mid = [aDecoder decodeIntForKey:LEVEL_MID];
        self.level_hi = [aDecoder decodeIntForKey:LEVEL_HIGH];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeInt:self.type forKey:TYPE];
    [aCoder encodeInt:self.status forKey:STATUS];

    [aCoder encodeInt:self.level forKey:LEVEL];
    [aCoder encodeInt:self.duration forKey:DURATION];
    
    [aCoder encodeInt:self.start_hour forKey:START_HOUR];
    [aCoder encodeInt:self.start_min forKey:START_MIN];
    [aCoder encodeInt:self.end_hour forKey:END_HOUR];
    [aCoder encodeInt:self.end_min forKey:END_MIN];
    
    [aCoder encodeInt:self.interval forKey:INTERVAL];
    [aCoder encodeInt:self.level_low forKey:LEVEL_LOW];
    [aCoder encodeInt:self.level_mid forKey:LEVEL_MID];
    [aCoder encodeInt:self.level_hi forKey:LEVEL_HIGH];
    
}

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    
    [copy setType:self.type];
    [copy setStatus:self.status];

    [copy setLevel:self.level];
    [(DayLightAlert*)copy setDuration:self.duration];
    
    [copy setStart_hour:self.start_hour];
    [copy setStart_min:self.start_min];
    [copy setEnd_hour:self.end_hour];
    [copy setEnd_min:self.end_min];
    
    [copy setInterval:self.interval];
    [copy setLevel_low:self.level_low];
    [copy setLevel_mid:self.level_mid];
    [copy setLevel_hi:self.level_hi];
    
    return copy;
}




@end
