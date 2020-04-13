//
//  NSDate+Util.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 8/31/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Util.h"

@implementation NSDate (Util)

+ (NSUInteger)numberOfDaysForCurrentYear
{
    NSUInteger days = 0;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit fromDate:today];
   
    NSUInteger months = [calendar rangeOfUnit:NSMonthCalendarUnit
                                       inUnit:NSYearCalendarUnit
                                      forDate:today].length;
    for (int i = 1; i <= months; i++) {
        components.month = i;
        NSDate *month = [calendar dateFromComponents:components];
        days += [calendar rangeOfUnit:NSDayCalendarUnit
                               inUnit:NSMonthCalendarUnit
                              forDate:month].length;
    }
    
    return days;
}


+ (NSUInteger)numberOfDaysInMonthForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange days = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    return days.length;
}

+ (NSInteger)durationWithStartHour:(NSInteger)startHour
                       startMinute:(NSInteger)startMinute
                           endHour:(NSInteger)endHour
                         endMinute:(NSInteger)endMinute
{
    NSInteger startInMinute = (startHour * 60) + startMinute;
    NSInteger endInMinute = (endHour * 60) + endMinute;
    
    if(endInMinute > startInMinute)
        return endInMinute - startInMinute;
    else
        return startInMinute - endInMinute;
}

@end
