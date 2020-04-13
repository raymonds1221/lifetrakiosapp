//
//  SFAGoalManager.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Format.h"

#import "DeviceEntity+Data.h"
#import "GoalsEntity+Data.h"

#import "SFAGoalManager.h"

@interface SFAGoalManager ()

@end

@implementation SFAGoalManager

/*
 @property (readwrite, nonatomic) NSInteger  calorieGoal;
 @property (readwrite, nonatomic) NSInteger  stepGoal;
 @property (readwrite, nonatomic) CGFloat    distanceGoal;
 @property (readwrite, nonatomic) NSInteger  sleepGoal;
 */

#pragma mark - Singleton Instance

+ (SFAGoalManager *)sharedManager
{
    static SFAGoalManager *instance = nil;
    
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

#pragma mark - Public Methods

@end
