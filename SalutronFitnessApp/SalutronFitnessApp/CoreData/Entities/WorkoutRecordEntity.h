//
//  WorkoutRecordEntity.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/2/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "WorkoutRecord.h"

@class WorkoutHeaderEntity;

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutRecordEntity : NSManagedObject

+ (WorkoutRecordEntity *)entityWithWorkoutRecord:(WorkoutRecord *)workoutRecord;

@end

NS_ASSUME_NONNULL_END

#import "WorkoutRecordEntity+CoreDataProperties.h"
