//
//  Wakeup.h
//  BLEManager
//
//  Created by Kevin on 18/10/13.
//  Copyright (c) 2013 Salutron Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WAKEUP_ON = 0,
    WAKEUP_OFF,
} WakeupMode;

typedef enum {
    SNOOZE_ON = 0,
    SNOOZE_OFF,
} SnoozeMode;

@interface Wakeup : NSObject

@property (assign, nonatomic) unsigned char type;                            //
@property (assign, nonatomic) int wakeup_mode;                      // 0-2
@property (assign, nonatomic) unsigned char wakeup_hr;               //
@property (assign, nonatomic) unsigned char wakeup_min;                //
@property (assign, nonatomic) unsigned char wakeup_window;                //
@property (assign, nonatomic) int snooze_mode;                      // 0-2
@property (assign, nonatomic) unsigned char snooze_min;                //

@end
