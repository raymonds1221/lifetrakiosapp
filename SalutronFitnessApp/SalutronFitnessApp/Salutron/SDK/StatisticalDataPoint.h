//
//  StatisticalDataPoint.h
//  BLEManager
//
//  Created by Herman on 2/25/13.
//  Copyright (c) 2013 GV Concepts Inc. All rights reserved.
//
//  All information and materials contained herein are owned by GV Concepts, Inc.
//  and is protected by U.S. and international copyright laws.
//  All use, disclosure, dissemination, transfer, publication or reproduction
//  of these materials, in whole or in part, is prohibited, unless authorized
//  in writing by GV Concepts, Inc.
//  If copies of these materials are made with written authorization of
//  GV Concepts, Inc, all copies must contain this notice.
//

#import <Foundation/Foundation.h>

@interface StatisticalDataPoint : NSObject

@property (assign, nonatomic) int averageHR;    // 40 - 240 (bpm) or 0
@property (assign, nonatomic) double distance;  // 0.0 - 40.95
@property (assign, nonatomic) int steps;        // 0 - 4095
@property (assign, nonatomic) double calorie;   // 0 - 6553.5
@property (assign, nonatomic) char sleeppoint_0_2;  // 0 - 127
@property (assign, nonatomic) char sleeppoint_2_4;  // 0 - 127
@property (assign, nonatomic) char sleeppoint_4_6;  // 0 - 127
@property (assign, nonatomic) char sleeppoint_6_8;  // 0 - 127
@property (assign, nonatomic) char sleeppoint_8_10;  // 0 - 127
@property (assign, nonatomic) char dominant_axis;    // 0 - 3
@property (assign, nonatomic) char axis_direction;      //0-1
@property (assign, nonatomic) char axis_magnitude;      //0-1
@property (assign, nonatomic) bool wrist_detection;      //0 : OFF,  1 : Active
@property (assign, nonatomic) bool ble_status;           //0 : OFF,  1 : Active
//@property (assign, nonatomic) NSData *rawData;           //

@end
