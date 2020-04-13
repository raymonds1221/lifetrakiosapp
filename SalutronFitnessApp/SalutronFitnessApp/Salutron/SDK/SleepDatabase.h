//
//  SleepDatabase.h
//  BLEManager
//
//  Created by Kevin on 7/18/13.
//  Copyright (c) 2013 Salutron Inc. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "SH_Date.h"

@interface SleepDatabase : NSObject

@property (strong, nonatomic) SH_Date *date;
@property (assign, nonatomic) int sleep_start_min;
@property (assign, nonatomic) int sleep_start_hr;
@property (assign, nonatomic) int sleep_end_min;
@property (assign, nonatomic) int sleep_end_hr;
@property (assign, nonatomic) int lapses;               // 0 - 255
@property (assign, nonatomic) int deepsleepcount;       // 0 - 65535
@property (assign, nonatomic) int lightsleepcount;      // 0 - 65535
@property (assign, nonatomic) int sleepoffset;          // 0 - 255
@property (assign, nonatomic) int extra_info;           //
@property (assign, nonatomic) int sleepduration;       //

@end
