//
//  DayLightAlert.h
//  BLEManager
//
//  Created by Kevin on 7/8/14.
//  Copyright (c) 2013 Salutron Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DayLightAlert : NSObject

@property (assign, nonatomic) unsigned char type;                   // 0 - Status 1 - level 2 - duration 3 - Start Time 4 - End Time 5 - interval
@property (assign, nonatomic) unsigned char status;                 // 0 - inactive 1 - active (default Inactive)
@property (assign, nonatomic) unsigned char level;                   // 0 - Low 1 - Medium 2 - High (default Medium)
@property (assign, nonatomic) unsigned char duration;                // 10 - 60 minutes (default 30)
@property (assign, nonatomic) unsigned char start_hour;             // 0 - 23
@property (assign, nonatomic) unsigned char start_min;              // 0 - 59
@property (assign, nonatomic) unsigned char end_hour;               // 0 - 23
@property (assign, nonatomic) unsigned char end_min;                // 0 - 59
@property (assign, nonatomic) unsigned char interval;                // 5 - 120 minutes (default 60)

@property (assign, nonatomic) unsigned int level_low;
@property (assign, nonatomic) unsigned int level_mid;
@property (assign, nonatomic) unsigned int level_hi;

@end
