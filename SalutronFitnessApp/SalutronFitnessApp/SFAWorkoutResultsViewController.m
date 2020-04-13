//
//  SFAWorkoutResultsViewController.m
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/6/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronFitnessAppDelegate.h"

#import "SFAWorkoutResultsViewController.h"
#import "SFAMainViewController.h"
#import "SFAWorkoutGraphViewController.h"

#import "SFAGraphView.h"
#import "SFAGraph.h"
#import "SFAGraphTools.h"
#import "SFAXYPlotSpace.h"
#import "SFABarPlot.h"
#import "SFABarPlot+Type.h"
#import "CPTGraph+Label.h"

#import "StatisticalDataHeaderEntity.h"
#import "StatisticalDataPointEntity.h"
#import "StatisticalDataPointEntity+Data.h"
#import "DateEntity.h"
#import "TimeEntity.h"
#import "WorkoutInfoEntity+Data.h"
#import "NSString+Helper.h"

#import "SFAWorkoutInfoCell.h"
#import "TimeDate+Data.h"


#import "SalutronUserProfile+Data.h"


#define WORKOUT_GRAPH_SEGUE_IDENTIFIER @"WorkoutGraph"

#define WORKOUT_LOGS_HEADER_CELL_IDENTIFIER @"WorkoutsHeaderCell"
#define WORKOUT_LOGS_CELL_IDENTIFIER @"WorkoutDataCell"

#define CALORIES_ACTIVE_IMAGE   [UIImage imageNamed:@"ll_workout_toggle_icon_calorie"]
#define HEART_RATE_ACTIVE_IMAGE [UIImage imageNamed:@"ll_workout_toggle_icon_heart"]
#define STEPS_ACTIVE_IMAGE      [UIImage imageNamed:@"ll_workout_toggle_icon_steps"]
#define DISTANCE_ACTIVE_IMAGE   [UIImage imageNamed:@"ll_workout_toggle_icon_distance"]
#define INACTIVE_IMAGE          [UIImage imageNamed:@"ll_workout_toggle_icon_inactive"]


@interface SFAWorkoutResultsViewController () < UITableViewDataSource, UITableViewDelegate, SFAWorkoutGraphViewControllerDelegate>

// Core Data
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) SFAWorkoutGraphViewController *graphViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endTimeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startTimeConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *workoutMetricConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *workoutMetricBottomConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusTopConstaint;


@property (readwrite, nonatomic) NSInteger startPoint;
@property (readwrite, nonatomic) NSInteger endPoint;

@property (nonatomic) NSInteger oldGraphViewWidthConstraint;


@property (readwrite, nonatomic) NSInteger totalCalories;
@property (readwrite, nonatomic) NSInteger averageHeartRate;
@property (readwrite, nonatomic) NSInteger totalSteps;
@property (readwrite, nonatomic) CGFloat   totalDistance;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalWorkoutTimeHours;
@property (weak, nonatomic) IBOutlet UILabel *totalWorkoutTimeMinutes;
@property (weak, nonatomic) IBOutlet UILabel *totalWorkoutTimeSeconds;
@property (weak, nonatomic) IBOutlet UILabel *hrLabel;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *secLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *workoutStartTime;
@property (weak, nonatomic) IBOutlet UILabel *workoutEndTime;
@property (weak, nonatomic) IBOutlet UIView *graphDisplayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphBackgroundHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphDisplayViewHeight;
@property (weak, nonatomic) IBOutlet UIView *workoutGraphView;

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

@property (strong, nonatomic) NSDate *date;


@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *workoutTimeLabel;



@end

@implementation SFAWorkoutResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.userProfile = [SalutronUserProfile getData];
    self.isPortrait = YES;
    self.workoutIndex = 0;
    
    self.navigationItem.title = LS_WORKOUT;

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
    [self configureFitnessButtons];
    [self addGraphType:SFAGraphTypeCalories];
    [self addGraphType:SFAGraphTypeDistance];
    [self addGraphType:SFAGraphTypeHeartRate];
    [self addGraphType:SFAGraphTypeSteps];
}

- (void)configureFitnessButtons{
    self.caloriesButton.titleLabel.numberOfLines = 1;
    self.caloriesButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.caloriesButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    self.heartRateButton.titleLabel.numberOfLines = 1;
    self.heartRateButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.heartRateButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    self.distanceButton.titleLabel.numberOfLines = 1;
    self.distanceButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.distanceButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    self.stepsButton.titleLabel.numberOfLines = 1;
    self.stepsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.stepsButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self toggleStartEndTimeViews];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd yyyy"];
    
    NSString *selectedDate = [dateFormatter stringFromDate:self.date];
    self.dateLabel.text = selectedDate;
    
    //highlight first table view cell, since that is the graph that is being shown
    SFAWorkoutInfoCell *cell = (SFAWorkoutInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell setSelected:YES];
    
    self.workoutIndex = 0;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:WORKOUT_GRAPH_SEGUE_IDENTIFIER])
    {
        self.graphViewController = (SFAWorkoutGraphViewController *)segue.destinationViewController;
        self.graphViewController.delegate = self;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.isPortrait = (toInterfaceOrientation == UIInterfaceOrientationPortrait); //set isPortrait value
    [self _toggleObjectsWithInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.tableView.scrollEnabled = (fromInterfaceOrientation != UIInterfaceOrientationPortrait);
    self.tableView.contentOffset = CGPointZero;
    self.labelActiveTime.text = @"";
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
    [self setDataForDate:self.date workoutIndex:_workoutIndex];

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
        self.startTimeConstraint.constant = 90.0f;
        self.endTimeConstraint.constant = 90.0f;
        
    }else{
        self.startTimeConstraint.constant = 131.0f;
        self.endTimeConstraint.constant = 131.0f;
        
    }
    self.workoutStartTime.font = [UIFont systemFontOfSize:16.0f];
    self.workoutEndTime.font = [UIFont systemFontOfSize:16.0f];
}

- (void)getDataForDate:(NSDate *)date
{
    self.date = date;
    NSArray *yesterdayData = [WorkoutInfoEntity getWorkoutInfoWithDate:[date dateByAddingTimeInterval:-DAY_SECONDS]];
    WorkoutInfoEntity *spillOverWorkout = nil;
    for (WorkoutInfoEntity *workout in yesterdayData){
        if ([workout hasSpillOverWorkoutMinutes]){
            spillOverWorkout = workout;
            break;
        }
    }
    NSArray *data = nil;
    if (spillOverWorkout){
        NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[WorkoutInfoEntity getWorkoutInfoWithDate:date]];
        [temp insertObject:spillOverWorkout atIndex:0];
        data = temp.copy;
    }else{
        data =[WorkoutInfoEntity getWorkoutInfoWithDate:date];
    }
    
    self.dataPoints = [StatisticalDataPointEntity dataPointsForDate:date];
    
    if (data.count > 0){
        self.workouts = data;
    }else{
        self.workouts = @[];
    }
    [self.tableView reloadData];

}

- (void)setDataForDate:(NSDate *)date workoutIndex:(NSInteger)index
{
    [self.graphViewController setContentsWithDate:date workoutIndex:index];
    
    if (self.workouts.count == 0){
        [self showNoDataOnGraph];
        self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", 0];
        self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", 0];
        self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", 0];
        self.hrLabel.text = @"min";
        self.minLabel.text = @"sec";
        self.secLabel.text = @"hund";
        self.hrLabel.font = [UIFont systemFontOfSize:12.0];
        self.minLabel.font = [UIFont systemFontOfSize:12.0];
        self.secLabel.font = [UIFont systemFontOfSize:12.0];
        return;
    }
    
    WorkoutInfoEntity *workout = [self.workouts objectAtIndex:index];
    if (workout){
        if (self.isPortrait) {
            self.workoutTimeLabel.text = [NSString stringWithFormat:LS_WORKOUT_TIME_VARIABLE,index+1];
        }
        else{
            self.workoutTimeLabel.text = LS_TOTAL_WORKOUT_TIME_VARIABLE;
        }
        self.totalCalories      = workout.calories.integerValue;
        self.totalDistance      = workout.distance.floatValue;
        self.totalSteps         = workout.steps.integerValue;
        self.averageHeartRate   = 0.0f;
        if ([workout checkIfSpillOverWorkoutForDate:date]){
            NSInteger workoutYesterdaySeconds = [workout spillOverWorkoutSeconds];
            if (workoutYesterdaySeconds/3600 < 1) {
                self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", (workoutYesterdaySeconds%3600)/60];
                self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", workoutYesterdaySeconds%60];
                self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", [workout spillOverWorkoutHundredths]%100];
                self.hrLabel.text = @"min";
                self.minLabel.text = @"sec";
                self.secLabel.text = @"hund";
                self.hrLabel.font = [UIFont systemFontOfSize:12.0];
                self.minLabel.font = [UIFont systemFontOfSize:12.0];
                self.secLabel.font = [UIFont systemFontOfSize:12.0];
            }
            else{
                self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", workoutYesterdaySeconds/3600];
                self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", (workoutYesterdaySeconds%3600)/60];
                self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", workoutYesterdaySeconds%60];
                self.hrLabel.text = @"hr";
                self.minLabel.text = @"min";
                self.secLabel.text = @"sec";
                self.hrLabel.font = [UIFont systemFontOfSize:15.0];
                self.minLabel.font = [UIFont systemFontOfSize:15.0];
                self.secLabel.font = [UIFont systemFontOfSize:15.0];
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
                    self.hrLabel.font = [UIFont systemFontOfSize:12.0];
                    self.minLabel.font = [UIFont systemFontOfSize:12.0];
                    self.secLabel.font = [UIFont systemFontOfSize:12.0];
                }
                else{
                    self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", workoutTodaySeconds/3600];
                    self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", (workoutTodaySeconds%3600)/60];
                    self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", workoutTodaySeconds%60];
                    self.hrLabel.text = @"hr";
                    self.minLabel.text = @"min";
                    self.secLabel.text = @"sec";
                    self.hrLabel.font = [UIFont systemFontOfSize:15.0];
                    self.minLabel.font = [UIFont systemFontOfSize:15.0];
                    self.secLabel.font = [UIFont systemFontOfSize:15.0];
                }
                
            }else{
                if (workout.hour.integerValue < 1) {
                    self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", workout.minute.integerValue];
                    self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", workout.second.integerValue];
                    self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", workout.hundredths.integerValue];
                    self.hrLabel.text = @"min";
                    self.minLabel.text = @"sec";
                    self.secLabel.text = @"hund";
                    self.hrLabel.font = [UIFont systemFontOfSize:12.0];
                    self.minLabel.font = [UIFont systemFontOfSize:12.0];
                    self.secLabel.font = [UIFont systemFontOfSize:12.0];
                }
                else{
                    self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", workout.hour.integerValue];
                    self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", workout.minute.integerValue];
                    self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", workout.second.integerValue];
                    self.hrLabel.text = @"hr";
                    self.minLabel.text = @"min";
                    self.secLabel.text = @"sec";
                    self.hrLabel.font = [UIFont systemFontOfSize:15.0];
                    self.minLabel.font = [UIFont systemFontOfSize:15.0];
                    self.secLabel.font = [UIFont systemFontOfSize:15.0];
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
        }else{
            self.workoutStartTime.text = startTime;
        }

//        self.workoutEndTime.text = [self removeTimeHourFormat:endTime];
        
        self.labelCalories.text     = self.caloriesButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalCalories] : @"...";
        self.labelSteps.text        = self.stepsButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalSteps] : @"...";
        self.labelMiles.text        = self.distanceButton.isSelected ? [self formatDistance:self.totalDistance] : @"...";
        
    }else{
        [self showNoDataOnGraph];
    }
}

- (void)showNoDataOnGraph
{
    
    self.workoutTimeLabel.text = [NSString stringWithFormat:LS_WORKOUT_TIME];
    self.totalCalories = 0;
    self.averageHeartRate = 0;
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
    self.workoutEndTime.text = @"00:00:00";
    
    self.labelCalories.text     = self.caloriesButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalCalories] : @"...";
    self.labelSteps.text        = self.stepsButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalSteps] : @"...";
    self.labelMiles.text        = self.distanceButton.isSelected ? [NSString stringWithFormat:@"%.2f", self.totalDistance] : @"...";
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
    NSString *time = [NSString stringWithFormat:@"%i:%@:%@ %@", hour, minuteString, secondString, timeAMPM];
    
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
    self.workoutEndTime.hidden = !self.isPortrait;
    self.endLabel.hidden = !self.isPortrait;
    
    if (!self.isPortrait){
        self.workoutTimeLabel.text = LS_TOTAL_WORKOUT_TIME_VARIABLE;//LS_WORKOUT_TIME;
        self.workoutMetricConstraints.constant = 160;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.statusTopConstaint.constant = 30;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        else{
            self.statusTopConstaint.constant = 30;
            self.workoutMetricBottomConstraints.constant = 280;
        }
    }else{
        self.workoutTimeLabel.text = [NSString stringWithFormat:LS_WORKOUT_TIME_VARIABLE,self.workoutIndex+1];
        self.workoutMetricConstraints.constant = 2;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.statusTopConstaint.constant = 82;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            self.workoutMetricBottomConstraints.constant = -10;
            [self.tableView reloadData];
        }
        else{
            self.statusTopConstaint.constant = 82;
            self.workoutMetricBottomConstraints.constant = 162;
        }
    }
    self.labelMiles.text        = self.distanceButton.isSelected ? [self formatDistance:self.totalDistance] : @"...";
    
    [self setDataForDate:self.date workoutIndex:_workoutIndex];
}

- (void)selectGraphType:(SFAGraphType)graphType
{
    UIButton *button        = [self buttonForGraphType:graphType];
    UIImage *image          = [self imageForGraphType:graphType];
    button.selected         = !button.selected;
    
    [button setImage:image forState:UIControlStateNormal];
    
    self.labelCalories.text     = self.caloriesButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalCalories] : @"...";
    self.labelHeartRate.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.averageHeartRate] : @"...";
    self.labelSteps.text        = self.stepsButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalSteps] : @"...";
    self.labelMiles.text        = self.distanceButton.isSelected ? [self formatDistance:self.totalDistance] : @"...";
}

- (void)deselectGraphType:(SFAGraphType)graphType
{
    UIButton *button        = [self buttonForGraphType:graphType];
    button.selected         = !button.selected;
    
    [button setImage:INACTIVE_IMAGE forState:UIControlStateNormal];
    
    
    self.labelCalories.text     = self.caloriesButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalCalories] : @"...";
    self.labelHeartRate.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.averageHeartRate] : @"...";
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
            
            if ([self.delegate conformsToProtocol:@protocol(SFAWorkoutResultsViewControllerDelegate)])
            {
                [self.delegate workoutResultsViewController:self didRemoveGraphType:SFAGraphTypeCalories];
            }
        }
    }
    else
    {
        [self addGraphType:SFAGraphTypeCalories];
        
        if ([self.delegate conformsToProtocol:@protocol(SFAWorkoutResultsViewControllerDelegate)])
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
            
            if ([self.delegate conformsToProtocol:@protocol(SFAWorkoutResultsViewControllerDelegate)])
            {
                [self.delegate workoutResultsViewController:self didRemoveGraphType:SFAGraphTypeHeartRate];
            }
        }
    }
    else
    {
        [self addGraphType:SFAGraphTypeHeartRate];
        
        if ([self.delegate conformsToProtocol:@protocol(SFAWorkoutResultsViewControllerDelegate)])
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
            
            if ([self.delegate conformsToProtocol:@protocol(SFAWorkoutResultsViewControllerDelegate)])
            {
                [self.delegate workoutResultsViewController:self didRemoveGraphType:SFAGraphTypeSteps];
            }
        }
    }
    else
    {
        [self addGraphType:SFAGraphTypeSteps];
        
        if ([self.delegate conformsToProtocol:@protocol(SFAWorkoutResultsViewControllerDelegate)])
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
            
            if ([self.delegate conformsToProtocol:@protocol(SFAWorkoutResultsViewControllerDelegate)])
            {
                [self.delegate workoutResultsViewController:self didRemoveGraphType:SFAGraphTypeDistance];
            }
        }
    }
    else
    {
        [self addGraphType:SFAGraphTypeDistance];
        
        if ([self.delegate conformsToProtocol:@protocol(SFAWorkoutResultsViewControllerDelegate)])
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return LS_WORKOUT;
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SFAWorkoutInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:WORKOUT_LOGS_CELL_IDENTIFIER];
        
        if ([self.workouts objectAtIndex:indexPath.row]){
            cell.date = self.date;
            [cell setContentsWithWorkout:self.workouts[indexPath.row] workoutIndex:indexPath.row];
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
    
    [self setWorkoutIndex:indexPath.row];
    
    //scroll to top
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, -self.tableView.contentInset.top) animated:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - sfaworkoutgraphview delegate

- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeDataPoint:(NSInteger)index
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
    self.averageHeartRate = dataPoint != nil? dataPoint.averageHR.integerValue : 0;
    self.totalSteps = dataPoint != nil? dataPoint.steps.integerValue :0;
    self.totalDistance = dataPoint != nil? dataPoint.distance.floatValue : 0.0f;
    
    self.labelCalories.text     = self.caloriesButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalCalories] : @"...";
    self.labelHeartRate.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.averageHeartRate] : @"...";
    self.labelSteps.text        = self.stepsButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalSteps] : @"...";
    self.labelMiles.text        = self.distanceButton.isSelected ? [self formatDistance:self.totalDistance] : @"...";
}

- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeTotalWorkoutTime:(NSInteger)workoutSeconds
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
        self.hrLabel.font = [UIFont systemFontOfSize:12.0];
        self.minLabel.font = [UIFont systemFontOfSize:12.0];
        self.secLabel.font = [UIFont systemFontOfSize:12.0];
    }
    else{
        self.totalWorkoutTimeHours.text = [NSString stringWithFormat:@"%02d", (workoutSeconds/100)/3600];
        self.totalWorkoutTimeMinutes.text = [NSString stringWithFormat:@"%02d", ((workoutSeconds/100)%3600)/60];
        self.totalWorkoutTimeSeconds.text = [NSString stringWithFormat:@"%02d", (workoutSeconds/100)%60];
        self.hrLabel.text = @"hr";
        self.minLabel.text = @"min";
        self.secLabel.text = @"sec";
        self.hrLabel.font = [UIFont systemFontOfSize:15.0];
        self.minLabel.font = [UIFont systemFontOfSize:15.0];
        self.secLabel.font = [UIFont systemFontOfSize:15.0];
    }
}

- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeWorkoutEndTime:(NSString *)time
{
    self.workoutEndTime.text = time;
}

- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeTime:(NSString *)time
{
    
}

- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeCalories:(NSInteger)calories
{
    self.totalCalories = calories;
    self.labelCalories.text     = self.caloriesButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalCalories] : @"...";
}

- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeHeartRate:(NSInteger)heartRate
{
    self.averageHeartRate = heartRate;
    self.labelHeartRate.text    = self.heartRateButton.isSelected ? [NSString stringWithFormat:@"%i", self.averageHeartRate] : @"...";
}

- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeSteps:(NSInteger)steps
{
    self.totalSteps = steps;
    self.labelSteps.text        = self.stepsButton.isSelected ? [NSString stringWithFormat:@"%i", self.totalSteps] : @"...";
}

- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeDistance:(CGFloat)distance
{
    self.totalDistance = distance;
    self.labelMiles.text        = self.distanceButton.isSelected ? [self formatDistance:self.totalDistance] : @"...";
}

@end
