//
//  CalibrationDataEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "JDACoreData.h"

#import "DeviceEntity.h"

#import "CalibrationDataEntity+Data.h"

@implementation CalibrationDataEntity (Data)

+ (CalibrationDataEntity *)calibrationDataWithCalibrationData:(CalibrationData *)calibrationData forDeviceEntity:(DeviceEntity *)device
{
    JDACoreData *coreData = [JDACoreData sharedManager];
    
    if (!device.calibrationData) {
        device.calibrationData  = [coreData insertNewObjectWithEntityName:CALIBRATION_DATA_ENTITY];
    }
    
    device.calibrationData.type     = @(calibrationData.type);
    device.calibrationData.step     = @(calibrationData.calib_step);
    device.calibrationData.walk     = @(calibrationData.calib_walk);
    device.calibrationData.run      = @(calibrationData.calib_run);
    device.calibrationData.autoEL   = @(calibrationData.autoEL);
    device.calibrationData.calories = @(calibrationData.calib_calo);
    
    [coreData save];
    
    return device.calibrationData;
}

@end
