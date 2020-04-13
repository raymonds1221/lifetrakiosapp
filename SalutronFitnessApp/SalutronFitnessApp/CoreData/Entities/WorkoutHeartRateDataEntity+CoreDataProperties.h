//
//  WorkoutHeartRateDataEntity+CoreDataProperties.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/12/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WorkoutHeartRateDataEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutHeartRateDataEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *hrData;
@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) WorkoutHeaderEntity *workoutHeader;

@end

NS_ASSUME_NONNULL_END
