//
//  CalibrationData+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "Calibration_Data.h"

@class CalibrationDataEntity;

@interface CalibrationData (Data)

+ (CalibrationData *)calibrationData;
+ (CalibrationData *)calibrationDataWithDictionary:(NSDictionary *)dictionary;
+ (CalibrationData *)calibrationDataWithCalibrationDataEntity:(CalibrationDataEntity *)entity;

- (NSDictionary *)dictionary;

@end
