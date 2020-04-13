//
//  SFAWorkoutCell.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/24/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "WorkoutInfoEntity.h"

#import "TimeDate+Data.h"
#import "SalutronUserProfile+Data.h"

#import "SFAWorkoutCell.h"

@implementation SFAWorkoutCell

#pragma mark - Public Methods

- (void)setContentsWithWorkout:(WorkoutInfoEntity *)workout workoutIndex:(NSInteger)workoutIndex
{
    SalutronUserProfile *userProfile    = [SalutronUserProfile getData];
    BOOL isMetric                       = workout.distanceUnitFlag.boolValue;
    CGFloat distance                    = workout.distance.floatValue;
    
    if (userProfile.unit == IMPERIAL) {
        distance                *= isMetric ? 0.621371 : 1;
        self.totalDistance.text = [NSString stringWithFormat:@"%.2f mi", distance];
    } else {
        distance                /= isMetric ? 1 : 0.621371;
        self.totalDistance.text = [NSString stringWithFormat:@"%.2f km", distance];
    }
    
    self.workoutTitle.text              = [NSString stringWithFormat:LS_WORKOUT_VARIABLE, workoutIndex + 1];
    self.totalCalories.text             = [NSString stringWithFormat:@"%@ kcal", workout.calories];
    self.totalSteps.text                = [NSString stringWithFormat:@"%@", workout.steps];
    self.workoutStartTime.text          = [self formatTimeWithHourFormat:[[TimeDate getData] hourFormat]
                                                                    hour:workout.stampHour.integerValue
                                                                  minute:workout.stampMinute.integerValue];
    
    TimeDate *timeDate = [TimeDate getData];
    if (timeDate.hourFormat == _24_HOUR) {
        self.workoutStartTime.text = [self.workoutStartTime.text removeTimeHourFormat];
    }
    
    self.totalWorkoutTime.text          = [NSString stringWithFormat:@"%@:%@:%@:%@", workout.hour, workout.minute, workout.second, workout.hundredths];
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

@end
