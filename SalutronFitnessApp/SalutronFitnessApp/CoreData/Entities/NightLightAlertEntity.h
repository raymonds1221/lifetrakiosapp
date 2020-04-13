//
//  NightLightAlertEntity.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/2/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeviceEntity;

@interface NightLightAlertEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * endHour;
@property (nonatomic, retain) NSNumber * endMin;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * startHour;
@property (nonatomic, retain) NSNumber * startMin;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * levelLow;
@property (nonatomic, retain) NSNumber * levelMid;
@property (nonatomic, retain) NSNumber * levelHigh;
@property (nonatomic, retain) DeviceEntity *device;

@end
