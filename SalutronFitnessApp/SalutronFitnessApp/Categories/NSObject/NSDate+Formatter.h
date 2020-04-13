//
//  NSDate+Formatter.h
//  WomensCircle
//
//  Created by John Dwaine Alingarog on 11/3/13.
//  Copyright (c) 2013 John Dwaine Alingarog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatter)

+ (NSString *)getTimeStringNow;
+ (NSString *)getDateStringNow;
+ (NSString *)getDateTimeStringNow;

- (NSString *)getTimeString;
- (NSString *)getDateString;
- (NSString *)getDateTimeStringNow;
- (NSString *)getDateStringWithFormat:(NSString *)dateFormat;

- (BOOL)dateHasPassedWithNumberOfSeconds:(float)seconds;
- (BOOL)dateHasPassedWithNumberOfMinutes:(float)minutes;
- (BOOL)dateHasPassedWithNumberOfHours:(float)hours;
- (BOOL)dateHasPassedWithNumberOfDays:(float)days;
- (BOOL)dateHasPassedWithNumberOfWeeks:(float)weeks;
- (BOOL)dateHasPassedWithNumberOfMonths:(float)months;

- (NSDate *)getDateWithInterval:(NSInteger)interval;
- (NSDate *)getFirstDayOfTheWeek;
- (NSDate *)getLastDayOfTheWeek;

@end
