//
//  InactiveAlertEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/2/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "InactiveAlertEntity.h"

@interface InactiveAlertEntity (Data)

+ (InactiveAlertEntity *)getInactiveAlert;
+ (InactiveAlertEntity *)inactiveAlertWithInactiveAlert:(InactiveAlert *)inactiveAlert forDeviceEntity:(DeviceEntity *)device;
+ (InactiveAlertEntity *)inactiveAlertEntityForDeviceEntity:(DeviceEntity *)device;
@end
