//
//  SFASleepDataCell.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 1/13/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Format.h"

#import "TimeDate+Data.h"

#import "SleepDatabaseEntity+Data.h"

#import "SFASleepDataCell.h"

@implementation SFASleepDataCell

#pragma mark - Public Methods

- (void)setContentsWithSleepDatabaseEntity:(SleepDatabaseEntity *)sleepDatabaseEntity
{
    TimeDate *timeDate  = [TimeDate getData];
    NSString *startTime = [self formatTimeWithHourFormat:timeDate.hourFormat
                                                    hour:sleepDatabaseEntity.sleepStartHour.integerValue
                                                  minute:sleepDatabaseEntity.sleepStartMin.integerValue];
    NSString *endTime   = [self formatTimeWithHourFormat:timeDate.hourFormat
                                                    hour:sleepDatabaseEntity.sleepEndHour.integerValue
                                                  minute:sleepDatabaseEntity.sleepEndMin.integerValue];
    
    if (timeDate.hourFormat == _24_HOUR) {
        startTime = [startTime removeTimeHourFormat];
        endTime = [endTime removeTimeHourFormat];
    }
    
    NSInteger sleepDurationHours    = sleepDatabaseEntity.sleepDuration.integerValue / 60;
    NSInteger sleepDurationMinutes  = sleepDatabaseEntity.sleepDuration.integerValue % 60;
    
    self.sleepDuration.text = [NSString stringWithFormat:@"%02ih %imin", sleepDurationHours, sleepDurationMinutes];
    self.sleepTime.text     = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
    self.sleepDate.text     = [self sleepDateWithSleepDatabaseEntity:sleepDatabaseEntity];
}

#pragma mark - Private Methods

- (NSString *)formatTimeWithHourFormat:(HourFormat)hourFormat hour:(NSInteger)hour minute:(NSInteger)minute
{
    NSString *timeAMPM = @"";
    
    if (hourFormat == _12_HOUR) {
        timeAMPM = hour < 12 ? LS_AM : LS_PM;
        hour = hour > 12 ? hour - 12 : hour;
        hour = hour == 0 ? 12 : hour;
    }
    
    NSString *minuteString = [NSString stringWithFormat:@"%@%i", minute < 10 ? @"0" : @"", minute];
    NSString *time = [NSString stringWithFormat:@"%i:%@ %@", hour, minuteString, timeAMPM];
    
    return time;
}

- (NSString *)sleepDateWithSleepDatabaseEntity:(SleepDatabaseEntity *)sleep
{
    TimeDate *timeDate              = [TimeDate getData];
    NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    NSDate *date                    = sleep.dateInNSDate;
    
    if (timeDate.hourFormat == 0 && timeDate.dateFormat == 0)
    {
        dateFormatter.dateFormat = @"dd MMM yyyy";
    }
    else if (timeDate.hourFormat == 0 && timeDate.dateFormat == 1)
    {
        dateFormatter.dateFormat = @"MMM dd yyyy";
    }
    else if (timeDate.hourFormat == 1 && timeDate.dateFormat == 0)
    {
        dateFormatter.dateFormat = @"dd MMM yyyy";
    }
    else
    {
        dateFormatter.dateFormat = @"MMM dd yyyy";
    }
    
    return [dateFormatter stringFromDate:date];
}


@end
