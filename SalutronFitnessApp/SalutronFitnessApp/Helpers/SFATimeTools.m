//
//  SFATimeTools.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFATimeTools.h"

@implementation SFATimeTools

+ (NSString *)timeStringWithHour:(NSNumber *)hour minute:(NSNumber *)minute second:(NSNumber *)second
{
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone          = [NSTimeZone timeZoneWithName:@"UTC"];
    
    NSString *timeString = [NSString stringWithFormat:@"%02d:%02d:%02d", hour.integerValue,
                            minute.integerValue, second.integerValue];
    
    return timeString;
}

@end
