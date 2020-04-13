//
//  SFASalutronLibrary.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/26/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronLibrary.h"

#import "SFASalutronFitnessAppDelegate.h"
#import "SFAServerAccountManager.h"


@interface SFASalutronLibrary ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation SFASalutronLibrary

- (id) initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    if(self = [super init]) {
        //_managedObjectContext = managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:STATISTICAL_DATA_HEADER_ENTITY];
        NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        //DDLogError(@"fetch results: %@", results);
        return self;
    }
    return nil;
}

#pragma mark - Public Methods

- (NSManagedObjectContext *)managedObjectContext
{
    if(!_managedObjectContext) {
        SFASalutronFitnessAppDelegate *appDelegate = (SFASalutronFitnessAppDelegate *)[UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (BOOL) isStatisticalDataHeaderExists:(StatisticalDataHeader *)dataHeader
                                entity:(StatisticalDataHeaderEntity *__autoreleasing *)entity {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *macAddress = [userDefaults stringForKey:MAC_ADDRESS];
    NSString *query = @"date.day == $day && date.month == $month && date.year == $year && device.macAddress == $macAddress";
    if ([SFAServerAccountManager sharedManager].user.userID) {
        query = @"date.day == $day && date.month == $month && date.year == $year && device.macAddress == $macAddress && device.user.userID == $userID";
    }
    else{
        query = @"date.day == $day && date.month == $month && date.year == $year && device.macAddress == $macAddress && device.user.userID = nil";
    }
    // && device.user.userID == $userID
    SH_Date *date = dataHeader.date;
    
    NSNumber *day = [NSNumber numberWithInt:date.day];
    NSNumber *month = [NSNumber numberWithInt:date.month];
    NSNumber *year = [NSNumber numberWithInt:date.year];
    NSDictionary *vars = [[NSDictionary alloc]
                          initWithObjectsAndKeys:day, @"day", month, @"month", year,@"year", macAddress, @"macAddress", [SFAServerAccountManager sharedManager].user.userID, @"userID", nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
    predicate = [predicate predicateWithSubstitutionVariables:vars];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:STATISTICAL_DATA_HEADER_ENTITY];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error && [results count] > 0) {
        
        if([SFAServerAccountManager sharedManager].user.userID){
            for (StatisticalDataHeaderEntity *result in results) {
                if ([result.device.user.userID isEqualToString:[SFAServerAccountManager sharedManager].user.userID]) {
                    StatisticalDataHeaderEntity *dataHeaderEntity = result;
                    *entity = dataHeaderEntity;
                    return YES;
                }
            }
            return NO;
        }
        else{
            StatisticalDataHeaderEntity *dataHeaderEntity = (StatisticalDataHeaderEntity *)[results lastObject];
            *entity = dataHeaderEntity;
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) isStatisticalDataPointExists:(StatisticalDataPoint *)dataPoint
                               entity:(StatisticalDataPointEntity *__autoreleasing *)entity {
    NSString *query = @"averageHR == $averageHR && axisDirection == $axisDirection && "
    @"axisMagnitude == $axisMagnitude && calorie == $calorie && "
    @"distance == $distance && dominantAxis == $dominantAxis && "
    @"lux == $lux && sleepPoint02 == $sleepPoint02 && "
    @"sleepPoint24 == $sleepPoint24 && sleepPoint46 == $sleepPoint46 && "
    @"sleepPoint68 == $sleepPoint68 && sleepPoint810 == $sleepPoint810 && steps == $steps";
    
    NSNumber *averageHR = [NSNumber numberWithInt:dataPoint.averageHR];
    NSNumber *axisDirection = [NSNumber numberWithInt:dataPoint.axis_direction];
    NSNumber *axisMagnitude = [NSNumber numberWithInt:dataPoint.axis_magnitude];
    NSNumber *calorie = [NSNumber numberWithInt:dataPoint.calorie];
    NSNumber *distance = [NSNumber numberWithInt:dataPoint.distance];
    NSNumber *dominantAxis = [NSNumber numberWithInt:dataPoint.dominant_axis];
    //NSNumber *lux = [NSNumber numberWithInt:dataPoint.Lux];
    NSNumber *sleepPoint02 = [NSNumber numberWithInt:dataPoint.sleeppoint_0_2];
    NSNumber *sleepPoint24 = [NSNumber numberWithInt:dataPoint.sleeppoint_2_4];
    NSNumber *sleepPoint46 = [NSNumber numberWithInt:dataPoint.sleeppoint_4_6];
    NSNumber *sleepPoint68 = [NSNumber numberWithInt:dataPoint.sleeppoint_6_8];
    NSNumber *sleepPoint810 = [NSNumber numberWithInt:dataPoint.sleeppoint_8_10];
    NSNumber *steps = [NSNumber numberWithInt:dataPoint.steps];
    
    NSDictionary *vars = [[NSDictionary alloc] initWithObjectsAndKeys:averageHR, @"averageHR", axisDirection, @"axisDirection", axisMagnitude, @"axisMagnitude", calorie, @"calorie", distance, @"distance", dominantAxis, @"dominantAxis", @0, @"lux", sleepPoint02, @"sleepPoint02", sleepPoint24, @"sleepPoint24", sleepPoint46, @"sleepPoint46", sleepPoint68, @"sleepPoint68", sleepPoint810, @"sleepPoint810", steps, @"steps", nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
    predicate = [predicate predicateWithSubstitutionVariables:vars];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:STATISTICAL_DATA_POINT_ENTITY];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error && [results count] > 0) {
        StatisticalDataPointEntity *dataPointEntity = [results lastObject];
        *entity = dataPointEntity;
        return YES;
    }
    return NO;
}

- (BOOL)isStatisticalDataHeaderUpdated:(StatisticalDataHeader *)dataHeader
                                entity:(StatisticalDataHeaderEntity *)entity {
    return (entity.totalCalorie.integerValue >= dataHeader.totalCalorie &&
            entity.totalDistance.integerValue >= dataHeader.totalDistance &&
            entity.totalSteps.integerValue >= dataHeader.totalSteps &&
            entity.totalExposureTime.integerValue >= dataHeader.totalExposureTime &&
            entity.totalSleep.integerValue >= dataHeader.totalSleep);
}

- (BOOL)saveChanges:(NSError *__autoreleasing *)error {
    NSError *e = nil;
    
    if([self.managedObjectContext save:&e]) {
        @try {
            [self.managedObjectContext.undoManager endUndoGrouping];
        }
        @catch (NSException *exception) {
            DDLogError(@"saveChanges exception: %@", exception);
        }
        return YES;
    } else {
        [self.managedObjectContext.undoManager undo];
        *error = [e copy];
    }
    return NO;
}

- (DeviceEntity *)deviceEntityWithMacAddress:(NSString *)macAddress
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:DEVICE_ENTITY];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"macAddress == %@", macAddress];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *deviceDetails = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error && deviceDetails.count > 0) {
        for (DeviceEntity *device in deviceDetails) {
            if ([device.user.userID isEqualToString:[SFAServerAccountManager sharedManager].user.userID]) {
                return device;
            }
        }
        
        for (DeviceEntity *device in deviceDetails) {
            if (device.user.userID == nil) {
                return device;
            }
        }
        //DeviceEntity *deviceEntity = (DeviceEntity *)[deviceDetails firstObject];
        //return deviceEntity;
    }
    
    return nil;
}

- (DeviceEntity *)newDeviceEntityWithUUID:(NSString *)uuid
                                     name:(NSString *)name
                               macAddress:(NSString *)macAddress
                        modelNumberString:(NSString *)modelNumberString
                           modelNumberInt:(NSNumber *)modelNumberInt {
    
    DeviceEntity *deviceEntity = [self deviceEntityWithMacAddress:macAddress];
    NSString     *deviceName   = name;
    
    if (deviceEntity == nil) {
        deviceEntity = [NSEntityDescription insertNewObjectForEntityForName:DEVICE_ENTITY
                                                     inManagedObjectContext:self.managedObjectContext];
        if (modelNumberInt.integerValue == WatchModel_Move_C300_Android){
            modelNumberInt = @(WatchModel_Move_C300);
        }
        switch (modelNumberInt.integerValue) {
            case WatchModel_Move_C300:
                deviceName = WATCHNAME_MOVE_C300;
                break;
            case WatchModel_Zone_C410:
                deviceName = WATCHNAME_ZONE_C410;
                break;
            case WatchModel_R420:
                deviceName = WATCHNAME_R420;
                break;
            case WatchModel_R450:
                deviceName = WATCHNAME_BRITE_R450;
                break;
            default:
                deviceName = name;
                break;
        }
    }
    
    deviceEntity.uuid = uuid;
    
    if(!deviceEntity.name)
        deviceEntity.name = deviceName;
    
    deviceEntity.macAddress = macAddress;
    deviceEntity.modelNumberString = modelNumberString;
    deviceEntity.modelNumber = modelNumberInt;
    deviceEntity.lastDateSynced = [NSDate date];
    deviceEntity.updatedSynced = [NSDate date];
    deviceEntity.cloudSyncEnabled = [NSNumber numberWithBool:YES];
    
    return deviceEntity;
}

@end
