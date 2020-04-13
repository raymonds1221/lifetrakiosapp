//
//  TimeDate.h
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

typedef enum {
    _12_HOUR = 0,
    _24_HOUR,
} HourFormat;

typedef enum {
    _DDMM = 0,
    _MMDD,
    _DDMMM,
    _MMMDD,
    _100,
    _101,
    _110,
    _111,
} DateFormat;       //kevin 3 May

typedef enum {
    _SIMPLE = 1,
    _FULL,
} WatchFace;

@interface TimeDate : NSObject

@property (strong, nonatomic) SH_Time *time;
@property (strong, nonatomic) SH_Date *date;
@property (assign, nonatomic) HourFormat hourFormat;   // 0 – 12 Hour / 1 – 24 Hour     //kevin 30/4
@property (assign, nonatomic) DateFormat dateFormat;   // 0 – DDMM / 1 – MMDD  / 2 - DDMMM / 3 - MMMDD / 4~ 7 reserved        //kevin 28 Jan 2014
@property (assign, nonatomic) WatchFace watchFace;      // 0 - Simple / 1 - Full    // kevin 28 Jan 2014

- (id)initWithDate:(NSDate *)nsDate;

@end
