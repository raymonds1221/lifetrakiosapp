//
//  UserProfile.h
//  BLEManager
//
//  Created by Herman on 2/21/13.
//  Copyright (c) 2013 GV Concepts Inc. All rights reserved.
//
//  All information and materials contained herein are owned by GV Concepts, Inc.
//  and is protected by U.S. and international copyright laws.
//  All use, disclosure, dissemination, transfer, publication or reproduction
//  of these materials, in whole or in part, is prohibited, unless authorized
//  in writing by GV Concepts, Inc.
//  If copies of these materials are made with written authorization of
//  GV Concepts, Inc, all copies must contain this notice.
//

#import <Foundation/Foundation.h>
#import "SH_Date.h"

typedef enum {
    MALE = 0,
    FEMALE,
} Gender;

typedef enum {
    IMPERIAL = 0,
    METRIC,
} Unit;

typedef enum {
    LOW = 0,
    MEDIUM,
    HIGH,
} AccelSensorSensitivity;

@interface SalutronUserProfile : NSObject

@property (strong, nonatomic) SH_Date *birthday;
@property (assign, nonatomic) Gender gender;
@property (assign, nonatomic) Unit unit;
@property (assign, nonatomic) AccelSensorSensitivity sensitivity;
@property (assign, nonatomic) int weight;                           // 44 - 440 (lbs)
@property (assign, nonatomic) int height;                           // 100 - 220 (cm)

@end
