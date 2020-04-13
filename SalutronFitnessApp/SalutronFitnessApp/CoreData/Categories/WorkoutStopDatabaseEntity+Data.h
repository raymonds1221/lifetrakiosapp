//
//  WorkoutStopDatabaseEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/7/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "WorkoutStopDatabaseEntity+CoreDataProperties.h"

@class WorkoutStopDatabase, WorkoutInfoEntity;

@interface WorkoutStopDatabaseEntity (Data)

+ (WorkoutStopDatabaseEntity *)workoutStopDatabaseEntityWithWorkoutStopDatabase:(WorkoutStopDatabase *)workoutStopDatabase
                                                       workoutStopDatabaseIndex:(NSInteger)index
                                                              workoutInfoEntity:(WorkoutInfoEntity *)workoutInfoEntity
                                                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (WorkoutStopDatabaseEntity *)workoutStopDatabaseEntityWithWorkoutStopDatabase:(WorkoutStopDatabase *)workoutStopDatabase
                                                              workoutInfoEntity:(WorkoutInfoEntity *)workoutInfoEntity
                                                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)workoutStopDatabaseEntitiesWithArray:(NSArray *)array forWorkoutInfoEntity:(WorkoutInfoEntity *)workout;
+ (NSArray *)workoutStopDatabaseEntitiesWithArray:(NSArray *)array forWorkoutHeader:(WorkoutHeaderEntity *)workoutHeader;

- (NSDictionary *)dictionary;

- (NSInteger)workoutEndTimeFromStartTime:(NSInteger) startTimeMinutes;
- (NSInteger)workoutAndWorkoutStopEndTimeFromStartTime:(NSInteger) startTimeMinutes;
- (NSInteger)workoutEndTimeFromStartTimeInSeconds:(NSInteger) startTimeSeconds;
- (NSInteger)workoutAndWorkoutStopEndTimeFromStartTimeInSeconds:(NSInteger) startTimeSeconds;

@end
