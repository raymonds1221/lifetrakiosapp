//
//  WorkoutStopDatabaseEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/7/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFATimeTools.h"
#import "NSDate+Format.h"

#import "WorkoutStopDatabase.h"
#import "WorkoutInfoEntity.h"

#import "JDACoreData.h"

#import "WorkoutStopDatabaseEntity+Data.h"
#import "WorkoutHeaderEntity+CoreDataProperties.h"

@implementation WorkoutStopDatabaseEntity (Data)

#pragma mark - Private Methods

+ (WorkoutStopDatabaseEntity *)workoutStopWithDictionary:(NSDictionary *)dictionary forWorkoutInfoEntity:(WorkoutInfoEntity *)workout
{
    NSString *stopTimeString        = [dictionary objectForKey:API_WORKOUT_STOP_STOP_TIME];
    NSString *workoutTimeString     = [dictionary objectForKey:API_WORKOUT_STOP_WORKOUT_TIME];
    NSDate *stopTime                = [NSDate dateFromString:stopTimeString withFormat:API_TIME_FORMAT];
    NSDate *workoutTime             = [NSDate dateFromString:workoutTimeString withFormat:API_TIME_FORMAT];
    NSNumber *index                 = [dictionary objectForKey:API_WORKOUT_STOP_INDEX];
    NSDateComponents *components    = stopTime.dateComponents;
    NSNumber *stopHour              = @(components.hour);
    NSNumber *stopMinute            = @(components.minute);
    NSNumber *stopSecond            = @(components.second);
    components                      = workoutTime.dateComponents;
    NSNumber *workoutHour           = @(components.hour);
    NSNumber *workoutMinute         = @(components.minute);
    NSNumber *workoutSecond         = @(components.second);
    
    // TODO: Add validation if record exists in CoreData.
    
    JDACoreData *coreData                   = [JDACoreData sharedManager];
    for (WorkoutStopDatabaseEntity *workoutStopDatabaseEntity in workout.workoutStopDatabase.allObjects) {
        NSString *string = [NSString stringWithFormat:@"%@", workoutStopDatabaseEntity.workoutSecond];
        if ([string length] > 1) {
            string = [string substringToIndex:2];
        }
        else if ([string length] == 1) {
            string = [NSString stringWithFormat:@"0%@", string];
        }
        NSNumber *workoutSecond = @(string.integerValue);
        if ([workoutSecond isEqualToNumber:workoutSecond] &&
            [workoutStopDatabaseEntity.workoutMinute isEqualToNumber:workoutMinute] &&
            [workoutStopDatabaseEntity.workoutHour isEqualToNumber:workoutHour] &&
            [workoutStopDatabaseEntity.stopSecond isEqualToNumber:stopSecond] &&
            [workoutStopDatabaseEntity.stopMinute isEqualToNumber:stopMinute] &&
            [workoutStopDatabaseEntity.stopHour isEqualToNumber:stopHour]/* &&
            [workoutStopDatabaseEntity.index isEqualToNumber:@(index)]*/) {
                return workoutStopDatabaseEntity;
            }
    }
    WorkoutStopDatabaseEntity *workoutStop  = [coreData insertNewObjectWithEntityName:WORKOUT_STOP_DATABASE_ENTITY];
    workoutStop.stopHour                    = stopHour;
    workoutStop.stopMinute                  = stopMinute;
    workoutStop.stopSecond                  = stopSecond;
    workoutStop.stopHundredth               = @(0);
    workoutStop.workoutHour                 = workoutHour;
    workoutStop.workoutMinute               = workoutMinute;
    workoutStop.workoutSecond               = workoutSecond;
    workoutStop.workoutHundredth            = @(0);
    workoutStop.index                       = index.integerValue == 0 ? @(0) : @(index.integerValue);
    
    [workout addWorkoutStopDatabaseObject:workoutStop];
    
    return workoutStop;
}

+ (WorkoutStopDatabaseEntity *)workoutStopWithDictionary:(NSDictionary *)dictionary forWorkoutHeader:(WorkoutHeaderEntity *)workoutHeader
{
    NSString *stopTimeString        = [dictionary objectForKey:API_WORKOUT_STOP_STOP_TIME];
    NSString *workoutTimeString     = [dictionary objectForKey:API_WORKOUT_STOP_WORKOUT_TIME];
    NSDate *stopTime                = [NSDate dateFromString:stopTimeString withFormat:API_TIME_FORMAT];
    NSDate *workoutTime             = [NSDate dateFromString:workoutTimeString withFormat:API_TIME_FORMAT];
    NSNumber *index                 = [dictionary objectForKey:API_WORKOUT_STOP_INDEX];
    NSDateComponents *components    = stopTime.dateComponents;
    NSNumber *stopHour              = @(components.hour);
    NSNumber *stopMinute            = @(components.minute);
    NSNumber *stopSecond            = @(components.second);
    components                      = workoutTime.dateComponents;
    NSNumber *workoutHour           = @(components.hour);
    NSNumber *workoutMinute         = @(components.minute);
    NSNumber *workoutSecond         = @(components.second);
    
    // TODO: Add validation if record exists in CoreData.
    
    JDACoreData *coreData                   = [JDACoreData sharedManager];
    for (WorkoutStopDatabaseEntity *workoutStopDatabaseEntity in workoutHeader.workoutStopDatabase.allObjects) {
        NSString *string = [NSString stringWithFormat:@"%@", workoutStopDatabaseEntity.workoutSecond];
        if ([string length] > 1) {
            string = [string substringToIndex:2];
        }
        else if ([string length] == 1) {
            string = [NSString stringWithFormat:@"0%@", string];
        }
        NSNumber *workoutSecond = @(string.integerValue);
        if ([workoutSecond isEqualToNumber:workoutSecond] &&
            [workoutStopDatabaseEntity.workoutMinute isEqualToNumber:workoutMinute] &&
            [workoutStopDatabaseEntity.workoutHour isEqualToNumber:workoutHour] &&
            [workoutStopDatabaseEntity.stopSecond isEqualToNumber:stopSecond] &&
            [workoutStopDatabaseEntity.stopMinute isEqualToNumber:stopMinute] &&
            [workoutStopDatabaseEntity.stopHour isEqualToNumber:stopHour]/* &&
                                                                          [workoutStopDatabaseEntity.index isEqualToNumber:@(index)]*/) {
                                                                              return workoutStopDatabaseEntity;
                                                                          }
    }
    WorkoutStopDatabaseEntity *workoutStop  = [coreData insertNewObjectWithEntityName:WORKOUT_STOP_DATABASE_ENTITY];
    workoutStop.stopHour                    = stopHour;
    workoutStop.stopMinute                  = stopMinute;
    workoutStop.stopSecond                  = stopSecond;
    workoutStop.stopHundredth               = @(0);
    workoutStop.workoutHour                 = workoutHour;
    workoutStop.workoutMinute               = workoutMinute;
    workoutStop.workoutSecond               = workoutSecond;
    workoutStop.workoutHundredth            = @(0);
    workoutStop.index                       = index.integerValue == 0 ? @(0) : @(index.integerValue);
    
    [workoutHeader addWorkoutStopDatabaseObject:workoutStop];
    
    return workoutStop;
}


#pragma mark - Public Methods

+ (WorkoutStopDatabaseEntity *)workoutStopDatabaseEntityWithWorkoutStopDatabase:(WorkoutStopDatabase *)workoutStopDatabase
                                                       workoutStopDatabaseIndex:(NSInteger)index
                                                              workoutInfoEntity:(WorkoutInfoEntity *)workoutInfoEntity
                                                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    // Check for existing WorkoutStopDatabaseEntity in WorkoutInfoEntity
    for (WorkoutStopDatabaseEntity *workoutStopDatabaseEntity in workoutInfoEntity.workoutStopDatabase.allObjects) {
        NSString *string = [NSString stringWithFormat:@"%@", workoutStopDatabaseEntity.workoutSecond];
        NSString *string2 = [NSString stringWithFormat:@"%@", @(workoutStopDatabase.wrkSS)];
        /*
        if ([string length] > 1) {
            string = [string substringToIndex:2];
        }
        else if ([string length] == 1) {
            string = [NSString stringWithFormat:@"0%@", string];
        }
        */
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
            [workoutStopDatabaseEntity.stopHour isEqualToNumber:@(workoutStopDatabase.stopHH)]/* &&
            [workoutStopDatabaseEntity.index isEqualToNumber:@(index)]*/) {
            return workoutStopDatabaseEntity;
        }
    }
    
    // Create new WorkoutStopDatabaseEntity
    WorkoutStopDatabaseEntity *workoutStopDatabaseEntity = [NSEntityDescription insertNewObjectForEntityForName:WORKOUT_STOP_DATABASE_ENTITY
                                                                                         inManagedObjectContext:managedObjectContext];
    
    workoutStopDatabaseEntity.workout           = workoutInfoEntity;
    workoutStopDatabaseEntity.workoutHundredth  = @(workoutStopDatabase.wrkHund);
    workoutStopDatabaseEntity.workoutSecond     = @(workoutStopDatabase.wrkSS);
    workoutStopDatabaseEntity.workoutMinute     = @(workoutStopDatabase.wrkMM);
    workoutStopDatabaseEntity.workoutHour       = @(workoutStopDatabase.wrkHH);
    workoutStopDatabaseEntity.stopHundredth     = @(workoutStopDatabase.stopHund);
    workoutStopDatabaseEntity.stopSecond        = @(workoutStopDatabase.stopSS);
    workoutStopDatabaseEntity.stopMinute        = @(workoutStopDatabase.stopMM);
    workoutStopDatabaseEntity.stopHour          = @(workoutStopDatabase.stopHH);
    workoutStopDatabaseEntity.index             = @(index);
    
    [workoutInfoEntity addWorkoutStopDatabaseObject:workoutStopDatabaseEntity];
    
    return workoutStopDatabaseEntity;
}

+ (WorkoutStopDatabaseEntity *)workoutStopDatabaseEntityWithWorkoutStopDatabase:(WorkoutStopDatabase *)workoutStopDatabase
                                                              workoutInfoEntity:(WorkoutInfoEntity *)workoutInfoEntity
                                                           managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    // Check for existing WorkoutStopDatabaseEntity in WorkoutInfoEntity
    for (WorkoutStopDatabaseEntity *workoutStopDatabaseEntity in workoutInfoEntity.workoutStopDatabase.allObjects) {
        NSString *string = [NSString stringWithFormat:@"%@", workoutStopDatabaseEntity.workoutSecond];
        NSString *string2 = [NSString stringWithFormat:@"%@", @(workoutStopDatabase.wrkSS)];
        /*
         if ([string length] > 1) {
         string = [string substringToIndex:2];
         }
         else if ([string length] == 1) {
         string = [NSString stringWithFormat:@"0%@", string];
         }
         */
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
            [workoutStopDatabaseEntity.stopHour isEqualToNumber:@(workoutStopDatabase.stopHH)]/* &&
            [workoutStopDatabaseEntity.index isEqualToNumber:@(index)]*/) {
                return workoutStopDatabaseEntity;
            }
    }
    
    // Create new WorkoutStopDatabaseEntity
    WorkoutStopDatabaseEntity *workoutStopDatabaseEntity = [NSEntityDescription insertNewObjectForEntityForName:WORKOUT_STOP_DATABASE_ENTITY
                                                                                         inManagedObjectContext:managedObjectContext];
    
    workoutStopDatabaseEntity.workout           = workoutInfoEntity;
    workoutStopDatabaseEntity.workoutHundredth  = @(workoutStopDatabase.wrkHund);
    workoutStopDatabaseEntity.workoutSecond     = @(workoutStopDatabase.wrkSS);
    workoutStopDatabaseEntity.workoutMinute     = @(workoutStopDatabase.wrkMM);
    workoutStopDatabaseEntity.workoutHour       = @(workoutStopDatabase.wrkHH);
    workoutStopDatabaseEntity.stopHundredth     = @(workoutStopDatabase.stopHund);
    workoutStopDatabaseEntity.stopSecond        = @(workoutStopDatabase.stopSS);
    workoutStopDatabaseEntity.stopMinute        = @(workoutStopDatabase.stopMM);
    workoutStopDatabaseEntity.stopHour          = @(workoutStopDatabase.stopHH);
    
    [workoutInfoEntity addWorkoutStopDatabaseObject:workoutStopDatabaseEntity];
    
    return workoutStopDatabaseEntity;
}

+ (NSArray *)workoutStopDatabaseEntitiesWithArray:(NSArray *)array forWorkoutInfoEntity:(WorkoutInfoEntity *)workout
{
    NSMutableArray *workoutStops = [NSMutableArray new];
    
    for (NSDictionary *dictionary in array) {
        WorkoutStopDatabaseEntity *workoutStop = [self workoutStopWithDictionary:dictionary forWorkoutInfoEntity:workout];
        [workoutStops addObject:workoutStop];
    }
    
    return workoutStops.copy;
}

+ (NSArray *)workoutStopDatabaseEntitiesWithArray:(NSArray *)array forWorkoutHeader:(WorkoutHeaderEntity *)workoutHeader
{
    NSMutableArray *workoutStops = [NSMutableArray new];
    
    for (NSDictionary *dictionary in array) {
        WorkoutStopDatabaseEntity *workoutStop = [self workoutStopWithDictionary:dictionary forWorkoutHeader:workoutHeader];
        [workoutStops addObject:workoutStop];
    }
    
    return workoutStops.copy;
}

- (NSDictionary *)dictionary
{
    NSString *workoutTime       = [SFATimeTools timeStringWithHour:self.workoutHour minute:self.workoutMinute second:self.workoutSecond];
    NSString *stopTime          = [SFATimeTools timeStringWithHour:self.stopHour minute:self.stopMinute second:self.stopSecond];
    NSDictionary *dictionary    = @{API_WORKOUT_STOP_WORKOUT_TIME   : workoutTime,
                                    API_WORKOUT_STOP_STOP_TIME      : stopTime,
                                    API_WORKOUT_STOP_INDEX          : self.index};
    
    return dictionary;
}

- (NSInteger)workoutEndTimeFromStartTime:(NSInteger) startTimeMinutes
{
    return startTimeMinutes + self.workoutHour.integerValue*60 + self.workoutMinute.integerValue;
}

- (NSInteger)workoutEndTimeFromStartTimeInSeconds:(NSInteger) startTimeSeconds
{
    return startTimeSeconds + self.workoutHour.integerValue*3600 + self.workoutMinute.integerValue*60 + self.workoutSecond.integerValue;
}

- (NSInteger)workoutAndWorkoutStopEndTimeFromStartTime:(NSInteger) startTimeMinutes
{
    return [self workoutEndTimeFromStartTime:startTimeMinutes] + self.stopHour.integerValue*60 + self.stopMinute.integerValue;
}

- (NSInteger)workoutAndWorkoutStopEndTimeFromStartTimeInSeconds:(NSInteger) startTimeSeconds
{
    return [self workoutEndTimeFromStartTimeInSeconds:startTimeSeconds] + self.stopHour.integerValue*3600 + self.stopMinute.integerValue*60 + self.stopSecond.integerValue;
}

@end
