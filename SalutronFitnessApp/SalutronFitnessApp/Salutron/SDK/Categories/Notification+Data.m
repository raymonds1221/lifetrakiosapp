//
//  Notification+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NotificationEntity.h"

#import "Notification+Data.h"
#import "SFAUserDefaultsManager.h"

@implementation Notification (Data)

#pragma mark - Private Methods

#pragma mark - Public Methods

+ (Notification *)notification
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSData *data                    = [userDefaults dataForKey:NOTIFICATION];
    Notification *notification      = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (!notification) {
        notification = [[Notification alloc] init];
    }
    
    return notification;
}

+ (Notification *)notificationWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        NSString *simpleAlertString     = [dictionary objectForKey:API_DEVICE_SETTINGS_NOTI_SIMPLE_ALERT];
        NSString *emailString           = [dictionary objectForKey:API_DEVICE_SETTINGS_NOTI_EMAIL];
        NSString *newsString            = [dictionary objectForKey:API_DEVICE_SETTINGS_NOTI_NEWS];
        NSString *incomingCallString    = [dictionary objectForKey:API_DEVICE_SETTINGS_NOTI_INCOMING_CALL];
        NSString *missedCallString      = [dictionary objectForKey:API_DEVICE_SETTINGS_NOTI_MISSED_CALL];
        NSString *smsString             = [dictionary objectForKey:API_DEVICE_SETTINGS_NOTI_SMS];
        NSString *voiceMailString       = [dictionary objectForKey:API_DEVICE_SETTINGS_NOTI_VOICE_MAIL];
        NSString *schedulesString       = [dictionary objectForKey:API_DEVICE_SETTINGS_NOTI_SCHEDULES];
        NSString *highPrioString        = [dictionary objectForKey:API_DEVICE_SETTINGS_NOTI_HIGH_PRIO];
        NSString *socialString          = [dictionary objectForKey:API_DEVICE_SETTINGS_NOTI_SOCIAL];
        
        NSNumber *notificationStatus    = [dictionary objectForKey:API_DEVICE_SETTINGS_NOTI_STATUS];
        [SFAUserDefaultsManager sharedManager].notificationStatus = notificationStatus.boolValue;
        
        Notification *notification      = [[Notification alloc] init];
        notification.noti_simpleAlert   = [simpleAlertString boolValue];
        notification.noti_email         = [emailString boolValue];
        notification.noti_news          = [newsString boolValue];
        notification.noti_incomingCall  = [incomingCallString boolValue];
        notification.noti_missedCall    = [missedCallString boolValue];
        notification.noti_sms           = [smsString boolValue];
        notification.noti_voiceMail     = [voiceMailString boolValue];
        notification.noti_schedule      = [schedulesString boolValue];
        notification.noti_hightPrio     = [highPrioString boolValue];
        notification.noti_social        = [socialString boolValue];
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:notification];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:data forKey:NOTIFICATION];
        
        return notification;
    }
    return nil;
}

- (BOOL)isEqualToNotification:(Notification *)notification
{
    if (self.type == notification.type &&
        self.noti_simpleAlert == notification.noti_simpleAlert &&
        self.noti_email == notification.noti_email &&
        self.noti_news == notification.noti_news &&
        self.noti_incomingCall == notification.noti_incomingCall &&
        self.noti_missedCall == notification.noti_missedCall &&
        self.noti_sms == notification.noti_sms &&
        self.noti_voiceMail == notification.noti_voiceMail &&
        self.noti_schedule == notification.noti_schedule &&
        self.noti_hightPrio == notification.noti_hightPrio &&
        self.noti_social == notification.noti_social) {
        return YES;
    }
    return NO;
}

+ (Notification *)notificationWithNotificationEntity:(NotificationEntity *)entity
{
    Notification *notification      = [Notification new];
    notification.type               = (char)entity.type.integerValue;
    notification.noti_simpleAlert   = entity.simpleAlert.boolValue;
    notification.noti_email         = entity.email.boolValue;
    notification.noti_news          = entity.news.boolValue;
    notification.noti_incomingCall  = entity.incomingCall.boolValue;
    notification.noti_missedCall    = entity.missedCall.boolValue;
    notification.noti_sms           = entity.sms.boolValue;
    notification.noti_voiceMail     = entity.voiceMail.boolValue;
    notification.noti_schedule      = entity.schedule.boolValue;
    notification.noti_hightPrio     = entity.highPriority.boolValue;
    notification.noti_social        = entity.social.boolValue;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:notification];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:data forKey:NOTIFICATION];
    
    return notification;
}

- (NSDictionary *)dictionary
{
    
    NSDictionary *dictionary = @{API_DEVICE_SETTINGS_NOTI_STATUS        : @([SFAUserDefaultsManager sharedManager].notificationStatus),
                                 API_DEVICE_SETTINGS_NOTI_SIMPLE_ALERT  : @(self.noti_simpleAlert),
                                 API_DEVICE_SETTINGS_NOTI_EMAIL         : @(self.noti_email),
                                 API_DEVICE_SETTINGS_NOTI_NEWS          : @(self.noti_news),
                                 API_DEVICE_SETTINGS_NOTI_INCOMING_CALL : @(self.noti_incomingCall),
                                 API_DEVICE_SETTINGS_NOTI_MISSED_CALL   : @(self.noti_missedCall),
                                 API_DEVICE_SETTINGS_NOTI_SMS           : @(self.noti_sms),
                                 API_DEVICE_SETTINGS_NOTI_VOICE_MAIL    : @(self.noti_voiceMail),
                                 API_DEVICE_SETTINGS_NOTI_SCHEDULES     : @(self.noti_schedule),
                                 API_DEVICE_SETTINGS_NOTI_HIGH_PRIO     : @(self.noti_hightPrio),
                                 API_DEVICE_SETTINGS_NOTI_SOCIAL        : @(self.noti_social)};
    
    return dictionary;
}

@end
