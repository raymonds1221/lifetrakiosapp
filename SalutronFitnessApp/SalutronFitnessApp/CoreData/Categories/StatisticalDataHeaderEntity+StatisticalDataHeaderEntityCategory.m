//
//  StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/13/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "SH_Date.h"
#import "DateEntity.h"
#import "TimeEntity.h"
#import "SFAServerAccountManager.h"

#import "JDACoreData.h"

@implementation StatisticalDataHeaderEntity (StatisticalDataHeaderEntityCategory)

+ (StatisticalDataHeaderEntity *)statisticalDataHeaderEntityForDate:(NSDate *)date
{
    NSArray *data                   = [self statisticalDataHeaderEntitiesForDate:date];
    return [data firstObject];
}

+ (NSArray *)statisticalDataHeaderEntitiesForDate:(NSDate *)date
{
    NSManagedObjectContext *context = [[JDACoreData sharedManager] context];
    
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSInteger year                  = [components year] - 1900;
    NSInteger month                 = [components month];
    NSInteger day                   = [components day];
    NSString  *macAddress           = [[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS];
    NSString  *userID               = [SFAServerAccountManager sharedManager].user.userID;
    
    if (macAddress) {
        NSString *predicateFormat       = @"date.month == $month AND date.day == $day AND date.year == $year AND device.macAddress == $macAddress AND device.user.userID == $userID";
        if (userID == nil) {
            predicateFormat       = @"date.month == $month AND date.day == $day AND date.year == $year AND device.macAddress == $macAddress AND device.user.userID = nil";
        }
        NSFetchRequest *fetchRequest    = [[NSFetchRequest alloc] initWithEntityName:STATISTICAL_DATA_HEADER_ENTITY];
        NSPredicate *predicate          = [NSPredicate predicateWithFormat:predicateFormat];
        NSDictionary *dictionary        = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:month],@"month",[NSNumber numberWithInteger:day],@"day",[NSNumber numberWithInteger:year],@"year", macAddress,@"macAddress", userID, @"userID", nil];
        predicate                       = [predicate predicateWithSubstitutionVariables:dictionary];
        fetchRequest.predicate          = predicate;
        
        NSError *error                  = nil;
        NSArray *data                   = [context executeFetchRequest:fetchRequest error:&error];
        return data;
    }
    return nil;
}

#pragma mark - Public class insert methods
+ (id) statisticalForInsertDataHeader:(StatisticalDataHeader *)dataHeader
   inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    
    StatisticalDataHeaderEntity *dataHeaderEntity = [[JDACoreData sharedManager] insertNewObjectWithEntityName:STATISTICAL_DATA_HEADER_ENTITY];
    
    [self entityWithStatisticalDataHeader:dataHeader DataHeaderEntity:dataHeaderEntity];
    
    return dataHeaderEntity;
}

+ (BOOL)updateEntityWithStatisticalDataHeader:(StatisticalDataHeader *)dataHeader
                                       entity:(StatisticalDataHeaderEntity *)dataHeaderEntity
                       inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    [self entityWithStatisticalDataHeader:dataHeader DataHeaderEntity:dataHeaderEntity];
    
    NSError *error = nil;
    
    if([managedObjectContext save:&error]) {
        if(!error) {
            return YES;
        } else {
            DDLogError(@"updateEntityWithStatisticalDataHeader error: %@", [error localizedDescription]);
        }
    }
    
    return NO;
}

+ (id)entityWithStatisticalDataHeader:(StatisticalDataHeader *)dataHeader
                     DataHeaderEntity:(StatisticalDataHeaderEntity *)dataHeaderEntity
{
    dataHeaderEntity.allocationBlockIndex	= [NSNumber numberWithInt:dataHeader.allocationBlockIndex];
    dataHeaderEntity.totalCalorie			= [NSNumber numberWithDouble:dataHeader.totalCalorie];
    dataHeaderEntity.totalDistance			= [NSNumber numberWithDouble:dataHeader.totalDistance];
    dataHeaderEntity.totalSleep				= [NSNumber numberWithInt:dataHeader.totalSleep];
    dataHeaderEntity.totalSteps				= [NSNumber numberWithInt:dataHeader.totalSteps];
    dataHeaderEntity.totalExposureTime		= [NSNumber numberWithInt:dataHeader.totalExposureTime];
    dataHeaderEntity.minHR					= [NSNumber numberWithInt:dataHeader.minHR];
    dataHeaderEntity.maxHR					= [NSNumber numberWithInt:dataHeader.maxHR];
	dataHeaderEntity.isSyncedToServer		= [NSNumber numberWithBool:NO];
	
    SH_Date *shDate = dataHeader.date;
    DateEntity *dateEntity = [[JDACoreData sharedManager] insertNewObjectWithEntityName:DATE_ENTITY];
    dateEntity.day = [NSNumber numberWithInt:shDate.day];
    dateEntity.month = [NSNumber numberWithInt:shDate.month];
    dateEntity.year = [NSNumber numberWithInt:shDate.year];
    dataHeaderEntity.date = dateEntity;
    
    SH_Time *shStartTime = dataHeader.startTime;
    SH_Time *shEndTime = dataHeader.endTime;
    TimeEntity *timeEntity = [[JDACoreData sharedManager] insertNewObjectWithEntityName:TIME_ENTITY];
    
    timeEntity.startSecond = [NSNumber numberWithInt:shStartTime.second];
    timeEntity.startMinute = [NSNumber numberWithInt:shStartTime.minute];
    timeEntity.startHour = [NSNumber numberWithInt:shStartTime.hour];
    timeEntity.endSecond = [NSNumber numberWithInt:shEndTime.second];
    timeEntity.endMinute = [NSNumber numberWithInt:shEndTime.minute];
    timeEntity.endHour = [NSNumber numberWithInt:shEndTime.hour];
    
    dataHeaderEntity.time = timeEntity;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
//    components.timeZone          = [NSTimeZone timeZoneWithName:@"UTC"];
    components.timeZone          = [NSTimeZone localTimeZone];
    [components setDay:shDate.day];
    [components setMonth:shDate.month];
    [components setYear:shDate.year + 1900];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    dataHeaderEntity.dateInNSDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    return dataHeaderEntity;
}


#pragma mark - Public instance delete method
- (void)deleteObject
{
    [[JDACoreData sharedManager] deleteEntityObjectWithObject:self];
    [[JDACoreData sharedManager] save];
}

@end
