//
//  DeviceEntity+CoreDataProperties.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/2/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DeviceEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *cloudSyncEnabled;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *isSyncedToServer;
@property (nullable, nonatomic, retain) NSDate *lastDateSynced;
@property (nullable, nonatomic, retain) NSString *macAddress;
@property (nullable, nonatomic, retain) NSNumber *modelNumber;
@property (nullable, nonatomic, retain) NSString *modelNumberString;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSDate *updatedSynced;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) CalibrationDataEntity *calibrationData;
@property (nullable, nonatomic, retain) DayLightAlertEntity *dayLightAlert;
@property (nullable, nonatomic, retain) NSSet<GoalsEntity *> *goals;
@property (nullable, nonatomic, retain) NSSet<StatisticalDataHeaderEntity *> *header;
@property (nullable, nonatomic, retain) InactiveAlertEntity *inactiveAlert;
@property (nullable, nonatomic, retain) NightLightAlertEntity *nightLightAlert;
@property (nullable, nonatomic, retain) NotificationEntity *notification;
@property (nullable, nonatomic, retain) NSSet<SleepDatabaseEntity *> *sleepdatabase;
@property (nullable, nonatomic, retain) SleepSettingEntity *sleepSetting;
@property (nullable, nonatomic, retain) TimeDateEntity *timeDate;
@property (nullable, nonatomic, retain) TimingEntity *timing;
@property (nullable, nonatomic, retain) UserEntity *user;
@property (nullable, nonatomic, retain) UserProfileEntity *userProfile;
@property (nullable, nonatomic, retain) WakeupEntity *wakeup;
@property (nullable, nonatomic, retain) NSSet<WorkoutInfoEntity *> *workout;
@property (nullable, nonatomic, retain) NSSet<WorkoutHeaderEntity *> *workoutHeader;
@property (nullable, nonatomic, retain) WorkoutSettingEntity *workoutSetting;

@end

@interface DeviceEntity (CoreDataGeneratedAccessors)

- (void)addGoalsObject:(GoalsEntity *)value;
- (void)removeGoalsObject:(GoalsEntity *)value;
- (void)addGoals:(NSSet<GoalsEntity *> *)values;
- (void)removeGoals:(NSSet<GoalsEntity *> *)values;

- (void)addHeaderObject:(StatisticalDataHeaderEntity *)value;
- (void)removeHeaderObject:(StatisticalDataHeaderEntity *)value;
- (void)addHeader:(NSSet<StatisticalDataHeaderEntity *> *)values;
- (void)removeHeader:(NSSet<StatisticalDataHeaderEntity *> *)values;

- (void)addSleepdatabaseObject:(SleepDatabaseEntity *)value;
- (void)removeSleepdatabaseObject:(SleepDatabaseEntity *)value;
- (void)addSleepdatabase:(NSSet<SleepDatabaseEntity *> *)values;
- (void)removeSleepdatabase:(NSSet<SleepDatabaseEntity *> *)values;

- (void)addWorkoutObject:(WorkoutInfoEntity *)value;
- (void)removeWorkoutObject:(WorkoutInfoEntity *)value;
- (void)addWorkout:(NSSet<WorkoutInfoEntity *> *)values;
- (void)removeWorkout:(NSSet<WorkoutInfoEntity *> *)values;

- (void)addWorkoutHeaderObject:(WorkoutHeaderEntity *)value;
- (void)removeWorkoutHeaderObject:(WorkoutHeaderEntity *)value;
- (void)addWorkoutHeader:(NSSet<WorkoutHeaderEntity *> *)values;
- (void)removeWorkoutHeader:(NSSet<WorkoutHeaderEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
