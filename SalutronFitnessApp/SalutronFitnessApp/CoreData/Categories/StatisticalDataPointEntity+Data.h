//
//  StatisticalDataPointEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "StatisticalDataPointEntity.h"

@interface StatisticalDataPointEntity (Data)

+ (NSArray *)dataPointsForDate:(NSDate *)date;
+ (NSArray *)dataPointsForWeek:(NSInteger)week ofYear:(NSInteger)year;
+ (NSArray *)dataPointsForMonth:(NSInteger)month ofYear:(NSInteger)year;
+ (NSArray *)dataPointsForYear:(NSInteger)year;
+ (NSInteger)getAverageBPMForDate:(NSDate *)date;
+ (NSInteger)getAverageBPMForMonth:(NSInteger)month ofYear:(NSInteger)year;
+ (NSInteger)getAverageBPMForWeek:(NSInteger)week ofYear:(NSInteger)year;
+ (NSInteger)getAverageBPMForYear:(NSInteger)year;
+ (NSArray *)dataPointsWithArray:(NSArray *)array forDataHeader:(StatisticalDataHeaderEntity *)dataHeader;

- (NSDictionary *)dictionary;

@end
