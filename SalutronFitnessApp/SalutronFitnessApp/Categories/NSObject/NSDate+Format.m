//
//  NSDate+Format.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)

#pragma mark - Public Methods

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    dateFormatter.dateFormat        = format;
//    Changed timeZone from UTC to local - walgreens data inconsistency fix
//    dateFormatter.timeZone          = [NSTimeZone timeZoneWithName:@"UTC"];
    dateFormatter.timeZone          = [NSTimeZone localTimeZone];
    NSDate *date                    = [dateFormatter dateFromString:dateString];
    
    return date;
}

+ (NSDate *)UTCDateFromString:(NSString *)dateString withFormat:(NSString *)format
{
	NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    dateFormatter.dateFormat        = @"MM/dd/yyyy";//format;
	//dateFormatter.timeZone          = [NSTimeZone timeZoneWithName:@"UTC"];
	dateFormatter.timeZone          = [NSTimeZone localTimeZone];
	NSDate *date                    = [dateFormatter dateFromString:dateString];
	
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    dateFormatter2.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter2 setDateFormat:format];
    NSString *newDateString = [dateFormatter2 stringFromDate:date];
    
    NSDate *newDate = [dateFormatter2 dateFromString:newDateString];
    date = newDate;
    
	return date;
}

+ (NSString *)dateToString:(NSDate *)date withFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:format];
    NSString *newDateString = [dateFormatter2 stringFromDate:date];
    return newDateString;
}

+ (NSString *)dateToUTCString:(NSDate *)date withFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:format];
    dateFormatter2.timeZone          = [NSTimeZone timeZoneWithName:@"UTC"];
    NSString *newDateString = [dateFormatter2 stringFromDate:date];
    return newDateString;
}

//- (NSDate *)dateWithoutTime
//{
//	unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
//	NSCalendar* calendar = [NSCalendar currentCalendar];
//	NSDateComponents* components = [calendar components:flags fromDate:self];
//	return [calendar dateFromComponents:components];
//}

-(NSDate *)dateWithoutTime{
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (NSString *)stringWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    dateFormatter.dateFormat        = format;
//    dateFormatter.locale            = [NSLocale currentLocale];
//    dateFormatter.timeZone          = [NSTimeZone systemTimeZone];
    
//    Changed timeZone from UTC to local - walgreens data inconsistency fix
//    dateFormatter.timeZone          = [NSTimeZone timeZoneWithName:@"UTC"];
    NSString *dateString            = [dateFormatter stringFromDate:self];
    
    return dateString;
}

- (NSDateComponents *)dateComponents
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [calendar components:NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit |
                                                           NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                  fromDate:self];
    
    return components;
}

@end
