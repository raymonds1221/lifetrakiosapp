//
//  NSDate+Age.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/13/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Age.h"

@implementation NSDate (Age)

- (NSInteger)age
{
    NSDate *now                         = [NSDate date];
    NSCalendar *calendar                = [NSCalendar currentCalendar];
    NSDateComponents* ageComponents     = [calendar components:NSYearCalendarUnit
                                                      fromDate:self
                                                        toDate:now
                                                       options:0];
    NSInteger age                       = [ageComponents year];
    
    return age;
}

@end
