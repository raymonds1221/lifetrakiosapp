//
//  StatisticalDataPointEntity+StatisticalDataPointEntityCategory.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/15/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "StatisticalDataPointEntity.h"
#import "StatisticalDataPoint.h"

@interface StatisticalDataPointEntity (StatisticalDataPointEntityCategory)

+ (id) statisticalForInsertDataPoint:(StatisticalDataPoint *) dataPoint
                               index:(NSInteger)index
              inManagedObjectContext:(NSManagedObjectContext *) managedObjectContext;
+ (id) dataPointEntityWithDataPoint:(StatisticalDataPoint *)dataPoint dataPointEntity:(StatisticalDataPointEntity *)dataPointEntity;

@end
