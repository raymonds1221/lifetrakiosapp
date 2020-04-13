//
//  SFABarPlot+Type.h
//  SalutronFitnessApp
//
//  Created by Dana Nicolas on 4/4/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFABarPlot.h"

@interface SFABarPlot (Type)

- (NSInteger)numberOfBarForBarPlot:(SFABarPlot *)barPlot ofType:(BarPlotType)type withArrays:(NSArray *)dataArrays;
- (CGPoint)barPlot:(SFABarPlot *)barPlot pointAtIndex:(NSInteger)index ofType:(BarPlotType)type withArrays:(NSArray *)dataArrays;

@end
