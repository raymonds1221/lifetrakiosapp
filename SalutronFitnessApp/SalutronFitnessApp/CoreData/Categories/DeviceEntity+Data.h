//
//  DeviceEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/17/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "DeviceEntity+CoreDataProperties.h"

@interface DeviceEntity (Data)

+ (BOOL)hasDeviceEntity;
+ (NSArray *)deviceEntities;
+ (DeviceEntity *)deviceEntityForMacAddress:(NSString *)macAddress;
+ (DeviceEntity *)deviceEntityForUUID:(NSUUID *)uuid;
+ (NSArray *)deviceEntitesForArray:(NSArray *)array;
+ (void)deviceEntityWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)deviceEntitiesWithNoUser;
+ (NSArray *)deviceEntitiesForUser:(UserEntity *)user;

- (NSDictionary *)dictionary;

@end
