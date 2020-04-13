//
//  CalibrationDataEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "CalibrationDataEntity.h"

@interface CalibrationDataEntity (Data)

+ (CalibrationDataEntity *)calibrationDataWithCalibrationData:(CalibrationData *)calibrationData forDeviceEntity:(DeviceEntity *)device;

@end
