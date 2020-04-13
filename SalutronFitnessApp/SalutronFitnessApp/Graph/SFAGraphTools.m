//
//  SFAGraphTools.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/13/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAGraphTools.h"

@implementation SFAGraphTools

+ (CGFloat)xWithMaxX:(CGFloat)maxX
              xValue:(CGFloat)xValue
{
    //maxX            -= 1;
    CGFloat percent = xValue / maxX;
    CGFloat x       = percent * (X_MAX_RANGE - X_MIN_RANGE);
    return x;
}

+ (CGFloat)xWithMaxX:(CGFloat)maxX
              xValue:(CGFloat)xValue
            barCount:(NSInteger)barCount
{
    if (maxX > 0)
    {
        CGFloat percent = xValue / maxX / barCount;
        CGFloat x       = percent * (X_MAX_RANGE - X_MIN_RANGE);
        return x;
    }
    
    return 0; 
}

+ (CGFloat)yWithMaxY:(CGFloat)maxY
              yValue:(CGFloat)yValue
{
    if (yValue == 0) {
        return 0;
    }
    
    if (maxY > 0)
    {
        CGFloat percent = yValue / maxY;
        CGFloat y       = percent * (Y_MAX_RANGE - Y_MIN_RANGE);
        return y;
    }
    
    return 0;
}

+ (CGFloat)yValueForMaxY:(CGFloat)maxY
                       y:(CGFloat)y
{
    CGFloat percent = (y - Y_MIN_RANGE) / (Y_MAX_RANGE - Y_MIN_RANGE);
    CGFloat yValue  = percent * maxY;
    return yValue;
}

+ (CGFloat)xWithMinX:(CGFloat)minX
                maxX:(CGFloat)maxX
           minXRange:(CGFloat)minXRange
           maxXRange:(CGFloat)maxXRange
              xValue:(CGFloat)xValue {
    CGFloat percent = (xValue - minX) / (maxX - minX);
    CGFloat x       = percent * (maxXRange - minXRange);
    return x;
}

+ (CGFloat)yWithMinY:(CGFloat)minY
                maxY:(CGFloat)maxY
           minYRange:(CGFloat)minYRange
           maxYRange:(CGFloat)maxYRange
              yValue:(CGFloat)yValue {
    CGFloat percent = (yValue - minY) / (maxY - minY);
    CGFloat y       = percent * (maxYRange - minYRange);
    return y;
}

#pragma mark - Bar Plot Tools

+ (CGFloat)barWidthWithWithMaxX:(CGFloat)maxX
                       barCount:(NSInteger)barCount
{
    CGFloat barWidth    = (X_MAX_RANGE - X_MIN_RANGE) / maxX / barCount;
    barWidth            -= (barWidth * BAR_SPACE_PERCENTAGE);
    //barWidth            -= (barWidth * BAR_DATA_SPACE_PERCENTAGE / barCount);
    return barWidth;
}

+ (CGFloat)barOffsetWithMaxX:(CGFloat)maxX
                    barCount:(NSInteger)barCount
                    barIndex:(NSInteger)barIndex
{
    CGFloat x           = 1.0f / maxX / barCount * (X_MAX_RANGE - X_MIN_RANGE);
    CGFloat barOffset   = barIndex * x + (x * 0.43f);
    return barOffset;
}

+ (CGFloat)barPlotWidthWithMaxX:(CGFloat)maxX
                       barCount:(NSInteger)barCount
                   calendarMode:(SFACalendarMode)calendarMode
{
    CGFloat barWidth        = (calendarMode == SFACalendarDay || calendarMode == SFACalendarWeek) ? MULTIPLE_DATA_BAR_WIDTH : SINGLE_DATA_BAR_WIDTH;
    barWidth                *= (1.0f + BAR_SPACE_PERCENTAGE);
    CGFloat barPlotWidth    = (barWidth * maxX * barCount);
    barPlotWidth            += (barWidth * maxX * barCount * BAR_DATA_SPACE_PERCENTAGE);
    
    return barPlotWidth;
}

@end
