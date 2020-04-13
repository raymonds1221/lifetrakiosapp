//
//  Sleep_Setting.h
//  BLEManager
//
//  Created by Kevin on 23/7/13.
//  Copyright (c) 2013 Salutron Inc. All rights reserved.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    AUTO = 0,
    MANUAL,
} SleepMode;


@interface SleepSetting : NSObject

@property (assign, nonatomic) int sleep_goal_lo;                        //
@property (assign, nonatomic) int sleep_goal_hi;                        // sleep goal from 60 min to 899min
@property (assign, nonatomic) int sleep_mode;                           // 0 - 1

@end
