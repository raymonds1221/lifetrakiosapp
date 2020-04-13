//
//  InactiveAlertEntity.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 8/19/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeviceEntity;

@interface InactiveAlertEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * timeDuration;
@property (nonatomic, retain) NSNumber * stepsThreshold;
@property (nonatomic, retain) NSNumber * startHour;
@property (nonatomic, retain) NSNumber * startMin;
@property (nonatomic, retain) NSNumber * endHour;
@property (nonatomic, retain) NSNumber * endMin;
@property (nonatomic, retain) DeviceEntity *device;

@end
