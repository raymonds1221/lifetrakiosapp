//
//  NSDate+Comparison.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/12/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Comparison.h"

@implementation NSDate (Comparison)

- (NSComparisonResult)compareToDate:(NSDate *)date
{
    NSCalendar *calendar                    = [NSCalendar currentCalendar];
    NSInteger components                    = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    NSDateComponents *firstDateComponents   = [calendar components:components fromDate:self];
    NSDateComponents *secondDateComponents  = [calendar components:components fromDate:date];
    NSDate *firstDate                       = [calendar dateFromComponents:firstDateComponents];
    NSDate *secondDate                      = [calendar dateFromComponents:secondDateComponents];
    NSComparisonResult result               = [firstDate compare:secondDate];
    
    return result;
}

- (BOOL)isToday
{
    NSDate *today               = [NSDate date];
    NSComparisonResult result   = [self compareToDate:today];
    BOOL isToday                = result == NSOrderedSame;
    
    return isToday;
}

- (BOOL)isTomorrow
{
    NSDate *tomorrow            = [NSDate dateWithTimeIntervalSinceNow:DAY_SECONDS];
    NSComparisonResult result   = [self compareToDate:tomorrow];
    BOOL isTomorrow             = result == NSOrderedSame || result == NSOrderedDescending;
    
    return isTomorrow;
}

- (BOOL)isYesterday
{
    NSDate *yesterday           = [NSDate dateWithTimeIntervalSinceNow:-DAY_SECONDS];
    NSComparisonResult result   = [self compareToDate:yesterday];
    BOOL isYesterday            = result == NSOrderedSame || result == NSOrderedDescending;
    
    return isYesterday;
}

@end
