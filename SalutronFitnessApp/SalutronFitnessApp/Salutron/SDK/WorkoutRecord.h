//
//  WorkoutRecord.h
//  BLEManager
//
//  Created by Leo Bellotindos on 18/8/15.
//  Copyright (c) 2015 Salutron Inc. All rights reserved.
//

#ifndef BLEManager_WorkoutRecord_h
#define BLEManager_WorkoutRecord_h

#import <Foundation/Foundation.h>

@interface WorkoutRecord : NSObject

@property (assign, nonatomic) char recordType;
@property (assign, nonatomic) char split_hundredths;
@property (assign, nonatomic) char split_second;
@property (assign, nonatomic) char split_minute;
@property (assign, nonatomic) char split_hour;

@property (assign, nonatomic) long steps;
@property (assign, nonatomic) double distance;
@property (assign, nonatomic) double calories;

@property (assign, nonatomic) char stop_hundredths;
@property (assign, nonatomic) char stop_second;
@property (assign, nonatomic) char stop_minute;
@property (assign, nonatomic) char stop_hour;

@property (assign, nonatomic) unsigned char HR1;
@property (assign, nonatomic) unsigned char HR2;
@property (assign, nonatomic) unsigned char HR3;
@property (assign, nonatomic) unsigned char HR4;
@property (assign, nonatomic) unsigned char HR5;
@property (assign, nonatomic) unsigned char HR6;
@property (assign, nonatomic) unsigned char HR7;
@property (assign, nonatomic) unsigned char HR8;

@end

#endif
