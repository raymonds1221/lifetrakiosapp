//
//  WorkoutRecordEntity.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/2/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import "WorkoutRecordEntity.h"
#import "WorkoutHeaderEntity.h"
#import "JDACoreData.h"

@implementation WorkoutRecordEntity

+ (WorkoutRecordEntity *)entityWithWorkoutRecord:(WorkoutRecord *)workoutRecord
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    WorkoutRecordEntity *workoutRecordEntity = [coreData insertNewObjectWithEntityName:WORKOUT_RECORD_ENTITY];
    
    workoutRecordEntity.recordType      = [NSNumber numberWithChar:workoutRecord.recordType];
    workoutRecordEntity.splitHundredhts = [NSNumber numberWithChar:workoutRecord.split_hundredths];
    workoutRecordEntity.splitSecond     = [NSNumber numberWithChar:workoutRecord.split_second];
    workoutRecordEntity.splitMinute     = [NSNumber numberWithChar:workoutRecord.split_minute];
    workoutRecordEntity.splitHour       = [NSNumber numberWithChar:workoutRecord.split_hour];
    workoutRecordEntity.steps           = [NSNumber numberWithLong:workoutRecord.steps];
    workoutRecordEntity.distance        = [NSNumber numberWithDouble:workoutRecord.distance];
    workoutRecordEntity.calories        = [NSNumber numberWithDouble:workoutRecord.calories];
    workoutRecordEntity.stopHundredths  = [NSNumber numberWithChar:workoutRecord.stop_hundredths];
    workoutRecordEntity.stopSecond      = [NSNumber numberWithChar:workoutRecord.stop_second];
    workoutRecordEntity.stopMinute      = [NSNumber numberWithChar:workoutRecord.stop_minute];
    workoutRecordEntity.stopHour        = [NSNumber numberWithChar:workoutRecord.stop_hour];
    workoutRecordEntity.hr1             = [NSNumber numberWithChar:workoutRecord.HR1];
    workoutRecordEntity.hr2             = [NSNumber numberWithChar:workoutRecord.HR2];
    workoutRecordEntity.hr3             = [NSNumber numberWithChar:workoutRecord.HR3];
    workoutRecordEntity.hr4             = [NSNumber numberWithChar:workoutRecord.HR4];
    workoutRecordEntity.hr5             = [NSNumber numberWithChar:workoutRecord.HR5];
    workoutRecordEntity.hr6             = [NSNumber numberWithChar:workoutRecord.HR6];
    workoutRecordEntity.hr7             = [NSNumber numberWithChar:workoutRecord.HR7];
    workoutRecordEntity.hr8             = [NSNumber numberWithChar:workoutRecord.HR8];
    
    return workoutRecordEntity;
}

@end
