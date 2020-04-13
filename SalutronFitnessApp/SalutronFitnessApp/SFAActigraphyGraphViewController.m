//
//  SFAActigraphyGraphViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/11/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "StatisticalDataPointEntity+Data.h"
#import "SleepDatabaseEntity+Data.h"
#import "WorkoutInfoEntity+Data.h"
#import "CPTGraph+Label.h"
#import "TimeDate+Data.h"

#import "SFAMainViewController.h"

#import "StatisticalDataHeaderEntity.h"
#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "DateEntity.h"

#import "SFAGraph.h"
#import "SFAXYPlotSpace.h"
#import "SFABarPlot.h"
#import "SFAGraphTools.h"
#import "SFAActigraphyGraphViewController.h"

#import "UIViewController+Helper.h"

#define Y_MIN_VALUE_KEY     @"minValue"
#define Y_MAX_VALUE_KEY     @"maxValue"
#define X_VALUE_KEY         @"xValue"

#define DAILY_PADDING       49.0f
#define WEEKLY_PADDING      29.0f

#define DAY_X_BAR_SIZE      18
#define DAY_X_BAR_OFFSET    200//76
#define DAY_X_BAR_TAG       1000

#define SLEEP_MAX_HOUR                      15 //3pm is the max time for turn over

typedef enum
{
    SFAActigraphyBarTypeActive,
    SFAActigraphyBarTypeLightSleep,
    SFAActigraphyBarTypeMediumSleep,
    SFAActigraphyBarTypeDeepSleep,
    SFAActigraphyBarTypeWorkout,
    SFAActigraphyBarTypeSedentary,
    SFAActigraphyBarTypeWristOff
}SFAActigraphyBarType;

@interface SFAActigraphyGraphViewController () <CPTBarPlotDataSource>

// Graph
@property (strong, nonatomic) SFAGraph          *graph;
@property (strong, nonatomic) SFAXYPlotSpace    *plotSpace;
@property (strong, nonatomic) SFABarPlot        *barPlot;
@property (nonatomic) CGFloat                   barWidth;
@property (nonatomic) CGFloat                   barSpace;

// Data Source
@property (strong, nonatomic) NSArray   *dataSource; //of NSDictionary
@property (strong, nonatomic) NSArray   *sedentaryIndexes;
@property (strong, nonatomic) NSArray   *lightSleepIndexes; //of NSNumber
@property (strong, nonatomic) NSArray   *mediumSleepIndexes;
@property (strong, nonatomic) NSArray   *deepSleepIndexes; //of NSNumber
@property (strong, nonatomic) NSArray   *workoutIndexes; //of NSNumber
@property (strong, nonatomic) NSArray   *wristOffIndexes; //of NSNumber
@property (nonatomic) NSInteger         activeTimeCount;
@property (nonatomic) NSInteger         deepSleepCount;
@property (nonatomic) NSInteger         lightSleepCount;
@property (nonatomic) NSInteger         workoutCount;

@property (strong, nonatomic) NSString  *totalActiveTime;
@property (strong, nonatomic) NSString  *totalSleepTime;
@property (strong, nonatomic) NSString  *totalSedentaryTime;

@property (nonatomic) NSInteger         totalActiveTimeHour;
@property (nonatomic) NSInteger         totalActiveTimeMinute;

@property (readwrite, nonatomic) NSString *currentDay;

@property (readwrite, nonatomic) NSInteger  month;
@property (readwrite, nonatomic) NSInteger  year;
@property (readwrite, nonatomic) NSInteger  week;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphLeftHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphRightHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewHeight;

@end

@implementation SFAActigraphyGraphViewController

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


#pragma mark - CPTBarPlotDataSource Methods

- (CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx
{
    NSNumber *number    = [NSNumber numberWithInt:idx];
    UIColor *color      = ACTIVE_LINE_COLOR;
    
    if ([self.deepSleepIndexes containsObject:number])
    {
        color = DEEP_SLEEP_LINE_COLOR;
    }
    else if ([self.mediumSleepIndexes containsObject:number]) {
        color = MEDIUM_SLEEP_LINE_COLOR;
    }
    else if ([self.lightSleepIndexes containsObject:number])
    {
        color = LIGHT_SLEEP_LINE_COLOR;
    }
    else if ([self.workoutIndexes containsObject:number])
    {
        color = WORKOUT_LINE_COLOR;
    }
    else if ([self.sedentaryIndexes containsObject:number]) {
        color = CALORIES_LINE_COLOR;
    }
    
    if ([self.wristOffIndexes containsObject:number]) {
        color = [UIColor lightGrayColor];
    }
    
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
    NSDictionary *dictionary = self.dataSource[idx];
    
    if (fieldEnum == CPTBarPlotFieldBarLocation)
    {
        return [dictionary objectForKey:X_VALUE_KEY];
    }
    else if (fieldEnum == CPTBarPlotFieldBarBase)
    {
        return [dictionary objectForKey:Y_MIN_VALUE_KEY];
    }
    else if (fieldEnum == CPTBarPlotFieldBarTip)
    {
        return [dictionary objectForKey:Y_MAX_VALUE_KEY];
    }
    
    return [NSNumber numberWithInt:0];
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //Get x value
    CGFloat x       = scrollView.contentOffset.x < 0 ? 0 : scrollView.contentOffset.x;
    x               = scrollView.contentOffset.x > self.graphViewWidth ? self.graphViewWidth : x;
    //Get index value
    NSInteger index = x / (self.barWidth + self.barSpace);
    index           = index < self.maxX ? index : self.maxX;
    
    //Set count values
    NSInteger activeTimeCount   = 0;
    NSInteger deepSleepCount    = 0;
    NSInteger mediumSleepCount  = 0;
    NSInteger lightSleepCount   = 0;
    NSInteger workoutCount      = 0;
    NSInteger sedentaryCount    = 0;
    
    //Insert index to data
    NSMutableArray *data = [NSMutableArray new];
    
    
    //Day view
    
    //if (self.calendarController.calendarMode == SFACalendarDay)
    //{
    //    self.activeTimeCount    = self.dataSource.count - (self.workoutIndexes.count + self.deepSleepIndexes.count + self.lightSleepIndexes.count);
    //    self.workoutCount   = self.workoutIndexes.count;
    //    self.deepSleepCount = self.deepSleepIndexes.count + self.lightSleepIndexes.count;
    //}
    //else
    
    //Week view onwards
    if (self.calendarController.calendarMode != SFACalendarDay)
    {
        for (NSDictionary *dictionary in self.dataSource) {
            NSNumber *newX      = [dictionary objectForKey:X_VALUE_KEY];
            if (self.calendarController.calendarMode == SFACalendarYear) {
                newX                = @(newX.integerValue);
            }
            else{
                newX                = @(newX.integerValue + self.barSpace);
            }
            NSNumber *newXWidth = @(newX.integerValue + self.barWidth);
            if (x >= newX.integerValue && x <= newXWidth.integerValue) {
                [data addObject:@([self.dataSource indexOfObject:dictionary])];
            }
        }
        
        //Count number of data
        for (NSNumber *number in data) {
            if ([self.lightSleepIndexes containsObject:number]) {
                lightSleepCount ++;
            } else if ([self.mediumSleepIndexes containsObject:number]) {
                mediumSleepCount ++;
            } else if ([self.deepSleepIndexes containsObject:number]) {
                deepSleepCount ++;
            } else if ([self.workoutIndexes containsObject:number]) {
                workoutCount ++;
            } else if ([self.sedentaryIndexes containsObject:number]) {
                 sedentaryCount++;
            } else {
                activeTimeCount ++;
            }
        }
        
        self.activeTimeCount    = sedentaryCount;
        self.deepSleepCount     = deepSleepCount;
        //self.mediumSleepCount   = mediumSleepCount;
        self.lightSleepCount    = lightSleepCount;
        self.workoutCount       = activeTimeCount;
        
        if ((self.calendarController.calendarMode == SFACalendarMonth ||
            self.calendarController.calendarMode == SFACalendarYear) ||
            self.calendarController.calendarMode == SFACalendarWeek) {
            
            if (self.calendarController.calendarMode == SFACalendarWeek) {
                if (index < 0) {
                    index = 0;
                }
                if (index > 6) {
                    index = 6;
                }
                index++;
                
                NSCalendar *calendar            = [NSCalendar currentCalendar];
                NSDateComponents *components    = [NSDateComponents new];
                components.month                = self.month;
                components.year                 = self.year;
                components.week                 = self.week;
                components.weekday              = index;
                NSDate *date                    = [calendar dateFromComponents:components];
                NSDateFormatter *formatter      = [NSDateFormatter new];
                
                TimeDate *timeDate = [TimeDate getData];
                
                if (timeDate.dateFormat == 0) {
                    formatter.dateFormat    = @"dd MMMM, YYYY";
                } else {
                    formatter.dateFormat    = @"MMMM dd, YYYY";
                }
                
                self.currentDay = [formatter stringFromDate:date];
            } else if (self.calendarController.calendarMode == SFACalendarMonth) {
                NSCalendar *calendar            = [NSCalendar currentCalendar];
                NSDateComponents *components    = [NSDateComponents new];
                components.month                = self.month;
                components.year                 = self.year;
                components.day                  = index + 1;
                NSDate *date                    = [calendar dateFromComponents:components];
                NSDateFormatter *formatter      = [NSDateFormatter new];
                
                TimeDate *timeDate = [TimeDate getData];
                
                if (timeDate.dateFormat == 0) {
                    formatter.dateFormat    = @"dd MMMM, YYYY";
                } else {
                    formatter.dateFormat    = @"MMMM dd, YYYY";
                }
                
                self.currentDay = [formatter stringFromDate:date];
            } else if (self.calendarController.calendarMode == SFACalendarYear) {
                index -= 1;
                NSCalendar *calendar            = [NSCalendar currentCalendar];
                NSDateComponents *components    = [NSDateComponents new];
                components.month                = 1;
                components.day                  = 1;
                components.year                 = self.year;
                NSDate *firstDate               = [calendar dateFromComponents:components];
                NSDate *date                    = [firstDate dateByAddingTimeInterval:DAY_SECONDS * index];
                NSDateFormatter *formatter      = [NSDateFormatter new];
                
                TimeDate *timeDate = [TimeDate getData];
                
                if (timeDate.dateFormat == 0) {
                    formatter.dateFormat    = @"dd MMMM, YYYY";
                } else {
                    formatter.dateFormat    = @"MMMM dd, YYYY";
                }
                
                self.currentDay = [formatter stringFromDate:date];
                
                if (index < 0) {
                    self.currentDay = [formatter stringFromDate:firstDate];
                }
            }
            
        }
    }
}

#pragma mark - Private Methods
- (void)_drawView
{
    int deepSleepCounter            = 0; //0 if start of deepsleep
    int workoutCounter              = 0; //0 if start of workout
    NSMutableArray *deepSleepImages = [NSMutableArray array];
    NSMutableArray *workoutImages   = [NSMutableArray array];
    
    //Get sleep data
    for (NSDictionary *dictionary in self.dataSource) {
        //convert index to x offset of scrollview
        NSNumber *xAxis     = [dictionary objectForKey:X_VALUE_KEY];
        if (self.isPortrait) {
            xAxis           = @((xAxis.floatValue / 1728) * 310);
        }
        
        //Get object index
        NSNumber *index = @([self.dataSource indexOfObject:dictionary]);
        
        //draw workout view inside scrollview
        CGRect frame            = CGRectMake(xAxis.floatValue + self.graphLeftHorizontalSpace.constant,
                                             DAY_X_BAR_OFFSET,
                                             self.barWidth + self.barSpace,
                                             DAY_X_BAR_SIZE);
        UIView *view            = [[UIView alloc] initWithFrame:frame];
        view.tag                = DAY_X_BAR_TAG;
        
        if ([self.deepSleepIndexes containsObject:index]) {
            view.backgroundColor = DEEP_SLEEP_LINE_COLOR;
        } else if ([self.mediumSleepIndexes containsObject:index]) {
            view.backgroundColor = MEDIUM_SLEEP_LINE_COLOR;
        } else if ([self.lightSleepIndexes containsObject:index]) {
            view.backgroundColor = LIGHT_SLEEP_LINE_COLOR;
        } else if ([self.workoutIndexes containsObject:index]) {
            view.backgroundColor = HEART_RATE_LINE_COLOR;
        } else if ([self.sedentaryIndexes containsObject:index]) {
            view.backgroundColor = CALORIES_LINE_COLOR;
        } else {
            view.backgroundColor = ACTIVE_LINE_COLOR;
        }
        
        //view.backgroundColor    = [self.deepSleepIndexes containsObject:index] ? DEEP_SLEEP_LINE_COLOR : CALORIES_LINE_COLOR;
        [self.scrollView addSubview:view];
        
        //Draw image
        frame                   = CGRectMake(xAxis.floatValue + self.graphLeftHorizontalSpace.constant,
                                             DAY_X_BAR_OFFSET,
                                             self.barWidth + self.barSpace + 2,
                                             DAY_X_BAR_SIZE);
        UIImageView *imageView  = [[UIImageView alloc] initWithFrame:frame];
        imageView.tag           = DAY_X_BAR_TAG;
        imageView.contentMode   = UIViewContentModeLeft;
        
        if ([self.deepSleepIndexes containsObject:index] ||
            [self.mediumSleepIndexes containsObject:index] ||
            [self.lightSleepIndexes containsObject:index]) {
            //If start of deepsleep draw bed icon
            if (deepSleepCounter == 0) {
                imageView.image = [UIImage imageNamed:@"SleepActigraphyBedIcon"];
                [deepSleepImages addObject:imageView];
            }
            deepSleepCounter++;
            workoutCounter = 0;
        } else if ([self.workoutIndexes containsObject:index]) {
            //if start of workout draw running icon
            if (workoutCounter == 0) {
                imageView.image  = [UIImage imageNamed:@"SleepActigraphyIcon"];
                [workoutImages addObject:imageView];
            }
            workoutCounter++;
            deepSleepCounter = 0;
        } else {
            deepSleepCounter    = 0;
            workoutCounter      = 0;
        }
    }
    
    //Add image
    for (UIImageView *imageView in deepSleepImages) {
        [self.scrollView addSubview:imageView];
    }
    
    for (UIImageView *imageView in workoutImages) {
        [self.scrollView addSubview:imageView];
    }
    
}

- (void)_removeScrollViewDayBars
{
    for (UIView *subView in self.scrollView.subviews) {
        if ([subView tag] == DAY_X_BAR_TAG)
            [subView removeFromSuperview];
    }
}

- (void)_adjustView
{
    if (_isPortrait)
    {
        self.scrollView.scrollEnabled           = NO;
        //self.graphViewWidthConstraint.constant  = self.view.window.frame.size.width - (GRAPH_PORTRAIT_HORIZONTAL_MARGIN * 2);
        self.graphViewWidthConstraint.constant  = self.view.window.frame.size.width - 10;
        self.graphLeftHorizontalSpace.constant  = GRAPH_PORTRAIT_HORIZONTAL_MARGIN;
        self.graphRightHorizontalSpace.constant = GRAPH_PORTRAIT_HORIZONTAL_MARGIN;
    }
    else
    {
        self.scrollView.scrollEnabled           = YES;
        self.graphViewWidthConstraint.constant  = self.graphViewWidth;
        
        if(self.isIOS8AndAbove) {
            self.graphLeftHorizontalSpace.constant  = self.view.window.frame.size.width / 2;
            self.graphRightHorizontalSpace.constant = self.view.window.frame.size.width / 2;
        } else {
            self.graphLeftHorizontalSpace.constant  = self.view.window.frame.size.height / 2;
            self.graphRightHorizontalSpace.constant = self.view.window.frame.size.height / 2;
        }
    }
    
    [self adjustGraphViewWidth];
    [self adjustBarWidth];
    //[self adjustTickLocation];
}

- (CGFloat)graphViewWidth
{
    CGFloat graphViewWidth  = self.barWidth * [self maxX];
    graphViewWidth          += ([self maxX] * self.barSpace);
    
    return graphViewWidth;
}

- (CGFloat)barWidth
{
    if (self.calendarController.calendarMode == SFACalendarDay) {
        return DAY_DATA_BAR_WIDTH / 2;
    } else if (self.calendarController.calendarMode == SFACalendarYear) {
        return 3;
    }
    
    return DAY_DATA_BAR_WIDTH;
}

- (CGFloat)barSpace
{
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
        return 2;
    }
    return 0.0f;
}

- (void)initializeObjects
{
    
    // Graph
    self.graph                              = [SFAGraph graphWithGraphView:self.graphView];
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        self.graphViewHeight.constant = 200;
    }
    self.graph.paddingLeft                  = 0.0f;
    self.graph.paddingRight                 = 0.0f;
    self.graph.paddingBottom                = 30.0f;
    self.graph.paddingTop                   = 0.0f;
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
    axisSet.xAxis.tickDirection                 = CPTSignNone;
    
    // Plot Space
    self.plotSpace          = (SFAXYPlotSpace *) self.graph.defaultPlotSpace;
    self.plotSpace.xRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(X_MIN_RANGE) length:CPTDecimalFromFloat(self.graphViewWidth)];
    self.plotSpace.yRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-10.0f) length:CPTDecimalFromFloat(Y_MAX_RANGE * 2)];
    
    // Plot
    self.barPlot                = [SFABarPlot barPlot];
    self.barPlot.dataSource     = self;
    self.barPlot.barWidth       = CPTDecimalFromCGFloat(self.barWidth);
    self.barPlot.barOffset      = CPTDecimalFromCGFloat((self.barWidth + self.barSpace) / 2);
    self.barPlot.barBasesVary   = YES;
    self.barPlot.anchorPoint    = CGPointZero;
    self.barPlot.fill           = [CPTFill fillWithColor:[CPTColor colorWithCGColor:CALORIES_LINE_COLOR.CGColor]];
    self.barPlot.lineStyle      = nil;
    
    _isPortrait                 = YES;
    [self _adjustView];
    
    [self.graph addPlot:self.barPlot toPlotSpace:self.plotSpace];
    [self adjustGraphViewWidth];
    [self adjustBarWidth];
    //[self adjustTickLocation];
}

//- (void)adjustTickLocation
- (void)adjustBarWidth
{
    self.barPlot.barWidth       = CPTDecimalFromCGFloat(self.barWidth);
    self.barPlot.barOffset      = CPTDecimalFromCGFloat((self.barWidth + self.barSpace) / 2);
    if (self.calendarController.calendarMode == SFACalendarYear) {
        self.barPlot.barOffset  = CPTDecimalFromCGFloat(self.barWidth*-1.0);
    }
    
    //NSMutableSet *tickLocations = [NSMutableSet new];
    
    //for (NSInteger a = 0; a <= [self maxX]; a++)
    //{
    //    NSDecimal tickLocation  = CPTDecimalFromInt(a * (self.barWidth + self.barSpace));
    //    NSNumber *number        = [NSDecimalNumber decimalNumberWithDecimal:tickLocation];
    //
    //    [tickLocations addObject:number];
    //}
    
    //CPTXYAxisSet *axisSet               = (CPTXYAxisSet *) self.graph.axisSet;
    //axisSet.xAxis.majorTickLocations    = tickLocations.copy;
}

- (void)getDataForDate:(NSDate *)date
{
    NSArray *data = [StatisticalDataPointEntity dataPointsForDate:date];
    
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    WatchModel watchModel           = [[userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
    
    if (data.count > 0)
    {
        CGFloat maxActiveY  = 0;
        //CGFloat maxSleepY   = 0;
        
        NSDate *yesterday               = [date dateByAddingTimeInterval:-DAY_SECONDS];
        NSArray *yesterdaySleeps        = [SleepDatabaseEntity sleepDatabaseForDate:yesterday];
        NSArray *sleeps                 = [SleepDatabaseEntity sleepDatabaseForDate:date];
        NSArray *workouts               = nil;
        
        if (watchModel != WatchModel_Core_C200 &&
            watchModel != WatchModel_Move_C300 &&
            watchModel != WatchModel_Move_C300_Android &&
            watchModel != WatchModel_Zone_C410 &&
            watchModel != WatchModel_R420) {
             workouts = [WorkoutInfoEntity getWorkoutInfoWithDate:date];
        }
        
        NSMutableArray *sleepIndexes        = [NSMutableArray new];
        NSMutableArray *deepSleepIndexes    = [NSMutableArray new];
        NSMutableArray *mediumSleepIndexes  = [NSMutableArray new];
        NSMutableArray *lightSleepIndexes   = [NSMutableArray new];
        NSMutableArray *workoutIndexes      = [NSMutableArray new];
        NSMutableArray *wristOffIndexes     = [NSMutableArray new];
        NSMutableArray *sedentaryIndexes    = [NSMutableArray new];
        NSMutableArray *dataSource          = [NSMutableArray new];
        
        NSInteger lightSleepCount = 0;
//        NSInteger mediumSleepCount = 0;
        NSInteger deepSleepCount = 0;
        NSInteger workoutCount = 0;
        NSInteger sedentaryCount = 0;
        NSInteger activeCount = 0;
        
        NSInteger totalActiveTime = 0;
        NSInteger totalSleepTime = 0;
        NSInteger totalSedentaryTime = 0;
        
        for (SleepDatabaseEntity *sleep in yesterdaySleeps)
        {
            NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6) + (sleep.sleepStartMin.integerValue / 10);
            NSInteger endIndex       = sleep.adjustedSleepEndMinutes/10;
            
            if (startIndex >= endIndex)
            {
                deepSleepCount ++;
                totalSleepTime += sleep.sleepDuration.integerValue;
                
                for (NSInteger a = 0; a <= endIndex; a++)
                {
                    NSNumber *number = [NSNumber numberWithInt:a];
                    [sleepIndexes addObject:number];
                }
            }
            
        }
        
        for (SleepDatabaseEntity *sleep in sleeps)
        {
            NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6) + (sleep.sleepStartMin.integerValue / 10);
            NSInteger endIndex      = (sleep.sleepEndHour.integerValue * 6) + (sleep.sleepEndMin.integerValue / 10);
            endIndex                = endIndex >= DAY_DATA_MAX_COUNT - 1 ? DAY_DATA_MAX_COUNT - 1 : endIndex;
            endIndex                = endIndex <= startIndex ? DAY_DATA_MAX_COUNT - 1 : endIndex;
            
            deepSleepCount ++;
            activeCount += (endIndex < DAY_DATA_MAX_COUNT - 1);
            
            for (NSInteger a = startIndex; a <= endIndex; a++)
            {
                NSNumber *number = [NSNumber numberWithInt:a];
                [sleepIndexes addObject:number];
            }
            
            if (startIndex < endIndex &&
                sleep.sleepEndHour.integerValue < 23) {
                //totalSleepTime += sleep.sleepDuration.integerValue;
            }
            
            //if (startIndex < endIndex && sleep.sleepEndHour.integerValue < 23)
            //{
            //    for (NSInteger a = startIndex; a <= endIndex; a++)
            //    {
            //        NSNumber *number = [NSNumber numberWithInt:a];
            //        [sleepIndexes addObject:number];
            //    }
            //}
        }
        
        for (WorkoutInfoEntity *workout in workouts)
        {
            NSInteger startIndex    = (workout.stampHour.integerValue * 6) + (workout.stampMinute.integerValue / 10);
            NSInteger endIndex      = startIndex + (workout.hour.integerValue * 6) + (workout.minute.integerValue / 10);
            endIndex                = endIndex >= DAY_DATA_MAX_COUNT - 1 ? DAY_DATA_MAX_COUNT - 1 : endIndex;
            
            workoutCount ++;
            activeCount ++;
            
            //totalActiveTime += workout.hour.integerValue * 60 + workout.minute.integerValue;
            
            for (NSInteger a = startIndex; a <= endIndex; a++)
            {
                NSNumber *number = [NSNumber numberWithInt:a];
                [workoutIndexes addObject:number];
            }
        }
        
        for (NSInteger a = 0; a < data.count; a++)
        {
            StatisticalDataPointEntity *dataPoint   = [data objectAtIndex:a];
            NSNumber *number                        = [NSNumber numberWithInt:a];
            CGFloat value                           = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
            value                                   += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
            
            if ([sleepIndexes containsObject:number])
            {
                //maxSleepY = maxSleepY > value ? maxSleepY : value;
            }
            else
            {
                maxActiveY = maxActiveY > value ? maxActiveY : value;
            }
        }
        
        for (NSInteger a = 0; a < data.count; a++)
        {
            StatisticalDataPointEntity *dataPoint = [data objectAtIndex:a];
            
            NSNumber *number    = [NSNumber numberWithInt:a];
            CGFloat value       = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
            value               += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
            CGFloat x           = (self.barWidth + self.barSpace) * a;
            CGFloat y           = 0;
            
            if ([sleepIndexes containsObject:number])
            {
                value = (120 * 5) - value;
                y = [SFAGraphTools yWithMaxY:(120 * 5) yValue:-value];
                
                if (value >= 300) {
                    [deepSleepIndexes addObject:@(a)];
                } else if (value >= 150) {
                    [mediumSleepIndexes addObject:@(a)];
                } else {
                    [lightSleepIndexes addObject:@(a)];
                }
                
                totalSleepTime += 10;
            }
            else
            {
                if (value < (40 * 5)) {
                    [sedentaryIndexes addObject:@(a)];
                    
                    if (![sedentaryIndexes containsObject:@(a - 1)]) {
                        sedentaryCount ++;
                    }
                    
                    totalSedentaryTime += 10;
                } else {
                    if ([sedentaryIndexes containsObject:@(a - 1)]) {
                        activeCount ++;
                    }
                    
                    totalActiveTime += 10;
                }
                y = [SFAGraphTools yWithMaxY:maxActiveY yValue:value];
            }
            
            NSDictionary *dictionary = @{ X_VALUE_KEY       : [NSNumber numberWithFloat:x],
                                          Y_MIN_VALUE_KEY   : [NSNumber numberWithFloat:0],
                                          Y_MAX_VALUE_KEY   : [NSNumber numberWithFloat:y]};
            
            [dataSource addObject:dictionary];
            
            if (dataPoint.wristDetection.boolValue == NO) {
                [wristOffIndexes addObject:number];
            }
        }
        
        totalSleepTime = [self getTotalSleepTimeForDate:date];
        
        self.dataSource         = dataSource.copy;
        self.lightSleepIndexes  = lightSleepIndexes.copy;
        self.mediumSleepIndexes = mediumSleepIndexes.copy;
        self.deepSleepIndexes   = deepSleepIndexes.copy;
        self.workoutIndexes     = workoutIndexes.copy;
        self.wristOffIndexes    = wristOffIndexes.copy;
        self.sedentaryIndexes   = sedentaryIndexes.copy;
        
        self.deepSleepCount = deepSleepCount;
        //self.mediumSleepCount = mediumSleepCount;
        self.lightSleepCount = lightSleepCount;
        //self.workoutCount = workoutCount;
        self.activeTimeCount = sedentaryCount;
        self.workoutCount = activeCount;
        
        NSInteger activeTimeHour = totalActiveTime / 60;
        NSInteger activeTimeMinute = totalActiveTime % 60;
        NSInteger sleepTimeHour = totalSleepTime / 60;
        NSInteger sleepTimeMinute = totalSleepTime % 60;
        NSInteger sedentaryTimeHour = totalSedentaryTime / 60;
        NSInteger sedentaryTimeMinute = totalSedentaryTime % 60;
        
        self.totalActiveTime    = [NSString stringWithFormat:@"%iH %iM", activeTimeHour, activeTimeMinute];
        self.totalSleepTime     = [NSString stringWithFormat:@"%iH %iM", sleepTimeHour, sleepTimeMinute];
        self.totalSedentaryTime = [NSString stringWithFormat:@"%iH %iM", sedentaryTimeHour, sedentaryTimeMinute];
        
        self.totalActiveTimeHour = activeTimeHour;
        self.totalActiveTimeMinute = activeTimeMinute;
    }
    else
    {
        self.dataSource         = nil;
        self.lightSleepIndexes  = nil;
        self.deepSleepIndexes   = nil;
        self.workoutIndexes     = nil;
        self.wristOffIndexes    = nil;
        
        self.deepSleepCount = 0;
        self.lightSleepCount = 0;
        self.workoutCount = 0;
        self.activeTimeCount = 0;
        
        self.totalActiveTime    = @"0H 0M";
        self.totalSleepTime     = @"0H 0M";
        self.totalSedentaryTime = @"0H 0M";
        
        self.totalActiveTimeHour = 0;
        self.totalActiveTimeMinute = 0;
    }
    
    [self.barPlot reloadData];
    
    [self adjustGraphViewWidth];
    [self adjustGraphRange:SFADateRangeDay];
    [self adjustBarWidth];
    //[self adjustTickLocation];
    
    //self.activeTimeCount    = self.dataSource.count - (self.workoutIndexes.count + self.deepSleepIndexes.count + self.lightSleepIndexes.count);
    //self.workoutCount       = self.workoutIndexes.count;
    //self.deepSleepCount     = self.deepSleepIndexes.count + self.lightSleepIndexes.count;
    
    [self _removeScrollViewDayBars];
    
    if (self.isPortrait) return;
    [self _drawView];
}

- (CGFloat)maxX
{
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
        return YEAR_ACT_DATA_MAX_COUNT;
    }
    
    return 0.0f;
}

- (void)getDataForWeek:(NSUInteger)week ofYear:(NSUInteger)year
{
    NSArray *data = [StatisticalDataPointEntity dataPointsForWeek:week ofYear:year];
    
//    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
//    WatchModel watchModel           = [[userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
    
    if (data.count > 0)
    {
        NSMutableArray *deepSleepIndex      = [NSMutableArray new];
        NSMutableArray *wristOffIndex       = [NSMutableArray new];
        NSMutableArray *mediumSleepIndex    = [NSMutableArray new];
        NSMutableArray *lightSleepIndex     = [NSMutableArray new];
        NSMutableArray *sedentaryIndex      = [NSMutableArray new];
        NSMutableArray *workoutIndex        = [NSMutableArray new];
        NSMutableArray *dataSource          = [NSMutableArray new];
        
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        NSDateComponents *components    = [NSDateComponents new];
        components.week                 = week;
        components.year                 = year;
        
        StatisticalDataPointEntity *dataPoint   = [data firstObject];
        NSDateComponents *dateComponents        = [NSDateComponents new];
        dateComponents.month                    = dataPoint.header.date.month.integerValue;
        dateComponents.day                      = dataPoint.header.date.day.integerValue;
        dateComponents.year                     = dataPoint.header.date.year.integerValue + 1900;
        NSDate *date                            = [calendar dateFromComponents:dateComponents];
        dateComponents                          = [calendar components:NSWeekdayCalendarUnit fromDate:date];
        NSInteger indexAdjustment               = (dateComponents.weekday - 1) * 24 * 6;
        
        for (int weekday = dateComponents.weekday; weekday <= 7; weekday++)
        {
            components.weekday  = weekday;
            NSDate *date        = [calendar dateFromComponents:components];
            
            NSDate *yesterday               = [date dateByAddingTimeInterval:-DAY_SECONDS];
            NSArray *yesterdaySleeps        = [SleepDatabaseEntity sleepDatabaseForDate:yesterday];
            NSArray *sleeps                 = [SleepDatabaseEntity sleepDatabaseForDate:date];
             /*
            NSArray *workouts               = nil;
            
           
            if (watchModel != WatchModel_Core_C200 &&
                watchModel != WatchModel_Move_C300 &&
                watchModel != WatchModel_Zone_C410) {
                workouts = [WorkoutInfoEntity getWorkoutInfoWithDate:date];
            }
             */
            
            NSMutableArray *deepSleepIndexes    = [NSMutableArray new];
            NSMutableArray *wristOffIndexes    = [NSMutableArray new];
            NSMutableArray *mediumSleepIndexes  = [NSMutableArray new];
            NSMutableArray *lightSleepIndexes   = [NSMutableArray new];
            NSMutableArray *workoutIndexes      = [NSMutableArray new];
            NSMutableArray *sedentaryIndexes    = [NSMutableArray new];
            
            for (SleepDatabaseEntity *sleep in yesterdaySleeps) {
                NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6) + (sleep.sleepStartMin.integerValue / 10);
                NSInteger endIndex      = (sleep.sleepEndHour.integerValue * 6) + (sleep.sleepEndMin.integerValue / 10);
                
                if (startIndex >= endIndex)
                {
                    for (NSInteger a = 0; a <= endIndex; a++)
                    {
                        NSInteger index = ((weekday - 1) * 144) + a - indexAdjustment;
                        index = index > 0 ? index : 0;
                        StatisticalDataPointEntity *dataPoint = [data objectAtIndex:index];
                        
                        CGFloat value   = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
                        value           += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
                        value           = (120 * 5) - value;
                        
                        if (value >= 300) {
                            [deepSleepIndexes addObject:@(a)];
                        } else if (value >= 150) {
                            [mediumSleepIndexes addObject:@(a)];
                        } else {
                            [lightSleepIndexes addObject:@(a)];
                        }
                    }
                }
                
            }
            
            for (SleepDatabaseEntity *sleep in sleeps) {
                NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6) + (sleep.sleepStartMin.integerValue / 10);
                NSInteger endIndex      = (sleep.sleepEndHour.integerValue * 6) + (sleep.sleepEndMin.integerValue / 10);
                endIndex                = endIndex >= DAY_DATA_MAX_COUNT - 1 ? DAY_DATA_MAX_COUNT - 1 : endIndex;
                endIndex                = endIndex <= startIndex ? DAY_DATA_MAX_COUNT - 1 : endIndex;
                
                for (NSInteger a = startIndex; a <= endIndex; a++)
                {
                    NSUInteger index = ((weekday - 1) * 144) + a - indexAdjustment;
                    index = index > 0 ? index : 0;
                    if (index > data.count-1) {
                        break;
                    }
                    StatisticalDataPointEntity *dataPoint = [data objectAtIndex:index];
                    
                    CGFloat value   = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
                    value           += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
                    value           = (120 * 5) - value;
                    
                    if (value >= 300) {
                        [deepSleepIndexes addObject:@(a)];
                    } else if (value >= 150) {
                        [mediumSleepIndexes addObject:@(a)];
                    } else {
                        [lightSleepIndexes addObject:@(a)];
                    }
                    
                }
                
                /*if (startIndex < endIndex && sleep.sleepEndHour.integerValue < 23)
                {
                    for (NSInteger a = startIndex; a <= endIndex; a++)
                    {
                        NSUInteger index = ((weekday - 1) * 144) + a - indexAdjustment;
                        index = index > 0 ? index : 0;
                        StatisticalDataPointEntity *dataPoint = [data objectAtIndex:index];
                        
                        CGFloat value   = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
                        value           += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
                        
                        if (value == 0) {
                            [deepSleepIndexes addObject:[NSNumber numberWithInt:a]];
                        } else {
                            [lightSleepIndexes addObject:[NSNumber numberWithInt:a]];
                        }
                    }
                }*/
            }
            
            /*for (WorkoutInfoEntity *workout in workouts) {
                NSInteger startIndex    = (workout.stampHour.integerValue * 6) + (workout.stampMinute.integerValue / 10);
                NSInteger endIndex      = startIndex + (workout.hour.integerValue * 6) + (workout.minute.integerValue / 10);
                endIndex                = endIndex >= DAY_DATA_MAX_COUNT - 1 ? DAY_DATA_MAX_COUNT - 1 : endIndex;
                
                for (NSInteger a = startIndex; a <= endIndex; a++) {
                    NSNumber *number = [NSNumber numberWithInt:a];
                    [workoutIndexes addObject:number];
                }
            }*/
            
            NSArray *dayData = [StatisticalDataPointEntity dataPointsForDate:date];
            
            for (NSInteger a = 0; a < dayData.count; a++)
            {
                StatisticalDataPointEntity *dataPoint = [dayData objectAtIndex:a];
                
                NSNumber *number    = [NSNumber numberWithInt:a];
                CGFloat value       = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
                value               += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
                
                if (![deepSleepIndexes containsObject:number] &&
                    ![mediumSleepIndexes containsObject:number] &&
                    ![lightSleepIndexes containsObject:number] &&
                    ![workoutIndexes containsObject:number])
                {
                    if (value < (40 * 5)) {
                        [sedentaryIndexes addObject:@(a)];
                        
                        //NSLog(@"SEDENTARY INDEXES: %@", number);
                    }
                }
                if (dataPoint.wristDetection.boolValue == NO) {
                    [wristOffIndexes addObject:@(a)];
                }
            }
            
            NSUInteger startIndex           = 0;
            NSUInteger endIndex             = 0;
            SFAActigraphyBarType barType    = SFAActigraphyBarTypeActive;
            
            for (NSUInteger a = 0; a < dayData.count; a++)
            {
                NSNumber *number = [NSNumber numberWithInteger:a];
                SFAActigraphyBarType newBarType = SFAActigraphyBarTypeActive;
                
                if ([deepSleepIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeDeepSleep;
                } else if ([mediumSleepIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeMediumSleep;
                } else if ([lightSleepIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeLightSleep;
                } else if ([workoutIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeWorkout;
                } else if ([sedentaryIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeSedentary;
                }
                if ([wristOffIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeWristOff;
                }
                
                if (barType != newBarType ||
                    a == dayData.count - 1)
                {
                    if (a == 0) {
                        barType = newBarType;
                    } else {
                        CGFloat x       = (self.barWidth + self.barSpace) * (weekday - 1);
                        CGFloat yMin    = [SFAGraphTools yWithMaxY:143.0f yValue:startIndex];
                        CGFloat yMax    = [SFAGraphTools yWithMaxY:143.0f yValue:endIndex];
                        
                        NSDictionary *dictionary = @{ X_VALUE_KEY       : [NSNumber numberWithFloat:x],
                                                      Y_MIN_VALUE_KEY   : [NSNumber numberWithFloat:yMin],
                                                      Y_MAX_VALUE_KEY   : [NSNumber numberWithFloat:yMax]};
                        
                        [dataSource addObject:dictionary];
                        
                        if (barType == SFAActigraphyBarTypeDeepSleep) {
                            [deepSleepIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        } else if (barType == SFAActigraphyBarTypeMediumSleep) {
                            [mediumSleepIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        } else if (barType == SFAActigraphyBarTypeLightSleep) {
                            [lightSleepIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        } else if (barType ==SFAActigraphyBarTypeWorkout) {
                            [workoutIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        } else if (barType ==SFAActigraphyBarTypeSedentary) {
                            [sedentaryIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        }
                        
                        if (barType == SFAActigraphyBarTypeWristOff) {
                            [wristOffIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        }
                        
                        
                        startIndex = endIndex;
                        barType = newBarType;
                    }
                }
                
                endIndex = a;
            }
        }
        
        self.dataSource         = [dataSource copy];
        self.deepSleepIndexes   = [deepSleepIndex copy];
        self.mediumSleepIndexes = [mediumSleepIndex copy];
        self.lightSleepIndexes  = [lightSleepIndex copy];
        self.workoutIndexes     = [workoutIndex copy];
        self.sedentaryIndexes   = [sedentaryIndex copy];
        self.wristOffIndexes    = [wristOffIndex copy];
    }
    else
    {
        self.dataSource         = nil;
        self.lightSleepIndexes  = nil;
        self.mediumSleepIndexes = nil;
        self.deepSleepIndexes   = nil;
        self.workoutIndexes     = nil;
        self.sedentaryIndexes   = nil;
    }
    
    [self.barPlot reloadData];
    
    [self adjustGraphViewWidth];
    [self adjustGraphRange:SFADateRangeWeek];
    [self adjustBarWidth];
    //[self adjustTickLocation];
}

- (void)getDataForMonth:(NSInteger)month ofYear:(NSInteger)year
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.month                = month;
    components.year                 = year;
    NSDate *date                    = [calendar dateFromComponents:components];
    NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSArray *data                   = [StatisticalDataPointEntity dataPointsForMonth:month ofYear:year];
    
    StatisticalDataPointEntity *dataPoint   = [data firstObject];
    
    NSInteger indexAdjustment               = (dataPoint.header.date.day.integerValue - 1) * 24 * 6;
    
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    WatchModel watchModel           = [[userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
    
    if (data.count > 0)
    {
        NSMutableArray *deepSleepIndex      = [NSMutableArray new];
        NSMutableArray *wristOffIndex       = [NSMutableArray new];
        NSMutableArray *mediumSleepIndex    = [NSMutableArray new];
        NSMutableArray *lightSleepIndex     = [NSMutableArray new];
        NSMutableArray *sedentaryIndex      = [NSMutableArray new];
        NSMutableArray *workoutIndex        = [NSMutableArray new];
        NSMutableArray *dataSource          = [NSMutableArray new];
        
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        NSDateComponents *components    = [NSDateComponents new];
        components.month                = month;
        components.year                 = year;
        
        for (int day = dataPoint.header.date.day.integerValue; day <= range.length; day++)
        {
            components.day  = day;
            NSDate *date    = [calendar dateFromComponents:components];
            
            NSDate *yesterday           = [date dateByAddingTimeInterval:-DAY_SECONDS];
            NSArray *yesterdaySleeps    = [SleepDatabaseEntity sleepDatabaseForDate:yesterday];
            NSArray *sleeps             = [SleepDatabaseEntity sleepDatabaseForDate:date];
            NSArray *workouts               = nil;
            
            if (watchModel != WatchModel_Core_C200 &&
                watchModel != WatchModel_Move_C300 &&
                watchModel != WatchModel_Move_C300_Android &&
                watchModel != WatchModel_Zone_C410 &&
                watchModel != WatchModel_R420) {
                workouts = [WorkoutInfoEntity getWorkoutInfoWithDate:date];
            }
            
            NSMutableArray *deepSleepIndexes    = [NSMutableArray new];
            NSMutableArray *wristOffIndexes     = [NSMutableArray new];
            NSMutableArray *mediumSleepIndexes  = [NSMutableArray new];
            NSMutableArray *lightSleepIndexes   = [NSMutableArray new];
            NSMutableArray *workoutIndexes      = [NSMutableArray new];
            NSMutableArray *sedentaryIndexes    = [NSMutableArray new];
            
            for (SleepDatabaseEntity *sleep in yesterdaySleeps) {
                NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6) + (sleep.sleepStartMin.integerValue / 10);
                NSInteger endIndex      = (sleep.sleepEndHour.integerValue * 6) + (sleep.sleepEndMin.integerValue / 10);
                
                if (startIndex >= endIndex)
                {
                    for (NSInteger a = 0; a <= endIndex; a++)
                    {
                        NSUInteger index = ((day - 1) * 144) + a - indexAdjustment;
                        index = index > 0 ? index : 0;
                        if (index > data.count-1) {
                            break;
                        }
                        StatisticalDataPointEntity *dataPoint = [data objectAtIndex:index];
                        
                        CGFloat value   = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
                        value           += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
                        value           = (120 * 5) - value;
                        
                        if (value >= 300) {
                            [deepSleepIndexes addObject:@(a)];
                        } else if (value >= 150) {
                            [mediumSleepIndexes addObject:@(a)];
                        } else {
                            [lightSleepIndexes addObject:@(a)];
                        }
                    }
                }
                
            }
            
            for (SleepDatabaseEntity *sleep in sleeps) {
                NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6) + (sleep.sleepStartMin.integerValue / 10);
                NSInteger endIndex      = (sleep.sleepEndHour.integerValue * 6) + (sleep.sleepEndMin.integerValue / 10);
                endIndex                = endIndex >= DAY_DATA_MAX_COUNT - 1 ? DAY_DATA_MAX_COUNT - 1 : endIndex;
                endIndex                = endIndex <= startIndex ? DAY_DATA_MAX_COUNT - 1 : endIndex;
                
                for (NSInteger a = startIndex; a <= endIndex; a++)
                {
                    NSUInteger index = ((day - 1) * 144) + a - indexAdjustment;
                    index = index > 0 ? index : 0;
                    if (index <= endIndex) {
                        StatisticalDataPointEntity *dataPoint = [data objectAtIndex:index];
                        
                        CGFloat value   = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
                        value           += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
                        value           = (120 * 5) - value;
                        
                        if (value >= 300) {
                            [deepSleepIndexes addObject:@(a)];
                        } else if (value >= 150) {
                            [mediumSleepIndexes addObject:@(a)];
                        } else {
                            [lightSleepIndexes addObject:@(a)];
                        }
                    }
                }
                
                /*if (startIndex < endIndex && sleep.sleepEndHour.integerValue < 23)
                {
                    for (NSInteger a = startIndex; a <= endIndex; a++)
                    {
                        NSUInteger index = ((day - 1) * 144) + a - indexAdjustment;
                        index = index > 0 ? index : 0;
                        StatisticalDataPointEntity *dataPoint = [data objectAtIndex:index];
                        
                        CGFloat value   = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
                        value           += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
                        
                        if (value == 0) {
                            [deepSleepIndexes addObject:[NSNumber numberWithInt:a]];
                        } else {
                            [lightSleepIndexes addObject:[NSNumber numberWithInt:a]];
                        }
                    }
                }*/
            }
            
            for (WorkoutInfoEntity *workout in workouts) {
                NSInteger startIndex    = (workout.stampHour.integerValue * 6) + (workout.stampMinute.integerValue / 10);
                NSInteger endIndex      = startIndex + (workout.hour.integerValue * 6) + (workout.minute.integerValue / 10);
                endIndex                = endIndex >= DAY_DATA_MAX_COUNT - 1 ? DAY_DATA_MAX_COUNT - 1 : endIndex;
                
                for (NSInteger a = startIndex; a <= endIndex; a++) {
                    NSNumber *number = [NSNumber numberWithInt:a];
                    [workoutIndexes addObject:number];
                }
            }
            
            NSArray *dayData = [StatisticalDataPointEntity dataPointsForDate:date];
            
            for (NSInteger a = 0; a < dayData.count; a++)
            {
                StatisticalDataPointEntity *dataPoint = [dayData objectAtIndex:a];
                
                NSNumber *number    = [NSNumber numberWithInt:a];
                CGFloat value       = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
                value               += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
                
                if (![deepSleepIndexes containsObject:number] &&
                    ![mediumSleepIndexes containsObject:number] &&
                    ![lightSleepIndexes containsObject:number] &&
                    ![workoutIndexes containsObject:number])
                {
                    if (value < (40 * 5)) {
                        [sedentaryIndexes addObject:@(a)];
                    }
                }
                if (dataPoint.wristDetection.boolValue == NO) {
                    [wristOffIndexes addObject:@(a)];
                }
            }
            
            NSUInteger startIndex           = 0;
            NSUInteger endIndex             = 0;
            SFAActigraphyBarType barType    = SFAActigraphyBarTypeActive;
            
            for (NSUInteger a = 0; a < dayData.count; a++)
            {
                NSNumber *number = [NSNumber numberWithInteger:a];
                SFAActigraphyBarType newBarType = SFAActigraphyBarTypeActive;
                
                if ([deepSleepIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeDeepSleep;
                } else if ([mediumSleepIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeMediumSleep;
                } else if ([lightSleepIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeLightSleep;
                } else if ([workoutIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeWorkout;
                } else if ([sedentaryIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeSedentary;
                }
                
                if ([wristOffIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeWristOff;
                }
                
                DDLogInfo(@"barType ?= newBarType\n %i ?= %i", barType, newBarType);
                if (barType != newBarType ||
                    a == dayData.count - 1)
                {
                    if (a == 0) {
                        barType = newBarType;
                    } else {
                        CGFloat x       = (self.barWidth + self.barSpace) * (day - 1);
                        CGFloat yMin    = [SFAGraphTools yWithMaxY:143.0f yValue:startIndex];
                        CGFloat yMax    = [SFAGraphTools yWithMaxY:143.0f yValue:endIndex];
                        
                        NSDictionary *dictionary = @{ X_VALUE_KEY       : [NSNumber numberWithFloat:x],
                                                      Y_MIN_VALUE_KEY   : [NSNumber numberWithFloat:yMin],
                                                      Y_MAX_VALUE_KEY   : [NSNumber numberWithFloat:yMax]};
                        
                        [dataSource addObject:dictionary];
                        
                        if (barType == SFAActigraphyBarTypeDeepSleep) {
                            [deepSleepIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        } else if (barType == SFAActigraphyBarTypeMediumSleep) {
                            [mediumSleepIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        } else if (barType == SFAActigraphyBarTypeLightSleep) {
                            [lightSleepIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        } else if (barType ==SFAActigraphyBarTypeWorkout) {
                            [workoutIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        } else if (barType ==SFAActigraphyBarTypeSedentary) {
                            [sedentaryIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        }
                        
                        if (barType == SFAActigraphyBarTypeWristOff) {
                            [wristOffIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        }
                        
                        startIndex = endIndex;
                        barType = newBarType;
                    }
                }
                
                endIndex = a;
            }
        }
        
        self.dataSource         = [dataSource copy];
        self.deepSleepIndexes   = [deepSleepIndex copy];
        self.mediumSleepIndexes = [mediumSleepIndex copy];
        self.lightSleepIndexes  = [lightSleepIndex copy];
        self.workoutIndexes     = [workoutIndex copy];
        self.sedentaryIndexes   = [sedentaryIndex copy];
        self.wristOffIndexes    = [wristOffIndex copy];
        DDLogInfo(@"year dataSource = %@", dataSource);
        DDLogInfo(@"year sedentaryIndexes = %@", self.sedentaryIndexes);
    }
    else
    {
        self.dataSource         = nil;
        self.lightSleepIndexes  = nil;
        self.mediumSleepIndexes = nil;
        self.deepSleepIndexes   = nil;
        self.workoutIndexes     = nil;
        self.sedentaryIndexes   = nil;
        self.wristOffIndexes    = nil;
    }
    
    [self.barPlot reloadData];
    
    [self adjustGraphViewWidth];
    [self adjustGraphRange:SFADateRangeWeek];
    [self adjustBarWidth];
    //[self adjustTickLocation];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)getDataForYear:(NSInteger)year
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    //NSDateComponents *components    = [NSDateComponents new];
    //components.year                 = year;
    //NSDate *date                    = [calendar dateFromComponents:components];
    //NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:date];
    NSRange range                   = NSMakeRange(0, 365);
    NSArray *data                   = [StatisticalDataPointEntity dataPointsForYear:year];
    
    StatisticalDataPointEntity *dataPoint   = [data firstObject];
    NSDateComponents *dateComponents        = [NSDateComponents new];
    dateComponents.month                    = dataPoint.header.date.month.integerValue;
    dateComponents.day                      = dataPoint.header.date.day.integerValue;
    dateComponents.year                     = dataPoint.header.date.year.integerValue + 1900;
    NSDate *newDate                         = [calendar dateFromComponents:dateComponents];
    dateComponents.month                    = 1;
    dateComponents.day                      = 1;
    dateComponents.year                     = dataPoint.header.date.year.integerValue + 1900;
    NSDate *firstDate                       = [calendar dateFromComponents:dateComponents];
    dateComponents                          = [calendar components:NSDayCalendarUnit fromDate:firstDate toDate:newDate options:kNilOptions];
    NSInteger indexAdjustment               = dateComponents.day * 24 * 6;
    
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    WatchModel watchModel           = [[userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
    
    if (data.count > 0)
    {
        NSMutableArray *deepSleepIndex      = [NSMutableArray new];
        NSMutableArray *wristOffIndex       = [NSMutableArray new];
        NSMutableArray *mediumSleepIndex    = [NSMutableArray new];
        NSMutableArray *lightSleepIndex     = [NSMutableArray new];
        NSMutableArray *sedentaryIndex      = [NSMutableArray new];
        NSMutableArray *workoutIndex        = [NSMutableArray new];
        NSMutableArray *dataSource          = [NSMutableArray new];
        
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        NSDateComponents *components    = [NSDateComponents new];
        components.year                 = year;
        
        for (int day = dateComponents.day + 1; day <= range.length; day++)
        {
            components.day  = day;
            NSDate *date    = [calendar dateFromComponents:components];
            
            NSDate *yesterday           = [date dateByAddingTimeInterval:-DAY_SECONDS];
            NSArray *yesterdaySleeps    = [SleepDatabaseEntity sleepDatabaseForDate:yesterday];
            NSArray *sleeps             = [SleepDatabaseEntity sleepDatabaseForDate:date];
            NSArray *workouts               = nil;
            
            if (watchModel != WatchModel_Core_C200 &&
                watchModel != WatchModel_Move_C300 &&
                watchModel != WatchModel_Move_C300_Android &&
                watchModel != WatchModel_Zone_C410 &&
                watchModel != WatchModel_R420) {
                workouts = [WorkoutInfoEntity getWorkoutInfoWithDate:date];
            }
            
            NSMutableArray *deepSleepIndexes    = [NSMutableArray new];
            NSMutableArray *wristOffIndexes     = [NSMutableArray new];
            NSMutableArray *mediumSleepIndexes  = [NSMutableArray new];
            NSMutableArray *lightSleepIndexes   = [NSMutableArray new];
            NSMutableArray *workoutIndexes      = [NSMutableArray new];
            NSMutableArray *sedentaryIndexes    = [NSMutableArray new];
            
            for (SleepDatabaseEntity *sleep in yesterdaySleeps) {
                NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6) + (sleep.sleepStartMin.integerValue / 10);
                NSInteger endIndex      = (sleep.sleepEndHour.integerValue * 6) + (sleep.sleepEndMin.integerValue / 10);
                
                if (startIndex >= endIndex)
                {
                    for (NSInteger a = 0; a <= endIndex; a++)
                    {
                        NSUInteger index = ((day - 1) * 144) + a - indexAdjustment;
                        index = index > 0 ? index : 0;
                        if (index > data.count) {
                            break;
                        }
                        StatisticalDataPointEntity *dataPoint = [data objectAtIndex:index];
                        
                        CGFloat value   = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
                        value           += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
                        value           = (120 * 5) - value;
                        
                        if (value >= 300) {
                            [deepSleepIndexes addObject:@(a)];
                        } else {
                            [lightSleepIndexes addObject:@(a)];
                        }
                    }
                }
                
            }
            
            for (SleepDatabaseEntity *sleep in sleeps) {
                NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6) + (sleep.sleepStartMin.integerValue / 10);
                NSInteger endIndex      = (sleep.sleepEndHour.integerValue * 6) + (sleep.sleepEndMin.integerValue / 10);
                endIndex                = endIndex >= DAY_DATA_MAX_COUNT - 1 ? DAY_DATA_MAX_COUNT - 1 : endIndex;
                endIndex                = endIndex <= startIndex ? DAY_DATA_MAX_COUNT - 1 : endIndex;
                
                for (NSInteger a = startIndex; a <= endIndex; a++)
                {
                    NSUInteger index = ((day - 1) * 144) + a - indexAdjustment;
                    index = index > 0 ? index : 0;
                    if (index > data.count-1) {
                        break;
                    }
                    StatisticalDataPointEntity *dataPoint = [data objectAtIndex:index];
                    
                    CGFloat value   = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
                    value           += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
                    value           = (120 * 5) - value;
                    
                    if (value >= 300) {
                        [deepSleepIndexes addObject:@(a)];
                    } else {
                        [lightSleepIndexes addObject:@(a)];
                    }
                }
                
                /*if (startIndex < endIndex && sleep.sleepEndHour.integerValue < 23)
                {
                    for (NSInteger a = startIndex; a <= endIndex; a++)
                    {
                        NSUInteger index = ((day - 1) * 144) + a - indexAdjustment;
                        index = index > 0 ? index : 0;
                        StatisticalDataPointEntity *dataPoint = [data objectAtIndex:index];
                        
                        CGFloat value   = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
                        value           += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
                        
                        if (value == 0) {
                            [deepSleepIndexes addObject:[NSNumber numberWithInt:a]];
                        } else {
                            [lightSleepIndexes addObject:[NSNumber numberWithInt:a]];
                        }
                    }
                }*/
            }
            
            for (WorkoutInfoEntity *workout in workouts) {
                NSInteger startIndex    = (workout.stampHour.integerValue * 6) + (workout.stampMinute.integerValue / 10);
                NSInteger endIndex      = startIndex + (workout.hour.integerValue * 6) + (workout.minute.integerValue / 10);
                endIndex                = endIndex >= DAY_DATA_MAX_COUNT - 1 ? DAY_DATA_MAX_COUNT - 1 : endIndex;
                
                for (NSInteger a = startIndex; a <= endIndex; a++) {
                    NSNumber *number = [NSNumber numberWithInt:a];
                    [workoutIndexes addObject:number];
                }
            }
            
            NSArray *dayData = [StatisticalDataPointEntity dataPointsForDate:date];
            
            for (NSInteger a = 0; a < dayData.count; a++)
            {
                StatisticalDataPointEntity *dataPoint = [dayData objectAtIndex:a];
                
                NSNumber *number    = [NSNumber numberWithInt:a];
                CGFloat value       = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
                value               += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
                
                if (![deepSleepIndexes containsObject:number] &&
                    ![mediumSleepIndexes containsObject:number] &&
                    ![lightSleepIndexes containsObject:number] &&
                    ![workoutIndexes containsObject:number])
                {
                    if (value < (40 * 5)) {
                        [sedentaryIndexes addObject:@(a)];
                    }
                }
                if (dataPoint.wristDetection.boolValue == NO) {
                    [wristOffIndexes addObject:@(a)];
                }
            }
            
            NSUInteger startIndex           = 0;
            NSUInteger endIndex             = 0;
            SFAActigraphyBarType barType    = SFAActigraphyBarTypeActive;
            
            for (NSUInteger a = 0; a < dayData.count; a++)
            {
                NSNumber *number = [NSNumber numberWithInteger:a];
                SFAActigraphyBarType newBarType = SFAActigraphyBarTypeActive;
                
                if ([deepSleepIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeDeepSleep;
                } else if ([mediumSleepIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeMediumSleep;
                } else if ([lightSleepIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeLightSleep;
                } else if ([workoutIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeWorkout;
                } else if ([sedentaryIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeSedentary;
                }
                if ([wristOffIndexes containsObject:number]) {
                    newBarType = SFAActigraphyBarTypeWristOff;
                }
                
                if (barType != newBarType ||
                    a == dayData.count - 1)
                {
                    if (a == 0) {
                        barType = newBarType;
                    } else {
                        CGFloat x       = (self.barWidth + self.barSpace) * day;
                        CGFloat yMin    = [SFAGraphTools yWithMaxY:143.0f yValue:startIndex];
                        CGFloat yMax    = [SFAGraphTools yWithMaxY:143.0f yValue:endIndex];
                        
                        NSDictionary *dictionary = @{ X_VALUE_KEY       : [NSNumber numberWithFloat:x],
                                                      Y_MIN_VALUE_KEY   : [NSNumber numberWithFloat:yMin],
                                                      Y_MAX_VALUE_KEY   : [NSNumber numberWithFloat:yMax]};
                        
                        [dataSource addObject:dictionary];
                        
                        if (barType == SFAActigraphyBarTypeDeepSleep) {
                            [deepSleepIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        } else if (barType == SFAActigraphyBarTypeMediumSleep) {
                            [mediumSleepIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        } else if (barType == SFAActigraphyBarTypeLightSleep) {
                            [lightSleepIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        } else if (barType ==SFAActigraphyBarTypeWorkout) {
                            [workoutIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        } else if (barType ==SFAActigraphyBarTypeSedentary) {
                            [sedentaryIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        }
                        
                        if (barType == SFAActigraphyBarTypeWristOff) {
                            [wristOffIndex addObject:[NSNumber numberWithInt:dataSource.count - 1]];
                        }
                        
                        startIndex = endIndex;
                        barType = newBarType;

                    }
                }
                
                endIndex = a;
            }
        }
        
        self.dataSource         = [dataSource copy];
        self.deepSleepIndexes   = [deepSleepIndex copy];
        self.mediumSleepIndexes = [mediumSleepIndex copy];
        self.lightSleepIndexes  = [lightSleepIndex copy];
        self.workoutIndexes     = [workoutIndex copy];
        self.sedentaryIndexes   = [sedentaryIndex copy];
        self.wristOffIndexes    = [wristOffIndex copy];
    }
    else
    {
        self.dataSource         = nil;
        self.lightSleepIndexes  = nil;
        self.mediumSleepIndexes = nil;
        self.deepSleepIndexes   = nil;
        self.workoutIndexes     = nil;
        self.sedentaryIndexes   = nil;
        self.wristOffIndexes    = nil;
    }
    
    [self.barPlot reloadData];
    [self adjustGraphViewWidth];
    [self adjustGraphRange:SFADateRangeWeek];
    [self adjustBarWidth];
    //[self adjustTickLocation];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)adjustBarPlotWidth
{
    self.barPlot.barWidth = CPTDecimalFromCGFloat(self.barWidth);
    self.barPlot.barOffset = CPTDecimalFromCGFloat((self.barSpace * 0.5f) + (self.barWidth * 0.5f));
}

- (void)adjustGraphViewWidth
{
    self.graphViewWidthConstraint.constant  = (_isPortrait) ? self.view.frame.size.width : self.graphViewWidth;
    self.plotSpace.xRange                   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f)
                                                                           length:CPTDecimalFromFloat(self.graphViewWidth)];
}

- (void)adjustGraphRange:(SFADateRange)dateRange
{
    if(dateRange == SFADateRangeDay) {
        self.plotSpace.yRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-10.0f) length:CPTDecimalFromFloat(Y_MAX_RANGE * 2)];
    } else {
        self.plotSpace.yRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(Y_MAX_RANGE)];
    }
}

#pragma mark - Public Methods

- (void)setContentsWithDate:(NSDate *)date
{
    [self getDataForDate:date];
    if (_isPortrait)
        [self.graph hourPortraitLabelsForActigraphyWithBarWidth:self.barWidth barSpace:self.barSpace];
    else
        [self.graph hourLabelsForActigraphyWithBarWidth:self.barWidth barSpace:self.barSpace];
}

- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year
{
    self.week = week;
    self.year = year;
    self.month = (int) self.week/4;
    
    [self _removeScrollViewDayBars];
    [self getDataForWeek:week ofYear:year];
    [self.graph dayLabelsForActigraphyWithWeek:week ofYear:year barWidth:self.barWidth barSpace:self.barSpace];
}

- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year
{
    self.month = month;
    self.year = year;
    
    [self _removeScrollViewDayBars];
    [self getDataForMonth:month ofYear:year];
    [self.graph dayLabelsWithMonth:month ofYear:year barWidth:self.barWidth barSpace:self.barSpace];
}

- (void)setContentsWithYear:(NSInteger)year
{
    self.year = year;
    
    [self _removeScrollViewDayBars];
    [self getDataForYear:year];
    [self.graph dayLabelsForActigraphyWithYear:year BarWidth:self.barWidth barSpace:self.barSpace];
}

#pragma mark - Setter methods

- (void)setWorkoutCount:(NSInteger)workoutCount
{
    if (_workoutCount != workoutCount)
    {
        _workoutCount = workoutCount;
        if ([self.delegate conformsToProtocol:@protocol(SFAActigraphyGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(didChangeWorkoutCount:)])
            [self.delegate didChangeWorkoutCount:@(_workoutCount)];
    }
}

- (void)setActiveTimeCount:(NSInteger)activeTimeCount
{
    if (_activeTimeCount != activeTimeCount && activeTimeCount >= 0)
    {
        _activeTimeCount = activeTimeCount;
        if ([self.delegate conformsToProtocol:@protocol(SFAActigraphyGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(didChangeActiveCount:)])
            [self.delegate didChangeActiveCount:@(_activeTimeCount)];
    }
}

- (void)setLightSleepCount:(NSInteger)lightSleepCount
{
    if (_lightSleepCount != lightSleepCount)
    {
        _lightSleepCount = lightSleepCount;
        if ([self.delegate conformsToProtocol:@protocol(SFAActigraphyGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(didChangeLightSleepCount:)])
            [self.delegate didChangeLightSleepCount:@(_lightSleepCount)];
    }
}

- (void)setDeepSleepCount:(NSInteger)deepSleepCount
{
    if (_deepSleepCount != deepSleepCount)
    {
        _deepSleepCount = deepSleepCount;
        if ([self.delegate conformsToProtocol:@protocol(SFAActigraphyGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(didChangeDeepSleepCount:)])
            [self.delegate didChangeDeepSleepCount:@(_deepSleepCount)];
    }
}

- (void)setTotalActiveTime:(NSString *)totalActiveTime
{
    if (![_totalActiveTime isEqualToString:totalActiveTime])
    {
        _totalActiveTime = totalActiveTime;
        if ([self.delegate conformsToProtocol:@protocol(SFAActigraphyGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(didChangeTotalActiveTime:)])
            [self.delegate didChangeTotalActiveTime:_totalActiveTime];
    }
}

- (void)setTotalSleepTime:(NSString *)totalSleepTime
{
    if (![_totalSleepTime isEqualToString:totalSleepTime])
    {
        _totalSleepTime = totalSleepTime;
        if ([self.delegate conformsToProtocol:@protocol(SFAActigraphyGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(didChangeTotalSleepTime:)])
            [self.delegate didChangeTotalSleepTime:_totalSleepTime];
    }
}

- (void)setTotalSedentaryTime:(NSString *)totalSedentaryTime
{
    if (![_totalSedentaryTime isEqualToString:totalSedentaryTime])
    {
        _totalSedentaryTime = totalSedentaryTime;
        if ([self.delegate conformsToProtocol:@protocol(SFAActigraphyGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(didChangeTotalSedentaryTime:)])
            [self.delegate didChangeTotalSedentaryTime:_totalSedentaryTime];
    }
}

- (void)setTotalActiveTimeHour:(NSInteger)totalActiveTimeHour
{
    if (_totalActiveTimeHour != totalActiveTimeHour){
        _totalActiveTimeHour = totalActiveTimeHour;
    
        if ([self.delegate conformsToProtocol:@protocol(SFAActigraphyGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(didChangeTotalActiveTimeHour:)])
            [self.delegate didChangeTotalActiveTimeHour:totalActiveTimeHour];
    }
}

- (void)setTotalActiveTimeMinute:(NSInteger)totalActiveTimeMinute
{
    if (_totalActiveTimeMinute != totalActiveTimeMinute){
        _totalActiveTimeMinute = totalActiveTimeMinute;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAActigraphyGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(didChangeTotalActiveTimeMinute:)])
            [self.delegate didChangeTotalActiveTimeMinute:totalActiveTimeMinute];
    }
}

- (void)setCurrentDay:(NSString *)currentDay
{
    if (![_currentDay isEqualToString:currentDay]) {
        _currentDay = currentDay;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAActigraphyGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(didChangeCurrentDay:)])
            [self.delegate didChangeCurrentDay:currentDay];
    }
}

- (NSInteger)getTotalSleepTimeForDate:(NSDate *)date{
    NSDate *yesterday               = [date dateByAddingTimeInterval:-DAY_SECONDS];
    NSArray *yesterdaySleeps        = [SleepDatabaseEntity sleepDatabaseForDate:yesterday];
    NSArray *sleeps                 = [SleepDatabaseEntity sleepDatabaseForDate:date];
    NSMutableArray *sleepLogs       = [NSMutableArray new];
    NSMutableArray *sleepLogsGraph  = [[NSMutableArray alloc] init];
    NSInteger totalSleepDuration    = 0;
    
    //check and stop processing if there are no statistical data headers for that date
    NSArray *data                   = [StatisticalDataHeaderEntity statisticalDataHeaderEntitiesForDate:date];
    NSArray *yesterdayData          = [StatisticalDataHeaderEntity statisticalDataHeaderEntitiesForDate:yesterday];
    
    if (yesterdayData && yesterdayData.count > 0){
        for (SleepDatabaseEntity *sleep in yesterdaySleeps)
        {
            NSInteger sleepStartMinutes = (sleep.sleepStartHour.integerValue * 60) + sleep.sleepStartMin.integerValue;
            NSInteger sleepEndMinutes   =  sleep.adjustedSleepEndMinutes;
            //NSInteger sleepEndMinutes   = (sleep.sleepEndHour.integerValue * 60) + sleep.sleepEndMin.integerValue;
            
            if ((sleepStartMinutes >= sleepEndMinutes) ||
                (sleep.sleepStartHour.integerValue >= SLEEP_MAX_HOUR || sleep.sleepEndHour.integerValue >= SLEEP_MAX_HOUR)){
                totalSleepDuration += sleep.sleepDuration.integerValue;
                [sleepLogs addObject:sleep];
                [sleepLogsGraph addObject:sleep];
                continue;
            }
        }
    }
    
    if (data && data.count > 0){
        for (SleepDatabaseEntity *sleep in sleeps)
        {
            NSInteger sleepStartMinutes = (sleep.sleepStartHour.integerValue * 60) + sleep.sleepStartMin.integerValue;
            NSInteger sleepEndMinutes   =  sleep.adjustedSleepEndMinutes;
            //NSInteger sleepEndMinutes   = (sleep.sleepEndHour.integerValue * 60) + sleep.sleepEndMin.integerValue;
            
            if ((sleepStartMinutes < sleepEndMinutes) &&
                (sleep.sleepStartHour.integerValue < SLEEP_MAX_HOUR && sleep.sleepEndHour.integerValue < SLEEP_MAX_HOUR)) {
                totalSleepDuration += sleep.sleepDuration.integerValue;
                [sleepLogsGraph addObject:sleep];
                [sleepLogs addObject:sleep];
            }
        }
    }
    /*
    StatisticalDataHeaderEntity *dataHeader = [data firstObject];
    if (dataHeader){
        totalSleepDuration = [[dataHeader totalSleep] integerValue];
    }
     */
    return totalSleepDuration;
}

@end
