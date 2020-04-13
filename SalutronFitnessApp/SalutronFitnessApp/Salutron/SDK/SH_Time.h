//
//  Time.h
//  BLEManager
//
//  Created by Herman on 2/25/13.
//  Copyright (c) 2013 GV Concepts Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SH_Time : NSObject

@property (assign, nonatomic) int second;   // 0 - 59
@property (assign, nonatomic) int minute;   // 0 - 59
@property (assign, nonatomic) int hour;     // 0 - 23

@end
