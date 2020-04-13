//
//  TimeDateEntity.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeviceEntity;

@interface TimeDateEntity : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * hourFormat;
@property (nonatomic, retain) NSNumber * dateFormat;
@property (nonatomic, retain) NSNumber * watchFace;
@property (nonatomic, retain) DeviceEntity *device;

@end
