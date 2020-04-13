//
//  WorkoutInfoEntity+Data.h
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/6/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "WorkoutInfoEntity.h"

@interface WorkoutInfoEntity (Data)

//select methods
+ (NSArray *)getWorkoutInfoWithDate:(NSDate *)date;
+ (NSArray *)getHighestWorkoutStepsWithDate:(NSDate *)date;

//insert methods
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
                                        workoutID:(NSNumber *)workoutID;

+ (NSArray *)workoutsDictionaryForDeviceEntity:(DeviceEntity *)device;
+ (NSArray *)workoutsWithArray:(NSArray *)array forDeviceEntity:(DeviceEntity *)device;

+ (NSArray *)workoutsDictionaryWithStartingDateForDeviceEntity:(DeviceEntity *)device;
+ (NSArray *)workoutsDictionaryForDeviceEntity:(DeviceEntity *)device forDate:(NSDate *)date;

- (NSDictionary *)dictionary;

- (BOOL)hasSpillOverWorkoutMinutes;
- (BOOL)hasSpillOverWorkoutSeconds;
- (BOOL)checkIfSpillOverWorkoutForDate:(NSDate *)date;
- (NSInteger)totalWorkoutDurationMinutes;
- (NSInteger)workoutDurationMinutesForThatDay;
- (NSInteger)workoutDurationSecondsForThatDay;
- (NSInteger)workoutDurationHundredthsForThatDay;
- (NSInteger)spillOverWorkoutMinutes;
- (NSInteger)spillOverWorkoutSeconds;
- (NSInteger)spillOverWorkoutHundredths;
- (NSInteger)spillOverWorkoutEndTimeMinutes;
- (NSInteger)spillOverWorkoutEndTimeSeconds;

+ (void)setAllIsSyncedToServer:(BOOL)isSyncedToServer forDeviceEntity:(DeviceEntity *)deviceEntity;

@end
