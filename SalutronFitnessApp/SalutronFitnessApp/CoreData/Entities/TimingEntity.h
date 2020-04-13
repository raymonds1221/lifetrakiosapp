//
//  TimingEntity.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 8/19/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeviceEntity;

@interface TimingEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * periodicInterval;
@property (nonatomic, retain) NSNumber * scanTime;
@property (nonatomic, retain) NSNumber * limitTime;
@property (nonatomic, retain) NSNumber * smartForSleep;
@property (nonatomic, retain) NSNumber * smartForWrist;
@property (nonatomic, retain) DeviceEntity *device;

@end
