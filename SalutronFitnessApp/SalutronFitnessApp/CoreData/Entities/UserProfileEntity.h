//
//  UserProfileEntity.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeviceEntity;

@interface UserProfileEntity : NSManagedObject

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSNumber * unit;
@property (nonatomic, retain) NSNumber * sensitivity;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) DeviceEntity *device;

@end
