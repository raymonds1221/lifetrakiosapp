//
//  SleepSettingEntity.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeviceEntity;

@interface SleepSettingEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * sleepGoalLo;
@property (nonatomic, retain) NSNumber * sleepGoalHi;
@property (nonatomic, retain) NSNumber * sleepMode;
@property (nonatomic, retain) DeviceEntity *device;

@end
