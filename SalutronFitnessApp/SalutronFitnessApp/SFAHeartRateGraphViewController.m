//
//  SFAHeartRateGraphViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/5/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAHeartRateGraphViewController.h"
#import "SFAMainViewController.h"
#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "UIViewController+Helper.h"

#import "CPTGraph+Label.h"
#import "TimeDate+Data.h"

#import "SFAGraphTools.h"

#import "SFAGraph.h"
#import "SFAGraphView.h"
#import "SFAXYPlotSpace.h"
#import "SFABarPlot.h"

#import "StatisticalDataHeaderEntity.h"
#import "StatisticalDataPointEntity+Data.h"
#import "DateEntity.h"

#define Y_MIN_VALUE_KEY     @"minValue"
#define Y_MAX_VALUE_KEY     @"maxValue"
#define X_VALUE_KEY         @"xValue"
#define BPM_VALUE_KEY       @"bpmValue"
#define BPM_MIN_VALUE_KEY   @"bpmMinValue"
#define BPM_MAX_VALUE_KEY   @"bpmMaxValue"

#define BPM_MIN_Y_VALUE 40
#define BPM_MAX_Y_VALUE 240

@interface SFAHeartRateGraphViewController () <UIScrollViewDelegate, CPTBarPlotDataSource>

// Graph
@property (strong, nonatomic) SFAGraph                          *graph;
@property (strong, nonatomic) SFAXYPlotSpace                    *plotSpace;
@property (strong, nonatomic) SFABarPlot                        *barPlot;
@property (strong, nonatomic) SFAHeartRateGraphViewController   *viewController;
@property (readonly, nonatomic) CGFloat                         maxX;
@property (readonly, nonatomic) CGFloat                         barWidth;
@property (readonly, nonatomic) CGFloat                         barSpace;
@property (readonly, nonatomic) CGFloat                         graphViewWidth;

// Data
@property (strong, nonatomic) NSArray *dataSource;
@property (readonly, nonatomic) CGFloat maxY;
@property (readwrite, nonatomic) NSInteger month;
@property (readwrite, nonatomic) NSInteger year;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphLeftHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphRightHorizontalSpace;
@property (readwrite, nonatomic) CGFloat                oldGraphViewHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewHeight;
@end

@implementation SFAHeartRateGraphViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        self.graphViewHeight.constant = 155;
    }
    [self _adjustView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _isPortrait = (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    [self _adjustView];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat x           = scrollView.contentOffset.x < 0 ? 0 : scrollView.contentOffset.x;
    x                   = scrollView.contentOffset.x > self.graphViewWidth ? self.graphViewWidth : x;
    NSInteger index     = x / (self.barWidth + self.barSpace);
    index               = index < self.maxX ? index : self.maxX;
    self.currentTime    = [self.calendarController currentTimeForIndex:index month:self.month year:self.year];
    
    if (index < self.dataSource.count)
    {
        NSDictionary *record    = self.dataSource[index];
        self.currentHeartRate   = [[record objectForKey:BPM_VALUE_KEY] integerValue];;
        
        if (self.calendarController.calendarMode != SFACalendarDay) {
            self.minHeartRate = [[record objectForKey:BPM_MIN_VALUE_KEY] integerValue];
            self.maxHeartRate = [[record objectForKey:BPM_MAX_VALUE_KEY] integerValue];
            
            if ((self.minHeartRate > 0 && self.maxHeartRate > 0) && self.minHeartRate == self.maxHeartRate) {
                self.minHeartRate -= 5;
                self.maxHeartRate += 5;
            }

        }
        
        // Values
        /*if (_isPortrait)
        {
            self.currentCalories    = _totalCalories;
            self.currentDistance    = _totalDistance;
            self.currentHeartRate   = _totalHeartRate;
            self.currentSteps       = _totalSteps;
        }
        else
        {*/
            //self.currentHeartRate = [SFAGraphTools yValueForMaxY:BPM_MAX_Y_VALUE y:heartRate];
    
        //}
    }
    else
    {
        self.currentHeartRate   = 0;
        
        if (self.calendarController.calendarMode != SFACalendarDay) {
            // Values
            self.minHeartRate       = 0;
            self.maxHeartRate       = 0;
        }
    }
}


#pragma mark - CPTBarPlotDataSource and CPTTradingRangePlotDataSource Methods

- (CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx
{
    UIColor *color  = HEART_RATE_LINE_COLOR;
    CPTFill *fill   = [CPTFill fillWithColor:[CPTColor colorWithCGColor:color.CGColor]];
    
    return fill;
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if (plot == self.barPlot)
    {
        return self.dataSource.count;
    }
    
    return 0;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    if (plot == self.barPlot)
    {
        NSDictionary *record = self.dataSource[idx];
        
        if (fieldEnum == CPTBarPlotFieldBarLocation)
        {
            return [record objectForKey:X_VALUE_KEY];
        }
        else if (fieldEnum == CPTBarPlotFieldBarTip)
        {
            return [record objectForKey:Y_MAX_VALUE_KEY];
        }
        else if (fieldEnum == CPTBarPlotFieldBarBase)
        {
            return [record objectForKey:Y_MIN_VALUE_KEY];
        }
    }
    
    return [NSNumber numberWithInt:0];
}

#pragma mark - Setters

- (void)setCurrentTime:(NSString *)currentTime
{
    if (![_currentTime isEqualToString:currentTime])
    {
        _currentTime = currentTime;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAHeartRateGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(graphViewController:didChangeTime:)])
        {
            [self.delegate graphViewController:self didChangeTime:currentTime];
        }
    }
}

- (void)setCurrentHeartRate:(NSInteger)currentHeartRate
{
    if (_currentHeartRate != currentHeartRate)
    {
        _currentHeartRate = currentHeartRate;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAHeartRateGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(graphViewController:didChangeHeartRate:)])
        {
            [self.delegate graphViewController:self didChangeHeartRate:currentHeartRate];
        }
    }
}

- (void)setMinHeartRate:(NSInteger)minHeartRate
{
    if (_minHeartRate != minHeartRate)
    {
        _minHeartRate = minHeartRate;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAHeartRateGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(graphViewController:didChangeMinHeartRate:)])
        {
            [self.delegate graphViewController:self didChangeMinHeartRate:minHeartRate];
        }
    }
}

- (void)setMaxHeartRate:(NSInteger)maxHeartRate
{
    if (_maxHeartRate != maxHeartRate)
    {
        _maxHeartRate = maxHeartRate;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAHeartRateGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(graphViewController:didChangeMaxHeartRate:)])
        {
            [self.delegate graphViewController:self didChangeMaxHeartRate:maxHeartRate];
        }
    }
}

#pragma mark - Getters

- (CGFloat)maxX
{
    if (self.calendarController.calendarMode == SFACalendarDay)
    {
        return DAY_DATA_MAX_COUNT;
    }
    else if (self.calendarController.calendarMode == SFACalendarWeek)
    {
        return WEEK_DATA_MAX_COUNT;
    }
    else if (self.calendarController.calendarMode == SFACalendarMonth)
    {
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        NSDateComponents *components    = [NSDateComponents new];
        components.month                = self.calendarController.selectedMonth;
        components.year                 = self.calendarController.selectedYear;
        NSDate *date                    = [calendar dateFromComponents:components];
        NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
        
        return range.length;
    }
    else if (self.calendarController.calendarMode == SFACalendarYear)
    {
        return YEAR_DATA_MAX_COUNT;
    }
    
    return 0.0f;
}

- (CGFloat)barWidth
{
    if (self.calendarController.calendarMode == SFACalendarDay)
    {
        return DAY_DATA_BAR_WIDTH;
    }
    else if (self.calendarController.calendarMode == SFACalendarWeek)
    {
        return WEEK_DATA_BAR_WIDTH;
    }
    else if (self.calendarController.calendarMode == SFACalendarMonth)
    {
        return MONTH_DATA_BAR_WIDTH;
    }
    else if (self.calendarController.calendarMode == SFACalendarYear)
    {
        return YEAR_DATA_BAR_WIDTH;
    }
    
    return 0.0f;
}

- (CGFloat)barSpace
{
    if (self.calendarController.calendarMode == SFACalendarDay)
    {
        return DAY_DATA_BAR_SPACE;
    }
    else if (self.calendarController.calendarMode == SFACalendarWeek)
    {
        return WEEK_DATA_BAR_SPACE;
    }
    else if (self.calendarController.calendarMode == SFACalendarMonth)
    {
        return MONTH_DATA_BAR_SPACE;
    }
    else if (self.calendarController.calendarMode == SFACalendarYear)
    {
        return YEAR_DATA_BAR_SPACE;
    }
    
    return 0.0f;
}

- (CGFloat)graphViewWidth
{
    CGFloat graphViewWidth  = self.barWidth * self.maxX;
    graphViewWidth          += (self.maxX * self.barSpace);
    
    return graphViewWidth;
}

#pragma mark - Private Methods

- (void)_adjustView
{
    if (_isPortrait)
    {
        self.graphLeftHorizontalSpace.constant  = GRAPH_PORTRAIT_HORIZONTAL_MARGIN;
        self.graphRightHorizontalSpace.constant = GRAPH_PORTRAIT_HORIZONTAL_MARGIN;
        self.scrollView.scrollEnabled           = NO;
    }
    else
    {
        if (self.isIOS8AndAbove) {
            self.graphLeftHorizontalSpace.constant      = self.view.window.frame.size.width / 2;
            self.graphRightHorizontalSpace.constant     = self.view.window.frame.size.width / 2;
        } else {
            self.graphLeftHorizontalSpace.constant      = self.view.window.frame.size.height / 2;
            self.graphRightHorizontalSpace.constant     = self.view.window.frame.size.height / 2;
        }
        
        self.scrollView.scrollEnabled               = YES;
    }
    
    [self adjustGraphViewWidth];
    [self adjustBarPlotWidth];
    [self adjustTickLocation];
}

- (void)adjustGraphViewWidth
{
    self.graphViewWidthConstraint.constant  = (_isPortrait) ? self.view.frame.size.width : self.graphViewWidth;
    self.plotSpace.xRange                   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f)
                                                                           length:CPTDecimalFromFloat(self.graphViewWidth)];
}

- (void)adjustBarPlotWidth
{
    self.barPlot.barWidth = CPTDecimalFromCGFloat(self.barWidth);
    self.barPlot.barOffset = CPTDecimalFromCGFloat((self.barSpace * 0.5f) + (self.barWidth * 0.5f));
}

- (void)adjustTickLocation
{
    if (self.isPortrait)
    {
        CPTXYAxisSet *axisSet               = (CPTXYAxisSet *) self.graph.axisSet;
        axisSet.xAxis.majorTickLocations    = nil;
    }
    else
    {
        NSMutableSet *tickLocations = [NSMutableSet new];
        for (NSInteger a = 0; a <= self.maxX; a++)
        {
            NSDecimal tickLocation  = CPTDecimalFromInt(a * (self.barWidth + self.barSpace));
            NSNumber *number        = [NSDecimalNumber decimalNumberWithDecimal:tickLocation];
            
            [tickLocations addObject:number];
        }
        
        CPTXYAxisSet *axisSet               = (CPTXYAxisSet *) self.graph.axisSet;
        axisSet.xAxis.majorTickLocations    = tickLocations.copy;
    }
}

- (void)initializeObjects
{
    // Graph
    self.graph                              = [SFAGraph graphWithGraphView:self.graphView];
    self.graph.paddingTop                   = 0.0f;
    self.graph.paddingLeft                  = 0.0f;
    self.graph.paddingRight                 = 0.0f;
    self.graph.paddingBottom                = 10.0f;
    self.graph.plotAreaFrame.masksToBorder  = NO;
    self.graphView.hostedGraph              = self.graph;
    
    // Axis Line Style
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *) self.graph.axisSet;
    CPTMutableLineStyle *lineStyle  = axisSet.xAxis.axisLineStyle.mutableCopy;
    lineStyle.lineColor             = [CPTColor clearColor];
    axisSet.xAxis.axisLineStyle     = lineStyle.copy;
    axisSet.yAxis.hidden            = YES;
    axisSet.yAxis.labelTextStyle    = nil;
    
    // Axis Text Style
    CPTMutableTextStyle *textStyle  = axisSet.xAxis.labelTextStyle.mutableCopy;
    textStyle.fontSize              = 10.0f;
    axisSet.xAxis.labelTextStyle    = textStyle.copy;
    axisSet.xAxis.labelingPolicy    = CPTAxisLabelingPolicyNone;
    
    // Tick Mark Style
    CPTMutableLineStyle *tickLineStyle          = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor                     = [CPTColor grayColor];
    tickLineStyle.lineWidth                     = 1.0f;
    axisSet.xAxis.orthogonalCoordinateDecimal   = CPTDecimalFromInt(0);
    axisSet.xAxis.majorTickLineStyle            = tickLineStyle.copy;
    axisSet.xAxis.majorTickLength               = 4.0f;
    axisSet.xAxis.tickDirection                 = CPTSignNegative;
    
    // Plot Space
    self.plotSpace          = (SFAXYPlotSpace *) self.graph.defaultPlotSpace;
    self.plotSpace.xRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(X_MIN_RANGE) length:CPTDecimalFromFloat(self.graphViewWidth)];
    self.plotSpace.yRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(Y_MAX_RANGE)];
    
    // Plot
    self.barPlot                = [SFABarPlot barPlot];
    self.barPlot.dataSource     = self;
    self.barPlot.fill           = [CPTFill fillWithColor:[CPTColor colorWithCGColor:HEART_RATE_LINE_COLOR.CGColor]];
    self.barPlot.barWidth       = CPTDecimalFromFloat(1.0f);
    self.barPlot.lineStyle      = nil;
    self.barPlot.barBasesVary   = YES;
    self.barPlot.anchorPoint    = CGPointZero;
    
    _isPortrait                 = YES;
    [self _adjustView];
    
    [self.graph addPlot:self.barPlot toPlotSpace:self.plotSpace];
    [self adjustTickLocation];
}

#pragma mark - Set Min and Max Heart Rate

- (void)setMinAndMaxHeartRateForDate:(NSDate *)date
{
    StatisticalDataHeaderEntity *statisticalDataHeaderEntity = [StatisticalDataHeaderEntity statisticalDataHeaderEntityForDate:date];
    
    self.minHeartRate = [statisticalDataHeaderEntity.minHR integerValue];
    self.maxHeartRate = [statisticalDataHeaderEntity.maxHR integerValue];
    
    NSInteger averageBPM = [StatisticalDataPointEntity getAverageBPMForDate:statisticalDataHeaderEntity.dateInNSDate];
    if ( self.calendarController.calendarMode == SFACalendarDay && (self.minHeartRate == 0 && self.maxHeartRate == 0)) {
        if (averageBPM > 0) {
            NSArray *datapoints = [statisticalDataHeaderEntity.dataPoint copy];
            NSInteger tempMinHR = 0;
            NSInteger tempMaxHR = 0;
            NSMutableArray *heartRates = [[NSMutableArray alloc] init];
            for (StatisticalDataPointEntity *datapoint in datapoints) {
                if (datapoint.averageHR.integerValue > 0){
                    [heartRates addObject:datapoint.averageHR];
                    if (datapoint.averageHR.integerValue > tempMaxHR || tempMaxHR == 0) {
                        tempMaxHR = datapoint.averageHR.integerValue;
                    }
                    else if (datapoint.averageHR.integerValue < tempMinHR || tempMinHR == 0) {
                        tempMinHR = datapoint.averageHR.integerValue;
                    }
                }
            }
            if (heartRates.count == 1) {
                self.minHeartRate = averageBPM - 5;
                self.maxHeartRate = averageBPM + 5;
            }
            else if(heartRates.count > 1){
                self.minHeartRate = tempMinHR;
                self.maxHeartRate = tempMaxHR;
            }
            [heartRates removeAllObjects];
        }
        
    }
    else if(self.calendarController.calendarMode == SFACalendarDay) {
        NSArray *datapoints = [statisticalDataHeaderEntity.dataPoint copy];
        NSInteger tempMaxHR = self.maxHeartRate;
        NSMutableArray *heartRates = [[NSMutableArray alloc] init];
        for (StatisticalDataPointEntity *datapoint in datapoints) {
            if (datapoint.averageHR.integerValue > 0){
                [heartRates addObject:datapoint.averageHR];
                if (datapoint.averageHR.integerValue > tempMaxHR) {
                    tempMaxHR = datapoint.averageHR.integerValue;
                }
            }
        }
        self.maxHeartRate = tempMaxHR;
    }
}

#pragma mark - Get and set data for graph

- (void)getDataForDate:(NSDate *)date
{
    [self setMinAndMaxHeartRateForDate:date];
    
    NSArray *data = [StatisticalDataPointEntity dataPointsForDate:date];
    
    if (data)
    {
        if (data.count > 0)
        {
            NSMutableArray *heartRate = [NSMutableArray new];
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index         = [data indexOfObject:dataPoint];
                CGFloat x               = (self.barWidth + self.barSpace) * index;
                CGFloat maxY            = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:dataPoint.averageHR.floatValue];
                CGFloat minY            = 0.0f;
                
                NSDictionary *record    = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x], X_VALUE_KEY,
                                           [NSNumber numberWithFloat:maxY], Y_MAX_VALUE_KEY,
                                           [NSNumber numberWithFloat:minY], Y_MIN_VALUE_KEY,
                                           [NSNumber numberWithInt:dataPoint.averageHR.integerValue], BPM_VALUE_KEY,
                                           [NSNumber numberWithInteger:self.maxHeartRate], BPM_MAX_VALUE_KEY,
                                           [NSNumber numberWithInteger:self.minHeartRate], BPM_MIN_VALUE_KEY,
                                           nil];
                
                [heartRate addObject:record];
            }
            
            self.dataSource = heartRate.copy;
        }
        else {
            self.dataSource = nil;
        }
    }
    
    self.scrollView.contentOffset = CGPointZero;
    
    [self.barPlot reloadData];
    [self adjustGraphViewWidth];
    [self adjustBarPlotWidth];
    [self adjustTickLocation];
    
    if (_isPortrait)
        [self.graph hourPortraitLabelsWithBarWidth:self.barWidth barSpace:self.barSpace];
    else
        [self.graph hourLabelsWithBarWidth:self.barWidth barSpace:self.barSpace];
}

- (void)getDataForWeek:(NSInteger)week ofYear:(NSInteger)year
{
    NSArray *data = [StatisticalDataPointEntity dataPointsForWeek:week ofYear:year];
    
    if (data)
    {
        if (data.count > 0)
        {
            CGFloat heartRateMinValue[84]   = {};
            CGFloat heartRateMaxValue[84]   = {};
            CGFloat heartRateValue[84]      = {};
            CGFloat heartRateCount[84]      = {};
            NSMutableArray *heartRate       = [NSMutableArray new];
            
            StatisticalDataPointEntity *dataPoint   = [data objectAtIndex:0];
            NSCalendar *calendar                    = [NSCalendar currentCalendar];
            NSDateComponents *components            = [NSDateComponents new];
            components.month                        = dataPoint.header.date.month.integerValue;
            components.day                          = dataPoint.header.date.day.integerValue;
            components.year                         = dataPoint.header.date.year.integerValue + 1900;
            NSDate *date                            = [calendar dateFromComponents:components];
            components                              = [calendar components:NSWeekdayCalendarUnit fromDate:date];
            NSInteger startIndex                    = (components.weekday - 1) * 24 * 6;
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index             = (startIndex + [data indexOfObject:dataPoint]) / 12;
                CGFloat heartRateFloat      = dataPoint.averageHR.floatValue;
                heartRateMaxValue[index]    = heartRateFloat > heartRateMaxValue[index] ? heartRateFloat: heartRateMaxValue[index];
                heartRateMinValue[index]    = heartRateMaxValue[index];
                heartRateValue[index]       += heartRateFloat;
                heartRateCount[index]       += heartRateFloat > 0;
            }
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index             = (startIndex + [data indexOfObject:dataPoint]) / 12;
                CGFloat heartRateFloat      = dataPoint.averageHR.floatValue;
                
                if (heartRateFloat > 0)
                {
                    heartRateMinValue[index] = heartRateFloat < heartRateMinValue[index] ? heartRateFloat: heartRateMinValue[index];
                }
            }
            
            for (NSInteger index = 0; index < 84; index++)
            {
                NSInteger bpmMin = heartRateMinValue[index] > 0 ?  heartRateMinValue[index] - 5 : 0;
                NSInteger bpmMax = heartRateMaxValue[index] > 0 ?  heartRateMaxValue[index] + 5 : 0;
                heartRateValue[index] /= heartRateCount[index];
                
                CGFloat x               = (self.barWidth + self.barSpace) * index;
                CGFloat maxY            = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:bpmMax];
                CGFloat minY            = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:bpmMin];
                NSDictionary *record    = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x], X_VALUE_KEY,
                                           [NSNumber numberWithFloat:maxY], Y_MAX_VALUE_KEY,
                                           [NSNumber numberWithFloat:minY], Y_MIN_VALUE_KEY,
                                           [NSNumber numberWithInt:heartRateValue[index]], BPM_VALUE_KEY,
                                           [NSNumber numberWithInt:heartRateMaxValue[index]], BPM_MAX_VALUE_KEY,
                                           [NSNumber numberWithInt:heartRateMinValue[index]], BPM_MIN_VALUE_KEY,
                                           nil];
                
                [heartRate addObject:record];
            }
            
            self.dataSource = heartRate.copy;
        }
        else
        {
            self.dataSource = nil;
        }
    }
    
    self.scrollView.contentOffset = CGPointZero;
    
    [self adjustGraphViewWidth];
    [self adjustBarPlotWidth];
    [self adjustTickLocation];
    [self.graph dayLabelsWithWeek:week ofYear:year barWidth:self.barWidth barSpace:self.barSpace];
    if (_isPortrait)
        [self.graph dayPortraitLabelsWithWeek:week ofYear:year barWidth:self.barWidth barSpace:self.barSpace];
    else
        [self.graph dayLabelsWithWeek:week ofYear:year barWidth:self.barWidth barSpace:self.barSpace];
    [self.barPlot reloadData];
}

- (void)getDataForMonth:(NSInteger)month ofYear:(NSInteger)year
{
    self.month  = month;
    self.year   = year;
    
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.month                = month;
    components.year                 = year;
    NSDate *date                    = [calendar dateFromComponents:components];
    NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSArray *data                   = [StatisticalDataPointEntity dataPointsForMonth:month ofYear:year];
    
    if (data)
    {
        if (data.count > 0)
        {
            CGFloat heartRateMinValue[31]   = {};
            CGFloat heartRateMaxValue[31]   = {};
            CGFloat heartRateValue[31]      = {};
            CGFloat heartRateCount[31]      = {};
            NSMutableArray *heartRate       = [NSMutableArray new];
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index             = dataPoint.header.date.day.integerValue - 1;
                CGFloat heartRateFloat      = dataPoint.averageHR.floatValue;
                heartRateMaxValue[index]    = heartRateFloat > heartRateMaxValue[index] ? heartRateFloat: heartRateMaxValue[index];
                heartRateMinValue[index]    = heartRateMaxValue[index];
                heartRateValue[index]       += heartRateFloat;
                heartRateCount[index]       += heartRateFloat > 0;
            }
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index             = dataPoint.header.date.day.integerValue - 1;
                CGFloat heartRateFloat      = dataPoint.averageHR.floatValue;
                
                if (heartRateFloat > 0)
                {
                    heartRateMinValue[index]    = heartRateFloat < heartRateMinValue[index] ? heartRateFloat: heartRateMinValue[index];
                }
            }
            
            for (NSInteger day = 0; day < range.length; day++)
            {
                NSInteger bpmMin = heartRateMinValue[day] > 0 ?  heartRateMinValue[day] - 5 : 0;
                NSInteger bpmMax = heartRateMaxValue[day] > 0 ?  heartRateMaxValue[day] + 5 : 0;
                heartRateValue[day] /= heartRateCount[day];
                
                CGFloat x               = (self.barWidth + self.barSpace) * day;
                CGFloat maxY            = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:bpmMax];
                CGFloat minY            = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:bpmMin];
                NSDictionary *record    = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x], X_VALUE_KEY,
                                           [NSNumber numberWithFloat:maxY], Y_MAX_VALUE_KEY,
                                           [NSNumber numberWithFloat:minY], Y_MIN_VALUE_KEY,
                                           [NSNumber numberWithInt:heartRateValue[day]], BPM_VALUE_KEY,
                                           [NSNumber numberWithInt:heartRateMaxValue[day]], BPM_MAX_VALUE_KEY,
                                           [NSNumber numberWithInt:heartRateMinValue[day]], BPM_MIN_VALUE_KEY,
                                           nil];
                
                [heartRate addObject:record];
            }
            
            self.dataSource = heartRate.copy;
        }
        else
        {
            self.dataSource = nil;
        }
    }
    
    self.scrollView.contentOffset = CGPointZero;
    
    [self adjustGraphViewWidth];
    [self adjustBarPlotWidth];
    [self adjustTickLocation];
    if (_isPortrait)
        [self.graph dayPortraitLabelsWithMonth:month ofYear:year barWidth:self.barWidth barSpace:self.barSpace];
    else
        [self.graph dayLabelsWithMonth:month ofYear:year barWidth:self.barWidth barSpace:self.barSpace];
    [self.barPlot reloadData];
}

- (void)getDataForYear:(NSInteger)year
{
    NSArray *data = [StatisticalDataPointEntity dataPointsForYear:year];
    
    if (data)
    {
        if (data.count > 0)
        {
            CGFloat heartRateMinValue[12]   = {};
            CGFloat heartRateMaxValue[12]   = {};
            CGFloat heartRateValue[12]      = {};
            CGFloat heartRateCount[12]      = {};
            NSMutableArray *heartRate       = [NSMutableArray new];
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index             = dataPoint.header.date.month.integerValue - 1;
                CGFloat heartRateFloat      = dataPoint.averageHR.floatValue;
                heartRateMaxValue[index]    = heartRateFloat > heartRateMaxValue[index] ? heartRateFloat: heartRateMaxValue[index];
                heartRateMinValue[index]    = heartRateMaxValue[index];
                heartRateValue[index]       += heartRateFloat;
                heartRateCount[index]       += heartRateFloat > 0;
            }
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index             = dataPoint.header.date.month.integerValue - 1;
                CGFloat heartRateFloat      = dataPoint.averageHR.floatValue;
                
                if (heartRateFloat > 0)
                {
                    heartRateMinValue[index]    = heartRateFloat < heartRateMinValue[index] ? heartRateFloat: heartRateMinValue[index];
                }
            }
            
            for (NSInteger month = 0; month < 12; month++)
            {
                NSInteger bpmMin = heartRateMinValue[month] > 0 ?  heartRateMinValue[month] - 5 : 0;
                NSInteger bpmMax = heartRateMaxValue[month] > 0 ?  heartRateMaxValue[month] + 5 : 0;
                
                heartRateValue[month] /= heartRateCount[month];
                
                CGFloat x               = (self.barWidth + self.barSpace) * month;
                CGFloat maxY            = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:bpmMax];
                CGFloat minY            = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:bpmMin];
                NSDictionary *record    = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x], X_VALUE_KEY,
                                           [NSNumber numberWithFloat:maxY], Y_MAX_VALUE_KEY,
                                           [NSNumber numberWithFloat:minY], Y_MIN_VALUE_KEY,
                                           [NSNumber numberWithInt:heartRateValue[month]], BPM_VALUE_KEY,
                                           [NSNumber numberWithInt:heartRateMaxValue[month]], BPM_MAX_VALUE_KEY,
                                           [NSNumber numberWithInt:heartRateMinValue[month]], BPM_MIN_VALUE_KEY,
                                           nil];
                
                [heartRate addObject:record];
            }
            
            self.dataSource = heartRate.copy;
        }
        else
        {
            self.dataSource = nil;
        }
    }
    
    self.scrollView.contentOffset = CGPointZero;
    
    [self adjustGraphViewWidth];
    [self adjustBarPlotWidth];
    [self adjustTickLocation];
    [self.graph monthLabelsWithBarWidth:self.barWidth barSpace:self.barSpace];
    [self.barPlot reloadData];
}

#pragma mark - Public Methods

// Graph Methods

- (void)scrollToFirstRecord
{
    NSInteger firstRecordIndex = self.maxX;
    
    NSArray *dataSource = self.dataSource;
    
    for (NSDictionary *record in dataSource)
    {
        NSNumber *heartRate = [record objectForKey:Y_MAX_VALUE_KEY];
        
        if (heartRate.floatValue > 0)
        {
            NSInteger index = [dataSource indexOfObject:record];
            firstRecordIndex = index < firstRecordIndex ? index : firstRecordIndex;
            break;
        }
    }
    
    if (firstRecordIndex != self.maxX &&
        firstRecordIndex != 0)
    {
        CGRect firstRecordRect      = self.scrollView.frame;
        firstRecordRect.origin.x    = firstRecordIndex * (self.barWidth + self.barSpace);
        
        [UIView animateWithDuration:0.5f animations:^{
            self.scrollView.contentOffset = firstRecordRect.origin;
        }];
        
        //[self.scrollView scrollRectToVisible:firstRecordRect animated:NO];
    }
}

// Data Methods

- (void)setContentsWithDate:(NSDate *)date
{
    [self getDataForDate:date];
}

- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year
{
    [self getDataForWeek:week ofYear:year];
}

- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year
{
    [self getDataForMonth:month ofYear:year];
}

- (void)setContentsWithYear:(NSInteger)year
{
    [self getDataForYear:year];
}

@end
