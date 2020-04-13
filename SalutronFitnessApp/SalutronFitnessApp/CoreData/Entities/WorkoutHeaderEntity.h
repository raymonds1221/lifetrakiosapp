//
//  WorkoutHeaderEntity.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/12/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "WorkoutHeader.h"
#import "DeviceEntity+CoreDataProperties.h"

@class DeviceEntity, WorkoutRecordEntity, WorkoutStopDatabaseEntity, WorkoutHeartRateDataEntity;

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutHeaderEntity : NSManagedObject

+ (WorkoutHeaderEntity *)entityWithWorkoutHeader:(WorkoutHeader *)workoutHeader;
+ (NSArray *)workoutHeaderDictionaryWithDevice:(DeviceEntity *)device;
+ (WorkoutHeaderEntity *)workoutHeaderEntityWithDictionary:(NSDictionary *)dictionary forDeviceEntity:(DeviceEntity *)deviceEntity;
+ (NSArray *)getWorkoutHeartRateWithMinMaxDataWithDate:(NSDate *)date;
+ (int)getAverageWorkoutHeartRateWithDate:(NSDate *)date;
+ (int)getMinWorkoutHeartRateWithDate:(NSDate *)date;
+ (int)getMaxWorkoutHeartRateWithDate:(NSDate *)date;
+ (NSArray *)getWorkoutHeartRateDataWithDate:(NSDate *)date withWorkoutIndex:(int)workoutIndex;
+ (NSArray *)workoutHeadersWithArray:(NSArray *)array forDeviceEntity:(DeviceEntity *)deviceEntity;

- (NSDictionary *)dictionary;


//select methods
+ (NSArray *)getWorkoutInfoWithDate:(NSDate *)date;
+ (NSArray *)getHighestWorkoutStepsWithDate:(NSDate *)date;

//insert methods
+ (WorkoutHeaderEntity *)insertWorkoutInfoWithSteps:(NSNumber *)steps
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
+ (NSArray *)workoutHeaderDictionaryWithDevice:(DeviceEntity *)device forDate:(NSDate *)date;
+ (NSArray *)getWorkoutHeartRateDataWithDate:(NSDate *)date;

+ (NSArray *)workoutsDictionaryWithStartingDateForDeviceEntity:(DeviceEntity *)device;

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

+ (WorkoutHeaderEntity *)workoutHeaderEntityWithMacAddress:(NSString *)macAddress
                                                stampMonth:(NSNumber *)stampMonth
                                                 stampYear:(NSNumber *)stampYear
                                                  stampDay:(NSNumber *)stampDay
                                               stampMinute:(NSNumber *)stampMinute
                                                 stampHour:(NSNumber *)stampHour
                                               stampSecond:(NSNumber *)stampSecond;
@end

NS_ASSUME_NONNULL_END

#import "WorkoutHeaderEntity+CoreDataProperties.h"
