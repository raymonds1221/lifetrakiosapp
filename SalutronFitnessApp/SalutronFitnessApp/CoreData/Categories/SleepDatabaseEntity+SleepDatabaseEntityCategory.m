//
//  SleepDatabaseEntity+SleepDatabaseEntityCategory.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/9/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SleepDatabaseEntity+SleepDatabaseEntityCategory.h"
#import "SH_Date.h"
#import "DateEntity.h"
#import "SleepDatabaseEntity+Data.h"
#import "SFAServerAccountManager.h"

@implementation SleepDatabaseEntity (SleepDatabaseEntityCategory)

+ (SleepDatabaseEntity *) sleepDatabaseEntityWithRecord:(SleepDatabase *)sleepDatabase
                                          managedObject:(NSManagedObjectContext *)managedObjectContext {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:SLEEP_DATABASE_ENTITY];
    NSString *query =  @"sleepStartHour == $sleepStartHour AND sleepStartMin == $sleepStartMin AND sleepEndHour == $sleepEndHour AND sleepEndMin == $sleepEndMin AND device.macAddress == $macAddress AND device.user.userID == \"$userID\"";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
    NSUserDefaults *userDefaults        = [NSUserDefaults standardUserDefaults];
    NSString *macAddress                = [userDefaults objectForKey:MAC_ADDRESS];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:sleepDatabase.sleep_start_hr], @"sleepStartHour", [NSNumber numberWithInt:sleepDatabase.sleep_start_min], @"sleepStartMin", [NSNumber numberWithInt:sleepDatabase.sleep_end_hr], @"sleepEndHour", [NSNumber numberWithInt:sleepDatabase.sleep_end_min], @"sleepEndMin", macAddress ,@"macAddress", [SFAServerAccountManager sharedManager].user.userID, @"userID", nil];
    predicate = [predicate predicateWithSubstitutionVariables:params];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    SleepDatabaseEntity *sleepDatabaseEntity = nil;
    
    NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error && [results count] > 0) {
        sleepDatabaseEntity = [results firstObject];
    } else {
        sleepDatabaseEntity = [self sleepDatabaseEntityOverlappingSleepDatabase:sleepDatabase];
        
        if (sleepDatabaseEntity) {
            return sleepDatabaseEntity;
        }
    }
    
    if(sleepDatabaseEntity == nil)
        sleepDatabaseEntity = [NSEntityDescription insertNewObjectForEntityForName:SLEEP_DATABASE_ENTITY
                                                                                 inManagedObjectContext:managedObjectContext];
    
    sleepDatabaseEntity.deepSleepCount = [NSNumber numberWithInt:sleepDatabase.deepsleepcount];
    sleepDatabaseEntity.extraInfo = [NSNumber numberWithInt:sleepDatabase.extra_info];
    sleepDatabaseEntity.lapses = [NSNumber numberWithInt:sleepDatabase.lapses];
    sleepDatabaseEntity.lightSleepCount = [NSNumber numberWithInt:sleepDatabase.lightsleepcount];
    sleepDatabaseEntity.sleepDuration = [NSNumber numberWithInt:sleepDatabase.sleepduration];
    sleepDatabaseEntity.sleepStartHour = [NSNumber numberWithInt:sleepDatabase.sleep_start_hr];
    sleepDatabaseEntity.sleepStartMin = [NSNumber numberWithInt:sleepDatabase.sleep_start_min];
    sleepDatabaseEntity.sleepEndHour = [NSNumber numberWithInt:sleepDatabase.sleep_end_hr];
    sleepDatabaseEntity.sleepEndMin = [NSNumber numberWithInt:sleepDatabase.sleep_end_min];
    sleepDatabaseEntity.sleepOffset = [NSNumber numberWithInt:sleepDatabase.sleepoffset];
    
    SH_Date *date = sleepDatabase.date;
    DateEntity *dateEntity = [NSEntityDescription insertNewObjectForEntityForName:DATE_ENTITY inManagedObjectContext:managedObjectContext];
    
    dateEntity.day = [NSNumber numberWithInt:date.day];
    dateEntity.month = [NSNumber numberWithInt:date.month];
    dateEntity.year = [NSNumber numberWithInt:date.year];
    
    sleepDatabaseEntity.date = dateEntity;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setSecond:0];
    [components setMinute:0];
    [components setHour:0];
    [components setDay:date.day];
    [components setMonth:date.month];
    [components setYear:date.year + 1900];
    
    sleepDatabaseEntity.dateInNSDate = [calendar dateFromComponents:components];
    
    return sleepDatabaseEntity;
}

+ (SleepDatabaseEntity *)sleepDatabaseEntityOverlappingSleepDatabase:(SleepDatabase *)sleepDatabase
{
    SH_Date *date = sleepDatabase.date;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [NSDateComponents new];
    [components setSecond:0];
    [components setMinute:0];
    [components setHour:0];
    [components setDay:date.day];
    [components setMonth:date.month];
    [components setYear:date.year + 1900];
    
    NSInteger newSleepStart     = sleepDatabase.sleep_start_hr * 60 + sleepDatabase.sleep_start_min;
    NSInteger newSleepEnd       = sleepDatabase.sleep_end_hr * 60 + sleepDatabase.sleep_end_min;
    NSDate *sleepDate           = [calendar dateFromComponents:components];
    sleepDate                   = newSleepStart >= newSleepEnd ? [sleepDate dateByAddingTimeInterval:DAY_SECONDS] : sleepDate;
    NSDate *yesterday           = [sleepDate dateByAddingTimeInterval:-DAY_SECONDS];
    NSArray *yesterdaySleeps    = [SleepDatabaseEntity sleepDatabaseForDate:yesterday];
    NSArray *sleeps             = [SleepDatabaseEntity sleepDatabaseForDate:sleepDate];
    
    if (newSleepStart < newSleepEnd) {
        newSleepStart += 24 * 60;
    } else if (newSleepStart == 0 &&
               newSleepEnd == 0) {
        newSleepStart   += 24 * 60;
        newSleepEnd     += 24 * 60;
    }
    
    newSleepEnd += 24 * 60;
    
    for (SleepDatabaseEntity *sleep in yesterdaySleeps) {
        NSInteger sleepStart    = sleep.sleepStartHour.integerValue * 60 + sleep.sleepStartMin.integerValue;
        NSInteger sleepEnd      = sleep.sleepEndHour.integerValue * 60 + sleep.sleepEndMin.integerValue;
        
        if (sleepStart > sleepEnd) {
            sleepEnd += 24 * 60;
        }
        
        if (newSleepStart >= sleepStart &&
            newSleepStart <= sleepEnd) {
            return sleep;
        } else if (newSleepEnd >= sleepStart &&
                   newSleepEnd <= sleepEnd) {
            return sleep;
        } else if (sleepStart >= newSleepStart &&
                   sleepStart <= newSleepEnd) {
            return sleep;
        } else if (sleepEnd >= newSleepStart &&
                   sleepEnd <= newSleepEnd) {
            return sleep;
        }
    }
    
    for (SleepDatabaseEntity *sleep in sleeps)
    {
        NSInteger sleepStart    = sleep.sleepStartHour.integerValue * 60 + sleep.sleepStartMin.integerValue + 24 * 60;
        NSInteger sleepEnd      = sleep.sleepEndHour.integerValue * 60 + sleep.sleepEndMin.integerValue + 24 * 60;
        
        if (newSleepStart >= sleepStart &&
            newSleepStart <= sleepEnd) {
            return sleep;
        } else if (newSleepEnd >= sleepStart &&
                   newSleepEnd <= sleepEnd) {
            return sleep;
        } else if (sleepStart >= newSleepStart &&
                   sleepStart <= newSleepEnd) {
            return sleep;
        } else if (sleepEnd >= newSleepStart &&
                   sleepEnd <= newSleepEnd) {
            return sleep;
        }
    }
    
    return nil;
}

@end
