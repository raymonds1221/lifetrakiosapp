//
//  WorkoutHeartRateDataEntity.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/12/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WorkoutHeaderEntity;

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutHeartRateDataEntity : NSManagedObject

+ (WorkoutHeartRateDataEntity *)entityWithHrData:(NSInteger)hrData index:(NSInteger)index;
+ (NSArray *)workoutHeartRateDataEntitiesWithArray:(NSArray *)array forWorkoutHeader:(WorkoutHeaderEntity *)workoutHeader;
+ (WorkoutHeartRateDataEntity *)workoutHeartRateDataWithDictionary:(NSDictionary *)dictionary forWorkoutHeader:(WorkoutHeaderEntity *)workoutHeaderEntity;

- (NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END

#import "WorkoutHeartRateDataEntity+CoreDataProperties.h"
