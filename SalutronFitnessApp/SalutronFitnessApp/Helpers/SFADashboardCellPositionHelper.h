//
//  SFADashboardCellPositionHelper.h
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 1/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFADashboardCellPositionHelper : NSObject

@property (readwrite, nonatomic) NSInteger caloriesRow;
@property (readwrite, nonatomic) NSInteger bpmRow;
@property (readwrite, nonatomic) NSInteger stepsRow;
@property (readwrite, nonatomic) NSInteger distanceRow;
@property (readwrite, nonatomic) NSInteger sleepRow;
@property (readwrite, nonatomic) NSInteger workoutRow;
@property (readwrite, nonatomic) NSInteger actigraphyRow;
@property (readwrite, nonatomic) NSInteger lightPlotRow;

- (void)setFromRow:(NSInteger)fromRow toRow:(NSInteger)toRow;

@end
