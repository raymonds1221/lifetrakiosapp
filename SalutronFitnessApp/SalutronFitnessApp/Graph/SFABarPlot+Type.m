//
//  SFABarPlot+Type.m
//  SalutronFitnessApp
//
//  Created by Dana Nicolas on 4/4/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFABarPlot+Type.h"

@implementation SFABarPlot (Type)

- (NSInteger)numberOfBarForBarPlot:(SFABarPlot *)barPlot ofType:(BarPlotType)type withArrays:(NSArray *)dataArrays
{
    if (type == CALORIE_PLOT) {
        return [[dataArrays objectAtIndex:0] count];
    }
    else if (type == HEARTRATE_PLOT) {
        return [[dataArrays objectAtIndex:1] count];
    }
    else if (type == STEPS_PLOT) {
        return [[dataArrays objectAtIndex:2] count];
    }
    else if (type == DISTANCE_PLOT) {
        return [[dataArrays objectAtIndex:3] count];
    }
    return 0;
}

- (CGPoint)barPlot:(SFABarPlot *)barPlot pointAtIndex:(NSInteger)index ofType:(BarPlotType)type withArrays:(NSArray *)dataArrays
{
    if (type == CALORIE_PLOT)
    {
        CGPoint point = [[dataArrays objectAtIndex:0][index] CGPointValue];
        return point;
    }
    else if (type == HEARTRATE_PLOT)
    {
        CGPoint point = [[dataArrays objectAtIndex:1][index] CGPointValue];
        return point;
    }
    else if (type == STEPS_PLOT)
    {
        CGPoint point = [[dataArrays objectAtIndex:2][index] CGPointValue];
        return point;
    }
    else if (type == DISTANCE_PLOT)
    {
        CGPoint point = [[dataArrays objectAtIndex:3][index] CGPointValue];
        return point;
    }
    
    return CGPointMake(0, 0);
}

@end
