//
//  SalutronVibra.h
//  BLEManager
//
//  Created by Kevin on 29/10/13.
//  Copyright (c) 2013 Salutron Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    VIBRA_OFF = 0,
    VIBRA_ON,
} VibraMode;

typedef enum {
    VIBRA_1 = 1,
    VIBRA_2,
    VIBRA_3,
    VIBRA_4,
} VibraPattern;


@interface SalutronVibra : NSObject

@property (assign, nonatomic) int vibra_mode;
@property (assign, nonatomic) int vibra_pattern;
@property (assign, nonatomic) int vibra_repeat;

@end
