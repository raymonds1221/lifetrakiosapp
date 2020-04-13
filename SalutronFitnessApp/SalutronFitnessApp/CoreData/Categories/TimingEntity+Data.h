//
//  TimingEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 9/9/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "TimingEntity.h"

@interface TimingEntity (Data)

+ (TimingEntity *)timingWithTiming:(Timing *)timing forDeviceEntity:(DeviceEntity *)device;

@end
