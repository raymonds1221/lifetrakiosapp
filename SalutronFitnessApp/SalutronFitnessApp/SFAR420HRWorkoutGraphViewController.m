//
//  SFAR420HRWorkoutGraphViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 11/11/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//


#import "SFAR420HRWorkoutGraphViewController.h"

#import "SFAGraphView.h"
#import "SFAGraph.h"
#import "SFAGraphTools.h"
#import "SFAXYPlotSpace.h"
#import "SFALinePlot.h"
//#import "SFALinePlot+Type.h"
#import "CPTGraph+Label.h"

#import "UIViewController+Helper.h"
#import "SFAGraphView.h"

#import "StatisticalDataHeaderEntity.h"
#import "StatisticalDataPointEntity.h"
#import "StatisticalDataPointEntity+Data.h"
#import "DateEntity.h"
#import "TimeEntity.h"
#import "WorkoutHeaderEntity.h"
#import "WorkoutHeartRateDataEntity.h"

#import "WorkoutStopDatabaseEntity.h"

#import "TimeDate+Data.h"

#define Y_VALUE_KEY                 @"yValue"
#define X_VALUE_KEY                 @"xValue"
#define SLEEP_LOGS_BAR_COLOR_KEY    @"sleepLogsBarColor"
#define SLEEP_LOGS_INDEX_KEY        @"sleepLogsIndex"
#define SLEEP_LOGS_BAR_WIDTH        DAY_DATA_BAR_WIDTH / 2

#define DAY_DATA_MAX_COUNT_WORKOUT  86400
#define STARTPOINT_LANDSCAPE        0

#define SLEEP_LOGS_START_INDEX      6 * 15

//#define GRAPH_VIEW_PADDING          155.0f
#define GRAPH_VIEW_PADDING          30.0f
#define GRAPH_VIEW_WIDTH            320.0f

#define WORKOUT_STOP                -1
#define NO_TIME_LABEL               -1


@interface SFAR420HRWorkoutGraphViewController ()<SFALinePlotDelegate,UIScrollViewDelegate, SFAGraphViewDelegate>


//@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *viewLeftGraphSpace;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *viewRightGraphSpace;

// Graph
@property (strong, nonatomic) SFAGraph          *graph;
@property (strong, nonatomic) SFAXYPlotSpace    *plotSpace;
@property (strong, nonatomic) SFALinePlot        *caloriesPlot;
@property (strong, nonatomic) SFALinePlot        *barPlot;


// Data
@property (strong, nonatomic) NSArray *calories;
@property (strong, nonatomic) NSArray *calorieDataPoint;
// Data
@property (strong, nonatomic) NSMutableArray *workouts;

@property (assign, nonatomic) NSUInteger workoutIndex;

@property (readwrite, nonatomic) NSInteger totalCalories;
@property (readwrite, nonatomic) NSInteger averageHeartRate;

@property (strong, nonatomic) NSArray *workoutDataPointsIndexArray;


// Ranges
@property (strong, nonatomic) NSNumber *caloriesMaxY;

// Date
@property (readwrite, nonatomic) NSInteger month;
@property (readwrite, nonatomic) NSInteger year;
@property (strong, nonatomic) NSDate *date;

//Getters
@property (readwrite, nonatomic) CGFloat graphViewWidth;

@property (readwrite, nonatomic) NSInteger startPoint;
@property (readwrite, nonatomic) NSInteger endPoint;

@property (readwrite, nonatomic) NSInteger selectedIndex;

@property (strong, nonatomic) NSDictionary *graphLabels;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewHeight;

@property (nonatomic) BOOL isFirstLoad;
@property (nonatomic) BOOL isScrolling;

@end

@implementation SFAR420HRWorkoutGraphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isFirstLoad = YES;
    self.isScrolling = NO;
    
    [self initializeObjects];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.isLandscape = (toInterfaceOrientation != UIInterfaceOrientationPortrait);
    self.scrollView.scrollEnabled = self.isLandscape;
    self.loadingView.hidden = NO;
    
    
    self.calories = nil;
    [self.barPlot reloadData];
    
    
    [self adjustGraphView];
    self.isScrolling = NO;
}
/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.loadingView.hidden = NO;
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self setContentsWithDate:self.date workoutIndex:0];//getDataForDate:self.date];
    });
    
}
*/

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (self.isIOS8AndAbove && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self adjustGraphView];
    }
    else{
        if (!self.isScrolling || self.isFirstLoad) {
            [self adjustGraphView];
            self.isScrolling = NO;
        }
        else if (self.isScrolling && !self.isLandscape) {
            [self adjustGraphView];
            self.isScrolling = NO;
        }
    }
}

#pragma mark - private methods

- (SFALinePlot *)linePlotWithLineColor:(UIColor *)barColor
{
    SFALinePlot *linePlot     = [SFALinePlot linePlot];
    linePlot.dataDelegate    = self;
    linePlot.anchorPoint     = CGPointZero;
    
    CPTMutableLineStyle *lineStyle = [linePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 2.0;
    lineStyle.lineColor = [CPTColor colorWithCGColor:barColor.CGColor];
    linePlot.dataLineStyle   = lineStyle;
    
    //    self.barPlot.dataSource     = self;
    //    self.barPlot.barWidth       = CPTDecimalFromCGFloat(self.barWidth);
    //    self.barPlot.barOffset      = CPTDecimalFromCGFloat((self.barWidth + self.barSpace) / 2);
    
    
    return linePlot;
}


- (void)initializeObjects
{
    
    // Scroll View
    self.scrollView.delegate = self;
    self.graphView.delegate = self;
    
    // Ranges
    self.caloriesMaxY   = [NSNumber numberWithFloat:240.0f];
    
    // Graph
    self.graph                                  = [SFAGraph graphWithGraphView:self.graphView];
    self.graph.paddingLeft                      = 20.0f;
    self.graph.paddingRight                     = 20.0f;
   // if (self.isIOS8AndAbove && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        self.graph.paddingBottom                    = 0.0f;
   // }
   // else{
    //    self.graph.paddingBottom                    = -50.0f;
    //}
    self.graph.paddingTop                       = 0.0f;
    self.graph.plotAreaFrame.masksToBorder      = NO;
    self.graphView.hostedGraph                  = self.graph;
    self.visiblePlots                           = [NSMutableArray new];
    
    self.graph.axisSet = nil;
    /*
    CPTXYAxisSet *axisSet                       = (CPTXYAxisSet *) self.graph.axisSet;
    CPTAxis *x = axisSet.xAxis;
    
    CPTAxis *y = axisSet.yAxis;
    
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    */
    /*
    // Axis Line Style
    CPTXYAxisSet *axisSet                       = (CPTXYAxisSet *) self.graph.axisSet;
    CPTMutableLineStyle *lineStyle              = axisSet.yAxis.axisLineStyle.mutableCopy;
    lineStyle.lineColor                         = [CPTColor clearColor];
    axisSet.yAxis.axisLineStyle                 = lineStyle.copy;
    axisSet.xAxis.hidden                        = YES;
    axisSet.yAxis.hidden                        = YES;
    axisSet.xAxis.labelTextStyle                = nil;
    
    // Axis Text Style
    CPTMutableTextStyle *textStyle  = axisSet.yAxis.labelTextStyle.mutableCopy;
    textStyle.fontSize              = 9.0f;
    textStyle.color                 = [CPTColor colorWithComponentRed:54.0f/255.0f green:62.0f/255.0f blue:70.0f/255.0f alpha:1.0f];
    axisSet.yAxis.labelTextStyle    = textStyle.copy;
    axisSet.yAxis.labelingPolicy    = CPTAxisLabelingPolicyNone;
    
    // Tick Mark Style
    CPTMutableLineStyle *tickLineStyle  = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor             = [CPTColor grayColor];
    tickLineStyle.lineWidth             = 1.0f;
    axisSet.yAxis.majorTickLineStyle    = tickLineStyle.copy;
    axisSet.yAxis.majorTickLength       = 4.0f;
    axisSet.yAxis.tickDirection         = CPTSignNegative;
    */
    // Plot Space
    self.plotSpace          = (SFAXYPlotSpace *) self.graph.defaultPlotSpace;
    self.plotSpace.xRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(self.graphViewWidth)];
    self.plotSpace.yRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(Y_MAX_RANGE)];
    
    // Plot
    self.caloriesPlot       = [self linePlotWithLineColor:HEART_RATE_LINE_COLOR];
    /*
    CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    aaplSymbol.size = CGSizeMake(1.0f, 1.0f);
    self.caloriesPlot.plotSymbol = aaplSymbol;
    */
    //[self adjustTickLocation];
   
    
    
    self.isLandscape = NO;
    _oldGraphViewHorizontalSpace = self.graphViewHorizontalSpace.constant;
    
}


- (void)adjustGraphView
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationIsLandscape(orientation) && !self.isFirstLoad) {
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            if (self.isIOS8AndAbove) {
                self.graphViewHorizontalSpace.constant      = self.view.window.frame.size.width / 2;
                self.graphViewRightHorizontalSpace.constant = self.view.window.frame.size.width / 2;
                self.graphViewWidthConstraint.constant      = self.graphViewWidth;
            }
            else{
            self.graphViewHorizontalSpace.constant      = self.view.window.frame.size.height / 2;
            self.graphViewRightHorizontalSpace.constant = self.view.window.frame.size.height / 2;
            self.graphViewWidthConstraint.constant      = self.graphViewWidth;
            self.scrollView.contentSize                 = CGSizeMake(self.scrollView.contentSize.width, 0);
            }
        }
        else{
             if (self.isIOS8AndAbove) {
            self.graphViewHorizontalSpace.constant      = self.view.window.frame.size.width / 2;
            self.graphViewRightHorizontalSpace.constant = self.view.window.frame.size.width / 2;
             }
             else{
                 self.graphViewHorizontalSpace.constant      = self.view.window.frame.size.height / 2;
                 self.graphViewRightHorizontalSpace.constant = self.view.window.frame.size.height / 2;
             }
            
            // if (self.isIOS8AndAbove) {
            //     self.graphViewWidthConstraint.constant      = self.graphViewWidth + 192;
            // }
            // else{
            self.graphViewWidthConstraint.constant      = self.graphViewWidth;
            // }
        }
        
        self.graph.paddingLeft                      = 0.0f;
        self.graph.paddingRight                     = 0.0f;
        
        /*
        //redraw graph with all workouts for that day
        if (self.date){
            self.loadingView.hidden = NO;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self setContentsWithDate:self.date workoutIndex:0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update UI
                //    self.loadingView.hidden = YES;
                });
            });
        }
         */
        //[self scrollToFirstRecord];
        [self.graph hourLabelsWithBarWidth:self.maxBarWidth barSpace:self.barSpace];
        
        [self adjustGraphViewWidth];
    } else {
        [self adjustGraphViewWidth];
        self.graphViewHorizontalSpace.constant     = 0;
        self.graphViewRightHorizontalSpace.constant    = 0;
        self.graphViewWidthConstraint.constant  = self.view.frame.size.width;
        
        self.graph.paddingLeft                      = 20.0f;
        self.graph.paddingRight                     = 20.0f;
      
        /*
        if (self.date){
            self.loadingView.hidden = NO;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self setContentsWithDate:self.date workoutIndex:self.selectedIndex];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update UI
             //       self.loadingView.hidden = YES;
                });
            });
        }
         */
    }
    
    //    self.plotSpace.xRange                   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f)
    //                                                                           length:CPTDecimalFromFloat(self.graphViewWidth)];
    
    self.isFirstLoad = NO;
    
    //[self adjustBarPlotWidth];
    //    [self adjustTickLocation];
}

- (void)reloadGraph
{
    for (SFALinePlot *linePlot in self.visiblePlots)
    {
        [linePlot reloadData];
    }
}

- (SFALinePlot *)plotForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return self.caloriesPlot;
    }
    return nil;
}


- (CGFloat)graphViewWidth
{
    if (self.isLandscape) {
        CGFloat graphViewWidth  = self.maxBarWidth * 144/*self.maxX*/;
        graphViewWidth          += (144/*self.maxX*/ * self.barSpace);
        
        return graphViewWidth;
    }
    else{
        CGFloat graphViewWidth  = self.maxBarWidth * self.maxX;
        graphViewWidth          += (self.maxX * self.barSpace);
    
        return graphViewWidth;
    }
}
/*
- (void)adjustBarPlotWidth
{
    for (SFALinePlot *plot in self.visiblePlots)
    {
        NSInteger index     = [self.visiblePlots indexOfObject:plot];
        //plot.barWidth       = CPTDecimalFromCGFloat(self.barWidth);
        //plot.barOffset      = CPTDecimalFromCGFloat(self.barWidth * index + (self.barSpace * 0.5f) + (self.barWidth * 0.5f));
    }
}
*/
/*

- (void)adjustTickLocation
{
    NSMutableSet *tickLocations = [NSMutableSet new];
    float interval = self.graphViewHeight.constant/13.0;
    for (float a = 0; a <= 13; a=a+interval)
    {
        NSDecimal tickLocation  = CPTDecimalFromFloat(a);
        NSNumber *number        = [NSDecimalNumber decimalNumberWithDecimal:tickLocation];
        
        [tickLocations addObject:number];
    }
    
    CPTXYAxisSet *axisSet               = (CPTXYAxisSet *) self.graph.axisSet;
    axisSet.yAxis.majorTickLocations    = tickLocations.copy;
}
*/

- (void)adjustGraphViewWidth
{
    //    self.graphViewWidthConstraint.constant   = (!self.isLandscape) ? self.view.frame.size.width - 10.0f : self.graphViewWidth;
    self.plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(self.graphViewWidth)];
    
}

- (CGFloat)maxX
{
    return (self.endPoint - self.startPoint)+1;
}

- (CGFloat)maxBarWidth
{
    return DAY_DATA_BAR_WIDTH;
}

- (CGFloat)barWidth
{
    return self.maxBarWidth / self.barPlotCount;
}

- (CGFloat)barSpace
{
    
    return 8.0f;
}

- (NSInteger)barPlotCount
{
    return self.visiblePlots.count > 0 ? self.visiblePlots.count : 1;
}

- (NSString *)timeForIndex:(NSInteger)index startPoint:(NSInteger)startPoint
{
    NSInteger hour      = (index + startPoint) / 6;
    NSInteger minute    = (index + startPoint) - (hour * 6);
    
    if (hour == 0 || hour == HOURS_IN_DAY_COUNT)
    {
        return [NSString stringWithFormat:@"12:%i0%@", minute,LS_AM];
    }
    else if (hour == 12)
    {
        return [NSString stringWithFormat:@"12:%i0%@", minute,LS_PM];
    }
    else if (hour > 12)
    {
        hour -= 12;
        return [NSString stringWithFormat:@"%i:%i0%@", hour, minute,LS_PM];
    }
    else
    {
        return [NSString stringWithFormat:@"%i:%i0%@", hour, minute,LS_AM];
    }
    
    return nil;
}

#pragma mark - public methods

- (void)setContentsWithDate:(NSDate *)date workoutIndex:(NSInteger )index
{
    self.date = date;
    NSArray *data = [WorkoutHeaderEntity getWorkoutInfoWithDate:date];
    NSArray *dataPoints;
    if (data.count > 0){
        
        
        if (!self.isLandscape){
            self.selectedIndex = index;
            
            self.graphLabels = [[NSMutableDictionary alloc] init];
            dataPoints  = [WorkoutHeaderEntity getWorkoutHeartRateDataWithDate:date withWorkoutIndex:index];
            
        }else{
            self.startPoint = STARTPOINT_LANDSCAPE;
            self.endPoint   = DAY_DATA_MAX_COUNT_WORKOUT-1;
            dataPoints  = [WorkoutHeaderEntity getWorkoutHeartRateWithMinMaxDataWithDate:date];
            
        }
        
        self.calorieDataPoint = [dataPoints copy];
        self.caloriesMaxY  = [NSNumber numberWithFloat:240.0f];
        self.averageHeartRate = 0;
        
        NSMutableArray *calories    = [NSMutableArray new];
        
        //show whole day graph workout for landscape view
        NSDictionary *firstData = [dataPoints firstObject];
        NSDictionary *lastData = [dataPoints lastObject];
        NSInteger startingIndex = self.isLandscape ? 0 : [firstData[@"index"] integerValue];
        NSInteger endingIndex = self.isLandscape ? DAY_DATA_MAX_COUNT_WORKOUT-1 : [lastData[@"index"] integerValue];
        //increment ending index by 1 to add last graph label
        for (NSDictionary *hrDataDict in dataPoints)
        {
            int i = [hrDataDict[@"index"] intValue];
            CGFloat x;
            if (self.isLandscape) {
                x = (self.graphViewWidth) * ((i*1.0)/DAY_DATA_MAX_COUNT_WORKOUT);//-startingIndex);
            }
            else{
                x = (self.graphViewWidth/(endingIndex-startingIndex)) * (i - startingIndex);
            }
            CGFloat y;
            CGPoint point;
            
            NSNumber *hrData = hrDataDict[@"hrData"];
            
            y = [SFAGraphTools yWithMaxY:self.caloriesMaxY.floatValue yValue:hrData.floatValue];
            if (y > 0) {
                point = CGPointMake(x, y);
                [calories addObject:[NSValue valueWithCGPoint:point]];
            }
            else{
                [calories addObject:[NSValue valueWithCGPoint:CGPointZero]];
            }
        }
        self.calories  = calories.copy ? calories.copy : @[];
        
    }else{
        [self resetWorkoutData];
    }
    
    if ([self.delegate conformsToProtocol:@protocol(SFAR420HRWorkoutGraphViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(hrgraphViewController:didChangeHeartRate:)]){
        [self.delegate hrgraphViewController:self didChangeHeartRate:self.averageHeartRate];
    }
    
    if (self.isLandscape) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self adjustGraphViewWidth];
            [self reloadGraph];
            self.loadingView.hidden = YES;
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self adjustGraphViewWidth];
            [self reloadGraph];
            self.loadingView.hidden = YES;
        });
    }
}


#pragma mark - Other methods

- (void)resetWorkoutData
{
    self.calories  = nil;
    self.totalCalories  = 0;
    self.averageHeartRate = 0;
}

- (void)setMaxYValuesWorkoutData
{
    self.caloriesMaxY   = [NSNumber numberWithFloat:240.0f];
}

- (void)setLandscapeViewWorkoutWithDataPointIndex:(NSArray *)dataPointIndex dataPoints:(NSArray *)dataPoints startingIndex:(NSInteger *)startIndex endingIndex:(NSInteger *)endIndex
{
    //show whole day graph workout for landscape view
    NSInteger heartRateCount = 0;
    NSInteger startingIndex = self.isLandscape ? 0 :[[dataPointIndex firstObject] integerValue];
    NSInteger endingIndex = self.isLandscape ? (DAY_DATA_MAX_COUNT_WORKOUT-1):[[dataPointIndex lastObject] integerValue] >= DAY_DATA_MAX_COUNT_WORKOUT-1 ? DAY_DATA_MAX_COUNT_WORKOUT-1 : [[dataPointIndex lastObject] integerValue];
    
    for (NSDictionary *hrDataDict in dataPoints){
        /*
        //check if data point exists
        if (i>=dataPoints.count){
            break;
        }
        
        //skip data points of workoutstops
        if (![dataPointIndex containsObject:@(i)]){
            continue;
        }
        */
        //WorkoutHeartRateDataEntity *dataPoint = [[dataPoints filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:@"index == %i", i]] firstObject];
        NSNumber *hrData = hrDataDict[@"hrData"];
        
        //WorkoutHeartRateDataEntity *dataPoint = [dataPoints objectAtIndex:i];
        //self.caloriesMaxY   = @(240);//[hrData isGreaterThan:self.caloriesMaxY] ? hrData : self.caloriesMaxY;
        self.averageHeartRate   += hrData.integerValue;
        
        heartRateCount += hrData.integerValue > 0 ? 1 : 0;
    }
    *startIndex = startingIndex;
    *endIndex = endingIndex;
    self.averageHeartRate = heartRateCount != 0 ? self.averageHeartRate/heartRateCount : 0;
}

#pragma mark - Workout data points

- (NSArray *)getDataPointIndexArrayForDate:(NSDate *)date workoutIndex:(NSInteger )index
{
    self.date = date;
    
    NSArray *yesterdayData = [WorkoutHeaderEntity getWorkoutInfoWithDate:[date dateByAddingTimeInterval:-DAY_SECONDS]];
    WorkoutHeaderEntity *spillOverWorkout = nil;
    for (WorkoutHeaderEntity *workout in yesterdayData){
        if ([workout hasSpillOverWorkoutMinutes]){
            spillOverWorkout = workout;
            break;
        }
    }
    NSArray *data = nil;
    if (spillOverWorkout){
        NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[WorkoutHeaderEntity getWorkoutInfoWithDate:date]];
        [temp insertObject:spillOverWorkout atIndex:0];
        data = temp.copy;
    }else{
        data =[WorkoutHeaderEntity getWorkoutInfoWithDate:date];
    }
    
    NSArray *dataPointIndex = @[];
    
    if (!self.isLandscape){
        //self.graphLabels = [[NSMutableDictionary alloc] init];
        WorkoutHeaderEntity *workout = [data objectAtIndex:index];
        dataPointIndex = [self getDataPointsForWorkout:workout];
    }else{
        NSMutableArray *tempDataPointIndex = [[NSMutableArray alloc] init];
        NSInteger totalWorkout = 0;
        NSInteger workoukHundredths = 0;
        
        for (WorkoutHeaderEntity *workout in data){
            [tempDataPointIndex addObjectsFromArray:[self getDataPointsForWorkout:workout]];
            totalWorkout += (workout.hour.integerValue * 3600) + workout.minute.integerValue * 60 + workout.second.integerValue;
            workoukHundredths += workout.hundredths.integerValue;
        }
        //remove data point duplicates and sort
        dataPointIndex = [[tempDataPointIndex valueForKeyPath:@"@distinctUnionOfObjects.self"] sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
            if ( obj1.integerValue < obj2.integerValue ) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ( obj1.integerValue > obj2.integerValue ) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }
        }];
        
        self.startPoint = 0;
        self.endPoint   = DAY_DATA_MAX_COUNT_WORKOUT-1;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAR420HRWorkoutGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(hrgraphViewController:didChangeTotalWorkoutTime:)]){
            //convert to hundredth
            totalWorkout = (totalWorkout * 100) + workoukHundredths;
            [self.delegate hrgraphViewController:self didChangeTotalWorkoutTime:totalWorkout];
        }
        
    }
    return dataPointIndex;
}

- (NSArray *)getDataPointsForWorkout:(WorkoutHeaderEntity *)workout
{
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    //sort workout stop by index
    NSArray *tempWorkoutStop = [workout.workoutStopDatabase allObjects];
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    NSArray *workoutStops = [tempWorkoutStop sortedArrayUsingDescriptors:@[sortByIndex]];
    
    //get the starting index from the start time of the workout
    //NSInteger startMinutes =(workout.stampHour.integerValue * 60 + workout.stampMinute.integerValue);
    NSInteger startSeconds =(workout.stampHour.integerValue * 3600 + workout.stampMinute.integerValue * 60 + workout.stampSecond.integerValue);
    NSInteger startIndex = workout.stampHour.integerValue *60*60 + workout.stampMinute.integerValue*60 + workout.stampSecond.integerValue;//floorf(workout.stampMinute.integerValue/10);
    
    //initialize loop variabls
    NSInteger index = startIndex;
    NSInteger startWorkoutTime = startSeconds;
    //NSInteger tempTotalWorkout = 0;
    NSInteger tempTotalWorkoutSeconds = 0;
    //NSInteger tempTotalTime = workoutStops.count == 0 ? (workout.hour.integerValue * 60 + workout.minute.integerValue): 0;
    NSInteger tempTotalTimeSeconds = workoutStops.count == 0 ? (workout.hour.integerValue * 3600 + workout.minute.integerValue * 60 + workout.second.integerValue): 0;
    NSInteger carryOverWorkoutSeconds = 0;
    NSInteger carryOverStopMinutes = 0;
    NSInteger carryOverStopSeconds = 0;
    
    BOOL twoDayWorkout = NO;
    
    //add workout stop label for start of workout
    
    BOOL isSpillOverWorkout = [workout checkIfSpillOverWorkoutForDate:self.date];
    /*
    if (isSpillOverWorkout){
        //[self addWorkoutStopLabelForIndex:(0) time:0];
    }else{
        NSInteger startWorkoutTimeSeconds =(workout.stampHour.integerValue * 3600 + workout.stampMinute.integerValue * 60 + workout.stampSecond.integerValue);
        //[self addWorkoutStopLabelForIndex:(index) time:startWorkoutTimeSeconds];
    }
    */
    
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        NSInteger workoutMinutesSeconds = workoutStop.workoutHour.integerValue *60*60 + workoutStop.workoutMinute.integerValue*60 + workoutStop.workoutSecond.integerValue;
        //NSInteger stopSeconds = workoutStop.stopHour.integerValue *60*60 + workoutStop.stopMinute.integerValue*60 + workoutStop.stopSecond.integerValue;
        NSInteger startWorkoutTimeSeconds =(workout.stampHour.integerValue * 3600 + workout.stampMinute.integerValue* 60 + workout.stampSecond.integerValue);
        NSInteger workoutSeconds = workoutStop.workoutHour.integerValue * 3600 + workoutStop.workoutMinute.integerValue * 60 + workoutStop.workoutMinute.integerValue;
        NSInteger stopSeconds = workoutStop.stopHour.integerValue * 3600 + workoutStop.stopMinute.integerValue * 60 + workoutStop.stopSecond.integerValue;
        
        //workout stop is less than 10 minutes, disregard stop
        
        if (stopSeconds < 1/*10*60*/){
            carryOverWorkoutSeconds += workoutSeconds + stopSeconds;
            //carryOverStopMinutes += stopMinutes;
            carryOverStopSeconds += stopSeconds;
            continue;
        }
         
        
        //tempTotalTime += workoutMinutes + stopMinutes;
        tempTotalTimeSeconds += workoutSeconds + stopSeconds;
        workoutSeconds += carryOverWorkoutSeconds;
        //tempTotalWorkout += workoutSeconds;
        tempTotalWorkoutSeconds += workoutSeconds;
        
        //reset carry over
        carryOverWorkoutSeconds = 0;
        carryOverStopMinutes = 0;
        carryOverStopSeconds = 0;
        
        //adjust increments if workout time overlaps multiple datapoints
        int endWorkoutIncrementAdjustment = (startWorkoutTime + workoutSeconds)/*/(10*60)*/ - startWorkoutTimeSeconds/*/(10*60)*/;
        int endWorkoutIncrements = (startWorkoutTime + workoutSeconds + carryOverStopSeconds)/*%(10*60)*/ != 0  ? endWorkoutIncrementAdjustment+1: endWorkoutIncrementAdjustment;
        
        for (int i = 0; i<endWorkoutIncrements; i++){
            /*
            int startStop = startIndex + workoutSeconds;
            int endStop = startStop + stopSeconds;
            if (index <= endStop && index >= startStop) {
                index = endStop + i;
            }
            */
            if (index >= DAY_DATA_MAX_COUNT_WORKOUT){
                if (isSpillOverWorkout){
                    [temp addObject:@(index-DAY_DATA_MAX_COUNT_WORKOUT)];
                    index++;
                }else{
                    twoDayWorkout = YES;
                    break;
                }
            }else{
                if (!isSpillOverWorkout){
                    [temp addObject:@(index)];
                }
                index++;
            }
        }
        
        //increment index, by skipping stop indexes
        NSInteger stopStartOverlap = 10*60 - (startWorkoutTime + workoutSeconds)/*%(10*60)*/;
        NSInteger stopEndOverlap = (startWorkoutTime + workoutSeconds + stopSeconds)/*%(10*60)*/;
        
        NSInteger adjustedStopSeconds = stopSeconds - (stopStartOverlap + stopEndOverlap);
        NSInteger stopIncrements = adjustedStopSeconds/*/(10*60)*/;
        
        if (stopIncrements > 0){
            
            index += stopIncrements;
            
            //adjust start workout time to the start of next workout
            startWorkoutTime += workoutSeconds + stopSeconds;
            startWorkoutTimeSeconds += workoutSeconds + stopSeconds;
            
        }else{
            //adjust start workout time to the start of next workout
            startWorkoutTime += workoutSeconds + stopSeconds;
        }
    }
    
    //NSInteger totalWorkout = workout.hour.integerValue*60 + workout.minute.integerValue;
    NSInteger totalWorkoutSeconds = workout.hour.integerValue* 3600 + workout.minute.integerValue * 60 + workout.second.integerValue;
    //for workouts without stops, or for remaining workout after workout stop
    if (tempTotalWorkoutSeconds < totalWorkoutSeconds){
        
        tempTotalTimeSeconds += workoutStops.count == 0 ? 0: (totalWorkoutSeconds-tempTotalWorkoutSeconds)+carryOverStopSeconds;
        tempTotalTimeSeconds += workoutStops.count == 0 ? 0: (totalWorkoutSeconds-tempTotalWorkoutSeconds)+carryOverStopSeconds;
        
        //get remaining workout minutes
        NSInteger workoutSeconds = totalWorkoutSeconds - tempTotalWorkoutSeconds;
        
        //adjust increments if workout time overlaps multiple datapoints
        int endWorkoutIncrementAdjustment = (startWorkoutTime + workoutSeconds + carryOverStopSeconds)/*/(10*60)*/ - startWorkoutTime/*/(10*60)*/;
        int endWorkoutIncrements = (startWorkoutTime + workoutSeconds + carryOverStopSeconds)/*%(10*60)*/ != 0 ? endWorkoutIncrementAdjustment + 1:endWorkoutIncrementAdjustment;
        
        for (int i = 0; i<endWorkoutIncrements; i++){
            if (index >= DAY_DATA_MAX_COUNT_WORKOUT){
                if (isSpillOverWorkout){
                    [temp addObject:@(index-DAY_DATA_MAX_COUNT_WORKOUT)];
                    index++;
                }else{
                    twoDayWorkout = YES;
                    break;
                }
            }else{
                if (!isSpillOverWorkout){
                    [temp addObject:@(index)];
                }
                index++;
            }
        }
    }
    else if (tempTotalWorkoutSeconds != 0 && totalWorkoutSeconds != 0){
        int additionalTempValues = tempTotalWorkoutSeconds/*/(10*60)*/;
        for (int i = 1; i <= additionalTempValues; i++) {
            [temp addObject:@(index++/*[(NSNumber *)[temp lastObject] integerValue]+1*/)];
        }
        
        DDLogInfo(@"WORKOUT STOP ON END OF WORKOUT");
    }
    
    //adjust startPoint and endPoint for graph view
    self.startPoint = [[temp firstObject] integerValue];
    self.endPoint   = [[temp lastObject] integerValue] >= DAY_DATA_MAX_COUNT_WORKOUT-1 ? DAY_DATA_MAX_COUNT_WORKOUT-1 : [[temp lastObject] integerValue];
    
    //Delete index if it is part of workoutstop
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        NSInteger workoutSeconds = workoutStop.workoutHour.integerValue *60*60 + workoutStop.workoutMinute.integerValue*60 + workoutStop.workoutSecond.integerValue;
        NSInteger stopSeconds = workoutStop.stopHour.integerValue *60*60 + workoutStop.stopMinute.integerValue*60 + workoutStop.stopSecond.integerValue;
        
        if (stopSeconds >= 1) { //10*60
            NSInteger workoutStart = workout.stampHour.integerValue*60*60 + workout.stampMinute.integerValue*60 + workout.stampSecond.integerValue;
            NSMutableArray *tempCopy = [temp mutableCopy];
            for (NSNumber *index in temp) {
                if (index.integerValue > (lround((workoutStart+workoutSeconds)/*/(10*60)*/)) && index.integerValue < (lround((workoutStart+stopSeconds+workoutSeconds)/*/(10*60)*/))) {
                    [tempCopy removeObject:index];
                }
            }
            if ((tempTotalWorkoutSeconds != 0 && totalWorkoutSeconds != 0) && tempTotalWorkoutSeconds >= totalWorkoutSeconds){
                int additionalTempValues = tempTotalWorkoutSeconds/*/(10*60)*/;
                
                int indexOfLast = [[temp lastObject] integerValue];
                indexOfLast = indexOfLast - additionalTempValues;
                
                for (int i = 0; i < additionalTempValues; i++) {
                    int indexOfLastItem = [[tempCopy lastObject] integerValue];
                    if (indexOfLastItem <= indexOfLast) {
                        break;
                    }
                    [tempCopy removeObject:@(indexOfLastItem)];
                }
                
                DDLogInfo(@"WORKOUT STOP ON END OF WORKOUT");
                NSArray *workoutStops = [workout.workoutStopDatabase allObjects];
                NSInteger workoutStopDuration = 0;
                NSInteger workoutDuration = workout.hour.integerValue * 3600 + workout.minute.integerValue * 60 + workout.second.integerValue;
                for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
                    NSInteger stopSeconds = workoutStop.stopHour.integerValue * 3600 + workoutStop.stopMinute.integerValue * 60 + workoutStop.stopSecond.integerValue;
                    workoutStopDuration += stopSeconds;
                }
                
                NSInteger startSeconds =(workout.stampHour.integerValue * 3600 + workout.stampMinute.integerValue * 60 + workout.stampSecond.integerValue);
                
                workoutDuration += startSeconds + workoutStopDuration;
                if ([workout checkIfSpillOverWorkoutForDate:self.date]){
                    workoutDuration = [workout spillOverWorkoutEndTimeSeconds];
                    startSeconds= 0;
                }else{
                    workoutDuration = [workout hasSpillOverWorkoutSeconds] ? 86399 : workoutDuration;
                }
                
                // [self addWorkoutStopLabelForIndex:([(NSNumber *)[tempCopy lastObject] integerValue] +1) time:(workoutDuration)];
                
            }
            temp = [tempCopy mutableCopy];
        }
    }
    return temp;
}
/*
- (void)addWorkoutStopLabelForIndex:(NSInteger)index time:(NSInteger)time
{
    TimeDate *timeDate = [TimeDate getData];
    NSString *timeString = [self formatTimeWithHourFormat:timeDate.hourFormat hour:time/3600 minute:(time%3600)/60 second:time%60];
    
    if (timeDate.hourFormat == _24_HOUR) {
        timeString = [timeString removeTimeHourFormat];
    }
    
    [self.graphLabels setValue:timeString forKey:[NSString stringWithFormat:@"%i",index]];
}
 */


- (NSString *)formatTimeWithHourFormat:(HourFormat)hourFormat hour:(NSInteger)hour minute:(NSInteger)minute
{
    NSString *timeAMPM = @"";
    
    if (hourFormat == _12_HOUR) {
        timeAMPM = hour < 12 ? LS_AM : LS_PM;
        hour = hour > 12 ? hour - 12 : hour;
        hour = hour == 0 ? 12 : hour;
    }
    
    NSString *minuteString = [NSString stringWithFormat:@"%@%i", minute < 10 ? @"0" : @"", minute];
    NSString *time = [NSString stringWithFormat:@"%i:%@ %@", hour, minuteString, timeAMPM];
    
    return time;
}

- (NSString *)formatTimeWithHourFormat:(HourFormat)hourFormat hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second
{
    NSString *timeAMPM = @"";
    
    if (hourFormat == _12_HOUR) {
        timeAMPM = hour < 12 ? LS_AM : LS_PM;
        hour = hour > 12 ? hour - 12 : hour;
        hour = hour == 0 ? 12 : hour;
    }
    
    NSString *minuteString = [NSString stringWithFormat:@"%@%i", minute < 10 ? @"0" : @"", minute];
    NSString *secondString = [NSString stringWithFormat:@"%@%i", second < 10 ? @"0" : @"", second];
    NSString *time = [NSString stringWithFormat:@"%02d:%02d:%02d %@", hour, minute, second, timeAMPM];
    
    return time;
}

- (void)addGraphType:(SFAGraphType)graphType
{
    SFALinePlot *barPlot     = [self plotForGraphType:graphType];
    
    [barPlot reloadData];
    [self.graph addPlot:barPlot toPlotSpace:self.plotSpace];
    [self.visiblePlots addObject:barPlot];
    //[self adjustBarPlotWidth];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)removeGraphType:(SFAGraphType)graphType
{
    SFALinePlot *barPlot     = [self plotForGraphType:graphType];
    
    [self.graph removePlot:barPlot];
    [self.visiblePlots removeObject:barPlot];
    //[self adjustBarPlotWidth];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)resetScrollViewOffset
{
    self.scrollView.contentOffset = CGPointZero;
    [self scrollViewDidScroll:self.scrollView];
}

- (void)scrollToFirstRecord
{
    NSInteger firstRecordIndex = [(NSNumber *)[self.workoutDataPointsIndexArray firstObject] integerValue];
    
    
    CGRect firstRecordRect      = self.scrollView.frame;
    firstRecordRect.origin.x    = firstRecordIndex * (self.maxBarWidth + self.barSpace);
    
    [UIView animateWithDuration:0.5f animations:^{
        self.scrollView.contentOffset = firstRecordRect.origin;
    }];
    
    //        [self.scrollView scrollRectToVisible:firstRecordRect animated:NO];
    
}

/*
#pragma mark - CPTBarPlotDataSource Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if (plot == self.barPlot)
    {
        NSInteger recordCount = 0;
        
        if ([self.visiblePlots containsObject:[NSNumber numberWithInt:SFAGraphTypeCalories]])
        {
            recordCount += self.calories.count;
        }
        return recordCount;
    }
    
    return 0;
}

- (CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx
{
    SFAGraphType graphType  = [self graphTypeForIndex:idx];
    UIColor *color          = [self barColorForGraphType:graphType];
    CPTFill *fill           = [CPTFill fillWithColor:[CPTColor colorWithCGColor:color.CGColor]];
    
    return fill;
    
}
- (SFAGraphType)graphTypeForIndex:(NSInteger)index
{
    index = index % self.visiblePlots.count;
    return [self.visiblePlots[index] integerValue];
}

- (UIColor *)barColorForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return HEART_RATE_LINE_COLOR;
    }
    return nil;
}
 
 */

/*
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

- (NSArray *)dataSourceForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return self.calories;
    }
    
    return nil;
}
*/

#pragma mark - SFABarPlotDelegate Methods

- (NSInteger)numberOfPointsForLinePlot:(SFALinePlot *)linePlot
{
    //    if (barPlot == self.caloriesPlot)
    //    {
    //        return self.calories.count;
    //    }
    //    else if (barPlot == self.heartRatePlot)
    //    {
    //        return self.heartRate.count;
    //    }
    //    else if (barPlot == self.stepsPlot)
    //    {
    //        return self.steps.count;
    //    }
    //    else if (barPlot == self.distancePlot)
    //    {
    //        return self.distance.count;
    //    }
    //
    //    return 0;
    
    BarPlotType type;
    if (linePlot == self.caloriesPlot){
        type = CALORIE_PLOT;
        if (!self.calories.count){
            return 0;
        }
    }else{
        type = CALORIE_PLOT;
        if (!self.calories.count){
            return 0;
        }
    }
    
    return self.calories.count;//[linePlot numberOfBarForBarPlot:linePlot ofType:type withArrays:@[self.calories]];
}

- (CGPoint)linePlot:(SFALinePlot *)linePlot pointAtIndex:(NSInteger)index
{
    BarPlotType type;
    if (linePlot == self.caloriesPlot)
    {
        type = CALORIE_PLOT;
        //        return self.calories.count;
    }
    else
    {
        type = DISTANCE_PLOT;
        //        return self.distance.count;
    }
    CGPoint point = [[self.calories objectAtIndex:index] CGPointValue];
    return point;
    //return [linePlot barPlot:linePlot pointAtIndex:index ofType:type withArrays:@[self.calories]];
    
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.isScrolling = YES;
    //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
    //    [scrollView setContentOffset: CGPointMake(scrollView.contentOffset.x, 0)];
    //}
    CGFloat x           = scrollView.contentOffset.x-25 < 0 ? 0 : scrollView.contentOffset.x-25;
    x                   = scrollView.contentOffset.x-25 > self.graphViewWidth ? self.graphViewWidth : x;
    NSInteger index     = x / (self.graphViewWidth / DAY_DATA_MAX_COUNT_WORKOUT*1.0);//(self.maxBarWidth + self.barSpace);
    index               = index < self.maxX ? index : self.maxX;
    //DDLogInfo(@"x = %f", x);
    //DDLogInfo(@"index = %i", index);
    
    // Values
    if (self.isLandscape && [self.delegate conformsToProtocol:@protocol(SFAR420HRWorkoutGraphViewControllerDelegate)]
        /*&& [self.delegate respondsToSelector:@selector(hrgraphViewController:didChangeDataPoint:)]*/){
        if (!self.isIOS8AndAbove && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (index < DAY_DATA_MAX_COUNT_WORKOUT) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %i", index];
                NSArray *matchedArray = [self.calorieDataPoint filteredArrayUsingPredicate:predicate];
                NSDictionary *hrDict = [matchedArray firstObject];
                [self.delegate hrgraphViewController:self didChangeHeartRate:[hrDict[@"hrData"] integerValue]];
                [self.delegate hrgraphViewController:self didChangeMinHeartRate:[hrDict[@"min"] integerValue]];
                [self.delegate hrgraphViewController:self didChangeMaxHeartRate:[hrDict[@"max"] integerValue]];
            }
            [self.delegate hrgraphViewController:self didScroll:scrollView.contentOffset];
        }
        else{
        if (index < DAY_DATA_MAX_COUNT_WORKOUT) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %i", index];
            NSArray *matchedArray = [self.calorieDataPoint filteredArrayUsingPredicate:predicate];
            NSDictionary *hrDict = [matchedArray firstObject];
            [self.delegate hrgraphViewController:self didChangeHeartRate:[hrDict[@"hrData"] integerValue]];
            [self.delegate hrgraphViewController:self didChangeMinHeartRate:[hrDict[@"min"] integerValue]];
            [self.delegate hrgraphViewController:self didChangeMaxHeartRate:[hrDict[@"max"] integerValue]];
        }
            [self.delegate hrgraphViewController:self didScroll:scrollView.contentOffset];
        }
    }
    
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
