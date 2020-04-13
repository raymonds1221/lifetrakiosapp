//
//  SFALightPlotGraphViewController.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 8/22/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFALightPlotGraphViewController.h"

#import "SFAMainViewController.h"

#import "SFAGraphView.h"
#import "SFAGraph.h"
#import "SFAGraphTools.h"
#import "SFAXYPlotSpace.h"
#import "SFABarPlot.h"
#import "SFABarPlot+Type.h"
#import "CPTGraph+Label.h"
#import "SFAGraphView.h"
#import "NSDate+Util.h"

#import "LightDataPointEntity+Data.h"
#import "LightDataPointEntity+GraphData.h"
#import "DayLightAlertEntity+Data.h"
#import "NightLightAlertEntity+Data.h"
#import "SFALightDataManager.h"

#import "UIViewController+Helper.h"

#define LIGHT_PLOT_BAR_SPACE         0
//#define LIGHT_PLOT_BAR_WIDTH        (DAY_DATA_BAR_WIDTH / 2)-LIGHT_PLOT_BAR_SPACE

#define Y_VALUE_KEY                 @"yValue"
#define ALL_LIGHT_VALUE_KEY         @"allLightValue"se
#define BLUE_LIGHT_VALUE_KEY        @"blueLightValue"
#define X_VALUE_KEY                 @"xValue"
#define LIGHT_PLOT_BAR_COLOR_KEY    @"lightPlotBarColor"
#define LIGHT_PLOT_INDEX_KEY        @"lightPlotIndex"

#define GRAPH_VIEW_PADDING          30.0f
#define GRAPH_VIEW_WIDTH            310.0f

@interface SFALightPlotGraphViewController ()<CPTBarPlotDataSource,CPTBarPlotDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightPaddingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftPaddingConstraint;
@property (weak, nonatomic) IBOutlet SFAGraphView *graphView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewHeight;

// Graph
@property (strong, nonatomic) CPTXYGraph    *graph;
@property (strong, nonatomic) CPTBarPlot    *barPlot;

@property (strong, nonatomic) SFAXYPlotSpace    *plotSpace;
@property (readwrite, nonatomic) CGFloat barSpace;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSDate *currentDate;

@property (readwrite, nonatomic) BOOL isLandscape;

@end

@implementation SFALightPlotGraphViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    DDLogInfo(@"");
    [super viewDidLoad];
    
    [self initializeObjects];
    /*
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self adjustToPortraitView];
    }
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    DDLogInfo(@"");
    [super viewWillLayoutSubviews];
    //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [self adjustGraphView];
    //}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    DDLogInfo(@"");
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self adjustGraphView];
}

#pragma mark - private methods

- (void)initializeObjects
{
    DDLogInfo(@"");
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        self.graphViewHeight.constant = 162;
    }
    // Graph View
    // self.graphView.allowPinchScaling = NO;
    
    // Graph
    self.graph                              = [[CPTXYGraph alloc] init];
    self.graph.paddingLeft                  = 0.0f;
    self.graph.paddingRight                 = 0.0f;
    self.graph.paddingTop                   = 0.0f;
    self.graph.paddingBottom                = 1.0f;
    self.graph.plotAreaFrame.masksToBorder  = NO;
    self.graphView.hostedGraph              = self.graph;
    
    // Plot Space
    CPTXYPlotSpace *plotSpace   = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange            = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(X_MIN_RANGE)
                                                               length:CPTDecimalFromInt(self.graphViewWidth)];
    plotSpace.yRange            = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(-0.6)
                                                               length:CPTDecimalFromInt(10)];
    plotSpace.xScaleType        = CPTScaleTypeLinear;
    plotSpace.yScaleType        = CPTScaleTypeLinear;
    
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

    // Tick Mark Style
    CPTMutableLineStyle *tickLineStyle          = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor                     = [CPTColor grayColor];
    tickLineStyle.lineWidth                     = 1.0f;
    axisSet.xAxis.orthogonalCoordinateDecimal   = CPTDecimalFromInt(0);
    axisSet.xAxis.majorTickLineStyle            = tickLineStyle.copy;
    axisSet.xAxis.majorTickLength               = 4.0f;
    axisSet.xAxis.tickDirection                 = CPTSignNone;
    
    // Bar Plots
    self.barPlot = [self setupBarPlot];
    self.barPlot.barBasesVary = YES;
    
    [self.graph addPlot:self.barPlot toPlotSpace:plotSpace];
    [self.graph hourPortraitLabelsForLightPlotWithBarWidth:self.barWidth barSpace:self.barSpace];

    self.plotSpace = (SFAXYPlotSpace *)plotSpace;
    
}

- (CPTBarPlot *)setupBarPlot
{
   // DDLogInfo(@"");
    CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
    barPlot.dataSource = self;
    barPlot.delegate   = self;
    barPlot.lineStyle  = nil;
    barPlot.barWidth   = CPTDecimalFromCGFloat(self.barWidth);
    barPlot.barOffset  = CPTDecimalFromCGFloat((self.barWidth + self.barSpace) / 2);
    
    return barPlot;
}

- (void)adjustGraphView
{
  //  DDLogInfo(@"");
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        [self adjustToLandscapeView];
    } else {
        [self adjustToPortraitView];
    }
}

- (void)adjustToLandscapeView
{
    DDLogInfo(@"");
    self.isLandscape = YES;
    self.scrollView.scrollEnabled = YES;
    
    if(self.isIOS8AndAbove) { // add support for iOS 8
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            self.leftPaddingConstraint.constant     = screenBounds.size.width / 2;
            self.rightPaddingConstraint.constant    = screenBounds.size.width / 2;
        }
        else{
            self.leftPaddingConstraint.constant     = screenBounds.size.height / 2;
            self.rightPaddingConstraint.constant    = screenBounds.size.height / 2;
        }
    } else {
        self.leftPaddingConstraint.constant     = self.view.window.frame.size.height / 2;
        self.rightPaddingConstraint.constant    = self.view.window.frame.size.height / 2;
    }
    
    self.graphViewWidthConstraint.constant      = self.graphViewWidth;
    [self adjustGraphViewWidth];
    [self adjustBarWidth];
    [self.graph hourLabelsForLightPlotWithBarWidth:self.barWidth barSpace:self.barSpace];
    [self scrollToFirstRecord];
}

- (void)adjustToPortraitView
{
    DDLogInfo(@"");
    self.isLandscape = NO;
    [self.scrollView setFrame:CGRectMake(0,self.view.frame.size.height,self.view.frame.size.width, -self.view.frame.size.height)];
    self.scrollView.scrollEnabled = NO;
    self.leftPaddingConstraint.constant     = 0;
    self.rightPaddingConstraint.constant    = 0;
    if (self.isIOS8AndAbove) {
        self.graphViewWidthConstraint.constant  = self.view.window.frame.size.height-15.0f;
    }
    else{
        self.graphViewWidthConstraint.constant  = self.view.window.frame.size.width-15.0f;
    }
    //if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [self adjustGraphViewWidth];
        [self adjustBarWidth];
    //}
    [self.graph hourPortraitLabelsForLightPlotWithBarWidth:self.barWidth barSpace:self.barSpace];
}

- (void)adjustGraphViewWidth
{
    DDLogInfo(@"");
    //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.graphViewWidthConstraint.constant  = (!self.isLandscape) ? self.view.frame.size.width : self.graphViewWidth;
    //}
    //else{
    //    self.graphViewWidthConstraint.constant  = (!self.isLandscape) ? 320 : self.graphViewWidth;
    //}
    self.plotSpace.xRange                   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(X_MIN_RANGE)
                                                                           length:CPTDecimalFromFloat(self.graphViewWidth)];
}

- (void)adjustBarWidth
{
    DDLogInfo(@"");
    self.barPlot.barWidth       = CPTDecimalFromCGFloat(self.barWidth);
    self.barPlot.barOffset      = CPTDecimalFromCGFloat((self.barWidth + self.barSpace) / 2);
}

#pragma mark - CPTBarPlotDataSource Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.dataSource.count;
}

- (CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx
{
    SFABarGraphData *barGraphData = self.dataSource[idx];
    
    switch (self.dateRangeSelected) {
        case SFADateRangeDay:
            if (barGraphData.wristDetection) {
                if (barGraphData.barColor == SFALightPlotBarColorAllLight) {
                    return [CPTFill fillWithColor:[CPTColor colorWithCGColor:ALL_LIGHT_LINE_COLOR.CGColor]];
                }
                else if (barGraphData.barColor == SFALightPlotBarColorBlueLight) {
                    return [CPTFill fillWithColor:[CPTColor colorWithCGColor:BLUE_LIGHT_LINE_COLOR.CGColor]];
                }
                else {
                    return [CPTFill fillWithColor:[CPTColor colorWithCGColor:[UIColor lightGrayColor].CGColor]];;
                }
            } else {
                if (barGraphData.barColor == SFALightPlotBarColorAllLight) {
                    return [CPTFill fillWithColor:[CPTColor colorWithCGColor:[UIColor lightGrayColor].CGColor]];;
                } else if(barGraphData.barColor == SFALightPlotBarColorBlueLight) {
                    return [CPTFill fillWithColor:[CPTColor colorWithCGColor:[UIColor darkGrayColor].CGColor]];;
                } else {
                    return [CPTFill fillWithColor:[CPTColor colorWithCGColor:[UIColor lightGrayColor].CGColor]];;
                }
            }
            break;
        case SFADateRangeWeek:
        case SFADateRangeMonth:
        case SFADateRangeYear:
            
            return [self barColorByValue:barGraphData.light barColor:barGraphData.barColor];
            break;
        default:
            return nil;
            break;
    }
}

- (CPTFill *)barColorByValue:(CGFloat)value barColor:(SFALightPlotBarColor)barColor
{
    switch (barColor) {
            
        case SFALightPlotBarColorAllLight:
            if (value > 0 && value <= SFAAllLightThreshold_01) {
                return [CPTFill fillWithColor:[CPTColor colorWithCGColor:ALL_LIGHT_LINE_COLOR_01.CGColor]];
            }
            else if (value > SFAAllLightThreshold_01 && value <= SFAAllLightThreshold_02) {
                return [CPTFill fillWithColor:[CPTColor colorWithCGColor:ALL_LIGHT_LINE_COLOR_02.CGColor]];
            }
            else if (value > SFAAllLightThreshold_02 && value <= SFAAllLightThreshold_03) {
                return [CPTFill fillWithColor:[CPTColor colorWithCGColor:ALL_LIGHT_LINE_COLOR_03.CGColor]];
            }
            else if (value > SFAAllLightThreshold_03 && value <= SFAAllLightThreshold_04) {
                return [CPTFill fillWithColor:[CPTColor colorWithCGColor:ALL_LIGHT_LINE_COLOR_04.CGColor]];
            }
            else if (value > SFAAllLightThreshold_04 && value <= SFAAllLightThreshold_05) {
                return [CPTFill fillWithColor:[CPTColor colorWithCGColor:ALL_LIGHT_LINE_COLOR_05.CGColor]];
            }
            else {
                return [CPTFill fillWithColor:[CPTColor colorWithCGColor:ALL_LIGHT_LINE_COLOR_06.CGColor]];
            }
            break;
            
        case SFALightPlotBarColorBlueLight:
            if (value > 0 && value <= SFABlueLightThreshold_01) {
                return [CPTFill fillWithColor:[CPTColor colorWithCGColor:BLUE_LIGHT_LINE_COLOR_01.CGColor]];
            }
            else if (value > SFABlueLightThreshold_01 && value <= SFABlueLightThreshold_02) {
                return [CPTFill fillWithColor:[CPTColor colorWithCGColor:BLUE_LIGHT_LINE_COLOR_02.CGColor]];
            }
            else if (value > SFABlueLightThreshold_02 && value <= SFABlueLightThreshold_03) {
                return [CPTFill fillWithColor:[CPTColor colorWithCGColor:BLUE_LIGHT_LINE_COLOR_03.CGColor]];
            }
            else if (value > SFABlueLightThreshold_03 && value <= SFABlueLightThreshold_04) {
                return [CPTFill fillWithColor:[CPTColor colorWithCGColor:BLUE_LIGHT_LINE_COLOR_04.CGColor]];
            }
            else if (value > SFABlueLightThreshold_04 && value <= SFABlueLightThreshold_05) {
                return [CPTFill fillWithColor:[CPTColor colorWithCGColor:BLUE_LIGHT_LINE_COLOR_05.CGColor]];
            }
            else {
                return [CPTFill fillWithColor:[CPTColor colorWithCGColor:BLUE_LIGHT_LINE_COLOR_06.CGColor]];
            }
            break;
        case SFALightPlotBarColorGray:
        default:
            return [CPTFill fillWithColor:[CPTColor colorWithCGColor:[UIColor lightGrayColor].CGColor]];
            break;
    }
    return [CPTFill fillWithColor:[CPTColor colorWithCGColor:[UIColor clearColor].CGColor]];
    
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    //DDLogInfo(@"");
    SFABarGraphData *barGraphData = self.dataSource[idx];
    
    if (fieldEnum == CPTBarPlotFieldBarLocation) {
        return [NSNumber numberWithFloat:barGraphData.x * (self.barWidth + self.barSpace)];
    }
    else if (fieldEnum == CPTBarPlotFieldBarBase) {
        if (self.calendarController.calendarMode == SFACalendarDay) {
            return [NSNumber numberWithFloat:barGraphData.yBaseLog];
        }
        return [NSNumber numberWithFloat:barGraphData.yBase];
    }
    else if (fieldEnum == CPTBarPlotFieldBarTip) {
        if (self.calendarController.calendarMode == SFACalendarDay) {
            return [NSNumber numberWithFloat:barGraphData.yTipLog];
        }
        return [NSNumber numberWithFloat:barGraphData.yTip];
    }
    else {
        return @0;
    }
}

#pragma mark - properties

- (CGFloat)maxX
{
    //DDLogInfo(@"");
    if (self.calendarController.calendarMode == SFACalendarDay)
    {
        return DAY_DATA_MAX_COUNT;
    }
    else if (self.calendarController.calendarMode == SFACalendarWeek)
    {
        //return WEEK_DATA_MAX_COUNT;
        
        return 7;
    }
    else if (self.calendarController.calendarMode == SFACalendarMonth)
    {
        return 31;
    }
    else if (self.calendarController.calendarMode == SFACalendarYear)
    {
        return YEAR_ACT_DATA_MAX_COUNT;
    }
    
    return 0.0f;
}

- (CGFloat)graphViewWidth
{
    //DDLogInfo(@"");
    return ((self.barSpace + self.barWidth) * [self maxX]);
}

- (CGFloat)barWidth
{
    //DDLogInfo(@"");
    if (self.calendarController.calendarMode == SFACalendarDay) {
        return DAY_DATA_BAR_WIDTH / 2;
    }
    else if (self.calendarController.calendarMode == SFACalendarYear) {
       return DAY_DATA_BAR_WIDTH / 8;
    }
    else {
        return DAY_DATA_BAR_WIDTH;
    }
}

- (CGFloat)barSpace
{
    //DDLogInfo(@"");
    if (self.calendarController.calendarMode == SFACalendarDay)
    {
        return 0;
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

#pragma mark - Data source

- (NSArray *)getDataSourceForAllLight:(NSArray *)allLight blueLight:(NSArray *)blueLight
{
    DDLogInfo(@"");
    NSMutableArray *accumulatedLightGraphData = [[NSMutableArray alloc] init];
    NSMutableArray *arrayOfDays = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *computedLight = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *totalBlueLight = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *totalWristOffLight = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *totalAllLight = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *allLightBarGraphData = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *blueLightBarGraphData = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *barGraphPerDay in allLight) {
        NSArray *barGraphDataPerDayArray = (NSArray *)barGraphPerDay[barGraphPerDay.allKeys[0]];
        [allLightBarGraphData setObject:barGraphDataPerDayArray forKey:barGraphPerDay.allKeys[0]];
        [arrayOfDays addObject:barGraphPerDay.allKeys[0]];
    }
    
    for (NSDictionary *barGraphPerDay in blueLight) {
        NSArray *barGraphDataPerDayArray = (NSArray *)barGraphPerDay[barGraphPerDay.allKeys[0]];
        [blueLightBarGraphData setObject:barGraphDataPerDayArray forKey:barGraphPerDay.allKeys[0]];
    }
    
    if (self.dateRangeSelected == SFADateRangeMonth) {
        [arrayOfDays removeAllObjects];
        for (NSUInteger i = 1; i <= 31; i++) {
            [arrayOfDays addObject:[NSNumber numberWithInteger:i]];
        }
    }
    else if (self.dateRangeSelected == SFADateRangeYear) {
        [arrayOfDays removeAllObjects];
        for (NSUInteger i = 1; i <= [NSDate numberOfDaysForCurrentYear]; i++) {
            [arrayOfDays addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    if (allLightBarGraphData.allKeys.count) {   
        
        float lastXPosition = 0;
        
        for (int i = 0; i < arrayOfDays.count; i++) {
            
            NSArray *barGraphAllDataPerDayArray = (NSArray *)allLightBarGraphData[arrayOfDays[i]];
            NSArray *barGraphBlueDataPerDayArray = (NSArray *)blueLightBarGraphData[arrayOfDays[i]];
            
            if (barGraphAllDataPerDayArray.count) {
                
                CGFloat maxYTipValueAll = [LightDataPointEntity getMaxYTipValueForLightBarGraphDataArray:barGraphAllDataPerDayArray];
                CGFloat maxYTipValueBlue = [LightDataPointEntity getMaxYTipValueForLightBarGraphDataArray:barGraphBlueDataPerDayArray];
                
                float all = 0;
                float blue = 0;
                float wristOff = 0;
                
                for (SFABarGraphData *barGraphData in barGraphAllDataPerDayArray) {
                    barGraphData.yTip = [SFAGraphTools yWithMaxY:maxYTipValueAll yValue:barGraphData.yTip];
                    barGraphData.yBase = [SFAGraphTools yWithMaxY:maxYTipValueAll yValue:barGraphData.yBase];
                    barGraphData.x = (self.calendarController.calendarMode == SFACalendarYear) ? i - 0.3 : i + 0.1;
                    lastXPosition = barGraphData.x;
                    if (barGraphData.wristDetection == YES) {
                        all += barGraphData.light;
                    }
                    else {
                       barGraphData.barColor = SFALightPlotBarColorGray;
                    }
                    [accumulatedLightGraphData addObject:barGraphData];
                }
                [totalAllLight setObject:[NSNumber numberWithFloat:all] forKey:[NSNumber numberWithInt:i]];
                
                for (int i = 0; i < barGraphBlueDataPerDayArray.count; i++) {
                    SFABarGraphData *barGraphData = (SFABarGraphData *)barGraphBlueDataPerDayArray[i];
                    barGraphData.yTip = [SFAGraphTools yWithMaxY:maxYTipValueBlue yValue:barGraphData.yTip];
                    barGraphData.yBase = [SFAGraphTools yWithMaxY:maxYTipValueBlue yValue:barGraphData.yBase];
                    barGraphData.x = (self.calendarController.calendarMode == SFACalendarYear) ? lastXPosition + 0.3 : lastXPosition + 0.3;
                    if (barGraphData.wristDetection == YES) {
                        blue += barGraphData.light;
                    }
                    else {
                        wristOff += barGraphData.light;
                        barGraphData.barColor = SFALightPlotBarColorGray;
                    }
                    [accumulatedLightGraphData addObject:barGraphData];
                }
                
                [totalBlueLight setObject:[NSNumber numberWithFloat:blue] forKey:[NSNumber numberWithInt:i]];
                [totalWristOffLight setObject:@(wristOff) forKey:@(i)];
            }
        }
        [computedLight setObject:totalAllLight forKey:@"ALL"];
        [computedLight setObject:totalBlueLight forKey:@"BLUE"];
        [computedLight setObject:totalWristOffLight forKey:@"WRISTOFF"];
    }
    self.computeLightDictionary = computedLight;
    
    return accumulatedLightGraphData;
}

- (NSArray *)getWeekMonthYearDataSourceForAllLight:(NSArray *)allLight blueLight:(NSArray *)blueLight
{
    DDLogInfo(@"");
    NSMutableArray *accumulatedLightGraphData = [[NSMutableArray alloc] init];
    NSMutableArray *arrayOfDays = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *computedLight = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *totalBlueLight = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *totalWristOffLight = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *totalAllLight = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *allLightBarGraphData = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *blueLightBarGraphData = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *barGraphPerDay in allLight) {
        NSArray *barGraphDataPerDayArray = (NSArray *)barGraphPerDay[barGraphPerDay.allKeys[0]];
        [allLightBarGraphData setObject:barGraphDataPerDayArray forKey:barGraphPerDay.allKeys[0]];
        [arrayOfDays addObject:barGraphPerDay.allKeys[0]];
    }
    
    for (NSDictionary *barGraphPerDay in blueLight) {
        NSArray *barGraphDataPerDayArray = (NSArray *)barGraphPerDay[barGraphPerDay.allKeys[0]];
        [blueLightBarGraphData setObject:barGraphDataPerDayArray forKey:barGraphPerDay.allKeys[0]];
    }
    
    if (self.dateRangeSelected == SFADateRangeMonth) {
        [arrayOfDays removeAllObjects];
        for (NSUInteger i = 1; i <= 31; i++) {
            [arrayOfDays addObject:[NSNumber numberWithInteger:i]];
        }
    }
    else if (self.dateRangeSelected == SFADateRangeYear) {
        [arrayOfDays removeAllObjects];
        for (NSUInteger i = 1; i <= [NSDate numberOfDaysForCurrentYear]; i++) {
            [arrayOfDays addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    if (allLightBarGraphData.allKeys.count) {
        
        float lastXPosition = 0;
        
        for (int i = 0; i < arrayOfDays.count; i++) {
            
            NSArray *barGraphAllDataPerDayArray = (NSArray *)allLightBarGraphData[arrayOfDays[i]];
            NSArray *barGraphBlueDataPerDayArray = (NSArray *)blueLightBarGraphData[arrayOfDays[i]];
            
            if (barGraphAllDataPerDayArray.count) {
                
                //CGFloat maxYTipValueAll = [LightDataPointEntity getMaxYTipValueForLightBarGraphDataArray:barGraphAllDataPerDayArray];
                //CGFloat maxYTipValueBlue = [LightDataPointEntity getMaxYTipValueForLightBarGraphDataArray:barGraphBlueDataPerDayArray];
                
                float all = 0;
                float blue = 0;
                float wristOff = 0;
                
                for (SFABarGraphData *barGraphData in barGraphAllDataPerDayArray) {
                    barGraphData.yTip = [SFAGraphTools yWithMaxY:barGraphAllDataPerDayArray.count+10 yValue:[barGraphAllDataPerDayArray indexOfObject:barGraphData]+1];
                    barGraphData.yBase = [SFAGraphTools yWithMaxY:barGraphAllDataPerDayArray.count+10 yValue:[barGraphAllDataPerDayArray indexOfObject:barGraphData]];
                    barGraphData.x = (self.calendarController.calendarMode == SFACalendarYear) ? i - 0.3 : i + 0.1;
                    lastXPosition = barGraphData.x;
                    if (barGraphData.wristDetection == YES) {
                        all += barGraphData.light;
                    }
                    else {
                        barGraphData.barColor = SFALightPlotBarColorGray;
                    }
                    [accumulatedLightGraphData addObject:barGraphData];
                }
                [totalAllLight setObject:[NSNumber numberWithFloat:all] forKey:[NSNumber numberWithInt:i]];
                
                for (int i = 0; i < barGraphBlueDataPerDayArray.count; i++) {
                    SFABarGraphData *barGraphData = (SFABarGraphData *)barGraphBlueDataPerDayArray[i];
                    barGraphData.yTip = [SFAGraphTools yWithMaxY:barGraphBlueDataPerDayArray.count+10 yValue:i+1];
                    barGraphData.yBase = [SFAGraphTools yWithMaxY:barGraphBlueDataPerDayArray.count+10 yValue:i];
                    barGraphData.x = (self.calendarController.calendarMode == SFACalendarYear) ? lastXPosition + 0.3 : lastXPosition + 0.3;
                    if (barGraphData.wristDetection == YES) {
                        blue += barGraphData.light;
                    }
                    else {
                        wristOff += barGraphData.light;
                        barGraphData.barColor = SFALightPlotBarColorGray;
                    }
                    [accumulatedLightGraphData addObject:barGraphData];
                }
                
                [totalBlueLight setObject:[NSNumber numberWithFloat:blue] forKey:[NSNumber numberWithInt:i]];
                [totalWristOffLight setObject:@(wristOff) forKey:@(i)];
            }
        }
        [computedLight setObject:totalAllLight forKey:@"ALL"];
        [computedLight setObject:totalBlueLight forKey:@"BLUE"];
        [computedLight setObject:totalWristOffLight forKey:@"WRISTOFF"];
    }
    self.computeLightDictionary = computedLight;
    
    return accumulatedLightGraphData;
}

#pragma mark - public methods
#pragma mark - Set contents

- (void)setContentsWithDate:(NSDate *)date
{
    DDLogInfo(@"");
    self.dateRangeSelected = SFADateRangeDay;
    self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.origin.y);
    self.currentDate = date;
    
    [self adjustGraphViewWidth];
    [self adjustBarWidth];
    
    NSMutableArray *dailyLightBarGraphData = [[LightDataPointEntity getDailyLightBarGraphDataForDate:date lightDataPointsArray:NULL] mutableCopy];
    
    CGFloat maxYTipValue = [LightDataPointEntity getMaxYTipValueForLightBarGraphDataArray:dailyLightBarGraphData];
    
    self.maxYTipValue = log10f(maxYTipValue);
    self.maxYTipValueInLux = maxYTipValue;
    
    for (SFABarGraphData *barGraphData in dailyLightBarGraphData) {
        barGraphData.yTip = [SFAGraphTools yWithMaxY:maxYTipValue yValue:barGraphData.yTip];
        barGraphData.yBase = [SFAGraphTools yWithMaxY:maxYTipValue yValue:barGraphData.yBase];
        barGraphData.yTipLog = [SFAGraphTools yWithMaxY:log10f(maxYTipValue) yValue:barGraphData.yTipLog];
        barGraphData.yBaseLog = [SFAGraphTools yWithMaxY:log10f(maxYTipValue) yValue:barGraphData.yBaseLog];
    }
    
    if (!self.isLandscape){
        [self.graph hourPortraitLabelsForLightPlotWithBarWidth:self.barWidth barSpace:self.barSpace];
    }else{
        [self updateGraphAndScrollView];
        [self.graph hourLabelsForLightPlotWithBarWidth:self.barWidth barSpace:self.barSpace];
    }
    
    self.dataSource = [dailyLightBarGraphData mutableCopy];
    
    [self.graph reloadData];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        [self scrollToFirstRecord];
    }
    
}

- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year
{
    DDLogInfo(@"");
    self.dateRangeSelected = SFADateRangeWeek;
    [self updateGraphAndScrollView];
    self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.origin.y);
    
    NSArray *allLight = [LightDataPointEntity getWeeklyLightBarGraphDataForWeek:week ofYear:year lightColor:SFALightColorAll];
    NSArray *blueLight = [LightDataPointEntity getWeeklyLightBarGraphDataForWeek:week ofYear:year lightColor:SFALightColorBlue];
    
    self.dataSource = [self getWeekMonthYearDataSourceForAllLight:allLight blueLight:blueLight];
    
    self.barPlot.barWidth       = CPTDecimalFromCGFloat(DAY_DATA_BAR_WIDTH/2);
    self.barPlot.barOffset      = CPTDecimalFromCGFloat(((DAY_DATA_BAR_WIDTH/2) + self.barSpace) / 2);
    
    [self.graph dayLabelsForActigraphyWithWeek:week ofYear:year barWidth:self.barWidth barSpace:self.barSpace];
    [self.graph reloadData];
    
    [self scrollToFirstRecord];
}

- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year
{
    DDLogInfo(@"");
    self.dateRangeSelected = SFADateRangeMonth;
    [self updateGraphAndScrollView];
    self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.origin.y);
    
    NSArray *allLight = [LightDataPointEntity getMonthlyLightBarGraphDataForMonth:month ofYear:year lightColor:SFALightColorAll];
    NSArray *blueLight = [LightDataPointEntity getMonthlyLightBarGraphDataForMonth:month ofYear:year lightColor:SFALightColorBlue];
    
    self.dataSource = [self getWeekMonthYearDataSourceForAllLight:allLight blueLight:blueLight];
    
    self.barPlot.barWidth       = CPTDecimalFromCGFloat(DAY_DATA_BAR_WIDTH/2);
    self.barPlot.barOffset      = CPTDecimalFromCGFloat(((DAY_DATA_BAR_WIDTH/2) + self.barSpace) / 2);
    
    [self.graph dayLabelsWithMonth:month ofYear:year barWidth:self.barWidth barSpace:self.barSpace];
    [self.graph reloadData];
    
    [self scrollToFirstRecord];
}

- (void)setContentsWithYear:(NSInteger)year
{
    DDLogInfo(@"");
    self.dateRangeSelected = SFADateRangeYear;
    [self updateGraphAndScrollView];
    self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.origin.y);
    
    NSArray *allLight = [LightDataPointEntity getYearlyLightBarGraphDataForYear:year lightColor:SFALightColorAll];
    NSArray *blueLight = [LightDataPointEntity getYearlyLightBarGraphDataForYear:year lightColor:SFALightColorBlue];

    self.dataSource = [self getWeekMonthYearDataSourceForAllLight:allLight blueLight:blueLight];
    
    self.barPlot.barWidth       = CPTDecimalFromCGFloat(3);
    self.barPlot.barOffset      = CPTDecimalFromCGFloat(((3) + self.barSpace) / 2);
    
    [self.graph dayLabelsWithYear:year barWidth:self.barWidth barSpace:self.barSpace];
    [self.graph reloadData];
    
    [self scrollToFirstRecord];
}

//static float const leftPaddingAllowance = 50.0f;

- (void)updateGraphAndScrollView
{
    DDLogInfo(@"");
    CGFloat scrollContentWidth = (self.graphViewWidth + self.view.window.frame.size.height + 200);
    
    self.scrollView.contentSize = CGSizeMake(scrollContentWidth, self.scrollView.contentSize.height);
    self.graphViewWidthConstraint.constant = self.graphViewWidth;
    // BAR AND GRAPH
    CGRect preferredFrame = self.barPlot.frame;
    preferredFrame.size.width = self.graphViewWidth;
    
    self.graph.frame = preferredFrame;
    self.barPlot.frame = preferredFrame;
    
    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(X_MIN_RANGE)
                                                         length:CPTDecimalFromInt(preferredFrame.size.width)];
    
//    //SCROLL VIEW
//    CGRect scrollPreferredFrame = self.scrollView.frame;
//    scrollPreferredFrame.origin.x = (self.calendarController.calendarMode == SFACalendarMonth || self.calendarController.calendarMode == SFACalendarYear) ? leftPaddingAllowance : 0;
//
//    self.leftPaddingConstraint.constant = (self.calendarController.calendarMode == SFACalendarMonth || self.calendarController.calendarMode == SFACalendarYear) ? (self.view.window.frame.size.height/2) - leftPaddingAllowance : self.view.window.frame.size.height/2;
//    
//    self.scrollView.frame = scrollPreferredFrame;
}

#pragma mark - UIScrollViewDelegate Methods

static CGFloat const yAxisViewDayConstant = 23.0f;
static CGFloat const yAxisViewWeekConstant = 17.0f;
static CGFloat const yAxisViewMonthConstant = 17.0f;
static CGFloat const yAxisViewYearConstant = 20.0f;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //DDLogInfo(@"");
    CGFloat x       = scrollView.contentOffset.x < 0 ? 0 : scrollView.contentOffset.x;
    x               = scrollView.contentOffset.x > self.graphViewWidth ? self.graphViewWidth : x;
    x               = scrollView.contentOffset.x;
    
    NSInteger index = 0;
    if (self.calendarController.calendarMode == SFACalendarWeek){
        x               -= yAxisViewWeekConstant;
        index = x / (self.barWidth + self.barSpace);
    }
    else if (self.calendarController.calendarMode == SFACalendarMonth){
        x               -= yAxisViewMonthConstant;
        index = x / (self.barWidth + self.barSpace);
        if (index < 1) {
            index = 1;
        }
        NSInteger daysOfMonth = [NSDate numberOfDaysInMonthForDate:self.currentDate];
        if (index > daysOfMonth) {
            index = daysOfMonth;
        }
    }
    else if (self.calendarController.calendarMode == SFACalendarYear){
        x               -= yAxisViewYearConstant;
        index = x / (self.barWidth + self.barSpace);
        index -= 2;
        if (index < 0) {
            index = 0;
        }
        else if (index > 364) {
            index = 364;
        }
    }
    else{
        x               -= yAxisViewDayConstant;
        index = x / (self.barWidth + self.barSpace);
        if (index > 143) {
            index = 143;
        }
    }
    //Get index value
    index           = index < self.maxX ? index : self.maxX;

//    DDLogInfo(@"self.maxX = %i", self.maxX);
    // Values
    
    if (self.isLandscape && [self.delegate conformsToProtocol:@protocol(SFALightPlotGraphViewControllerDelegate)]
        && [self.delegate respondsToSelector:@selector(graphViewController:didChangeDataPoint:)]){
        [self.delegate graphViewController:self didChangeDataPoint:index];
    }
}

- (void)scrollToFirstRecord
{
    DDLogInfo(@"");
    NSInteger firstRecordIndex = self.maxX;
    NSArray *dataSource = self.dataSource;
    
    for (SFABarGraphData *value in dataSource)
    {
        //if (value.light > 0 && value.wristDetection == YES)
        if (value.light > 1 && value.barColor == SFALightPlotBarColorBlueLight)
        {
            NSInteger index = value.x;
            firstRecordIndex = index < firstRecordIndex ? index : firstRecordIndex;
            break;
        }
    }
    
    if (firstRecordIndex != self.maxX &&
        firstRecordIndex != 0)
    {
        CGRect firstRecordRect      = self.scrollView.frame;
        
        firstRecordRect.origin.x    = firstRecordIndex * (self.barWidth + self.barSpace);
        if (self.calendarController.calendarMode == SFACalendarDay){
            firstRecordRect.origin.x += 23;
        }
        else if (self.calendarController.calendarMode == SFACalendarWeek
                 || self.calendarController.calendarMode == SFACalendarMonth) {
            firstRecordRect.origin.x += 45;
        }
        else if (self.calendarController.calendarMode == SFACalendarYear){
            firstRecordRect.origin.x += 52;
        }
        
        [UIView animateWithDuration:0.5f animations:^{
            self.scrollView.contentOffset = firstRecordRect.origin;
        }];
        
        //[self.scrollView scrollRectToVisible:firstRecordRect animated:NO];
    }
}


@end
