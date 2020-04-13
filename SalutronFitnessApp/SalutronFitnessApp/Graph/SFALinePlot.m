//
//  SFALinePlot.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/3/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFALinePlot.h"

#import "SFAXYPlotSpace.h"

@interface SFALinePlot () <CPTScatterPlotDataSource>

@end

@implementation SFALinePlot

#pragma mark - Initialization

- (id)init
{
    if (self = [super init])
    {
        self.dataSource = self;
    }
    
    return self;
}

#pragma mark - CPTPlotDataSource Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords
{
    if ([self.dataDelegate conformsToProtocol:@protocol(SFALinePlotDelegate)])
    {
        return [self.dataDelegate numberOfPointsForLinePlot:self];
    }
    
    return 0;
}
/*
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if ([self.dataDelegate conformsToProtocol:@protocol(SFALinePlotDelegate)])
    {
        CGPoint point = [self.dataDelegate linePlot:self pointAtIndex:index];
        
        //dont plot if y is zero, adds gap to line plot
        if (point.y == 0) {
            return nil;
        }
        if (fieldEnum == CPTScatterPlotFieldX)
        {
            NSNumber *number = [NSNumber numberWithFloat:point.x];
            return number;
        }
        else if (fieldEnum == CPTScatterPlotFieldY)
        {
            NSNumber *number = [NSNumber numberWithFloat:point.y];
            return number;
        }
    }
    
    return nil;
}

*/
- (double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx{
    if ([self.dataDelegate conformsToProtocol:@protocol(SFALinePlotDelegate)])
    {
        CGPoint point = [self.dataDelegate linePlot:self pointAtIndex:idx];
        
        //dont plot if y is zero, adds gap to line plot
        if (point.y == 0) {
            return NAN;
        }
        if (fieldEnum == CPTScatterPlotFieldX)
        {
            NSNumber *number = [NSNumber numberWithFloat:point.x];
            return point.x;
        }
        else if (fieldEnum == CPTScatterPlotFieldY)
        {
            NSNumber *number = [NSNumber numberWithFloat:point.y];
            return point.y;
        }
    }
    
    return NAN;
}

- (CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)idx {
    if([self.dataDelegate conformsToProtocol:@protocol(SFALinePlotDelegate)] && [self.dataDelegate respondsToSelector:@selector(symbolForScatterPlot:pointAtIndex:)])
        return [self.dataDelegate symbolForScatterPlot:self pointAtIndex:idx];
    return nil;
}

#pragma mark - Public Methods

+ (SFALinePlot *)linePlot
{
    SFALinePlot *linePlot = [[SFALinePlot alloc] init];
    return linePlot;
}

@end
