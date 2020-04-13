//
//  CPTGraph+Label.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/13/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "CPTGraph.h"

@interface CPTGraph (Label)

- (void)hourLabels;
- (void)dayLabelsWithWeek:(NSInteger)week ofYear:(NSInteger)year;
- (void)dayLabelsWithMonth:(NSInteger)month ofYear:(NSInteger)year;
- (void)monthLabels;

// New Label Methods

//FITNESS RESULTS PORTRAIT
- (void)hourLabelsWithBarWidth:(CGFloat)barWidth
                      barSpace:(CGFloat)barSpace
                    graphWidth:(CGFloat)graphWidth;

- (void)hourPortraitLabelsForActigraphyWithBarWidth:(CGFloat)barWidth
                                           barSpace:(CGFloat)barSpace;

- (void)HRworkoutPortraitLabelsWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace labelArray:(NSArray *)labelArray numberOfDataPoints:(NSInteger) dataPointsCount;

- (void)hourPortraitLabelsWithBarWidth:(CGFloat)barWidth
                              barSpace:(CGFloat)barSpace;

- (void)dayPortraitLabelsWithWeek:(NSInteger)week ofYear:(NSInteger)year
                         barWidth:(CGFloat)barWidth
                         barSpace:(CGFloat)barSpace;

- (void)dayPortraitLabelsWithMonth:(NSInteger)month
                            ofYear:(NSInteger)year
                          barWidth:(CGFloat)barWidth
                          barSpace:(CGFloat)barSpace;

- (void)dayLabelsForActigraphyWithWeek:(NSInteger)week
                                ofYear:(NSInteger)year
                              barWidth:(CGFloat)barWidth
                              barSpace:(CGFloat)barSpace;

- (void)dayLabelsForActigraphyWithYear:(NSInteger)year
                              BarWidth:(CGFloat)barWidth
                              barSpace:(CGFloat)barSpace;

- (void)hourLabelsWithBarWidth:(CGFloat)barWidth
                      barSpace:(CGFloat)barSpace;

- (void)hourLabelsForActigraphyWithBarWidth:(CGFloat)barWidth
                                   barSpace:(CGFloat)barSpace;

- (void)hourLabelsWithBarWidth:(CGFloat)barWidth
                      barSpace:(CGFloat)barSpace
                    startPoint:(NSInteger)startPoint
                      endPoint:(NSInteger)endPoint;

- (void)dayLabelsWithWeek:(NSInteger)week
                   ofYear:(NSInteger)year
                 barWidth:(CGFloat)barWidth
                 barSpace:(CGFloat)barSpace;

- (void)dayLabelsWithMonth:(NSInteger)month
                    ofYear:(NSInteger)year
                  barWidth:(CGFloat)barWidth
                  barSpace:(CGFloat)barSpace;

- (void)dayLabelsWithYear:(NSInteger)year
                 barWidth:(CGFloat)barWidth
                 barSpace:(CGFloat)barSpace;

- (void)monthLabelsWithBarWidth:(CGFloat)barWidth
                       barSpace:(CGFloat)barSpace;

- (void)sleepLogsHourPortraitLabelsWithBarWidth:(CGFloat)barWidth
                                       barSpace:(CGFloat)barSpace;

- (void)sleepLogsHourLabelsWithBarWidth:(CGFloat)barWidth
                               barSpace:(CGFloat)barSpace;

- (void)workoutPortraitLabelsWithBarWidth:(CGFloat)barWidth
                                 barSpace:(CGFloat)barSpace
                               labelArray:(NSArray *)labelArray
                       numberOfDataPoints:(NSInteger)dataPointsCount;

- (void)lightPlotHourPortraitLabelsWithBarWidth:(CGFloat)barWidth
                                       barSpace:(CGFloat)barSpace;

- (void)hourPortraitLabelsForLightPlotWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace;
- (void)hourLabelsForLightPlotWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace;

@end
