//
//  Calibration_Data.h
//  BLEManager
//
//  Created by Kevin on 23/7/13.
//  Copyright (c) 2013 Salutron Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CalibrationData : NSObject

@property (assign, nonatomic) char type;                            // 0 - Step, 1 - Walk, 2 - Run
@property (assign, nonatomic) char calib_step;                      // 0-2
@property (assign, nonatomic) signed char calib_walk;               // -25 to +25
@property (assign, nonatomic) signed char calib_run;                // -25 to +25
@property (assign, nonatomic) bool autoEL;                          // 0 - autoEL Off, 1 - autoEL ON
@property (assign, nonatomic) signed char calib_calo;                // -25 to +25

@end
