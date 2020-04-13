//
//  WorkoutHeaderEntity+CoreDataProperties.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/12/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WorkoutHeaderEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutHeaderEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *autoSplitThreshold;
@property (nullable, nonatomic, retain) NSNumber *autoSplitType;
@property (nullable, nonatomic, retain) NSNumber *averageBPM;
@property (nullable, nonatomic, retain) NSNumber *calories;
@property (nullable, nonatomic, retain) NSNumber *distance;
@property (nullable, nonatomic, retain) NSNumber *hour;
@property (nullable, nonatomic, retain) NSNumber *hundredths;
@property (nullable, nonatomic, retain) NSNumber *logRateHR;
@property (nullable, nonatomic, retain) NSNumber *maximumBPM;
@property (nullable, nonatomic, retain) NSNumber *minimumBPM;
@property (nullable, nonatomic, retain) NSNumber *minute;
@property (nullable, nonatomic, retain) NSNumber *recordCountHR;
@property (nullable, nonatomic, retain) NSNumber *recordCountSplits;
@property (nullable, nonatomic, retain) NSNumber *recordCountStops;
@property (nullable, nonatomic, retain) NSNumber *recordCountTotal;
@property (nullable, nonatomic, retain) NSNumber *second;
@property (nullable, nonatomic, retain) NSNumber *stampDay;
@property (nullable, nonatomic, retain) NSNumber *stampHour;
@property (nullable, nonatomic, retain) NSNumber *stampMinute;
@property (nullable, nonatomic, retain) NSNumber *stampMonth;
@property (nullable, nonatomic, retain) NSNumber *stampSecond;
@property (nullable, nonatomic, retain) NSNumber *stampYear;
@property (nullable, nonatomic, retain) NSNumber *statusFlags;
@property (nullable, nonatomic, retain) NSNumber *steps;
@property (nullable, nonatomic, retain) NSNumber *userMaxHR;
@property (nullable, nonatomic, retain) NSNumber *zone0LowerHR;
@property (nullable, nonatomic, retain) NSNumber *zone0UpperHR;
@property (nullable, nonatomic, retain) NSNumber *zone1LowerHR;
@property (nullable, nonatomic, retain) NSNumber *zone2LowerHR;
@property (nullable, nonatomic, retain) NSNumber *zone3LowerHR;
@property (nullable, nonatomic, retain) NSNumber *zone4LowerHR;
@property (nullable, nonatomic, retain) NSNumber *zone5LowerHR;
@property (nullable, nonatomic, retain) NSNumber *zone5UpperHR;
@property (nullable, nonatomic, retain) NSNumber *zoneTrainType;
@property (nullable, nonatomic, retain) DeviceEntity *device;
@property (nullable, nonatomic, retain) NSSet<WorkoutRecordEntity *> *workoutRecord;
@property (nullable, nonatomic, retain) NSSet<WorkoutStopDatabaseEntity *> *workoutStopDatabase;
@property (nullable, nonatomic, retain) NSOrderedSet<WorkoutHeartRateDataEntity *> *workoutHeartRateData;

@end

@interface WorkoutHeaderEntity (CoreDataGeneratedAccessors)

- (void)addWorkoutRecordObject:(WorkoutRecordEntity *)value;
- (void)removeWorkoutRecordObject:(WorkoutRecordEntity *)value;
- (void)addWorkoutRecord:(NSSet<WorkoutRecordEntity *> *)values;
- (void)removeWorkoutRecord:(NSSet<WorkoutRecordEntity *> *)values;

- (void)addWorkoutStopDatabaseObject:(WorkoutStopDatabaseEntity *)value;
- (void)removeWorkoutStopDatabaseObject:(WorkoutStopDatabaseEntity *)value;
- (void)addWorkoutStopDatabase:(NSSet<WorkoutStopDatabaseEntity *> *)values;
- (void)removeWorkoutStopDatabase:(NSSet<WorkoutStopDatabaseEntity *> *)values;

- (void)insertObject:(WorkoutHeartRateDataEntity *)value inWorkoutHeartRateDataAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWorkoutHeartRateDataAtIndex:(NSUInteger)idx;
- (void)insertWorkoutHeartRateData:(NSArray<WorkoutHeartRateDataEntity *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWorkoutHeartRateDataAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWorkoutHeartRateDataAtIndex:(NSUInteger)idx withObject:(WorkoutHeartRateDataEntity *)value;
- (void)replaceWorkoutHeartRateDataAtIndexes:(NSIndexSet *)indexes withWorkoutHeartRateData:(NSArray<WorkoutHeartRateDataEntity *> *)values;
- (void)addWorkoutHeartRateDataObject:(WorkoutHeartRateDataEntity *)value;
- (void)removeWorkoutHeartRateDataObject:(WorkoutHeartRateDataEntity *)value;
- (void)addWorkoutHeartRateData:(NSOrderedSet<WorkoutHeartRateDataEntity *> *)values;
- (void)removeWorkoutHeartRateData:(NSOrderedSet<WorkoutHeartRateDataEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
