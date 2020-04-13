//
//  StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/13/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "StatisticalDataHeaderEntity.h"
#import "StatisticalDataHeader.h"

@interface StatisticalDataHeaderEntity (StatisticalDataHeaderEntityCategory)

+ (StatisticalDataHeaderEntity *)statisticalDataHeaderEntityForDate:(NSDate *)date;
+ (NSArray *)statisticalDataHeaderEntitiesForDate:(NSDate *)date;

//insert methods
+ (id)statisticalForInsertDataHeader:(StatisticalDataHeader *) dataHeader
               inManagedObjectContext:(NSManagedObjectContext *) managedObjectContext;
+ (BOOL)updateEntityWithStatisticalDataHeader:(StatisticalDataHeader *)dataHeader
                                     entity:(StatisticalDataHeaderEntity *)dataHeaderEntity
                     inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

//delete method
- (void)deleteObject;

@end
