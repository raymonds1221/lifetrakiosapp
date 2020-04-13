//
//  NSDate+Formatter.m
//  WomensCircle
//
//  Created by John Dwaine Alingarog on 11/3/13.
//  Copyright (c) 2013 John Dwaine Alingarog. All rights reserved.
//

#import "NSDate+Formatter.h"

@implementation NSDate (Formatter)

static NSString *_timeFormat            = @"hh:mma";
static NSString *_militaryTimeFormat    = @"HH:mm";
static NSString *_dateFormat            = @"MM/dd/yyyy";
static NSString *_dateTimeFormat        = @"MM/dd/yyyy hh:mma";

#pragma mark - Public class methods
+ (NSString *)getTimeStringNow
{
    
    NSDateFormatter *_formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat       = _timeFormat;
    return [_formatter stringFromDate:[NSDate date]];
}

+ (NSString *)getDateStringNow
{
    NSDateFormatter *_formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat       = _dateFormat;
    return [_formatter stringFromDate:[NSDate date]];
}

+ (NSString *)getDateTimeStringNow
{
    NSDateFormatter *_formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat       = _dateTimeFormat;
    return [_formatter stringFromDate:[NSDate date]];
}

#pragma mark - Public instance date format methods
- (NSString *)getTimeString
{
    NSDateFormatter *_formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat       = _timeFormat;
    return [_formatter stringFromDate:self];
}

- (NSString *)getDateString
{
    NSDateFormatter *_formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat       = _dateFormat;
    return [_formatter stringFromDate:self];
}

- (NSString *)getDateTimeStringNow
{
    NSDateFormatter *_formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat       = _dateTimeFormat;
    return [_formatter stringFromDate:self];
}

- (NSString *)getDateStringWithFormat:(NSString *)dateFormat
{
    NSDateFormatter *_formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat       = dateFormat;
    return [_formatter stringFromDate:self];
}

#pragma mark - Public instance date interval methods
- (BOOL)dateHasPassedWithNumberOfSeconds:(float)seconds
{
    NSDate *_curDate                = [NSDate date];
    NSTimeInterval _timeInterval    = [_curDate timeIntervalSinceDate:self];
    return _timeInterval > seconds;
}

- (BOOL)dateHasPassedWithNumberOfMinutes:(float)minutes
{
    NSDate *_curDate                = [NSDate date];
    NSTimeInterval _timeInterval    = [_curDate timeIntervalSinceDate:self];
    CGFloat _minuteInterval         = floorf((_timeInterval / 60));
    return _minuteInterval > minutes;
}

- (BOOL)dateHasPassedWithNumberOfHours:(float)hours
{
    NSDate *_curDate                = [NSDate date];
    NSTimeInterval _timeInterval    = [_curDate timeIntervalSinceDate:self];
    CGFloat _minuteInterval         = floorf((_timeInterval / 60));
    CGFloat _hourInterval           = floorf((_minuteInterval / 60));
    return _hourInterval > hours;
}

- (BOOL)dateHasPassedWithNumberOfDays:(float)days
{
    NSDate *_curDate                = [NSDate date];
    NSTimeInterval _timeInterval    = [_curDate timeIntervalSinceDate:self];
    CGFloat _minuteInterval         = floorf((_timeInterval / 60));
    CGFloat _hourInterval           = floorf((_minuteInterval / 60));
    CGFloat _dayInterval            = floorf((_hourInterval / 24));
    return _dayInterval > days;
}

- (BOOL)dateHasPassedWithNumberOfWeeks:(float)weeks
{
    NSDate *_curDate                = [NSDate date];
    NSTimeInterval _timeInterval    = [_curDate timeIntervalSinceDate:self];
    CGFloat _minuteInterval         = floorf((_timeInterval / 60));
    CGFloat _hourInterval           = floorf((_minuteInterval / 60));
    CGFloat _dayInterval            = floorf((_hourInterval / 24));
    CGFloat _weekInterval           = floorf((_dayInterval / 7));
    return _weekInterval > weeks;
}

- (BOOL)dateHasPassedWithNumberOfMonths:(float)months
{
    NSDate *_curDate                = [NSDate date];
    NSTimeInterval _timeInterval    = [_curDate timeIntervalSinceDate:self];
    CGFloat _minuteInterval         = floorf((_timeInterval / 60));
    CGFloat _hourInterval           = floorf((_minuteInterval / 60));
    CGFloat _dayInterval            = floorf((_hourInterval / 24));
    CGFloat _weekInterval           = floorf((_dayInterval / 7));
    CGFloat _monthInterval          = floorf((_weekInterval / 4));
    return _monthInterval > months;
}

- (NSDate *)getDateWithInterval:(NSInteger)interval
{
    return [self dateByAddingTimeInterval:interval * (24*60*60)];
}

- (NSDate *)getFirstDayOfTheWeek
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [calendar components:NSYearForWeekOfYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSYearCalendarUnit fromDate:self];
    NSDate *_firstDayOfTheWeek      = [calendar dateFromComponents:components];
    [calendar rangeOfUnit:NSWeekOfYearCalendarUnit
                startDate:&_firstDayOfTheWeek
                 interval:NULL
                  forDate:self];
    return _firstDayOfTheWeek;
}

- (NSDate *)getLastDayOfTheWeek
{
    NSDate *_firstDayOfTheWeek  = [self getFirstDayOfTheWeek];
    return [_firstDayOfTheWeek getDateWithInterval:6];
}

@end
