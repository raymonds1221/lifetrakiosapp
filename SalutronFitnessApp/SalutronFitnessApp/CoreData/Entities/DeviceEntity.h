//
//  DeviceEntity.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/2/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CalibrationDataEntity, DayLightAlertEntity, GoalsEntity, InactiveAlertEntity, NightLightAlertEntity, NotificationEntity, SleepDatabaseEntity, SleepSettingEntity, StatisticalDataHeaderEntity, TimeDateEntity, TimingEntity, UserEntity, UserProfileEntity, WakeupEntity, WorkoutHeaderEntity, WorkoutInfoEntity, WorkoutSettingEntity;

NS_ASSUME_NONNULL_BEGIN

@interface DeviceEntity : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "DeviceEntity+CoreDataProperties.h"
