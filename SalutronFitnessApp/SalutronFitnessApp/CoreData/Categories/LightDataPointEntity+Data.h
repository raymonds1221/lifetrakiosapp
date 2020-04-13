//
//  LightDataPointEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 8/20/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "LightDataPointEntity.h"
#import "LightDataPoint.h"

@interface LightDataPointEntity (Data)

/* INSERT AND UPDATE LIGHT DATA POINT */

float clearCoefficient(int gain);

+ (id)insertLightDataPoint:(LightDataPoint *)dataPoint
      statisticalDataPointEntity:(StatisticalDataPointEntity *)statisticalDataPoint
                     index:(NSInteger)index
    inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (id)updateLightDataPointEntityWithDataPoint:(LightDataPoint *)dataPoint
                   statisticalDataPointEntity:(StatisticalDataPointEntity *)statisticalDataPoint
                              dataPointEntity:(LightDataPointEntity *)dataPointEntity;

/* GET LIGHT DATA POINTS */

+ (NSArray *)lightDataPointsForDate:(NSDate *)date;

+ (NSArray *)lightDataPointsForWeek:(NSInteger)week
                             ofYear:(NSInteger)year
                         daysInWeek:(NSMutableOrderedSet *__autoreleasing *)daysInWeek;

+ (NSArray *)lightDataPointsForMonth:(NSInteger)month
                              ofYear:(NSInteger)year
                         daysInMonth:(NSMutableOrderedSet *__autoreleasing *)daysInMonth;

+ (NSArray *)lightDataPointsForYear:(NSInteger)year
                         daysInYear:(NSMutableOrderedSet *__autoreleasing *)daysInYear;

/* OTHER METHODS */

+ (LightDataPointEntity *)lightDataPointForDictionary:(NSDictionary *)dictionary
                                        forDataHeader:(StatisticalDataHeaderEntity *)dataHeader;

+ (NSArray *)dataPointsWithArray:(NSArray *)array dataPoints:(NSArray *)statisticalDataPoints forDataHeader:(StatisticalDataHeaderEntity *)dataHeader;


- (NSDictionary *)dictionary;

@end

