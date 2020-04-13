//
//  SFABarPlot.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/4/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFABarPlot.h"

@interface SFABarPlot() <CPTBarPlotDataSource>

@end

@implementation SFABarPlot

- (id)init
{
    if(self = [super init])
    {
        self.dataSource = self;
    }
    
    return self;
}

#pragma mark - CPTBarPlotDataSource

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ([self.dataDelegate conformsToProtocol:@protocol(SFABarPlotDelegate)])
    {
        return [self.dataDelegate numberOfBarForBarPlot:self];
    }
    
    return 0;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    if ([self.dataDelegate conformsToProtocol:@protocol(SFABarPlotDelegate)]) {
        
        CGPoint point = [self.dataDelegate barPlot:self pointAtIndex:idx];
        
        if (fieldEnum == CPTBarPlotFieldBarLocation)
        {
            return [NSNumber numberWithFloat:point.x];
        }
        else if (fieldEnum == CPTBarPlotFieldBarTip)
        {
            return [NSNumber numberWithFloat:point.y];
        }
    }
    
    return 0;
}

#pragma mark - Public Methods

+ (CPTBarPlot *) barPlot
{
    SFABarPlot *barPlot = [[SFABarPlot alloc] init];
    return barPlot;
}

@end
