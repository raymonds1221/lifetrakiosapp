//
//  DayLightAlertEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/2/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "DayLightAlertEntity.h"

@interface DayLightAlertEntity (Data)

+ (DayLightAlertEntity *)getDayLightAlert;
+ (NSInteger)getDayLightAlertThreshold;
+ (DayLightAlertEntity *)dayLightAlertWithDayLightAlert:(DayLightAlert *)dayLightAlert forDeviceEntity:(DeviceEntity *)device;
+ (NSString *)thresholdToString:(NSInteger)threshold;
+ (DayLightAlertEntity *)dayLightAlertEntityForDeviceEntity:(DeviceEntity *)device;

@end
