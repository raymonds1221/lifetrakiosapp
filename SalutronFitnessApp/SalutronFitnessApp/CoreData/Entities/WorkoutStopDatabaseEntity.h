//
//  WorkoutStopDatabaseEntity.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/12/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "WorkoutStopDatabase.h"

@class WorkoutHeaderEntity, WorkoutInfoEntity;

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutStopDatabaseEntity : NSManagedObject

+ (WorkoutStopDatabaseEntity *)entityWithWorkoutHeaderEntity:(WorkoutHeaderEntity *)workoutHeaderEntity
                                                       index:(NSInteger)index
                                         workoutStopDatabase:(WorkoutStopDatabase *)workoutStopDatabase;

@end

NS_ASSUME_NONNULL_END

#import "WorkoutStopDatabaseEntity+CoreDataProperties.h"
