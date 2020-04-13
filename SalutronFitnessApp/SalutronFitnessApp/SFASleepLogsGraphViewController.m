//
//  SFASleepLogsGraphViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/27/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Comparison.h"
#import "CPTGraph+Label.h"
#import "SleepDatabaseEntity+Data.h"

#import "SFAGraphTools.h"

#import "StatisticalDataHeaderEntity.h"
#import "StatisticalDataPointEntity+Data.h"
#import "SleepDatabaseEntity.h"

#import "SFASleepLogsGraphViewController.h"

#define Y_VALUE_KEY                 @"yValue"
#define X_VALUE_KEY                 @"xValue"
#define SLEEP_LOGS_BAR_COLOR_KEY    @"sleepLogsBarColor"
#define SLEEP_LOGS_INDEX_KEY        @"sleepLogsIndex"
#define SLEEP_LOGS_BAR_WIDTH        DAY_DATA_BAR_WIDTH / 2

#define SLEEP_LOGS_START_INDEX      6 * 15

//#define GRAPH_VIEW_PADDING          155.0f
#define GRAPH_VIEW_PADDING          30.0f
#define GRAPH_VIEW_WIDTH            310.0f

typedef enum {
    SFASleepGraphBarColorActive,
    SFASleepGraphBarColorSedentary,
    SFASleepGraphBarColorLightSleep,
    SFASleepGraphBarColorMediumSleep,
    SFASleepGraphBarColorDeepSleep
} SFASleepGraphBarColor;

@interface SFASleepLogsGraphViewController () <CPTBarPlotDataSource, CPTBarPlotDelegate>


@property (strong, nonatomic) CPTBarPlot *barPlot;
@property (strong, nonatomic) CPTXYGraph *graph;
@property (strong, nonatomic) NSArray *sleepLogs;
@property (strong, nonatomic) NSArray *dataSource;
@property (nonatomic) float ipadWidth;
@property (nonatomic) BOOL isFirstLoad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphHeight;

@end

@implementation SFASleepLogsGraphViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.isFirstLoad = YES;
    [self initializeObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self adjustGraphView];
}

#pragma mark - CPTBarPlotDataSource Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if (plot == self.barPlot) {
        return self.dataSource.count;
    }
    return 0;
}

- (CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx
{
    NSDictionary *data              = self.dataSource[idx];
    SFASleepGraphBarColor barColor  = [data[SLEEP_LOGS_BAR_COLOR_KEY] integerValue];
    
    if (barColor == SFASleepGraphBarColorActive) {
        return [CPTFill fillWithColor:[CPTColor colorWithCGColor:ACTIVE_LINE_COLOR.CGColor]];
    } else if (barColor == SFASleepGraphBarColorSedentary) {
        return [CPTFill fillWithColor:[CPTColor colorWithCGColor:SEDENTARY_LINE_COLOR.CGColor]];
    } else if (barColor == SFASleepGraphBarColorLightSleep) {
        return [CPTFill fillWithColor:[CPTColor colorWithCGColor:LIGHT_SLEEP_LINE_COLOR.CGColor]];
    } else if (barColor == SFASleepGraphBarColorMediumSleep) {
        return [CPTFill fillWithColor:[CPTColor colorWithCGColor:MEDIUM_SLEEP_LINE_COLOR.CGColor]];
    } else if (barColor == SFASleepGraphBarColorDeepSleep) {
        return [CPTFill fillWithColor:[CPTColor colorWithCGColor:DEEP_SLEEP_LINE_COLOR.CGColor]];
    }
    
    return nil;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    NSDictionary *data = self.dataSource[idx];
    
    if (fieldEnum == CPTBarPlotFieldBarLocation) {
        return [data objectForKey:X_VALUE_KEY];
    } else if (fieldEnum == CPTBarPlotFieldBarTip) {
        return [data objectForKey:Y_VALUE_KEY];
    }
    
    return [NSNumber numberWithInt:0];
}

#pragma mark - CPTBarPlotDelegate Methods

- (void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(UIEvent *)event
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        if ([self.delegate conformsToProtocol:@protocol(SFASleepLogsGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(sleepLogsGraphViewController:didSelectSleepLog:)]) {
            NSDictionary *data          = self.dataSource[idx];
            NSInteger sleepLogIndex     = [data[SLEEP_LOGS_INDEX_KEY] integerValue];
            
            if (sleepLogIndex != -1){
                [self.delegate sleepLogsGraphViewController:self didSelectSleepLog:self.sleepLogs[sleepLogIndex]];
            }
        }
    }
}

#pragma mark - Private Methods

- (void)initializeObjects
{
    // Graph View
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        self.graphHeight.constant = 160;
    }
    self.graphView.allowPinchScaling = NO;
    self.ipadWidth                   = [[UIScreen mainScreen] bounds].size.width - 10;
    
    // Graph
    self.graph                              = [[CPTXYGraph alloc] init];
    self.graph.paddingLeft                  = 0.0f;
    self.graph.paddingRight                 = 0.0f;
    self.graph.paddingTop                   = 5.0f;
    self.graph.paddingBottom                = 33.0f;
    self.graph.plotAreaFrame.masksToBorder  = NO;
    self.graphView.hostedGraph              = self.graph;
    
    // Plot Space
    CPTXYPlotSpace *plotSpace   = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange            = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0)
                                                               length:CPTDecimalFromInt(SLEEP_LOGS_BAR_WIDTH * DAY_DATA_MAX_COUNT)];
    plotSpace.yRange            = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(-10)
                                                               length:CPTDecimalFromInt(20)];
    
    
    // Axis Line Style
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *)self.graph.axisSet;
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
    
    // Bar Plot
    self.barPlot            = [[CPTBarPlot alloc] init];
    self.barPlot.dataSource = self;
    self.barPlot.delegate   = self;
    self.barPlot.lineStyle  = nil;
    self.barPlot.barWidth   = CPTDecimalFromCGFloat(SLEEP_LOGS_BAR_WIDTH);
    self.barPlot.barOffset  = CPTDecimalFromCGFloat(SLEEP_LOGS_BAR_WIDTH / 2);
    
    [self.graph addPlot:self.barPlot toPlotSpace:plotSpace];
    [self.graph sleepLogsHourPortraitLabelsWithBarWidth:SLEEP_LOGS_BAR_WIDTH barSpace:0];
    [self adjustGraphView];
}

#pragma mark - Private Methods

- (void)adjustGraphView
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationIsLandscape(orientation) && !self.isFirstLoad) {
        self.leftPaddingConstraint.constant     = GRAPH_VIEW_PADDING;
        self.rightPaddingConstraint.constant    = GRAPH_VIEW_PADDING;
        self.graphViewWidthConstraint.constant  = SLEEP_LOGS_BAR_WIDTH * DAY_DATA_MAX_COUNT;
        
        [self.graph sleepLogsHourLabelsWithBarWidth:SLEEP_LOGS_BAR_WIDTH barSpace:0];
    } else {
        self.leftPaddingConstraint.constant     = 0;
        self.rightPaddingConstraint.constant    = 0;
        self.graphViewWidthConstraint.constant  = GRAPH_VIEW_WIDTH;
        //if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
            //CGRect screenRect = [[UIScreen mainScreen] bounds];
            //CGFloat screenWidth = screenRect.size.width;
            //CGFloat screenHeight = screenRect.size.height;
            self.graphViewWidthConstraint.constant = self.ipadWidth;//GRAPH_VIEW_WIDTH_IPAD;//screenHeight-10;
        //}
        
        [self.graph sleepLogsHourPortraitLabelsWithBarWidth:SLEEP_LOGS_BAR_WIDTH barSpace:0];
    }
    
    self.isFirstLoad = NO;
}

- (void)setContentsWithDate:(NSDate *)date sleepLogs:(NSArray *)sleepLogs
{
    NSDate *yesterday               = [date dateByAddingTimeInterval:-DAY_SECONDS];
//    NSArray *yesterdaySleepLogs     = [SleepDatabaseEntity sleepDatabaseForDate:yesterday];
    NSMutableArray *allSleepLogs    = sleepLogs.mutableCopy;
    
    //[allSleepLogs addObjectsFromArray:yesterdaySleepLogs];
    
    if (allSleepLogs.count > 0) {
        NSArray *dataPoints                     = [StatisticalDataPointEntity dataPointsForDate:date];
        NSArray *yesterdayDataPoints            = [StatisticalDataPointEntity dataPointsForDate:yesterday];
        NSMutableArray *dataSource              = [NSMutableArray new];
        
        NSInteger maxActiveY                    = 0;
        NSMutableArray *values                  = [NSMutableArray new];
        NSMutableArray *sleepIndexes            = [NSMutableArray new];
        NSMutableDictionary *sleepLogIndexes    = [NSMutableDictionary new];
        
        
        
        for (SleepDatabaseEntity *sleep in allSleepLogs) {
            NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6);
            startIndex              += sleep.sleepStartMin.integerValue / 10;
            NSInteger endIndex      = sleep.sleepEndHour.integerValue * 6;
            endIndex                += sleep.sleepEndMin.integerValue / 10;
            
            if ([date compareToDate:sleep.dateInNSDate] == NSOrderedSame) {
                startIndex  += DAY_DATA_MAX_COUNT;
                endIndex    += DAY_DATA_MAX_COUNT;
            }
            
            startIndex  = startIndex > SLEEP_LOGS_START_INDEX ? startIndex : SLEEP_LOGS_START_INDEX;
            endIndex    = endIndex < startIndex ? endIndex + DAY_DATA_MAX_COUNT : endIndex;
            endIndex    = endIndex > 2 * DAY_DATA_MAX_COUNT ? 2 * DAY_DATA_MAX_COUNT : endIndex;
            
            for (NSInteger a = startIndex; a <= endIndex; a++) {
                [sleepIndexes addObject:@(a - SLEEP_LOGS_START_INDEX)];
                [sleepLogIndexes setObject:@([sleepLogs indexOfObject:sleep]) forKey:@(a - SLEEP_LOGS_START_INDEX)];
            }
        }
        
        for (NSInteger a = SLEEP_LOGS_START_INDEX; a < DAY_DATA_MAX_COUNT + SLEEP_LOGS_START_INDEX; a ++) {
            StatisticalDataPointEntity *dataPoint = nil;
            
            if (a >= DAY_DATA_MAX_COUNT) {
                if (a - DAY_DATA_MAX_COUNT < dataPoints.count) {
                    dataPoint = dataPoints[a - DAY_DATA_MAX_COUNT];
                }
            } else {
                if (a < yesterdayDataPoints.count) {
                    dataPoint = yesterdayDataPoints[a];
                }
            }
            
            CGFloat value   = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue;
            value           += dataPoint.sleepPoint46.floatValue + dataPoint.sleepPoint68.floatValue;
            value           += dataPoint.sleepPoint810.floatValue;
            
            [values addObject:@(value)];
            
            if (![sleepIndexes containsObject:@(a - SLEEP_LOGS_START_INDEX)]) {
                if (value > maxActiveY) {
                    maxActiveY = value;
                }
            }
        }
        
        for (NSInteger a = 0; a < DAY_DATA_MAX_COUNT; a ++) {
            CGFloat value   = [values[a] floatValue];
            SFASleepGraphBarColor barColor = SFASleepGraphBarColorActive;
            NSNumber *sleepLogsIndexKey = @(-1);
            
            if ([sleepIndexes containsObject:@(a)]) {
                value               = (120 * 5) - value;
                sleepLogsIndexKey   = sleepLogIndexes[@(a)];
                
                if (value >= 300) {
                    barColor = SFASleepGraphBarColorDeepSleep;
                } else if (value >= 150) {
                    barColor = SFASleepGraphBarColorMediumSleep;
                } else {
                    barColor = SFASleepGraphBarColorLightSleep;
                }
                
                value = [SFAGraphTools yWithMaxY:(120 * 5) yValue:-value];
                
            } else {
                if (value > 40 * 5) {
                    barColor = SFASleepGraphBarColorActive;
                } else {
                    barColor = SFASleepGraphBarColorSedentary;
                }
                
                value = [SFAGraphTools yWithMaxY:maxActiveY yValue:value];
            }
            
            NSDictionary *data = @{X_VALUE_KEY              : @(a * SLEEP_LOGS_BAR_WIDTH),
                                   Y_VALUE_KEY              : @(value),
                                   SLEEP_LOGS_BAR_COLOR_KEY : @(barColor),
                                   SLEEP_LOGS_INDEX_KEY     : sleepLogsIndexKey};
            
            [dataSource addObject:data];
        }
        
        self.sleepLogs  = sleepLogs;
        self.dataSource = dataSource.copy;
        
    } else {
        self.sleepLogs  = nil;
        self.dataSource = nil;
    }
    
    [self.barPlot reloadData];
}

@end
