//
//  WorkoutSettingEntity+CoreDataProperties.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/2/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WorkoutSettingEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutSettingEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSNumber *hrLogRate;
@property (nullable, nonatomic, retain) NSNumber *autoSplitType;
@property (nullable, nonatomic, retain) NSNumber *autoSplitThreshold;
@property (nullable, nonatomic, retain) NSNumber *zoneTrainType;
@property (nullable, nonatomic, retain) NSNumber *zone0Upper;
@property (nullable, nonatomic, retain) NSNumber *zone0Lower;
@property (nullable, nonatomic, retain) NSNumber *zone1Lower;
@property (nullable, nonatomic, retain) NSNumber *zone2Lower;
@property (nullable, nonatomic, retain) NSNumber *zone3Lower;
@property (nullable, nonatomic, retain) NSNumber *zone4Lower;
@property (nullable, nonatomic, retain) NSNumber *zone5Lower;
@property (nullable, nonatomic, retain) NSNumber *zone5Upper;
@property (nullable, nonatomic, retain) NSNumber *reserved;
@property (nullable, nonatomic, retain) NSNumber *databaseUsage;
@property (nullable, nonatomic, retain) NSNumber *databaseUsageMax;
@property (nullable, nonatomic, retain) NSNumber *reconnectTimeout;
@property (nullable, nonatomic, retain) DeviceEntity *device;

@end

NS_ASSUME_NONNULL_END
