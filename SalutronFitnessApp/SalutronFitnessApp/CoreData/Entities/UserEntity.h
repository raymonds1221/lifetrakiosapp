//
//  UserEntity.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 12/11/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeviceEntity;

@interface UserEntity : NSManagedObject

@property (nonatomic, retain) NSString * accessToken;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * newlyRegistered;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSSet *device;
@end

@interface UserEntity (CoreDataGeneratedAccessors)

- (void)addDeviceObject:(DeviceEntity *)value;
- (void)removeDeviceObject:(DeviceEntity *)value;
- (void)addDevice:(NSSet *)values;
- (void)removeDevice:(NSSet *)values;

@end
