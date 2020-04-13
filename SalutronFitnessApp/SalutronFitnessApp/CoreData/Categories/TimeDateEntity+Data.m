//
//  TimeDateEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "JDACoreData.h"

#import "DeviceEntity.h"

#import "TimeDateEntity+Data.h"

@implementation TimeDateEntity (Data)

+ (TimeDateEntity *)timeDateWithTimeDate:(TimeDate *)timeDate forDeviceEntity:(DeviceEntity *)device
{
    // Date
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.month                = timeDate.date.month;
    components.day                  = timeDate.date.day;
    components.year                 = timeDate.date.year + DATE_YEAR_ADDER;
    components.hour                 = timeDate.time.hour;
    components.minute               = timeDate.time.minute;
    components.second               = timeDate.time.second;
    NSDate *date                    = [calendar dateFromComponents:components];
    JDACoreData *coreData           = [JDACoreData sharedManager];
    
    if (!device.timeDate) {
        device.timeDate = [coreData insertNewObjectWithEntityName:TIME_DATE_ENTITY];
    }
    
    device.timeDate.date        = date;
    device.timeDate.hourFormat  = @(timeDate.hourFormat);
    device.timeDate.dateFormat  = @(timeDate.dateFormat);
    device.timeDate.watchFace   = @(timeDate.watchFace);
    
    DDLogInfo(@"----------> TIMEDATE : %@", device.timeDate);
    
    [coreData save];
    
    return device.timeDate;
}

@end
