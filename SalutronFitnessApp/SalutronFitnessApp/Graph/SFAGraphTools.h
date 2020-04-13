//
//  SFAGraphTools.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/13/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SFAGraphConstants.h"

@interface SFAGraphTools : NSObject

+ (CGFloat)xWithMaxX:(CGFloat)maxX
              xValue:(CGFloat)xValue;

+ (CGFloat)yWithMaxY:(CGFloat)maxY
              yValue:(CGFloat)yValue;

+ (CGFloat)yValueForMaxY:(CGFloat)maxY
                       y:(CGFloat)y;

+ (CGFloat)xWithMinX:(CGFloat)minX
                maxX:(CGFloat)maxX
           minXRange:(CGFloat)minXRange
           maxXRange:(CGFloat)maxXRange
              xValue:(CGFloat)xValue;

+ (CGFloat)yWithMinY:(CGFloat)minY
                maxY:(CGFloat)maxY
           minYRange:(CGFloat)minYRange
           maxYRange:(CGFloat)maxYRange
              yValue:(CGFloat)yValue;

// Bar Plot Tools

+ (CGFloat)barWidthWithWithMaxX:(CGFloat)maxX
                       barCount:(NSInteger)barCount;

+ (CGFloat)barOffsetWithMaxX:(CGFloat)maxX
                    barCount:(NSInteger)barCount
                    barIndex:(NSInteger)barIndex;

+ (CGFloat)barPlotWidthWithMaxX:(CGFloat)maxX
                       barCount:(NSInteger)barCount
                   calendarMode:(SFACalendarMode)calendarMode;


@end
