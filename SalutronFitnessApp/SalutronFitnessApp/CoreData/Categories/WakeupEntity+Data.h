//
//  WakeupEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 2/6/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "WakeupEntity.h"
#import "DeviceEntity+Data.h"

@interface WakeupEntity (Data)<NSCopying>

+(BOOL) addWakeupEntityWithDevice:(DeviceEntity *)device
                       macAddress:(NSString *)macAddress
                       wakeupMode:(NSNumber *)wakeUpMode
                       wakeupHour:(NSNumber *)wakeupHour
                     wakeupMinute:(NSNumber *)wakeupMinute
                     wakeupWindow:(NSNumber *)wakeupWindow
                       snoozeMode:(NSNumber *)snoozeMode
                        snoozeMin:(NSNumber *)snoozeMin
                    managedObject:(NSManagedObjectContext *)managedObject
                     wakeupEntity:(WakeupEntity **)wakeup;

+(WakeupEntity *) getWakeup;
+ (WakeupEntity *)wakeupEntityForDeviceEntity:(DeviceEntity *)device;
+ (WakeupEntity *)wakeupEntityWithDictionary:(NSDictionary *)dictionary forDeviceEntity:(DeviceEntity *)device;
+ (WakeupEntity *)wakeupWithWakeup:(Wakeup *)wakeup forDeviceEntity:(DeviceEntity *)device;
- (NSDictionary *)dictionary;

@end
