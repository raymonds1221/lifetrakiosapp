//
//  CalibrationData+CalibrationDataCategory.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/18/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "Calibration_Data.h"

#define TYPE        @"type"
#define CALIB_STEP  @"calib_step"
#define CALIB_WALK  @"calib_walk"
#define CALIB_RUN   @"calib_run"
#define CALIB_CALO  @"calib_calo"
#define AUTO_EL     @"auto_el"

@interface CalibrationData (CalibrationDataCategory) <NSCoding, NSCopying>

@end
