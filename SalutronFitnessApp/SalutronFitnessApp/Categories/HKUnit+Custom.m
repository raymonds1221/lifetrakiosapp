//
//  HKUnit+Custom.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 1/26/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "HKUnit+Custom.h"

@implementation HKUnit (Custom)

+ (HKUnit *)heartBeatsPerMinuteUnit {
    return [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
}

@end
