//
//  SFABarPlot.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/4/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "CPTBarPlot.h"

@protocol SFABarPlotDelegate;

@interface SFABarPlot : CPTBarPlot

@property (weak, nonatomic) id <SFABarPlotDelegate> dataDelegate;

- (id)init;

+ (SFABarPlot *)barPlot;

@end

@protocol SFABarPlotDelegate <NSObject>

- (NSInteger)numberOfBarForBarPlot:(SFABarPlot *)barPlot;
- (CGPoint)barPlot:(SFABarPlot *)barPlot pointAtIndex:(NSInteger)index;

@end