//
//  LightDataPoint.h
//  BLEManager
//
//  Created by Kevin on 12/8/14.
//  Copyright (c) 2014 Salutron Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LightDataPoint : NSObject

@property (assign, nonatomic) int red;            //
@property (assign, nonatomic) int green;            //
@property (assign, nonatomic) int blue;            //
@property (assign, nonatomic) char sensor_gain;      //0-1
@property (assign, nonatomic) char intergration_time;      //0-1
//@property (assign, nonatomic) NSData *rawData;           //

@end
