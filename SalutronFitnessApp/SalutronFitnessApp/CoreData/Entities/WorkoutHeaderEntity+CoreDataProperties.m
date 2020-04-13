//
//  WorkoutHeaderEntity+CoreDataProperties.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/12/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WorkoutHeaderEntity+CoreDataProperties.h"

@implementation WorkoutHeaderEntity (CoreDataProperties)

@dynamic autoSplitThreshold;
@dynamic autoSplitType;
@dynamic averageBPM;
@dynamic calories;
@dynamic distance;
@dynamic hour;
@dynamic hundredths;
@dynamic logRateHR;
@dynamic maximumBPM;
@dynamic minimumBPM;
@dynamic minute;
@dynamic recordCountHR;
@dynamic recordCountSplits;
@dynamic recordCountStops;
@dynamic recordCountTotal;
@dynamic second;
@dynamic stampDay;
@dynamic stampHour;
@dynamic stampMinute;
@dynamic stampMonth;
@dynamic stampSecond;
@dynamic stampYear;
@dynamic statusFlags;
@dynamic steps;
@dynamic userMaxHR;
@dynamic zone0LowerHR;
@dynamic zone0UpperHR;
@dynamic zone1LowerHR;
@dynamic zone2LowerHR;
@dynamic zone3LowerHR;
@dynamic zone4LowerHR;
@dynamic zone5LowerHR;
@dynamic zone5UpperHR;
@dynamic zoneTrainType;
@dynamic device;
@dynamic workoutRecord;
@dynamic workoutStopDatabase;
@dynamic workoutHeartRateData;

- (void)addWorkoutHeartRateData:(NSOrderedSet<WorkoutHeartRateDataEntity *> *)values
{
    NSMutableOrderedSet *workoutHeartRateData = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.workoutHeartRateData];
    [workoutHeartRateData addObjectsFromArray:[values array]];
    self.workoutHeartRateData = workoutHeartRateData;
}

- (void)addWorkoutHeartRateDataObject:(WorkoutHeartRateDataEntity *)value
{
    NSMutableOrderedSet *workoutHeartRateData = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.workoutHeartRateData];
    [workoutHeartRateData addObject:value];
    self.workoutHeartRateData = workoutHeartRateData;
}

@end
