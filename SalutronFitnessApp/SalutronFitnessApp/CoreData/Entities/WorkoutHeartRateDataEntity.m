//
//  WorkoutHeartRateDataEntity.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/12/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import "WorkoutHeartRateDataEntity.h"
#import "WorkoutHeaderEntity.h"
#import "JDACoreData.h"

@implementation WorkoutHeartRateDataEntity

+ (WorkoutHeartRateDataEntity *)entityWithHrData:(NSInteger)hrData index:(NSInteger)index
{
    WorkoutHeartRateDataEntity *workoutHeartRateDataEntity = [[JDACoreData sharedManager] insertNewObjectWithEntityName:WORKOUT_HEART_RATE_DATA_ENTITY];
    workoutHeartRateDataEntity.hrData = [NSNumber numberWithInteger:hrData];
    workoutHeartRateDataEntity.index = [NSNumber numberWithInteger:index];
    
    return workoutHeartRateDataEntity;
}

+ (NSArray *)workoutHeartRateDataEntitiesWithArray:(NSArray *)array forWorkoutHeader:(WorkoutHeaderEntity *)workoutHeader
{
    NSMutableArray *workoutHeartRateData = [[NSMutableArray alloc] init];
    //NSMutableOrderedSet<WorkoutHeartRateDataEntity *> *workoutHeartRateData = [[NSMutableOrderedSet<WorkoutHeartRateDataEntity *> alloc] init];
    for (NSDictionary *hrData in array) {
        WorkoutHeartRateDataEntity *hrEntity = [WorkoutHeartRateDataEntity workoutHeartRateDataWithDictionary:hrData forWorkoutHeader:workoutHeader];
        [workoutHeartRateData addObject:hrEntity];
    }
    [workoutHeartRateData sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
    [workoutHeader addWorkoutHeartRateData:[[NSOrderedSet alloc] initWithArray:workoutHeartRateData]];
    return workoutHeartRateData;
}

+ (WorkoutHeartRateDataEntity *)workoutHeartRateDataWithDictionary:(NSDictionary *)dictionary forWorkoutHeader:(WorkoutHeaderEntity *)workoutHeaderEntity
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    
    NSInteger hrDataValue = [[dictionary valueForKey:API_WORKOUT_HEART_RATE_HR_DATA] integerValue];
    NSInteger indexValue = [[dictionary valueForKey:API_WORKOUT_HEART_RATE_INDEX] integerValue];
    NSNumber *hrData = [NSNumber numberWithInteger:hrDataValue];
    NSNumber *index = [NSNumber numberWithInteger:indexValue];
    
    /*NSString *predicateFormat = [NSString stringWithFormat:@"index == '%@' and workoutHeader == '%@'", index, workoutHeaderEntity];
    
    WorkoutHeartRateDataEntity *workoutHeartRateDataEntity = [[coreData fetchEntityWithEntityName:WORKOUT_HEART_RATE_DATA_ENTITY predicate:[NSPredicate predicateWithFormat:predicateFormat]] firstObject];
    
    if (!workoutHeartRateDataEntity) {
        workoutHeartRateDataEntity = [coreData insertNewObjectWithEntityName:WORKOUT_HEART_RATE_DATA_ENTITY];
        return workoutHeartRateDataEntity;
    }*/
    
    WorkoutHeartRateDataEntity *workoutHeartRateDataEntity = workoutHeartRateDataEntity = [coreData insertNewObjectWithEntityName:WORKOUT_HEART_RATE_DATA_ENTITY];
    
    workoutHeartRateDataEntity.hrData = hrData;
    workoutHeartRateDataEntity.index = index;
    
    //[workoutHeaderEntity addWorkoutHeartRateDataObject:workoutHeartRateDataEntity];
    
    return workoutHeartRateDataEntity;
}

- (NSDictionary *)dictionary
{
    NSDictionary *dictionary = @{
                                 API_WORKOUT_HEART_RATE_HR_DATA : self.hrData,
                                 API_WORKOUT_HEART_RATE_INDEX   : self.index
                                 };
    
    return dictionary;
}

@end
