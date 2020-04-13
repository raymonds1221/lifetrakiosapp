//
//  SFAGoalManager.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFAGoalManager : NSObject

@property (readwrite, nonatomic) NSInteger  calorieGoal;
@property (readwrite, nonatomic) NSInteger  stepGoal;
@property (readwrite, nonatomic) CGFloat    distanceGoal;
@property (readwrite, nonatomic) NSInteger  sleepGoal;

// Singleton Instance

+ (SFAGoalManager *)sharedManager;

// Instance Methods

//- (NSDictionary *)dictionary;

@end
