//
//  StatisticalDataHeader.h
//  BLEManager
//
//  Created by Herman on 2/21/13.
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
#import "SH_Date.h"
#import "SH_Time.h"

@interface StatisticalDataHeader : NSObject

@property (strong, nonatomic) SH_Date *date;
@property (strong, nonatomic) SH_Time *startTime;
@property (strong, nonatomic) SH_Time *endTime;
@property (assign, nonatomic) int allocationBlockIndex; // 2 - 9
@property (assign, nonatomic) int totalSteps;           // 0 - 99999
@property (assign, nonatomic) double totalDistance;     // 0 - 999.99 (km)
@property (assign, nonatomic) double totalCalorie;      // 0 - 99999.9
@property (assign, nonatomic) int totalSleep;           // in minute
@property (assign, nonatomic) int minHR;                // MIN heartrate
@property (assign, nonatomic) int maxHR;                // MAX heartrate
@property (assign, nonatomic) int totalExposureTime;    // Exposure Time
@end
