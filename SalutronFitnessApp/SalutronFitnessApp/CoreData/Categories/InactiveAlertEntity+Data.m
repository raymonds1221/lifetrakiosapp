//
//  InactiveAlertEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/2/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "InactiveAlertEntity+Data.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFAServerAccountManager.h"
#import "JDACoreData.h"
#import "DeviceEntity.h"

@implementation InactiveAlertEntity (Data)

+ (InactiveAlertEntity *)getInactiveAlert {
    
    SFASalutronFitnessAppDelegate *appDelegate = (SFASalutronFitnessAppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:INACTIVE_ALERT_ENTITY];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"device.macAddress == %@ AND device.user.userID == %@", [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(results.count > 0) {
        return (InactiveAlertEntity *)results[0];
    }
    
    return nil;
}

+ (InactiveAlertEntity *)inactiveAlertEntityForDeviceEntity:(DeviceEntity *)device
{
    if (!device.inactiveAlert) {
        JDACoreData *coreData   = [JDACoreData sharedManager];
        device.inactiveAlert    = [coreData insertNewObjectWithEntityName:INACTIVE_ALERT_ENTITY];
    }
    
    return device.inactiveAlert;
}

+ (InactiveAlertEntity *)inactiveAlertWithInactiveAlert:(InactiveAlert *)inactiveAlert forDeviceEntity:(DeviceEntity *)device
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    
    if (!device.inactiveAlert) {
        device.inactiveAlert  = [coreData insertNewObjectWithEntityName:INACTIVE_ALERT_ENTITY];
    }
    
    device.inactiveAlert.type = @(inactiveAlert.type);
    device.inactiveAlert.status = @(inactiveAlert.status);
    device.inactiveAlert.timeDuration = @(inactiveAlert.time_duration);
    device.inactiveAlert.stepsThreshold = @(inactiveAlert.steps_threshold);
    device.inactiveAlert.startMin = @(inactiveAlert.start_min);
    device.inactiveAlert.startHour = @(inactiveAlert.start_hour);
    device.inactiveAlert.endMin = @(inactiveAlert.end_min);
    device.inactiveAlert.endHour = @(inactiveAlert.end_hour);
    
    [coreData save];
    
    return device.inactiveAlert;
}




@end
