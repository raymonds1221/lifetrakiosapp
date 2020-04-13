//
//  TimeDate+Encoder.m
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/19/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "TimeDate+Encoder.h"
#import "SH_Date+SH_DateCategory.h"
#import "SH_Time+SH_TimeCategory.h"

@implementation TimeDate (Encoder)

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        self.date           = [aDecoder decodeObjectForKey:DATE];
        self.time           = [aDecoder decodeObjectForKey:TIME];
        self.hourFormat     = [aDecoder decodeIntForKey:HOUR_FORMAT];
        self.dateFormat     = [aDecoder decodeIntForKey:DATE_FORMAT];
        self.watchFace      = [aDecoder decodeIntForKey:WATCH_FACE];
        
        return self;
    }
    return nil;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.date forKey:DATE];
    [aCoder encodeObject:self.time forKey:TIME];
    [aCoder encodeInt:self.hourFormat forKey:HOUR_FORMAT];
    [aCoder encodeInt:self.dateFormat forKey:DATE_FORMAT];
    [aCoder encodeInt:self.watchFace forKey:WATCH_FACE];
}

@end
