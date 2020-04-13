//
//  NightLightAlertEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/2/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NightLightAlertEntity.h"

@interface NightLightAlertEntity (Data)

+ (NSInteger)getNightLightAlertThreshold;
+ (NightLightAlertEntity *)getNightLightAlert;
+ (NightLightAlertEntity *)nightLightAlertWithNightLightAlert:(NightLightAlert *)nightLightAlert forDeviceEntity:(DeviceEntity *)device;
+ (NSString *)thresholdToString:(NSInteger)threshold;
+ (NightLightAlertEntity *)nightLightAlertEntityForDeviceEntity:(DeviceEntity *)device;
@end
