//
//  SFALinePlot.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/3/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "CPTScatterPlot.h"

@protocol SFALinePlotDelegate;

@interface SFALinePlot : CPTScatterPlot 

@property (weak, nonatomic) id <SFALinePlotDelegate> dataDelegate;
@property (assign, nonatomic) NSUInteger index;

+ (SFALinePlot *)linePlot;

- (id)init;

@end

@protocol SFALinePlotDelegate <NSObject>

@required
- (NSInteger)numberOfPointsForLinePlot:(SFALinePlot *)linePlot;
- (CGPoint)linePlot:(SFALinePlot *)linePlot pointAtIndex:(NSInteger)index;

@optional
- (CPTPlotSymbol *)symbolForScatterPlot:(SFALinePlot *)linePlot pointAtIndex:(NSInteger)index;

@end
