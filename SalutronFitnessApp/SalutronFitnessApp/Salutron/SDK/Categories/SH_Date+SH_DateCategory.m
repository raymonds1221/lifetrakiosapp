//
//  SH_Date+SH_DateCategory.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/13/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SH_Date+SH_DateCategory.h"

@implementation SH_Date (SH_DateCategory)

- (id) initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.day = [aDecoder decodeIntForKey:DAY];
        self.month = [aDecoder decodeIntForKey:MONTH];
        self.year = [aDecoder decodeIntForKey:YEAR];
        return self;
    }
    return nil;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.day forKey:DAY];
    [aCoder encodeInt:self.month forKey:MONTH];
    [aCoder encodeInt:self.year forKey:YEAR];
}

@end
