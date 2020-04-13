//
//  TimingEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 9/9/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "TimingEntity+Data.h"
#import "DeviceEntity+Data.h"
#import "JDACoreData.h"

@implementation TimingEntity (Data)

+ (TimingEntity *)timingWithTiming:(Timing *)timing forDeviceEntity:(DeviceEntity *)device
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    
    if (!device.timing) {
        device.timing = [coreData insertNewObjectWithEntityName:TIMING_ENTITY];
    }
    
    
    device.timing.periodicInterval  = @(timing.periodic_interval);
    device.timing.scanTime          = @(timing.scan_time);
    device.timing.limitTime         = @(timing.limit_time);
    device.timing.smartForSleep     = @(timing.smartForSleep);
    device.timing.smartForWrist     = @(timing.smartForWrist);
    
    [coreData save];
    
    return device.timing;
}

@end
