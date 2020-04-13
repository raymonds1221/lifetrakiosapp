//
//  Date.h
//  BLEManager
//
//  Created by Herman on 2/25/13.
//  Copyright (c) 2013 GV Concepts Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SH_Date : NSObject

@property (assign, nonatomic) int day;      // 1 - 31
@property (assign, nonatomic) int month;    // 1 - 12
@property (assign, nonatomic) int year;     // 0 - 199 (1900 - 2099)

@end
