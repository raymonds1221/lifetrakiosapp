//
//  StatisticalDataHeaderEntity.h
//  SalutronFitnessApp
//
//  Created by Patricia Marie Cesar on 11/28/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DateEntity, DeviceEntity, LightDataPointEntity, StatisticalDataPointEntity, TimeEntity;

@interface StatisticalDataHeaderEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * allocationBlockIndex;
@property (nonatomic, retain) NSDate * dateInNSDate;
@property (nonatomic, retain) NSNumber * maxHR;
@property (nonatomic, retain) NSNumber * minHR;
@property (nonatomic, retain) NSNumber * totalCalorie;
@property (nonatomic, retain) NSNumber * totalDistance;
@property (nonatomic, retain) NSNumber * totalExposureTime;
@property (nonatomic, retain) NSNumber * totalSleep;
@property (nonatomic, retain) NSNumber * totalSteps;
@property (nonatomic, retain) NSNumber * isSyncedToServer;
@property (nonatomic, retain) NSSet *dataPoint;
@property (nonatomic, retain) DateEntity *date;
@property (nonatomic, retain) DeviceEntity *device;
@property (nonatomic, retain) NSSet *lightDataPoint;
@property (nonatomic, retain) TimeEntity *time;
@end

@interface StatisticalDataHeaderEntity (CoreDataGeneratedAccessors)

- (void)addDataPointObject:(StatisticalDataPointEntity *)value;
- (void)removeDataPointObject:(StatisticalDataPointEntity *)value;
- (void)addDataPoint:(NSSet *)values;
- (void)removeDataPoint:(NSSet *)values;

- (void)addLightDataPointObject:(LightDataPointEntity *)value;
- (void)removeLightDataPointObject:(LightDataPointEntity *)value;
- (void)addLightDataPoint:(NSSet *)values;
- (void)removeLightDataPoint:(NSSet *)values;

@end
