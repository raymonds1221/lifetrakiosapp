//
//  SFAContinuousHRViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 11/26/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAContinuousHRViewController.h"
#import "UISegmentedControl+Theme.h"
#import "SalutronUserProfile+Data.h"

#import "SFASalutronFitnessAppDelegate.h"

#import "SFAMainViewController.h"
#import "UIViewController+Helper.h"
#import "SFAContinuousHRGraphViewController.h"
#import "SFAContinuousHRPageViewController.h"
#import "SFAServerAccountManager.h"

#import "WorkoutHeaderEntity.h"
#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "CPTGraph+Label.h"

#import "SFAGraph.h"
#import "SFAGraphView.h"
#import "SFAGraphTools.h"
#import "SFAXYPlotSpace.h"
#import "SFABarPlot.h"
#import "SFATradingRangePlot.h"

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
#define BPM_VALUE_KEY       @"bpmValue"
#define BPM_MIN_VALUE_KEY   @"bpmMinValue"
#define BPM_MAX_VALUE_KEY   @"bpmMaxValue"

typedef enum
{
    SFAHeartRatePlotTypeBar,
    SFAHeartRatePlotTypeTradingRange
} SFAHeartRatePlotType;

@interface SFAContinuousHRViewController () <SFACalendarControllerDelegate, SFAContinuousHRGraphViewControllerDelegate>

// Core Datas
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

// Graphs
@property (strong, nonatomic) SFAContinuousHRGraphViewController   *viewController;
@property (readwrite, nonatomic) SFAHeartRatePlotType           plotType;
@property (readwrite, nonatomic) BOOL                           scrolled;
@property (readwrite, nonatomic) CGFloat                        scrollIndex;

// Data
@property (strong, nonatomic) NSArray *heartRate;

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@property (weak, nonatomic) IBOutlet UIImageView *imagePlayHead;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartRateAverageValue;
@property (weak, nonatomic) IBOutlet UILabel *minBPMLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxBPMLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartRateMinValue;
@property (weak, nonatomic) IBOutlet UILabel *heartRateMaxValue;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (weak, nonatomic) IBOutlet UIView *overlay1;
@property (weak, nonatomic) IBOutlet UIView *overlay2;
@property (weak, nonatomic) IBOutlet UIView *overlay3;
@property (weak, nonatomic) IBOutlet UIView *overlay4;
@property (weak, nonatomic) IBOutlet UIView *overlay5;

@end

@implementation SFAContinuousHRViewController

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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:HEART_RATE_GRAPH_SEGUE_IDENTIFIER])
    {
        self.viewController = (SFAContinuousHRGraphViewController *) segue.destinationViewController;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.imagePlayHead.hidden  = YES;
        self.activeTimeLabel.hidden  = YES;
    }
    else{
        self.imagePlayHead.hidden  = NO;
        self.activeTimeLabel.hidden  = NO;
    }
    self.isPortrait = (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    
    self.heartRateAverageValue.text = @"0";
    self.heartRateMinValue.text = @"0";
    self.heartRateMaxValue.text = @"0";
    
   // [self getHRsForDate:self.date];
    if (self.isPortrait) {
        [self getHRsForDate:self.date];
    }
    
    /*
    if (self.isIOS8AndAbove) {
        if (self.isIOS9AndAbove) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.viewController.loadingView.hidden = NO;
            });
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self setContentsWithDate:self.date];
        });
    }
    else{
        [self setContentsWithDate:self.date];
    }
     */
}

//- (void)willMoveToParentViewController:(UIViewController *)parent {
    //SFAHeartRateScrollViewController *heartRateScrollView = (SFAHeartRateScrollViewController *)parent;
    //self.parentScrollView = heartRateScrollView.scrollView;
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [self scrollToFirstData];
    
    
}

#pragma mark - SFAHeartRateGraphViewControllerDelegate Methods

- (void)graphViewController:(SFAContinuousHRGraphViewController *)graphViewController didChangeTime:(NSString *)time
{
    self.activeTimeLabel.text = time;
}

- (void)graphViewController:(SFAContinuousHRGraphViewController *)graphViewController didChangeHeartRate:(NSInteger)heartRate
{
    self.heartRateAverageValue.text = [NSString stringWithFormat:@"%i", heartRate];
}

- (void)graphViewController:(SFAContinuousHRGraphViewController *)graphViewController didChangeMinHeartRate:(NSInteger)minHeartRate
{
    self.heartRateMinValue.text = [NSString stringWithFormat:@"%i", minHeartRate];
}

- (void)graphViewController:(SFAContinuousHRGraphViewController *)graphViewController didChangeMaxHeartRate:(NSInteger)maxHeartRate
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

- (void)initializeObjects
{

    // Graph View
    self.viewController.delegate = self;
    
    // Active time
    self.activeTimeLabel.text = self.viewController.currentTime;
    
    // Status
    
    self.imagePlayHead.hidden  = YES;
    self.activeTimeLabel.hidden  = YES;
    self.isPortrait = YES;
    
    [self configureOverlayView];
    /*
    self.viewController.loadingView.hidden = NO;z
   
    if (self.isIOS8AndAbove) {
        if (self.isIOS9AndAbove) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.viewController.loadingView.hidden = NO;
            });
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self setContentsWithDate:self.date];
        });
    }
    else{
        [self setContentsWithDate:self.date];
     }*/
    
    self.heartRateMinValue.text = [NSString stringWithFormat:@"..."];
    self.heartRateMaxValue.text = [NSString stringWithFormat:@"..."];
    self.heartRateAverageValue.text = [NSString stringWithFormat:@"..."];
    self.viewController.loadingView.hidden = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getHRsForDate:self.date];
        [self.viewController getDataForDate:self.date];
    });
}

- (void)setContentsWithDate:(NSDate *)date
{
    self.viewController.loadingView.hidden = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.viewController getDataForDate:date];
    });
    
       
}

- (void)configureOverlayView{
    UIColor *lightGrayColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0];
    self.overlay1.layer.borderColor = lightGrayColor.CGColor;
    self.overlay1.layer.borderWidth = 0.5f;
    
    self.overlay2.layer.borderColor = lightGrayColor.CGColor;
    self.overlay2.layer.borderWidth = 0.5f;
    
    self.overlay3.layer.borderColor = lightGrayColor.CGColor;
    self.overlay3.layer.borderWidth = 0.5f;
    
    self.overlay4.layer.borderColor = lightGrayColor.CGColor;
    self.overlay4.layer.borderWidth = 0.5f;
    
    self.overlay5.layer.borderColor = lightGrayColor.CGColor;
    self.overlay5.layer.borderWidth = 0.5f;
    
    //self.overlayView.hidden = NO;
    self.overlayView.userInteractionEnabled = NO;
}



- (void)hrgraphViewControllerTouchStarted{
    self.overlayView.hidden = NO;
}
- (void)hrgraphViewControllerTouchEnded{
    self.overlayView.hidden = YES;
}


- (void)getHRsForDate:(NSDate *)date
{
    self.date = date;
    //
    //    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    StatisticalDataHeaderEntity *statisticalDataHeaderEntity = [StatisticalDataHeaderEntity statisticalDataHeaderEntityForDate:date];
    
    NSInteger minHRDataPoint = [statisticalDataHeaderEntity.minHR integerValue];
    NSInteger maxHRDataPoint = [statisticalDataHeaderEntity.maxHR integerValue];
    NSInteger aveHRDataPoint = [StatisticalDataPointEntity getAverageBPMForDate:date];
    
    NSArray *hrarray = [WorkoutHeaderEntity getWorkoutHeartRateDataWithDate:date];
    if ([hrarray count] > 0) {
        
        //
        //    //self.heartRateMinValue.text = [NSString stringWithFormat:@"%i", minHeartRate];
        //
        //    NSInteger averageBPM = [StatisticalDataPointEntity getAverageBPMForDate:statisticalDataHeaderEntity.dateInNSDate];
        //    aveHR = averageBPM;
        //
        //    if ( self.calendarController.calendarMode == SFACalendarDay && (minHR == 0 && maxHR == 0)) {
        //        if (averageBPM > 0) {
        //            NSArray *datapoints = [statisticalDataHeaderEntity.dataPoint copy];
        //            NSInteger tempMinHR = 0;
        //            NSInteger tempMaxHR = 0;
        //            NSMutableArray *heartRates = [[NSMutableArray alloc] init];
        //            for (StatisticalDataPointEntity *datapoint in datapoints) {
        //                if (datapoint.averageHR.integerValue > 0){
        //                    [heartRates addObject:datapoint.averageHR];
        //                    if (datapoint.averageHR.integerValue > tempMaxHR || tempMaxHR == 0) {
        //                        tempMaxHR = datapoint.averageHR.integerValue;
        //                    }
        //                    else if (datapoint.averageHR.integerValue < tempMinHR || tempMinHR == 0) {
        //                        tempMinHR = datapoint.averageHR.integerValue;
        //                    }
        //                }
        //            }
        //            if (heartRates.count == 1) {
        //                minHR = averageBPM - 5;
        //                maxHR = averageBPM + 5;
        //            }
        //            else if(heartRates.count > 1){
        //                minHR = tempMinHR;
        //                maxHR = tempMaxHR;
        //            }
        //            [heartRates removeAllObjects];
        //        }
        //
        //    }
        //    else if(self.calendarController.calendarMode == SFACalendarDay) {
        //        NSArray *datapoints = [statisticalDataHeaderEntity.dataPoint copy];
        //        NSInteger tempMaxHR = maxHR;
        //        NSMutableArray *heartRates = [[NSMutableArray alloc] init];
        //        for (StatisticalDataPointEntity *datapoint in datapoints) {
        //            if (datapoint.averageHR.integerValue > 0){
        //                [heartRates addObject:datapoint.averageHR];
        //                if (datapoint.averageHR.integerValue > tempMaxHR) {
        //                    tempMaxHR = datapoint.averageHR.integerValue;
        //                }
        //            }
        //        }
        //        maxHR = tempMaxHR;
        //    }
        //    //[self setMinAndMaxHeartRateForDate:date];
        //
        //    NSArray *data = [StatisticalDataPointEntity dataPointsForDate:date];
        //    NSInteger workoutCount = [[WorkoutHeaderEntity getWorkoutInfoWithDate:date] count];
        //    if (data && workoutCount > 0)
        //    {
        //        if (data.count > 0)
        //        {
        //
        //            NSMutableArray *heartRate = [NSMutableArray new];
        //            int averagehr = 0;
        //            int totalhr = 0;
        //            int minhr = 999;
        //            int maxhr = 0;
        //            int counter = 0;
        //
        //            /*
        //            NSArray *continuousHR = [WorkoutHeaderEntity getWorkoutHeartRateWithMinMaxDataWithDate:date];
        //
        //            for (NSDictionary *hrEntity in continuousHR) {
        //                totalhr += [hrEntity[@"hrData"] integerValue];
        //                counter++;
        //                if ([hrEntity[@"hrData"] integerValue]>0) {
        //                    minhr = [hrEntity[@"hrData"] integerValue] < minhr ? [hrEntity[@"hrData"] intValue] : minhr;
        //                    maxhr = [hrEntity[@"hrData"] integerValue] > maxhr ? [hrEntity[@"hrData"] intValue] : maxhr;
        //                }
        //            }
        //
        //
        //            for (StatisticalDataPointEntity *dataPoint in data)
        //            {
        //                if (dataPoint.averageHR.integerValue > 0) {
        //                    for (int i=0; i<600; i++) {
        //                        totalhr += dataPoint.averageHR.floatValue;
        //                        counter++;
        //                        if (minHR > 0) {
        //                            minhr = minHR < minhr ? minHR : minhr;
        //                        }
        //                        if (maxHR > 0) {
        //                            maxhr = minHR > maxhr ? maxHR : maxhr;
        //                        }
        //                    }
        //                }
        //            }
        //            */
        //#warning no case for data with normal and continuous hr
        //            averagehr = [WorkoutHeaderEntity getAverageWorkoutHeartRateWithDate:date];
        //            averagehr = abs(averagehr);
        //                if (self.isPortrait && averagehr > 0) {
        //                    aveHR = averagehr;
        //                    minHR = [WorkoutHeaderEntity getMinWorkoutHeartRateWithDate:date];
        //                    maxHR = [WorkoutHeaderEntity getMaxWorkoutHeartRateWithDate:date];
        //                }
        //                else{
        //                    aveHR = 0;
        //                    minHR = 0;
        //                    maxHR = 0;
        //                }
        //        }
        //    else {
        //        aveHR = 0;
        //        minHR = 0;
        //        maxHR = 0;
        //        }
        //    }
        
        NSArray *data = [StatisticalDataPointEntity dataPointsForDate:date];
        
        if (data)
        {
            if (data.count > 0)
            {
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
                                NSDictionary *hrDict = [NSDictionary dictionaryWithObjectsAndKeys:
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
                            NSDictionary *hrDict = [NSDictionary dictionaryWithObjectsAndKeys:
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
                                NSDictionary *hrDict = [NSDictionary dictionaryWithObjectsAndKeys:
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
                            NSDictionary *hrDict = [NSDictionary dictionaryWithObjectsAndKeys:
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
                
                
                
                for (StatisticalDataPointEntity *dataPoint in data)
                {
                    if (dataPoint.averageHR.integerValue > 0) {
                        NSInteger index         = [data indexOfObject:dataPoint];
                        NSDictionary *record    = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [NSNumber numberWithInt:dataPoint.averageHR.intValue], BPM_VALUE_KEY,
                                                   [NSNumber numberWithInteger:maxHRDataPoint], BPM_MAX_VALUE_KEY,
                                                   [NSNumber numberWithInteger:minHRDataPoint], BPM_MIN_VALUE_KEY,
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
                
                maxHRDataPoint = maximumBPM;
                minHRDataPoint = minimumBPM;
                aveHRDataPoint = averageBPM;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.heartRateAverageValue.text = [NSString stringWithFormat:@"%i", aveHRDataPoint];
                    self.heartRateMinValue.text = [NSString stringWithFormat:@"%i", minHRDataPoint];
                    self.heartRateMaxValue.text = [NSString stringWithFormat:@"%i", maxHRDataPoint];
                });
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                self.heartRateAverageValue.text = @"0";
                self.heartRateMinValue.text = @"0";
                self.heartRateMaxValue.text = @"0";
                });
            }
        }
        else{
            self.heartRateAverageValue.text = @"0";
            self.heartRateMinValue.text = @"0";
            self.heartRateMaxValue.text = @"0";
        }
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.heartRateAverageValue.text = [NSString stringWithFormat:@"%i", aveHRDataPoint];
            self.heartRateMinValue.text = [NSString stringWithFormat:@"%i", minHRDataPoint];
            self.heartRateMaxValue.text = [NSString stringWithFormat:@"%i", maxHRDataPoint];
        });
    }

}
@end
