//
//  WeightInfo.h
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
#import "SH_Date.h"
#import "SH_Time.h"

@interface WeightInfo : NSObject

@property (strong, nonatomic) SH_Time *time;
@property (strong, nonatomic) SH_Date *date;
@property (assign, nonatomic) int weight;   // 40 - 440 (lbs)

@end
