//
//  WorkoutHeaderEntity.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/12/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import "WorkoutHeaderEntity.h"
#import "DeviceEntity.h"
#import "WorkoutRecordEntity.h"
#import "WorkoutStopDatabaseEntity.h"
#import "WorkoutStopDatabaseEntity+Data.h"
#import "WorkoutHeader.h"
#import "SFAServerAccountManager.h"
#import "JDACoreData.h"
#import "WorkoutHeartRateDataEntity+CoreDataProperties.h"


#import "NSDate+Format.h"
#import "WorkoutStopDatabaseEntity+Data.h"

@implementation WorkoutHeaderEntity

+ (WorkoutHeaderEntity *)entityWithWorkoutHeader:(WorkoutHeader *)workoutHeader
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSString *_predicateFormat;
    NSNumber *stampMonth            = [NSNumber numberWithChar:workoutHeader.stamp_month];
    NSNumber *stampYear             = [NSNumber numberWithChar:workoutHeader.stamp_year];
    NSNumber *stampDay              = [NSNumber numberWithChar:workoutHeader.stamp_day];
    NSNumber *stampMinute           = [NSNumber numberWithChar:workoutHeader.stamp_minute];
    NSNumber *stampHour             = [NSNumber numberWithChar:workoutHeader.stamp_hour];
    NSNumber *stampSecond           = [NSNumber numberWithChar:workoutHeader.stamp_second];
    //sdk may return negative stamp second due to corrupted data
    if (stampSecond.integerValue < 0) {
        stampSecond = @(0);
    }
    
    
    if ([SFAServerAccountManager sharedManager].user.userID) {
        _predicateFormat = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND stampMinute == '%@' AND stampHour == '%@' AND stampSecond == '%@' AND device.macAddress == '%@' AND device.user.userID == '%@'", stampMonth, stampYear, stampDay, stampMinute, stampHour, stampSecond, [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    }
    else{
        _predicateFormat = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND stampMinute == '%@' AND stampHour == '%@' AND stampSecond == '%@' AND device.macAddress == '%@'", stampMonth, stampYear, stampDay, stampMinute, stampHour, stampSecond, [userDefaults objectForKey:MAC_ADDRESS]];
    }
    
    WorkoutHeaderEntity *workoutHeaderEntity = [[[JDACoreData sharedManager] fetchEntityWithEntityName:WORKOUT_HEADER_ENTITY predicate:[NSPredicate predicateWithFormat:_predicateFormat]] firstObject];
    
    if (!workoutHeaderEntity) {
        workoutHeaderEntity = [[JDACoreData sharedManager] insertNewObjectWithEntityName:WORKOUT_HEADER_ENTITY];
    }
    
    workoutHeaderEntity.stampSecond         = stampSecond;
    workoutHeaderEntity.stampHour           = stampHour;
    workoutHeaderEntity.stampMinute         = stampMinute;
    workoutHeaderEntity.stampDay            = stampDay;
    workoutHeaderEntity.stampYear           = stampYear;
    workoutHeaderEntity.stampMonth          = stampMonth;
    workoutHeaderEntity.hundredths          = [NSNumber numberWithChar:workoutHeader.hundredths];
    workoutHeaderEntity.second              = [NSNumber numberWithChar:workoutHeader.second];
    workoutHeaderEntity.minute              = [NSNumber numberWithChar:workoutHeader.minute];
    workoutHeaderEntity.hour                = [NSNumber numberWithChar:workoutHeader.hour];
    workoutHeaderEntity.distance            = [NSNumber numberWithDouble:workoutHeader.distance];
    workoutHeaderEntity.calories            = [NSNumber numberWithDouble:workoutHeader.calories];
    workoutHeaderEntity.steps               = [NSNumber numberWithLong:workoutHeader.steps];
    workoutHeaderEntity.recordCountSplits   = [NSNumber numberWithUnsignedChar:workoutHeader.recordCountSplits];
    workoutHeaderEntity.recordCountStops    = [NSNumber numberWithUnsignedChar:workoutHeader.recordCountStops];
    workoutHeaderEntity.recordCountHR       = [NSNumber numberWithUnsignedChar:workoutHeader.recordCountHR];
    workoutHeaderEntity.recordCountTotal    = [NSNumber numberWithUnsignedChar:workoutHeader.recordCountTotal];
    workoutHeaderEntity.averageBPM          = [NSNumber numberWithUnsignedChar:workoutHeader.averageBPM];
    workoutHeaderEntity.minimumBPM          = [NSNumber numberWithUnsignedChar:workoutHeader.minimumBPM];
    workoutHeaderEntity.maximumBPM          = [NSNumber numberWithUnsignedChar:workoutHeader.maximumBPM];
    workoutHeaderEntity.statusFlags         = [NSNumber numberWithUnsignedChar:workoutHeader.statusFlags];
    workoutHeaderEntity.logRateHR           = [NSNumber numberWithUnsignedChar:workoutHeader.logRateHR];
    workoutHeaderEntity.autoSplitType       = [NSNumber numberWithUnsignedChar:workoutHeader.autoSplitType];
    workoutHeaderEntity.zoneTrainType       = [NSNumber numberWithUnsignedChar:workoutHeader.zoneTrainType];
    workoutHeaderEntity.userMaxHR           = [NSNumber numberWithUnsignedChar:workoutHeader.userMaxHR];
    workoutHeaderEntity.zone0UpperHR        = [NSNumber numberWithUnsignedChar:workoutHeader.zone0UpperHR];
    workoutHeaderEntity.zone0LowerHR        = [NSNumber numberWithUnsignedChar:workoutHeader.zone0LowerHR];
    workoutHeaderEntity.zone1LowerHR        = [NSNumber numberWithUnsignedChar:workoutHeader.zone1LowerHR];
    workoutHeaderEntity.zone2LowerHR        = [NSNumber numberWithUnsignedChar:workoutHeader.zone2LowerHR];
    workoutHeaderEntity.zone3LowerHR        = [NSNumber numberWithUnsignedChar:workoutHeader.zone3LowerHR];
    workoutHeaderEntity.zone4LowerHR        = [NSNumber numberWithUnsignedChar:workoutHeader.zone4LowerHR];
    workoutHeaderEntity.zone5LowerHR        = [NSNumber numberWithUnsignedChar:workoutHeader.zone5LowerHR];
    workoutHeaderEntity.zone5UpperHR        = [NSNumber numberWithUnsignedChar:workoutHeader.zone5UpperHR];
    workoutHeaderEntity.autoSplitThreshold  = [NSNumber numberWithUnsignedChar:workoutHeader.autoSplitThreshold];
    
    return workoutHeaderEntity;
}

+ (WorkoutHeaderEntity *)workoutHeaderEntityWithMacAddress:(NSString *)macAddress stampMonth:(NSNumber *)stampMonth stampYear:(NSNumber *)stampYear stampDay:(NSNumber *)stampDay stampMinute:(NSNumber *)stampMinute stampHour:(NSNumber *)stampHour stampSecond:(NSNumber *)stampSecond
{
    NSString *_predicateFormat = nil;
    
    if ([SFAServerAccountManager sharedManager].user.userID) {
        _predicateFormat = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND stampMinute == '%@' AND stampHour == '%@' AND stampSecond == '%@' AND device.macAddress == '%@' AND device.user.userID == '%@'", stampMonth, stampYear, stampDay, stampMinute, stampHour, stampSecond, macAddress, [SFAServerAccountManager sharedManager].user.userID];
    }
    else{
        _predicateFormat = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND stampMinute == '%@' AND stampHour == '%@' AND stampSecond == '%@' AND device.macAddress == '%@'", stampMonth, stampYear, stampDay, stampMinute, stampHour, stampSecond, macAddress];
    }
    
    WorkoutHeaderEntity *workoutHeaderEntity = [[[JDACoreData sharedManager] fetchEntityWithEntityName:WORKOUT_HEADER_ENTITY predicate:[NSPredicate predicateWithFormat:_predicateFormat]] firstObject];
    
    return workoutHeaderEntity;
}

+ (NSArray *)workoutHeaderDictionaryWithDevice:(DeviceEntity *)device
{
    NSMutableArray *workoutHeaders = [[NSMutableArray alloc] init];
    
    for (WorkoutHeaderEntity *workoutHeaderEntity in device.workoutHeader) {
        [workoutHeaders addObject:workoutHeaderEntity.dictionary];
    }
    
    return workoutHeaders;
}

+ (NSArray *)workoutHeaderDictionaryWithDevice:(DeviceEntity *)device forDate:(NSDate *)date
{
    NSMutableArray *workoutHeaders = [[NSMutableArray alloc] init];
    NSArray *workoutsForDate = [WorkoutHeaderEntity getWorkoutInfoWithDate:date];
    for (WorkoutHeaderEntity *workoutHeaderEntity in workoutsForDate){//device.workoutHeader) {
        NSDate *headerDate = [[workoutHeaderEntity startDate] dateWithoutTime];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        NSDateComponents *dateComponentsHeader = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:headerDate];
        NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
        /*
        if ([dateComponents year] == [dateComponentsHeader year] + 1900 &&
            [dateComponents month] == [dateComponentsHeader month] &&
            [dateComponents day] == [dateComponentsHeader day]) {
            [workoutHeaders addObject:workoutHeaderEntity.dictionary];
        }
        */
        NSInteger yearComponentHeader = [dateComponentsHeader year];
        NSInteger yearComponent = [dateComponents year];
        yearComponentHeader = yearComponentHeader < 1900 ? yearComponentHeader + 1900 : yearComponentHeader;
        yearComponent = yearComponent < 1900 ? yearComponent + 1900 : yearComponent;
        
        DDLogInfo(@"workout - %@", workoutHeaderEntity);
        DDLogInfo(@"yearComponent ?= yearComponentHeader %ld %ld %ld ?= %ld %ld %ld", (long)yearComponent, (long)[dateComponents month], (long)[dateComponents day], (long)yearComponentHeader, (long)[dateComponentsHeader month], (long)[dateComponentsHeader day]);
        if (yearComponent == yearComponentHeader &&
            [dateComponents month] == [dateComponentsHeader month] &&
            [dateComponents day] == [dateComponentsHeader day]) {
            [workoutHeaders addObject:workoutHeaderEntity.dictionary];
            DDLogInfo(@"DEBUG --> workoutDB date: %@", [workoutHeaderEntity startDate]);
        }
        
    }
    
    return workoutHeaders;
}

+ (WorkoutHeaderEntity *)workoutHeaderEntityWithDictionary:(NSDictionary *)dictionary forDeviceEntity:(DeviceEntity *)deviceEntity
{
    NSInteger stampSecond           = [[dictionary valueForKey:API_WORKOUT_HEADER_STAMP_SECOND] integerValue];
    NSInteger stampMinute           = [[dictionary valueForKey:API_WORKOUT_HEADER_STAMP_MINUTE] integerValue];
    NSInteger stampHour             = [[dictionary valueForKey:API_WORKOUT_HEADER_STAMP_HOUR] integerValue];
    NSInteger stampDay              = [[dictionary valueForKey:API_WORKOUT_HEADER_STAMP_DAY] integerValue];
    NSInteger stampMonth            = [[dictionary valueForKey:API_WORKOUT_HEADER_STAMP_MONTH] integerValue];
    NSInteger stampYear             = [[dictionary valueForKey:API_WORKOUT_HEADER_STAMP_YEAR] integerValue];
    NSInteger hundredths            = [[dictionary valueForKey:API_WORKOUT_HEADER_HUNDREDTHS] integerValue];
    NSInteger second                = [[dictionary valueForKey:API_WORKOUT_HEADER_SECOND] integerValue];
    NSInteger minute                = [[dictionary valueForKey:API_WORKOUT_HEADER_MINUTE] integerValue];
    NSInteger hour                  = [[dictionary valueForKey:API_WORKOUT_HEADER_HOUR] integerValue];
    double distance                 = [[dictionary valueForKey:API_WORKOUT_HEADER_DISTANCE] doubleValue];
    double calories                 = [[dictionary valueForKey:API_WORKOUT_HEADER_CALORIES] doubleValue];
    NSInteger steps                 = [[dictionary valueForKey:API_WORKOUT_HEADER_STEPS] integerValue];
    NSInteger recordCountSplits     = [[dictionary valueForKey:API_WORKOUT_HEADER_RECORD_COUNT_SPLITS] integerValue];
    NSInteger recordCountStops      = [[dictionary valueForKey:API_WORKOUT_HEADER_RECORD_COUNT_STOPS] integerValue];
    NSInteger recordCountHR         = [[dictionary valueForKey:API_WORKOUT_HEADER_RECORD_COUNT_HR] integerValue];
    NSInteger recordCountTotal      = [[dictionary valueForKey:API_WORKOUT_HEADER_RECORD_COUNT_TOTAL] integerValue];
    NSInteger averageBPM            = [[dictionary valueForKey:API_WORKOUT_HEADER_AVERAGE_BPM] integerValue];
    NSInteger minimumBPM            = [[dictionary valueForKey:API_WORKOUT_HEADER_MINIMUM_BPM] integerValue];
    NSInteger maximumBPM            = [[dictionary valueForKey:API_WORKOUT_HEADER_MAXIMUM_BPM] integerValue];
    NSInteger statusFlags           = [[dictionary valueForKey:API_WORKOUT_HEADER_STATUS_FLAG] integerValue];
    NSInteger logRateHR             = [[dictionary valueForKey:API_WORKOUT_HEADER_LOG_RATE_HR] integerValue];
    NSInteger autoSplitType         = [[dictionary valueForKey:API_WORKOUT_HEADER_AUTO_SPLIT_TYPE] integerValue];
    NSInteger zoneTrainType         = [[dictionary valueForKey:API_WORKOUT_HEADER_ZONE_TRAIN_TYPE] integerValue];
    NSInteger userMaxHR             = [[dictionary valueForKey:API_WORKOUT_HEADER_USER_MAX_HR] integerValue];
    NSInteger zone0UpperHR          = [[dictionary valueForKey:API_WORKOUT_HEADER_ZONE0_UPPER_HR] integerValue];
    NSInteger zone0LowerHR          = [[dictionary valueForKey:API_WORKOUT_HEADER_ZONE0_LOWER_HR] integerValue];
    NSInteger zone1LowerHR          = [[dictionary valueForKey:API_WORKOUT_HEADER_ZONE1_LOWER_HR] integerValue];
    NSInteger zone2LowerHR          = [[dictionary valueForKey:API_WORKOUT_HEADER_ZONE2_LOWER_HR] integerValue];
    NSInteger zone3LowerHR          = [[dictionary valueForKey:API_WORKOUT_HEADER_ZONE3_LOWER_HR] integerValue];
    NSInteger zone4LowerHR          = [[dictionary valueForKey:API_WORKOUT_HEADER_ZONE4_LOWER_HR] integerValue];
    NSInteger zone5LowerHR          = [[dictionary valueForKey:API_WORKOUT_HEADER_ZONE5_LOWER_HR] integerValue];
    NSInteger zone5UpperHR          = [[dictionary valueForKey:API_WORKOUT_HEADER_ZONE5_UPPER_HR] integerValue];
    NSInteger autoSplitThreshold    = [[dictionary valueForKey:API_WORKOUT_HEADER_AUTO_SPLIT_THRESHOLD] integerValue];
    
    NSArray *workoutStops           = [dictionary objectForKey:API_WORKOUT_HEADER_WORKOUT_STOP];
    NSArray *workoutHRData          = [dictionary objectForKey:API_WORKOUT_HEADER_WORKOUT_HR_DATA];
    
    WorkoutHeaderEntity *workoutHeaderEntity = [WorkoutHeaderEntity workoutHeaderEntityWithMacAddress:deviceEntity.macAddress stampMonth:@(stampMonth) stampYear:@(stampYear) stampDay:@(stampDay) stampMinute:@(stampMinute) stampHour:@(stampHour) stampSecond:@(stampSecond)];
    
    if (!workoutHeaderEntity) {
        workoutHeaderEntity = [[JDACoreData sharedManager] insertNewObjectWithEntityName:WORKOUT_HEADER_ENTITY];
    }
    
    workoutHeaderEntity.stampSecond         = @(stampSecond);
    workoutHeaderEntity.stampMinute         = @(stampMinute);
    workoutHeaderEntity.stampHour           = @(stampHour);
    workoutHeaderEntity.stampDay            = @(stampDay);
    workoutHeaderEntity.stampMonth          = @(stampMonth);
    workoutHeaderEntity.stampYear           = @(stampYear);
    workoutHeaderEntity.hundredths          = @(hundredths);
    workoutHeaderEntity.second              = @(second);
    workoutHeaderEntity.minute              = @(minute);
    workoutHeaderEntity.hour                = @(hour);
    workoutHeaderEntity.distance            = @(distance);
    workoutHeaderEntity.calories            = @(calories);
    workoutHeaderEntity.steps               = @(steps);
    workoutHeaderEntity.recordCountSplits   = @(recordCountSplits);
    workoutHeaderEntity.recordCountStops    = @(recordCountStops);
    workoutHeaderEntity.recordCountHR       = @(recordCountHR);
    workoutHeaderEntity.recordCountTotal    = @(recordCountTotal);
    workoutHeaderEntity.averageBPM          = @(averageBPM);
    workoutHeaderEntity.minimumBPM          = @(minimumBPM);
    workoutHeaderEntity.maximumBPM          = @(maximumBPM);
    workoutHeaderEntity.statusFlags         = @(statusFlags);
    workoutHeaderEntity.logRateHR           = @(logRateHR);
    workoutHeaderEntity.autoSplitType       = @(autoSplitType);
    workoutHeaderEntity.zoneTrainType       = @(zoneTrainType);
    workoutHeaderEntity.userMaxHR           = @(userMaxHR);
    workoutHeaderEntity.zone0UpperHR        = @(zone0UpperHR);
    workoutHeaderEntity.zone0LowerHR        = @(zone0LowerHR);
    workoutHeaderEntity.zone1LowerHR        = @(zone1LowerHR);
    workoutHeaderEntity.zone2LowerHR        = @(zone2LowerHR);
    workoutHeaderEntity.zone3LowerHR        = @(zone3LowerHR);
    workoutHeaderEntity.zone4LowerHR        = @(zone4LowerHR);
    workoutHeaderEntity.zone5LowerHR        = @(zone5LowerHR);
    workoutHeaderEntity.zone5UpperHR        = @(zone5UpperHR);
    workoutHeaderEntity.autoSplitThreshold  = @(autoSplitThreshold);
    
    [WorkoutStopDatabaseEntity workoutStopDatabaseEntitiesWithArray:workoutStops forWorkoutHeader:workoutHeaderEntity];
    [WorkoutHeartRateDataEntity workoutHeartRateDataEntitiesWithArray:workoutHRData forWorkoutHeader:workoutHeaderEntity];
    
    [deviceEntity addWorkoutHeaderObject:workoutHeaderEntity];
    
    return workoutHeaderEntity;
}

+ (NSArray *)workoutHeadersWithArray:(NSArray *)array forDeviceEntity:(DeviceEntity *)deviceEntity
{
    NSMutableArray *workoutHeaders = [[NSMutableArray alloc] init];
    
    for (NSDictionary *workoutHeader in array) {
        WorkoutHeaderEntity *workoutHeaderEntity = [WorkoutHeaderEntity workoutHeaderEntityWithDictionary:workoutHeader forDeviceEntity:deviceEntity];
        [workoutHeaders addObject:workoutHeaderEntity];
    }
    
    return workoutHeaders;
}

- (NSDictionary *)dictionary
{
    NSMutableArray *workoutStops = [[NSMutableArray alloc] init];
    NSMutableArray *workoutHeartRateData = [[NSMutableArray alloc] init];
    
    for (WorkoutStopDatabaseEntity *workoutStopDatabaseEntity in self.workoutStopDatabase) {
        [workoutStops addObject:workoutStopDatabaseEntity.dictionary];
    }
    
    for (WorkoutHeartRateDataEntity *workoutHeartDataEntity in self.workoutHeartRateData) {
        [workoutHeartRateData addObject:workoutHeartDataEntity.dictionary];
    }
    
    NSDictionary *dictionary = @{
                                 API_WORKOUT_HEADER_AUTO_SPLIT_THRESHOLD : self.autoSplitThreshold,
                                 API_WORKOUT_HEADER_AUTO_SPLIT_TYPE      : self.autoSplitType,
                                 API_WORKOUT_HEADER_AVERAGE_BPM          : self.averageBPM,
                                 API_WORKOUT_HEADER_HOUR                 : self.hour,
                                 API_WORKOUT_HEADER_HUNDREDTHS           : self.hundredths,
                                 API_WORKOUT_HEADER_LOG_RATE_HR          : self.logRateHR,
                                 API_WORKOUT_HEADER_MAXIMUM_BPM          : self.maximumBPM,
                                 API_WORKOUT_HEADER_MINIMUM_BPM          : self.minimumBPM,
                                 API_WORKOUT_HEADER_MINUTE               : self.minute,
                                 API_WORKOUT_HEADER_RECORD_COUNT_HR      : self.recordCountHR,
                                 API_WORKOUT_HEADER_RECORD_COUNT_SPLITS  : self.recordCountSplits,
                                 API_WORKOUT_HEADER_RECORD_COUNT_STOPS   : self.recordCountStops,
                                 API_WORKOUT_HEADER_RECORD_COUNT_TOTAL   : self.recordCountTotal,
                                 API_WORKOUT_HEADER_SECOND               : self.second,
                                 API_WORKOUT_HEADER_STAMP_DAY            : self.stampDay,
                                 API_WORKOUT_HEADER_STAMP_HOUR           : self.stampHour,
                                 API_WORKOUT_HEADER_STAMP_MINUTE         : self.stampMinute,
                                 API_WORKOUT_HEADER_STAMP_MONTH          : self.stampMonth,
                                 API_WORKOUT_HEADER_STAMP_SECOND         : self.stampSecond,
                                 API_WORKOUT_HEADER_STAMP_YEAR           : self.stampYear,
                                 API_WORKOUT_HEADER_START_DATE_TIME      : [NSString stringWithFormat:@"%i-%02i-%i %i:%i:%i", self.stampYear.integerValue + 1900, self.stampMonth.integerValue, self.stampDay.integerValue, self.stampHour.integerValue, self.stampMinute.integerValue, self.stampSecond.integerValue],
                                 API_WORKOUT_HEADER_STATUS_FLAG          : self.statusFlags,
                                 API_WORKOUT_HEADER_USER_MAX_HR          : self.userMaxHR,
                                 API_WORKOUT_HEADER_ZONE0_LOWER_HR       : self.zone0LowerHR,
                                 API_WORKOUT_HEADER_ZONE0_UPPER_HR       : self.zone0UpperHR,
                                 API_WORKOUT_HEADER_ZONE1_LOWER_HR       : self.zone1LowerHR,
                                 API_WORKOUT_HEADER_ZONE2_LOWER_HR       : self.zone2LowerHR,
                                 API_WORKOUT_HEADER_ZONE3_LOWER_HR       : self.zone3LowerHR,
                                 API_WORKOUT_HEADER_ZONE4_LOWER_HR       : self.zone4LowerHR,
                                 API_WORKOUT_HEADER_ZONE5_LOWER_HR       : self.zone5LowerHR,
                                 API_WORKOUT_HEADER_ZONE5_UPPER_HR       : self.zone5UpperHR,
                                 API_WORKOUT_HEADER_ZONE_TRAIN_TYPE      : self.zoneTrainType,
                                 API_WORKOUT_HEADER_STEPS                : self.steps,
                                 API_WORKOUT_HEADER_CALORIES             : self.calories,
                                 API_WORKOUT_HEADER_DISTANCE             : self.distance,
                                 API_WORKOUT_HEADER_WORKOUT_STOP         : workoutStops.copy,
                                 API_WORKOUT_HEADER_WORKOUT_HR_DATA      : workoutHeartRateData.copy
                                 };
    
    return dictionary;
}

#pragma mark - Public class select methods
+ (NSArray *)getWorkoutInfoWithDate:(NSDate *)date
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *_month                        = [date getDateStringWithFormat:@"MM"];
    NSString *_day                          = [date getDateStringWithFormat:@"dd"];
    NSString *_year                         = [date getDateStringWithFormat:@"yyyy"];
    int year                                = [_year integerValue];
    if (year > 1900) {
        year                                = [_year integerValue]-1900;
    }
    _year                                   = [NSString stringWithFormat:@"%i", year];
    NSString *_predicateFormat              = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND device.macAddress == '%@' AND device.user.userID == '%@'", _month, _year, _day, [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    
    NSArray *_workoutInfoEntity      = [[JDACoreData sharedManager] fetchEntityWithEntityName:WORKOUT_HEADER_ENTITY
                                                                                    predicate:[NSPredicate predicateWithFormat:_predicateFormat]
                                                                                  sortWithKey:@"stampHour, stampMinute, stampSecond"
                                                                                    ascending:YES
                                                                                     sortType:SORT_TYPE_NUMBER];
    
    NSMutableArray *_workoutArray    = [_workoutInfoEntity mutableCopy];
    //[_workoutArray invertData];
    return _workoutArray;
}


+ (NSArray *)getWorkoutHeartRateDataWithDate:(NSDate *)date
{
    //return @[];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *_month                        = [date getDateStringWithFormat:@"MM"];
    NSString *_day                          = [date getDateStringWithFormat:@"dd"];
    NSString *_year                         = [date getDateStringWithFormat:@"yyyy"];
    int year                                = [_year integerValue]-1900;
    _year                                   = [NSString stringWithFormat:@"%i", year];
    NSString *_predicateFormat              = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND device.macAddress == '%@' AND device.user.userID == '%@'", _month, _year, _day, [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    
    NSArray *_workoutInfoEntity      = [[JDACoreData sharedManager] fetchEntityWithEntityName:WORKOUT_HEADER_ENTITY
                                                                                    predicate:[NSPredicate predicateWithFormat:_predicateFormat]
                                                                                  sortWithKey:@"stampHour, stampMinute, stampSecond"
                                                                                    ascending:YES
                                                                                     sortType:SORT_TYPE_NUMBER];
    NSMutableArray *_workoutArray    = [_workoutInfoEntity mutableCopy];
    //[_workoutArray invertData];
    NSMutableArray *workoutHeartRateData = [[NSMutableArray alloc] init];
    /*
    [workoutHeartRateData addObject:@{@"hrData" : @(80),
                                      @"index" : @(3600)}];
    [workoutHeartRateData addObject:@{@"hrData" : @(60),
                                      @"index" : @(3700)}];
    [workoutHeartRateData addObject:@{@"hrData" : @(100),
                                      @"index" : @(3800)}];
     */
    //for (int loop = 0; loop < 24*60*60; loop++)
    //{
        //WorkoutHeartRateDataEntity *hrTemp = [WorkoutHeartRateDataEntity entityWithHrData:0 index:0];
    //    [workoutHeartRateData addObject:@(0)];
    //}
    for (WorkoutHeaderEntity *workoutHeader in _workoutArray) {
        NSMutableArray *stopIndexes = [[NSMutableArray alloc] init];
        int index = (workoutHeader.stampHour.integerValue*60*60)+
        (workoutHeader.stampMinute.integerValue*60)+
        workoutHeader.stampSecond.integerValue;
        for (WorkoutStopDatabaseEntity *stopDatabase in workoutHeader.workoutStopDatabase) {
            int startStopWorkout =  index + stopDatabase.workoutHour.integerValue*3600 + stopDatabase.workoutMinute.integerValue*60 +stopDatabase.workoutSecond.integerValue;
            int endStopWorkout = startStopWorkout + stopDatabase.stopHour.integerValue*3600 + stopDatabase.stopMinute.integerValue*60 +stopDatabase.stopSecond.integerValue;
            [stopIndexes addObject:@{@"start" : @(startStopWorkout),
                                    @"end" : @(endStopWorkout)}];
        }
        NSArray *heartRates = [workoutHeader.workoutHeartRateData array];
        int logRate = workoutHeader.logRateHR.integerValue;
        //[workoutHeartRateData addObject:[WorkoutHeartRateDataEntity entityWithHrData:0 index:0]];
        for (WorkoutHeartRateDataEntity *heartRateDataEntity in heartRates) {
            //heartRateDataEntity.index = @(index+logRate);
            //[workoutHeartRateData addObject:heartRateDataEntity];
            for (NSDictionary *stopIndex in stopIndexes) {
                int start = [stopIndex[@"start"] integerValue];
                int end = [stopIndex[@"end"] integerValue];
                if (index >= start && index <= end) {
                    index = end-(end%logRate)+logRate;
                    break;
                }
            }
            [workoutHeartRateData addObject:@{@"hrData" : heartRateDataEntity.hrData,
                                              @"index" : @(index)}];
            //replaceObjectAtIndex:index+logRate withObject:@{@"hrData" : heartRateDataEntity.hrData, @"index" : @(index+logRate)}];
            index += logRate;
        }
      //  [workoutHeartRateData addObject:[WorkoutHeartRateDataEntity entityWithHrData:0 index:(24*60*60)-1]];
    }
    /*
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"index"  ascending:YES];
    workoutHeartRateData = [[workoutHeartRateData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] copy];*/
    return workoutHeartRateData;
}

+ (int)getAverageWorkoutHeartRateWithDate:(NSDate *)date
{
    //return @[];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *_month                        = [date getDateStringWithFormat:@"MM"];
    NSString *_day                          = [date getDateStringWithFormat:@"dd"];
    NSString *_year                         = [date getDateStringWithFormat:@"yyyy"];
    int year                                = [_year integerValue]-1900;
    _year                                   = [NSString stringWithFormat:@"%i", year];
    NSString *_predicateFormat              = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND device.macAddress == '%@' AND device.user.userID == '%@'", _month, _year, _day, [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    
    NSArray *_workoutInfoEntity      = [[JDACoreData sharedManager] fetchEntityWithEntityName:WORKOUT_HEADER_ENTITY
                                                                                    predicate:[NSPredicate predicateWithFormat:_predicateFormat]
                                                                                  sortWithKey:@"stampHour, stampMinute, stampSecond"
                                                                                    ascending:YES
                                                                                     sortType:SORT_TYPE_NUMBER];
    NSMutableArray *_workoutArray    = [_workoutInfoEntity mutableCopy];
    int hrCount = 0;
    int averageHR = 0;
    int totalHr = 0;
    for (WorkoutHeaderEntity *workoutHeader in _workoutArray) {
        hrCount++;
        totalHr += abs([workoutHeader.averageBPM intValue]);
    }
    averageHR = totalHr/hrCount;
    return averageHR;
}


+ (int)getMinWorkoutHeartRateWithDate:(NSDate *)date
{
    //return @[];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *_month                        = [date getDateStringWithFormat:@"MM"];
    NSString *_day                          = [date getDateStringWithFormat:@"dd"];
    NSString *_year                         = [date getDateStringWithFormat:@"yyyy"];
    int year                                = [_year integerValue]-1900;
    _year                                   = [NSString stringWithFormat:@"%i", year];
    NSString *_predicateFormat              = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND device.macAddress == '%@' AND device.user.userID == '%@'", _month, _year, _day, [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    
    NSArray *_workoutInfoEntity      = [[JDACoreData sharedManager] fetchEntityWithEntityName:WORKOUT_HEADER_ENTITY
                                                                                    predicate:[NSPredicate predicateWithFormat:_predicateFormat]
                                                                                  sortWithKey:@"stampHour, stampMinute, stampSecond"
                                                                                    ascending:YES
                                                                                     sortType:SORT_TYPE_NUMBER];
    NSMutableArray *_workoutArray    = [_workoutInfoEntity mutableCopy];
    int hrCount = 0;
    int minHR = 999;
    for (WorkoutHeaderEntity *workoutHeader in _workoutArray) {
        minHR = abs([workoutHeader.minimumBPM intValue]) < minHR ? abs([workoutHeader.minimumBPM intValue]) : minHR;
    }
    return minHR;
}

+ (int)getMaxWorkoutHeartRateWithDate:(NSDate *)date
{
    //return @[];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *_month                        = [date getDateStringWithFormat:@"MM"];
    NSString *_day                          = [date getDateStringWithFormat:@"dd"];
    NSString *_year                         = [date getDateStringWithFormat:@"yyyy"];
    int year                                = [_year integerValue]-1900;
    _year                                   = [NSString stringWithFormat:@"%i", year];
    NSString *_predicateFormat              = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND device.macAddress == '%@' AND device.user.userID == '%@'", _month, _year, _day, [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    
    NSArray *_workoutInfoEntity      = [[JDACoreData sharedManager] fetchEntityWithEntityName:WORKOUT_HEADER_ENTITY
                                                                                    predicate:[NSPredicate predicateWithFormat:_predicateFormat]
                                                                                  sortWithKey:@"stampHour, stampMinute, stampSecond"
                                                                                    ascending:YES
                                                                                     sortType:SORT_TYPE_NUMBER];
    NSMutableArray *_workoutArray    = [_workoutInfoEntity mutableCopy];
    int maxHr = 0;
    for (WorkoutHeaderEntity *workoutHeader in _workoutArray) {
        maxHr = abs([workoutHeader.maximumBPM intValue]) > maxHr ? abs([workoutHeader.maximumBPM intValue]) : maxHr;
    }
    return maxHr;
}



+ (NSArray *)getWorkoutHeartRateDataWithDate:(NSDate *)date withWorkoutIndex:(int)workoutIndex
{
    //return @[];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *_month                        = [date getDateStringWithFormat:@"MM"];
    NSString *_day                          = [date getDateStringWithFormat:@"dd"];
    NSString *_year                         = [date getDateStringWithFormat:@"yyyy"];
    int year                                = [_year intValue]-1900;
    _year                                   = [NSString stringWithFormat:@"%i", year];
    NSString *_predicateFormat              = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND device.macAddress == '%@' AND device.user.userID == '%@'", _month, _year, _day, [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    
    NSArray *_workoutInfoEntity      = [[JDACoreData sharedManager] fetchEntityWithEntityName:WORKOUT_HEADER_ENTITY
                                                                                    predicate:[NSPredicate predicateWithFormat:_predicateFormat]
                                                                                  sortWithKey:@"stampHour, stampMinute, stampSecond"
                                                                                    ascending:YES
                                                                                     sortType:SORT_TYPE_NUMBER];
    NSMutableArray *_workoutArray    = [_workoutInfoEntity mutableCopy];
    
    NSMutableArray *workoutHeartRateData = [[NSMutableArray alloc] init];
    WorkoutHeaderEntity *workoutHeader = _workoutArray[workoutIndex];
        NSMutableArray *stopIndexes = [[NSMutableArray alloc] init];
        int index = (workoutHeader.stampHour.intValue*60*60)+
        (workoutHeader.stampMinute.intValue*60)+
        workoutHeader.stampSecond.intValue;
        for (WorkoutStopDatabaseEntity *stopDatabase in workoutHeader.workoutStopDatabase) {
            int startStopWorkout =  index + stopDatabase.workoutHour.intValue*3600 + stopDatabase.workoutMinute.intValue*60 +stopDatabase.workoutSecond.intValue;
            int endStopWorkout = startStopWorkout + stopDatabase.stopHour.intValue*3600 + stopDatabase.stopMinute.intValue*60 +stopDatabase.stopSecond.intValue;
            [stopIndexes addObject:@{@"start" : @(startStopWorkout),
                                     @"end" : @(endStopWorkout)}];
        }
        NSArray *heartRates = [workoutHeader.workoutHeartRateData array];
        int logRate = workoutHeader.logRateHR.intValue;
        //[workoutHeartRateData addObject:[WorkoutHeartRateDataEntity entityWithHrData:0 index:0]];
        for (WorkoutHeartRateDataEntity *heartRateDataEntity in heartRates) {
            //heartRateDataEntity.index = @(index+logRate);
            //[workoutHeartRateData addObject:heartRateDataEntity];
            for (NSDictionary *stopIndex in stopIndexes) {
                int start = [stopIndex[@"start"] intValue];
                int end = [stopIndex[@"end"] intValue];
                if (index >= start && index <= end) {
                    index = end-(end%logRate)+logRate;
                    break;
                }
            }
            [workoutHeartRateData addObject:@{@"hrData" : heartRateDataEntity.hrData,
                                              @"index" : @(index)}];
            //replaceObjectAtIndex:index+logRate withObject:@{@"hrData" : heartRateDataEntity.hrData, @"index" : @(index+logRate)}];
            index += logRate;
        }
        //  [workoutHeartRateData addObject:[WorkoutHeartRateDataEntity entityWithHrData:0 index:(24*60*60)-1]];
    /*
     NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"index"  ascending:YES];
     workoutHeartRateData = [[workoutHeartRateData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] copy];*/
    return workoutHeartRateData;
}



+ (NSArray *)getWorkoutHeartRateWithMinMaxDataWithDate:(NSDate *)date
{
    //return @[];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *_month                        = [date getDateStringWithFormat:@"MM"];
    NSString *_day                          = [date getDateStringWithFormat:@"dd"];
    NSString *_year                         = [date getDateStringWithFormat:@"yyyy"];
    int year                                = [_year integerValue]-1900;
    _year                                   = [NSString stringWithFormat:@"%i", year];
    NSString *_predicateFormat              = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND device.macAddress == '%@' AND device.user.userID == '%@'", _month, _year, _day, [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    
    NSArray *_workoutInfoEntity      = [[JDACoreData sharedManager] fetchEntityWithEntityName:WORKOUT_HEADER_ENTITY
                                                                                    predicate:[NSPredicate predicateWithFormat:_predicateFormat]
                                                                                  sortWithKey:@"stampHour, stampMinute, stampSecond"
                                                                                    ascending:YES
                                                                                     sortType:SORT_TYPE_NUMBER];
    NSMutableArray *_workoutArray    = [_workoutInfoEntity mutableCopy];
    //[_workoutArray invertData];
    NSMutableArray *workoutHeartRateData = [[NSMutableArray alloc] init];
    /*
     [workoutHeartRateData addObject:@{@"hrData" : @(80),
     @"index" : @(3600)}];
     [workoutHeartRateData addObject:@{@"hrData" : @(60),
     @"index" : @(3700)}];
     [workoutHeartRateData addObject:@{@"hrData" : @(100),
     @"index" : @(3800)}];
     */
    //for (int loop = 0; loop < 24*60*60; loop++)
    //{
    //WorkoutHeartRateDataEntity *hrTemp = [WorkoutHeartRateDataEntity entityWithHrData:0 index:0];
    //    [workoutHeartRateData addObject:@(0)];
    //}
    for (WorkoutHeaderEntity *workoutHeader in _workoutArray) {
        NSMutableArray *stopIndexes = [[NSMutableArray alloc] init];
        int index = (workoutHeader.stampHour.integerValue*60*60)+
        (workoutHeader.stampMinute.integerValue*60)+
        workoutHeader.stampSecond.integerValue;
        for (WorkoutStopDatabaseEntity *stopDatabase in workoutHeader.workoutStopDatabase) {
            int startStopWorkout =  index + stopDatabase.workoutHour.integerValue*3600 + stopDatabase.workoutMinute.integerValue*60 +stopDatabase.workoutSecond.integerValue;
            int endStopWorkout = startStopWorkout + stopDatabase.stopHour.integerValue*3600 + stopDatabase.stopMinute.integerValue*60 +stopDatabase.stopSecond.integerValue;
            [stopIndexes addObject:@{@"start" : @(startStopWorkout),
                                     @"end" : @(endStopWorkout)}];
        }
        NSArray *heartRates = [workoutHeader.workoutHeartRateData array];
        int logRate = workoutHeader.logRateHR.integerValue;
        //[workoutHeartRateData addObject:[WorkoutHeartRateDataEntity entityWithHrData:0 index:0]];
        for (WorkoutHeartRateDataEntity *heartRateDataEntity in heartRates) {
            //heartRateDataEntity.index = @(index+logRate);
            //[workoutHeartRateData addObject:heartRateDataEntity];
            for (NSDictionary *stopIndex in stopIndexes) {
                int start = [stopIndex[@"start"] integerValue];
                int end = [stopIndex[@"end"] integerValue];
                if (index >= start && index <= end) {
                    index = end-(end%logRate)+logRate;
                    break;
                }
            }
            [workoutHeartRateData addObject:@{@"hrData" : heartRateDataEntity.hrData,
                                              @"index" : @(index),
                                              @"min" : workoutHeader.minimumBPM,
                                              @"max" : workoutHeader.maximumBPM}];
            //replaceObjectAtIndex:index+logRate withObject:@{@"hrData" : heartRateDataEntity.hrData, @"index" : @(index+logRate)}];
            index += logRate;
        }
        //  [workoutHeartRateData addObject:[WorkoutHeartRateDataEntity entityWithHrData:0 index:(24*60*60)-1]];
    }
    /*
     NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"index"  ascending:YES];
     workoutHeartRateData = [[workoutHeartRateData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] copy];*/
    return workoutHeartRateData;
}


#pragma mark - Private Methods

+ (WorkoutHeaderEntity *)workoutWithDictionary:(NSDictionary *)dictionary forDeviceEntity:(DeviceEntity *)device
{
    NSNumber *workoutID             = @([[dictionary objectForKey:API_WORKOUT_ID] floatValue]);
    NSNumber *duration              = @([[dictionary objectForKey:API_WORKOUT_DURATION] floatValue]);
    if (device.modelNumber.integerValue == WatchModel_Zone_C410 ||
        device.modelNumber.integerValue == WatchModel_R420) {
        if ([device.macAddress rangeOfString:@":"].location != NSNotFound) {
            duration = duration;
        }
        else{
            //convert seconds to centiseconds
            duration = @(duration.integerValue * 100);
        }
    }
    NSString *startDateString       = [dictionary objectForKey:API_WORKOUT_START_DATE];
    NSNumber *steps                 = @([[dictionary objectForKey:API_WORKOUT_STEPS] floatValue]);
    NSNumber *calories              = @([[dictionary objectForKey:API_WORKOUT_CALORIES] floatValue]);
    NSNumber *distance              = @([[dictionary objectForKey:API_WORKOUT_DISTANCE] floatValue]);
    NSNumber *distanceUnit          = @([[dictionary objectForKey:API_WORKOUT_DISTANCE_UNIT] floatValue]);
    NSArray *workoutStop            = [dictionary objectForKey:API_WORKOUT_WORKOUT_STOP];
    NSDate *startDate               = [NSDate dateFromString:startDateString withFormat:API_DATE_TIME_FORMAT];
    NSDateComponents *components    = startDate.dateComponents;
    NSInteger hour                  = ((duration.integerValue/100) / 3600);
    NSInteger minute                = ((duration.integerValue/100) / 60) - (hour * 60);
    NSInteger second                = (duration.integerValue/100)%60;
    NSInteger hundredth             = duration.integerValue%100;
    WorkoutHeaderEntity *workout      = [self insertWorkoutInfoWithSteps:steps
                                                                distance:distance
                                                                calories:calories
                                                                  minute:@(minute)
                                                                  second:@(second)
                                                                    hour:@(hour)
                                                        distanceUnitFlag:distanceUnit
                                                               hundredth:@(hundredth)
                                                             stampSecond:@(components.second)
                                                             stampMinute:@(components.minute)
                                                               stampHour:@(components.hour)
                                                                stampDay:@(components.day)
                                                              stampMonth:@(components.month)
                                                               stampYear:@(components.year)
                                                               workoutID:workoutID];
    
    [device addWorkoutHeaderObject:workout];
    [WorkoutStopDatabaseEntity workoutStopDatabaseEntitiesWithArray:workoutStop forWorkoutInfoEntity:workout];
    
    return workout;
}

+ (void)setAllIsSyncedToServer:(BOOL)isSyncedToServer forDeviceEntity:(DeviceEntity *)deviceEntity
{
    for (WorkoutHeaderEntity *workoutEntity in deviceEntity.workout.allObjects) {
        
        NSDate *workoutEntityDate = [[workoutEntity startDate] dateWithoutTime];
        NSDate *currentDate = [[NSDate date] dateWithoutTime];
        
        if ([workoutEntityDate isEqualToDate:currentDate]) {
            //workoutEntity.isSyncedToServer = [NSNumber numberWithBool:NO];
        }
        else {
            //workoutEntity.isSyncedToServer = [NSNumber numberWithBool:isSyncedToServer];
        }
    }
    [[JDACoreData sharedManager] save];
}


#pragma mark - Public Methods

+ (NSArray *)workoutsDictionaryForDeviceEntity:(DeviceEntity *)device
{
    NSMutableArray *workouts = [NSMutableArray new];
    
    for (WorkoutHeaderEntity *workout in device.workout) {
        [workouts addObject:workout.dictionary];
    }
    
    return workouts.copy;
}

+ (NSArray *)workoutsDictionaryWithStartingDateForDeviceEntity:(DeviceEntity *)device
{
    NSMutableArray *workouts = [NSMutableArray new];
    
    for (WorkoutHeaderEntity *workout in device.workout) {
        /*
         unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
         NSCalendar* calendar = [NSCalendar currentCalendar];
         NSDateComponents* components = [calendar components:flags fromDate:[workout startDate]];
         NSDate* date1 = [calendar dateFromComponents:components];
         NSDateComponents* components2 = [calendar components:flags fromDate:device.updatedSynced];
         NSDate* date2 = [calendar dateFromComponents:components2];
         if([date1 isEqualToDate:date2] || [date1 compare:date2]==NSOrderedDescending){
         [workouts addObject:workout.dictionary];
         }
         */
        
        //NSDate *headerEntityDate = [[workout startDate] dateWithoutTime];
        //NSDate *cloudSyncedDate = [device.updatedSynced dateWithoutTime];
        //NSDate *currentDate = [[NSDate date] dateWithoutTime];
        
        //if ([self isLateOrEqualForDates:headerEntityDate andDate:cloudSyncedDate]) {
        
        /*	if ([self isLateOrEqualForDates:headerEntityDate andDate:cloudSyncedDate] ||
         [workout.isSyncedToServer isEqualToNumber:[NSNumber numberWithBool:NO]] ||
         [headerEntityDate isEqualToDate:currentDate]) {
         */
        [workouts addObject:workout.dictionary];
        DDLogInfo(@"DEBUG --> workoutDB date: %@", [workout startDate]);
        //	}
        
        //}
    }
    
    return workouts.copy;
}

+ (BOOL)isLateOrEqualForDates:(NSDate *)date1 andDate:(NSDate *)date2
{
    
    if ([date1 isEqualToDate:date2] || [date1 compare:date2] == NSOrderedDescending) {
        return YES;
    }
    return NO;
}

+ (NSArray *)workoutsWithArray:(NSArray *)array forDeviceEntity:(DeviceEntity *)device
{
    NSMutableArray *workouts = [NSMutableArray new];
    
    for (NSDictionary *dictionary in array) {
        WorkoutHeaderEntity *workout = [self workoutWithDictionary:dictionary forDeviceEntity:device];
        [workouts addObject:workout];
    }
    
    return workouts.copy;
}

- (NSDate *)startDate
{
    NSDateComponents *components    = [NSDateComponents new];
    components.hour                 = self.stampHour.integerValue;
    components.minute               = self.stampMinute.integerValue;
    components.second               = self.stampSecond.integerValue;
    if (self.stampSecond.integerValue < 0) {
        components.second = 0;
    }
    components.month                = self.stampMonth.integerValue;
    components.day                  = self.stampDay.integerValue;
    components.year                 = self.stampYear.integerValue;
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDate *date                    = [calendar dateFromComponents:components];
    
    return date;
}

- (NSInteger)duration
{
    //in hundredths or centiseconds
    NSInteger duration  = self.second.integerValue;
    duration            += self.minute.integerValue * 60;
    duration            += self.hour.integerValue * 60 * 60;
    duration            = duration * 100;
    duration            = duration + self.hundredths.integerValue;
    
    return duration;
}

- (NSInteger)totalWorkoutDurationMinutes
{
    NSArray *workoutStops = [[NSArray alloc] init];//[self.workoutStopDatabase allObjects];
    //NSInteger workoutStopDuration = 0;
    NSInteger workoutDuration = self.hour.integerValue * 60 + self.minute.integerValue;
    
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        NSInteger stopMinutes = workoutStop.stopHour.integerValue *60 + workoutStop.stopMinute.integerValue;
        workoutDuration += stopMinutes;
    }
    
    return workoutDuration;
}

- (NSInteger)totalWorkoutDurationSeconds
{
    NSArray *workoutStops = [[NSArray alloc] init];//[self.workoutStopDatabase allObjects];
    //NSInteger workoutStopDuration = 0;
    NSInteger workoutDuration = self.hour.integerValue * 3600 + self.minute.integerValue * 60 + self.second.integerValue;
    
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        NSInteger stopSeconds = workoutStop.stopHour.integerValue * 3600 + workoutStop.stopMinute.integerValue * 60 + workoutStop.stopSecond.integerValue;
        workoutDuration += stopSeconds;
    }
    
    return workoutDuration;
}

- (NSArray *)indexedWorkoutStopArray
{
    NSArray *tempWorkoutStop = [[NSArray alloc] init];//[self.workoutStopDatabase allObjects];
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    NSArray *workoutStops = [tempWorkoutStop sortedArrayUsingDescriptors:@[sortByIndex]];
    
    return workoutStops;
}

- (NSInteger)workoutDurationMinutesForThatDay
{
    NSArray *workoutStops = [self indexedWorkoutStopArray];
    
    //get the starting index from the start time of the workout
    NSInteger startMinutes =(self.stampHour.integerValue * 60 + self.stampMinute.integerValue);
    
    NSInteger workoutDuration = 0;
    NSInteger totalDuration = startMinutes;
    
    BOOL spillOver = NO;
    
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        NSInteger workoutMinutes = workoutStop.workoutHour.integerValue *60 + workoutStop.workoutMinute.integerValue;
        NSInteger stopMinutes = workoutStop.stopHour.integerValue *60 + workoutStop.stopMinute.integerValue;
        
        if ((totalDuration + workoutMinutes + stopMinutes) >= 1439){
            workoutDuration += workoutMinutes;
            workoutDuration = totalDuration+workoutMinutes > 1439 ? 1439-totalDuration: workoutDuration;
            spillOver = YES;
            break;
        }else{
            totalDuration += workoutMinutes + stopMinutes;
            workoutDuration += workoutMinutes;
        }
    }
    if ([workoutStops count] == 0) {
        workoutDuration = self.hour.integerValue*60 + self.minute.integerValue;
        totalDuration += workoutDuration;
        if (totalDuration > 1439) {
            spillOver = YES;
            workoutDuration = 1439-startMinutes;
        }
    }
    
    if (!spillOver){
        workoutDuration = (self.hour.integerValue *60) + self.minute.integerValue;
    }
    
    return workoutDuration;
}

- (NSInteger)workoutDurationSecondsForThatDay
{
    NSArray *workoutStops = [self indexedWorkoutStopArray];
    
    //get the starting index from the start time of the workout
    NSInteger startSeconds =(self.stampHour.integerValue * 3600 + self.stampMinute.integerValue * 60 + self.stampSecond.integerValue);
    
    NSInteger workoutDuration = 0;
    NSInteger totalDuration = startSeconds;
    
    BOOL spillOver = NO;
    
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        NSInteger workoutSeconds = workoutStop.workoutHour.integerValue * 3600 + workoutStop.workoutMinute.integerValue * 60 + workoutStop.workoutSecond.integerValue;
        NSInteger stopSeconds = workoutStop.stopHour.integerValue * 3600 + workoutStop.stopMinute.integerValue * 60 + workoutStop.stopSecond.integerValue;
        
        if ((totalDuration + workoutSeconds + stopSeconds) >= 86399){
            workoutDuration += workoutSeconds;
            workoutDuration = totalDuration+workoutSeconds > 86399 ? 86399-totalDuration: workoutDuration;
            spillOver = YES;
            break;
        }else{
            totalDuration += workoutSeconds + stopSeconds;
            workoutDuration += workoutSeconds;
        }
    }
    if ([workoutStops count] == 0) {
        workoutDuration = self.hour.integerValue*3600 + self.minute.integerValue*60 + self.second.integerValue;
        totalDuration += workoutDuration;
        if (totalDuration > 86399) {
            spillOver = YES;
            workoutDuration = 86399-startSeconds;
        }
    }
    
    if (!spillOver){
        workoutDuration = (self.hour.integerValue * 3600) + self.minute.integerValue * 60 + self.second.integerValue;
    }
    
    return workoutDuration;
}

- (NSInteger)workoutDurationHundredthsForThatDay
{
    NSArray *workoutStops = [self indexedWorkoutStopArray];
    
    //get the starting index from the start time of the workout
    NSInteger startHundredths =(self.stampHour.integerValue * 3600 + self.stampMinute.integerValue * 60 + self.stampSecond.integerValue)*100;
    
    NSInteger workoutDuration = 0;
    NSInteger totalDuration = startHundredths;
    
    BOOL spillOver = NO;
    
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        NSInteger workoutHundredths = (workoutStop.workoutHour.integerValue * 3600 + workoutStop.workoutMinute.integerValue * 60 + workoutStop.workoutSecond.integerValue)*100 + workoutStop.workoutHundredth.integerValue;
        NSInteger stopHundredths = (workoutStop.stopHour.integerValue * 3600 + workoutStop.stopMinute.integerValue * 60 + workoutStop.stopSecond.integerValue)*100 + workoutStop.stopHundredth.integerValue;
        
        if ((totalDuration + workoutHundredths + stopHundredths) >= 86399*100){
            workoutDuration += workoutHundredths;
            workoutDuration = totalDuration+workoutHundredths > 86399*100 ? 86399*100-totalDuration: workoutDuration;
            spillOver = YES;
            break;
        }else{
            totalDuration += workoutHundredths + stopHundredths;
            workoutDuration += workoutHundredths;
        }
    }
    
    if (!spillOver){
        workoutDuration = (self.hour.integerValue * 3600) + self.minute.integerValue * 60 + self.second.integerValue;
        workoutDuration = workoutDuration * 100 + self.hundredths.integerValue;
    }
    
    return workoutDuration;
}


- (NSInteger)workoutStopDurationMinutesForThatDay
{
    NSArray *workoutStops = [self indexedWorkoutStopArray];
    
    //get the starting index from the start time of the workout
    NSInteger startMinutes =(self.stampHour.integerValue * 60 + self.stampMinute.integerValue);
    
    NSInteger totalDuration = startMinutes;
    NSInteger workoutStopDuration = 0;
    
    //BOOL spillOver = NO;
    
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        NSInteger workoutMinutes = workoutStop.workoutHour.integerValue *60 + workoutStop.workoutMinute.integerValue;
        NSInteger stopMinutes = workoutStop.stopHour.integerValue *60 + workoutStop.stopMinute.integerValue;
        
        if ([workoutStop workoutEndTimeFromStartTime:totalDuration] > 1439){
            //workout ends the day
            break;
        }else if ([workoutStop workoutAndWorkoutStopEndTimeFromStartTime:totalDuration] > 1439){
            workoutStopDuration += stopMinutes;
            workoutStopDuration = totalDuration+workoutMinutes+stopMinutes > 1439 ? 1439-(totalDuration+workoutMinutes): workoutStopDuration;
            break;
        }else{
            totalDuration += workoutMinutes + stopMinutes;
            workoutStopDuration += stopMinutes;
        }
    }
    
    return workoutStopDuration;
}

- (NSInteger)workoutStopDurationSecondsForThatDay
{
    NSArray *workoutStops = [self indexedWorkoutStopArray];
    
    //get the starting index from the start time of the workout
    NSInteger startSeconds =(self.stampHour.integerValue * 3600 + self.stampMinute.integerValue * 60 + self.stampSecond.integerValue);
    
    NSInteger totalDuration = startSeconds;
    NSInteger workoutStopDuration = 0;
    
    //BOOL spillOver = NO;
    
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        NSInteger workoutSeconds = workoutStop.workoutHour.integerValue * 3600 + workoutStop.workoutMinute.integerValue * 60 + workoutStop.workoutSecond.integerValue;
        NSInteger stopSeconds = workoutStop.stopHour.integerValue * 3600 + workoutStop.stopMinute.integerValue * 60 + workoutStop.stopSecond.integerValue;
        
        if ([workoutStop workoutEndTimeFromStartTimeInSeconds:totalDuration] > 86399){
            //workout ends the day
            break;
        }else if ([workoutStop workoutAndWorkoutStopEndTimeFromStartTimeInSeconds:totalDuration] > 86399){
            workoutStopDuration += stopSeconds;
            workoutStopDuration = totalDuration + workoutSeconds + stopSeconds > 86399 ? 86399-(totalDuration+workoutSeconds): workoutStopDuration;
            break;
        }else{
            totalDuration += workoutSeconds + stopSeconds;
            workoutStopDuration += stopSeconds;
        }
    }
    
    return workoutStopDuration;
}

- (BOOL)hasSpillOverWorkoutMinutes
{
    NSInteger todayWorkout = [self workoutDurationMinutesForThatDay];
    NSInteger totalWorkout = (self.hour.integerValue * 60) + self.minute.integerValue;
    return totalWorkout > todayWorkout;
}

- (BOOL)hasSpillOverWorkoutSeconds
{
    NSInteger todayWorkout = [self workoutDurationSecondsForThatDay];
    NSInteger totalWorkout = (self.hour.integerValue * 3600) + self.minute.integerValue * 60 + self.second.integerValue;
    return totalWorkout > todayWorkout;
}


- (BOOL)checkIfSpillOverWorkoutForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger comps = NSDayCalendarUnit;
    NSDateComponents *date1Components = [calendar components:comps
                                                    fromDate:date];
    NSInteger day = date1Components.day;
    
    return day == self.stampDay.integerValue+1;
}


- (NSInteger)spillOverWorkoutMinutes
{
    NSInteger workoutDuration = self.hour.integerValue*60 + self.minute.integerValue;
    return  workoutDuration - [self workoutDurationMinutesForThatDay];
}

- (NSInteger)spillOverWorkoutSeconds
{
    NSInteger workoutDuration = self.hour.integerValue * 3600 + self.minute.integerValue * 60 + self.second.integerValue;
    return  workoutDuration - [self workoutDurationSecondsForThatDay];
}

- (NSInteger)spillOverWorkoutHundredths
{
    NSInteger workoutDuration = self.hour.integerValue * 3600 + self.minute.integerValue * 60 + self.second.integerValue;
    workoutDuration = workoutDuration * 100 + self.hundredths.integerValue;
    return  workoutDuration - [self workoutDurationHundredthsForThatDay];
}

- (NSInteger)spillOverWorkoutEndTimeMinutes
{
    NSInteger totalWorkoutDurationForThatDay =[self workoutDurationMinutesForThatDay]+ [self workoutStopDurationMinutesForThatDay];
    
    return ([self totalWorkoutDurationMinutes] - totalWorkoutDurationForThatDay);
}

- (NSInteger)spillOverWorkoutEndTimeSeconds
{
    NSInteger totalWorkoutDurationForThatDay =[self workoutDurationSecondsForThatDay] + [self workoutStopDurationSecondsForThatDay];
    
    return ([self totalWorkoutDurationSeconds] - totalWorkoutDurationForThatDay);
}

@end
