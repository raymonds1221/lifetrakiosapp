//
//  SFAR420WorkoutViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 11/6/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAR420WorkoutViewController.h"

#import "SFASalutronFitnessAppDelegate.h"

#import "SFAMainViewController.h"
#import "SFAR420WorkoutGraphViewController.h"
#import "SFAR420HRWorkoutGraphViewController.h"

#import "SFAGraphView.h"
#import "SFAGraph.h"
#import "SFAGraphTools.h"
#import "SFAXYPlotSpace.h"
#import "SFABarPlot.h"
#import "SFABarPlot+Type.h"
#import "CPTGraph+Label.h"
#import "UIViewController+Helper.h"

#import "StatisticalDataHeaderEntity.h"
#import "StatisticalDataPointEntity.h"
#import "StatisticalDataPointEntity+Data.h"
#import "DateEntity.h"
#import "TimeEntity.h"
#import "WorkoutHeaderEntity.h"
#import "WorkoutHeaderEntity+CoreDataProperties.h"
#import "NSString+Helper.h"

#import "SFAWorkoutInfoCell.h"
#import "TimeDate+Data.h"

#import <QuartzCore/QuartzCore.h>


#import "SalutronUserProfile+Data.h"


#define WORKOUT_GRAPH_SEGUE_IDENTIFIER @"WorkoutGraph"
#define HR_WORKOUT_GRAPH_SEGUE_IDENTIFIER @"HRWorkoutGraph"

#define WORKOUT_LOGS_HEADER_CELL_IDENTIFIER @"WorkoutsHeaderCell"
#define WORKOUT_LOGS_CELL_IDENTIFIER @"WorkoutDataCell"

#define CALORIES_ACTIVE_IMAGE   [UIImage imageNamed:@"ll_workout_toggle_icon_calorie"]
#define HEART_RATE_ACTIVE_IMAGE [UIImage imageNamed:@"ll_workout_toggle_icon_heart"]
#define STEPS_ACTIVE_IMAGE      [UIImage imageNamed:@"ll_workout_toggle_icon_steps"]
#define DISTANCE_ACTIVE_IMAGE   [UIImage imageNamed:@"ll_workout_toggle_icon_distance"]
#define INACTIVE_IMAGE          [UIImage imageNamed:@"ll_workout_toggle_icon_inactive"]


@interface SFAR420WorkoutViewController () < UITableViewDataSource, UITableViewDelegate, SFAR420WorkoutGraphViewControllerDelegate, SFAR420HRWorkoutGraphViewControllerDelegate,SFACalendarControllerDelegate, UIGestureRecognizerDelegate, SFAGraphViewDelegate>

// Core Data
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) SFAR420WorkoutGraphViewController *graphViewController;
@property (strong, nonatomic) SFAR420HRWorkoutGraphViewController *hrGraphViewController;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endTimeConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startTimeConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *workoutMetricConstraints;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *workoutMetricBottomConstraints;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusTopConstaint;


@property (readwrite, nonatomic) NSInteger startPoint;
@property (readwrite, nonatomic) NSInteger endPoint;

//@property (nonatomic) NSInteger oldGraphViewWidthConstraint;


@property (readwrite, nonatomic) NSInteger totalCalories;
@property (readwrite, nonatomic) NSInteger averageHeartRate;
@property (readwrite, nonatomic) NSInteger minHeartRate;
@property (readwrite, nonatomic) NSInteger maxHeartRate;
@property (readwrite, nonatomic) NSInteger totalSteps;
@property (readwrite, nonatomic) CGFloat   totalDistance;

//@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalWorkoutTimeHours;
@property (weak, nonatomic) IBOutlet UILabel *totalWorkoutTimeMinutes;
@property (weak, nonatomic) IBOutlet UILabel *totalWorkoutTimeSeconds;
@property (weak, nonatomic) IBOutlet UILabel *hrLabel;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *secLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *workoutStartTime;
@property (weak, nonatomic) IBOutlet UILabel *workoutEndTime;
@property (weak, nonatomic) IBOutlet UILabel *workoutStartTimeBig;
@property (weak, nonatomic) IBOutlet UILabel *workoutEndTimeBig;
@property (weak, nonatomic) IBOutlet UIView *graphDisplayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphBackgroundHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphDisplayViewHeight;
@property (weak, nonatomic) IBOutlet UIView *workoutGraphView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statsLeftConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statsTopConst;

// Ranges
@property (strong, nonatomic) NSNumber *caloriesMaxY;
@property (strong, nonatomic) NSNumber *heartRateMaxY;
@property (strong, nonatomic) NSNumber *stepsMaxY;
@property (strong, nonatomic) NSNumber *distanceMaxY;

// Data
@property (strong, nonatomic) NSArray *calories;
@property (strong, nonatomic) NSArray *heartRate;
@property (strong, nonatomic) NSArray *steps;
@property (strong, nonatomic) NSArray *distance;
@property (strong, nonatomic) NSArray *calorieDataPoint;
@property (strong, nonatomic) NSArray *heartRateDataPoint;
@property (strong, nonatomic) NSArray *stepsDataPoint;
@property (strong, nonatomic) NSArray *distanceDataPoint;

@property (assign, nonatomic) NSInteger barPlotCount;

@property (strong, nonatomic) NSArray *dataPoints;

@property (strong, nonatomic) NSArray *workouts;
@property (strong, nonatomic) SalutronUserProfile *userProfile;

//@property (strong, nonatomic) NSDate *date;


@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *workoutTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *hrContainer;
@property (weak, nonatomic) IBOutlet UIView *wOContainer;
@property (weak, nonatomic) IBOutlet UILabel *maxHRValue;
@property (weak, nonatomic) IBOutlet UILabel *minHRValue;
@property (weak, nonatomic) IBOutlet UILabel *maxHRLabel;
@property (weak, nonatomic) IBOutlet UILabel *minHRLabel;


@property (weak, nonatomic) IBOutlet UIView *overlay1;
@property (weak, nonatomic) IBOutlet UIView *overlay2;
@property (weak, nonatomic) IBOutlet UIView *overlay3;
@property (weak, nonatomic) IBOutlet UIView *overlay4;
@property (weak, nonatomic) IBOutlet UIView *overlay5;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@property (weak, nonatomic) IBOutlet UIView *loadingView;



@end

@implementation SFAR420WorkoutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userProfile = [SalutronUserProfile getData];
    self.isPortrait = YES;
    
    self.labelActiveTime.hidden = self.isPortrait;
    self.imagePlayHead.hidden   = self.isPortrait;
    self.navigationItem.title = LS_WORKOUT;
    [self configureOverlayView];
    
    
    CGRect viewFrame = [UIScreen mainScreen].bounds;
    if (self.isPortrait) {
        if (self.isIOS8AndAbove) {
            self.workoutGraphView.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height-124);
        }
        else{
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                self.workoutGraphView.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height-124);
            }
            else{
                self.workoutGraphView.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height-124);
                self.statsHeight.constant = 150;
                self.statsLeftConst.constant = 0;
                self.statsTopConst.constant = 0;
            }
            
        }
    }
    else{
        if (self.isIOS8AndAbove) {
            self.workoutGraphView.frame = CGRectMake(0, 0, viewFrame.size.height, viewFrame.size.width);
        }
        else{
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                
            }
            else{
                self.workoutGraphView.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.width);
                
                self.statsHeight.constant = 75;
                self.statsLeftConst.constant = viewFrame.size.width/2;
                self.statsTopConst.constant = -75;
            }
        }
    }
    /*
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        self.graphContainerHeight.constant = 162;
        self.graphBackgroundHeight.constant = 210;
        self.graphDisplayViewHeight.constant = 188;
        self.workoutGraphView.frame = CGRectMake(self.workoutGraphView.frame.origin.x, self.workoutGraphView.frame.origin.y, self.workoutGraphView.frame.size.width, 300);
    }
    else {
        self.graphContainerHeight.constant = 442;
        self.graphBackgroundHeight.constant = 490;
        self.graphDisplayViewHeight.constant = 458;
        self.workoutGraphView.frame = CGRectMake(self.workoutGraphView.frame.origin.x, self.workoutGraphView.frame.origin.y, self.workoutGraphView.frame.size.width, 552);
    }
     */
    [self addGraphType:SFAGraphTypeCalories];
    [self addGraphType:SFAGraphTypeDistance];
    [self addGraphType:SFAGraphTypeSteps];
    //[self addGraphType:SFAGraphTypeHeartRate];
    [self.hrGraphViewController addGraphType:SFAGraphTypeCalories];
    [self selectGraphType:SFAGraphTypeHeartRate];
    
    //[self setContentsWithDate:self.date workoutIndex:0];
    //self.date = date;
    self.hrGraphViewController.loadingView.hidden = NO;
    if (self.isIOS8AndAbove) {
        if (!self.isIOS9AndAbove) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.hrGraphViewController.loadingView.hidden = NO;
            });
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getDataForDate:self.date];
            [self setDataForDate:self.date workoutIndex:0];
        });
    }
    else{
        [self getDataForDate:self.date];
        [self setDataForDate:self.date workoutIndex:0];
    }
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self toggleStartEndTimeViews];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd yyyy"];
    
    //NSString *selectedDate = [dateFormatter stringFromDate:self.date];
    //self.dateLabel.text = selectedDate;
    
    //highlight first table view cell, since that is the graph that is being shown
    /*
    SFAWorkoutInfoCell *cell = (SFAWorkoutInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell setSelected:YES];
    
    self.workoutIndex = 0;
     */
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.overlayView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:WORKOUT_GRAPH_SEGUE_IDENTIFIER])
    {
        self.graphViewController = (SFAR420WorkoutGraphViewController *)segue.destinationViewController;
        self.graphViewController.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:HR_WORKOUT_GRAPH_SEGUE_IDENTIFIER])
    {
        self.hrGraphViewController = (SFAR420HRWorkoutGraphViewController *)segue.destinationViewController;
        self.hrGraphViewController.delegate = self;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //self.loadingView.hidden = NO;
    self.isPortrait = (toInterfaceOrientation == UIInterfaceOrientationPortrait); //set isPortrait value
    
    CGRect viewFrame = [UIScreen mainScreen].bounds;
    if (self.isPortrait) {
        if (self.isIOS8AndAbove) {
            self.workoutGraphView.frame = CGRectMake(0, 0, viewFrame.size.height, viewFrame.size.width-124);
        }
        else{
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                self.workoutGraphView.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height-124);
            }
            else{
                self.workoutGraphView.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height-124);
                self.statsHeight.constant = 150;
                self.statsLeftConst.constant = 0;
                self.statsTopConst.constant = 0;
            }
        }
    }
    else{
        if (self.isIOS8AndAbove) {
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                self.workoutGraphView.frame = CGRectMake(0, 0, viewFrame.size.height, viewFrame.size.width-24);
            }
            else{
                self.workoutGraphView.frame = CGRectMake(0, 0, viewFrame.size.height, viewFrame.size.width);
            }
        }
        else{
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                self.workoutGraphView.frame = CGRectMake(0, 0, viewFrame.size.height, viewFrame.size.width-24);
            }
            else{
                self.workoutGraphView.frame = CGRectMake(0, 0, viewFrame.size.height, viewFrame.size.width-24);
                self.statsHeight.constant = 75;
                self.statsLeftConst.constant = viewFrame.size.height*(0.4);
                self.statsTopConst.constant = -75;
            }
            
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.tableView.scrollEnabled = (fromInterfaceOrientation != UIInterfaceOrientationPortrait);
    self.tableView.contentOffset = CGPointZero;
    self.labelActiveTime.text = @"";
    
    //self.loadingView.hidden = YES;
    [self _toggleObjectsWithInterfaceOrientation];
}


#pragma mark - property
- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext)
    {
        SFASalutronFitnessAppDelegate *appDelegate  = [UIApplication sharedApplication].delegate;
        _managedObjectContext                       = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (void)setWorkoutIndex:(NSUInteger)workoutIndex {
    //save workout index for toggling landscape and portrait views
    _workoutIndex = workoutIndex;
    self.hrGraphViewController.loadingView.hidden = NO;
    if (self.isIOS8AndAbove) {
        if (self.isIOS9AndAbove) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.hrGraphViewController.loadingView.hidden = NO;
            });
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self setDataForDate:self.date workoutIndex:_workoutIndex];
        });
    }
    else{
        [self setDataForDate:self.date workoutIndex:_workoutIndex];
    }
    
}

- (NSInteger)barPlotCount
{
    return self.graphViewController.visiblePlots.count > 0 ? self.graphViewController.visiblePlots.count : 1;
}

#pragma mark - Public Methods

- (void)setContentsWithDate:(NSDate *)date workoutIndex:(NSInteger)index
{
    self.date = date;
    [self getDataForDate:date];
    [self setDataForDate:date workoutIndex:index];
}

- (void)addGraphType:(SFAGraphType)graphType
{
    [self selectGraphType:graphType];
    [self.graphViewController addGraphType:graphType];
}

- (void)removeGraphType:(SFAGraphType)graphType
{
    [self deselectGraphType:graphType];
    [self.graphViewController removeGraphType:graphType];
}

- (void)resetScrollViewOffset
{
    [self.graphViewController resetScrollViewOffset];
    self.tableView.contentOffset = CGPointZero;
}

#pragma mark - Private instance methods

- (void)toggleStartEndTimeViews
{
    TimeDate *timeDate = [TimeDate getData];
    if (timeDate.hourFormat == _12_HOUR){
        //self.startTimeConstraint.constant = 90.0f;
        //self.endTimeConstraint.constant = 90.0f;
        
    }else{
        //self.startTimeConstraint.constant = 131.0f;
        //self.endTimeConstraint.constant = 131.0f;
        
    }
    //self.workoutStartTime.font = [UIFont systemFontOfSize:16.0f];
    //self.workoutEndTime.font = [UIFont systemFontOfSize:16.0f];
}

- (void)getDataForDate:(NSDate *)date
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
    
    self.dataPoints = [StatisticalDataPointEntity dataPointsForDate:date];
    
    if (data.count > 0){
        self.workouts = data;
    }else{
        self.workouts = @[];
    }
    if (self.isIOS9AndAbove) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    else{
        [self.tableView reloadData];
    }
    
}

- (void)setDataForDate:(NSDate *)date workoutIndex:(NSInteger)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
    if (self.workouts.count == 0){
        [self showNoDataOnGraph];
        self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", 0];
        self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", 0];
        self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", 0];
        self.hrLabel.text = @"min";
        self.minLabel.text = @"sec";
        self.secLabel.text = @"hund";
        return;
    }
    
    WorkoutHeaderEntity *workout = [self.workouts objectAtIndex:index];
    //DDLogInfo(@"workout.workoutHeartRateData.count = %i", workout.workoutHeartRateData.count);
    //DDLogInfo(@"workout.workoutHeartRateData = %i", workout.workoutHeartRateData);
    if (workout){
        if (self.isPortrait) {
            self.workoutTimeLabel.text = [NSString stringWithFormat:LS_WORKOUT_TIME_VARIABLE,index+1];
        }
        else{
            self.workoutTimeLabel.text = LS_TOTAL_WORKOUT_TIME_VARIABLE;
        }
        if (self.isPortrait) {
            self.totalCalories      = workout.calories.integerValue;
            self.totalDistance      = workout.distance.floatValue;
            self.totalSteps         = workout.steps.integerValue;
            self.averageHeartRate   = workout.averageBPM.integerValue;
            self.minHeartRate       = workout.minimumBPM.integerValue;
            self.maxHeartRate       = workout.maximumBPM.integerValue;
        }
        else{
            self.totalCalories      = 0;
            self.totalDistance      = 0;
            self.totalSteps         = 0;
            self.averageHeartRate   = 0;
            self.minHeartRate       = 0;
            self.maxHeartRate       = 0;
        }
        if ([workout checkIfSpillOverWorkoutForDate:date]){
            NSInteger workoutYesterdaySeconds = [workout spillOverWorkoutSeconds];
            if (workoutYesterdaySeconds/3600 < 1) {
                self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", (workoutYesterdaySeconds%3600)/60];
                self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", workoutYesterdaySeconds%60];
                self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", [workout spillOverWorkoutHundredths]%100];
                self.hrLabel.text = @"min";
                self.minLabel.text = @"sec";
                self.secLabel.text = @"hund";
            }
            else{
                self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", workoutYesterdaySeconds/3600];
                self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", (workoutYesterdaySeconds%3600)/60];
                self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", workoutYesterdaySeconds%60];
                self.hrLabel.text = @"hr";
                self.minLabel.text = @"min";
                self.secLabel.text = @"sec";
            }
        }else{
            if ([workout hasSpillOverWorkoutSeconds]){
                NSInteger workoutTodaySeconds = [workout workoutDurationSecondsForThatDay];
                if (workoutTodaySeconds/3600 < 1) {
                    self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", (workoutTodaySeconds%3600)/60];
                    self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", workoutTodaySeconds%60];
                    self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", [workout workoutDurationHundredthsForThatDay]%100];
                    self.hrLabel.text = @"min";
                    self.minLabel.text = @"sec";
                    self.secLabel.text = @"hund";
                }
                else{
                    self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", workoutTodaySeconds/3600];
                    self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", (workoutTodaySeconds%3600)/60];
                    self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", workoutTodaySeconds%60];
                    self.hrLabel.text = @"hr";
                    self.minLabel.text = @"min";
                    self.secLabel.text = @"sec";
                }
                
            }else{
                if (workout.hour.integerValue < 1) {
                    self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", workout.minute.integerValue];
                    self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", workout.second.integerValue];
                    self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", workout.hundredths.integerValue];
                    self.hrLabel.text = @"min";
                    self.minLabel.text = @"sec";
                    self.secLabel.text = @"hund";
                }
                else{
                    self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", workout.hour.integerValue];
                    self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", workout.minute.integerValue];
                    self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", workout.second.integerValue];
                    self.hrLabel.text = @"hr";
                    self.minLabel.text = @"min";
                    self.secLabel.text = @"sec";
                }
            }
        }
        
        
        TimeDate *timeDate = [TimeDate getData];
        
        
        //        NSInteger workoutMinutes =(workout.stampMinute.integerValue + workout.minute.integerValue);
        //        NSInteger endMinute = workoutMinutes%60;
        //        NSInteger endHour = (workout.stampHour.integerValue + workout.hour.integerValue + workoutMinutes/60)%24;
        
        NSString *startTime = [self formatTimeWithHourFormat:timeDate.hourFormat
                                                        hour:workout.stampHour.integerValue
                                                      minute:workout.stampMinute.integerValue
                                                      second:workout.stampSecond.integerValue];
        //        NSString *endTime   = [self formatTimeWithHourFormat:timeDate.hourFormat
        //                                                        hour:endHour
        //                                                      minute:endMinute];
        
        if (timeDate.hourFormat == _24_HOUR) {
            startTime = [startTime removeTimeHourFormat];
        }
        
        if ([workout checkIfSpillOverWorkoutForDate:date]){
            NSString *startTime = [self formatTimeWithHourFormat:timeDate.hourFormat
                                                            hour:0
                                                          minute:0
                                                          second:0];
            self.workoutStartTime.text = startTime;
            self.workoutStartTimeBig.text = startTime;
        }else{
            self.workoutStartTime.text = startTime;
            self.workoutStartTimeBig.text = startTime;
        }
        
        //        self.workoutEndTime.text = [self removeTimeHourFormat:endTime];
        
        self.labelCalories.text     = self.caloriesButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalCalories] : @"...";
        self.labelSteps.text        = self.stepsButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalSteps] : @"...";
        self.labelMiles.text        = self.distanceButton.isSelected ? [self formatDistance:self.totalDistance] : @"...";
        self.labelHeartRate.text        = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.averageHeartRate] : @"...";
        self.minHRValue.text        = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.minHeartRate] : @"...";
        self.maxHRValue.text        = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.maxHeartRate] : @"...";

        
    }else{
        [self showNoDataOnGraph];
    }
    [self.tableView reloadData];
    [self.graphViewController setContentsWithDate:date workoutIndex:index];
});

    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //self.hrGraphViewController.loadingView.hidden = NO;
    //if (self.isPortrait) {
    [self.hrGraphViewController setContentsWithDate:date workoutIndex:index];
    //}
    //else{
    //    if ([date isEqual:self.calendarController.selectedDate]) {
    //       [self.hrGraphViewController setContentsWithDate:date workoutIndex:index];
    //    }
    //}
    //});

}

- (void)showNoDataOnGraph
{
    
    self.workoutTimeLabel.text = [NSString stringWithFormat:LS_WORKOUT_TIME];
    self.totalCalories = 0;
    self.averageHeartRate = 0;
    self.minHeartRate = 0;
    self.maxHeartRate = 0;
    self.totalDistance = 0;
    self.totalSteps = 0;
    
    self.calories  = nil;
    self.heartRate = nil;
    self.steps     = nil;
    self.distance  = nil;
    
    self.startPoint = 0;
    self.endPoint   = 0;
    
    self.totalWorkoutTimeHours.text = @"0";
    self.totalWorkoutTimeMinutes.text = @"0";
    self.totalWorkoutTimeSeconds.text = @"0";
    self.workoutStartTime.text = @"00:00:00";
    self.workoutStartTimeBig.text = @"00:00:00";
    self.workoutEndTime.text = @"00:00:00";
    self.workoutEndTimeBig.text = @"00:00:00";
    
    self.labelCalories.text     = self.caloriesButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalCalories] : @"...";
    self.labelSteps.text        = self.stepsButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalSteps] : @"...";
    self.labelMiles.text        = self.distanceButton.isSelected ? [NSString stringWithFormat:@"%.2f", self.totalDistance] : @"...";
    self.labelHeartRate.text        = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.averageHeartRate] : @"...";
    self.minHRValue.text        = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.minHeartRate] : @"...";
    self.maxHRValue.text        = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.maxHeartRate] : @"...";
}

- (NSString *)removeTimeHourFormat:(NSString *)time
{
    return [[time stringByReplacingOccurrencesOfString:LS_AM withString:@""] stringByReplacingOccurrencesOfString:LS_PM withString:@""];
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

- (NSString *)formatDistance:(CGFloat)distance
{
    NSString *temp;
    if (self.userProfile.unit == IMPERIAL) {
        if (!self.isPortrait) {
            temp = [NSString stringWithFormat:@"%.2f mi", (distance * 0.621371)];
        }
        else{
            temp = [NSString stringWithFormat:@"%.2f mi", (distance * 0.621371)];
        }
    }
    else {
        if (!self.isPortrait) {
            temp = [NSString stringWithFormat:@"%.2f km", distance];
        }
        else{
            temp = [NSString stringWithFormat:@"%.2f km", distance];
        }
    }
    return temp;
}

- (void)_toggleObjectsWithInterfaceOrientation
{
    
    self.imagePlayHead.hidden   = self.isPortrait;
    self.labelActiveTime.hidden = self.isPortrait;
    
    self.startLabel.hidden = !self.isPortrait;
    self.workoutStartTime.hidden = !self.isPortrait;
    self.workoutStartTimeBig.hidden = !self.isPortrait;
    self.workoutEndTime.hidden = !self.isPortrait;
    self.workoutEndTimeBig.hidden = !self.isPortrait;
    self.endLabel.hidden = !self.isPortrait;
    
    if (!self.isPortrait){
        self.workoutTimeLabel.text = LS_TOTAL_WORKOUT_TIME_VARIABLE;//LS_WORKOUT_TIME;
        
    }else{
        self.workoutTimeLabel.text = [NSString stringWithFormat:LS_WORKOUT_TIME_VARIABLE,self.workoutIndex+1];
        //self.workoutMetricConstraints.constant = 2;
        }
    self.labelMiles.text        = self.distanceButton.isSelected ? [self formatDistance:self.totalDistance] : @"...";
    
    //if (self.isPortrait) {
    
    self.hrGraphViewController.loadingView.hidden = NO;
    
    if (self.isIOS8AndAbove) {
        if (self.isIOS9AndAbove) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.hrGraphViewController.loadingView.hidden = NO;
            });
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self setDataForDate:self.date workoutIndex:_workoutIndex];
        });
    }
    else{
        [self setDataForDate:self.date workoutIndex:_workoutIndex];
    }
    //}
    //else{
    //    if ([self.date isEqual:self.calendarController.selectedDate]) {
    //        [self setDataForDate:self.date workoutIndex:_workoutIndex];
    //    }
    //}
    
}

- (void)selectGraphType:(SFAGraphType)graphType
{
    UIButton *button        = [self buttonForGraphType:graphType];
    UIImage *image          = [self imageForGraphType:graphType];
    button.selected         = !button.selected;
    
    [button setImage:image forState:UIControlStateNormal];
    
    self.labelCalories.text     = self.caloriesButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalCalories] : @"...";
    self.labelSteps.text        = self.stepsButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalSteps] : @"...";
    self.labelMiles.text        = self.distanceButton.isSelected ? [self formatDistance:self.totalDistance] : @"...";
    self.labelHeartRate.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.averageHeartRate] : @"...";
    self.minHRValue.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.minHeartRate] : @"...";
    self.maxHRValue.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.maxHeartRate] : @"...";
}

- (void)deselectGraphType:(SFAGraphType)graphType
{
    UIButton *button        = [self buttonForGraphType:graphType];
    button.selected         = !button.selected;
    
    [button setImage:INACTIVE_IMAGE forState:UIControlStateNormal];
    
    
    self.labelCalories.text     = self.caloriesButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalCalories] : @"...";
    self.labelHeartRate.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.averageHeartRate] : @"...";
    self.minHRValue.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.minHeartRate] : @"...";
    self.maxHRValue.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.maxHeartRate] : @"...";
    self.labelSteps.text        = self.stepsButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalSteps] : @"...";
    self.labelMiles.text        = self.distanceButton.isSelected ? [self formatDistance:self.totalDistance] : @"...";
}

- (UIButton *)buttonForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return self.caloriesButton;
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        return self.heartRateButton;
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        return self.distanceButton;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        return self.stepsButton;
    }
    
    return nil;
}

- (UIImage *)imageForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return CALORIES_ACTIVE_IMAGE;
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        return HEART_RATE_ACTIVE_IMAGE;
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        return DISTANCE_ACTIVE_IMAGE;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        return STEPS_ACTIVE_IMAGE;
    }
    
    return nil;
}

#pragma mark - IBAction Methods

- (IBAction)caloriesButtonPressed:(id)sender
{
    UIButton *button = sender;
    
    if (button.selected)
    {
        if (self.barPlotCount > 1)
        {
            [self removeGraphType:SFAGraphTypeCalories];
            
            if ([self.delegate conformsToProtocol:@protocol(SFAR420WorkoutViewControllerDelegate)])
            {
                [self.delegate workoutResultsViewController:self didRemoveGraphType:SFAGraphTypeCalories];
            }
        }
    }
    else
    {
        [self addGraphType:SFAGraphTypeCalories];
        
        if ([self.delegate conformsToProtocol:@protocol(SFAR420WorkoutViewControllerDelegate)])
        {
            [self.delegate workoutResultsViewController:self didAddGraphType:SFAGraphTypeCalories];
        }
    }
}

- (IBAction)heartRateButtonPressed:(id)sender
{
    UIButton *button = sender;
    
    if (button.selected)
    {
        if (self.barPlotCount > 1)
        {
            [self removeGraphType:SFAGraphTypeHeartRate];
            
            if ([self.delegate conformsToProtocol:@protocol(SFAR420WorkoutViewControllerDelegate)])
            {
                [self.delegate workoutResultsViewController:self didRemoveGraphType:SFAGraphTypeHeartRate];
            }
        }
    }
    else
    {
        [self addGraphType:SFAGraphTypeHeartRate];
        
        if ([self.delegate conformsToProtocol:@protocol(SFAR420WorkoutViewControllerDelegate)])
        {
            [self.delegate workoutResultsViewController:self didAddGraphType:SFAGraphTypeHeartRate];
        }
    }
}

- (IBAction)stepsButtonPressed:(id)sender
{
    UIButton *button = sender;
    
    if (button.selected)
    {
        if (self.barPlotCount > 1)
        {
            [self removeGraphType:SFAGraphTypeSteps];
            
            if ([self.delegate conformsToProtocol:@protocol(SFAR420WorkoutViewControllerDelegate)])
            {
                [self.delegate workoutResultsViewController:self didRemoveGraphType:SFAGraphTypeSteps];
            }
        }
    }
    else
    {
        [self addGraphType:SFAGraphTypeSteps];
        
        if ([self.delegate conformsToProtocol:@protocol(SFAR420WorkoutViewControllerDelegate)])
        {
            [self.delegate workoutResultsViewController:self didAddGraphType:SFAGraphTypeSteps];
        }
    }
}

- (IBAction)distanceButtonPressed:(id)sender
{
    UIButton *button = sender;
    
    if (button.selected)
    {
        if (self.barPlotCount > 1)
        {
            [self removeGraphType:SFAGraphTypeDistance];
            
            if ([self.delegate conformsToProtocol:@protocol(SFAR420WorkoutViewControllerDelegate)])
            {
                [self.delegate workoutResultsViewController:self didRemoveGraphType:SFAGraphTypeDistance];
            }
        }
    }
    else
    {
        [self addGraphType:SFAGraphTypeDistance];
        
        if ([self.delegate conformsToProtocol:@protocol(SFAR420WorkoutViewControllerDelegate)])
        {
            [self.delegate workoutResultsViewController:self didAddGraphType:SFAGraphTypeDistance];
        }
    }
}



#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isPortrait) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.workouts.count == 0) {
            tableView.separatorColor = [UIColor whiteColor];
        }
        else {
            tableView.separatorColor = PERCENT_0_COLOR;
        }
        
        return self.workouts.count;
    }
    return 0;
}

#pragma mark - table view delegate
/*
 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
 {
 if (section == 0) {
 return [tableView dequeueReusableCellWithIdentifier:WORKOUT_LOGS_HEADER_CELL_IDENTIFIER];
 }
 
 return nil;
 }
 */
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"";//LS_WORKOUT;
    }
    return @"";
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SFAWorkoutInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:WORKOUT_LOGS_CELL_IDENTIFIER];
        
        if ([self.workouts objectAtIndex:indexPath.row]){
            cell.date = self.date;
            [cell setContentsWithWorkoutHeader:self.workouts[indexPath.row] workoutIndex:indexPath.row];
            DDLogInfo(@"self.workouts[indexPath.row] = %@", self.workouts[indexPath.row]);
        }
        return cell;
    }
    
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //remove programmatic highlight of the first table view cell
    SFAWorkoutInfoCell *firstCell = (SFAWorkoutInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    firstCell.selected = indexPath.row == 0 ? YES : NO;
    //
    //    cell = (SFAWorkoutInfoCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    //    cell.selected = YES;
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //    self.hrGraphViewController.loadingView.hidden = NO;
        [self setWorkoutIndex:indexPath.row];
    
    
    //scroll to top
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, -self.tableView.contentInset.top) animated:YES];
    //});
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - sfaworkoutgraphview delegate

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeDataPoint:(NSInteger)index
{
    StatisticalDataPointEntity *dataPoint;
    //-1 index is for workout stop
    if (index < self.dataPoints.count && index > 0){
        dataPoint = [self.dataPoints objectAtIndex:index];
        
        NSString *time = [self.calendarController timeForIndex:index];
        self.labelActiveTime.text = time;
    }else{
        NSString *time = [self.calendarController timeForIndex:-index];
        self.labelActiveTime.text = time;
    }
    
    self.totalCalories = dataPoint != nil? dataPoint.calorie.integerValue : 0;
    //self.averageHeartRate = dataPoint != nil? dataPoint.averageHR.integerValue : 0;
    self.totalSteps = dataPoint != nil? dataPoint.steps.integerValue : 0;
    self.totalDistance = dataPoint != nil? dataPoint.distance.floatValue : 0.0f;
    //self.minHeartRate = [self minHeartRateForIndex:index];
    //self.maxHeartRate = [self maxHeartRateForIndex:index];
    
    self.labelCalories.text     = self.caloriesButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalCalories] : @"...";
    self.labelHeartRate.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.averageHeartRate] : @"...";
    self.minHRValue.text = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.minHeartRate] : @"...";
    self.maxHRValue.text = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.maxHeartRate] : @"...";
    self.labelSteps.text        = self.stepsButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalSteps] : @"...";
    self.labelMiles.text        = self.distanceButton.isSelected ? [self formatDistance:self.totalDistance] : @"...";
}

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeTotalWorkoutTime:(NSInteger)workoutSeconds
{
    //no longer seconds but hundredths
    self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", (workoutSeconds/100)/3600];
    self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", ((workoutSeconds/100)%3600)/60];
    self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", (workoutSeconds/100)%60];
    if ((workoutSeconds/100)/3600 < 1) {
        self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", ((workoutSeconds/100)%3600)/60];
        self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", (workoutSeconds/100)%60];
        self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", workoutSeconds%100];
        self.hrLabel.text = @"min";
        self.minLabel.text = @"sec";
        self.secLabel.text = @"hund";
    }
    else{
        self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", (workoutSeconds/100)/3600];
        self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", ((workoutSeconds/100)%3600)/60];
        self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", (workoutSeconds/100)%60];
        self.hrLabel.text = @"hr";
        self.minLabel.text = @"min";
        self.secLabel.text = @"sec";
    }
}

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeWorkoutEndTime:(NSString *)time
{
    self.workoutEndTime.text = time;
    self.workoutEndTimeBig.text = time;
}

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeTime:(NSString *)time
{
    
}

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeCalories:(NSInteger)calories
{
    self.totalCalories = calories;
    self.labelCalories.text     = self.caloriesButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalCalories] : @"...";
}

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeHeartRate:(NSInteger)heartRate
{
    if (!self.isPortrait) {
        self.averageHeartRate = heartRate;
        self.labelHeartRate.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.averageHeartRate] : @"...";
    }
}

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeMinHeartRate:(NSInteger)heartRate
{
    //self.minHeartRate = heartRate;
    //self.maxHRValue.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.minHeartRate] : @"...";
}

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeMaxHeartRate:(NSInteger)heartRate
{
    //self.maxHeartRate = heartRate;
    //self.maxHRValue.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.maxHeartRate] : @"...";
}
- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeSteps:(NSInteger)steps
{
    self.totalSteps = steps;
    self.labelSteps.text        = self.stepsButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalSteps] : @"...";
}

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeDistance:(CGFloat)distance
{
    self.totalDistance = distance;
    self.labelMiles.text        = self.distanceButton.isSelected ? [self formatDistance:self.totalDistance] : @"...";
}
- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didScroll:(CGPoint)offSet{
    [self.hrGraphViewController.scrollView setContentOffset:offSet];
    //self.hrGraphViewController.delegate = nil;
    //self.overlayView.hidden = NO;
}

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didEndScroll:(CGPoint)offSet{
    //self.overlayView.hidden = YES;
}

- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didScroll:(CGPoint)offset{
    [self.graphViewController.scrollView setContentOffset:offset];
    //self.graphViewController.delegate = nil;
    //self.overlayView.hidden = NO;
}

- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didEndScroll:(CGPoint)offSet{
    //self.overlayView.hidden = YES;
}

- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didChangeHeartRate:(NSInteger)heartRate{
    if(!self.isPortrait){
    self.averageHeartRate = heartRate;
    self.labelHeartRate.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.averageHeartRate] : @"...";
    }
}

- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didChangeMinHeartRate:(NSInteger)heartRate{
    if(!self.isPortrait){
        self.minHeartRate = heartRate;
        self.minHRValue.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.minHeartRate] : @"...";
    }
}

- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didChangeMaxHeartRate:(NSInteger)heartRate{
    if(!self.isPortrait){
        self.maxHeartRate = heartRate;
        self.maxHRValue.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.maxHeartRate] : @"...";
    }
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
    
    //[self.graphViewController.scrollView setMultipleTouchEnabled:YES];
    /*
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOverlay:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    tapRecognizer.delegate = self;
    [self.graphViewController.scrollView addGestureRecognizer:tapRecognizer];
    */
    /*
    UIPanGestureRecognizer *tap = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(showOverlay:)];
    [self.graphViewController.scrollView setMultipleTouchEnabled:YES];
    [self.graphViewController.scrollView setUserInteractionEnabled:YES];
    self.graphViewController.scrollView.gestureRecognizers = @[tap];
    */
    
}
/*
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    DDLogInfo(@"TOUCHED!");
}*/
/*
- (void)showOverlay:(UITapGestureRecognizer *)tapRecognizer{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        self.overlayView.hidden = YES;
    }
    else{
        self.overlayView.hidden = NO;
    }
    
}
*/
/*
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    self.overlayView.hidden = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    self.overlayView.hidden = YES;
}
*/

- (NSInteger)minHeartRateForIndex:(NSInteger)index{
    index = labs(index);
    int minHeartRate = 0;
    for(WorkoutHeaderEntity *workoutHeader in self.workouts){
        int startIndex = [self getWorkoutStartForWorkout:workoutHeader];
        int endIndex = [self getWorkoutEndForWorkout:workoutHeader];
        if (index >= startIndex && index <= endIndex) {
            minHeartRate = workoutHeader.minimumBPM.integerValue;
            break;
        }
    }
    return minHeartRate;
}

- (NSInteger)maxHeartRateForIndex:(NSInteger)index{
    index = labs(index);
    int maxHeartRate = 0;
    for(WorkoutHeaderEntity *workoutHeader in self.workouts){
        NSInteger startIndex = [self getWorkoutStartForWorkout:workoutHeader];
        NSInteger endIndex = [self getWorkoutEndForWorkout:workoutHeader];
        if (index >= startIndex && index <= endIndex) {
            maxHeartRate = workoutHeader.maximumBPM.integerValue;
            break;
        }
    }
    return maxHeartRate;
}


- (NSInteger)getWorkoutStartForWorkout:(WorkoutHeaderEntity *)workout{
    return lround((workout.stampHour.integerValue*60 + workout.stampMinute.integerValue)/10);
}

- (NSInteger)getWorkoutEndForWorkout:(WorkoutHeaderEntity *)workout{
    return [self getWorkoutStartForWorkout:workout] + lround((workout.hour.integerValue*60 + workout.minute.integerValue)/10);
}

- (void)graphViewControllerTouchStarted{
    self.overlayView.hidden = NO;
}
- (void)graphViewControllerTouchEnded{
    self.overlayView.hidden = YES;
}

- (void)hrgraphViewControllerTouchStarted{
    self.overlayView.hidden = NO;
}
- (void)hrgraphViewControllerTouchEnded{
    self.overlayView.hidden = YES;
}

@end
