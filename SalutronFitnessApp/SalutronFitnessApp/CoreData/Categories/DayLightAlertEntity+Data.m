//
//  DayLightAlertEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/2/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "DayLightAlertEntity+Data.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFAServerAccountManager.h"
#import "JDACoreData.h"
#import "DeviceEntity.h"

@implementation DayLightAlertEntity (Data)

+ (DayLightAlertEntity *)getDayLightAlert {
    
    SFASalutronFitnessAppDelegate *appDelegate = (SFASalutronFitnessAppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:DAY_LIGHT_ALERT_ENTITY];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"device.macAddress == %@ AND device.user.userID == %@", [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(results.count > 0) {
        return (DayLightAlertEntity *)results[0];
    }
    
    return nil;
}

+ (NSInteger)getDayLightAlertThreshold
{
    DayLightAlertEntity *alert = [DayLightAlertEntity getDayLightAlert];
    
    switch (alert.level.integerValue) {
        case 0:
            return SFAAllLightDailyThresholdLow;
        case 1:
            return SFAAllLightDailyThresholdMed;
        case 2:
            return SFAAllLightDailyThresholdHigh;
        default:
            //default value based from pdf
            return SFAAllLightDailyThresholdMed;
    }
}

+ (NSString *)thresholdToString:(NSInteger)threshold
{
    if (threshold > 0 && threshold <= SFAAllLightDailyThresholdLow) {
        return LS_LOW_CAPS;
    }
    else if (threshold > SFAAllLightDailyThresholdLow && threshold <= SFAAllLightDailyThresholdMed) {
        return LS_MEDIUM_CAPS;
    }
    else if (threshold > SFAAllLightDailyThresholdMed && threshold <= SFAAllLightDailyThresholdHigh) {
        return LS_HIGH_CAPS;
    }
    else {
        return LS_HIGH_CAPS;
    }
}

+ (DayLightAlertEntity *)dayLightAlertEntityForDeviceEntity:(DeviceEntity *)device
{
    if (!device.dayLightAlert) {
        JDACoreData *coreData   = [JDACoreData sharedManager];
        device.dayLightAlert    = [coreData insertNewObjectWithEntityName:DAY_LIGHT_ALERT_ENTITY];
    }
    
    return device.dayLightAlert;
}

+ (DayLightAlertEntity *)dayLightAlertWithDayLightAlert:(DayLightAlert *)dayLightAlert forDeviceEntity:(DeviceEntity *)device
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    
    if (!device.dayLightAlert) {
        device.dayLightAlert  = [coreData insertNewObjectWithEntityName:DAY_LIGHT_ALERT_ENTITY];
    }
    
    device.dayLightAlert.type = @(dayLightAlert.type);
    device.dayLightAlert.status = @(dayLightAlert.status);
    device.dayLightAlert.level = @(dayLightAlert.level);
    device.dayLightAlert.duration = @(dayLightAlert.duration);
    device.dayLightAlert.startMin = @(dayLightAlert.start_min);
    device.dayLightAlert.startHour = @(dayLightAlert.start_hour);
    device.dayLightAlert.endMin = @(dayLightAlert.end_min);
    device.dayLightAlert.endHour = @(dayLightAlert.end_hour);
    device.dayLightAlert.interval = @(dayLightAlert.interval);
    device.dayLightAlert.levelLow = @(dayLightAlert.level_low);
    device.dayLightAlert.levelMid = @(dayLightAlert.level_mid);
    device.dayLightAlert.levelHigh = @(dayLightAlert.level_hi);
    
    [coreData save];
    
    return device.dayLightAlert;
}



@end
