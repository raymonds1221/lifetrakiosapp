//
//  WorkoutStopDatabaseEntity.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/12/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import "WorkoutStopDatabaseEntity.h"
#import "WorkoutHeaderEntity.h"
#import "WorkoutInfoEntity.h"
#import "JDACoreData.h"

@implementation WorkoutStopDatabaseEntity

+ (WorkoutStopDatabaseEntity *)entityWithWorkoutHeaderEntity:(WorkoutHeaderEntity *)workoutHeaderEntity index:(NSInteger)index workoutStopDatabase:(WorkoutStopDatabase *)workoutStopDatabase
{
    for (WorkoutStopDatabaseEntity *workoutStopDatabaseEntity in workoutHeaderEntity.workoutStopDatabase.allObjects) {
        NSString *string = [NSString stringWithFormat:@"%@", workoutStopDatabaseEntity.workoutSecond];
        NSString *string2 = [NSString stringWithFormat:@"%@", @(workoutStopDatabase.wrkSS)];
        
        if ([string length] > 0 && [string2 length] > 0) {
            string = [string substringToIndex:1];
            string2 = [string2 substringToIndex:1];
        }
        NSNumber *workoutSecond = @(string.integerValue);
        NSNumber *workoutStopDatabaseSecond = @(string2.integerValue);
        if ([workoutSecond isEqualToNumber:workoutStopDatabaseSecond] &&
            [workoutStopDatabaseEntity.workoutMinute isEqualToNumber:@(workoutStopDatabase.wrkMM)] &&
            [workoutStopDatabaseEntity.workoutHour isEqualToNumber:@(workoutStopDatabase.wrkHH)] &&
            [workoutStopDatabaseEntity.stopSecond isEqualToNumber:@(workoutStopDatabase.stopSS)] &&
            [workoutStopDatabaseEntity.stopMinute isEqualToNumber:@(workoutStopDatabase.stopMM)] &&
            [workoutStopDatabaseEntity.stopHour isEqualToNumber:@(workoutStopDatabase.stopHH)]) {
            return workoutStopDatabaseEntity;
        }
    }
    
    WorkoutStopDatabaseEntity *workoutStopDatabaseEntity = [[JDACoreData sharedManager] insertNewObjectWithEntityName:WORKOUT_STOP_DATABASE_ENTITY];
    
    workoutStopDatabaseEntity.workoutHeader     = workoutHeaderEntity;
    workoutStopDatabaseEntity.workoutHundredth  = @(workoutStopDatabase.wrkHund);
    workoutStopDatabaseEntity.workoutSecond     = @(workoutStopDatabase.wrkSS);
    workoutStopDatabaseEntity.workoutMinute     = @(workoutStopDatabase.wrkMM);
    workoutStopDatabaseEntity.workoutHour       = @(workoutStopDatabase.wrkHH);
    workoutStopDatabaseEntity.stopHundredth     = @(workoutStopDatabase.stopHund);
    workoutStopDatabaseEntity.stopSecond        = @(workoutStopDatabase.stopSS);
    workoutStopDatabaseEntity.stopMinute        = @(workoutStopDatabase.stopMM);
    workoutStopDatabaseEntity.stopHour          = @(workoutStopDatabase.stopHH);
    workoutStopDatabaseEntity.index             = @(index);
    
    [workoutHeaderEntity addWorkoutStopDatabaseObject:workoutStopDatabaseEntity];
    
    return workoutStopDatabaseEntity;
}

@end
