//
//  NotificationEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "JDACoreData.h"

#import "DeviceEntity.h"

#import "Notification.h"

#import "NotificationEntity+Data.h"

@implementation NotificationEntity (Data)

+ (NotificationEntity *)notificationWithNotification:(Notification *)notification notificationStatus:(BOOL)notificationStatus forDeviceEntity:(DeviceEntity *)device
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    
    if (!device.notification) {
        device.notification = [coreData insertNewObjectWithEntityName:NOTIFICATION_ENTITY];
    }
    
    device.notification.type                = @(notification.type);
    device.notification.simpleAlert         = @(notification.noti_simpleAlert);
    device.notification.email               = @(notification.noti_email);
    device.notification.news                = @(notification.noti_news);
    device.notification.incomingCall        = @(notification.noti_incomingCall);
    device.notification.missedCall          = @(notification.noti_missedCall);
    device.notification.sms                 = @(notification.noti_sms);
    device.notification.voiceMail           = @(notification.noti_voiceMail);
    device.notification.schedule            = @(notification.noti_schedule);
    device.notification.highPriority        = @(notification.noti_hightPrio);
    device.notification.social              = @(notification.noti_social);
    device.notification.notificationStatus  = @(notificationStatus);
    
    [coreData save];
    
    return device.notification;
}

@end
