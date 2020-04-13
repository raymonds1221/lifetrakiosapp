//
//  NightLightAlertEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/2/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NightLightAlertEntity+Data.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFAServerAccountManager.h"
#import "JDACoreData.h"
#import "DeviceEntity.h"

@implementation NightLightAlertEntity (Data)

+ (NightLightAlertEntity *)getNightLightAlert {
    
    SFASalutronFitnessAppDelegate *appDelegate = (SFASalutronFitnessAppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NIGHT_LIGHT_ALERT_ENTITY];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(device.macAddress == %@) AND (device.user.userID == %@)", [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(results.count > 0) {
        return (NightLightAlertEntity *)results[0];
    }
    
    return nil;
}

+ (NSInteger)getNightLightAlertThreshold
{
    NightLightAlertEntity *alert = [NightLightAlertEntity getNightLightAlert];
    
    switch (alert.level.integerValue) {
        case 0:
            return SFABlueLightDailyThresholdLow;
        case 1:
            return SFABlueLightDailyThresholdMed;
        case 2:
            return SFABlueLightDailyThresholdHigh;
        default:
            //default value based from pdf
            return SFABlueLightDailyThresholdMed;
    }
}

+ (NSString *)thresholdToString:(NSInteger)threshold
{
    if (threshold > 0 && threshold <= SFABlueLightDailyThresholdLow) {
        return LS_LOW_CAPS;
    }
    else if (threshold > SFABlueLightDailyThresholdLow && threshold <= SFABlueLightDailyThresholdMed) {
        return LS_MEDIUM_CAPS;
    }
    else if (threshold > SFABlueLightDailyThresholdMed && threshold <= SFABlueLightDailyThresholdHigh) {
        return LS_HIGH_CAPS;
    }
    else {
        return LS_HIGH_CAPS;
    }
}

+ (NightLightAlertEntity *)nightLightAlertEntityForDeviceEntity:(DeviceEntity *)device
{
    if (!device.nightLightAlert) {
        JDACoreData *coreData   = [JDACoreData sharedManager];
        device.nightLightAlert    = [coreData insertNewObjectWithEntityName:NIGHT_LIGHT_ALERT_ENTITY];
    }
    
    return device.nightLightAlert;
}

+ (NightLightAlertEntity *)nightLightAlertWithNightLightAlert:(NightLightAlert *)nightLightAlert forDeviceEntity:(DeviceEntity *)device
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    
    if (!device.nightLightAlert) {
        device.nightLightAlert  = [coreData insertNewObjectWithEntityName:NIGHT_LIGHT_ALERT_ENTITY];
    }
    
    device.nightLightAlert.type = @(nightLightAlert.type);
    device.nightLightAlert.status = @(nightLightAlert.status);
    device.nightLightAlert.level = @(nightLightAlert.level);
    device.nightLightAlert.duration = @(nightLightAlert.duration);
    device.nightLightAlert.startMin = @(nightLightAlert.start_min);
    device.nightLightAlert.startHour = @(nightLightAlert.start_hour);
    device.nightLightAlert.endMin = @(nightLightAlert.end_min);
    device.nightLightAlert.endHour = @(nightLightAlert.end_hour);
    device.nightLightAlert.levelLow = @(nightLightAlert.level_low);
    device.nightLightAlert.levelMid = @(nightLightAlert.level_mid);
    device.nightLightAlert.levelHigh = @(nightLightAlert.level_hi);
    
    [coreData save];
    
    return device.nightLightAlert;
}

@end
