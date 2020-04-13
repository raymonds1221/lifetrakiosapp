//
//  Notification+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "Notification.h"

@class NotificationEntity;

@interface Notification (Data)

+ (Notification *)notification;
+ (Notification *)notificationWithDictionary:(NSDictionary *)dictionary;
+ (Notification *)notificationWithNotificationEntity:(NotificationEntity *)entity;

- (NSDictionary *)dictionary;
- (BOOL)isEqualToNotification:(Notification *)notification;

@end
