//
//  StatisticalDataHeaderEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/7/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "JDACoreData.h"

#import "NSDate+Format.h"

#import "DeviceEntity.h"
#import "TimeEntity.h"
#import "DateEntity.h"
#import "StatisticalDataPointEntity+Data.h"
#import "LightDataPointEntity+Data.h"
#import "StatisticalDataHeaderEntity+Data.h"
#import "SFAServerAccountManager.h"

@implementation StatisticalDataHeaderEntity (Data)

#pragma mark - Private Methods

+ (StatisticalDataHeaderEntity *)statisticalDataHeaderEntityWithStatisticalDataHeader:(StatisticalDataHeader *)statisticalDataHeader
                                                                         deviceEntity:(DeviceEntity *)deviceEntity
                                                                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    StatisticalDataHeaderEntity *dataHeaderEntity = [NSEntityDescription insertNewObjectForEntityForName:STATISTICAL_DATA_HEADER_ENTITY
                                                                                  inManagedObjectContext:managedObjectContext];
    
    
    
    return dataHeaderEntity;
}

+ (NSArray *)dataHeadersDictionaryForDeviceEntity:(DeviceEntity *)device
{
    NSMutableArray *dataHeaders = [NSMutableArray new];
    
    for (StatisticalDataHeaderEntity *dataHeader in device.header) {
        [dataHeaders addObject:dataHeader.dictionary];
    }
    
    return dataHeaders.copy;
}

+ (NSArray *)dataHeadersForDeviceEntity:(DeviceEntity *)device
{
    NSMutableArray *dataHeaders = [NSMutableArray new];
    
    for (StatisticalDataHeaderEntity *dataHeader in device.header) {
        [dataHeaders addObject:dataHeader];
    }
    
    return dataHeaders.copy;
}

+ (NSArray *)dataHeadersDictionaryWithContext:(NSManagedObjectContext *)context device:(DeviceEntity *)device
{
    NSMutableArray *dataHeaders = [NSMutableArray new];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:STATISTICAL_DATA_HEADER_ENTITY];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"device.macAddress == %@ AND device.user.userID == %@", device.macAddress, [SFAServerAccountManager sharedManager].user.userID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    DDLogInfo(@"----------> DATA HEADER COUNT : %i", [results count]);
    
    if (results.count == 0) {
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"device.macAddress == %@ AND device.user.userID == %@", device.macAddress, nil];
        [fetchRequest setPredicate:predicate2];
        NSError *error2 = nil;
        results = [context executeFetchRequest:fetchRequest error:&error2];
    }
    
    DDLogInfo(@"----------> DATA HEADER COUNT : %i", [results count]);
    
    for(StatisticalDataHeaderEntity *dataHeader in results) {
        DDLogInfo(@"----------> DATAHEADER DATE : %@", dataHeader.dateInNSDate);
        [dataHeaders addObject:dataHeader.dictionary];
    }
    
    return dataHeaders.copy;
}

+ (NSArray *)dataHeadersWithStartedDateDictionaryWithContext:(NSManagedObjectContext *)context device:(DeviceEntity *)device
{
    NSMutableArray *dataHeaders = [NSMutableArray new];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:STATISTICAL_DATA_HEADER_ENTITY];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"device.macAddress == %@ AND device.user.userID == %@", device.macAddress, [SFAServerAccountManager sharedManager].user.userID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    DDLogInfo(@"----------> DATA HEADER COUNT : %i", [results count]);
    
    for(StatisticalDataHeaderEntity *dataHeader in results) {
        //DDLogInfo(@"----------> DATAHEADER DATE : %@", dataHeader.dateInNSDate);
		
		NSDate *headerEntityDate = [dataHeader.dateInNSDate dateWithoutTime];
		NSDate *cloudSyncedDate = [device.updatedSynced dateWithoutTime];
		NSDate *currentDate = [[NSDate date] dateWithoutTime];
		
		//if ([self isLateOrEqualForDates:headerEntityDate andDate:cloudSyncedDate]) {
			if ([self isLateOrEqualForDates:headerEntityDate andDate:cloudSyncedDate]||
                [dataHeader.isSyncedToServer isEqualToNumber:[NSNumber numberWithBool:NO]] ||
                [headerEntityDate isEqualToDate:currentDate]) {
                [dataHeaders addObject:dataHeader.dictionary];
                DDLogInfo(@"cloudSyncedDate - %@", cloudSyncedDate);
				DDLogInfo(@"DEBUG --> sdh date: %@", dataHeader.dateInNSDate);
			}
			
       // }
    }
    
    DDLogInfo(@"----------> DATA HEADER COUNT FOR UPLOAD : %i", dataHeaders.count);
    return dataHeaders.copy;
}

+ (BOOL)isLateOrEqualForDates:(NSDate *)date1 andDate:(NSDate *)date2
{
	
	if ([date1 isEqualToDate:date2] || [date1 compare:date2] == NSOrderedDescending) {
		return YES;
	}
    return NO;
}


+ (StatisticalDataHeaderEntity *)dataHeaderWithDictionary:(NSDictionary *)dictionary forDeviceEntity:(DeviceEntity *)deviceEntity
{
    NSNumber *maxHR                 = @([[dictionary objectForKey:API_DATA_HEADER_MAX_HR] floatValue]);
    NSNumber *minHR                 = @([[dictionary objectForKey:API_DATA_HEADER_MIN_HR] floatValue]);
    NSNumber *allocationBlockIndex  = @([[dictionary objectForKey:API_DATA_HEADER_ALLOCATION_BLOCK_INDEX] floatValue]);
    NSNumber *totalSleep            = @([[dictionary objectForKey:API_DATA_HEADER_TOTAL_SLEEP] floatValue]);
    NSNumber *totalSteps            = @([[dictionary objectForKey:API_DATA_HEADER_TOTAL_STEPS] floatValue]);
    NSNumber *totalCalories         = @([[dictionary objectForKey:API_DATA_HEADER_TOTAL_CALORIES] floatValue]);
    NSNumber *totalDistance         = @([[dictionary objectForKey:API_DATA_HEADER_TOTAL_DISTANCE] floatValue]);
    NSNumber *totalExposureTime     = @([[dictionary objectForKey:API_DATA_HEADER_TOTAL_EXPOSURE_TIME] floatValue]);
    NSString *createdDateString     = [dictionary objectForKey:API_DATA_HEADER_CREATED_DATE];
    NSString *startTimeString       = [dictionary objectForKey:API_DATA_HEADER_START_TIME];
    NSString *endTimeString         = [dictionary objectForKey:API_DATA_HEADER_END_TIME];
    NSArray *dataPoints             = [dictionary objectForKey:API_DATA_HEADER_DATA_POINT];
    NSArray *lightDataPoints        = [dictionary objectForKey:API_DATA_HEADER_LIGHT_DATA_POINT];
    
    NSDate *startTime               = [NSDate dateFromString:startTimeString withFormat:API_TIME_FORMAT];
    NSDate *endTime                 = [NSDate dateFromString:endTimeString withFormat:API_TIME_FORMAT];
//    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
//    dateFormatter.timeZone          = [NSTimeZone systemTimeZone];
//    dateFormatter.dateFormat        = API_DATE_FORMAT;
//    NSDate *createdDate             = [dateFormatter dateFromString:createdDateString];
    NSDate *createdDate             = [NSDate dateFromString:createdDateString withFormat:API_DATE_FORMAT];
    
    // Clean this up
    JDACoreData *coreData   = [JDACoreData sharedManager];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"dateInNSDate == %@ AND device.macAddress == %@ AND device.user.userID == %@",
                               createdDate,
                               deviceEntity.macAddress,
                               [SFAServerAccountManager sharedManager].user.userID];
    NSArray *results        = [coreData fetchEntityWithEntityName:STATISTICAL_DATA_HEADER_ENTITY predicate:predicate limit:1];
	
    
    if (results.count > 0) {
        StatisticalDataHeaderEntity *dataHeader = results.firstObject; //add sleeplogs duration created from app
        if (dataHeader.dataPoint.count < 144) {
            [[JDACoreData sharedManager] deleteEntityObjectWithEntityName:STATISTICAL_DATA_HEADER_ENTITY predicate:predicate];
            StatisticalDataHeaderEntity *dataHeader = [coreData insertNewObjectWithEntityName:STATISTICAL_DATA_HEADER_ENTITY];
            dataHeader.isSyncedToServer				= [NSNumber numberWithBool:YES];
            dataHeader.maxHR                        = maxHR;
            dataHeader.minHR                        = minHR;
            dataHeader.allocationBlockIndex         = allocationBlockIndex;
            dataHeader.totalSleep                   = totalSleep;
            dataHeader.totalSteps                   = totalSteps;
            dataHeader.totalCalorie                 = totalCalories;
            dataHeader.totalDistance                = totalDistance;
            dataHeader.dateInNSDate                 = createdDate;
            dataHeader.totalExposureTime            = totalExposureTime;
            DateEntity *date                        = [coreData insertNewObjectWithEntityName:DATE_ENTITY];
            date.month                              = @(createdDate.dateComponents.month);
            date.day                                = @(createdDate.dateComponents.day);
            date.year                               = @(createdDate.dateComponents.year - DATE_YEAR_ADDER);
            dataHeader.date                         = date;
            TimeEntity *time                        = [coreData insertNewObjectWithEntityName:TIME_ENTITY];
            time.startHour                          = @(startTime.dateComponents.hour);
            time.startMinute                        = @(startTime.dateComponents.minute);
            time.startSecond                        = @(startTime.dateComponents.second);
            time.endHour                            = @(endTime.dateComponents.hour);
            time.endMinute                          = @(endTime.dateComponents.minute);
            time.endSecond                          = @(endTime.dateComponents.second);
            dataHeader.time                         = time;
            
            [deviceEntity addHeaderObject:dataHeader];
            
            NSArray *statisticalDataPoints = [StatisticalDataPointEntity dataPointsWithArray:dataPoints forDataHeader:dataHeader];
            [LightDataPointEntity dataPointsWithArray:lightDataPoints dataPoints:statisticalDataPoints forDataHeader:dataHeader];
            
            return dataHeader;
        }
        else{
            return results.firstObject;
        }
    } else {
        StatisticalDataHeaderEntity *dataHeader = [coreData insertNewObjectWithEntityName:STATISTICAL_DATA_HEADER_ENTITY];
		dataHeader.isSyncedToServer				= [NSNumber numberWithBool:YES];
        dataHeader.maxHR                        = maxHR;
        dataHeader.minHR                        = minHR;
        dataHeader.allocationBlockIndex         = allocationBlockIndex;
        dataHeader.totalSleep                   = totalSleep;
        dataHeader.totalSteps                   = totalSteps;
        dataHeader.totalCalorie                 = totalCalories;
        dataHeader.totalDistance                = totalDistance;
        dataHeader.dateInNSDate                 = createdDate;
        dataHeader.totalExposureTime            = totalExposureTime;
        DateEntity *date                        = [coreData insertNewObjectWithEntityName:DATE_ENTITY];
        date.month                              = @(createdDate.dateComponents.month);
        date.day                                = @(createdDate.dateComponents.day);
        date.year                               = @(createdDate.dateComponents.year - DATE_YEAR_ADDER);
        dataHeader.date                         = date;
        TimeEntity *time                        = [coreData insertNewObjectWithEntityName:TIME_ENTITY];
        time.startHour                          = @(startTime.dateComponents.hour);
        time.startMinute                        = @(startTime.dateComponents.minute);
        time.startSecond                        = @(startTime.dateComponents.second);
        time.endHour                            = @(endTime.dateComponents.hour);
        time.endMinute                          = @(endTime.dateComponents.minute);
        time.endSecond                          = @(endTime.dateComponents.second);
        dataHeader.time                         = time;
        
        [deviceEntity addHeaderObject:dataHeader];
        
        NSArray *statisticalDataPoints = [StatisticalDataPointEntity dataPointsWithArray:dataPoints forDataHeader:dataHeader];
        [LightDataPointEntity dataPointsWithArray:lightDataPoints dataPoints:statisticalDataPoints forDataHeader:dataHeader];
        
        return dataHeader;
    }
}

#pragma mark - Public Methods

+ (NSArray *)dataHeadersWithArray:(NSArray *)array forDeviceEntity:(DeviceEntity *)device
{
    NSMutableArray *dataHeaders = [NSMutableArray new];
    
    for (NSDictionary *dictionary in array) {
        StatisticalDataHeaderEntity *dataHeader = [self dataHeaderWithDictionary:dictionary forDeviceEntity:device];
        [dataHeaders addObject:dataHeader];
    }
    
    return dataHeaders.copy;
}

+ (void)setAllIsSyncedToServer:(BOOL)isSyncedToServer forDeviceEntity:(DeviceEntity *)deviceEntity
{
	for (StatisticalDataHeaderEntity *dataHeaderEntity in [self dataHeadersForDeviceEntity:deviceEntity]) {
		
		NSDate *headerEntityDate = [dataHeaderEntity.dateInNSDate dateWithoutTime];
		NSDate *currentDate = [[NSDate date] dateWithoutTime];
		
		if ([headerEntityDate isEqualToDate:currentDate]) {
			dataHeaderEntity.isSyncedToServer = [NSNumber numberWithBool:NO];
		}
		else {
			dataHeaderEntity.isSyncedToServer = [NSNumber numberWithBool:isSyncedToServer];
		}
	}
	[[JDACoreData sharedManager] save];
}

- (NSDictionary *)dictionary
{
    NSMutableArray *dataPoints      = [NSMutableArray new];
    NSMutableArray *lightDataPoints = [NSMutableArray new];
    
    for (StatisticalDataPointEntity *dataPoint in self.dataPoint) {
        [dataPoints addObject:dataPoint.dictionary];
    }
    
    for (LightDataPointEntity *lightDataPoint in self.lightDataPoint) {
        [lightDataPoints addObject:lightDataPoint.dictionary];
    }
    
    NSString *startTime             = [NSString stringWithFormat:@"%02d:%02d:%02d", self.time.startHour.integerValue,
                                       self.time.startMinute.integerValue, self.time.startSecond.integerValue];
    NSString *endTime               = [NSString stringWithFormat:@"%02d:%02d:%02d", self.time.endHour.integerValue,
                                       self.time.endMinute.integerValue, self.time.endSecond.integerValue];
    NSString *dateString            = [self.dateInNSDate stringWithFormat:API_DATE_FORMAT];
    
    NSMutableDictionary *dictionary = @{API_DATA_HEADER_MAX_HR                  : self.maxHR,
                                        API_DATA_HEADER_MIN_HR                  : self.minHR,
                                        API_DATA_HEADER_ALLOCATION_BLOCK_INDEX  : self.allocationBlockIndex,
                                        API_DATA_HEADER_TOTAL_SLEEP             : self.totalSleep,
                                        API_DATA_HEADER_TOTAL_STEPS             : self.totalSteps,
                                        API_DATA_HEADER_TOTAL_CALORIES          : self.totalCalorie,
                                        API_DATA_HEADER_TOTAL_DISTANCE          : self.totalDistance,
                                        API_DATA_HEADER_TOTAL_EXPOSURE_TIME     : self.totalExposureTime ? self.totalExposureTime : @0,
                                        API_DATA_HEADER_CREATED_DATE            : dateString,
                                        API_DATA_HEADER_START_TIME              : startTime,
                                        API_DATA_HEADER_END_TIME                : endTime,
                                        API_DATA_HEADER_PLATFORM                : API_PLATFORM,
                                        API_DATA_HEADER_DATA_POINT              : dataPoints.copy
                                        }.mutableCopy;
    
    if (lightDataPoints && lightDataPoints.count > 0) {
        [dictionary setObject:lightDataPoints.copy forKey:API_DATA_HEADER_LIGHT_DATA_POINT];
    }
    
    return dictionary.copy;
}

@end
