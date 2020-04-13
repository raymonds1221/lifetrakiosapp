//
//  SFAFitnessGraphViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/4/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAFitnessGraphViewController.h"
#import "SFAMainViewController.h"

#import "SFAGraphView.h"
#import "SFAGraph.h"
#import "SFAGraphTools.h"
#import "SFAXYPlotSpace.h"
#import "SFABarPlot.h"
#import "SFABarPlot+Type.h"
#import "CPTGraph+Label.h"

#import "TimeDate+Data.h"

#import "StatisticalDataHeaderEntity.h"
#import "StatisticalDataPointEntity+Data.h"
#import "StatisticalDataPointEntity.h"
#import "DateEntity.h"
#import "TimeEntity.h"

#import "UIViewController+Helper.h"

@interface SFAFitnessGraphViewController () <UIScrollViewDelegate, CPTBarPlotDataSource, SFABarPlotDelegate, CPTAnimationDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewRightHorizontalSpace;
@property (readwrite, nonatomic) CGFloat                oldGraphViewHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewHeight;

// Graph
@property (strong, nonatomic) SFAGraph          *graph;
@property (strong, nonatomic) SFAXYPlotSpace    *plotSpace;
@property (strong, nonatomic) SFABarPlot        *caloriesPlot;
@property (strong, nonatomic) SFABarPlot        *heartRatePlot;
@property (strong, nonatomic) SFABarPlot        *stepsPlot;
@property (strong, nonatomic) SFABarPlot        *distancePlot;
@property (strong, nonatomic) SFABarPlot        *barPlot;
@property (strong, nonatomic) NSMutableArray    *visiblePlots;

// Data
@property (strong, nonatomic) NSArray *calories;
@property (strong, nonatomic) NSArray *heartRate;
@property (strong, nonatomic) NSArray *steps;
@property (strong, nonatomic) NSArray *distance;
@property (strong, nonatomic) NSArray *calorieDataPoint;
@property (strong, nonatomic) NSArray *heartRateDataPoint;
@property (strong, nonatomic) NSArray *stepsDataPoint;
@property (strong, nonatomic) NSArray *distanceDataPoint;


// Ranges
@property (strong, nonatomic) NSNumber *caloriesMaxY;
@property (strong, nonatomic) NSNumber *heartRateMaxY;
@property (strong, nonatomic) NSNumber *stepsMaxY;
@property (strong, nonatomic) NSNumber *distanceMaxY;

// Date
@property (readwrite, nonatomic) NSInteger month;
@property (readwrite, nonatomic) NSInteger year;

//Getters
@property (readwrite, nonatomic) CGFloat graphViewWidth;

@end

@implementation SFAFitnessGraphViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initializeObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self _adjustView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _isPortrait = (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    [self _adjustView];
}

#pragma mark - Setters

- (void)setCurrentTime:(NSString *)currentTime
{
    if (![_currentTime isEqualToString:currentTime])
    {
        _currentTime = currentTime;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAFitnessGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(graphViewController:didChangeTime:)])
        {
            [self.delegate graphViewController:self didChangeTime:currentTime];
        }
    }
}

- (void)setCurrentCalories:(NSInteger)currentCalories
{
    if (_currentCalories != currentCalories)
    {
        _currentCalories = currentCalories;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAFitnessGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(graphViewController:didChangeCalories:)])
        {
            [self.delegate graphViewController:self didChangeCalories:currentCalories];
        }
    }
}

- (void)setCurrentHeartRate:(NSInteger)currentHeartRate
{
    if (_currentHeartRate != currentHeartRate)
    {
        _currentHeartRate = currentHeartRate;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAFitnessGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(graphViewController:didChangeHeartRate:)])
        {
            [self.delegate graphViewController:self didChangeHeartRate:currentHeartRate];
        }
    }
}

- (void)setCurrentSteps:(NSInteger)currentSteps
{
    if (_currentSteps != currentSteps)
    {
        _currentSteps = currentSteps;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAFitnessGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(graphViewController:didChangeSteps:)])
        {
            [self.delegate graphViewController:self didChangeSteps:currentSteps];
        }
    }
}

- (void)setCurrentDistance:(CGFloat)currentDistance
{
    if (_currentDistance != currentDistance) {
        _currentDistance = currentDistance;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAFitnessGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(graphViewController:didChangeDistance:)])
        {
            [self.delegate graphViewController:self didChangeDistance:currentDistance];
        }
    }
}

- (void)setTotalCalories:(NSInteger)totalCalories
{
    if(_totalCalories != totalCalories) {
        _totalCalories = totalCalories;
        
        if([self.delegate conformsToProtocol:@protocol(SFAFitnessGraphViewControllerDelegate)] &&
           [self.delegate respondsToSelector:@selector(graphViewController:didGetTotalCalories:)]) {
            [self.delegate graphViewController:self didGetTotalCalories:totalCalories];
        }
    }
}

- (void)setTotalHeartRate:(NSInteger)totalHeartRate
{
    if(_totalHeartRate != totalHeartRate) {
        _totalHeartRate = totalHeartRate;
        
        if([self.delegate conformsToProtocol:@protocol(SFAFitnessGraphViewControllerDelegate)] &&
           [self.delegate respondsToSelector:@selector(graphViewController:didGetTotalHeartRate:)]) {
            [self.delegate graphViewController:self didGetTotalHeartRate:totalHeartRate];
        }
    }
}

- (void)setTotalSteps:(CGFloat)totalSteps
{
    if(_totalSteps != totalSteps) {
        _totalSteps = totalSteps;
        
        if([self.delegate conformsToProtocol:@protocol(SFAFitnessGraphViewControllerDelegate)] &&
           [self.delegate respondsToSelector:@selector(graphViewController:didGetTotalSteps:)]) {
            [self.delegate graphViewController:self didGetTotalSteps:totalSteps];
        }
    }
}

- (void)setTotalDistance:(CGFloat)totalDistance
{
    if(_totalDistance != totalDistance) {
        _totalDistance = totalDistance;
        
        if([self.delegate conformsToProtocol:@protocol(SFAFitnessGraphViewControllerDelegate)] &&
           [self.delegate respondsToSelector:@selector(graphViewController:didGetTotalDistance:)]) {
            [self.delegate graphViewController:self didGetTotalDistance:totalDistance];
        }
    }
}

#pragma mark - Getters

- (CGFloat)graphViewWidth
{
    _graphViewWidth = self.maxBarWidth * self.maxX;
    _graphViewWidth += (self.maxX * self.barSpace);
    
    //BROWNBAG ITEM - Show return value on debugger
    return _graphViewWidth;//self.maxBarWidth * self.maxX + (self.maxX * self.barSpace);
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat x           = scrollView.contentOffset.x < 0 ? 0 : scrollView.contentOffset.x;
    x                   = scrollView.contentOffset.x > self.graphViewWidth ? self.graphViewWidth : x;
    NSInteger index     = x / (self.maxBarWidth + self.barSpace);
    index               = index < self.maxX ? index : self.maxX;
    self.currentTime    = [self.calendarController currentTimeForIndex:index month:self.month year:self.year];
    
    if (index < self.calories.count &&
        index < self.steps.count &&
        index < self.distance.count)
    {
        // Points
        CGPoint caloriesPoint   = [self.calories[index] CGPointValue];
        CGPoint heartRatePoint  = [self.heartRate[index] CGPointValue];
        CGPoint stepsPoint      = [self.steps[index] CGPointValue];
        CGPoint distancePoint   = [self.distance[index] CGPointValue];
        
        // Values
        if (!_isPortrait)
        {
            if (self.calendarController.calendarMode == SFACalendarDay)
            {
                self.currentCalories    = [self.calorieDataPoint[index] integerValue];
                self.currentHeartRate   = [self.heartRateDataPoint[index] integerValue];
                self.currentSteps       = [self.stepsDataPoint[index] integerValue];
                self.currentDistance    = [self.distanceDataPoint[index] floatValue];
            }
            else
            {
                self.currentCalories    = [SFAGraphTools yValueForMaxY:self.caloriesMaxY.floatValue y:caloriesPoint.y];
                self.currentHeartRate   = [SFAGraphTools yValueForMaxY:self.heartRateMaxY.floatValue y:heartRatePoint.y];
                self.currentSteps       = [SFAGraphTools yValueForMaxY:self.stepsMaxY.floatValue y:stepsPoint.y];
                self.currentDistance    = [SFAGraphTools yValueForMaxY:self.distanceMaxY.floatValue y:distancePoint.y];
            }
        }
    }
    else
    {
        // Values
        self.currentCalories    = 0;
        self.currentHeartRate   = 0;
        self.currentSteps       = 0;
        self.currentDistance    = 0.0f;
    }
}

#pragma mark - CPTAnimationDelegate Methods

- (void)animationDidFinish:(CPTAnimationOperation *)operation
{
    
}

#pragma mark - CPTBarPlotDataSource Methods

- (CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx
{
    SFAGraphType graphType  = [self graphTypeForIndex:idx];
    UIColor *color          = [self barColorForGraphType:graphType];
    CPTFill *fill           = [CPTFill fillWithColor:[CPTColor colorWithCGColor:color.CGColor]];
    
    return fill;
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if (plot == self.barPlot)
    {
        NSInteger recordCount = 0;
        
        if ([self.visiblePlots containsObject:[NSNumber numberWithInt:SFAGraphTypeCalories]])
        {
            recordCount += self.calories.count;
        }
        
        if ([self.visiblePlots containsObject:[NSNumber numberWithInt:SFAGraphTypeHeartRate]])
        {
            recordCount += self.heartRate.count;
        }
        
        if ([self.visiblePlots containsObject:[NSNumber numberWithInt:SFAGraphTypeSteps]])
        {
            recordCount += self.steps.count;
        }
        
        if ([self.visiblePlots containsObject:[NSNumber numberWithInt:SFAGraphTypeDistance]])
        {
            recordCount += self.distance.count;
        }
        
        return recordCount;
    }
    
    return 0;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    SFAGraphType graphType  = [self graphTypeForIndex:idx];
    NSArray *dataSource     = [self dataSourceForGraphType:graphType];
    CGPoint point           = [[dataSource objectAtIndex:idx / self.visiblePlots.count] CGPointValue];
    
    if (fieldEnum == CPTBarPlotFieldBarLocation)
    {
        NSInteger graphIndex = idx % self.visiblePlots.count;
        point.x += self.barWidth * graphIndex;
        return [NSNumber numberWithFloat:point.x];
    }
    else if (fieldEnum == CPTBarPlotFieldBarTip)
    {
        return [NSNumber numberWithFloat:point.y];
    }
    
    return [NSNumber numberWithInt:0];
}

#pragma mark - SFABarPlotDataDelegate Methods

- (NSInteger)numberOfBarForBarPlot:(SFABarPlot *)barPlot
{
    BarPlotType type;
    if (barPlot == self.caloriesPlot)
    {
        type = CALORIE_PLOT;
//        return self.calories.count;
    }
    else if (barPlot == self.heartRatePlot)
    {
        type = HEARTRATE_PLOT;
//        return self.heartRate.count;
    }
    else if (barPlot == self.stepsPlot)
    {
        type = STEPS_PLOT;
//        return self.steps.count;
    }
    else
    {
        type = DISTANCE_PLOT;
//        return self.distance.count;
    }
//    return 0;
    
    return [barPlot numberOfBarForBarPlot:barPlot ofType:type withArrays:@[self.calories, self.heartRate, self.steps, self.distance]];
}

- (CGPoint)barPlot:(SFABarPlot *)barPlot pointAtIndex:(NSInteger)index
{
    BarPlotType type;
    if (barPlot == self.caloriesPlot)
    {
        type = CALORIE_PLOT;
        //        return self.calories.count;
    }
    else if (barPlot == self.heartRatePlot)
    {
        type = HEARTRATE_PLOT;
        //        return self.heartRate.count;
    }
    else if (barPlot == self.stepsPlot)
    {
        type = STEPS_PLOT;
        //        return self.steps.count;
    }
    else
    {
        type = DISTANCE_PLOT;
        //        return self.distance.count;
    }
    
    return [barPlot barPlot:barPlot pointAtIndex:index ofType:type withArrays:@[self.calories, self.heartRate, self.steps, self.distance]];
}

#pragma mark - Private Methods

- (void)_adjustView
{
    if (_isPortrait)
    {
        self.graphViewHorizontalSpace.constant      = 0.0f;
        self.graphViewRightHorizontalSpace.constant = 0.0f;
        self.scrollView.scrollEnabled               = NO;
    }
    else
    {
        if(self.isIOS8AndAbove) { // added support for iOS 8
            self.graphViewHorizontalSpace.constant      = (self.view.window.frame.size.width / 2);
            self.graphViewRightHorizontalSpace.constant = self.view.window.frame.size.width / 2;
        } else {
            self.graphViewHorizontalSpace.constant      = (self.view.window.frame.size.height / 2);
            self.graphViewRightHorizontalSpace.constant = self.view.window.frame.size.height / 2;
        }
        
        self.scrollView.scrollEnabled               = YES;
    }
    
    [self adjustGraphViewWidth];
    [self adjustBarPlotWidth];
    [self adjustTickLocation];
}

// Bar Plot

- (SFABarPlot *)barPlotWithBarColor:(UIColor *)barColor
{
    // Bar Plot
    SFABarPlot *barPlot     = [SFABarPlot barPlot];
    barPlot.anchorPoint     = CGPointZero;
    barPlot.dataDelegate    = self;
    barPlot.fill            = [CPTFill fillWithColor:[CPTColor colorWithCGColor:barColor.CGColor]];
    barPlot.lineStyle       = nil;
    
    return barPlot;
}

// Bar Plot Animations

- (CABasicAnimation *)growthAnimation
{
    CABasicAnimation *animation     = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration              = 0.5f;
    animation.removedOnCompletion   = YES;
    CATransform3D transform         = CATransform3DMakeScale(1, 0.0001, 1);
    transform                       = CATransform3DConcat(transform, CATransform3DMakeTranslation(0, 16.5, 0));
    animation.fromValue             = [NSValue valueWithCATransform3D:transform];
    animation.toValue               = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.delegate              = self;
    
    return animation;
}

- (SFABarPlot *)plotForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return self.caloriesPlot;
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        return self.distancePlot;
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        return self.heartRatePlot;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        return self.stepsPlot;
    }
    
    return nil;
}

- (NSArray *)dataSourceForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return self.calories;
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        return self.distance;
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        return self.heartRate;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        return self.steps;
    }
    
    return nil;
}

- (UIColor *)barColorForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return CALORIES_LINE_COLOR;
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        return DISTANCE_LINE_COLOR;
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        return HEART_RATE_LINE_COLOR;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        return STEPS_LINE_COLOR;
    }
    
    return nil;
}

- (SFAGraphType)graphTypeForIndex:(NSInteger)index
{
    index = index % self.visiblePlots.count;
    return [self.visiblePlots[index] integerValue];
}

- (void)addDataSource:(NSArray *)dataSource forGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        self.calories = dataSource;
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        self.distance = dataSource;
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        self.heartRate = dataSource;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        self.steps = dataSource;
    }
}

- (void)removeDataSourceForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        self.calories = nil;
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        self.distance = nil;
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        self.heartRate = nil;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        self.steps = nil;
    }
}

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
        components.month                = self.month;
        components.year                 = self.year;
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

- (CGFloat)maxBarWidth
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

- (CGFloat)barWidth
{
    return self.maxBarWidth / self.barPlotCount;
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

- (void)adjustBarPlotWidth
{
    /*for (SFABarPlot *plot in self.visiblePlots)
    {
        NSInteger index     = [self.visiblePlots indexOfObject:plot];
        plot.barWidth       = CPTDecimalFromCGFloat(self.barWidth);
        plot.barOffset      = CPTDecimalFromCGFloat(self.barWidth * index + (self.barSpace * 0.5f) + (self.barWidth * 0.5f));
    }*/
    
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
            NSDecimal tickLocation  = CPTDecimalFromInt(a * (self.maxBarWidth + self.barSpace));
            NSNumber *number        = [NSDecimalNumber decimalNumberWithDecimal:tickLocation];
            
            [tickLocations addObject:number];
        }
        
        CPTXYAxisSet *axisSet               = (CPTXYAxisSet *) self.graph.axisSet;
        axisSet.xAxis.majorTickLocations    = tickLocations.copy;
    }
}

- (void)adjustGraphViewWidth
{
    self.graphViewWidthConstraint.constant  = (_isPortrait) ? self.view.frame.size.width : self.graphViewWidth;
    self.plotSpace.xRange                   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f)
                                                                           length:CPTDecimalFromFloat(self.graphViewWidth)];
}

- (void)scrollToFirstRecord
{
    NSInteger firstRecordIndex = self.maxX;
    
    for (NSNumber *graphType in self.visiblePlots)
    {
        NSArray *dataSource = [self dataSourceForGraphType:graphType.integerValue];
        
        for (NSValue *value in dataSource)
        {
            CGPoint point = value.CGPointValue;
            
            if (point.y > 0)
            {
                NSInteger index = [dataSource indexOfObject:value];
                firstRecordIndex = index < firstRecordIndex ? index : firstRecordIndex;
                break;
            }
        }
    }
    
    if (firstRecordIndex != self.maxX &&
        firstRecordIndex != 0)
    {
        CGRect firstRecordRect      = self.scrollView.frame;
        firstRecordRect.origin.x    = firstRecordIndex * (self.maxBarWidth + self.barSpace);
        
        [UIView animateWithDuration:0.5f animations:^{
            self.scrollView.contentOffset = firstRecordRect.origin;
        }];
        
        //[self.scrollView scrollRectToVisible:firstRecordRect animated:NO];
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
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        self.graphViewHeight.constant = 155;
    }
    
    // Axis Line Style
    CPTXYAxisSet *axisSet                       = (CPTXYAxisSet *) self.graph.axisSet;
    CPTMutableLineStyle *lineStyle              = axisSet.xAxis.axisLineStyle.mutableCopy;
    lineStyle.lineColor                         = [CPTColor clearColor];
    axisSet.xAxis.axisLineStyle                 = lineStyle.copy;
    axisSet.yAxis.hidden                        = YES;
    axisSet.yAxis.labelTextStyle                = nil;
    
    // Axis Text Style
    CPTMutableTextStyle *textStyle  = axisSet.xAxis.labelTextStyle.mutableCopy;
    textStyle.fontSize              = 10.0f;
    axisSet.xAxis.labelTextStyle    = textStyle.copy;
    axisSet.xAxis.labelingPolicy    = CPTAxisLabelingPolicyNone;
    
    // Tick Mark Style
    CPTMutableLineStyle *tickLineStyle  = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor             = [CPTColor grayColor];
    tickLineStyle.lineWidth             = 1.0f;
    axisSet.xAxis.majorTickLineStyle    = tickLineStyle.copy;
    axisSet.xAxis.majorTickLength       = 4.0f;
    axisSet.xAxis.tickDirection         = CPTSignNegative;
    
    //set portrait vaue
    _isPortrait                     = YES;
    _oldGraphViewHorizontalSpace    = self.graphViewHorizontalSpace.constant;
    
    
}

- (void)getDataForDate:(NSDate *)date
{
    NSArray *data = [StatisticalDataPointEntity dataPointsForDate:date];
    
    if (data)
    {
        if (data.count > 0)
        {
            self.caloriesMaxY   = [NSNumber numberWithFloat:0.0f];
            self.heartRateMaxY  = [NSNumber numberWithFloat:0.0f];
            self.stepsMaxY      = [NSNumber numberWithFloat:0.0f];
            self.distanceMaxY   = [NSNumber numberWithFloat:0.0f];
            
            self.totalCalories  = 0;
            self.totalDistance  = 0;
            self.totalSteps     = 0;
            self.totalHeartRate = 0;
            
            NSMutableArray *calories    = [NSMutableArray new];
            NSMutableArray *heartRate   = [NSMutableArray new];
            NSMutableArray *steps       = [NSMutableArray new];
            NSMutableArray *distance    = [NSMutableArray new];
            
            NSMutableArray *calorieDataPoint    = [NSMutableArray new];
            NSMutableArray *heartRateDataPoint  = [NSMutableArray new];
            NSMutableArray *stepsDataPoint      = [NSMutableArray new];
            NSMutableArray *distanceDataPoint   = [NSMutableArray new];
            
            CGFloat totalCalories    = 0.0f;
            CGFloat totalDistance    = 0.0f;
            CGFloat totalSteps       = 0.0f;
            CGFloat totalHeartRate   = 0.0f;
            
            //start debug
            CGFloat dpTotalCalories    = 0.0f;
            CGFloat dpTotalDistance    = 0.0f;
            CGFloat dpTotalSteps       = 0.0f;
            //end debug
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                self.caloriesMaxY    = [dataPoint.calorie isGreaterThan:self.caloriesMaxY] ? dataPoint.calorie : self.caloriesMaxY;
                self.heartRateMaxY   = [dataPoint.averageHR isGreaterThan:self.heartRateMaxY] ? dataPoint.averageHR : self.heartRateMaxY;
                self.stepsMaxY       = [dataPoint.steps isGreaterThan:self.stepsMaxY] ? dataPoint.steps : self.stepsMaxY;
                self.distanceMaxY    = [dataPoint.distance isGreaterThan:self.distanceMaxY] ? dataPoint.distance : self.distanceMaxY;
                
                totalCalories        += dataPoint.calorie.floatValue;
                totalDistance        += dataPoint.distance.floatValue;
                totalSteps           += dataPoint.steps.floatValue;
                totalHeartRate       = 0;
                
                //start debug
                dpTotalCalories += dataPoint.calorie.floatValue;
                dpTotalDistance += dataPoint.distance.floatValue;
                dpTotalSteps    += dataPoint.steps.floatValue;
                //end debug
            }
            //start debug
            DDLogError(@"number of datapoints = %i", data.count);
            DDLogError(@"dp calories %f = %f total calories", dpTotalCalories, totalCalories);
            DDLogError(@"dp steps %f = %f total steps", dpTotalSteps, totalSteps);
            DDLogError(@"dp distance %f = %f total distance", dpTotalDistance, totalDistance);
            //end debug
            
            self.totalCalories       = totalCalories;
            self.totalDistance       = totalDistance;
            self.totalSteps          = totalSteps;
            self.totalHeartRate      = totalHeartRate;
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index = [data indexOfObject:dataPoint];
                CGFloat x       = (self.maxBarWidth + self.barSpace) * index;
                CGFloat y;
                CGPoint point;
                
                // Calories
                y = [SFAGraphTools yWithMaxY:self.caloriesMaxY.floatValue yValue:dataPoint.calorie.floatValue];
                point = CGPointMake(x, y);
                
                [calories addObject:[NSValue valueWithCGPoint:point]];
                [calorieDataPoint addObject:dataPoint.calorie];
                
                
                // Heart Rate
                y = [SFAGraphTools yWithMaxY:self.heartRateMaxY.floatValue yValue:dataPoint.averageHR.floatValue];
                point = CGPointMake(x, y);
                
                [heartRate addObject:[NSValue valueWithCGPoint:point]];
                [heartRateDataPoint addObject:dataPoint.averageHR];
                
                // Steps
                y = [SFAGraphTools yWithMaxY:self.stepsMaxY.floatValue yValue:dataPoint.steps.floatValue];
                point = CGPointMake(x, y);
                
                [steps addObject:[NSValue valueWithCGPoint:point]];
                [stepsDataPoint addObject:dataPoint.steps];
                
                // Distance
                y = [SFAGraphTools yWithMaxY:self.distanceMaxY.floatValue yValue:dataPoint.distance.floatValue];
                point = CGPointMake(x, y);
                
                [distance addObject:[NSValue valueWithCGPoint:point]];
                [distanceDataPoint addObject:dataPoint.distance];
            }
            
            self.calories  = calories.copy;
            self.heartRate = heartRate.copy;
            self.steps     = steps.copy;
            self.distance  = distance.copy;
            
            self.calorieDataPoint   = calorieDataPoint.copy;
            self.distanceDataPoint  = distanceDataPoint.copy;
            self.stepsDataPoint     = stepsDataPoint.copy;
            self.heartRateDataPoint = heartRateDataPoint.copy;
        }
        else
        {
            self.calories  = nil;
            self.heartRate = nil;
            self.steps     = nil;
            self.distance  = nil;
            
            self.currentCalories    = 0;
            self.currentDistance    = 0;
            self.currentSteps       = 0;
            self.currentHeartRate   = 0;
            
            self.totalCalories  = 0;
            self.totalDistance  = 0;
            self.totalSteps     = 0;
            self.totalHeartRate = 0;
        }
    }
    
    self.scrollView.contentOffset = CGPointZero;
    
    if (_isPortrait)
        [self.graph hourPortraitLabelsWithBarWidth:self.barWidth barSpace:self.barSpace];
    else
        [self.graph hourLabelsWithBarWidth:self.barWidth barSpace:self.barSpace];
    [self reloadGraph];
    
    
    [self adjustGraphViewWidth];
    [self adjustBarPlotWidth];
    [self adjustTickLocation];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)getDataForWeek:(NSInteger)week ofYear:(NSInteger)year
{
    NSArray *data = [StatisticalDataPointEntity dataPointsForWeek:week ofYear:year];
    
    if (data)
    {
        if (data.count > 0)
        {
            self.caloriesMaxY   = [NSNumber numberWithFloat:0.0f];
            self.heartRateMaxY  = [NSNumber numberWithFloat:0.0f];
            self.stepsMaxY      = [NSNumber numberWithFloat:0.0f];
            self.distanceMaxY   = [NSNumber numberWithFloat:0.0f];
            
            CGFloat caloriesTotal[84]   = {0};
            CGFloat heartRateTotal[84]  = {0};
            CGFloat stepsTotal[84]      = {0};
            CGFloat distanceTotal[84]   = {0};
            
            NSInteger heartRateCount[84] = {0};
            
            NSMutableArray *calories    = [NSMutableArray new];
            NSMutableArray *heartRate   = [NSMutableArray new];
            NSMutableArray *steps       = [NSMutableArray new];
            NSMutableArray *distance    = [NSMutableArray new];
            
            StatisticalDataPointEntity *dataPoint   = [data objectAtIndex:0];
            NSCalendar *calendar                    = [NSCalendar currentCalendar];
            NSDateComponents *components            = [NSDateComponents new];
            components.month                        = dataPoint.header.date.month.integerValue;
            components.day                          = dataPoint.header.date.day.integerValue;
            components.year                         = dataPoint.header.date.year.integerValue + 1900;
            NSDate *date                            = [calendar dateFromComponents:components];
            components                              = [calendar components:NSWeekdayCalendarUnit fromDate:date];
            NSInteger startIndex                    = (components.weekday - 1) * 24 * 6;
            
            self.totalCalories  = 0;
            self.totalDistance  = 0;
            self.totalSteps     = 0;
            self.totalHeartRate = 0;
            
            CGFloat totalCalories    = 0.0f;
            CGFloat totalDistance    = 0.0f;
            CGFloat totalSteps       = 0.0f;
            CGFloat totalHeartRate   = 0.0f;
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index         = (startIndex + [data indexOfObject:dataPoint]) / 12;
                
               // if (dataPoint.dataPointID.integerValue == 1)
               // {
                    totalCalories  += dataPoint.calorie.floatValue;
                    totalDistance  += dataPoint.distance.floatValue;
                    totalSteps     += dataPoint.steps.floatValue;
                    totalHeartRate = 0;
               // }
                
                caloriesTotal[index]    += dataPoint.calorie.floatValue;
                heartRateTotal[index]   += dataPoint.averageHR.floatValue;
                stepsTotal[index]       += dataPoint.steps.floatValue;
                distanceTotal[index]    += dataPoint.distance.floatValue;
                
                heartRateCount[index]   += (dataPoint.averageHR.floatValue > 0 ? 1 : 0);
            }
            
            self.totalCalories          = totalCalories;
            self.totalDistance          = totalDistance;
            self.totalSteps             = totalSteps;
            self.totalHeartRate         = totalHeartRate;
            
            for (NSInteger index = 0; index < 84; index++)
            {
                heartRateTotal[index]   = heartRateCount[index] > 0 ? heartRateTotal[index] / heartRateCount[index] : 0;
                
                NSNumber *caloriesY     = [NSNumber numberWithFloat:caloriesTotal[index]];
                NSNumber *heartRateY    = [NSNumber numberWithFloat:heartRateTotal[index]];
                NSNumber *stepsY        = [NSNumber numberWithFloat:stepsTotal[index]];
                NSNumber *distanceY     = [NSNumber numberWithFloat:distanceTotal[index]];
                
                self.caloriesMaxY   = [caloriesY isGreaterThan:self.caloriesMaxY] ? caloriesY : self.caloriesMaxY;
                self.heartRateMaxY  = [heartRateY isGreaterThan:self.heartRateMaxY] ? heartRateY : self.heartRateMaxY;
                self.stepsMaxY      = [stepsY isGreaterThan:self.stepsMaxY] ? stepsY : self.stepsMaxY;
                self.distanceMaxY   = [distanceY isGreaterThan:self.distanceMaxY] ? distanceY : self.distanceMaxY;
            }
            
            for (NSInteger index = 0; index < 84; index++)
            {
                CGFloat x = (self.maxBarWidth + self.barSpace) * index;
                CGFloat y;
                CGPoint point;
                
                // Calories
                y = [SFAGraphTools yWithMaxY:self.caloriesMaxY.floatValue yValue:caloriesTotal[index]];
                point = CGPointMake(x, y);
                
                [calories addObject:[NSValue valueWithCGPoint:point]];
                
                // Heart Rate
                y = [SFAGraphTools yWithMaxY:self.heartRateMaxY.floatValue yValue:heartRateTotal[index]];
                point = CGPointMake(x, y);
                
                [heartRate addObject:[NSValue valueWithCGPoint:point]];
                
                // Steps
                y = [SFAGraphTools yWithMaxY:self.stepsMaxY.floatValue yValue:stepsTotal[index]];
                point = CGPointMake(x, y);
                
                [steps addObject:[NSValue valueWithCGPoint:point]];
                
                // Distance
                y = [SFAGraphTools yWithMaxY:self.distanceMaxY.floatValue yValue:distanceTotal[index]];
                point = CGPointMake(x, y);
                 
                [distance addObject:[NSValue valueWithCGPoint:point]];
            }
            
            self.calories  = calories.copy;
            self.heartRate = heartRate.copy;
            self.steps     = steps.copy;
            self.distance  = distance.copy;
        }
        else
        {
            self.calories  = nil;
            self.heartRate = nil;
            self.steps     = nil;
            self.distance  = nil;
            
            self.currentCalories    = 0;
            self.currentDistance    = 0;
            self.currentSteps       = 0;
            self.currentHeartRate   = 0;
            
            self.totalCalories  = 0;
            self.totalDistance  = 0;
            self.totalSteps     = 0;
            self.totalHeartRate = 0;
        }
    }
    
    self.scrollView.contentOffset = CGPointZero;
    
    if (_isPortrait)
        [self.graph dayPortraitLabelsWithWeek:week ofYear:year barWidth:self.maxBarWidth barSpace:self.barSpace];
    else
        [self.graph dayLabelsWithWeek:week ofYear:year barWidth:self.maxBarWidth barSpace:self.barSpace];
    
    
    [self reloadGraph];
    [self adjustGraphViewWidth];
    [self adjustBarPlotWidth];
    [self adjustTickLocation];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)getDataForMonth:(NSInteger)month ofYear:(NSInteger)year
{
    self.month  = month;
    self.year   = year;
    
    // Date
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
            self.caloriesMaxY   = [NSNumber numberWithFloat:0.0f];
            self.heartRateMaxY  = [NSNumber numberWithFloat:0.0f];
            self.stepsMaxY      = [NSNumber numberWithFloat:0.0f];
            self.distanceMaxY   = [NSNumber numberWithFloat:0.0f];
            
            self.totalCalories  = 0;
            self.totalDistance  = 0;
            self.totalSteps     = 0;
            self.totalHeartRate = 0;
            
            CGFloat caloriesTotal[31]   = {0};
            CGFloat heartRateTotal[31]  = {0};
            CGFloat stepsTotal[31]      = {0};
            CGFloat distanceTotal[31]   = {0};
            
            NSInteger heartRateCount[31] = {0};
            
            NSMutableArray *calories    = [NSMutableArray new];
            NSMutableArray *heartRate   = [NSMutableArray new];
            NSMutableArray *steps       = [NSMutableArray new];
            NSMutableArray *distance    = [NSMutableArray new];
            
            CGFloat totalCalories    = 0.0f;
            CGFloat totalDistance    = 0.0f;
            CGFloat totalSteps       = 0.0f;
            CGFloat totalHeartRate   = 0.0f;
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index         = dataPoint.header.date.day.integerValue - 1;
                
                caloriesTotal[index]    += dataPoint.calorie.floatValue;
                heartRateTotal[index]   += dataPoint.averageHR.floatValue;
                stepsTotal[index]       += dataPoint.steps.floatValue;
                distanceTotal[index]    += dataPoint.distance.floatValue;
                
                heartRateCount[index]   += (dataPoint.averageHR.floatValue > 0 ? 1 : 0);
                
              //  if (dataPoint.dataPointID.integerValue == 1)
              //  {
                    totalCalories  += dataPoint.calorie.floatValue;
                    totalDistance  += dataPoint.distance.floatValue;
                    totalSteps     += dataPoint.steps.floatValue;
                    totalHeartRate = 0;
               // }
            }
            
            self.totalCalories          = totalCalories;
            self.totalDistance          = totalDistance;
            self.totalSteps             = totalSteps;
            self.totalHeartRate         = totalHeartRate;
            
            for (NSInteger day = 0; day < range.length; day++)
            {
                heartRateTotal[day]   = heartRateCount[day] > 0 ? heartRateTotal[day] / heartRateCount[day] : 0;
                
                NSNumber *caloriesY     = [NSNumber numberWithFloat:caloriesTotal[day]];
                NSNumber *heartRateY    = [NSNumber numberWithFloat:heartRateTotal[day]];
                NSNumber *stepsY        = [NSNumber numberWithFloat:stepsTotal[day]];
                NSNumber *distanceY     = [NSNumber numberWithFloat:distanceTotal[day]];
                
                self.caloriesMaxY    = [caloriesY isGreaterThan:self.caloriesMaxY] ? caloriesY : self.caloriesMaxY;
                self.heartRateMaxY   = [heartRateY isGreaterThan:self.heartRateMaxY] ? heartRateY : self.heartRateMaxY;
                self.stepsMaxY       = [stepsY isGreaterThan:self.stepsMaxY] ? stepsY : self.stepsMaxY;
                self.distanceMaxY    = [distanceY isGreaterThan:self.distanceMaxY] ? distanceY : self.distanceMaxY;
            }
            
            for (NSInteger day = 0; day < range.length; day++)
            {
                CGFloat x = (self.maxBarWidth + self.barSpace) * day;
                CGFloat y;
                CGPoint point;
                
                // Calories
                y = [SFAGraphTools yWithMaxY:self.caloriesMaxY.floatValue yValue:caloriesTotal[day]];
                point = CGPointMake(x, y);
                
                [calories addObject:[NSValue valueWithCGPoint:point]];
                
                // Heart Rate
                y = [SFAGraphTools yWithMaxY:self.heartRateMaxY.floatValue yValue:heartRateTotal[day]];
                point = CGPointMake(x, y);
                
                [heartRate addObject:[NSValue valueWithCGPoint:point]];
                
                // Steps
                y = [SFAGraphTools yWithMaxY:self.stepsMaxY.floatValue yValue:stepsTotal[day]];
                point = CGPointMake(x, y);
                
                [steps addObject:[NSValue valueWithCGPoint:point]];
                
                // Distance
                y = [SFAGraphTools yWithMaxY:self.distanceMaxY.floatValue yValue:distanceTotal[day]];
                point = CGPointMake(x, y);
                
                [distance addObject:[NSValue valueWithCGPoint:point]];
            }
            
            self.calories  = calories.copy;
            self.heartRate = heartRate.copy;
            self.steps     = steps.copy;
            self.distance  = distance.copy;
        }
        else
        {
            self.calories  = nil;
            self.heartRate = nil;
            self.steps     = nil;
            self.distance  = nil;
            
            self.currentCalories    = 0;
            self.currentDistance    = 0;
            self.currentSteps       = 0;
            self.currentHeartRate   = 0;
            
            self.totalCalories  = 0;
            self.totalDistance  = 0;
            self.totalSteps     = 0;
            self.totalHeartRate = 0;
        }
    }
    
    self.scrollView.contentOffset = CGPointZero;
    
    if (_isPortrait)
        [self.graph dayPortraitLabelsWithMonth:month ofYear:year barWidth:self.maxBarWidth barSpace:self.barSpace];
    else
        [self.graph dayLabelsWithMonth:month ofYear:year barWidth:self.maxBarWidth barSpace:self.barSpace];
    
    [self reloadGraph];
    [self adjustGraphViewWidth];
    [self adjustBarPlotWidth];
    [self adjustTickLocation];
    [self reloadGraph];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)getDataForYear:(NSInteger)year
{
    NSArray *data = [StatisticalDataPointEntity dataPointsForYear:year];
    
    if (data)
    {
        if (data.count > 0)
        {
            self.caloriesMaxY   = [NSNumber numberWithFloat:0.0f];
            self.heartRateMaxY  = [NSNumber numberWithFloat:0.0f];
            self.stepsMaxY      = [NSNumber numberWithFloat:0.0f];
            self.distanceMaxY   = [NSNumber numberWithFloat:0.0f];
            
            self.totalCalories  = 0;
            self.totalDistance  = 0;
            self.totalSteps     = 0;
            self.totalHeartRate = 0;
            
            CGFloat caloriesTotal[12]   = {0};
            CGFloat heartRateTotal[12]  = {0};
            CGFloat stepsTotal[12]      = {0};
            CGFloat distanceTotal[12]   = {0};
            
            NSInteger heartRateCount[12] = {0};
            
            NSMutableArray *calories    = [NSMutableArray new];
            NSMutableArray *heartRate   = [NSMutableArray new];
            NSMutableArray *steps       = [NSMutableArray new];
            NSMutableArray *distance    = [NSMutableArray new];
            
            CGFloat totalCalories    = 0.0f;
            CGFloat totalDistance    = 0.0f;
            CGFloat totalSteps       = 0.0f;
            CGFloat totalHeartRate   = 0.0f;
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index         = dataPoint.header.date.month.integerValue - 1;
                caloriesTotal[index]    += dataPoint.calorie.floatValue;
                heartRateTotal[index]   += dataPoint.averageHR.floatValue;
                stepsTotal[index]       += dataPoint.steps.floatValue;
                distanceTotal[index]    += dataPoint.distance.floatValue;
                
                heartRateCount[index]   += (dataPoint.averageHR.floatValue > 0 ? 1 : 0);
                
                //if (dataPoint.dataPointID.integerValue == 1)
                //{
                    totalCalories  += dataPoint.calorie.floatValue;
                    totalDistance  += dataPoint.distance.floatValue;
                    totalSteps     += dataPoint.steps.floatValue;
                    totalHeartRate = 0;
                //}
            }
            
            self.totalCalories          = totalCalories;
            self.totalDistance          = totalDistance;
            self.totalSteps             = totalSteps;
            self.totalHeartRate         = totalHeartRate;
            
            for (NSInteger month = 0; month < 12; month++)
            {
                
                heartRateTotal[month]   = heartRateCount[month] > 0 ? heartRateTotal[month] / heartRateCount[month] : 0;
                
                NSNumber *caloriesY     = [NSNumber numberWithFloat:caloriesTotal[month]];
                NSNumber *heartRateY    = [NSNumber numberWithFloat:heartRateTotal[month]];
                NSNumber *stepsY        = [NSNumber numberWithFloat:stepsTotal[month]];
                NSNumber *distanceY     = [NSNumber numberWithFloat:distanceTotal[month]];
                
                self.caloriesMaxY    = [caloriesY isGreaterThan:self.caloriesMaxY] ? caloriesY : self.caloriesMaxY;
                self.heartRateMaxY   = [heartRateY isGreaterThan:self.heartRateMaxY] ? heartRateY : self.heartRateMaxY;
                self.stepsMaxY       = [stepsY isGreaterThan:self.stepsMaxY] ? stepsY : self.stepsMaxY;
                self.distanceMaxY    = [distanceY isGreaterThan:self.distanceMaxY] ? distanceY : self.distanceMaxY;
            }
            
            for (NSInteger month = 0; month < 12; month++)
            {
                CGFloat x = (self.maxBarWidth + self.barSpace) * month;
                CGFloat y;
                CGPoint point;
                
                // Calories
                y = [SFAGraphTools yWithMaxY:self.caloriesMaxY.floatValue yValue:caloriesTotal[month]];
                point = CGPointMake(x, y);
                
                [calories addObject:[NSValue valueWithCGPoint:point]];
                
                // Heart Rate
                y = [SFAGraphTools yWithMaxY:self.heartRateMaxY.floatValue yValue:heartRateTotal[month]];
                point = CGPointMake(x, y);
                
                [heartRate addObject:[NSValue valueWithCGPoint:point]];
                
                // Steps
                y = [SFAGraphTools yWithMaxY:self.stepsMaxY.floatValue yValue:stepsTotal[month]];
                point = CGPointMake(x, y);
                
                [steps addObject:[NSValue valueWithCGPoint:point]];
                
                // Distance
                y = [SFAGraphTools yWithMaxY:self.distanceMaxY.floatValue yValue:distanceTotal[month]];
                point = CGPointMake(x, y);
                
                [distance addObject:[NSValue valueWithCGPoint:point]];
            }
            
            self.calories  = calories.copy;
            self.heartRate = heartRate.copy;
            self.steps     = steps.copy;
            self.distance  = distance.copy;
        }
        else
        {
            self.calories  = nil;
            self.heartRate = nil;
            self.steps     = nil;
            self.distance  = nil;
            
            self.currentCalories    = 0;
            self.currentDistance    = 0;
            self.currentSteps       = 0;
            self.currentHeartRate   = 0;
            
            self.totalCalories  = 0;
            self.totalDistance  = 0;
            self.totalSteps     = 0;
            self.totalHeartRate = 0;
        }
    }
    
    self.scrollView.contentOffset = CGPointZero;
    
    [self.graph monthLabelsWithBarWidth:self.maxBarWidth barSpace:self.barSpace];
    [self reloadGraph];
    [self adjustGraphViewWidth];
    [self adjustBarPlotWidth];
    [self adjustTickLocation];
    [self scrollViewDidScroll:self.scrollView];
}

#pragma mark - Public Methods

// Graph Methods

- (void)initializeGraph
{
    // Scroll View
    self.scrollView.delegate = self;
    
    // Ranges
    self.caloriesMaxY   = [NSNumber numberWithFloat:0.0f];
    self.heartRateMaxY  = [NSNumber numberWithFloat:0.0f];
    self.stepsMaxY      = [NSNumber numberWithFloat:0.0f];
    self.distanceMaxY   = [NSNumber numberWithFloat:0.0f];
    
    // Graph
    self.visiblePlots  = [NSMutableArray new];
    
    // Plot Space
    self.plotSpace          = (SFAXYPlotSpace *) self.graph.defaultPlotSpace;
    self.plotSpace.xRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(self.graphViewWidth)];
    self.plotSpace.yRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(Y_MAX_RANGE)];
    
    // Plot
    //self.caloriesPlot       = [self barPlotWithBarColor:CALORIES_LINE_COLOR];
    //self.heartRatePlot      = [self barPlotWithBarColor:HEART_RATE_LINE_COLOR];
    //self.stepsPlot          = [self barPlotWithBarColor:STEPS_LINE_COLOR];
    //self.distancePlot       = [self barPlotWithBarColor:DISTANCE_LINE_COLOR];
    
    self.barPlot = [self barPlotWithBarColor:CALORIES_LINE_COLOR];
    self.barPlot.dataSource = self;
    self.barPlot.barOffset  = CPTDecimalFromCGFloat(self.barSpace * 0.5f);
    [self.graph addPlot:self.barPlot toPlotSpace:self.plotSpace];
    
    if (_isPortrait)
        [self.graph hourPortraitLabelsWithBarWidth:self.barWidth barSpace:self.barSpace];
    else
        [self.graph hourLabelsWithBarWidth:self.barWidth barSpace:self.barSpace];
        
    [self adjustTickLocation];
    [self adjustGraphViewWidth];
}

- (void)initializeDummyGraph
{
    // Graph
    self.plotSpace                          = (SFAXYPlotSpace *) self.graph.defaultPlotSpace;
    self.plotSpace.xRange                   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(360.0f)];
    self.plotSpace.yRange                   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(Y_MAX_RANGE)];
    self.graphViewWidthConstraint.constant  = 360.0f;
    
    if (_isPortrait)
        [self.graph hourPortraitLabelsWithBarWidth:self.barWidth barSpace:self.barSpace];
    else
        [self.graph hourLabelsWithBarWidth:self.barWidth barSpace:self.barSpace];
    [self adjustTickLocation];
}

- (void)reloadGraph
{
    [self.barPlot reloadData];
    /*for (SFABarPlot *barPlot in self.visiblePlots)
    {
        [barPlot addAnimation:self.growthAnimation forKey:@"growthAnimation"];
        [barPlot reloadData];
    }*/
}

- (void)resetGraph
{
    self.calories  = nil;
    self.heartRate = nil;
    self.steps     = nil;
    self.distance  = nil;
    
    for (SFABarPlot *barPlot in self.visiblePlots)
    {
        [barPlot reloadData];
    }
}

- (void)addGraphType:(SFAGraphType)graphType
{
    //SFABarPlot *barPlot = [self plotForGraphType:graphType];
    
    //[barPlot addAnimation:self.growthAnimation forKey:@"growthAnimation"];
    //[self.graph addPlot:barPlot toPlotSpace:self.plotSpace];
    
    if (![self.visiblePlots containsObject:@(graphType)]) {
        [self.visiblePlots addObject:[NSNumber numberWithInt:graphType]];
        [self adjustBarPlotWidth];
        [self scrollViewDidScroll:self.scrollView];
        
        [self reloadGraph];
    }
}

- (void)removeGraphType:(SFAGraphType)graphType
{
    //SFABarPlot *barPlot = [self plotForGraphType:graphType];
    
    //[self.graph removePlot:barPlot];
    [self.visiblePlots removeObject:[NSNumber numberWithInt:graphType]];
    [self adjustBarPlotWidth];
    [self scrollViewDidScroll:self.scrollView];
    
    [self reloadGraph];
}

- (NSInteger)barPlotCount
{
    return self.visiblePlots.count > 0 ? self.visiblePlots.count : 1;
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
    self.month = month;
    self.year = year;
    
    [self getDataForMonth:month ofYear:year];
}

- (void)setContentsWithYear:(NSInteger)year
{
    [self getDataForYear:year];
}

@end
