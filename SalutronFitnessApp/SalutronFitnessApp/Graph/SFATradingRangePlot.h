//
//  SFATradingRangePlot.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/10/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "CPTTradingRangePlot.h"

@protocol SFATradingRangePlotDelegate;

@interface SFATradingRangePlot : CPTTradingRangePlot

@property (weak, nonatomic) id <SFATradingRangePlotDelegate> dataDelegate;

+ (SFATradingRangePlot *)tradingRangePlot;

- (id)init;

@end

@protocol SFATradingRangePlotDelegate <NSObject>

- (NSInteger)numberOfRecordsForTradingRangePlot:(SFATradingRangePlot *)tradingRangePlot;
- (CGFloat)tradingRangePlot:(SFATradingRangePlot *)linePlot xValueAtIndex:(NSInteger)index;
- (CGFloat)tradingRangePlot:(SFATradingRangePlot *)linePlot yMinValueAtIndex:(NSInteger)index;
- (CGFloat)tradingRangePlot:(SFATradingRangePlot *)linePlot yMaxValueAtIndex:(NSInteger)index;

@end