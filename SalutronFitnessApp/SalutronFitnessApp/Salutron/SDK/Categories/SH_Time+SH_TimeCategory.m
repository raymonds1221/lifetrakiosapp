//
//  SH_Time+SH_TimeCategory.m
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/19/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SH_Time+SH_TimeCategory.h"

@implementation SH_Time (SH_TimeCategory)

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init]) {
        self.second = [aDecoder decodeIntForKey:SECOND];
        self.minute = [aDecoder decodeIntForKey:MINUTE];
        self.hour   = [aDecoder decodeIntForKey:HOUR];
        return self;
    }
    return nil;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self.second   forKey:SECOND];
    [aCoder encodeInt:self.minute   forKey:MINUTE];
    [aCoder encodeInt:self.hour     forKey:HOUR];
}

@end
