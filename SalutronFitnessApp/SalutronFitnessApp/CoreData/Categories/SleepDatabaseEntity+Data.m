//
//  SleepDatabaseEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Format.h"

#import "JDACoreData.h"

#import "SFASalutronFitnessAppDelegate.h"

#import "DeviceEntity.h"
#import "DateEntity.h"

#import "SH_Date.h"

#import "SFAServerAccountManager.h"

#import "SleepDatabaseEntity+Data.h"

@implementation SleepDatabaseEntity (Data)

#pragma mark - Private Methods

+ (NSManagedObjectContext *)managedObjectContext
{
    SFASalutronFitnessAppDelegate *appDelegate  = [UIApplication sharedApplication].delegate;
    
    return  appDelegate.managedObjectContext;
}

+ (SleepDatabaseEntity *)sleepDatabaseWithDictionary:(NSDictionary *)dictionary forDeviceEntity:(DeviceEntity *)device
{
    NSString *startTimeString   = [dictionary objectForKey:API_SLEEP_START_TIME];
    NSString *endTimeString     = [dictionary objectForKey:API_SLEEP_END_TIME];
    NSNumber *offset            = @([[dictionary objectForKey:API_SLEEP_OFFSET] floatValue]);
    NSNumber *deepSleepCount    = @([[dictionary objectForKey:API_SLEEP_DEEP_SLEEP_COUNT] floatValue]);
    NSNumber *lightSleepCount   = @([[dictionary objectForKey:API_SLEEP_LIGHT_SLEEP_COUNT] floatValue]);
    NSNumber *lapses            = @([[dictionary objectForKey:API_SLEEP_LAPSES] floatValue]);
    NSNumber *duration          = @([[dictionary objectForKey:API_SLEEP_DURATION] floatValue]);
    NSString *createdDateString = [dictionary objectForKey:API_SLEEP_CREATED_DATE];
    NSNumber *extraInfo         = @([[dictionary objectForKey:API_SLEEP_EXTRA_INFO] floatValue]);
    NSDate *startTime           = [NSDate dateFromString:startTimeString withFormat:API_TIME_FORMAT];
    NSDate *endTime             = [NSDate dateFromString:endTimeString withFormat:API_TIME_FORMAT];
    NSDate *createdDate         = [NSDate dateFromString:createdDateString withFormat:API_DATE_FORMAT];
    
    // Clean this up
    JDACoreData *coreData   = [JDACoreData sharedManager];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"sleepStartHour == %@ AND sleepStartMin == %@ AND dateInNSDate == %@ AND (device.macAddress == '%@') AND (device.user.userID == '%@')",
                               @(startTime.dateComponents.hour),
                               @(startTime.dateComponents.minute),
                               createdDate,
                               device.macAddress,
                               [SFAServerAccountManager sharedManager].user.userID];
    NSArray *results        = [coreData fetchEntityWithEntityName:SLEEP_DATABASE_ENTITY predicate:predicate limit:1];
    
    
    if (results.count > 0) {
        return results.firstObject;
    } else {
        SleepDatabaseEntity *sleep  = [coreData insertNewObjectWithEntityName:SLEEP_DATABASE_ENTITY];
        sleep.deepSleepCount        = deepSleepCount;
        sleep.extraInfo             = extraInfo;
        sleep.lapses                = lapses;
        sleep.lightSleepCount       = lightSleepCount;
        sleep.sleepDuration         = duration;
        sleep.sleepStartHour        = @(startTime.dateComponents.hour);
        sleep.sleepStartMin         = @(startTime.dateComponents.minute);
        sleep.sleepEndHour          = @(endTime.dateComponents.hour);
        sleep.sleepEndMin           = @(endTime.dateComponents.minute);
        sleep.sleepOffset           = offset;
        sleep.dateInNSDate          = createdDate;
        DateEntity *date            = [coreData insertNewObjectWithEntityName:DATE_ENTITY];
        date.month                  = @(createdDate.dateComponents.month);
        date.day                    = @(createdDate.dateComponents.day);
        date.year                   = @(createdDate.dateComponents.year - DATE_YEAR_ADDER);
        sleep.date                  = date;
        
        [device addSleepdatabaseObject:sleep];
        
        return sleep;
    }
}

#pragma mark - Public Methods

+ (NSArray *)sleepDatabaseForDate:(NSDate *)date
{
    // Date
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSString *predicateFormat       = [NSString stringWithFormat:@"(date.month == %i) AND (date.day == %i) AND (date.year == %i) AND (device.macAddress == '%@') AND (device.user.userID == '%@')",
                                       components.month, components.day, components.year - 1900, macAddress, [SFAServerAccountManager sharedManager].user.userID];
    NSPredicate *predicate          = [NSPredicate predicateWithFormat:predicateFormat];
    NSArray *data                   = [[JDACoreData sharedManager] fetchEntityWithEntityName:SLEEP_DATABASE_ENTITY
                                                                             predicate:predicate
                                                                           sortWithKey:@"sleepStartHour"
                                                                             ascending:YES
                                                                              sortType:SORT_TYPE_NUMBER];
    
    return data;
}

+ (NSArray *)sleepDatabaseForDeviceEntity:(DeviceEntity *)device
{
	return device.sleepdatabase.allObjects;
}

+ (NSArray *)sleepDatabasesDictionaryForDeviceEntity:(DeviceEntity *)device
{
    NSMutableArray *sleeps = [NSMutableArray new];
    
    for (SleepDatabaseEntity *sleep in device.sleepdatabase) {
        [sleeps addObject:sleep.dictionary];
    }
    
    return sleeps.copy;
}

+ (NSArray *)sleepDatabasesWithStartingDateDictionaryForDeviceEntity:(DeviceEntity *)device
{
    NSMutableArray *sleeps = [NSMutableArray new];
    
    for (SleepDatabaseEntity *sleep in device.sleepdatabase) {
		/*
		NSDate *sleepEntityDate = [sleep.dateInNSDate dateWithoutTime];
		NSDate *cloudSyncedDate = [device.updatedSynced dateWithoutTime];
		NSDate *currentDate = [[NSDate date] dateWithoutTime];
		
		if ([self isLateOrEqualForDates:sleepEntityDate andDate:cloudSyncedDate]) {
			
			if (!sleep.isSyncedToServer || [sleepEntityDate isEqualToDate:currentDate]) {
		*/		[sleeps addObject:sleep.dictionary];
		/*		LOG(@"DEBUG --> sleepDB date: %@", sleep.dateInNSDate);
			}
			
		}
         */
		/*
		unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:flags fromDate:sleep.dateInNSDate];
        NSDate* date1 = [calendar dateFromComponents:components];
        NSDateComponents* components2 = [calendar components:flags fromDate:device.updatedSynced];
        NSDate* date2 = [calendar dateFromComponents:components2];
        if([date1 isEqualToDate:date2] || [date1 compare:date2]==NSOrderedDescending){
            [sleeps addObject:sleep.dictionary];
        }
		*/
    }
    
    return sleeps.copy;
}

+ (NSArray *)sleepDatabasesDictionaryForDeviceEntity:(DeviceEntity *)device forDate:(NSDate *)date
{
    NSMutableArray *sleeps = [NSMutableArray new];
    
    /*for (SleepDatabaseEntity *sleep in device.sleepdatabase) {
        if ([date isEqualToDate:sleep.dateInNSDate]) {
            [sleeps addObject:sleep.dictionary];
        }
    }*/
    
    NSDateComponents *dateComponents1 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    
    for (SleepDatabaseEntity *sleep in device.sleepdatabase) {
        NSDate *sleepDate = sleep.dateInNSDate;
        NSDateComponents *dateComponents2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:sleepDate];
        
        NSInteger day1      = [dateComponents1 day];
        NSInteger day2      = [dateComponents2 day];
        NSInteger month1    = [dateComponents1 month];
        NSInteger month2    = [dateComponents2 month];
        NSInteger year1     = [dateComponents1 year];
        NSInteger year2     = [dateComponents2 year];
        
        if (day1 == day2 && month1 == month2 && year1 == year2) {
            [sleeps addObject:sleep.dictionary];
        }
    }
    
    return sleeps.copy;
}

+ (BOOL)isLateOrEqualForDates:(NSDate *)date1 andDate:(NSDate *)date2
{
	
	if ([date1 isEqualToDate:date2] || [date1 compare:date2] == NSOrderedDescending) {
		return YES;
	}
	return NO;
}

+ (void)setAllIsSyncedToServer:(BOOL)isSyncedToServer forDeviceEntity:(DeviceEntity *)deviceEntity
{
	for (SleepDatabaseEntity *sleepEntity in deviceEntity.sleepdatabase) {
		
		NSDate *sleepEntityDate = [sleepEntity.dateInNSDate dateWithoutTime];
		NSDate *currentDate = [[NSDate date] dateWithoutTime];
		
		if ([sleepEntityDate isEqualToDate:currentDate]) {
			sleepEntity.isSyncedToServer = [NSNumber numberWithBool:NO];
		}
		else {
			sleepEntity.isSyncedToServer = [NSNumber numberWithBool:isSyncedToServer];
		}
	}
	[[JDACoreData sharedManager] save];
}

+ (NSArray *)sleepDatabasesWithArray:(NSArray *)array forDeviceEntity:(DeviceEntity *)deviceEntity
{
    NSMutableArray *sleepDatabases = [NSMutableArray new];
    
    
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"device.macAddress == %@ AND device.user.userID == %@",
                               deviceEntity.macAddress,
                               [SFAServerAccountManager sharedManager].user.userID];
    
    //JDACoreData *coreData = [JDACoreData sharedManager];
    //[coreData deleteEntityObjectWithEntityName:SLEEP_DATABASE_ENTITY predicate:predicate];
    
    //JDACoreData *coreData = [JDACoreData sharedManager];
    //[coreData deleteEntityObjectsWithEntityName:SLEEP_DATABASE_ENTITY];
    
    for (NSDictionary *dictionary in array) {
        SleepDatabaseEntity *sleepDatabase = [self sleepDatabaseWithDictionary:dictionary forDeviceEntity:deviceEntity];
        [sleepDatabases addObject:sleepDatabase];
    }
    
    return sleepDatabases.copy;
}

// SLEEP DATABASE WATCH BUG TEMPORARY FIX
// Author:      Mark John Revilla | mrevilla@stratpoint.com
// Description: The following lines of code fixes a watch bug in displaying total sleep time.
// Reference:   https://stratpoint.unfuddle.com/a#/projects/53/milestones/434
// TODO:        Remove this when the bug in the watch is fixed.

- (NSInteger)adjustedSleepEndMinutes
{
    // Get actual sleepEndMinutes
    NSInteger sleepEndMinutes = (self.sleepEndHour.integerValue * 60) + self.sleepEndMin.integerValue;
    
    // Adjust sleepEndMinutes based on extraInfo
    // Lower nibble B0~B3 of extraInfo
    // 1 : 10 minutes
    // 2 : 20 minutes
    // 3 : 4 minutes
    // 4 : 60 minutes
    // 5 : 60 minutes
    // 6 : 60 minutes
    
    // Get first 4 Bits of extraInfo and shift right
    NSInteger extraInfo = (self.extraInfo.integerValue&0xf0) >> 4;
    
    // Adjust sleepEndMinutes
    if (extraInfo == 1) {
        sleepEndMinutes += 10;
    } else if (extraInfo == 2) {
        sleepEndMinutes += 20;
    } else if (extraInfo == 3) {
        sleepEndMinutes += 4;
    } else if (extraInfo >= 4 &&
               extraInfo <= 6) {
        sleepEndMinutes += 60;
    }
    
    // Check if sleepEndMinutes is greater than 24 hours * 60 minutes
    if (sleepEndMinutes >= 24 * 60) {
        // Subtract 24 hours * 60 minutes
        sleepEndMinutes -= 24 * 60;
    }
    
    // return the adjusted sleepEndMinutes
    return sleepEndMinutes;
}

// END of SLEEP DATABASE WATCH BUG TEMPORARY FIX

- (NSDictionary *)dictionary
{
    NSString *sleepStartTime        = [NSString stringWithFormat:@"%02d:%02d:00", self.sleepStartHour.integerValue,
                                       self.sleepStartMin.integerValue];
    NSString *sleepEndTime          = [NSString stringWithFormat:@"%02d:%02d:00", self.sleepEndHour.integerValue,
                                       self.sleepEndMin.integerValue];
    NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    dateFormatter.dateFormat        = @"yyyy-MM-dd";
    NSString *dateString            = [dateFormatter stringFromDate:self.dateInNSDate];
    NSDictionary *dictionary        = @{API_SLEEP_START_TIME        : sleepStartTime,
                                        API_SLEEP_END_TIME          : sleepEndTime,
                                        API_SLEEP_OFFSET            : self.sleepOffset,
                                        API_SLEEP_DEEP_SLEEP_COUNT  : self.deepSleepCount,
                                        API_SLEEP_LIGHT_SLEEP_COUNT : self.lightSleepCount,
                                        API_SLEEP_LAPSES            : self.lapses,
                                        API_SLEEP_DURATION          : self.sleepDuration,
                                        API_SLEEP_CREATED_DATE      : dateString,
                                        API_SLEEP_EXTRA_INFO        : self.extraInfo,
                                        API_SLEEP_PLATFORM          : API_PLATFORM};
    
    return dictionary;
}

@end
