//
//  SFAR420WorkoutGraphViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 11/9/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAR420WorkoutGraphViewController.h"

#import "SFAGraphView.h"
#import "SFAGraph.h"
#import "SFAGraphTools.h"
#import "SFAXYPlotSpace.h"
#import "SFABarPlot.h"
#import "SFABarPlot+Type.h"
#import "CPTGraph+Label.h"

#import "UIViewController+Helper.h"
#import "SFAGraphView.h"

#import "StatisticalDataHeaderEntity.h"
#import "StatisticalDataPointEntity.h"
#import "StatisticalDataPointEntity+Data.h"
#import "DateEntity.h"
#import "TimeEntity.h"
#import "WorkoutHeaderEntity.h"

#import "WorkoutStopDatabaseEntity.h"

#import "TimeDate+Data.h"

#define Y_VALUE_KEY                 @"yValue"
#define X_VALUE_KEY                 @"xValue"
#define SLEEP_LOGS_BAR_COLOR_KEY    @"sleepLogsBarColor"
#define SLEEP_LOGS_INDEX_KEY        @"sleepLogsIndex"
#define SLEEP_LOGS_BAR_WIDTH        DAY_DATA_BAR_WIDTH / 2

#define SLEEP_LOGS_START_INDEX      6 * 15

//#define GRAPH_VIEW_PADDING          155.0f
#define GRAPH_VIEW_PADDING          30.0f
#define GRAPH_VIEW_WIDTH            320.0f

#define WORKOUT_STOP                -1
#define NO_TIME_LABEL               -1


@interface SFAR420WorkoutGraphViewController ()<SFABarPlotDelegate,UIScrollViewDelegate, SFAGraphViewDelegate>


//@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *viewLeftGraphSpace;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *viewRightGraphSpace;

// Graph
@property (strong, nonatomic) SFAGraph          *graph;
@property (strong, nonatomic) SFAXYPlotSpace    *plotSpace;
@property (strong, nonatomic) SFABarPlot        *caloriesPlot;
@property (strong, nonatomic) SFABarPlot        *heartRatePlot;
@property (strong, nonatomic) SFABarPlot        *stepsPlot;
@property (strong, nonatomic) SFABarPlot        *distancePlot;
@property (strong, nonatomic) SFABarPlot        *barPlot;


// Data
@property (strong, nonatomic) NSArray *calories;
@property (strong, nonatomic) NSArray *heartRate;
@property (strong, nonatomic) NSArray *steps;
@property (strong, nonatomic) NSArray *distance;
@property (strong, nonatomic) NSArray *calorieDataPoint;
@property (strong, nonatomic) NSArray *heartRateDataPoint;
@property (strong, nonatomic) NSArray *stepsDataPoint;
@property (strong, nonatomic) NSArray *distanceDataPoint;

// Data
@property (strong, nonatomic) NSMutableArray *workouts;

@property (assign, nonatomic) NSUInteger workoutIndex;

@property (readwrite, nonatomic) NSInteger totalCalories;
@property (readwrite, nonatomic) NSInteger averageHeartRate;
@property (readwrite, nonatomic) NSInteger totalSteps;
@property (readwrite, nonatomic) CGFloat   totalDistance;

@property (strong, nonatomic) NSArray *workoutDataPointsIndexArray;


// Ranges
@property (strong, nonatomic) NSNumber *caloriesMaxY;
@property (strong, nonatomic) NSNumber *heartRateMaxY;
@property (strong, nonatomic) NSNumber *stepsMaxY;
@property (strong, nonatomic) NSNumber *distanceMaxY;

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

@implementation SFAR420WorkoutGraphViewController

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
    self.scrollView.contentOffset = self.scrollView.contentOffset;
    self.isScrolling = NO;
    self.scrollView.scrollEnabled = self.isLandscape;
    [self adjustGraphView];
    self.isScrolling = NO;
}

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

- (SFABarPlot *)barPlotWithBarColor:(UIColor *)barColor
{
    SFABarPlot *barPlot     = [SFABarPlot barPlot];
    barPlot.dataDelegate    = self;
    barPlot.fill            = [CPTFill fillWithColor:[CPTColor colorWithCGColor:barColor.CGColor]];
    barPlot.lineStyle       = nil;
    barPlot.anchorPoint     = CGPointZero;
    
    //    self.barPlot.dataSource     = self;
    //    self.barPlot.barWidth       = CPTDecimalFromCGFloat(self.barWidth);
    //    self.barPlot.barOffset      = CPTDecimalFromCGFloat((self.barWidth + self.barSpace) / 2);
    
    
    return barPlot;
}


- (void)initializeObjects
{
    
    // Scroll View
    self.scrollView.delegate = self;
    self.graphView.delegate = self;
    
    // Ranges
    self.caloriesMaxY   = [NSNumber numberWithFloat:0.0f];
    self.heartRateMaxY  = [NSNumber numberWithFloat:0.0f];
    self.stepsMaxY      = [NSNumber numberWithFloat:0.0f];
    self.distanceMaxY   = [NSNumber numberWithFloat:0.0f];
    
    // Graph
    self.graph                                  = [SFAGraph graphWithGraphView:self.graphView];
    self.graph.paddingLeft                      = 20.0f;
    self.graph.paddingRight                     = 20.0f;
    self.graph.paddingBottom                    = 0.0f;
    self.graph.paddingTop                       = 0.0f;
    self.graph.plotAreaFrame.masksToBorder      = NO;
    self.graphView.hostedGraph                  = self.graph;
    self.visiblePlots                           = [NSMutableArray new];
    
    // Axis Line Style
    CPTXYAxisSet *axisSet                       = (CPTXYAxisSet *) self.graph.axisSet;
    CPTMutableLineStyle *lineStyle              = axisSet.xAxis.axisLineStyle.mutableCopy;
    lineStyle.lineColor                         = [CPTColor clearColor];
    axisSet.xAxis.axisLineStyle                 = lineStyle.copy;
    axisSet.yAxis.hidden                        = YES;
    axisSet.yAxis.labelTextStyle                = nil;
    
    // Axis Text Style
    CPTMutableTextStyle *textStyle  = axisSet.xAxis.labelTextStyle.mutableCopy;
    textStyle.fontSize              = 9.0f;
    textStyle.color                 = [CPTColor colorWithComponentRed:54.0f/255.0f green:62.0f/255.0f blue:70.0f/255.0f alpha:1.0f];
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
    self.plotSpace.xRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(self.graphViewWidth)];
    self.plotSpace.yRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(Y_MAX_RANGE)];
    
    // Plot
    self.caloriesPlot       = [self barPlotWithBarColor:CALORIES_LINE_COLOR];
    self.heartRatePlot      = [self barPlotWithBarColor:HEART_RATE_LINE_COLOR];
    self.stepsPlot          = [self barPlotWithBarColor:STEPS_LINE_COLOR];
    self.distancePlot       = [self barPlotWithBarColor:DISTANCE_LINE_COLOR];
    
    [self adjustTickLocation];
    [self adjustGraphViewWidth];
    
    if (!self.isIOS8AndAbove && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //[self adjustGraphView];
    }
    
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
            }
        }
        else{
            //if (self.isIOS8AndAbove) {
            if (self.isIOS8AndAbove) {
            self.graphViewHorizontalSpace.constant      = self.view.window.frame.size.width / 2;
            self.graphViewRightHorizontalSpace.constant = self.view.window.frame.size.width / 2;
            }
            else{
                self.graphViewHorizontalSpace.constant      = self.view.window.frame.size.height / 2;
                self.graphViewRightHorizontalSpace.constant = self.view.window.frame.size.height / 2;
            }
        }
        //else{
        //    self.graphViewHorizontalSpace.constant      = self.view.window.frame.size.height / 2;
        //    self.graphViewRightHorizontalSpace.constant = self.view.window.frame.size.height / 2;
        //}
            
            // if (self.isIOS8AndAbove) {
            //     self.graphViewWidthConstraint.constant      = self.graphViewWidth + 192;
            // }
            // else{
            self.graphViewWidthConstraint.constant      = self.graphViewWidth;
            // }
        //}
        self.graph.paddingLeft                      = 0.0f;
        self.graph.paddingRight                     = 0.0f;
        
        //redraw graph with all workouts for that day
        if (self.date){
            [self setContentsWithDate:self.date workoutIndex:0];
        }
        if (self.isIOS8AndAbove && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            [self scrollToFirstRecord];
        }
        [self.graph hourLabelsWithBarWidth:self.maxBarWidth barSpace:self.barSpace];
    } else {
        self.graphViewHorizontalSpace.constant     = 0;
        self.graphViewRightHorizontalSpace.constant    = 0;
        //if (self.isIOS8AndAbove) {
            self.graphViewWidthConstraint.constant  = self.view.frame.size.width;
        //}
        //else{
        //    self.graphViewWidthConstraint.constant  = self.view.frame.size.height;
        //}
        
        self.graph.paddingLeft                      = 20.0f;
        self.graph.paddingRight                     = 20.0f;
        
        if (self.date){
            [self setContentsWithDate:self.date workoutIndex:self.selectedIndex];
        }
    }
    
    //    self.plotSpace.xRange                   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f)
    //                                                                           length:CPTDecimalFromFloat(self.graphViewWidth)];
    
    self.isFirstLoad = NO;
    [self adjustGraphViewWidth];
    [self adjustBarPlotWidth];
    //    [self adjustTickLocation];
}

- (void)reloadGraph
{
    for (SFABarPlot *barPlot in self.visiblePlots)
    {
        [barPlot reloadData];
    }
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


- (CGFloat)graphViewWidth
{
    
    CGFloat graphViewWidth  = self.maxBarWidth * self.maxX;
    graphViewWidth          += (self.maxX * self.barSpace);
    
    return graphViewWidth;
    /*
    if (self.isLandscape) {
        CGFloat graphViewWidth  = self.maxBarWidth * 144;
        graphViewWidth          += (144 * self.barSpace);
        
        return graphViewWidth;
    }
    else{
        CGFloat graphViewWidth  = self.maxBarWidth * self.maxX;
        graphViewWidth          += (self.maxX * self.barSpace);
        
        return graphViewWidth;
    }
    */
}

- (void)adjustBarPlotWidth
{
    for (SFABarPlot *plot in self.visiblePlots)
    {
        NSInteger index     = [self.visiblePlots indexOfObject:plot];
        plot.barWidth       = CPTDecimalFromCGFloat(self.barWidth);
        plot.barOffset      = CPTDecimalFromCGFloat(self.barWidth * index + (self.barSpace * 0.5f) + (self.barWidth * 0.5f));
    }
}

- (void)adjustTickLocation
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
    
    NSArray *dataPoints = [StatisticalDataPointEntity dataPointsForDate:date];
    //Testing - portrait data points
    //NSArray *workoutHEs = [WorkoutHeaderEntity getWorkoutInfoWithDate:self.date];
    //WorkoutHeaderEntity *workoutHE = workoutHEs[0];
    //NSArray *workoutRecordDataPoints = [workoutHE.workoutRecord copy];
    
    if (data.count > 0 && dataPoints.count > 0){
        
        NSArray *dataPointIndex = @[];
        
        if (!self.isLandscape){
            self.selectedIndex = index;
            
            self.graphLabels = [[NSMutableDictionary alloc] init];
            WorkoutHeaderEntity *workout = [data objectAtIndex:index];
            dataPointIndex = [self getDataPointsForWorkout:workout];
            
            if ([self.delegate conformsToProtocol:@protocol(SFAR420WorkoutGraphViewControllerDelegate)] &&
                [self.delegate respondsToSelector:@selector(graphViewController:didChangeTotalWorkoutTime:)]){
                
                NSInteger totalWorkout;
                if ([workout checkIfSpillOverWorkoutForDate:date]){
                    totalWorkout = [workout spillOverWorkoutSeconds];
                }else{
                    if ([workout hasSpillOverWorkoutSeconds]){
                        totalWorkout = [workout workoutDurationSecondsForThatDay];
                    }else{
                        totalWorkout = (workout.hour.integerValue * 3600) + workout.minute.integerValue * 60 + workout.second.integerValue;
                    }
                }
                
                //totalWorkout now in centiseconds/hundredth
                totalWorkout = (totalWorkout*100) + workout.hundredths.integerValue;
                [self.delegate graphViewController:self didChangeTotalWorkoutTime:totalWorkout];
            }
            
        }else{
            NSMutableArray *tempDataPointIndex = [[NSMutableArray alloc] init];
            NSInteger totalWorkout = 0;
            NSInteger workoutHundredths = 0;
            for (WorkoutHeaderEntity *workout in data){
                [tempDataPointIndex addObjectsFromArray:[self getDataPointsForWorkout:workout]];
                
                if ([workout checkIfSpillOverWorkoutForDate:date]){
                    totalWorkout += [workout spillOverWorkoutSeconds];
                }else{
                    if ([workout hasSpillOverWorkoutSeconds]){
                        totalWorkout += [workout workoutDurationSecondsForThatDay];
                    }else{
                        totalWorkout += (workout.hour.integerValue * 3600) + workout.minute.integerValue * 60 + workout.second.integerValue;
                        workoutHundredths += workout.hundredths.integerValue;
                    }
                }
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
            self.endPoint   = DAY_DATA_MAX_COUNT-1;
            
            if ([self.delegate conformsToProtocol:@protocol(SFAR420WorkoutGraphViewControllerDelegate)] &&
                [self.delegate respondsToSelector:@selector(graphViewController:didChangeTotalWorkoutTime:)]){
                //convert to hundredths
                totalWorkout = (totalWorkout * 100) + workoutHundredths;
                [self.delegate graphViewController:self didChangeTotalWorkoutTime:totalWorkout];
            }
            
            //[self.graph hourLabelsWithBarWidth:self.maxBarWidth barSpace:self.barSpace];
        }
        
        self.workoutDataPointsIndexArray = dataPointIndex.copy;
        //            NSArray *xAxisLabels = [self getArrayLabelsForWorkout:workout dataPointsArray:dataPointIndex];
        
        self.caloriesMaxY   = [NSNumber numberWithFloat:0.0f];
        self.heartRateMaxY  = [NSNumber numberWithFloat:0.0f];
        self.stepsMaxY      = [NSNumber numberWithFloat:0.0f];
        self.distanceMaxY   = [NSNumber numberWithFloat:0.0f];
        self.averageHeartRate = 0;
        
        NSMutableArray *calories    = [NSMutableArray new];
        NSMutableArray *heartRate   = [NSMutableArray new];
        NSMutableArray *steps       = [NSMutableArray new];
        NSMutableArray *distance    = [NSMutableArray new];
        
        
        NSInteger heartRateCount = 0;
        
        //show whole day graph workout for landscape view
        NSInteger startingIndex = self.isLandscape ? 0 :[[dataPointIndex firstObject] integerValue];
        NSInteger endingIndex = self.isLandscape ? 143:[[dataPointIndex lastObject] integerValue] >= DAY_DATA_MAX_COUNT-1 ? DAY_DATA_MAX_COUNT-1 : [[dataPointIndex lastObject] integerValue];
        
        for (int i = startingIndex; i<=endingIndex; i++){
            
            //check if data point exists
            if (i>=dataPoints.count){
                break;
            }
            
            //skip data points of workoutstops
            if (![dataPointIndex containsObject:@(i)]){
                continue;
            }
            
            StatisticalDataPointEntity *dataPoint = [dataPoints objectAtIndex:i];
            self.caloriesMaxY   = [dataPoint.calorie isGreaterThan:self.caloriesMaxY] ? dataPoint.calorie : self.caloriesMaxY;
            self.heartRateMaxY  = [dataPoint.averageHR isGreaterThan:self.heartRateMaxY] ? dataPoint.averageHR : self.heartRateMaxY;
            self.stepsMaxY      = [dataPoint.steps isGreaterThan:self.stepsMaxY] ? dataPoint.steps : self.stepsMaxY;
            self.distanceMaxY   = [dataPoint.distance isGreaterThan:self.distanceMaxY] ? dataPoint.distance : self.distanceMaxY;
            
            //self.totalCalories      += dataPoint.calorie.integerValue;
            //self.totalDistance      += dataPoint.distance.floatValue;
            //self.totalSteps         += dataPoint.steps.integerValue;
            self.averageHeartRate   += dataPoint.averageHR.integerValue;
            
            heartRateCount += dataPoint.averageHR.integerValue > 0 ? 1 : 0;
            
        }
        self.averageHeartRate = heartRateCount != 0 ? self.averageHeartRate/heartRateCount : 0;
        
        //graph labels
        NSMutableArray *tempGraphLabels = [[NSMutableArray alloc] init];
        
        //increment ending index by 1 to add last graph label
        for (NSInteger i = startingIndex; i <= endingIndex+1; i++)
        {
            CGFloat x = (self.maxBarWidth + self.barSpace) * (i - startingIndex);
            CGFloat y;
            CGPoint point;
            
            //setup graph portrait label
            if ([self.graphLabels objectForKey:[NSString stringWithFormat:@"%i",i]]){
                x = x==0? 0.01:x;
                [tempGraphLabels addObject:@{@"x":@(x), @"string":[self.graphLabels objectForKey:[NSString stringWithFormat:@"%i",i]]}];
            }
            
            //check if data point exists
            if (i>=dataPoints.count){
                break;
            }
            
            //skip data points of workoutstops
            if (![dataPointIndex containsObject:@(i)]){
                
                [calories addObject:[NSValue valueWithCGPoint:CGPointZero]];
                [heartRate addObject:[NSValue valueWithCGPoint:CGPointZero]];
                [steps addObject:[NSValue valueWithCGPoint:CGPointZero]];
                [distance addObject:[NSValue valueWithCGPoint:CGPointZero]];
                continue;
            }
            
            StatisticalDataPointEntity *dataPoint = [dataPoints objectAtIndex:i];
            
            // Calories
            y = [SFAGraphTools yWithMaxY:self.caloriesMaxY.floatValue yValue:dataPoint.calorie.floatValue];
            point = CGPointMake(x, y);
            
            [calories addObject:[NSValue valueWithCGPoint:point]];
            
            // Heart Rate
            y = [SFAGraphTools yWithMaxY:self.heartRateMaxY.floatValue yValue:dataPoint.averageHR.floatValue];
            point = CGPointMake(x, y);
            
            [heartRate addObject:[NSValue valueWithCGPoint:point]];
            
            // Steps
            y = [SFAGraphTools yWithMaxY:self.stepsMaxY.floatValue yValue:dataPoint.steps.floatValue];
            point = CGPointMake(x, y);
            
            [steps addObject:[NSValue valueWithCGPoint:point]];
            
            // Distance
            y = [SFAGraphTools yWithMaxY:self.distanceMaxY.floatValue yValue:dataPoint.distance.floatValue];
            point = CGPointMake(x, y);
            
            [distance addObject:[NSValue valueWithCGPoint:point]];
        }
        
        self.calories  = calories.copy ? calories.copy : @[];
        self.heartRate = heartRate.copy ? heartRate.copy : @[];
        self.steps     = steps.copy ? steps.copy : @[];
        self.distance  = distance.copy ? distance.copy: @[];
        
        if(!self.isLandscape){
        [self.graph workoutPortraitLabelsWithBarWidth:self.maxBarWidth barSpace:self.barSpace labelArray:@[] numberOfDataPoints:(endingIndex-startingIndex)];
        }
        
    }else{
        [self resetWorkoutData];
        if(!self.isLandscape){
        [self.graph workoutPortraitLabelsWithBarWidth:self.maxBarWidth barSpace:self.barSpace labelArray:@[] numberOfDataPoints:0];
        }
    }
    
    if ([self.delegate conformsToProtocol:@protocol(SFAR420WorkoutGraphViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(graphViewController:didChangeHeartRate:)]){
        [self.delegate graphViewController:self didChangeHeartRate:self.averageHeartRate];
    }
    
    [self reloadGraph];
    [self adjustGraphViewWidth];
    [self adjustBarPlotWidth];
    [self adjustTickLocation];
}


#pragma mark - Other methods

- (void)resetWorkoutData
{
    self.calories  = nil;
    self.heartRate = nil;
    self.steps     = nil;
    self.distance  = nil;
    
    self.totalCalories  = 0;
    self.totalDistance  = 0;
    self.totalSteps     = 0;
    self.averageHeartRate = 0;
}

- (void)setMaxYValuesWorkoutData
{
    self.caloriesMaxY   = [NSNumber numberWithFloat:0.0f];
    self.heartRateMaxY  = [NSNumber numberWithFloat:0.0f];
    self.stepsMaxY      = [NSNumber numberWithFloat:0.0f];
    self.distanceMaxY   = [NSNumber numberWithFloat:0.0f];
}

- (void)setLandscapeViewWorkoutWithDataPointIndex:(NSArray *)dataPointIndex dataPoints:(NSArray *)dataPoints startingIndex:(NSInteger *)startIndex endingIndex:(NSInteger *)endIndex
{
    //show whole day graph workout for landscape view
    NSInteger heartRateCount = 0;
    NSInteger startingIndex = self.isLandscape ? 0 :[[dataPointIndex firstObject] integerValue];
    NSInteger endingIndex = self.isLandscape ? 143:[[dataPointIndex lastObject] integerValue] >= DAY_DATA_MAX_COUNT-1 ? DAY_DATA_MAX_COUNT-1 : [[dataPointIndex lastObject] integerValue];
    
    for (int i=startingIndex; i<=endingIndex; i++){
        
        //check if data point exists
        if (i>=dataPoints.count){
            break;
        }
        
        //skip data points of workoutstops
        if (![dataPointIndex containsObject:@(i)]){
            continue;
        }
        
        StatisticalDataPointEntity *dataPoint = [dataPoints objectAtIndex:i];
        self.caloriesMaxY   = [dataPoint.calorie isGreaterThan:self.caloriesMaxY] ? dataPoint.calorie : self.caloriesMaxY;
        self.heartRateMaxY  = [dataPoint.averageHR isGreaterThan:self.heartRateMaxY] ? dataPoint.averageHR : self.heartRateMaxY;
        self.stepsMaxY      = [dataPoint.steps isGreaterThan:self.stepsMaxY] ? dataPoint.steps : self.stepsMaxY;
        self.distanceMaxY   = [dataPoint.distance isGreaterThan:self.distanceMaxY] ? dataPoint.distance : self.distanceMaxY;
        
        //self.totalCalories      += dataPoint.calorie.integerValue;
        //self.totalDistance      += dataPoint.distance.floatValue;
        //self.totalSteps         += dataPoint.steps.integerValue;
        self.averageHeartRate   += dataPoint.averageHR.integerValue;
        
        heartRateCount += dataPoint.averageHR.integerValue > 0 ? 1 : 0;
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
        self.graphLabels = [[NSMutableDictionary alloc] init];
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
        self.endPoint   = DAY_DATA_MAX_COUNT-1;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAR420WorkoutGraphViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(graphViewController:didChangeTotalWorkoutTime:)]){
            //convert to hundredth
            totalWorkout = (totalWorkout * 100) + workoukHundredths;
            [self.delegate graphViewController:self didChangeTotalWorkoutTime:totalWorkout];
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
    NSInteger startMinutes =(workout.stampHour.integerValue * 60 + workout.stampMinute.integerValue);
    //NSInteger startSeconds =(workout.stampHour.integerValue * 3600 + workout.stampMinute.integerValue * 60 + workout.stampSecond.integerValue);
    NSInteger startIndex = workout.stampHour.integerValue *6 + floorf(workout.stampMinute.integerValue/10);
    
    //initialize loop variabls
    NSInteger index = startIndex;
    NSInteger startWorkoutTime = startMinutes;
    NSInteger tempTotalWorkout = 0;
    NSInteger tempTotalWorkoutSeconds = 0;
    NSInteger tempTotalTime = workoutStops.count == 0 ? (workout.hour.integerValue * 60 + workout.minute.integerValue): 0;
    NSInteger tempTotalTimeSeconds = workoutStops.count == 0 ? (workout.hour.integerValue * 3600 + workout.minute.integerValue * 60 + workout.second.integerValue): 0;
    NSInteger carryOverWorkoutMinutes = 0;
    NSInteger carryOverStopMinutes = 0;
    NSInteger carryOverStopSeconds = 0;
    
    BOOL twoDayWorkout = NO;
    
    //add workout stop label for start of workout
    BOOL isSpillOverWorkout = [workout checkIfSpillOverWorkoutForDate:self.date];
    if (isSpillOverWorkout){
        [self addWorkoutStopLabelForIndex:(0) time:0];
    }else{
        NSInteger startWorkoutTimeSeconds =(workout.stampHour.integerValue * 3600 + workout.stampMinute.integerValue * 60 + workout.stampSecond.integerValue);
        [self addWorkoutStopLabelForIndex:(index) time:startWorkoutTimeSeconds];
    }
    
    
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        NSInteger workoutMinutes = workoutStop.workoutHour.integerValue *60 + workoutStop.workoutMinute.integerValue;
        NSInteger stopMinutes = workoutStop.stopHour.integerValue *60 + workoutStop.stopMinute.integerValue;
        NSInteger startWorkoutTimeSeconds =(workout.stampHour.integerValue * 3600 + workout.stampMinute.integerValue* 60 + workout.stampSecond.integerValue);
        NSInteger workoutSeconds = workoutStop.workoutHour.integerValue * 3600 + workoutStop.workoutMinute.integerValue * 60 + workoutStop.workoutMinute.integerValue;
        NSInteger stopSeconds = workoutStop.stopHour.integerValue * 3600 + workoutStop.stopMinute.integerValue * 60 + workoutStop.stopSecond.integerValue;
        
        //workout stop is less than 10 minutes, disregard stop
        if (stopMinutes < 10){
            carryOverWorkoutMinutes += workoutMinutes + stopMinutes;
            carryOverStopMinutes += stopMinutes;
            carryOverStopSeconds += stopSeconds;
            continue;
        }
        
        tempTotalTime += workoutMinutes + stopMinutes;
        tempTotalTimeSeconds += workoutSeconds + stopSeconds;
        workoutMinutes += carryOverWorkoutMinutes;
        tempTotalWorkout += workoutMinutes;
        tempTotalWorkoutSeconds += workoutSeconds;
        
        //reset carry over
        carryOverWorkoutMinutes = 0;
        carryOverStopMinutes = 0;
        carryOverStopSeconds = 0;
        
        //adjust increments if workout time overlaps multiple datapoints
        int endWorkoutIncrementAdjustment = (startWorkoutTime + workoutMinutes)/10 - startWorkoutTime/10;
        int endWorkoutIncrements = (startWorkoutTime + workoutMinutes + carryOverStopMinutes)%10 != 0  ? endWorkoutIncrementAdjustment+1: endWorkoutIncrementAdjustment;
        
        for (int i = 0; i<endWorkoutIncrements; i++){
            
            if (index >= 144){
                if (isSpillOverWorkout){
                    [temp addObject:@(index-144)];
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
        NSInteger stopStartOverlap = 10 - (startWorkoutTime + workoutMinutes)%10;
        NSInteger stopEndOverlap = (startWorkoutTime + workoutMinutes + stopMinutes)%10;
        
        NSInteger adjustedStopMinutes = stopMinutes - (stopStartOverlap + stopEndOverlap);
        NSInteger stopIncrements = adjustedStopMinutes/10;
        
        if (stopIncrements > 0){
            
            //add workout stop label for start of workout stop
            /*
             if (isSpillOverWorkout){
             if (index>143){
             [self addWorkoutStopLabelForIndex:(index-144) time:(startWorkoutTimeSeconds+workoutSeconds)];
             }
             }else{
             [self addWorkoutStopLabelForIndex:(index) time:(startWorkoutTimeSeconds+workoutSeconds)];
             }
             */
            index += stopIncrements;
            
            //adjust start workout time to the start of next workout
            startWorkoutTime += workoutMinutes + stopMinutes;
            startWorkoutTimeSeconds += workoutSeconds + stopSeconds;
            
            //add workout stop label for end of workout stop
            /*
             if (isSpillOverWorkout){
             if (index>143){
             [self addWorkoutStopLabelForIndex:(index-144) time:(startWorkoutTimeSeconds+workoutSeconds)];
             }
             }else{
             [self addWorkoutStopLabelForIndex:(index) time:(startWorkoutTimeSeconds)];
             }
             */
        }else{
            //adjust start workout time to the start of next workout
            startWorkoutTime += workoutMinutes + stopMinutes;
        }
    }
    
    NSInteger totalWorkout = workout.hour.integerValue*60 + workout.minute.integerValue;
    NSInteger totalWorkoutSeconds = workout.hour.integerValue* 3600 + workout.minute.integerValue * 60 + workout.second.integerValue;
    //for workouts without stops, or for remaining workout after workout stop
    if (tempTotalWorkout < totalWorkout){
        
        tempTotalTime += workoutStops.count == 0 ? 0: (totalWorkout-tempTotalWorkout)+carryOverStopMinutes;
        tempTotalTimeSeconds += workoutStops.count == 0 ? 0: (totalWorkoutSeconds-tempTotalWorkoutSeconds)+carryOverStopSeconds;
        
        //get remaining workout minutes
        NSInteger workoutMinutes = totalWorkout - tempTotalWorkout;
        
        //adjust increments if workout time overlaps multiple datapoints
        int endWorkoutIncrementAdjustment = (startWorkoutTime + workoutMinutes + carryOverStopMinutes)/10 - startWorkoutTime/10;
        int endWorkoutIncrements = (startWorkoutTime + workoutMinutes + carryOverStopMinutes)%10 != 0 ? endWorkoutIncrementAdjustment + 1:endWorkoutIncrementAdjustment;
        
        for (int i = 0; i<endWorkoutIncrements; i++){
            if (index >= 144){
                if (isSpillOverWorkout){
                    [temp addObject:@(index-144)];
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
    else if (tempTotalWorkout != 0 && totalWorkout != 0){
        int additionalTempValues = tempTotalWorkout/10;
        for (int i = 1; i <= additionalTempValues; i++) {
            [temp addObject:@(index++/*[(NSNumber *)[temp lastObject] integerValue]+1*/)];
        }
        
        DDLogInfo(@"WORKOUT STOP ON END OF WORKOUT");
    }
    
    //add workout stop label for end of workout
    if (!twoDayWorkout){
        if (isSpillOverWorkout){
            [self addWorkoutStopLabelForIndex:([(NSNumber *)[temp lastObject] integerValue] +1) time:[workout spillOverWorkoutEndTimeSeconds]];
        }else{
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
            
            [self addWorkoutStopLabelForIndex:([(NSNumber *)[temp lastObject] integerValue] +1) time:(workoutDuration)];
            
            //   [self addWorkoutStopLabelForIndex:([(NSNumber *)[temp lastObject] integerValue] +1) time:(tempTotalTimeSeconds+startSeconds)];
        }
    }else{
        [self addWorkoutStopLabelForIndex:([(NSNumber *)[temp lastObject] integerValue] +1) time:(86399)];
    }
    
    
    if ([self.delegate conformsToProtocol:@protocol(SFAR420WorkoutGraphViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(graphViewController:didChangeWorkoutEndTime:)]){
        TimeDate *timeDate = [TimeDate getData];
        /*
         NSInteger startSeconds = workout.stampHour.integerValue * 3600 + workout.stampMinute.integerValue * 60 + workout.stampSecond.integerValue;
         if (!twoDayWorkout){
         if (!isSpillOverWorkout){
         tempTotalTime += startSeconds;
         }else{
         tempTotalTime = [workout spillOverWorkoutEndTimeSeconds];
         }
         
         }else{
         tempTotalTime = 86399;
         }
         NSString *endTime = [self formatTimeWithHourFormat:timeDate.hourFormat
         hour:(tempTotalTime/3600)
         minute:((tempTotalTime%3600)/60)
         second:(tempTotalTime%60)];
         */
        //in seconds
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
        
        NSInteger endMinute = (workoutDuration%3600)/60;
        NSInteger endHour = workoutDuration/3600;
        NSInteger endSecond = workoutDuration%60;
        
        NSString *endTime   = [self formatTimeWithHourFormat:timeDate.hourFormat
                                                        hour:endHour
                                                      minute:endMinute
                                                      second:endSecond];
        if (timeDate.hourFormat == _24_HOUR) {
            endTime = [endTime removeTimeHourFormat];
        }
        
        [self.delegate graphViewController:self didChangeWorkoutEndTime:endTime];
        
        //get index between start and duration
        /*
         int i = 0;
         [temp removeAllObjects];
         i = startSeconds;
         while(i < workoutDuration) {
         [temp addObject:@((i/60)/10)];
         i += (60*10);
         }
         */
        
    }
    
    //adjust startPoint and endPoint for graph view
    self.startPoint = [[temp firstObject] integerValue];
    self.endPoint   = [[temp lastObject] integerValue] >= DAY_DATA_MAX_COUNT-1 ? DAY_DATA_MAX_COUNT-1 : [[temp lastObject] integerValue];
    //Delete index if it is part of workoutstop
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        NSInteger workoutMinutes = workoutStop.workoutHour.integerValue *60 + workoutStop.workoutMinute.integerValue;
        NSInteger stopMinutes = workoutStop.stopHour.integerValue *60 + workoutStop.stopMinute.integerValue;
        
        if (stopMinutes >= 10) {
            NSInteger workoutStart = workout.stampHour.integerValue*60 + workout.stampMinute.integerValue;
            NSMutableArray *tempCopy = [temp mutableCopy];
            for (NSNumber *index in temp) {
                if (index.integerValue > (lround((workoutStart+workoutMinutes)/10)) && index.integerValue < (lround((workoutStart+stopMinutes+workoutMinutes)/10))) {
                    [tempCopy removeObject:index];
                }
            }
            if ((tempTotalWorkout != 0 && totalWorkout != 0) && tempTotalWorkout >= totalWorkout){
                int additionalTempValues = tempTotalWorkout/10;
                
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

- (void)addWorkoutStopLabelForIndex:(NSInteger)index time:(NSInteger)time
{
    TimeDate *timeDate = [TimeDate getData];
    NSString *timeString = [self formatTimeWithHourFormat:timeDate.hourFormat hour:time/3600 minute:(time%3600)/60 second:time%60];
    
    if (timeDate.hourFormat == _24_HOUR) {
        timeString = [timeString removeTimeHourFormat];
    }
    
    [self.graphLabels setValue:timeString forKey:[NSString stringWithFormat:@"%i",index]];
}


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
    SFABarPlot *barPlot     = [self plotForGraphType:graphType];
    
    [barPlot reloadData];
    [self.graph addPlot:barPlot toPlotSpace:self.plotSpace];
    [self.visiblePlots addObject:barPlot];
    [self adjustBarPlotWidth];
    [self scrollViewDidScroll:self.scrollView];
}

- (void)removeGraphType:(SFAGraphType)graphType
{
    SFABarPlot *barPlot     = [self plotForGraphType:graphType];
    
    [self.graph removePlot:barPlot];
    [self.visiblePlots removeObject:barPlot];
    [self adjustBarPlotWidth];
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

#pragma mark - SFABarPlotDelegate Methods

- (NSInteger)numberOfBarForBarPlot:(SFABarPlot *)barPlot
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
    if (barPlot == self.caloriesPlot){
        type = CALORIE_PLOT;
        if (!self.calories.count){
            return 0;
        }
    }else if (barPlot == self.heartRatePlot){
        type = HEARTRATE_PLOT;
        if (!self.heartRate.count){
            return 0;
        }
    }else if (barPlot == self.stepsPlot){
        type = STEPS_PLOT;
        if (!self.steps.count){
            return 0;
        }
    }else if (barPlot == self.distancePlot){
        type = DISTANCE_PLOT;
        if (!self.distance.count){
            return 0;
        }
    }else{
        type = CALORIE_PLOT;
        if (!self.calories.count){
            return 0;
        }
    }
    
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

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.isScrolling = YES;
    //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
    //    [scrollView setContentOffset: CGPointMake(scrollView.contentOffset.x, 0)];
    //}
    CGFloat x           = scrollView.contentOffset.x - 25 < 0 ? 0 : scrollView.contentOffset.x - 25;
    x                   = scrollView.contentOffset.x - 25 > self.graphViewWidth ? self.graphViewWidth : x;
    NSInteger index     = x / (self.maxBarWidth + self.barSpace);
    index               = index < self.maxX ? index : self.maxX;
    //DDLogInfo(@"x = %f", x);
    //DDLogInfo(@"index = %i", index);
    
    // Values
    if (self.isLandscape && [self.delegate conformsToProtocol:@protocol(SFAR420WorkoutGraphViewControllerDelegate)]
        && [self.delegate respondsToSelector:@selector(graphViewController:didChangeDataPoint:)]){
        if (!self.isIOS8AndAbove && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if ([self.workoutDataPointsIndexArray containsObject:@(index)]){
                [self.delegate graphViewController:self didChangeDataPoint:index];
            }else{
                [self.delegate graphViewController:self didChangeDataPoint:WORKOUT_STOP*index];
            }
            [self.delegate graphViewController:self didScroll:scrollView.contentOffset];
            
        }
        else{
            if ([self.workoutDataPointsIndexArray containsObject:@(index)]){
                [self.delegate graphViewController:self didChangeDataPoint:index];
            }else{
                [self.delegate graphViewController:self didChangeDataPoint:WORKOUT_STOP*index];
            }
            
            [self.delegate graphViewController:self didScroll:scrollView.contentOffset];
        }
    }
    
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.delegate graphViewControllerTouchStarted];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //[self.delegate graphViewController:self didEndScroll:scrollView.contentOffset];
    [self.delegate graphViewControllerTouchEnded];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //[self.delegate graphViewController:self didEndScroll:scrollView.contentOffset];
    [self.delegate graphViewControllerTouchEnded];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    //[self.delegate graphViewController:self didEndScroll:scrollView.contentOffset];
    [self.delegate graphViewControllerTouchEnded];
    self.isScrolling = NO;
}

- (void)graphTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.delegate graphViewControllerTouchStarted];
}
- (void)graphTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.delegate graphViewControllerTouchEnded];
    
}

@end

