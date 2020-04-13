//
//  NotificationEntity.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 9/9/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DeviceEntity;

@interface NotificationEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * email;
@property (nonatomic, retain) NSNumber * highPriority;
@property (nonatomic, retain) NSNumber * incomingCall;
@property (nonatomic, retain) NSNumber * missedCall;
@property (nonatomic, retain) NSNumber * news;
@property (nonatomic, retain) NSNumber * schedule;
@property (nonatomic, retain) NSNumber * simpleAlert;
@property (nonatomic, retain) NSNumber * sms;
@property (nonatomic, retain) NSNumber * social;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * voiceMail;
@property (nonatomic, retain) NSNumber * notiStatus;
@property (nonatomic, retain) NSNumber * notificationStatus;
@property (nonatomic, retain) DeviceEntity *device;

@end
