//
//  NSDate+Util.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 8/31/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Util)

+ (NSUInteger)numberOfDaysForCurrentYear;

+ (NSUInteger)numberOfDaysInMonthForDate:(NSDate *)date;

+ (NSInteger)durationWithStartHour:(NSInteger)startHour
                       startMinute:(NSInteger)startMinute
                           endHour:(NSInteger)endHour
                         endMinute:(NSInteger)endMinute;

@end
