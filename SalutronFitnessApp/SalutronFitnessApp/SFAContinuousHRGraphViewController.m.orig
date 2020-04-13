//
//  SFAContinuousHRGraphViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 11/26/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAContinuousHRGraphViewController.h"

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
#import "WorkoutHeaderEntity.h"
#import "WorkoutHeartRateDataEntity.h"
#import "DateEntity.h"

#define Y_MIN_VALUE_KEY     @"minValue"
#define Y_MAX_VALUE_KEY     @"maxValue"
#define X_VALUE_KEY         @"xValue"
#define BPM_VALUE_KEY       @"bpmValue"
#define BPM_MIN_VALUE_KEY   @"bpmMinValue"
#define BPM_MAX_VALUE_KEY   @"bpmMaxValue"

#define BPM_MIN_Y_VALUE 40
#define BPM_MAX_Y_VALUE 240
#define DAY_DATA_MAX_COUNT_WORKOUT 86400

@interface SFAContinuousHRGraphViewController () <UIScrollViewDelegate, CPTBarPlotDataSource, SFAGraphViewDelegate>

// Graph
@property (strong, nonatomic) SFAGraph                          *graph;
@property (strong, nonatomic) SFAXYPlotSpace                    *plotSpace;
@property (strong, nonatomic) SFABarPlot                        *barPlot;
@property (strong, nonatomic) SFAContinuousHRGraphViewController   *viewController;
@property (readonly, nonatomic) CGFloat                         maxX;
@property (readonly, nonatomic) CGFloat                         barWidth;
@property (readonly, nonatomic) CGFloat                         barSpace;
@property (readonly, nonatomic) CGFloat                         graphViewWidth;

// Data
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSArray *dataSourceCopy;
@property (readonly, nonatomic) CGFloat maxY;
@property (readwrite, nonatomic) NSInteger month;
@property (readwrite, nonatomic) NSInteger year;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphLeftHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphRightHorizontalSpace;
@property (readwrite, nonatomic) CGFloat                oldGraphViewHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewHeight;
@end

@implementation SFAContinuousHRGraphViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeObjects];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self _adjustView];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    _isPortrait = (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    self.dataSource = nil;
    [self.barPlot reloadData];
    [self _adjustView];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.loadingView.hidden = NO;
//    double delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self getDataForDate:self.date];
<<<<<<< HEAD
    });
=======
//    });

>>>>>>> 2cdef8b3de4aec53ec41c5048dbbbfbd464c27c2
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat x           = scrollView.contentOffset.x-10 < 0 ? 0 : scrollView.contentOffset.x-10;
    x                   = scrollView.contentOffset.x-10 > self.graphViewWidth ? self.graphViewWidth : x;
    //NSInteger index     = x / (self.graphViewWidth / (self.barWidth + self.barSpace));
    //index               = index < 144 ? index : 144;
    NSInteger index = x / (self.barSpace + self.barWidth);
    index           = index < self.maxX ? index : self.maxX;
    self.currentTime    = [self.calendarController currentTimeForIndex:index month:self.month year:self.year];
    /*
    CGFloat x           = scrollView.contentOffset.x < 0 ? 0 : scrollView.contentOffset.x;
    x                   = scrollView.contentOffset.x > self.graphViewWidth ? self.graphViewWidth : x;
    NSInteger index     = x / (self.barWidth + self.barSpace);
    index               = index < self.maxX ? index : self.maxX;
    self.currentTime    = [self.calendarController currentTimeForIndex:index month:self.month year:self.year];
    */
    if (index < 144 ? YES : NO)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %i", index];
        NSArray *matchedArray = [self.dataSource filteredArrayUsingPredicate:predicate];
        NSDictionary *record    = [matchedArray firstObject];//self.dataSource[index];
        self.currentHeartRate   = [[record objectForKey:BPM_VALUE_KEY] integerValue];;
        
        self.minHeartRate = [[record objectForKey:BPM_MIN_VALUE_KEY] integerValue];
        self.maxHeartRate = [[record objectForKey:BPM_MAX_VALUE_KEY] integerValue];
        
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
        /*
        else if (fieldEnum == CPTBarPlotFieldBarBase)
        {
            return [record objectForKey:Y_MIN_VALUE_KEY];
        }*/
    }
    
    return [NSNumber numberWithInt:0];
}

#pragma mark - Setters

- (void)setCurrentTime:(NSString *)currentTime
{
    if (![_currentTime isEqualToString:currentTime])
    {
        _currentTime = currentTime;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAContinuousHRGraphViewControllerDelegate)] &&
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
        
        if ([self.delegate conformsToProtocol:@protocol(SFAContinuousHRGraphViewControllerDelegate)] &&
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
        
        if ([self.delegate conformsToProtocol:@protocol(SFAContinuousHRGraphViewControllerDelegate)] &&
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
        
        if ([self.delegate conformsToProtocol:@protocol(SFAContinuousHRGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(graphViewController:didChangeMaxHeartRate:)])
        {
            [self.delegate graphViewController:self didChangeMaxHeartRate:maxHeartRate];
        }
    }
}

#pragma mark - Getters

- (CGFloat)maxX
{
    return DAY_DATA_MAX_COUNT;
}

- (CGFloat)barWidth
{
    return DAY_DATA_BAR_WIDTH;
}

- (CGFloat)barSpace
{
    return DAY_DATA_BAR_SPACE;
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
    
    
    if (_isPortrait)
        [self.graph hourPortraitLabelsWithBarWidth:self.barWidth barSpace:self.barSpace];
    else
        [self.graph hourLabelsWithBarWidth:self.barWidth barSpace:self.barSpace];
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
    self.graph.paddingBottom                = 0.0f;
    self.graph.plotAreaFrame.masksToBorder  = NO;
    self.graphView.hostedGraph              = self.graph;
    self.graphView.delegate                 = self;
    
    
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
    axisSet.xAxis.orthogonalCoordinateDecimal   = CPTDecimalFromFloat(0.1);
    axisSet.xAxis.majorTickLineStyle            = tickLineStyle.copy;
    axisSet.xAxis.majorTickLength               = 4.0f;
    axisSet.xAxis.tickDirection                 = CPTSignNegative;
    
    // Plot Space
    self.plotSpace          = (SFAXYPlotSpace *) self.graph.defaultPlotSpace;
    self.plotSpace.xRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(X_MIN_RANGE) length:CPTDecimalFromFloat(self.graphViewWidth)];
    self.plotSpace.yRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(Y_MAX_RANGE)];
    
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
    self.date = date;
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    StatisticalDataHeaderEntity *statisticalDataHeaderEntity = [StatisticalDataHeaderEntity statisticalDataHeaderEntityForDate:date];
    
    NSInteger dayMinHeartRate = [statisticalDataHeaderEntity.minHR integerValue];
    NSInteger dayMaxHeartRate = [statisticalDataHeaderEntity.maxHR integerValue];
    /*
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
     */
    //[self setMinAndMaxHeartRateForDate:date];
    
    NSArray *data = [StatisticalDataPointEntity dataPointsForDate:date];
    
    if (data)
    {
        if (data.count > 0)
        {
            /*
            NSMutableArray *heartRate = [NSMutableArray new];
            int averagehr = 0;
            int totalhr = 0;
            int minhr = 999;
            int maxhr = 0;
            */
            
            NSArray *continuousHR = [WorkoutHeaderEntity getWorkoutHeartRateWithMinMaxDataWithDate:date];
            
            //group hr per 10 mins
            int totalHR = 0;
            int totalCount = 0;
            NSInteger datapointIndex = [[[continuousHR firstObject] objectForKey:@"index"] integerValue]/600;
            NSInteger minHR = 999;
            NSInteger maxHR = 0;
            NSMutableArray *hrArray = [[NSMutableArray alloc] init];
            for (NSDictionary *hrEntity in continuousHR) {
                
                NSInteger hrValue = [hrEntity[@"hrData"] integerValue];
                NSInteger minhrValue = hrValue;//[hrEntity[@"min"] integerValue];
                NSInteger maxhrValue = hrValue;//[hrEntity[@"max"] integerValue];
                NSInteger index = [hrEntity[@"index"] integerValue];
                
                if (hrValue > 0) {
                    if (datapointIndex == index/600) {
                        if (minhrValue < minHR) {
                            minHR = minhrValue;
                        }
                        if (maxhrValue > maxHR) {
                            maxHR = maxhrValue;
                        }
                        totalHR += hrValue;
                        totalCount++;
                        if ([hrEntity isEqual:[continuousHR lastObject]]) {
                            //save avg hr
                            NSInteger averageHR = totalHR/totalCount;
                            CGFloat maxY = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:averageHR];
                            CGFloat minY = 0.0f;
                            CGFloat x = (self.barWidth + self.barSpace) * datapointIndex;
                            NSDictionary *hrDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithFloat:x], X_VALUE_KEY,
                                                    [NSNumber numberWithFloat:maxY], Y_MAX_VALUE_KEY,
                                                    [NSNumber numberWithFloat:minY], Y_MIN_VALUE_KEY,
                                                    [NSNumber numberWithInt:averageHR], BPM_VALUE_KEY,
                                                    [NSNumber numberWithInteger:maxHR], BPM_MAX_VALUE_KEY,
                                                    [NSNumber numberWithInteger:minHR], BPM_MIN_VALUE_KEY,
                                                    [NSNumber numberWithInteger:datapointIndex], @"index",
                                                    nil];
                            [hrArray addObject:hrDict];
                        }
                    }
                    else{
                        //save avg hr
                        NSInteger averageHR = totalHR/totalCount;
                        CGFloat maxY = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:averageHR];
                        CGFloat minY = 0.0f;

                        CGFloat x = (self.barWidth + self.barSpace) * datapointIndex;
                        NSDictionary *hrDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithFloat:x], X_VALUE_KEY,
                                                [NSNumber numberWithFloat:maxY], Y_MAX_VALUE_KEY,
                                                [NSNumber numberWithFloat:minY], Y_MIN_VALUE_KEY,
                                                [NSNumber numberWithInt:averageHR], BPM_VALUE_KEY,
                                                [NSNumber numberWithInteger:maxHR], BPM_MAX_VALUE_KEY,
                                                [NSNumber numberWithInteger:minHR], BPM_MIN_VALUE_KEY,
                                                [NSNumber numberWithInteger:datapointIndex], @"index",
                                                nil];
                        [hrArray addObject:hrDict];
                        //next index
                        datapointIndex = index/600;
                        minHR = 999;
                        maxHR = 0;
                        totalCount = 0;
                        totalHR = 0;
                        if (minhrValue < minHR) {
                            minHR = minhrValue;
                        }
                        if (maxhrValue > maxHR) {
                            maxHR = maxhrValue;
                        }
                        totalHR += hrValue;
                        totalCount++;
                        
                        if ([hrEntity isEqual:[continuousHR lastObject]]) {
                            //save avg hr
                            NSInteger averageHR = totalHR/totalCount;
                            CGFloat maxY = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:averageHR];
                            CGFloat minY = 0.0f;
                            CGFloat x = (self.barWidth + self.barSpace) * datapointIndex;
                            NSDictionary *hrDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithFloat:x], X_VALUE_KEY,
                                                    [NSNumber numberWithFloat:maxY], Y_MAX_VALUE_KEY,
                                                    [NSNumber numberWithFloat:minY], Y_MIN_VALUE_KEY,
                                                    [NSNumber numberWithInt:averageHR], BPM_VALUE_KEY,
                                                    [NSNumber numberWithInteger:maxHR], BPM_MAX_VALUE_KEY,
                                                    [NSNumber numberWithInteger:minHR], BPM_MIN_VALUE_KEY,
                                                    [NSNumber numberWithInteger:datapointIndex], @"index",
                                                    nil];
                            [hrArray addObject:hrDict];
                        }
                    }
                }
                else{
                    if ([hrEntity isEqual:[continuousHR lastObject]]) {
                        //save avg hr
                        NSInteger averageHR = totalHR/totalCount;
                        CGFloat maxY = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:averageHR];
                        CGFloat minY = 0.0f;
                        CGFloat x = (self.barWidth + self.barSpace) * datapointIndex;
                        NSDictionary *hrDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithFloat:x], X_VALUE_KEY,
                                                [NSNumber numberWithFloat:maxY], Y_MAX_VALUE_KEY,
                                                [NSNumber numberWithFloat:minY], Y_MIN_VALUE_KEY,
                                                [NSNumber numberWithInt:averageHR], BPM_VALUE_KEY,
                                                [NSNumber numberWithInteger:maxHR], BPM_MAX_VALUE_KEY,
                                                [NSNumber numberWithInteger:minHR], BPM_MIN_VALUE_KEY,
                                                [NSNumber numberWithInteger:datapointIndex], @"index",
                                                nil];
                        if (averageHR > 0) {
                            [hrArray addObject:hrDict];
                        }
                    }
                }
            }
            
            
            
            
            /*
            for (NSDictionary *hrEntity in continuousHR) {
                NSInteger index         = [hrEntity[@"index"] integerValue];
                CGFloat x               = (self.graphViewWidth) * ((index*1.0)/DAY_DATA_MAX_COUNT_WORKOUT);//(self.barWidth + self.barSpace) * index;
                CGFloat maxY            = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:[hrEntity[@"hrData"] integerValue]];
                CGFloat minY            = 0.0f;
                
                totalhr += [hrEntity[@"hrData"] integerValue];
                if ([hrEntity[@"hrData"] integerValue]>0) {
                    minhr = [hrEntity[@"hrData"] integerValue] < minhr ? [hrEntity[@"hrData"] intValue] : minhr;
                    maxhr = [hrEntity[@"hrData"] integerValue] > maxhr ? [hrEntity[@"hrData"] intValue] : maxhr;
                }
                
                NSDictionary *record    = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x], X_VALUE_KEY,
                                           [NSNumber numberWithFloat:maxY], Y_MAX_VALUE_KEY,
                                           [NSNumber numberWithFloat:minY], Y_MIN_VALUE_KEY,
                                           [NSNumber numberWithInt:[hrEntity[@"hrData"] integerValue]], BPM_VALUE_KEY,
                                           [NSNumber numberWithInteger:[hrEntity[@"max"] integerValue]], BPM_MAX_VALUE_KEY,
                                           [NSNumber numberWithInteger:[hrEntity[@"min"] integerValue]], BPM_MIN_VALUE_KEY,
                                           [NSNumber numberWithInteger:index], @"index",
                                           nil];
                
                [heartRate addObject:record];

            }
            */
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                if (dataPoint.averageHR.integerValue > 0) {
                    NSInteger index         = [data indexOfObject:dataPoint];
                    CGFloat x = (self.barWidth + self.barSpace) * index;
                    CGFloat maxY            = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:dataPoint.averageHR.floatValue];
                    CGFloat minY            = 0.0f;
                    NSDictionary *record    = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x], X_VALUE_KEY,
                                               [NSNumber numberWithFloat:maxY], Y_MAX_VALUE_KEY,
                                               [NSNumber numberWithFloat:minY], Y_MIN_VALUE_KEY,
                                               [NSNumber numberWithInt:dataPoint.averageHR.intValue], BPM_VALUE_KEY,
                                               [NSNumber numberWithInteger:dayMaxHeartRate], BPM_MAX_VALUE_KEY,
                                               [NSNumber numberWithInteger:dayMinHeartRate], BPM_MIN_VALUE_KEY,
                                               [NSNumber numberWithInteger:index], @"index",
                                               nil];
                    
                    [hrArray addObject:record];
                }
            }
            
            NSInteger minimumBPM = 999;
            NSInteger maximumBPM = 0;
            NSInteger averageBPM = 0;
            NSInteger totalBPMCount = 0;
            NSInteger totalBPM = 0;
            for (NSDictionary *hrDataDict in hrArray) {
                NSInteger hrDataDictAve = [hrDataDict[BPM_VALUE_KEY] integerValue];
                NSInteger minhrDataDictAve = [hrDataDict[BPM_MIN_VALUE_KEY] integerValue];
                NSInteger maxhrDataDictAve = [hrDataDict[BPM_MAX_VALUE_KEY] integerValue];
                if (hrDataDictAve > 0) {
                    totalBPM += hrDataDictAve;
                    totalBPMCount++;
                    if (minhrDataDictAve < minimumBPM) {
                        minimumBPM = minhrDataDictAve;
                    }
                    if (maxhrDataDictAve > maximumBPM) {
                        maximumBPM = maxhrDataDictAve;
                    }
                }
            }
            averageBPM = totalBPM/totalBPMCount;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (averageBPM > 0) {
                    self.maxHeartRate = maximumBPM;
                    self.minHeartRate = minimumBPM;
                    self.currentHeartRate = averageBPM;
                }
                else{
                    self.maxHeartRate = 0;
                    self.minHeartRate = 0;
                    self.currentHeartRate = 0;
                }
            
                self.dataSource = hrArray.copy;
                self.dataSourceCopy = hrArray.copy;
                /*
            if (self.isPortrait && heartRate.count > 0) {
                self.currentHeartRate = averagehr;
                self.minHeartRate = minhr;
                self.maxHeartRate = maxhr;
            }
            else{
                self.currentHeartRate = 0;
                self.minHeartRate = 0;
                self.maxHeartRate = 0;
            }
                 */
            });
        }
        else {
            self.dataSource = nil;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
    self.scrollView.contentOffset = CGPointZero;
    
    //});
    
        [self adjustGraphViewWidth];
        [self.barPlot reloadData];
        [self adjustBarPlotWidth];
        [self adjustTickLocation];
        if (_isPortrait)
            [self.graph hourPortraitLabelsWithBarWidth:self.barWidth barSpace:self.barSpace];
        else
            [self.graph hourLabelsWithBarWidth:self.barWidth barSpace:self.barSpace];
        self.loadingView.hidden = YES;
    });
 
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


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.delegate hrgraphViewControllerTouchStarted];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //[self.delegate hrgraphViewController:self didEndScroll:scrollView.contentOffset];
    [self.delegate hrgraphViewControllerTouchEnded];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //[self.delegate hrgraphViewController:self didEndScroll:scrollView.contentOffset];
    [self.delegate hrgraphViewControllerTouchEnded];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    //[self.delegate hrgraphViewController:self didEndScroll:scrollView.contentOffset];
    [self.delegate hrgraphViewControllerTouchEnded];
}

- (void)graphTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.delegate hrgraphViewControllerTouchStarted];
}
- (void)graphTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.delegate hrgraphViewControllerTouchEnded];
}


@end

