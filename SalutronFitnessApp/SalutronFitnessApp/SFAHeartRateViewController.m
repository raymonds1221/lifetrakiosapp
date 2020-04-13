//
//  SFAHeartRateViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/4/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAHeartRateViewController.h"
#import "UISegmentedControl+Theme.h"
#import "SalutronUserProfile+Data.h"

#import "SFASalutronFitnessAppDelegate.h"

#import "SFAMainViewController.h"
#import "SFAHeartRateGraphViewController.h"
#import "SFAHeartRateScrollViewController.h"
#import "SFAServerAccountManager.h"

#import "CPTGraph+Label.h"

#import "SFAGraph.h"
#import "SFAGraphView.h"
#import "SFAGraphTools.h"
#import "SFAXYPlotSpace.h"
#import "SFABarPlot.h"
#import "SFATradingRangePlot.h"

#import "JDAKeyboardAccessory.h"
#import "JDAPickerView.h"

#import "StatisticalDataHeaderEntity.h"
#import "StatisticalDataPointEntity.h"
#import "DateEntity.h"
#import "StatisticalDataPointEntity+Data.h"

#import "JDACoreData.h"

#define HEART_RATE_GRAPH_SEGUE_IDENTIFIER @"HeartRateGraphIdentifier"

#define GRAPH_VIEW_OFFSET       320.0f

#define BPM_MIN_Y_VALUE         40
#define BPM_MAX_Y_VALUE         240
#define DAY_DATA_MAX_COUNT      144
#define WEEK_DATA_MAX_COUNT     84
#define MONTH_DATA_MAX_COUNT    12

#define HEART_RATE_LINE_COLOR [UIColor colorWithRed:190/255.0f green:73/255.0f blue:67/255.0f alpha:1.0f]

#define Y_MIN_VALUE_KEY     @"minValue"
#define Y_MAX_VALUE_KEY     @"maxValue"
#define X_VALUE_KEY         @"xValue"

typedef enum
{
    SFAHeartRatePlotTypeBar,
    SFAHeartRatePlotTypeTradingRange
} SFAHeartRatePlotType;

@interface SFAHeartRateViewController () <UIScrollViewDelegate, UITextFieldDelegate, SFABarPlotDelegate, SFACalendarControllerDelegate, SFATradingRangePlotDelegate, SFAHeartRateGraphViewControllerDelegate, JDAPickerViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewVerticalSpace;
@property (readwrite, nonatomic) CGFloat                oldTableViewVerticalSpace;

// Core Datas
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

// Graphs
@property (strong, nonatomic) SFAGraph                          *graph;
@property (strong, nonatomic) SFAGraphView                      *graphView;
@property (strong, nonatomic) SFAXYPlotSpace                    *plotSpace;
@property (strong, nonatomic) SFABarPlot                        *barPlot;
@property (strong, nonatomic) SFATradingRangePlot               *tradingRangePlot;
@property (strong, nonatomic) SFAHeartRateGraphViewController   *viewController;
@property (weak, nonatomic) UIScrollView                        *parentScrollView;
@property (readwrite, nonatomic) SFAHeartRatePlotType           plotType;
@property (readwrite, nonatomic) BOOL                           scrolled;
@property (readwrite, nonatomic) CGFloat                        scrollIndex;

// Data
@property (strong, nonatomic) NSArray *heartRate;

@property (readwrite, nonatomic) NSString *monthSelected;
@property (readwrite, nonatomic) NSString *yearSelected;

@property (assign, nonatomic) int maxDataPoint;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (assign, nonatomic) unsigned int maxXRange;
@property (assign, nonatomic) unsigned int maxYRange;
@property (readwrite, nonatomic) BOOL isBarPlotVisible;

@property (strong, nonatomic) JDAPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UIImageView *imagePlayHead;
@property (weak, nonatomic) IBOutlet UIView *viewRightGraph;
@property (weak, nonatomic) IBOutlet UIView *viewLeftGraph;
@property (weak, nonatomic) IBOutlet UIView *heartRateLandscapeView;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartRateAverageValue;
@property (weak, nonatomic) IBOutlet UILabel *minBPMLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxBPMLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartRateMinValue;
@property (weak, nonatomic) IBOutlet UILabel *heartRateMaxValue;
@property (weak, nonatomic) IBOutlet UITextField *dateRangeTextField;
@property (weak, nonatomic) IBOutlet UIView *dateRangeView;

@property (weak, nonatomic) IBOutlet UILabel *percentLandscapeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *percentLandscapeImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *percentLandscapeViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playHeadHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphBackgroundHeight;
@end

@implementation SFAHeartRateViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializeObjects];
    
    if ([SFAUserDefaultsManager sharedManager].watchModel == WatchModel_R450 || [SFAUserDefaultsManager sharedManager].watchModel == WatchModel_R500) {
        self.minBPMLabel.hidden         = NO;
        self.maxBPMLabel.hidden         = NO;
        self.heartRateMinValue.hidden   = NO;
        self.heartRateMaxValue.hidden   = NO;
    }
    else {
        // Hide min and max bpm label forC300 and C410 - issue #916
        self.minBPMLabel.hidden         = YES;
        self.maxBPMLabel.hidden         = YES;
        self.heartRateMinValue.hidden   = YES;
        self.heartRateMaxValue.hidden   = YES;
    }
    
    //[self.liveHeartRateView initializeObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:HEART_RATE_GRAPH_SEGUE_IDENTIFIER])
    {
        self.viewController = (SFAHeartRateGraphViewController *) segue.destinationViewController;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        self.tableViewVerticalSpace.constant    = _oldTableViewVerticalSpace;
        self.segmentedControl.superview.hidden  = NO;
        self.activeTimeLabel.hidden             = YES;
        self.imagePlayHead.hidden               = YES;
        self.viewLeftGraph.hidden               = NO;
        self.viewRightGraph.hidden              = NO;
        
        [self.dateRangeTextField resignFirstResponder];
    }
    else
    {
        self.tableViewVerticalSpace.constant    = 0;
        self.segmentedControl.superview.hidden  = YES;
        self.activeTimeLabel.hidden             = NO;
        self.imagePlayHead.hidden               = NO;
        self.viewLeftGraph.hidden               = YES;
        self.viewRightGraph.hidden              = YES;
    }
    
    self.heartRateLandscapeView.hidden = toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    SFAHeartRateScrollViewController *heartRateScrollView = (SFAHeartRateScrollViewController *)parent;
    self.parentScrollView = heartRateScrollView.scrollView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self scrollToFirstData];
    
    
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.viewController.isPortrait)
        return;
    
    NSInteger selectedIndex = self.segmentedControl.selectedSegmentIndex;
//    SFADateRange dateRange  = [self dateRangeForSegmentControlIndex:selectedIndex];
//    CGFloat x               = scrollView.contentOffset.x < 0 ? 0 : scrollView.contentOffset.x;
    CGFloat x               = scrollView.contentOffset.x > 920.0f ? 920.0f : scrollView.contentOffset.x;
    NSInteger index         = 0;
    
    if ([[[self.segmentedControl titleForSegmentAtIndex:selectedIndex] lowercaseString] isEqualToString:[LS_DAY lowercaseString]])
    {
        index = x / (920.0f / DAY_DATA_MAX_COUNT);
        
        //active time label
        NSInteger _hours            = floorf(index / 6);
        NSInteger _minutes          = floorf(index % 6);
        _hours                      = (_hours == 24) ? 0 : _hours;
        NSString *_time             = [NSString stringWithFormat:@"%i:%i0", _hours, _minutes];
        
        if (index >= 0)
            self.activeTimeLabel.text   = [[_time getDateFromStringWithFormat:@"HH:mm"] getDateStringWithFormat:@"hh:mm a"];
    }
    else if ([[[self.segmentedControl titleForSegmentAtIndex:selectedIndex] lowercaseString] isEqualToString:[LS_WEEK lowercaseString]])
    {
        index = x / (920.0f / WEEK_DATA_MAX_COUNT);
        
        //active week label
        NSInteger _indexCounter     = index;
        while (_indexCounter > 12)
        {
            _indexCounter -= 12;
        }
        
        NSInteger _hours            = floorf(_indexCounter * 2);
        _hours                      = (_hours == 24) ? 0 : _hours;
        NSString *_time             = [NSString stringWithFormat:@"%i:00", _hours];
        
        if (_indexCounter >= 0)
            self.activeTimeLabel.text   = [[_time getDateFromStringWithFormat:@"HH:mm"] getDateStringWithFormat:@"hh:mm a"];
    }
    else if ([[[self.segmentedControl titleForSegmentAtIndex:selectedIndex] lowercaseString] isEqualToString:[LS_MONTH lowercaseString]])
    {
        index = x / (920.0f / 31.0f);
        
        //active month label
        NSString *_monthName        = [[_monthSelected getDateFromStringWithFormat:@"MM"] getDateStringWithFormat:@"MMM"];
        self.activeTimeLabel.text   = [NSString stringWithFormat:@"%@ %i",_monthName, index + 1];
    }
    else if ([[[self.segmentedControl titleForSegmentAtIndex:selectedIndex] lowercaseString] isEqualToString:[LS_YEAR lowercaseString]])
    {
       index = x / (920.0f / MONTH_DATA_MAX_COUNT);
        
        //active year label
        NSInteger _indexCounter     = index + 1;
        _indexCounter               = (_indexCounter > 12) ? 12 : _indexCounter;
        NSString *_monthLabel       = [[NSNumber numberWithInt:_indexCounter] stringValue];
        self.activeTimeLabel.text   = [[_monthLabel getDateFromStringWithFormat:@"MM"] getDateStringWithFormat:@"MMM "];
        self.activeTimeLabel.text   = [self.activeTimeLabel.text stringByAppendingString:_yearSelected];
    }
    
    if (index < self.heartRate.count)
    {
        NSInteger value = 0;
        
        if (self.plotType == SFAHeartRatePlotTypeBar)
        {
            CGPoint point       = [self.heartRate[index] CGPointValue];
            value               = [SFAGraphTools yValueForMaxY:BPM_MAX_Y_VALUE y:point.y];
        }
        else if (self.plotType == SFAHeartRatePlotTypeTradingRange)
        {
            NSDictionary *record    = self.heartRate[index];
            NSNumber *minValue      = [record objectForKey:Y_MIN_VALUE_KEY];
            NSNumber *maxValue      = [record objectForKey:Y_MAX_VALUE_KEY];
            NSInteger minInteger    = [SFAGraphTools yValueForMaxY:BPM_MAX_Y_VALUE y:minValue.integerValue];
            NSInteger maxInteger    = [SFAGraphTools yValueForMaxY:BPM_MAX_Y_VALUE y:maxValue.integerValue];
            value                   = (minInteger + maxInteger) / 2;
        }
        
        self.bpmLabel.text  = [NSString stringWithFormat:@"%i", value];
        
        [self setStatusViewWithValue:value minValue:BPM_MIN_Y_VALUE maxValue:BPM_MAX_Y_VALUE];
    }
    else
    {
        self.bpmLabel.text = @"0";
        
        [self setStatusViewWithValue:BPM_MIN_Y_VALUE minValue:BPM_MIN_Y_VALUE maxValue:BPM_MAX_Y_VALUE];
    }
    
}

#pragma mark - UITextFieldDelegate Methods
- (void)pickerViewDidSelectIndex:(NSInteger)selectedIndex
{
    self.segmentedControl.selectedSegmentIndex = selectedIndex;
    SFADateRange dateRange = SFADateRangeDay;
    
    if (selectedIndex == 0)
    {
        dateRange = SFADateRangeDay;
    }
    else if (selectedIndex == 1)
    {
        dateRange = SFADateRangeWeek;
    }
    else if (selectedIndex == 2)
    {
        dateRange = SFADateRangeMonth;
    }
    else if (selectedIndex == 3)
    {
        dateRange = SFADateRangeYear;
    }
    else
    {
        return;
    }
    
    if ([self.delegate conformsToProtocol:@protocol(SFAHeartRateViewControllerDelegate)])
    {
        [self.delegate heartRateViewController:self didChangeDateRange:dateRange];
    }
}

#pragma mark - SFACalendarControllerDelegate Methods

- (void)calendarController:(SFAMainViewController *)calendarController didSelectDate:(NSDate *)date
{
    [self setContentsWithDate:date];
}

#pragma mark - SFABarPlotDelegate Methods

- (NSInteger)numberOfBarForBarPlot:(SFABarPlot *)barPlot
{
    return self.heartRate.count;
}

- (CGPoint)barPlot:(SFABarPlot *)barPlot pointAtIndex:(NSInteger)index
{
    if (index == 0)
    {
       _scrolled        = NO;
        _scrollIndex    = 0;
    }
    
    CGPoint point = [self.heartRate[index] CGPointValue];
    if (point.y > 0 && !_scrolled)
    {
        _scrolled = YES;
        _scrollIndex = (920.0f / DAY_DATA_MAX_COUNT) * index;
    }
    return point;
}

#pragma mark - SFATradingRangePlotDelegate Methods

- (NSInteger)numberOfRecordsForTradingRangePlot:(SFATradingRangePlot *)tradingRangePlot
{
    return self.heartRate.count;
}

- (CGFloat)tradingRangePlot:(SFATradingRangePlot *)linePlot xValueAtIndex:(NSInteger)index
{
    NSDictionary *record    = self.heartRate[index];
    NSNumber *value         = [record objectForKey:X_VALUE_KEY];
    
    return value.floatValue;
}

- (CGFloat)tradingRangePlot:(SFATradingRangePlot *)linePlot yMinValueAtIndex:(NSInteger)index
{
    NSDictionary *record    = self.heartRate[index];
    NSNumber *value         = [record objectForKey:Y_MIN_VALUE_KEY];
    
    return value.floatValue;
}

- (CGFloat)tradingRangePlot:(SFATradingRangePlot *)linePlot yMaxValueAtIndex:(NSInteger)index
{
    NSDictionary *record    = self.heartRate[index];
    NSNumber *value         = [record objectForKey:Y_MAX_VALUE_KEY];
    
    return value.floatValue;
}

#pragma mark - SFAHeartRateGraphViewControllerDelegate Methods

- (void)graphViewController:(SFAHeartRateGraphViewController *)graphViewController didChangeTime:(NSString *)time
{
    self.activeTimeLabel.text = time;
}

- (void)graphViewController:(SFAHeartRateGraphViewController *)graphViewController didChangeHeartRate:(NSInteger)heartRate
{
    self.bpmLabel.text = [NSString stringWithFormat:@"%i", heartRate];
    self.heartRateAverageValue.text = [NSString stringWithFormat:@"%i", heartRate];
    
    [self setStatusViewWithValue:heartRate minValue:0 maxValue:BPM_MAX_Y_VALUE];
}

- (void)graphViewController:(SFAHeartRateGraphViewController *)graphViewController didChangeMinHeartRate:(NSInteger)minHeartRate
{
    self.heartRateMinValue.text = [NSString stringWithFormat:@"%i", minHeartRate];
}

- (void)graphViewController:(SFAHeartRateGraphViewController *)graphViewController didChangeMaxHeartRate:(NSInteger)maxHeartRate
{
    self.heartRateMaxValue.text = [NSString stringWithFormat:@"%i", maxHeartRate];
}


#pragma mark - Getters

- (NSManagedObjectContext *) managedObjectContext
{
    if (!_managedObjectContext)
    {
        SFASalutronFitnessAppDelegate *appDelegate  = (SFASalutronFitnessAppDelegate *) [UIApplication sharedApplication].delegate;
        _managedObjectContext                       = appDelegate.managedObjectContext;
    }
    
    return _managedObjectContext;
}

- (NSUserDefaults *) userDefaults
{
    if (!_userDefaults)
    {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    return _userDefaults;
}

#pragma mark - Setters

- (void)setPlotType:(SFAHeartRatePlotType)plotType
{
    if (_plotType == plotType)
    {
        return;
    }
    
    if (plotType == SFAHeartRatePlotTypeBar)
    {
        [self.graph removePlot:self.tradingRangePlot];
        [self.graph addPlot:self.barPlot toPlotSpace:self.plotSpace];
    }
    else
    {
        [self.graph removePlot:self.barPlot];
        [self.graph addPlot:self.tradingRangePlot toPlotSpace:self.plotSpace];
    }
    
    _plotType = plotType;
}

#pragma mark - IBAction Methods

- (IBAction)didChangeDateRange:(id)sender
{
    UISegmentedControl *segmentedControler  = (UISegmentedControl *)sender;
    NSInteger selectedIndex                 = segmentedControler.selectedSegmentIndex;
    SFADateRange dateRange                  = SFADateRangeDay;
    
    if([[[segmentedControler titleForSegmentAtIndex:selectedIndex] lowercaseString] isEqualToString:[LS_LIVE lowercaseString]])
    {
        [self.view bringSubviewToFront:self.liveHeartRateView];
        [self.liveHeartRateView startHeartRateLiveStream];
        
        if(self.parentScrollView)
            self.parentScrollView.scrollEnabled = NO;
    }
    if ([[[segmentedControler titleForSegmentAtIndex:selectedIndex] lowercaseString] isEqualToString:[LS_DAY lowercaseString]])
    {
        [self.view bringSubviewToFront:[self.view viewWithTag:101]];
        dateRange = SFADateRangeDay;
        [self.liveHeartRateView endHeartRateLiveStream];
        
        if(self.parentScrollView)
            self.parentScrollView.scrollEnabled = YES;
    }
    else if ([[[segmentedControler titleForSegmentAtIndex:selectedIndex] lowercaseString] isEqualToString:[LS_WEEK lowercaseString]])
    {
        [self.view bringSubviewToFront:[self.view viewWithTag:101]];
        dateRange = SFADateRangeWeek;
        [self.liveHeartRateView endHeartRateLiveStream];
        
        if(self.parentScrollView)
            self.parentScrollView.scrollEnabled = YES;
    }
    else if ([[[segmentedControler titleForSegmentAtIndex:selectedIndex] lowercaseString] isEqualToString:[LS_MONTH lowercaseString]])
    {
        [self.view bringSubviewToFront:[self.view viewWithTag:101]];
        dateRange = SFADateRangeMonth;
        [self.liveHeartRateView endHeartRateLiveStream];
        
        if(self.parentScrollView)
            self.parentScrollView.scrollEnabled = YES;
    }
    else if ([[[segmentedControler titleForSegmentAtIndex:selectedIndex] lowercaseString] isEqualToString:[LS_YEAR lowercaseString]])
    {
        [self.view bringSubviewToFront:[self.view viewWithTag:101]];
        dateRange = SFADateRangeYear;
        [self.liveHeartRateView endHeartRateLiveStream];
        
        if(self.parentScrollView)
            self.parentScrollView.scrollEnabled = YES;
    }
    else
    {
        return;
    }
    
    if ([self.delegate conformsToProtocol:@protocol(SFAHeartRateViewControllerDelegate)])
    {
        [self.delegate heartRateViewController:self didChangeDateRange:dateRange];
    }
    
    [self adjustBarPlotWidth];
}

#pragma mark - Private Methods
- (void)scrollToFirstRecord
{
    /*CGPoint _contentOffset = CGPointMake(_scrollIndex + 2,  0);
    if (self.viewController.scrollView.contentOffset.x != _contentOffset.x)
        [self.viewController.scrollView setContentOffset:_contentOffset animated:YES];
    
    _scrolled = NO;*/
    if (!self.viewController.isPortrait)
        [self.viewController scrollToFirstRecord];
}

- (SFABarPlot *)barPlotWithBarColor:(UIColor *)barColor
{
    SFABarPlot *barPlot     = [SFABarPlot barPlot];
    barPlot.dataDelegate    = self;
    barPlot.fill            = [CPTFill fillWithColor:[CPTColor colorWithCGColor:barColor.CGColor]];
    barPlot.barWidth        = CPTDecimalFromCGFloat([SFAGraphTools barWidthWithWithMaxX:DAY_DATA_MAX_COUNT barCount:1]);
    barPlot.lineStyle       = nil;
    
    return barPlot;
}

- (SFATradingRangePlot *)tradingRangePlotWithBarColor:(UIColor *)barColor
{
    SFATradingRangePlot *tradingRangePlot   = [SFATradingRangePlot tradingRangePlot];
    tradingRangePlot.dataDelegate           = self;
    tradingRangePlot.plotStyle              = CPTTradingRangePlotStyleCandleStick;
    //tradingRangePlot.barWidth               = 3.0f;
    
    return tradingRangePlot;
}

- (void)initializeObjects
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        self.containerHeight.constant = 155;
        self.playHeadHeight.constant = 163;
        self.graphBackgroundHeight.constant = 220;
        
    }
    // Graph View
    self.viewController.delegate = self;
    
    // Active time
    self.activeTimeLabel.text = self.viewController.currentTime;
    
    // Status
    self.percent.text = @"0%";
    
    // Segmented Control
    [self.segmentedControl themeWithSegmentedControlTheme:UISegmentedControlThemeGreen];
    
    //Get watch model connected
    WatchModel _watchModel = [[[NSUserDefaults standardUserDefaults] objectForKey:CONNECTED_WATCH_MODEL] integerValue];
    
    //Remove live bpm menu if watch does not support it
    if (_watchModel == WatchModel_Core_C200 ||
        _watchModel == WatchModel_Move_C300 ||
        _watchModel == WatchModel_Move_C300_Android ||
        _watchModel == WatchModel_R450 ||
        _watchModel == WatchModel_Zone_C410 ||
        _watchModel == WatchModel_R420)
    {
        [self.segmentedControl removeSegmentAtIndex:0 animated:NO];
        self.segmentedControl.selectedSegmentIndex = 1;
        self.segmentedControl.selectedSegmentIndex = 0;
    }
    
    //
    self.pickerView = [[JDAPickerView alloc] initWithArray:@[LS_DAILY, LS_WEEKLY, LS_MONTHLY, LS_YEARLY]
                                                  delegate:self];
    self.pickerView.textField = self.dateRangeTextField;
    self.dateRangeTextField.inputView = self.pickerView;
    
    JDAKeyboardAccessory *keyboardAccessory = [[JDAKeyboardAccessory alloc] initWithDoneAccessoryWithBarStyle:UIBarStyleDefault];
    keyboardAccessory.currentView = self.dateRangeTextField;
    self.dateRangeTextField.inputAccessoryView = keyboardAccessory;
    
    // initial for Fitness
    self.dateRangeTextField.text = LS_DAILY;
    
    // Set date range border
    self.dateRangeView.layer.borderWidth = 1.0f;
    self.dateRangeView.layer.borderColor = DISTANCE_LINE_COLOR.CGColor;
    self.dateRangeView.layer.cornerRadius = 10.0f;
    
    _oldTableViewVerticalSpace = self.tableViewVerticalSpace.constant;
    self.imagePlayHead.hidden  = YES;
}

/*- (void)initializeObjects
{
    // Active time
    self.activeTimeLabel.text = @"12:00 AM";
    
    // Scroll View
    self.viewController.scrollView.delegate = self;
    
    // Graph
    SFAGraphView *graphView                 = self.viewController.graphView;
    self.graph                              = [SFAGraph graphWithGraphView:graphView];
    self.graph.paddingBottom                = 30.0f;
    self.graph.plotAreaFrame.masksToBorder  = NO;
    
    // Axis Line Style
    CPTXYAxisSet *axisSet               = (CPTXYAxisSet *) self.graph.axisSet;
    axisSet.yAxis.hidden                = YES;
    axisSet.xAxis.hidden                = YES;
    axisSet.yAxis.labelTextStyle        = nil;
    axisSet.xAxis.majorTickLineStyle    = nil;
    graphView.hostedGraph               = self.graph;
    
    // Axis Text Style
    CPTMutableTextStyle *style      = [axisSet.xAxis.labelTextStyle mutableCopy];
    style.fontSize                  = 8.0f;
    axisSet.xAxis.labelTextStyle    = style.copy;
    axisSet.xAxis.labelingPolicy    = CPTAxisLabelingPolicyNone;
    
    // Plot Space
    self.plotSpace          = (SFAXYPlotSpace *) self.graph.defaultPlotSpace;
    self.plotSpace.xRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(X_MIN_RANGE) length:CPTDecimalFromFloat(X_MAX_RANGE)];
    self.plotSpace.yRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(Y_MIN_RANGE) length:CPTDecimalFromFloat(Y_MAX_RANGE)];
    
    // Plot
    self.plotType           = SFAHeartRatePlotTypeBar;
    self.barPlot            = [self barPlotWithBarColor:HEART_RATE_LINE_COLOR];
    self.tradingRangePlot   = [self tradingRangePlotWithBarColor:HEART_RATE_LINE_COLOR];
    
    // Status
    self.percent.text   = @"0%";
    
    [self.graph addPlot:self.barPlot toPlotSpace:self.plotSpace];
    [self adjustBarPlotWidth];
    
    [self.segmentedControl themeWithSegmentedControlTheme:UISegmentedControlThemeGreen];
    
    //Get watch model connected
    WatchModel _watchModel          = [[[NSUserDefaults standardUserDefaults] objectForKey:CONNECTED_WATCH_MODEL] integerValue];
    
    //Remove live bpm menu if watch does not support it
    if (_watchModel == WatchModel_Core_C200 ||
        _watchModel == WatchModel_Move_C300 ||
        _watchModel == WatchModel_R450 ||
        _watchModel == WatchModel_Zone_C410)
    {
        [self.segmentedControl removeSegmentAtIndex:0 animated:NO];
        self.segmentedControl.selectedSegmentIndex = 1;
        self.segmentedControl.selectedSegmentIndex = 0;
    }
}*/

- (void)getDataForDate:(NSDate *)date
{
    // Date
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSString *_macAddress           = [[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS];
    _macAddress                     = (_macAddress == nil) ? @"" : _macAddress;
    NSDateComponents *components    = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSString *predicateFormat       = [NSString stringWithFormat:@"(header.date.month == %i) AND (header.date.day == %i) AND (header.date.year == %i) AND (header.device.macAddress == '%@') AND (header.device.user.userID == '%@')",
                                       components.month, components.day, components.year - 1900, _macAddress, [SFAServerAccountManager sharedManager].user.userID];
    
    // Core Data
    JDACoreData *_coreData  = [JDACoreData sharedManager];
    NSArray *data           = [_coreData fetchEntityWithEntityName:STATISTICAL_DATA_POINT_ENTITY
                                                         predicate:[NSPredicate predicateWithFormat:predicateFormat]
                                                       sortWithKey:@"dataPointID"
                                                         ascending:YES
                                                          sortType:SORT_TYPE_NUMBER];
    NSError *error          = nil;
    if (data)
    {
        if (data.count > 0)
        {
            NSMutableArray *heartRate   = [NSMutableArray new];
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index = [data indexOfObject:dataPoint];
                CGFloat x = [SFAGraphTools xWithMaxX:DAY_DATA_MAX_COUNT xValue:index];
                CGFloat y = [SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:dataPoint.averageHR.floatValue];
                CGPoint point = CGPointMake(x, y);
                
                [heartRate addObject:[NSValue valueWithCGPoint:point]];
            }
            
            self.heartRate = heartRate.copy;
        }
        else
        {
            self.heartRate = nil;
        }
    }
    else
    {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    self.plotType                                   = SFAHeartRatePlotTypeBar;
    self.viewController.scrollView.contentOffset    = CGPointZero;
    
    [self.graph hourLabels];
    [self.barPlot reloadData];
}

- (void)getDataForWeek:(NSInteger)week ofYear:(NSInteger)year
{
    // Date
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.weekOfYear           = week;
    components.yearForWeekOfYear    = year;
    components.weekday              = 1;
    NSDate *firstDate               = [calendar dateFromComponents:components];
    components.weekday              = 7;
    NSDate *secondDate              = [calendar dateFromComponents:components];
    
    // Core Data
    components                          = [calendar components:NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit fromDate:firstDate];
    NSString *firstDatePredicate        = [NSString stringWithFormat:@"(header.date.month >= %i AND header.date.day >= %i AND header.date.year >= %i)",
                                           components.month, components.day, components.year - 1900];
    components                          = [calendar components:NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit fromDate:secondDate];
    NSString *secondDatePredicate       = [NSString stringWithFormat:@"(header.date.month <= %i AND header.date.day <= %i AND header.date.year <= %i)",
                                           components.month, components.day, components.year - 1900];
    NSString *predicateFormat           = [NSString stringWithFormat:@"%@ AND %@", firstDatePredicate, secondDatePredicate];
    NSPredicate *predicate              = [NSPredicate predicateWithFormat:predicateFormat];
    NSSortDescriptor *sortDescriptor    = [NSSortDescriptor sortDescriptorWithKey:@"header.date.day" ascending:YES];
//    NSSortDescriptor *sortDescriptor2   = [NSSortDescriptor sortDescriptorWithKey:@"dataPointID" ascending:YES];
    NSFetchRequest *fetchRequest        = [NSFetchRequest fetchRequestWithEntityName:STATISTICAL_DATA_POINT_ENTITY];
    fetchRequest.predicate              = predicate;
    fetchRequest.sortDescriptors        = @[sortDescriptor/*, sortDescriptor2*/];
    NSError *error                      = nil;
    NSArray *data                       = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (data)
    {
        if (data.count > 0)
        {
            CGFloat heartRateMinValue[84]   = {};
            CGFloat heartRateMaxValue[84]   = {};
            NSMutableArray *heartRate       = [NSMutableArray new];
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index             = [data indexOfObject:dataPoint] / 12;
                CGFloat heartRateFloat      = dataPoint.averageHR.floatValue;
                heartRateMaxValue[index]    = heartRateFloat > heartRateMaxValue[index] ? heartRateFloat: heartRateMaxValue[index];
                heartRateMinValue[index]    = heartRateMaxValue[index];
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
            
            for (NSInteger index = 0; index < 84; index++)
            {
                CGFloat offset              = [SFAGraphTools barOffsetWithMaxX:self.maxX barCount:1 barIndex:0];
                NSNumber *x                 = [NSNumber numberWithFloat:([SFAGraphTools xWithMaxX:WEEK_DATA_MAX_COUNT xValue:index] + offset)];
                NSNumber *minY              = [NSNumber numberWithFloat:[SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:heartRateMinValue[index]]];
                NSNumber *maxY              = [NSNumber numberWithFloat:[SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:heartRateMaxValue[index]]];
                NSDictionary *dictionary    = [NSDictionary dictionaryWithObjectsAndKeys:x, X_VALUE_KEY, minY, Y_MIN_VALUE_KEY, maxY, Y_MAX_VALUE_KEY, nil];
                
                [heartRate addObject:dictionary];
            }
            
            self.heartRate = heartRate.copy;
        }
        else
        {
            self.heartRate = nil;
        }
    }
    else
    {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    self.plotType                                   = SFAHeartRatePlotTypeTradingRange;
    self.viewController.scrollView.contentOffset    = CGPointZero;
    
    [self.graph dayLabelsWithWeek:week ofYear:year];
    [self.tradingRangePlot reloadData];
}

- (void)getDataForMonth:(NSInteger)month ofYear:(NSInteger)year
{
    _monthSelected                  = [[NSNumber numberWithInt:month] stringValue];
    
    // Date
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.month                = month;
    components.year                 = year;
    NSDate *date                    = [calendar dateFromComponents:components];
    NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    
    // Core Data
    NSString *predicateFormat           = [NSString stringWithFormat:@"(header.date.month == %i AND header.date.year == %i)",
                                           month, year - 1900];
    NSPredicate *predicate              = [NSPredicate predicateWithFormat:predicateFormat];
    NSSortDescriptor *sortDescriptor    = [NSSortDescriptor sortDescriptorWithKey:@"header.date.day" ascending:YES];
    NSFetchRequest *fetchRequest        = [NSFetchRequest fetchRequestWithEntityName:STATISTICAL_DATA_POINT_ENTITY];
    fetchRequest.predicate              = predicate;
    fetchRequest.sortDescriptors        = @[sortDescriptor];
    NSError *error                      = nil;
    NSArray *data                       = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (data)
    {
        if (data.count > 0)
        {
            CGFloat heartRateMinValue[31]   = {};
            CGFloat heartRateMaxValue[31]   = {};
            NSMutableArray *heartRate       = [NSMutableArray new];
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index             = dataPoint.header.date.day.integerValue - 1;
                CGFloat heartRateFloat      = dataPoint.averageHR.floatValue;
                heartRateMaxValue[index]    = heartRateFloat > heartRateMaxValue[index] ? heartRateFloat: heartRateMaxValue[index];
                heartRateMinValue[index]    = heartRateMaxValue[index];
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
                CGFloat offset              = [SFAGraphTools barOffsetWithMaxX:self.maxX barCount:1 barIndex:0];
                NSNumber *x                 = [NSNumber numberWithFloat:([SFAGraphTools xWithMaxX:range.length xValue:day] + offset)];
                NSNumber *minY              = [NSNumber numberWithFloat:[SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:heartRateMinValue[day]]];
                NSNumber *maxY              = [NSNumber numberWithFloat:[SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:heartRateMaxValue[day]]];
                NSDictionary *dictionary    = [NSDictionary dictionaryWithObjectsAndKeys:x, X_VALUE_KEY, minY, Y_MIN_VALUE_KEY, maxY, Y_MAX_VALUE_KEY, nil];
                
                [heartRate addObject:dictionary];
            }
            
            self.heartRate = heartRate.copy;
        }
        else
        {
            self.heartRate = nil;
        }
    }
    else
    {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    self.plotType                                   = SFAHeartRatePlotTypeTradingRange;
    self.viewController.scrollView.contentOffset    = CGPointZero;
    
    [self.graph dayLabelsWithMonth:month ofYear:year];
    [self.tradingRangePlot reloadData];
}

- (void)getDataForYear:(NSInteger)year
{
    _yearSelected                       = [[NSNumber numberWithInt:year] stringValue];
    
    // Core Data
    NSString *predicateFormat           = [NSString stringWithFormat:@"(header.date.year == %i)", year - 1900];
    NSPredicate *predicate              = [NSPredicate predicateWithFormat:predicateFormat];
    NSSortDescriptor *monthDescriptor   = [NSSortDescriptor sortDescriptorWithKey:@"header.date.month" ascending:YES];
    NSSortDescriptor *dayDescriptor     = [NSSortDescriptor sortDescriptorWithKey:@"header.date.day" ascending:YES];
    NSFetchRequest *fetchRequest        = [NSFetchRequest fetchRequestWithEntityName:STATISTICAL_DATA_POINT_ENTITY];
    fetchRequest.predicate              = predicate;
    fetchRequest.sortDescriptors        = @[monthDescriptor, dayDescriptor];
    NSError *error                      = nil;
    NSArray *data                       = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (data)
    {
        if (data.count > 0)
        {
            CGFloat heartRateMinValue[12]   = {};
            CGFloat heartRateMaxValue[12]   = {};
            NSMutableArray *heartRate       = [NSMutableArray new];
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                NSInteger index             = dataPoint.header.date.month.integerValue - 1;
                CGFloat heartRateFloat      = dataPoint.averageHR.floatValue;
                heartRateMaxValue[index]    = heartRateFloat > heartRateMaxValue[index] ? heartRateFloat: heartRateMaxValue[index];
                heartRateMinValue[index]    = heartRateMaxValue[index];
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
                CGFloat offset              = [SFAGraphTools barOffsetWithMaxX:self.maxX barCount:1 barIndex:0];
                NSNumber *x                 = [NSNumber numberWithFloat:([SFAGraphTools xWithMaxX:MONTH_DATA_MAX_COUNT xValue:month] + offset)];
                NSNumber *minY              = [NSNumber numberWithFloat:[SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:heartRateMinValue[month]]];
                NSNumber *maxY              = [NSNumber numberWithFloat:[SFAGraphTools yWithMaxY:BPM_MAX_Y_VALUE yValue:heartRateMaxValue[month]]];
                NSDictionary *dictionary    = [NSDictionary dictionaryWithObjectsAndKeys:x, X_VALUE_KEY, minY, Y_MIN_VALUE_KEY, maxY, Y_MAX_VALUE_KEY, nil];
                
                [heartRate addObject:dictionary];
            }
            
            self.heartRate = heartRate.copy;
        }
        else
        {
            self.heartRate = nil;
        }
    }
    else
    {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    self.plotType                                   = SFAHeartRatePlotTypeTradingRange;
    self.viewController.scrollView.contentOffset    = CGPointZero;
    
    [self.graph monthLabels];
    [self.tradingRangePlot reloadData];
}

- (SFADateRange)dateRangeForSegmentControlIndex:(NSInteger)index
{
    if (index == 1)
    {
        return SFADateRangeDay;
    }
    else if (index == 2)
    {
        return SFADateRangeWeek;
    }
    else if (index == 3)
    {
        return SFADateRangeMonth;
    }
    else if (index == 4)
    {
        return SFADateRangeYear;
    }
    
    return SFADateRangeDay;
}

- (UIImage *)percentImageWithPercent:(CGFloat)percent
{
    if (percent >= 100.0f)
    {
        return [UIImage imageNamed:@"DashboardMarkerRed"];
    }
    else if (percent >= 75.0f)
    {
        return [UIImage imageNamed:@"DashboardMarkerOrange"];
    }
    else if (percent >= 50.0f)
    {
        return [UIImage imageNamed:@"DashboardMarkerDarkGreen"];
    }
    else if (percent >= 25.0f)
    {
        return [UIImage imageNamed:@"DashboardMarkerLightGreen"];
    }
    else if (percent >= 0.0f)
    {
        return [UIImage imageNamed:@"DashboardMarkerYellow"];
    }
    
    return [UIImage imageNamed:@"DashboardMarkerYellow"];
}

- (CGFloat)xWithStartX:(CGFloat)startX
                      endX:(CGFloat)endX
                       percent:(float)percent
{
    // x
    float x             = endX - startX;
    x                   *= percent;
    x                   += startX;
    
    return x;
}

- (void)setProgressLabelWithStartX:(CGFloat)startX
                              endX:(CGFloat)endX
                           percent:(float)percent
{
    int progress                            = 100 * percent;
    CGFloat newX                            = [self xWithStartX:startX endX:endX percent:percent];
    self.percent.text                       = [NSString stringWithFormat:@"%i%%", progress];
    self.percentImage.image                 = [self percentImageWithPercent:progress];
    self.percentViewLeftConstraint.constant = newX - (self.percent.frame.size.width / 2);
    
    self.percentLandscapeLabel.text                     = [NSString stringWithFormat:@"%i%%", progress];
    self.percentLandscapeImage.image                    = [self percentImageWithPercent:progress];
    self.percentLandscapeViewLeftConstraint.constant    = newX - (self.percent.frame.size.width / 2);
    //[UIView animateWithDuration:0.2f animations:^{
        //[self.view layoutIfNeeded];
    //}];
}

- (void)setStatusViewWithValue:(int)value minValue:(int)minValue maxValue:(int)maxValue
{
    CGFloat startX  = 16.0f;
    CGFloat endX    = 151.0f;
    float percent   = (float)value / [SalutronUserProfile maxBPM];
    
    [self setProgressLabelWithStartX:startX endX:endX percent:percent];
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
        return 31.0f;
    }
    else if (self.calendarController.calendarMode == SFACalendarYear)
    {
        return MONTH_DATA_MAX_COUNT;
    }
    
    return 0.0f;
}

- (void)adjustBarPlotWidth
{
    self.barPlot.barWidth = CPTDecimalFromCGFloat([SFAGraphTools barWidthWithWithMaxX:self.maxX barCount:1]);
    
    if (self.plotType == SFAHeartRatePlotTypeBar)
    {
        self.barPlot.barWidth   = CPTDecimalFromCGFloat([SFAGraphTools barWidthWithWithMaxX:self.maxX barCount:1]);
        self.barPlot.barOffset  = CPTDecimalFromCGFloat([SFAGraphTools barOffsetWithMaxX:self.maxX barCount:1 barIndex:0]);
    }
    else if (self.plotType == SFAHeartRatePlotTypeTradingRange)
    {
        self.tradingRangePlot.barWidth  = self.viewController.graphView.frame.size.width / self.maxX * (1.0f - BAR_SPACE_PERCENTAGE);
    }
}

#pragma mark - Public Methods

- (void)changeDateRange:(SFADateRange)dateRange
{
    if (dateRange == SFADateRangeDay)
    {
        BOOL _isDay = [[[self.segmentedControl titleForSegmentAtIndex:1] lowercaseString] isEqualToString:@"day"];
        self.segmentedControl.selectedSegmentIndex = _isDay ? 1 : 0;
        self.pickerView.selectedIndex = 0;
    }
    else if (dateRange == SFADateRangeWeek)
    {
        BOOL _isWeek = [[[self.segmentedControl titleForSegmentAtIndex:2] lowercaseString] isEqualToString:@"week"];
        self.segmentedControl.selectedSegmentIndex = _isWeek ? 2 : 1;
        self.pickerView.selectedIndex = 1;
    }
    else if (dateRange == SFADateRangeMonth)
    {
        BOOL _isMonth = [[[self.segmentedControl titleForSegmentAtIndex:3] lowercaseString] isEqualToString:@"month"];
        self.segmentedControl.selectedSegmentIndex = _isMonth ? 3 : 2;
        self.pickerView.selectedIndex = 2;
    }
    else if (dateRange == SFADateRangeYear)
    {
        BOOL _isYear = [[[self.segmentedControl titleForSegmentAtIndex:3] lowercaseString] isEqualToString:@"year"];
        self.segmentedControl.selectedSegmentIndex = _isYear ? 3 : 4;
        self.pickerView.selectedIndex = 3;
    }
    
    [self adjustBarPlotWidth];
}

- (void)setContentsWithDate:(NSDate *)date
{
    //[self getDataForDate:date];
    [self.viewController setContentsWithDate:date];
    self.heartRateLabel.text = @"BPM";
    
    if (self.viewController.isPortrait)
    {
        NSInteger averageBPM    = [StatisticalDataPointEntity getAverageBPMForDate:date];
        self.bpmLabel.text      = [NSString stringWithFormat:@"%i", averageBPM];
        [self setStatusViewWithValue:averageBPM minValue:0 maxValue:BPM_MAX_Y_VALUE];
    }
    
}

- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year
{
    //[self getDataForWeek:week ofYear:year];
    [self.viewController setContentsWithWeek:week ofYear:year];
    self.heartRateLabel.text = LS_AVG_BPM;
    
    if (self.viewController.isPortrait)
    {
        NSInteger averageBPM    = [StatisticalDataPointEntity getAverageBPMForWeek:week ofYear:year];
        self.bpmLabel.text      = [NSString stringWithFormat:@"%i", averageBPM];
        [self setStatusViewWithValue:averageBPM minValue:0 maxValue:BPM_MAX_Y_VALUE];
    }
}

- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year
{
    //[self getDataForMonth:month ofYear:year];
    [self.viewController setContentsWithMonth:month ofYear:year];
    self.heartRateLabel.text = LS_AVG_BPM;
    
    if (self.viewController.isPortrait)
    {
        NSInteger averageBPM    = [StatisticalDataPointEntity getAverageBPMForMonth:month ofYear:year];
        self.bpmLabel.text      = [NSString stringWithFormat:@"%i", averageBPM];
        [self setStatusViewWithValue:averageBPM minValue:0 maxValue:BPM_MAX_Y_VALUE];
    }
}

- (void)setContentsWithYear:(NSInteger)year
{
    //[self getDataForYear:year];
    [self.viewController setContentsWithYear:year];
    self.heartRateLabel.text = LS_AVG_BPM;
    
    if (self.viewController.isPortrait)
    {
        NSInteger averageBPM    = [StatisticalDataPointEntity getAverageBPMForYear:year];
        self.bpmLabel.text      = [NSString stringWithFormat:@"%i", averageBPM];
        [self setStatusViewWithValue:averageBPM minValue:0 maxValue:BPM_MAX_Y_VALUE];
    }
}

@end
