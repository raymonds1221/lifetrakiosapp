//
//  WorkoutInfo.h
//  BLEManager
//
//  Created by Kevin on 31/7/13.
//  Copyright (c) 2013 Salutron Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkoutInfo : NSObject

@property (assign, nonatomic) bool distance_unit_flag;      // 0 - imperial; 1 - metric
@property (assign, nonatomic) char workoutID;
@property (assign, nonatomic) char stamp_second;
@property (assign, nonatomic) char stamp_minute;
@property (assign, nonatomic) char stamp_hour;
@property (assign, nonatomic) char stamp_day;
@property (assign, nonatomic) char stamp_month;
@property (assign, nonatomic) char stamp_year;
@property (assign, nonatomic) char hundredths;
@property (assign, nonatomic) char second;
@property (assign, nonatomic) char minute;
@property (assign, nonatomic) char hour;
@property (assign, nonatomic) double distance;
@property (assign, nonatomic) double calories;
@property (assign, nonatomic) long steps;

@end
