//
//  StatisticalDataPointEntity+StatisticalDataPointEntityCategory.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/15/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "StatisticalDataPointEntity+StatisticalDataPointEntityCategory.h"

@implementation StatisticalDataPointEntity (StatisticalDataPointEntityCategory)

+ (id) statisticalForInsertDataPoint:(StatisticalDataPoint *)dataPoint
                               index:(NSInteger)index
              inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    StatisticalDataPointEntity *dataPointEntity = [NSEntityDescription insertNewObjectForEntityForName:STATISTICAL_DATA_POINT_ENTITY inManagedObjectContext:managedObjectContext];
    //DDLogError(@"data point id = %i", index);
    dataPointEntity.dataPointID = [NSNumber numberWithInteger:index];
    return [self dataPointEntityWithDataPoint:dataPoint dataPointEntity:dataPointEntity];
}

+ (id) dataPointEntityWithDataPoint:(StatisticalDataPoint *)dataPoint
                    dataPointEntity:(StatisticalDataPointEntity *)dataPointEntity
{
    dataPointEntity.averageHR = [NSNumber numberWithInt:dataPoint.averageHR];
    dataPointEntity.distance = [NSNumber numberWithDouble:dataPoint.distance];
    dataPointEntity.steps = [NSNumber numberWithInt:dataPoint.steps];
    dataPointEntity.calorie = [NSNumber numberWithDouble:dataPoint.calorie];
    dataPointEntity.sleepPoint02 = [NSNumber numberWithChar:dataPoint.sleeppoint_0_2];
    dataPointEntity.sleepPoint24 = [NSNumber numberWithChar:dataPoint.sleeppoint_2_4];
    dataPointEntity.sleepPoint46 = [NSNumber numberWithChar:dataPoint.sleeppoint_4_6];
    dataPointEntity.sleepPoint68 = [NSNumber numberWithChar:dataPoint.sleeppoint_6_8];
    dataPointEntity.sleepPoint810 = [NSNumber numberWithChar:dataPoint.sleeppoint_8_10];
    dataPointEntity.dominantAxis = [NSNumber numberWithChar:dataPoint.dominant_axis];
    //dataPointEntity.lux = [NSNumber numberWithDouble:dataPoint.Lux];
    dataPointEntity.axisDirection = [NSNumber numberWithChar:dataPoint.axis_direction];
    dataPointEntity.axisMagnitude = [NSNumber numberWithChar:dataPoint.axis_magnitude];
    dataPointEntity.wristDetection = [NSNumber numberWithBool:dataPoint.wrist_detection];
    dataPointEntity.bleStatus = [NSNumber numberWithBool:dataPoint.ble_status];
    
    return dataPointEntity;
}

@end
