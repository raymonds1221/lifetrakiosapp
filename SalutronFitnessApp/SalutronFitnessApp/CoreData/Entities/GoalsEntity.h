//
//  GoalsEntity.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/17/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeviceEntity;

@interface GoalsEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * steps;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * calories;
@property (nonatomic, retain) NSNumber * sleep;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) DeviceEntity *device;

@end
