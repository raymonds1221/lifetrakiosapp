//
//  CalibrationDataEntity.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 9/23/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeviceEntity;

@interface CalibrationDataEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * autoEL;
@property (nonatomic, retain) NSNumber * calories;
@property (nonatomic, retain) NSNumber * run;
@property (nonatomic, retain) NSNumber * step;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * walk;
@property (nonatomic, retain) DeviceEntity *device;

@end
