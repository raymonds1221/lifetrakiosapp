//
//  InactiveAlert.h
//  BLEManager
//
//  Created by Kevin on 17/7/14.
//  Copyright (c) 2013 Salutron Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InactiveAlert : NSObject

@property (assign, nonatomic) unsigned char type;                           // 0 - Status 1 - Time Duration 2 - Steps Threshold 3 - Start Time 4 - End Time
@property (assign, nonatomic) unsigned char status;                         // 0 - inactive 1 - active
@property (assign, nonatomic) unsigned int time_duration;                   // 1 - 480 minutes
@property (assign, nonatomic) unsigned int steps_threshold;            // 1 - 999 steps
@property (assign, nonatomic) unsigned char start_hour;                     // 0 - 23
@property (assign, nonatomic) unsigned char start_min;                      // 0 - 59
@property (assign, nonatomic) unsigned char end_hour;                       // 0 - 23
@property (assign, nonatomic) unsigned char end_min;                        // 0 - 59
@end
