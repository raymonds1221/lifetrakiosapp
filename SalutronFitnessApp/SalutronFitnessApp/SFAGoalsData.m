//
//  SFAGoalsData.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/17/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAGoalsData.h"
#import "SFAServerAccountManager.h"

#import "JDACoreData.h"

@implementation SFAGoalsData

+ (GoalsEntity *)goalsFromNearestDate:(NSDate *)date
                               macAddress:(NSString *)macAddress
                        managedObject:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:GOALS_ENTITY];
    
    //get start of day
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    NSDate* startOfDay = [[calendar dateFromComponents:components] dateByAddingTimeInterval:[[NSTimeZone localTimeZone]secondsFromGMT]];
    
    if (!startOfDay) {
        return nil;
    }

    //get goals after the start of day, arranged ascendingly
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (device.macAddress == %@) AND (device.user.userID == %@)", startOfDay, macAddress, [SFAServerAccountManager sharedManager].user.userID];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
 //   [fetchRequest setFetchLimit:1];
//    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSDate *currentDate = [NSDate date];
    if(!error) {
        
        if([results count] > 0) {
            
            //check if there are multiple entries for the current date
            NSDate *nextDayDate =[startOfDay dateByAddingTimeInterval:60*60*24];
            NSPredicate *nextDayPredicate = [NSPredicate predicateWithFormat:@"(date < %@)", nextDayDate];
            NSArray *sameDayResults = [results filteredArrayUsingPredicate:nextDayPredicate];
            
            //get the latest goal for that day, if it exists
            if([sameDayResults lastObject] != nil){
                return [sameDayResults lastObject];
            }else{
                return [results firstObject];
            }
            
        } else if([date timeIntervalSinceNow] <= [currentDate timeIntervalSinceNow]) {
            fetchRequest.predicate = nil;
            predicate = [NSPredicate predicateWithFormat:@"device.macAddress == %@ AND device.user.userID == %@", macAddress, [SFAServerAccountManager sharedManager].user.userID];
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
            [fetchRequest setPredicate:predicate];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
//            [fetchRequest setFetchLimit:1];
            
            results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if(!error)
                return [results firstObject];
        } else if([date timeIntervalSinceNow] > [currentDate timeIntervalSinceNow]) {
            predicate = [NSPredicate predicateWithFormat:@"device.macAddress == %@ AND device.user.userID == %@", macAddress, [SFAServerAccountManager sharedManager].user.userID];
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
            
            [fetchRequest setPredicate:predicate];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
            [fetchRequest setFetchLimit:1];
            
            results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if (!error && results.count > 0) {
                return [results firstObject];
            }
        }
    }
    
    return nil;
}

+ (NSArray *)goalsEntitesToDate:(NSDate *)toDate
                     macAddress:(NSString *)macAddress
                  managedObject:(NSManagedObjectContext *)managedObjectContext
{
    NSPredicate *predicate          = [NSPredicate predicateWithFormat:@"date <= %@ AND device.macAddress == %@ AND device.user.userID == %@", toDate, macAddress, [SFAServerAccountManager sharedManager].user.userID];
    NSSortDescriptor *descriptor    = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSFetchRequest *fetchRequest    = [NSFetchRequest fetchRequestWithEntityName:GOALS_ENTITY];
    fetchRequest.predicate          = predicate;
    fetchRequest.sortDescriptors    = @[descriptor];
    NSError *error                  = nil;
    NSArray *results                = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error) {
        if(results.count > 0) {
            return results;
        } else {
            predicate                       = [NSPredicate predicateWithFormat:@"device.macAddress == %@ AND device.user.userID == %@", macAddress, [SFAServerAccountManager sharedManager].user.userID];
            descriptor                      = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
            fetchRequest.predicate          = predicate;
            fetchRequest.sortDescriptors    = @[descriptor];
            fetchRequest.fetchLimit         = 1;
            
            results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if(!error) {
                return results;
            }
        }
    }
    
    return nil;
}

+ (GoalsEntity *)goalsForDate:(NSDate *)date
                  macAddress:(NSString *)macAddress
               managedObject:(NSManagedObjectContext *)managedObjectContext
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    NSDate *goalsDate = [components date];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:GOALS_ENTITY];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@ AND device.macAddress == %@ AND device.user.userID == %@", goalsDate, macAddress, [SFAServerAccountManager sharedManager].user.userID];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error) {
        if(results.count > 0 && [results.firstObject isKindOfClass:[GoalsEntity class]]) {
            return results.firstObject;
        }
    } else {
        DDLogError(@"Error: %@", [error localizedDescription]);
    }

    return nil;
}

+ (BOOL)addGoalsWithSteps:(NSUInteger)steps
                 distance:(CGFloat)distance
                 calories:(NSUInteger)calories
                    sleep:(NSUInteger)sleep
                   device:(DeviceEntity *)device
            managedObject:(NSManagedObjectContext *)managedObjectContext
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSSecondCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
//    [components setSecond:0];
//    [components setMinute:0];
//    [components setHour:0];
    NSDate *currentDate = [calendar dateFromComponents:components];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:GOALS_ENTITY];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@ AND device.macAddress == %@ AND device.user.userID == %@", currentDate, device.macAddress, [SFAServerAccountManager sharedManager].user.userID];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error) {
        GoalsEntity *goalsEntity = nil;
        
        if(results.count > 0) {
            goalsEntity = [results firstObject];
            NSDateComponents *goalDateComponents = [calendar components:NSSecondCalendarUnit|NSMinuteCalendarUnit|NSHourCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:goalsEntity.date];
            if (goalDateComponents.month    == components.month     &&
                goalDateComponents.day      == components.day       &&
                goalDateComponents.year     == components.year      &&
                goalDateComponents.hour     == components.hour      &&
                goalDateComponents.minute   == components.minute    &&
                goalDateComponents.second   == components.second) {
                
                goalsEntity = [NSEntityDescription insertNewObjectForEntityForName:GOALS_ENTITY
                                                            inManagedObjectContext:managedObjectContext];
                [device addGoalsObject:goalsEntity];
            }
        } else {
            goalsEntity = [NSEntityDescription insertNewObjectForEntityForName:GOALS_ENTITY
                                                        inManagedObjectContext:managedObjectContext];
            [device addGoalsObject:goalsEntity];
        }
        
        goalsEntity.steps = [NSNumber numberWithInteger:steps];
        goalsEntity.distance = [NSNumber numberWithFloat:distance];
        goalsEntity.calories = [NSNumber numberWithInteger:calories];
        goalsEntity.sleep = [NSNumber numberWithInteger:sleep];
        goalsEntity.date = currentDate;
        
        /*if([managedObjectContext save:&error])
            return YES;
        else
            DDLogError(@"Error: %@", [error localizedDescription]);*/
        [[JDACoreData sharedManager] save];
        return YES;
    }
    
    return NO;
}

@end
