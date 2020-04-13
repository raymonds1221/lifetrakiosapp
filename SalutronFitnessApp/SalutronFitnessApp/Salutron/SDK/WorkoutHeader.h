//
//  WorkoutHeader.h
//  BLEManager
//
//  Created by Leo Bellotindos on 18/8/15.
//  Copyright (c) 2015 Salutron Inc. All rights reserved.
//

#ifndef BLEManager_WorkoutHeader_h
#define BLEManager_WorkoutHeader_h

#import <Foundation/Foundation.h>

@interface WorkoutHeader : NSObject

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

@property (assign, nonatomic) unsigned int recordCountSplits;
@property (assign, nonatomic) unsigned int recordCountStops;
@property (assign, nonatomic) unsigned int recordCountHR;
@property (assign, nonatomic) unsigned int recordCountTotal;

@property (assign, nonatomic) unsigned char averageBPM;
@property (assign, nonatomic) unsigned char minimumBPM;
@property (assign, nonatomic) unsigned char maximumBPM;
@property (assign, nonatomic) unsigned char statusFlags;
@property (assign, nonatomic) unsigned char logRateHR;
@property (assign, nonatomic) unsigned char autoSplitType;
@property (assign, nonatomic) unsigned char zoneTrainType;

@property (assign, nonatomic) unsigned char userMaxHR;
@property (assign, nonatomic) unsigned char zone0UpperHR;
@property (assign, nonatomic) unsigned char zone0LowerHR;
@property (assign, nonatomic) unsigned char zone1LowerHR;
@property (assign, nonatomic) unsigned char zone2LowerHR;
@property (assign, nonatomic) unsigned char zone3LowerHR;
@property (assign, nonatomic) unsigned char zone4LowerHR;
@property (assign, nonatomic) unsigned char zone5LowerHR;
@property (assign, nonatomic) unsigned char zone5UpperHR;

@property (assign, nonatomic) unsigned int autoSplitThreshold;

@end

#endif
