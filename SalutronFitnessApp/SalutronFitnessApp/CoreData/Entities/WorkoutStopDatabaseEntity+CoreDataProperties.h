//
//  WorkoutStopDatabaseEntity+CoreDataProperties.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/12/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WorkoutStopDatabaseEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutStopDatabaseEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSNumber *stopHour;
@property (nullable, nonatomic, retain) NSNumber *stopHundredth;
@property (nullable, nonatomic, retain) NSNumber *stopMinute;
@property (nullable, nonatomic, retain) NSNumber *stopSecond;
@property (nullable, nonatomic, retain) NSNumber *workoutHour;
@property (nullable, nonatomic, retain) NSNumber *workoutHundredth;
@property (nullable, nonatomic, retain) NSNumber *workoutMinute;
@property (nullable, nonatomic, retain) NSNumber *workoutSecond;
@property (nullable, nonatomic, retain) WorkoutInfoEntity *workout;
@property (nullable, nonatomic, retain) WorkoutHeaderEntity *workoutHeader;

@end

NS_ASSUME_NONNULL_END
