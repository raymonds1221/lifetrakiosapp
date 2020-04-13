//
//  NotificationEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NotificationEntity.h"

@class Notification;

@interface NotificationEntity (Data)

+ (NotificationEntity *)notificationWithNotification:(Notification *)notification notificationStatus:(BOOL)notificationStatus forDeviceEntity:(DeviceEntity *)device;

@end
