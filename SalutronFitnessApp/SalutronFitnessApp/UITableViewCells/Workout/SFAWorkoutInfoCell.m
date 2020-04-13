//
//  SFAWorkoutInfoCell.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 8/6/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAWorkoutInfoCell.h"

#import "WorkoutInfoEntity+Data.h"
#import "WorkoutHeaderEntity.h"
#import "WorkoutStopDatabaseEntity.h"
#import "TimeDate+Data.h"
#import "SalutronUserProfile+Data.h"

@interface SFAWorkoutInfoCell ()

@property (weak, nonatomic) IBOutlet UILabel *workoutId;
@property (weak, nonatomic) IBOutlet UILabel *workoutTime;
@property (weak, nonatomic) IBOutlet UILabel *workoutDuration;

@end

@implementation SFAWorkoutInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentsWithWorkout:(WorkoutInfoEntity *)workout workoutIndex:(NSInteger)workoutIndex
{
    TimeDate *timeDate  = [TimeDate getData];
    
    DDLogInfo(@"workout = %@", workout);
    self.workoutIndex = workoutIndex;
    self.workoutId.text = [NSString stringWithFormat:LS_WORKOUT_VARIABLE, workoutIndex + 1];
    
    if ([workout checkIfSpillOverWorkoutForDate:self.date]){
        if ([workout spillOverWorkoutSeconds]/3600 < 1) {
            self.workoutDuration.text = [NSString stringWithFormat:@" %02i min %02i sec %02i hund",([workout spillOverWorkoutSeconds]%3600)/60, [workout spillOverWorkoutSeconds]%(60), [workout spillOverWorkoutHundredths]%100];
        }
        else{
            self.workoutDuration.text = [NSString stringWithFormat:@" %02i hr %02i min %02i sec",[workout spillOverWorkoutSeconds]/3600, ([workout spillOverWorkoutSeconds]%3600)/60, [workout spillOverWorkoutSeconds]%(60)];
        }
    }else{
        if ([workout hasSpillOverWorkoutSeconds]){
            if ([workout workoutDurationSecondsForThatDay]/3600 < 1) {
                int workoutDurationSeconds = [workout workoutDurationSecondsForThatDay];
                self.workoutDuration.text = [NSString stringWithFormat:@" %02i min %02i sec %02i hund",(workoutDurationSeconds%3600)/60, (int)workoutDurationSeconds%60, [workout workoutDurationHundredthsForThatDay]%100];
                //workoutDurationHundredthsForThatDay
            }
            else{
            self.workoutDuration.text = [NSString stringWithFormat:@" %02i hr %02i min %02i sec",[workout workoutDurationSecondsForThatDay]/3600, ([workout workoutDurationSecondsForThatDay]%3600)/60, [workout workoutDurationSecondsForThatDay]%60];
            }
        }else{
            //self.workoutDuration.text = [NSString stringWithFormat:@" %02i hr %02i min %02i sec",workout.hour.integerValue, workout.minute.integerValue, workout.second.integerValue];
            if (workout.hour.integerValue < 1) {
                self.workoutDuration.text = [NSString stringWithFormat:@" %02i min %02i sec %02i hund", workout.minute.integerValue, workout.second.integerValue, workout.hundredths.integerValue];
            }
            else{
                self.workoutDuration.text = [NSString stringWithFormat:@" %02i hr %02i min %02i sec",workout.hour.integerValue, workout.minute.integerValue, workout.second.integerValue];
            }
        }
    }
    

    //in seconds
    NSArray *workoutStops = [workout.workoutStopDatabase allObjects];
    NSInteger workoutStopDuration = 0;
    NSInteger workoutDuration = workout.hour.integerValue * 3600 + workout.minute.integerValue * 60 + workout.second.integerValue;
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        NSInteger stopMinutes = workoutStop.stopHour.integerValue * 3600 + workoutStop.stopMinute.integerValue * 60 + workoutStop.stopSecond.integerValue;
        workoutStopDuration += stopMinutes;
    }

    NSInteger startSeconds =(workout.stampHour.integerValue * 3600 + workout.stampMinute.integerValue * 60 + workout.stampSecond.integerValue);
    
    workoutDuration += startSeconds + workoutStopDuration;
    if ([workout checkIfSpillOverWorkoutForDate:self.date]){
        workoutDuration = [workout spillOverWorkoutEndTimeSeconds];
        startSeconds= 0;
    }else{
        workoutDuration = [workout hasSpillOverWorkoutSeconds] ? 86399 : workoutDuration;
    }

    NSInteger startMinute = (startSeconds%3600)/60;
    NSInteger startHour = startSeconds/3600;
    NSInteger startSecond = startSeconds%60;
    
    NSInteger endMinute = (workoutDuration%3600)/60;
    NSInteger endHour = workoutDuration/3600;
    NSInteger endSecond = workoutDuration%60;
    
    NSString *startTime = [self formatTimeWithHourFormat:timeDate.hourFormat
                                                    hour:startHour
                                                  minute:startMinute
                                                  second:startSecond];
    NSString *endTime   = [self formatTimeWithHourFormat:timeDate.hourFormat
                                                    hour:endHour
                                                  minute:endMinute
                                                  second:endSecond];
    if (timeDate.hourFormat == _24_HOUR) {
        startTime = [startTime removeTimeHourFormat];
        endTime = [endTime removeTimeHourFormat];
    }
    
    self.workoutTime.text     = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
}


- (void)setContentsWithWorkoutHeader:(WorkoutHeaderEntity *)workout workoutIndex:(NSInteger)workoutIndex
{
    TimeDate *timeDate  = [TimeDate getData];
    
    DDLogInfo(@"workout = %@", workout);
    self.workoutIndex = workoutIndex;
    self.workoutId.text = [NSString stringWithFormat:LS_WORKOUT_VARIABLE, workoutIndex + 1];
    
    if ([workout checkIfSpillOverWorkoutForDate:self.date]){
        if ([workout spillOverWorkoutSeconds]/3600 < 1) {
            self.workoutDuration.text = [NSString stringWithFormat:@" %02i min %02i sec %02i hund",([workout spillOverWorkoutSeconds]%3600)/60, [workout spillOverWorkoutSeconds]%(60), [workout spillOverWorkoutHundredths]%100];
        }
        else{
            self.workoutDuration.text = [NSString stringWithFormat:@" %02i hr %02i min %02i sec",[workout spillOverWorkoutSeconds]/3600, ([workout spillOverWorkoutSeconds]%3600)/60, [workout spillOverWorkoutSeconds]%(60)];
        }
    }else{
        if ([workout hasSpillOverWorkoutSeconds]){
            if ([workout workoutDurationSecondsForThatDay]/3600 < 1) {
                int workoutDurationSeconds = [workout workoutDurationSecondsForThatDay];
                self.workoutDuration.text = [NSString stringWithFormat:@" %02i min %02i sec %02i hund",(workoutDurationSeconds%3600)/60, (int)workoutDurationSeconds%60, [workout workoutDurationHundredthsForThatDay]%100];
                //workoutDurationHundredthsForThatDay
            }
            else{
                self.workoutDuration.text = [NSString stringWithFormat:@" %02i hr %02i min %02i sec",[workout workoutDurationSecondsForThatDay]/3600, ([workout workoutDurationSecondsForThatDay]%3600)/60, [workout workoutDurationSecondsForThatDay]%60];
            }
        }else{
            //self.workoutDuration.text = [NSString stringWithFormat:@" %02i hr %02i min %02i sec",workout.hour.integerValue, workout.minute.integerValue, workout.second.integerValue];
            if (workout.hour.integerValue < 1) {
                self.workoutDuration.text = [NSString stringWithFormat:@" %02i min %02i sec %02i hund", workout.minute.integerValue, workout.second.integerValue, workout.hundredths.integerValue];
            }
            else{
                self.workoutDuration.text = [NSString stringWithFormat:@" %02i hr %02i min %02i sec",workout.hour.integerValue, workout.minute.integerValue, workout.second.integerValue];
            }
        }
    }
    
    
    //in seconds
    NSArray *workoutStops = [workout.workoutStopDatabase allObjects];
    NSInteger workoutStopDuration = 0;
    NSInteger workoutDuration = workout.hour.integerValue * 3600 + workout.minute.integerValue * 60 + workout.second.integerValue;
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        NSInteger stopMinutes = workoutStop.stopHour.integerValue * 3600 + workoutStop.stopMinute.integerValue * 60 + workoutStop.stopSecond.integerValue;
        workoutStopDuration += stopMinutes;
    }
    
    NSInteger startSeconds =(workout.stampHour.integerValue * 3600 + workout.stampMinute.integerValue * 60 + workout.stampSecond.integerValue);
    
    workoutDuration += startSeconds + workoutStopDuration;
    if ([workout checkIfSpillOverWorkoutForDate:self.date]){
        workoutDuration = [workout spillOverWorkoutEndTimeSeconds];
        startSeconds= 0;
    }else{
        workoutDuration = [workout hasSpillOverWorkoutSeconds] ? 86399 : workoutDuration;
    }
    
    NSInteger startMinute = (startSeconds%3600)/60;
    NSInteger startHour = startSeconds/3600;
    NSInteger startSecond = startSeconds%60;
    
    NSInteger endMinute = (workoutDuration%3600)/60;
    NSInteger endHour = workoutDuration/3600;
    NSInteger endSecond = workoutDuration%60;
    
    NSString *startTime = [self formatTimeWithHourFormat:timeDate.hourFormat
                                                    hour:startHour
                                                  minute:startMinute
                                                  second:startSecond];
    NSString *endTime   = [self formatTimeWithHourFormat:timeDate.hourFormat
                                                    hour:endHour
                                                  minute:endMinute
                                                  second:endSecond];
    if (timeDate.hourFormat == _24_HOUR) {
        startTime = [startTime removeTimeHourFormat];
        endTime = [endTime removeTimeHourFormat];
    }
    
    self.workoutTime.text     = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
}



- (NSString *)formatTimeWithHourFormat:(HourFormat)hourFormat hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second
{
    NSString *timeAMPM = @"";
    
    if (hourFormat == _12_HOUR) {
        timeAMPM = hour < 12 ? LS_AM : LS_PM;
        hour = hour > 12 ? hour - 12 : hour;
        hour = hour == 0 ? 12 : hour;
    }
    
    NSString *minuteString = [NSString stringWithFormat:@"%@%i", minute < 10 ? @"0" : @"", minute];
    NSString *secondString = [NSString stringWithFormat:@"%@%i", second < 10 ? @"0" : @"", second];
    NSString *time = [NSString stringWithFormat:@"%i:%@:%@ %@", hour, minuteString, secondString, timeAMPM];
    
    return time;
}


@end
