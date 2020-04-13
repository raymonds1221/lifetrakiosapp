//
//  WakeupEntity.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 2/6/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeviceEntity;

@interface WakeupEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * wakeupMode;
@property (nonatomic, retain) NSNumber * wakeupHour;
@property (nonatomic, retain) NSNumber * wakeupMinute;
@property (nonatomic, retain) NSNumber * wakeupWindow;
@property (nonatomic, retain) NSNumber * snoozeMode;
@property (nonatomic, retain) NSNumber * snoozeMin;
@property (nonatomic, retain) DeviceEntity *device;

@end
