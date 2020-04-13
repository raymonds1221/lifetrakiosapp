//
//  WorkoutSettingEntity.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/2/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import "WorkoutSettingEntity.h"
#import "DeviceEntity.h"
#import "JDACoreData.h"

@implementation WorkoutSettingEntity

// Insert code here to add functionality to your managed object subclass

+ (WorkoutSettingEntity *)entityWithWorkoutSetting:(WorkoutSetting *)workoutSetting forDeviceEntity:(DeviceEntity *)device
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    
    if (!device.workoutSetting) {
        device.workoutSetting = [coreData insertNewObjectWithEntityName:WORKOUT_SETTING_ENTITY];
    }
    
    device.workoutSetting.hrLogRate         = [NSNumber numberWithChar:workoutSetting.HRLogRate];
    device.workoutSetting.databaseUsage     = [NSNumber numberWithInt:workoutSetting.databaseUsage];
    device.workoutSetting.databaseUsageMax  = [NSNumber numberWithInt:workoutSetting.databaseUsageMax];
    device.workoutSetting.reconnectTimeout  = [NSNumber numberWithChar:workoutSetting.reconnectTimeout];
    
    [coreData save];
    
    return device.workoutSetting;
}

+ (WorkoutSettingEntity *)updateWorkoutSetting:(WorkoutSetting *)workoutSetting forDeviceEntity:(DeviceEntity *)device
{
    if (!device.workoutSetting) {
        device.workoutSetting = [[JDACoreData sharedManager] insertNewObjectWithEntityName:WORKOUT_SETTING_ENTITY];
    }
    
    device.workoutSetting.type                  = @(workoutSetting.type);
    device.workoutSetting.hrLogRate             = @(workoutSetting.HRLogRate);
    device.workoutSetting.autoSplitThreshold    = @(workoutSetting.autoSplitThreshold);
    device.workoutSetting.zoneTrainType         = @(workoutSetting.zoneTrainType);
    device.workoutSetting.zone0Upper            = @(workoutSetting.zone0Upper);
    device.workoutSetting.zone0Lower            = @(workoutSetting.zone0Lower);
    device.workoutSetting.zone1Lower            = @(workoutSetting.zone1Lower);
    device.workoutSetting.zone2Lower            = @(workoutSetting.zone2Lower);
    device.workoutSetting.zone3Lower            = @(workoutSetting.zone3Lower);
    device.workoutSetting.zone4Lower            = @(workoutSetting.zone4Lower);
    device.workoutSetting.zone5Lower            = @(workoutSetting.zone5Lower);
    device.workoutSetting.zone5Upper            = @(workoutSetting.zone5Upper);
    device.workoutSetting.reserved              = @(workoutSetting.reserved);
    device.workoutSetting.databaseUsage         = @(workoutSetting.databaseUsage);
    device.workoutSetting.databaseUsageMax      = @(workoutSetting.databaseUsageMax);
    device.workoutSetting.reconnectTimeout      = @(workoutSetting.reconnectTimeout);
    
    return device.workoutSetting;
}

@end
