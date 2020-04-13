//
//  WorkoutSetting.h
//  BLEManager
//
//  Created by Leo Bellotindos on 19/8/15.
//  Copyright (c) 2015 Salutron Inc. All rights reserved.
//

#ifndef BLEManager_WorkoutSetting_h
#define BLEManager_WorkoutSetting_h

#import <Foundation/Foundation.h>

@interface WorkoutSetting : NSObject

@property (assign, nonatomic) unsigned char type;
@property (assign, nonatomic) unsigned char HRLogRate;
@property (assign, nonatomic) unsigned char autoSplitType;
@property (assign, nonatomic) unsigned int autoSplitThreshold;
@property (assign, nonatomic) unsigned char zoneTrainType;
@property (assign, nonatomic) unsigned char zone0Upper;
@property (assign, nonatomic) unsigned char zone0Lower;
@property (assign, nonatomic) unsigned char zone1Lower;
@property (assign, nonatomic) unsigned char zone2Lower;
@property (assign, nonatomic) unsigned char zone3Lower;
@property (assign, nonatomic) unsigned char zone4Lower;
@property (assign, nonatomic) unsigned char zone5Lower;
@property (assign, nonatomic) unsigned char zone5Upper;
@property (assign, nonatomic) unsigned char reserved;
@property (assign, nonatomic) unsigned int databaseUsage;
@property (assign, nonatomic) unsigned int databaseUsageMax;
@property (assign, nonatomic) unsigned char reconnectTimeout;

@end


#endif
