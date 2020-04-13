//
//  WorkoutInfoEntity.h
//  Pods
//
//  Created by Patricia Marie Cesar on 11/28/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeviceEntity, WorkoutStopDatabaseEntity;

@interface WorkoutInfoEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * calories;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * distanceUnitFlag;
@property (nonatomic, retain) NSNumber * hour;
@property (nonatomic, retain) NSNumber * hundredths;
@property (nonatomic, retain) NSNumber * minute;
@property (nonatomic, retain) NSNumber * second;
@property (nonatomic, retain) NSNumber * stampDay;
@property (nonatomic, retain) NSNumber * stampHour;
@property (nonatomic, retain) NSNumber * stampMinute;
@property (nonatomic, retain) NSNumber * stampMonth;
@property (nonatomic, retain) NSNumber * stampSecond;
@property (nonatomic, retain) NSNumber * stampYear;
@property (nonatomic, retain) NSNumber * steps;
@property (nonatomic, retain) NSNumber * workoutID;
@property (nonatomic, retain) NSNumber * isSyncedToServer;
@property (nonatomic, retain) DeviceEntity *device;
@property (nonatomic, retain) NSSet *workoutStopDatabase;
@end

@interface WorkoutInfoEntity (CoreDataGeneratedAccessors)

- (void)addWorkoutStopDatabaseObject:(WorkoutStopDatabaseEntity *)value;
- (void)removeWorkoutStopDatabaseObject:(WorkoutStopDatabaseEntity *)value;
- (void)addWorkoutStopDatabase:(NSSet *)values;
- (void)removeWorkoutStopDatabase:(NSSet *)values;

@end
