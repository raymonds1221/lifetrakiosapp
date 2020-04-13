//
//  SFATradingRangePlot.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/10/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFATradingRangePlot.h"

@interface SFATradingRangePlot () <CPTTradingRangePlotDataSource>

@property (readonly, nonatomic) CGFloat yMin;
@property (readonly, nonatomic) CGFloat yMax;

@end

@implementation SFATradingRangePlot

#pragma mark - Initialization

- (id)init
{
    if (self = [super init])
    {
        self.dataSource = self;
    }
    
    return self;
}

#pragma mark - CPTTradingRangePlotDataSource Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ([self.dataDelegate conformsToProtocol:@protocol(SFATradingRangePlotDelegate)])
    {
        return [self.dataDelegate numberOfRecordsForTradingRangePlot:self];
    }
    
    return 0;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if ([self.dataDelegate conformsToProtocol:@protocol(SFATradingRangePlotDelegate)])
    {
        NSNumber *number;
        
        if (fieldEnum == CPTTradingRangePlotFieldX)
        {
            CGFloat x   = [self.dataDelegate tradingRangePlot:self xValueAtIndex:index];
            number      = [NSNumber numberWithFloat:x];
        }
        else if (fieldEnum == CPTTradingRangePlotFieldOpen)
        {
            CGFloat y   = [self.dataDelegate tradingRangePlot:self yMaxValueAtIndex:index];
            number      = [NSNumber numberWithFloat:y];
        }
        else if (fieldEnum == CPTTradingRangePlotFieldHigh)
        {
            CGFloat y   = [self.dataDelegate tradingRangePlot:self yMaxValueAtIndex:index];
            number      = [NSNumber numberWithFloat:y];
        }
        else if (fieldEnum == CPTTradingRangePlotFieldLow)
        {
            CGFloat y   = [self.dataDelegate tradingRangePlot:self yMinValueAtIndex:index];
            number      = [NSNumber numberWithFloat:y];
        }
        else if (fieldEnum == CPTTradingRangePlotFieldClose)
        {
            CGFloat y   = [self.dataDelegate tradingRangePlot:self yMinValueAtIndex:index];
            number      = [NSNumber numberWithFloat:y];
        }
        
        return number;
    }
    
    return [NSNumber numberWithInt:0];
}

#pragma mark - Public Methods

+ (SFATradingRangePlot *)tradingRangePlot
{
    SFATradingRangePlot *tradingRangePlot = [[SFATradingRangePlot alloc] init];
    return tradingRangePlot;
}

@end
