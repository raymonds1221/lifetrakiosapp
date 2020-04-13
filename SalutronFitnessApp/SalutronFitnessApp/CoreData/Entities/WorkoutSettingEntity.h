//
//  WorkoutSettingEntity.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/2/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "WorkoutSetting.h"

@class DeviceEntity;

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutSettingEntity : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (WorkoutSettingEntity *)entityWithWorkoutSetting:(WorkoutSetting *)workoutSetting forDeviceEntity:(DeviceEntity *)device;
+ (WorkoutSettingEntity *)updateWorkoutSetting:(WorkoutSetting *)workoutSetting forDeviceEntity:(DeviceEntity *)device;

@end

NS_ASSUME_NONNULL_END

#import "WorkoutSettingEntity+CoreDataProperties.h"
