//
//  Wakeup+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFATimeTools.h"

#import "NSDate+Format.h"

#import "Wakeup+Data.h"

@implementation Wakeup (Data)

#pragma mark - Public Methods

+ (Wakeup *)wakeup
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSData *data                    = [userDefaults dataForKey:WAKEUP_KEY];
    Wakeup *wakeup                  = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (!wakeup) {
        wakeup = [[Wakeup alloc] init];
    }
    
    return wakeup;
}

+ (Wakeup *)wakeupDefaultValues
{
    Wakeup *wakeup = [[Wakeup alloc] init];
    wakeup.snooze_min       = 0;
    wakeup.snooze_mode      = 0;
    wakeup.wakeup_hr        = 9;
    wakeup.wakeup_min       = 0;
    wakeup.wakeup_mode      = 0;
    wakeup.wakeup_window    = 0;
    wakeup.type             = 0;
    return wakeup;
}

+ (Wakeup *)wakeupWithDictionary:(NSDictionary *)dictionary
{
    NSString *snoozeMinString       = [dictionary objectForKey:API_WAKEUP_INFO_SNOOZE_MIN];
    NSString *snoozeModeString      = [dictionary objectForKey:API_WAKEUP_INFO_SNOOZE_MODE];
    NSString *wakeupTimeString      = [dictionary objectForKey:API_WAKEUP_INFO_WAKEUP_TIME];
    NSString *wakeupModeString      = [dictionary objectForKey:API_WAKEUP_INFO_WAKEUP_MODE];
    NSString *wakeupWindowString    = [dictionary objectForKey:API_WAKEUP_INFO_WAKEUP_WINDOW];
    NSString *wakeupTypeString      = [dictionary objectForKey:API_WAKEUP_INFO_WAKEUP_TYPE];
    NSDate *wakeupTime              = [NSDate dateFromString:wakeupTimeString withFormat:API_TIME_FORMAT];
    
    Wakeup *wakeup          = [[Wakeup alloc] init];
    wakeup.snooze_min       = [snoozeMinString characterAtIndex:0];
    wakeup.snooze_mode      = snoozeModeString.integerValue;
    wakeup.wakeup_hr        = wakeupTime.dateComponents.hour;
    wakeup.wakeup_min       = wakeupTime.dateComponents.minute;
    wakeup.wakeup_mode      = wakeupModeString.integerValue;
    wakeup.wakeup_window    = [wakeupWindowString characterAtIndex:0];
    wakeup.type             = [wakeupTypeString characterAtIndex:0];
    /*
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:wakeup];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:WAKEUP_KEY];
    */
    [SFAUserDefaultsManager sharedManager].wakeUp = wakeup;
    
    return wakeup;
}

- (NSDictionary *)dictionary
{
    NSString *timeString        = [SFATimeTools timeStringWithHour:@(self.wakeup_hr) minute:@(self.wakeup_min) second:@(0)];
    NSDictionary *dictionary    = @{API_WAKEUP_INFO_SNOOZE_MIN      : @(self.snooze_min),
                                    API_WAKEUP_INFO_SNOOZE_MODE     : @(self.snooze_mode),
                                    API_WAKEUP_INFO_WAKEUP_TIME     : timeString,
                                    API_WAKEUP_INFO_WAKEUP_MODE     : @(self.wakeup_mode),
                                    API_WAKEUP_INFO_WAKEUP_WINDOW   : @(self.wakeup_window),
                                    API_WAKEUP_INFO_WAKEUP_TYPE     : @(self.type)};
    
    return dictionary;
}

- (BOOL)isEqualToWakeupAlert:(Wakeup *)wakeup
{
    if (self.wakeup_mode == wakeup.wakeup_mode && self.wakeup_hr == wakeup.wakeup_hr && self.wakeup_min == wakeup.wakeup_min && self.wakeup_window == wakeup.wakeup_window && self.snooze_mode == wakeup.snooze_mode && self.snooze_min == wakeup.snooze_min) {
        return YES;
    }
    return NO;
}

@end
