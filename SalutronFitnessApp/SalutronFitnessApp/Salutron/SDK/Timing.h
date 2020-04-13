//
//  Timing.h
//  BLEManager
//
//  Created by Kevin on 04/07/14.
//  Copyright (c) 2013 Salutron Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Timing : NSObject

@property (assign, nonatomic) unsigned char type;                            //
@property (assign, nonatomic) int periodic_interval;        // 1-60 min
@property (assign, nonatomic) int scan_time;                // 5-60 sec
@property (assign, nonatomic) int limit_time;               // 60-1440 min
@property (assign, nonatomic) BOOL smartForSleep;            // (0-Disable 1-Enable)
@property (assign, nonatomic) BOOL smartForWrist;            // (0-Disable 1-Enable)
@end
