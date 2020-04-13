//
//  WorkoutInfoEntity+Data.m
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/6/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Format.h"

#import "WorkoutInfoEntity+Data.h"
#import "WorkoutStopDatabaseEntity+Data.h"
#import "DeviceEntity.h"
#import "DeviceEntity+Data.h"

#import "SFAServerAccountManager.h"

#import "JDACoreData.h"

@implementation WorkoutInfoEntity (Data)

#pragma mark - Public class select methods
+ (NSArray *)getWorkoutInfoWithDate:(NSDate *)date
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *_month                        = [date getDateStringWithFormat:@"MM"];
    NSString *_day                          = [date getDateStringWithFormat:@"dd"];
    NSString *_year                         = [date getDateStringWithFormat:@"yyyy"];
    NSString *_predicateFormat              = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND device.macAddress == '%@' AND device.user.userID == '%@'", _month, _year, _day, [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    
    NSArray *_workoutInfoEntity      = [[JDACoreData sharedManager] fetchEntityWithEntityName:WORKOUT_INFO_ENTITY
                                                                                    predicate:[NSPredicate predicateWithFormat:_predicateFormat]
                                                                                  sortWithKey:@"stampHour, stampMinute, stampSecond"
                                                                                    ascending:YES
                                                                                     sortType:SORT_TYPE_NUMBER];
    NSMutableArray *_workoutArray    = [_workoutInfoEntity mutableCopy];
    //[_workoutArray invertData];
    return _workoutArray;
}

+ (NSArray *)getHighestWorkoutStepsWithDate:(NSDate *)date
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *_month                        = [date getDateStringWithFormat:@"MM"];
    NSString *_day                          = [date getDateStringWithFormat:@"dd"];
    NSString *_year                         = [date getDateStringWithFormat:@"yyyy"];
    NSString *_predicateFormat              = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND device.macAddress == '%@' AND device.user.userID == '%@'", _month, _year, _day, [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    NSArray *_workoutInfoEntity      = [[JDACoreData sharedManager] fetchEntityWithEntityName:WORKOUT_INFO_ENTITY
                                                                                    predicate:[NSPredicate predicateWithFormat:_predicateFormat]
                                                                                  sortWithKey:@"steps"
                                                                                        limit:1
                                                                                    ascending:NO
                                                                                     sortType:SORT_TYPE_NUMBER];
    
    return _workoutInfoEntity;
}

#pragma mark - Public class insert methods
+ (WorkoutInfoEntity *)insertWorkoutInfoWithSteps:(NSNumber *)steps
                                         distance:(NSNumber *)distance
                                         calories:(NSNumber *)calories
                                           minute:(NSNumber *)minute
                                           second:(NSNumber *)second
                                             hour:(NSNumber *)hour
                                 distanceUnitFlag:(NSNumber *)distanceUnitFlag
                                      hundredth:(NSNumber *)hundredth
                                      stampSecond:(NSNumber *)stampSecond
                                      stampMinute:(NSNumber *)stampMinute
                                        stampHour:(NSNumber *)stampHour
                                         stampDay:(NSNumber *)stampDay
                                       stampMonth:(NSNumber *)stampMonth
                                        stampYear:(NSNumber *)stampYear
                                        workoutID:(NSNumber *)workoutID
{
    //sdk may return negative stamp second due to corrupted data
    if (stampSecond.integerValue < 0) {
        stampSecond = @(0);
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *_predicateFormat;
    
    NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
    DeviceEntity *device            = [DeviceEntity deviceEntityForMacAddress:macAddress];
    
    if ([SFAServerAccountManager sharedManager].user.userID) {
        //workaround - since sdk is returning negative stamp second, it will be disregarded for now until the sdk if fixed.
        if([device.modelNumber isEqual:@(WatchModel_Zone_C410)]){
            _predicateFormat = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND stampMinute == '%@' AND stampHour == '%@' AND device.macAddress == '%@' AND device.user.userID == '%@'", stampMonth, stampYear, stampDay, stampMinute, stampHour, [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
        }
        else{
            _predicateFormat = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND stampMinute == '%@' AND stampHour == '%@' AND stampSecond == '%@' AND device.macAddress == '%@' AND device.user.userID == '%@'", stampMonth, stampYear, stampDay, stampMinute, stampHour, stampSecond, [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
        }
    }
    else{
        if([device.modelNumber isEqual:@(WatchModel_Zone_C410)]){
            _predicateFormat = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND stampMinute == '%@' AND stampHour == '%@' AND device.macAddress == '%@'", stampMonth, stampYear, stampDay, stampMinute, stampHour, [userDefaults objectForKey:MAC_ADDRESS]];
        }
        else{
            _predicateFormat = [NSString stringWithFormat:@"stampMonth == '%@' AND stampYear == '%@' AND stampDay == '%@' AND stampMinute == '%@' AND stampHour == '%@' AND stampSecond == '%@' AND device.macAddress == '%@'", stampMonth, stampYear, stampDay, stampMinute, stampHour, stampSecond, [userDefaults objectForKey:MAC_ADDRESS]];
        }
    }
   
    WorkoutInfoEntity *_workoutInfoEntity   = [[[JDACoreData sharedManager] fetchEntityWithEntityName:WORKOUT_INFO_ENTITY
                                                                                            predicate:[NSPredicate predicateWithFormat:_predicateFormat]] firstObject];
    if (_workoutInfoEntity == nil)
        _workoutInfoEntity = [[JDACoreData sharedManager] insertNewObjectWithEntityName:WORKOUT_INFO_ENTITY];
    
    _workoutInfoEntity.steps            = steps;
    _workoutInfoEntity.distance         = distance;
    _workoutInfoEntity.calories         = calories;
    _workoutInfoEntity.hundredths       = hundredth;
    _workoutInfoEntity.minute           = minute;
    _workoutInfoEntity.second           = second;
    _workoutInfoEntity.hour             = hour;
    _workoutInfoEntity.distanceUnitFlag = distanceUnitFlag;
    _workoutInfoEntity.stampSecond      = stampSecond;
    _workoutInfoEntity.stampMinute      = stampMinute;
    _workoutInfoEntity.stampHour        = stampHour;
    _workoutInfoEntity.stampDay         = stampDay;
    _workoutInfoEntity.stampMonth       = stampMonth;
    _workoutInfoEntity.stampYear        = stampYear;
    _workoutInfoEntity.workoutID        = workoutID;
    //_workoutInfoEntity.isSyncedToServer = [NSNumber numberWithBool:NO];
    
    //[[JDACoreData manager] save];
    return _workoutInfoEntity;
}

#pragma mark - Private Methods

+ (WorkoutInfoEntity *)workoutWithDictionary:(NSDictionary *)dictionary forDeviceEntity:(DeviceEntity *)device
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
    WorkoutInfoEntity *workout      = [self insertWorkoutInfoWithSteps:steps
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
    
    [device addWorkoutObject:workout];
    [WorkoutStopDatabaseEntity workoutStopDatabaseEntitiesWithArray:workoutStop forWorkoutInfoEntity:workout];
    
    return workout;
}

+ (void)setAllIsSyncedToServer:(BOOL)isSyncedToServer forDeviceEntity:(DeviceEntity *)deviceEntity
{
	for (WorkoutInfoEntity *workoutEntity in deviceEntity.workout.allObjects) {
		
		NSDate *workoutEntityDate = [[workoutEntity startDate] dateWithoutTime];
		NSDate *currentDate = [[NSDate date] dateWithoutTime];
		
		if ([workoutEntityDate isEqualToDate:currentDate]) {
			workoutEntity.isSyncedToServer = [NSNumber numberWithBool:NO];
		}
		else {
			workoutEntity.isSyncedToServer = [NSNumber numberWithBool:isSyncedToServer];
		}
	}
	[[JDACoreData sharedManager] save];
}


#pragma mark - Public Methods

+ (NSArray *)workoutsDictionaryForDeviceEntity:(DeviceEntity *)device
{
    NSMutableArray *workouts = [NSMutableArray new];
    
    for (WorkoutInfoEntity *workout in device.workout) {
        [workouts addObject:workout.dictionary];
    }
    
    return workouts.copy;
}

+ (NSArray *)workoutsDictionaryWithStartingDateForDeviceEntity:(DeviceEntity *)device
{
    NSMutableArray *workouts = [NSMutableArray new];
    
    for (WorkoutInfoEntity *workout in device.workout) {
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

+ (NSArray *)workoutsDictionaryForDeviceEntity:(DeviceEntity *)device forDate:(NSDate *)date
{
    NSMutableArray *workouts = [NSMutableArray new];
    
    for (WorkoutInfoEntity *workout in device.workout) {
        NSDate *headerEntityDate = [[workout startDate] dateWithoutTime];
        DDLogInfo(@"workout - %@", workout);
        DDLogInfo(@"date ?= headerEntityDate -> %@ ?= %@", date, headerEntityDate);
        if ([date isEqualToDate:headerEntityDate]) {
            [workouts addObject:workout.dictionary];
            DDLogInfo(@"DEBUG --> workoutDB date: %@", [workout startDate]);
        }
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
        WorkoutInfoEntity *workout = [self workoutWithDictionary:dictionary forDeviceEntity:device];
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
    NSArray *workoutStops = [self.workoutStopDatabase allObjects];
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
    NSArray *workoutStops = [self.workoutStopDatabase allObjects];
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
    NSArray *tempWorkoutStop = [self.workoutStopDatabase allObjects];
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


- (NSDictionary *)dictionary
{
    NSMutableArray *workoutStops = [NSMutableArray new];
    
    for (WorkoutStopDatabaseEntity *workoutStop in self.workoutStopDatabase) {
        [workoutStops addObject:workoutStop.dictionary];
    }
    
    NSInteger duration = [self duration];
    if (self.device.modelNumber.integerValue == WatchModel_Zone_C410 ||
        self.device.modelNumber.integerValue == WatchModel_R420) {
        //If account is created on Android
        if ([self.device.macAddress rangeOfString:@":"].location != NSNotFound) {
            duration = duration;
        }
        else{
            //convert to seconds
            duration = (duration/100);
        }
    }
    
    NSDate *startDate           = [self startDate];
    NSString *dateString        = [startDate stringWithFormat:API_DATE_TIME_FORMAT];
    NSDictionary *dictionary    = @{API_WORKOUT_ID              : self.workoutID,
                                    API_WORKOUT_DURATION        : @(duration),
                                    API_WORKOUT_START_DATE      : dateString,
                                    API_WORKOUT_STEPS           : self.steps,
                                    API_WORKOUT_CALORIES        : self.calories,
                                    API_WORKOUT_DISTANCE        : self.distance,
                                    API_WORKOUT_DISTANCE_UNIT   : self.distanceUnitFlag,
                                    API_WORKOUT_PLATFORM        : API_PLATFORM,
                                    API_WORKOUT_WORKOUT_STOP    : workoutStops.copy};
    
    return dictionary;
}

@end
