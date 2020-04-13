//
//  TimeDateEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "TimeDateEntity.h"

@interface TimeDateEntity (Data)

+ (TimeDateEntity *)timeDateWithTimeDate:(TimeDate *)timeDate forDeviceEntity:(DeviceEntity *)device;

@end
