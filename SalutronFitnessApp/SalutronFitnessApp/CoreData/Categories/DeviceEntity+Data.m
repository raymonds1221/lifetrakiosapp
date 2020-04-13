//
//  DeviceEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/17/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Format.h"

#import "DeviceEntity+Data.h"
#import "UserEntity.h"
#import "SFAServerAccountManager.h"

#import "JDACoreData.h"

@implementation DeviceEntity (Data)

#pragma mark - Class Methods

+ (BOOL)hasDeviceEntity
{
    return self.deviceEntities.count > 0;
}

+ (NSArray *)deviceEntities
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    NSArray *devices = [coreData fetchEntityWithEntityName:DEVICE_ENTITY];
    return devices;
}

+ (NSArray *)deviceEntitiesWithNoUser
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    NSArray *devices = [coreData fetchEntityWithEntityName:DEVICE_ENTITY];
    NSMutableArray *devicesWithNoUsers = [[NSMutableArray alloc] init];
    
    for (DeviceEntity *device in devices) {
        if (device.user == nil)
            [devicesWithNoUsers addObject:device];
    }
    
    return devicesWithNoUsers;
}

+ (NSArray *)deviceEntitiesForUser:(UserEntity *)user
{
    JDACoreData *coreData   = [JDACoreData sharedManager];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"user == %@",user];
    NSArray *devices        = [coreData fetchEntityWithEntityName:DEVICE_ENTITY predicate:predicate];
    
    return devices;
}

+ (DeviceEntity *)deviceEntityForMacAddress:(NSString *)macAddress
{
    JDACoreData *coreData   = [JDACoreData sharedManager];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"macAddress == %@", macAddress];
    NSArray *devices        = [coreData fetchEntityWithEntityName:DEVICE_ENTITY predicate:predicate];
    
    if (devices.count > 0) {
        for (DeviceEntity *device in devices) {
            if ([device.user.userID isEqualToString:[SFAServerAccountManager sharedManager].user.userID]) {
                return device;
            }
        }
        for (DeviceEntity *device in devices) {
            if (device.user.userID == nil) {
                return device;
            }
        }
        //return devices.firstObject;
    }

    return nil;
}

+ (DeviceEntity *)deviceEntityForUUID:(NSUUID *)uuid
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", [uuid UUIDString]];
    NSArray *devices = [coreData fetchEntityWithEntityName:DEVICE_ENTITY predicate:predicate];
    
    if (devices.count > 0) {
        return devices.firstObject;
    }
    
    return nil;
}


+ (NSArray *)deviceEntitesForArray:(NSArray *)array
{
    NSMutableArray *deviceEntities = [NSMutableArray new];
    
    for (NSDictionary *dictionary in array) {
        NSString *macAddress        = [dictionary objectForKey:API_DEVICE_MAC_ADDRESS];
        DeviceEntity *deviceEntity  = [self deviceEntityForMacAddress:macAddress];
        
        if (!deviceEntity || deviceEntity.user.userID != [SFAServerAccountManager sharedManager].user.userID) {
        //if (!deviceEntity) {
            JDACoreData *coreData           = [JDACoreData sharedManager];
            NSString *lastDateSynced        = [dictionary objectForKey:API_DEVICE_LAST_DATE_SYNCED];
            NSString *updatedSynced         = [dictionary objectForKey:API_DEVICE_UPDATED_AT];
            NSString *modelNumber           = [dictionary objectForKey:API_DEVICE_MODEL_NUMBER];
            if([modelNumber isEqualToString:@"400"]){
                modelNumber = @"300";
            }
            deviceEntity                    = [coreData insertNewObjectWithEntityName:DEVICE_ENTITY];
            deviceEntity.uuid               = [dictionary objectForKey:API_DEVICE_UUID];
            deviceEntity.macAddress         = [dictionary objectForKey:API_DEVICE_MAC_ADDRESS];
            deviceEntity.modelNumber        = @(modelNumber.integerValue);
            deviceEntity.modelNumberString  = modelNumber;
            deviceEntity.name               = [dictionary objectForKey:API_DEVICE_NAME];
            deviceEntity.date               = [NSDate dateFromString:lastDateSynced withFormat:API_DATE_TIME_FORMAT];
            deviceEntity.lastDateSynced     = [NSDate dateFromString:lastDateSynced withFormat:API_DATE_TIME_FORMAT];
            deviceEntity.updatedSynced      = [NSDate dateFromString:updatedSynced withFormat:API_DATE_TIME_FORMAT];
            deviceEntity.isSyncedToServer   = [NSNumber numberWithBool:YES];
            deviceEntity.cloudSyncEnabled   = [NSNumber numberWithBool:YES];
            deviceEntity.user.userID         = [dictionary objectForKey:API_USER_ID];
        }
        else{
            /*
            NSString *lastDateSynced        = [dictionary objectForKey:API_DEVICE_LAST_DATE_SYNCED];
            NSString *updatedSynced         = [dictionary objectForKey:API_DEVICE_UPDATED_AT];
            NSString *modelNumber           = [dictionary objectForKey:API_DEVICE_MODEL_NUMBER];
            if([modelNumber isEqualToString:@"400"]){
                modelNumber = @"300";
            }
            deviceEntity.uuid               = [dictionary objectForKey:API_DEVICE_UUID];
            deviceEntity.macAddress         = [dictionary objectForKey:API_DEVICE_MAC_ADDRESS];
            deviceEntity.modelNumber        = @(modelNumber.integerValue);
            deviceEntity.modelNumberString  = modelNumber;
             */
            deviceEntity.name               = [dictionary objectForKey:API_DEVICE_NAME];
            /*
            deviceEntity.date               = [NSDate dateFromString:lastDateSynced withFormat:API_DATE_TIME_FORMAT];
            deviceEntity.lastDateSynced     = [NSDate dateFromString:lastDateSynced withFormat:API_DATE_TIME_FORMAT];
            deviceEntity.updatedSynced      = [NSDate dateFromString:updatedSynced withFormat:API_DATE_TIME_FORMAT];
            deviceEntity.isSyncedToServer   = [NSNumber numberWithBool:YES];
            deviceEntity.cloudSyncEnabled   = [NSNumber numberWithBool:YES];
            deviceEntity.user.userID         = [dictionary objectForKey:API_USER_ID];
             */
        }
    
        [deviceEntities addObject:deviceEntity];
    }

    return deviceEntities.copy;
}

+ (void)deviceEntityWithDictionary:(NSDictionary *)dictionary
{
    NSString *macAddress        = [dictionary objectForKey:API_DEVICE_MAC_ADDRESS];
    DeviceEntity *deviceEntity  = [self deviceEntityForMacAddress:macAddress];
    
    if (!deviceEntity) {
        JDACoreData *coreData           = [JDACoreData sharedManager];
        NSString *modelNumber           = [dictionary objectForKey:API_DEVICE_MODEL_NUMBER];
        if ([modelNumber isEqualToString:@"400"]) {
            modelNumber = @"300";
        }
        deviceEntity                    = [coreData insertNewObjectWithEntityName:DEVICE_ENTITY];
        deviceEntity.uuid               = [dictionary objectForKey:API_DEVICE_UUID];
        deviceEntity.macAddress         = [dictionary objectForKey:API_DEVICE_MAC_ADDRESS];
        deviceEntity.modelNumber        = @(modelNumber.integerValue);
        deviceEntity.modelNumberString  = modelNumber;
        deviceEntity.name               = [dictionary objectForKey:API_DEVICE_NAME];
        deviceEntity.isSyncedToServer   = [NSNumber numberWithBool:YES];
        deviceEntity.cloudSyncEnabled   = [NSNumber numberWithBool:YES];
        deviceEntity.user.userID         = [dictionary objectForKey:API_USER_ID];
    }
    
    NSString *dateString            = [dictionary objectForKey:API_DEVICE_LAST_DATE_SYNCED];
    
    deviceEntity.date               = [NSDate dateFromString:dateString withFormat:API_DATE_TIME_FORMAT];
    deviceEntity.lastDateSynced     = [NSDate dateFromString:dateString withFormat:API_DATE_TIME_FORMAT]; //watch
    
//    dateString                      = [dictionary objectForKey:API_DEVICE_UPDATED_AT];
//    deviceEntity.updatedSynced      = [NSDate dateFromString:dateString withFormat:API_DATE_TIME_FORMAT];
}

#pragma mark - Instance Methods

- (NSDictionary *)dictionary
{
    NSString *lastDateSynced;
    NSString *uuid;
    
    if (self.uuid == nil)
        uuid = @"";
    else
        uuid = self.uuid;
    
    NSString *tempName = [self.modelNumber intValue] == WatchModel_R450 ? @"LifeTrak Brite" : @"LifeTrak watch";
//    NSString *updatedSynced         = [self.updatedSynced stringWithFormat:API_DATE_TIME_FORMAT];
    NSDictionary *tempDictionary        = @{API_DEVICE_UUID             : uuid,
                                    API_DEVICE_MAC_ADDRESS          : self.macAddress,
                                    API_DEVICE_MODEL_NUMBER         : self.modelNumber,
                                    API_DEVICE_NAME                 : self.name ? self.name : tempName,
                                    /*API_DEVICE_UPDATED_AT           : updatedSynced*/};
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:tempDictionary];
    
    if (self.lastDateSynced) {
        lastDateSynced        = [self.lastDateSynced stringWithFormat:API_DATE_TIME_FORMAT];
        [dictionary setObject:lastDateSynced forKey:API_DEVICE_LAST_DATE_SYNCED];
    }

    return dictionary;
}

@end
