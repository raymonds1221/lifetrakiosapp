//
//  SFAWatchManager.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAWatchManager.h"

@interface SFAWatchManager ()

@property (strong, nonatomic) UILocalNotification *localNotification;

@end

@implementation SFAWatchManager

#pragma mark - Singleton Instance

+ (SFAWatchManager *)sharedManager
{
    static SFAWatchManager *instance = nil;
    
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

- (UILocalNotification *)localNotification
{
    if (!_localNotification) {
        _localNotification = [[UILocalNotification alloc] init];
    }
    return _localNotification;
}

#pragma mark - Private Methods

- (void)scheduleAutoSyncNotificationForTimeStamp:(NSNumber *)timestamp
{
    WatchModel watchModel        = [SFAUserDefaultsManager sharedManager].watchModel;
    
    if (timestamp && watchModel == WatchModel_R450) {
        NSUserDefaults *userDefaults            = [NSUserDefaults standardUserDefaults];
        NSString *macAddress                    = [userDefaults objectForKey:MAC_ADDRESS];
        NSDate *date                            = [NSDate dateWithTimeIntervalSince1970:timestamp.integerValue];
        self.localNotification.alertBody             = SYNC_NOTIFICATION_MESSAGE;
        self.localNotification.timeZone              = [NSTimeZone localTimeZone];
        self.localNotification.repeatInterval        = NSCalendarUnitDay; //NSWeekCalendarUnit
        self.localNotification.fireDate              = date;
        //localNotification.alertAction           = @"Slide to start sync.";
        self.localNotification.userInfo              = @{ MAC_ADDRESS : macAddress };
        
        
        SyncSetupOption syncSetupOption = [[userDefaults objectForKey:AUTO_SYNC_OPTION] intValue];
        if (syncSetupOption == SyncSetupOptionOnceAWeek) {
            
            NSInteger selectedIndex = 2;
            if ([userDefaults objectForKey:AUTO_SYNC_TIME_WEEKLY]) {
                if ([[self arrayDaysOfWeekFull] containsObject:[userDefaults objectForKey:AUTO_SYNC_TIME_WEEKLY]]) {
                    selectedIndex = [[self arrayDaysOfWeekFull] indexOfObject:[userDefaults objectForKey:AUTO_SYNC_TIME_WEEKLY]];
                }
                else if ([[self arrayDaysOfWeek] containsObject:[userDefaults objectForKey:AUTO_SYNC_TIME_WEEKLY]]){
                selectedIndex = [[self arrayDaysOfWeek] indexOfObject:[userDefaults objectForKey:AUTO_SYNC_TIME_WEEKLY]];
                }
            }
            
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            calendar.timeZone = [NSTimeZone localTimeZone];
            NSInteger wantedWeekday = selectedIndex; //2 Monday
            NSDateComponents *components = [calendar components: NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:date];
            
            components.day += wantedWeekday - components.weekday;
            components.weekday = wantedWeekday;
            components.hour = [components hour];
            components.minute = [components minute];
            NSDate *fire = [calendar dateFromComponents:components];
            self.localNotification.fireDate              = fire;

            self.localNotification.repeatInterval = NSWeekCalendarUnit;
        }
        
        DDLogInfo(@"self.localNotification = %@", self.localNotification);
        [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotification];
    }
}

#pragma mark - Public Methods

- (void)rescheduleAutoSyncNotifications
{
    if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        if([userDefaults boolForKey:AUTO_SYNC_ALERT] == YES) {
            
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSNumber *autoSyncTimestamp1 = [userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_1];
            
            [self scheduleAutoSyncNotificationForTimeStamp:autoSyncTimestamp1];
        }
    }
}


- (void)disableAutoSync
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:AUTO_SYNC_ALERT];
    [userDefaults synchronize];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)enableAutoSync
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:AUTO_SYNC_ALERT];
    [userDefaults synchronize];
}

- (NSArray *)arrayDaysOfWeek{
    return @[@"", @"", LS_MON, LS_TUE, LS_WED, LS_THU, LS_FRI, LS_SAT, LS_SUN];
}

- (NSArray *)arrayDaysOfWeekFull{
    return @[@"", @"", LS_MONDAY, LS_TUESDAY, LS_WEDNESDAY, LS_THURSDAY, LS_FRIDAY, LS_SATURDAY, LS_SUNDAY];
}

@end
