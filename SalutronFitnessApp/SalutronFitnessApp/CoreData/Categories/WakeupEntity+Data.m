//
//  WakeupEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 2/6/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

//#import "NSDate+Format.h"

#import "JDACoreData.h"

#import "SFATimeTools.h"

#import "SFAServerAccountManager.h"

#import "WakeupEntity+Data.h"
#import "Wakeup+Entity.h"
#import "Wakeup+Data.h"
#import "SFASalutronFitnessAppDelegate.h"

@implementation WakeupEntity (Data)

- (instancetype)copyWithZone:(NSZone *)zone {
    id copy = [[[super class] alloc] init];
    
    [copy setWakeupMode:self.wakeupMode];
    [copy setWakeupHour:self.wakeupHour];
    [copy setWakeupMinute:self.wakeupMinute];
    [copy setWakeupWindow:self.wakeupWindow];
    [copy setSnoozeMode:self.snoozeMode];
    [copy setSnoozeMin:self.snoozeMin];
    [copy setDevice:self.device];
    
    return copy;
}

+ (BOOL) addWakeupEntityWithDevice:(DeviceEntity *)device
                        macAddress:(NSString *)macAddress
                        wakeupMode:(NSNumber *)wakeUpMode
                        wakeupHour:(NSNumber *)wakeupHour
                      wakeupMinute:(NSNumber *)wakeupMinute
                      wakeupWindow:(NSNumber *)wakeupWindow
                        snoozeMode:(NSNumber *)snoozeMode
                         snoozeMin:(NSNumber *)snoozeMin
                     managedObject:(NSManagedObjectContext *)managedObject
                      wakeupEntity:(WakeupEntity *__autoreleasing *)wakeup
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:WAKEUP_ENTITY];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"device.macAddress == %@ AND device.user.userID == %@", macAddress, [SFAServerAccountManager sharedManager].user.userID];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [managedObject executeFetchRequest:fetchRequest error:&error];
    WakeupEntity *wakeupEntity = nil;
    
    if(results.count > 0) {
        wakeupEntity = (WakeupEntity *) results[0];
    } else {
        wakeupEntity = [NSEntityDescription insertNewObjectForEntityForName:WAKEUP_ENTITY
                                                     inManagedObjectContext:managedObject];
    }
    
    wakeupEntity.wakeupMode = wakeUpMode;
    wakeupEntity.wakeupHour = wakeupHour;
    wakeupEntity.wakeupMinute = wakeupMinute;
    wakeupEntity.wakeupWindow = wakeupWindow;
    wakeupEntity.snoozeMode = snoozeMode;
    wakeupEntity.snoozeMin = snoozeMin;
    
    device.wakeup = wakeupEntity;
    
    if([managedObject save:&error]) {
        if(error == nil) {
            *wakeup = wakeupEntity;
            return YES;
        } else {
            DDLogError(@"error: %@", [error localizedDescription]);
        }
    }
    
    return NO;
}

+ (WakeupEntity *)getWakeup {
    SFASalutronFitnessAppDelegate *appDelegate = (SFASalutronFitnessAppDelegate *)[UIApplication sharedApplication].delegate;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:WAKEUP_ENTITY];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"device.macAddress == %@ AND device.user.userID == %@", [userDefaults objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if(results.count > 0) {
        return (WakeupEntity *)results[0];
    }
    
    return nil;
}

+ (WakeupEntity *)wakeupEntityForDeviceEntity:(DeviceEntity *)device
{
    if (!device.wakeup) {
        JDACoreData *coreData   = [JDACoreData sharedManager];
        device.wakeup           = [coreData insertNewObjectWithEntityName:WAKEUP_ENTITY];
    }
    
    return device.wakeup;
}

+ (WakeupEntity *)wakeupEntityWithDictionary:(NSDictionary *)dictionary forDeviceEntity:(DeviceEntity *)device
{
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        NSString *wakeupTimeString      = [dictionary objectForKey:API_WAKEUP_INFO_WAKEUP_TIME];
        NSDateFormatter *dateFormatter  = [NSDateFormatter new];
        dateFormatter.dateFormat        = API_TIME_FORMAT;
        NSDate *wakeupTime              = [dateFormatter dateFromString:wakeupTimeString];
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:wakeupTime];
        
        JDACoreData *coreData   = [JDACoreData sharedManager];
        WakeupEntity *wakeup    = [coreData insertNewObjectWithEntityName:WAKEUP_ENTITY];
        wakeup.wakeupMode       = @([[dictionary objectForKey:API_WAKEUP_INFO_WAKEUP_MODE] integerValue]);
        wakeup.wakeupHour       = @(dateComponents.hour);
        wakeup.wakeupMinute     = @(dateComponents.minute);
        wakeup.wakeupWindow     = @([[dictionary objectForKey:API_WAKEUP_INFO_WAKEUP_WINDOW] integerValue]);
        wakeup.snoozeMode       = @([[dictionary objectForKey:API_WAKEUP_INFO_SNOOZE_MODE] integerValue]);
        wakeup.snoozeMin        = @([[dictionary objectForKey:API_WAKEUP_INFO_SNOOZE_MIN] integerValue]);
        wakeup.device           = device;
        device.wakeup           = wakeup;
        
        if ([[Wakeup alloc] respondsToSelector:@selector(initWithEntity:)]) {
            [SFAUserDefaultsManager sharedManager].wakeUp = [[Wakeup alloc] initWithEntity:wakeup];
        }
        else{
            [SFAUserDefaultsManager sharedManager].wakeUp = [Wakeup wakeupDefaultValues];
        }
        
        return wakeup;
    }
    
    return nil;
}

- (NSDictionary *)dictionary
{
    /*@property (nonatomic, retain) NSNumber * wakeupMode;
    @property (nonatomic, retain) NSNumber * wakeupHour;
    @property (nonatomic, retain) NSNumber * wakeupMinute;
    @property (nonatomic, retain) NSNumber * wakeupWindow;
    @property (nonatomic, retain) NSNumber * snoozeMode;
    @property (nonatomic, retain) NSNumber * snoozeMin;
    @property (nonatomic, retain) DeviceEntity *device;*/
    
    NSString *timeString        = [SFATimeTools timeStringWithHour:self.wakeupHour minute:self.wakeupMinute second:@(0)];
    NSDictionary *dictionary    = @{API_WAKEUP_INFO_SNOOZE_MIN      : self.snoozeMin,
                                    API_WAKEUP_INFO_SNOOZE_MODE     : self.snoozeMode,
                                    API_WAKEUP_INFO_WAKEUP_TIME     : timeString,
                                    API_WAKEUP_INFO_WAKEUP_MODE     : self.wakeupMode,
                                    API_WAKEUP_INFO_WAKEUP_WINDOW   : self.wakeupWindow,
                                    API_WAKEUP_INFO_WAKEUP_TYPE     : @(0)};
    
    return dictionary;
}

+ (WakeupEntity *)wakeupWithWakeup:(Wakeup *)wakeup forDeviceEntity:(DeviceEntity *)device
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    
    if (!device.wakeup) {
        device.wakeup  = [coreData insertNewObjectWithEntityName:WAKEUP_ENTITY];
    }
    else{
        device.wakeup = [WakeupEntity getWakeup];
    }
    
    device.wakeup.wakeupMode       = @(wakeup.wakeup_mode);
    device.wakeup.wakeupHour       = @(wakeup.wakeup_hr);
    device.wakeup.wakeupMinute     = @(wakeup.wakeup_min);
    device.wakeup.wakeupWindow     = @(wakeup.wakeup_window);
    device.wakeup.snoozeMode       = @(wakeup.snooze_mode);
    device.wakeup.snoozeMin        = @(wakeup.snooze_min);
    //device.wakeup.device           = device;
    //device.wakeup                  = wakeup;
    
    [coreData save];
    
    return device.wakeup;
}

@end
