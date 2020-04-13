//
//  NSDate+Format.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Format)

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)format;
+ (NSDate *)UTCDateFromString:(NSString *)dateString withFormat:(NSString *)format;
+ (NSString *)dateToString:(NSDate *)date withFormat:(NSString *)format;
+ (NSString *)dateToUTCString:(NSDate *)date withFormat:(NSString *)format;
- (NSDate *)dateWithoutTime;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSDateComponents *)dateComponents;

@end
