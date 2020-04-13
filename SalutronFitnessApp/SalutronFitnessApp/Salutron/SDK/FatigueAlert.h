//
//  FatigueAlert.h
//  BLEManager
//
//  Created by Kevin on 11/11/14.
//  Copyright (c) 2013 Salutron Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FatigueAlert : NSObject

@property (assign, nonatomic) unsigned char type;                   // 0 - Status 1 - threshold 2 - Interval
@property (assign, nonatomic) unsigned char status;                 // 0 - inactive 1 - active (Default:Active)
@property (assign, nonatomic) unsigned char threshold;              // 1 - 80 (default 50%)
@property (assign, nonatomic) unsigned char interval;               // 1 - 6  (equivalent to 10-60 minites: default is 1)
@property (assign, nonatomic) unsigned char hr;                       // 0 - 23
@property (assign, nonatomic) unsigned char min;                        // 0 - 59
@end
