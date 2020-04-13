//
//  GoalsEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Format.h"

#import "JDACoreData.h"

#import "DeviceEntity.h"

#import "GoalsEntity+Data.h"

@implementation GoalsEntity (Data)

#pragma mark - Private Methods

+ (GoalsEntity *)goalsEntityWithDictionary:(NSDictionary *)dictionary forDeviceEntity:(DeviceEntity *)device
{
    NSNumber *calories      = @([[dictionary objectForKey:API_GOAL_CALORIES] floatValue]);
    NSNumber *steps         = @([[dictionary objectForKey:API_GOAL_STEPS] floatValue]);
    NSNumber *distance      = @([[dictionary objectForKey:API_GOAL_DISTANCE] floatValue]);
    NSNumber *sleep         = @([[dictionary objectForKey:API_GOAL_SLEEP] floatValue]);
    NSString *dateString    = [dictionary objectForKey:API_GOAL_CREATED_DATE];
    NSDate *date            = [NSDate dateFromString:dateString withFormat:API_DATE_TIME_FORMAT];
    
    JDACoreData *coreData   = [JDACoreData sharedManager];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"date == %@", date];
    
    NSArray *results        = [coreData fetchEntityWithEntityName:GOALS_ENTITY predicate:predicate sortWithKey:@"date" limit:1 ascending:YES sortType:SORT_TYPE_NOTHING];
    
    if (results.count > 0) {
        return results.firstObject;
    } else {
        GoalsEntity *goalsEntity    = [coreData insertNewObjectWithEntityName:GOALS_ENTITY];
        goalsEntity.calories        = calories;
        goalsEntity.steps           = steps;
        goalsEntity.distance        = distance;
        goalsEntity.sleep           = sleep;
        goalsEntity.date            = date;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:calories forKey:CALORIE_GOAL];
        [userDefaults setObject:steps forKey:STEP_GOAL];
        [userDefaults setObject:distance forKey:DISTANCE_GOAL];
        [userDefaults setObject:sleep forKey:SLEEP_GOAL];
        
        [device addGoalsObject:goalsEntity];
        
        return goalsEntity;
    }
}

#pragma mark - Public Methods

+ (NSArray *)goalsEntitiesDictionaryForDeviceEntity:(DeviceEntity *)device
{
    NSMutableArray *goals = [NSMutableArray new];
    
    for (GoalsEntity *goal in device.goals) {
        [goals addObject:goal.dictionary];
    }
    
    return goals.copy;
}

+ (NSArray *)goalsEntitiesWithArray:(NSArray *)array forDeviceEnitity:(DeviceEntity *)device
{
    NSMutableArray *goals = [NSMutableArray new];
    
    for (NSDictionary *dictionary in array) {
        GoalsEntity *goal = [self goalsEntityWithDictionary:dictionary forDeviceEntity:device];
        [goals addObject:goal];
    }
    
    return goals.copy;
}


- (NSDictionary *)dictionary
{
    //handle nil value
    if(!self.date) self.date = [NSDate date];
    if(!self.calories) self.calories = @(2000);
    if(!self.steps) self.steps = @(10000);
    if(!self.distance) self.distance = @(3.22);
    if(!self.sleep) self.sleep = @(480);
    
    NSString *dateString        = [self.date stringWithFormat:API_DATE_TIME_FORMAT];
    NSDictionary *dictionary    = @{API_GOAL_CALORIES       : self.calories,
                                    API_GOAL_STEPS          : self.steps,
                                    API_GOAL_DISTANCE       : self.distance,
                                    API_GOAL_SLEEP          : self.sleep,
                                    API_GOAL_CREATED_DATE   : dateString};
    return dictionary;
}

@end
