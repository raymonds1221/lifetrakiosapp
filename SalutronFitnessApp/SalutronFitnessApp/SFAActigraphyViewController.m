//
//  SFAActigraphyViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/10/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "StatisticalDataPointEntity+Data.h"
#import "SleepDatabaseEntity+Data.h"
#import "TimeDate+Data.h"

#import "SFAActigraphyViewController.h"
#import "SFAActigraphyGraphViewController.h"
#import "SFASleepLogDataViewController.h"
#import "SFAGraph.h"
#import "SFAXYPlotSpace.h"
#import "SFALinePlot.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "StatisticalDataPointEntity.h"
#import "SleepDatabaseEntity.h"
#import "SFAMainViewController.h"
#import "WorkoutInfoEntity+Data.h"
#import "SFASleepDataCell.h"
#import "JDACoreData.h"
#import "GoalsEntity.h"
#import "SFAGoalsData.h"
#import "JDAPickerView.h"
#import "JDAKeyboardAccessory.h"
#import "SFACalendarView.h"
#import "NSDate+Comparison.h"
#import "SFAServerAccountManager.h"

#define MAX_X_RANGE 144
#define MAX_Y_RANGE 20.0f
#define ACTIGRAPHY_GRAPH_SEGUE_IDENTIFIER @"ActigraphyGraphSegueIdentifier"
#define SLEEP_DATA_SEGUE_IDENTIFIER @"SleepLogsToSleepData"
#define ACTIGRAPHY_STEPS_IDENTIFIER @"ActigraphyStepsIdentifier"
#define ACTIGRAPHY_SLEEP_IDENTIFIER @"ActigraphySleepIdentifier"
#define ACTIGRAPHY_WORKOUT_IDENTIFER @"ActigraphyWorkoutIdentifier"
#define ACTIGRAPHY_HORIZONTAL_LINE_IDENTIFIER @"ActigraphyHorizontalLineIdentifier"

#define TICK_SPACE 4.265
#define PLOT_AREA_PADDING_LEFT 10.0f

@interface SFAActigraphyViewController () <SFALinePlotDelegate, CPTPlotSpaceDelegate, SFAActigraphyGraphViewControllerDelegate, SFASleepLogDataViewControllerDelegate, JDAPickerViewDelegate>

@property (strong, nonatomic) SFAGraph *graph;
@property (strong, nonatomic) SFAXYPlotSpace *plotSpace;
@property (strong, nonatomic) SFALinePlot *actigraphyStepsPlot;
@property (strong, nonatomic) SFALinePlot *actigraphyLinePlot;
@property (strong, nonatomic) SFALinePlot *actigraphyWorkout;
@property (strong, nonatomic) SFALinePlot *actigraphyHorizontalLine;
@property (strong, nonatomic) SFAActigraphyGraphViewController *graphViewController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray *dataForSteps;
@property (strong, nonatomic) NSMutableArray *dataForSleep;
@property (strong, nonatomic) NSMutableArray *dataForWorkoutSteps;
@property (strong, nonatomic) NSMutableArray *dataForStepsPoints;
@property (strong, nonatomic) NSMutableArray *dataForHorizontalLine;
@property (assign, nonatomic) NSInteger minXRange;
@property (assign, nonatomic) NSInteger maxXRange;
@property (assign, nonatomic) NSInteger maxYRange;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSString *macAddress;
@property (strong, nonatomic) NSArray *sleepRecord;
@property (strong, nonatomic) NSArray *constraints;
@property (weak, nonatomic) IBOutlet UIView *leftGraphView;
@property (weak, nonatomic) IBOutlet UIView *rightGraphView;
@property (weak, nonatomic) IBOutlet UIImageView *graphViewImage;
@property (weak, nonatomic) IBOutlet UIView *actigraphyGraphView;
@property (weak, nonatomic) IBOutlet UIView *actigraphyLeftGraphView;
@property (weak, nonatomic) IBOutlet UIView *actigraphyRightGraphView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphVerticalConstraints2;
@property (weak, nonatomic) IBOutlet UIView *actigraphyView;
@property (weak, nonatomic) IBOutlet UIView *viewGraph;
@property (weak, nonatomic) IBOutlet UIView *viewProgressBackground;
@property (weak, nonatomic) IBOutlet UILabel *labelGoalPercent;
@property (weak, nonatomic) IBOutlet UILabel *labelGoal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidthConstriant;
@property (weak, nonatomic) IBOutlet UIImageView *imageGoal;
@property (weak, nonatomic) IBOutlet UIView *viewProgressBar;
@property (readwrite, nonatomic) CGFloat sleepValue;
@property (weak, nonatomic) IBOutlet UIImageView *imagePlayHead;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDateRange;
@property (weak, nonatomic) IBOutlet UIView *viewLandscapeDetails;
@property (strong, nonatomic) JDAPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *graphUnderView;
@property (weak, nonatomic) IBOutlet UIView *viewGraphYAxis;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *graphMargin;
@property (weak, nonatomic) IBOutlet UILabel *labelWorkoutCount;
@property (weak, nonatomic) IBOutlet UILabel *labelActiveCount;
@property (weak, nonatomic) IBOutlet UILabel *labelDeepSleepCount;
@property (weak, nonatomic) IBOutlet UILabel *labelLightSleepCount;
@property (weak, nonatomic) IBOutlet UILabel *labelMonthRange;
@property (weak, nonatomic) IBOutlet UIView *viewDataCount;
@property (weak, nonatomic) IBOutlet UIView *viewLightSleep;
@property (weak, nonatomic) IBOutlet UILabel *labelDeepSleep;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UILabel *totalActiveTime;
@property (weak, nonatomic) IBOutlet UILabel *totalSleepTime;
@property (weak, nonatomic) IBOutlet UILabel *totalSedentaryTime;

@property (weak, nonatomic) IBOutlet UIView *dateRangeButtonView;
@property (strong, nonatomic) SFAUserDefaultsManager *userDefaultsManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewBackgroundHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playheadHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphXBackgroundViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphYAxisHeight;

@end

@implementation SFAActigraphyViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.imagePlayHead setHidden:YES];
    [self.viewGraphYAxis setHidden:YES];
    if (!self.isActigraphy) {
        //self.navigationItem.title = @"Sleep";
        self.navItem.title = LS_SLEEP_LOGS;
        [self.actigraphyGraphView removeFromSuperview];
        [self.actigraphyLeftGraphView removeFromSuperview];
        [self.actigraphyRightGraphView removeFromSuperview];
        [self.graphUnderView removeFromSuperview];
        [self.graphViewImage removeFromSuperview];
        [self.viewGraphYAxis removeFromSuperview];
//        if (self.graphVerticalConstraints2 != nil)
//            [self.actigraphyView removeConstraints:self.view.constraints];
        [self.tableView reloadData];
    }
    else {
        //self.navigationItem.title = @"Actigraphy";
        self.navItem.title = kActigraphy;
        [self.tableView setBackgroundColor:[UIColor whiteColor]];
        if (self.graphViewController != nil)
            self.graphViewController.scrollView.contentOffset = CGPointMake(0, 0);
        if (self.userDefaultsManager.selectedDateFromCalendar)
            self.calendarController.selectedDate = self.userDefaultsManager.selectedDateFromCalendar;
//        [self.calendarController.calendarView setNeedsDisplay];
        /*
        NSNumber *orientation = @(UIInterfaceOrientationLandscapeLeft);
        [[UIDevice currentDevice] performSelector:NSSelectorFromString(@"setOrientation:") withObject:orientation afterDelay:1.0f];
         */
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:ACTIGRAPHY_GRAPH_SEGUE_IDENTIFIER]) {
        self.graphViewController            = segue.destinationViewController;
        self.graphViewController.delegate   = self;
    } else if ([segue.identifier isEqualToString:SLEEP_DATA_SEGUE_IDENTIFIER]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SFASleepLogDataViewController *viewController = (SFASleepLogDataViewController *)segue.destinationViewController;
        viewController.delegate = self;
        viewController.mode = SFASleepLogDataModeEdit;
        viewController.sleepDatabaseEntity = self.sleepRecord[indexPath.row];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        for (NSLayoutConstraint *obj in self.graphMargin) {
            obj.constant = 5;
        }
        
        self.graphViewImage.image           = [UIImage imageNamed:@"ll_sleep_graph_bg_container"];
        self.leftGraphView.hidden           = NO;
        self.rightGraphView.hidden          = NO;
        self.imagePlayHead.hidden           = YES;
        self.viewLandscapeDetails.hidden    = YES;
        self.viewGraphYAxis.hidden          = YES;
        
        [self.textFieldDateRange resignFirstResponder];
        [self.plotDelegate actigraphyViewController:self didChangeDateRange:SFADateRangeDay];
    }
    else
    {
        for (NSLayoutConstraint *obj in self.graphMargin) {
            obj.constant = 0;
        }
        
        self.graphViewImage.image           = [UIImage imageNamed:@"ActigraphyWeekBackground"];
        self.leftGraphView.hidden           = YES;
        self.rightGraphView.hidden          = YES;
        self.viewGraphYAxis.hidden          = self.calendarController.calendarMode == SFACalendarDay;
        self.viewDataCount.hidden           = NO;
        self.viewLightSleep.hidden          = YES;
        self.imagePlayHead.hidden           = YES;
        self.viewLandscapeDetails.hidden    = !self.isActigraphy;
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
        self.textFieldDateRange.text        = LS_DAILY;
        self.labelDeepSleep.text            = LS_SLEPT;
//        [self.plotDelegate actigraphyViewController:self didChangeDateRange:SFADateRangeDay];
        
        //[self _updateDateRangeLandscapeLabel];
    }
}

#pragma mark - Text field delegates
- (void)pickerViewDidSelectIndex:(NSInteger)selectedIndex
{
    SFADateRange dateRange  = SFADateRangeDay;
    self.viewGraphYAxis.hidden  = NO;
    self.viewDataCount.hidden   = NO;
    self.viewLightSleep.hidden  = NO;
    self.labelDeepSleep.text    = LS_DEEP_SLEEP;

    //Change graph
    if([self.pickerView.selectedValue isEqualToString:DAILY_IDENTIFIER])
    {
        dateRange                   = SFADateRangeDay;
        self.viewLightSleep.hidden  = YES;
        self.labelDeepSleep.text    = LS_SLEPT;
    }
    else if([self.pickerView.selectedValue isEqualToString:WEEKLY_IDENTIFIER])
    {
        dateRange = SFADateRangeWeek;
        
        self.labelDeepSleepCount.text   = [NSString stringWithFormat:@"0 %@", LS_TIMES];
        self.labelLightSleepCount.text  = [NSString stringWithFormat:@"0 %@", LS_TIMES];
        self.labelActiveCount.text      = [NSString stringWithFormat:@"0 %@", LS_TIMES];
        self.labelWorkoutCount.text     = [NSString stringWithFormat:@"0 %@", LS_TIMES];
    }
    else if([self.pickerView.selectedValue isEqualToString:MONTHLY_IDENTIFIER])
    {
        dateRange = SFADateRangeMonth;
        
        self.labelDeepSleepCount.text   = [NSString stringWithFormat:@"0 %@", LS_TIMES];
        self.labelLightSleepCount.text  = [NSString stringWithFormat:@"0 %@", LS_TIMES];
        self.labelActiveCount.text      = [NSString stringWithFormat:@"0 %@", LS_TIMES];
        self.labelWorkoutCount.text     = [NSString stringWithFormat:@"0 %@", LS_TIMES];
    }
    else if([self.pickerView.selectedValue isEqualToString:YEARLY_IDENTIFIER])
    {
        dateRange = SFADateRangeYear;
        
        self.graphViewController.scrollView.contentOffset = CGPointMake(0, 0);
        
        if (dateRange == SFADateRangeWeek) {
             [self _updateDateRangeLandscapeLabel];
        }
    }

    if ([self.plotDelegate respondsToSelector:@selector(actigraphyViewController:didChangeDateRange:)])
    {
        [self.plotDelegate actigraphyViewController:self didChangeDateRange:dateRange];
    }

    [self _updateDateRangeLandscapeLabel];
    self.graphViewController.scrollView.contentOffset = CGPointMake(0, 0);
}

#pragma mark - Private Methods
- (void)_updateDateRangeLandscapeLabel
{
    SFACalendarView *calendar   = [SFACalendarView activeCalendarView];
    self.labelMonthRange.text   = calendar.dateHeaderString;
    //[self.labelMonthRange sizeToFit];
}

- (CGFloat)xWithMinX:(CGFloat)minX
                maxX:(CGFloat)maxX
           minXRange:(CGFloat)minXRange
           maxXRange:(CGFloat)maxXRange
              xValue:(CGFloat)xValue
{
    CGFloat percent = (xValue - minX) / (maxX - minX);
    CGFloat x       = percent * (maxXRange - minXRange);
    return x;
}

- (CGFloat)yWithMinY:(CGFloat)minY
                maxY:(CGFloat)maxY
           minYRange:(CGFloat)minYRange
           maxYRange:(CGFloat)maxYRange
              yValue:(CGFloat)yValue
{
    CGFloat percent = (yValue - minY) / (maxY - minY);
    CGFloat y       = percent * (maxYRange - minYRange);
    return y;
}

- (NSManagedObjectContext *)managedObjectContext {
    if(!_managedObjectContext) {
        SFASalutronFitnessAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (NSUserDefaults *) userDefaults {
    if(!_userDefaults)
        _userDefaults = [NSUserDefaults standardUserDefaults];
    return _userDefaults;
}

- (NSString *) macAddress {
    _macAddress = [self.userDefaults objectForKey:MAC_ADDRESS];
    if(_macAddress == nil)
        _macAddress = @"";
    return _macAddress;
}

- (void) initializeObjects
{
    if (!self.isActigraphy)
    {
        _viewGraph.frame = CGRectMake(_viewGraph.frame.origin.x,
                                      _viewGraph.frame.origin.y,
                                      _viewGraph.frame.size.width,
                                      90);
    }
    else
    {
        self.tableView.scrollEnabled = NO;
    }
    
    //Set textfield keyboard accessory with done
    JDAKeyboardAccessory *_accessory            = [[JDAKeyboardAccessory alloc] initWithDoneAccessoryWithBarStyle:UIBarStyleDefault];
    _accessory.currentView                      = self.textFieldDateRange;
    self.textFieldDateRange.inputAccessoryView  = _accessory;
 
    //Set text field picker view
    self.pickerView                     = [[JDAPickerView alloc] initWithArray:DATE_RANGE_PICKER
                                                                      delegate:self];
    self.pickerView.textField           = self.textFieldDateRange;
    self.textFieldDateRange.inputView   = self.pickerView;
    self.textFieldDateRange.text        = DATE_RANGE_PICKER.firstObject;
    
    //Add left padding
//    UIView *leftPadding                     = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 30)];
//    self.textFieldDateRange.leftView        = leftPadding;
//    self.textFieldDateRange.leftViewMode    = UITextFieldViewModeAlways;
    
    //Add border
    self.dateRangeButtonView.layer.cornerRadius  = 8.0f;
    self.dateRangeButtonView.layer.borderColor   = DISTANCE_LINE_COLOR.CGColor;
    self.dateRangeButtonView.layer.borderWidth   = 1.0f;
    
    // initial for Fitness
    self.textFieldDateRange.text = DATE_RANGE_PICKER.firstObject;
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        self.graphViewHeight.constant = 200;
        self.playheadHeight.constant = 176;
        self.graphViewBackgroundHeight.constant = 170;
        self.graphYAxisHeight.constant = 168;
        //self.graphXBackgroundTopConstraint.constant = -180;
    }
}

- (NSArray *)_fetchSleepWithDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    [components setSecond:0];
    [components setMinute:0];
    [components setHour:0];
    NSDate *dateFromComponents = [calendar dateFromComponents:components];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:SLEEP_DATABASE_ENTITY];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateInNSDate == $dateInNSDate AND device.macAddress == $macAddress AND device.user.userID == $userID"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:dateFromComponents, @"dateInNSDate", self.macAddress, @"macAddress", [SFAServerAccountManager sharedManager].user.userID, @"userID",nil];
    predicate = [predicate predicateWithSubstitutionVariables:params];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return results;
}

- (void) getSleepDatabase:(NSDate *)date
{
    TimeDate *timeDate = [TimeDate getData];
    NSMutableArray *results     = [NSMutableArray array];
    
    //get previous day sleep results and current day sleep results
    NSArray *_prevDayResults    = [self _fetchSleepWithDate:[date getDateWithInterval:-1]];
    NSArray *_curDayResults     = [self _fetchSleepWithDate:date];
    
    //add previous day sleep data if reached the next day
    for (SleepDatabaseEntity *object in _prevDayResults)
    {
        if (object.sleepEndHour.integerValue == 23 ||
            !(object.sleepEndHour.integerValue < 23 && object.sleepEndHour.integerValue > object.sleepStartHour.integerValue - 1))
        {
            [results addObject: object];
        }
    }
    
    //add current day sleep data if data did not reach next day
    for (SleepDatabaseEntity *object in _curDayResults)
    {
        if (object.sleepEndHour.integerValue != 23 &&
            (object.sleepEndHour.integerValue < 23 && object.sleepEndHour.integerValue > object.sleepStartHour.integerValue - 1))
        {
            [results addObject:object];
        }
    }
    
    
    NSUInteger sleepDuration = 0;
    NSUInteger sleepStartHour = 0;
    NSUInteger sleepStartMin = 0;
    NSUInteger sleepEndHour = 0;
    NSUInteger sleepEndMin = 0;
    
    [self.dataForSleep removeAllObjects];
    
    if(results.count > 0) {
        /*NSArray *plots = [self.graph allPlots];
         
         for(CPTPlot *plot in plots) {
         if([plot.identifier isEqual:ACTIGRAPHY_SLEEP_IDENTIFIER]) {
         [self.graph removePlot:plot];
         }
         }*/
        [self removePlotsWithIdentifer:ACTIGRAPHY_SLEEP_IDENTIFIER];
        
        //get start end end sleep
        SleepDatabaseEntity *_startSleep    = results.firstObject;
        SleepDatabaseEntity *_endSleep      = results.lastObject;
        
        sleepStartHour  = _startSleep.sleepStartHour.integerValue;
        sleepStartMin   = _startSleep.sleepStartMin.integerValue;
        sleepEndHour    = _endSleep.sleepEndHour.integerValue;
        sleepEndMin     = _endSleep.sleepEndMin.integerValue;
        
        for(SleepDatabaseEntity *sleepDatabaseEntity in results) {
            sleepDuration += sleepDatabaseEntity.sleepDuration.integerValue;
            
            NSUInteger totalSleep = 0;
            NSArray *data = [[self getSleepInStartHour:sleepDatabaseEntity.sleepStartHour.integerValue
                                              startMin:sleepDatabaseEntity.sleepStartMin.integerValue
                                               endHour:sleepDatabaseEntity.sleepEndHour.integerValue
                                                endMin:sleepDatabaseEntity.sleepEndMin.integerValue
                                                  date:date
                                          nsdateindate:sleepDatabaseEntity.dateInNSDate
                                            totalSleep:&totalSleep] copy];
            [self.dataForSleep addObject:data];
            CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
            lineStyle.lineColor = [CPTColor cyanColor];
            SFALinePlot *linePlot = [SFALinePlot linePlot];
            CPTFill *fill = nil;
            
            /*if(totalSleep >= 300) {
             fill = [CPTFill fillWithColor:[CPTColor cyanColor]];
             lineStyle.lineColor = [CPTColor cyanColor];
             } else if(totalSleep >= 159 && totalSleep <= 299) {
             fill = [CPTFill fillWithColor:[CPTColor greenColor]];
             lineStyle.lineColor = [CPTColor greenColor];
             } else {
             fill = [CPTFill fillWithColor:[CPTColor yellowColor]];
             lineStyle.lineColor = [CPTColor yellowColor];
             }*/
            lineStyle.lineColor = [CPTColor colorWithComponentRed:28.0f/255.0f green:96.0f/255.0f blue:148.0f/255.0f alpha:1.0f];
            lineStyle.lineWidth = 1.0f;
            fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:38.0f/255.0f green:130.0f/255.0f blue:200.0f/255.0f alpha:1.0f]];
            
            linePlot.index = [results indexOfObject:sleepDatabaseEntity];
            linePlot.identifier = ACTIGRAPHY_SLEEP_IDENTIFIER;
            linePlot.dataDelegate = self;
            linePlot.dataLineStyle = lineStyle;
            linePlot.areaFill = fill;
            linePlot.areaBaseValue = CPTDecimalFromInt(MAX_Y_RANGE / 2);
            //linePlot.interpolation = CPTScatterPlotInterpolationCurved;
            [self.graph addPlot:linePlot toPlotSpace:self.plotSpace];
            
            if(data.count > 0) {
                NSValue *value = [data objectAtIndex:0];
                CGRect frame = CGRectMake(value.CGPointValue.x * TICK_SPACE, self.graphView.bounds.size.height - 18, 15, 18);
                UIImage *image = [UIImage imageNamed:@"ll_sleep_graph_icons_sleep"];
                CPTPlotSpaceAnnotation *annotationSleep = [self annotationWithFrame:frame image:image];
                [self.graph addAnnotation:annotationSleep];
                
                NSValue *value2 = [data objectAtIndex:data.count - 1];
                CGRect frame2 = CGRectMake(value2.CGPointValue.x * TICK_SPACE, self.graphView.bounds.size.height - 18, 15, 18);
                UIImage *image2 = [UIImage imageNamed:@"ll_sleep_graph_icons_awake"];
                CPTPlotSpaceAnnotation *annotationAwake = [self annotationWithFrame:frame2 image:image2];
                [self.graph addAnnotation:annotationAwake];
            }
        }
        
        //        SleepDatabaseEntity *sleepFirst = [results firstObject];
        ////        sleepStartHour = sleepFirst.sleepStartHour.integerValue;
        ////        sleepStartMin = sleepFirst.sleepStartMin.integerValue;
        ////        sleepEndHour = sleepFirst.sleepEndHour.integerValue;
        ////        sleepEndMin = sleepFirst.sleepEndMin.integerValue;
        
        if(sleepDuration > 59) {
            self.totalSleepTimeHr.text = [NSString stringWithFormat:@"%i", sleepDuration / 60];
            self.totalSleepTimeMin.text = [NSString stringWithFormat:@"%i", sleepDuration % 60];
        } else {
            self.totalSleepTimeHr.text = @"0";
            self.totalSleepTimeMin.text = [NSString stringWithFormat:@"%i", sleepDuration];
        }
        
        NSString *sleepStartTimeAppendString = @"";
        NSString *sleepEndTimeAppendString = @"";

        if (timeDate.hourFormat == _12_HOUR) {
            if (sleepStartHour >= 12) {
                sleepStartTimeAppendString = LS_PM;
            } else {
                sleepStartTimeAppendString = LS_AM;
            }
            
            if (sleepEndHour >= 12) {
                sleepEndTimeAppendString = LS_PM;
            } else {
                sleepEndTimeAppendString = LS_AM;
            }
        }
        
        
        if (sleepStartHour == 12) {
            self.sleepStart.text = [NSString stringWithFormat:@"%i:%02d %@", sleepStartHour, sleepStartMin, sleepStartTimeAppendString];
        } else if(sleepStartHour > 12) {
            self.sleepStart.text = [NSString stringWithFormat:@"%i:%02d %@", sleepStartHour - 12, sleepStartMin, sleepStartTimeAppendString];
        } else if (sleepStartHour == 0){
            self.sleepStart.text = [NSString stringWithFormat:@"12:%02d %@", sleepStartMin, sleepStartTimeAppendString];
        } else {
            self.sleepStart.text = [NSString stringWithFormat:@"%i:%02d %@", sleepStartHour, sleepStartMin, sleepStartTimeAppendString];
        }
        
        if (sleepEndHour == 12) {
            self.sleepEnd.text = [NSString stringWithFormat:@"%i:%02d %@", sleepEndHour, sleepEndMin, sleepEndTimeAppendString];
        }else if(sleepEndHour > 12) {
            self.sleepEnd.text = [NSString stringWithFormat:@"%i:%02d %@", sleepEndHour - 12, sleepEndMin, sleepEndTimeAppendString];
        } else if (sleepEndHour == 0) {
            self.sleepEnd.text = [NSString stringWithFormat:@"12:%02d %@", sleepEndMin, sleepEndTimeAppendString];
        } else {
            self.sleepEnd.text = [NSString stringWithFormat:@"%i:%02d %@", sleepEndHour, sleepEndMin, sleepEndTimeAppendString];
        }
        
        if (LANGUAGE_IS_FRENCH && timeDate.hourFormat == _24_HOUR) {
            self.sleepStart.text = [self.sleepStart.text stringByReplacingOccurrencesOfString:@":" withString:@"h"];
            self.sleepEnd.text = [self.sleepEnd.text stringByReplacingOccurrencesOfString:@":" withString:@"h"];
        }
        
        
        self.wokeUpCount.text = [NSString stringWithFormat:@"%i", [results count]];
        
        if([results count] > 1)
            self.wokeUpLabel.text = LS_TIMES;
        else
            //self.wokeUpLabel.text = @"time";
            self.wokeUpLabel.text = LS_TIMES;
    } else {
        self.totalSleepTimeHr.text = @"0";
        self.totalSleepTimeMin.text = @"0";
        self.sleepStart.text = timeDate.hourFormat == _12_HOUR ? [NSString stringWithFormat:@"0:00 %@", LS_AM] : @"00h00";
        self.sleepEnd.text = timeDate.hourFormat == _12_HOUR ? [NSString stringWithFormat:@"0:00 %@", LS_AM] : @"00h00";
        self.wokeUpCount.text = @"0";
        self.wokeUpLabel.text = LS_TIME;
    }
}

-(NSArray *) getSleepInStartHour:(NSUInteger) startHour
                        startMin:(NSUInteger)startMin
                         endHour:(NSUInteger)endHour
                          endMin:(NSUInteger)endMin
                            date:(NSDate *)date
                    nsdateindate:(NSDate *)nsdateindate
                      totalSleep:(NSUInteger *)totalSleep {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:STATISTICAL_DATA_POINT_ENTITY];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"header.date.day == $day AND header.date.month == $month AND header.date.year  == $year AND header.device.macAddress == $macAddress AND header.device.user.userID == $userID"];
    NSNumber *day = [NSNumber numberWithInt:[components day]];
    NSNumber *month = [NSNumber numberWithInt:[components month]];
    NSNumber *year = [NSNumber numberWithInt:[components year] - 1900];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *macAddress = [userDefaults objectForKey:MAC_ADDRESS];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:day, @"day", month, @"month", year, @"year", macAddress, @"macAddress", [SFAServerAccountManager sharedManager].user.userID, @"userID", nil];
    predicate = [predicate predicateWithSubstitutionVariables:params];
    
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error) {
        NSDate *_curDate = [[date getDateString] getDateFromStringWithFormat:@"MM/dd/yyyy"];
        startHour   = (![_curDate isEqualToDate:nsdateindate]) ? 0 : startHour;
        endHour     = (endHour == 23) ?  : endHour;
        NSUInteger startTimeInMinutes = (startHour * 60) + startMin;
        NSUInteger endTimeInMinutes = (endHour * 60) + endMin;
        
        NSMutableArray *data = [[NSMutableArray alloc] init];
        
        NSUInteger maxSleepValue = 0;
        
        for(StatisticalDataPointEntity *dataPoint in results) {
            NSUInteger sleepValue = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue +
            dataPoint.sleepPoint46.floatValue + dataPoint.sleepPoint68.floatValue +
            dataPoint.sleepPoint810.floatValue;
            maxSleepValue = MAX(maxSleepValue, sleepValue);
        }
        
        for(StatisticalDataPointEntity *dataPoint in results) {
            NSUInteger index = [results indexOfObject:dataPoint];
            
            if(index * 10 >= startTimeInMinutes && index * 10 <= endTimeInMinutes) {
                NSUInteger sleepValue = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue +
                dataPoint.sleepPoint46.floatValue + dataPoint.sleepPoint68.floatValue +
                dataPoint.sleepPoint810.floatValue;
                CGFloat x = [results indexOfObject:dataPoint];
                CGFloat y = [self yWithMinY:0.0f maxY:maxSleepValue minYRange:0.0f maxYRange:MAX_Y_RANGE / 2 yValue:sleepValue];
                y += MAX_Y_RANGE / 2;
                y = (MAX_Y_RANGE / 2) - (y - MAX_Y_RANGE / 2);
                CGPoint point = CGPointMake(x, y);
                [data addObject:[NSValue valueWithCGPoint:point]];
            }
        }
        *totalSleep = maxSleepValue;
        return data;
    }
    
    return nil;
}

- (void) _getWorkout:(NSDate *) date
{
    //Workout entities
    NSArray *_workoutEntities    = [WorkoutInfoEntity getWorkoutInfoWithDate:date];
    _dataForWorkoutSteps                = [NSMutableArray array];
    
    if (_workoutEntities.count > 0)
    {
        NSMutableArray *_stepsData  = [NSMutableArray array];
        WorkoutInfoEntity *_workout = [[WorkoutInfoEntity getHighestWorkoutStepsWithDate:date] firstObject];
        NSInteger _maxSteps         = _workout.steps.integerValue;
        NSInteger _maxYValue        = MAX(0, _maxSteps);
        
        for (WorkoutInfoEntity *_workoutEntity in _workoutEntities)
        {
            //Workout entity x and y
            self.maxYRange      = MAX(self.maxYRange, _maxSteps);
            
            if (_workoutEntity.steps.integerValue > 0)
            {
                CGFloat _steps  = _workoutEntity.steps.floatValue;
                CGFloat _x      = (MAX_X_RANGE / 24) * (_workoutEntity.stampHour.floatValue + (_workoutEntity.stampMinute.floatValue / 60));
                CGFloat _y      = [self yWithMinY:0.0f
                                             maxY:_maxYValue
                                        minYRange:0.0f
                                        maxYRange:MAX_Y_RANGE / 2
                                           yValue:_steps];
                _y += MAX_Y_RANGE / 2;
                CGPoint _point  = CGPointMake(_x, _y);
                NSValue *_value = [NSValue valueWithCGPoint:_point];
                [_stepsData addObject:_value];
            }
        }
        
        [self removePlotsWithIdentifer:ACTIGRAPHY_WORKOUT_IDENTIFER];
        [_dataForWorkoutSteps addObject:[_stepsData copy]];
        
        //line style
        CPTMutableLineStyle *_lineStyle = [CPTMutableLineStyle lineStyle];
        _lineStyle.lineColor            = [CPTColor grayColor];
        
        //line plot
        SFALinePlot *_linePlot  = [SFALinePlot linePlot];
        _linePlot.index         = 0;
        _linePlot.dataDelegate  = self;
        _linePlot.dataLineStyle = _lineStyle;
        _linePlot.identifier    = ACTIGRAPHY_WORKOUT_IDENTIFER;
        _linePlot.areaFill      = [CPTFill fillWithColor:[CPTColor grayColor]];
        _linePlot.areaBaseValue = CPTDecimalFromInt(MAX_Y_RANGE / 2);
        [self.graph addPlot:_linePlot toPlotSpace:_plotSpace];
    }
}

- (void) getDataForDay:(NSDate *)date {
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSInteger year                  = [components year] - 1900;
    NSInteger month                 = [components month];
    NSInteger day                   = [components day];
    NSString *predicateFormat       = [NSString stringWithFormat:@"header.date.day == $day AND header.date.month == $month AND header.date.year == $year AND header.device.macAddress == $macAddress AND header.device.user.userID == $userID"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:day], @"day", [NSNumber numberWithInteger:month], @"month", [NSNumber numberWithInteger:year], @"year", self.macAddress, @"macAddress", [SFAServerAccountManager sharedManager].user.userID, @"userID", nil];
    
    
    NSFetchRequest *fetchRequest    = [NSFetchRequest fetchRequestWithEntityName:STATISTICAL_DATA_POINT_ENTITY];
    NSPredicate *predicate          = [NSPredicate predicateWithFormat:predicateFormat];
    predicate = [predicate predicateWithSubstitutionVariables:params];
    fetchRequest.predicate          = predicate;
    NSError *error                  = nil;
    NSArray *data                   = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(data) {
        self.maxXRange = 144;
        
        NSMutableArray *stepData = [[NSMutableArray alloc] init];
        
        NSUInteger maxYValue = 0;
        
        for(StatisticalDataPointEntity *dataPoint in data) {
            maxYValue = MAX(maxYValue, dataPoint.steps.intValue);
        }
        
        for(StatisticalDataPointEntity *dataPoint in data) {
            NSUInteger sleepValue = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue +
            dataPoint.sleepPoint46.floatValue + dataPoint.sleepPoint68.floatValue +
            dataPoint.sleepPoint810.floatValue;
            self.maxXRange = MAX(self.maxYRange, sleepValue);
            //            self.maxYRange = MAX(self.maxYRange, dataPoint.steps.intValue);
            
            if(sleepValue > 0) {
                CGFloat steps = sleepValue;
                CGFloat x = [data indexOfObject:dataPoint];
                CGFloat y = [self yWithMinY:0.0f maxY:maxYValue minYRange:0.0f maxYRange:MAX_Y_RANGE / 2 yValue:steps];
                y += MAX_Y_RANGE / 2;
                CGPoint point = CGPointMake(x, y);
                [stepData addObject:[NSValue valueWithCGPoint:point]];
            }
        }
        
        
        DDLogError(@"stepsData: %@", stepData);
        
        [self getSleepDatabase:date];
        
        [self.dataForSteps removeAllObjects];
        
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineColor = [CPTColor colorWithComponentRed:184.0f/255.0f green:113.0f/255.0f blue:22.0f/255.0f alpha:1.0f];
        lineStyle.lineWidth = 1.0f;
        
        [self.dataForSteps removeAllObjects];
        
        if(self.dataForSleep.count > 0) {
            NSMutableArray *data  = [[NSMutableArray alloc] init];
            BOOL isInsideSleep    = NO;
            CGPoint _previousStep = CGPointMake(0, MAX_Y_RANGE / 2);
            CGPoint _currentStep;
//            CGPoint _currentStep  = CGPointMake(0, MAX_Y_RANGE / 2);
            
            for(NSValue *stepValue in stepData) {
                CGPoint stepPoint = [stepValue CGPointValue];
                _currentStep      = stepPoint;
                
                for(NSArray *sleepData in self.dataForSleep) {
                    NSValue *firstValue = [sleepData firstObject];
                    NSValue *lastValue = [sleepData lastObject];
                    CGPoint firstPoint = [firstValue CGPointValue];
                    CGPoint lastPoint = [lastValue CGPointValue];
                    
                    if(stepPoint.x >= firstPoint.x && stepPoint.x <= lastPoint.x)
                    {
                        //check if steps is inside sleep point
                        isInsideSleep = YES;
                        [data addObject:[NSValue valueWithCGPoint:CGPointMake(firstPoint.x, MAX_Y_RANGE / 2)]];
                        [data addObject:[NSValue valueWithCGPoint:CGPointMake(lastPoint.x, MAX_Y_RANGE / 2)]];
                        break;
                    }
                    else if (firstPoint.x >= _previousStep.x && lastPoint.x <= _currentStep.x)
                    {
                        //check if sleep data is inside steps points
                        [data addObject:[NSValue valueWithCGPoint:CGPointMake(firstPoint.x, MAX_Y_RANGE / 2)]];
                        [data addObject:[NSValue valueWithCGPoint:CGPointMake(lastPoint.x, MAX_Y_RANGE / 2)]];
                        break;
                    }
                }
                
                if(!isInsideSleep) {
                    [data addObject:[NSValue valueWithCGPoint:stepPoint]];
                }
                
                isInsideSleep = NO;
                _previousStep = stepPoint;
            }
            
            if(data.count > 0) {
                //DDLogError(@"data: %@", data);
                [self.dataForSteps addObject:[data copy]];
            }
            _dataForStepsPoints = [data copy];
            [self removePlotsWithIdentifer:ACTIGRAPHY_STEPS_IDENTIFIER];
            
            NSUInteger uindex = 0;
            
            for(NSArray *stepsData in self.dataForSteps) {
                SFALinePlot *linePlot = [SFALinePlot linePlot];
                linePlot.index = uindex;
                linePlot.dataDelegate = self;
                linePlot.dataLineStyle = lineStyle;
                linePlot.identifier = ACTIGRAPHY_STEPS_IDENTIFIER;
                linePlot.areaFill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:242.0f/255.0f green:146.0f/255.0f blue:37.0f/255.0f alpha:1.0f]];
                linePlot.areaBaseValue = CPTDecimalFromInt(MAX_Y_RANGE / 2);
                [self.graph addPlot:linePlot toPlotSpace:self.plotSpace];
                uindex++;
                
                NSValue *value = [stepsData objectAtIndex:0];
                CGRect frame = CGRectMake(value.CGPointValue.x * TICK_SPACE, self.graphView.bounds.size.height - 18, 15, 18);
                UIImage *image = [UIImage imageNamed:@"ll_sleep_graph_icons_awake"];
                CPTPlotSpaceAnnotation *annotationAwake = [self annotationWithFrame:frame image:image];
                [self.graph addAnnotation:annotationAwake];
            }
        } else {
            [self removePlotsWithIdentifer:ACTIGRAPHY_STEPS_IDENTIFIER];
            
            _dataForStepsPoints = [NSMutableArray array];
            [self.dataForSteps addObject:[stepData copy]];
            SFALinePlot *linePlot = [SFALinePlot linePlot];
            linePlot.index = 0;
            linePlot.dataDelegate = self;
            linePlot.dataLineStyle = lineStyle;
            linePlot.identifier = ACTIGRAPHY_STEPS_IDENTIFIER;
            linePlot.areaFill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:242.0f/255.0f green:146.0f/255.0f blue:37.0f/255.0f alpha:1.0f]];
            linePlot.areaBaseValue = CPTDecimalFromInt(MAX_Y_RANGE / 2);
            [self.graph addPlot:linePlot toPlotSpace:self.plotSpace];
            
            if([stepData count] > 0) {
                NSValue *value = [stepData objectAtIndex:0];
                CGRect frame = CGRectMake(value.CGPointValue.x * TICK_SPACE, self.graphView.bounds.size.height - 18, 15, 18);
                UIImage *image = [UIImage imageNamed:@"ll_sleep_graph_icons_awake"];
                CPTPlotSpaceAnnotation *annotationAwake = [self annotationWithFrame:frame image:image];
                [self.graph addAnnotation:annotationAwake];
            }
        }
        
        [self _getWorkout:date];
        [self.graph reloadData];
    }
}


- (NSSet *) labelsForDays {
    NSMutableArray *labels = [[NSMutableArray alloc] init];
    NSMutableSet *tickLocations = [[NSMutableSet alloc] init];
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.graph.axisSet;
    NSArray *times = @[@12, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11];
    NSUInteger index = 0;
    NSString *ampm = LS_AM;
    int counter = 0;
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontSize = 7.0f;
    textStyle.color = [CPTColor grayColor];
    
    for(int i=0;i < (144 / 6);i++) {
        counter++;
        CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%@%@", [times objectAtIndex:index], ampm] textStyle:textStyle];
        axisLabel.tickLocation = CPTDecimalFromInt(i * 6);
        axisLabel.offset = 5.0f;
        [tickLocations addObject:[NSNumber numberWithInt:i * 6]];
        [labels addObject:axisLabel];
        
        if(index < [times count] - 1) {
            index ++;
        } else {
            index = 0;
            ampm = LS_PM;
        }
    }
    
    axisSet.xAxis.majorTickLocations = tickLocations;
    return [NSSet setWithArray:[labels copy]];
}

- (void) removePlotsWithIdentifer:(NSString *)identifier {
    NSArray *plots = [self.graph allPlots];
    
    for(CPTPlot *plot in plots) {
        if([plot.identifier isEqual:identifier]) {
            [self.graph removePlot:plot];
        }
    }
}

- (void) removeAnnotations {
    NSArray *annotations = [self.graph annotations];
    
    for(CPTAnnotation *annotation in annotations) {
        [self.graph removeAnnotation:annotation];
    }
}

- (CPTPlotSpaceAnnotation *)annotationWithFrame:(CGRect)frame image:(UIImage *)image {
    CPTPlotSpaceAnnotation *annotationDivider = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.plotSpace anchorPlotPoint:nil];
    UIImage *imageDivider = [UIImage imageNamed:@"ll_sleep_graph_img_division"];
    CPTImage *imageCpt = [CPTImage imageWithCGImage:imageDivider.CGImage scale:imageDivider.scale];
    CGRect frameDivider = CGRectMake(frame.origin.x + frame.size.width / 2 - 1, 22, imageDivider.size.width, self.graphView.bounds.size.height);
    CPTBorderedLayer *layerDivider = [[CPTBorderedLayer alloc] initWithFrame:frameDivider];
    layerDivider.fill = [CPTFill fillWithImage:imageCpt];
    annotationDivider.contentLayer = layerDivider;
    [self.graph addAnnotation:annotationDivider];
    
    CPTPlotSpaceAnnotation *annotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.plotSpace anchorPlotPoint:nil];
    CPTBorderedLayer *layer = [[CPTBorderedLayer alloc] initWithFrame:frame];
    CPTImage *cptImage = [CPTImage imageWithCGImage:image.CGImage scale:image.scale];
    layer.fill = [CPTFill fillWithImage:cptImage];
    annotation.contentLayer = layer;
    return annotation;
}

- (void)reloadView
{
    UIView *parent = self.view.superview;
    self.constraints = [self.view constraints].copy;
    [self.view removeConstraints:self.constraints]; //remove constraints
    [self.view removeFromSuperview]; //remove from superview
    self.view = nil; // unloads the view
    [parent addSubview:self.view]; //reload view
    [parent setNeedsDisplay];
    [parent setNeedsLayout];
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

#pragma mark - Public Methods
- (void) setContentsWithDate:(NSDate *)date {
    /*[self removeAnnotations];
     self.sleepRecord = [self _fetchSleepWithDate:date].copy;
     [self getDataForDay:date];*/
    self.timeView.hidden = NO;
    self.imagePlayHead.hidden = YES;
    self.viewGraphYAxis.hidden = YES;
    [self.graphViewController setContentsWithDate:date];
    //[self getSleepRecordForDate:date];
}

- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year
{
    self.timeView.hidden = YES;
    self.imagePlayHead.hidden = NO;
    self.viewGraphYAxis.hidden = NO;
    [self.graphViewController setContentsWithWeek:week ofYear:year];
}

- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year
{
    self.timeView.hidden = YES;
    self.imagePlayHead.hidden = NO;
    self.viewGraphYAxis.hidden = NO;
    [self.graphViewController setContentsWithMonth:month ofYear:year];
}

- (void)setContentsWithYear:(NSInteger)year
{
    self.timeView.hidden = YES;
    self.imagePlayHead.hidden = NO;
    self.viewGraphYAxis.hidden = NO;
    [self.graphViewController setContentsWithYear:year];
}

#pragma mark - SFALinePlotDelegate
- (NSInteger) numberOfPointsForLinePlot:(SFALinePlot *)linePlot {
    if([linePlot.identifier isEqual:ACTIGRAPHY_STEPS_IDENTIFIER]) {
        if(self.dataForSteps.count > 0)
            return [[self.dataForSteps objectAtIndex:linePlot.index] count];
    } else if([linePlot.identifier isEqual:ACTIGRAPHY_SLEEP_IDENTIFIER]) {
        if(self.dataForSleep.count > 0)
            return [[self.dataForSleep objectAtIndex:linePlot.index] count];
    } else if ([linePlot.identifier isEqual:ACTIGRAPHY_WORKOUT_IDENTIFER]) {
        if (_dataForWorkoutSteps.count > 0)
            return [[_dataForWorkoutSteps objectAtIndex:linePlot.index] count];
    } else if([linePlot.identifier isEqual:ACTIGRAPHY_HORIZONTAL_LINE_IDENTIFIER])
        return [self.dataForHorizontalLine count];
    return 0;
}

- (CGPoint) linePlot:(SFALinePlot *)linePlot pointAtIndex:(NSInteger)index {
    if([linePlot.identifier isEqual:ACTIGRAPHY_STEPS_IDENTIFIER]) {
        NSArray *data = [self.dataForSteps objectAtIndex:linePlot.index];
        NSValue *value = [data objectAtIndex:index];
        CGPoint point = [value CGPointValue];
        return point;
    } else if([linePlot.identifier isEqual:ACTIGRAPHY_SLEEP_IDENTIFIER]) {
        NSArray *data = [self.dataForSleep objectAtIndex:linePlot.index];
        NSValue *value = [data objectAtIndex:index];
        CGPoint point = [value CGPointValue];
        return point;
    } else if ([linePlot.identifier isEqual:ACTIGRAPHY_WORKOUT_IDENTIFER]) {
        NSArray *_data  = [self.dataForWorkoutSteps objectAtIndex:linePlot.index];
        NSValue *_value = [_data objectAtIndex:index];
        CGPoint _point  = [_value CGPointValue];
        return _point;
    } else if([linePlot.identifier isEqual:ACTIGRAPHY_HORIZONTAL_LINE_IDENTIFIER]) {
        NSValue *value = [self.dataForHorizontalLine objectAtIndex:index];
        CGPoint point = [value CGPointValue];
        return point;
    }
    return CGPointMake(0, 0);
}

- (CPTPlotSymbol *)symbolForScatterPlot:(SFALinePlot *)linePlot pointAtIndex:(NSInteger)index {
    CPTPlotSymbol *plotSymbol = nil;
    
    if([linePlot.identifier isEqual:ACTIGRAPHY_STEPS_IDENTIFIER]) {
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineWidth = 0;
        lineStyle.lineColor = [CPTColor whiteColor];
        plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        
        CPTImage *image = [CPTImage imageWithCGImage:[UIImage imageNamed:@"ll_sleep_graph_img_datapoint_orange"].CGImage];
        plotSymbol.fill = [CPTFill fillWithImage:image.copy];
        plotSymbol.lineStyle = lineStyle;
        plotSymbol.size = CGSizeMake(5, 5);
    } else if([linePlot.identifier isEqual:ACTIGRAPHY_SLEEP_IDENTIFIER]) {
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineWidth = 0;
        lineStyle.lineColor = [CPTColor whiteColor];
        plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        
        CPTImage *image = [CPTImage imageWithCGImage:[UIImage imageNamed:@"ll_sleep_graph_img_datapoint_blue"].CGImage];
        plotSymbol.fill = [CPTFill fillWithImage:image.copy];
        plotSymbol.lineStyle = lineStyle;
        plotSymbol.size = CGSizeMake(5, 5);
    }
    return plotSymbol;
}

#pragma mark - CPTPlotSpaceDelegate
- (BOOL) plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(UIEvent *)event atPoint:(CGPoint)point {
    if([self.plotDelegate conformsToProtocol:@protocol(SFAActigraphyPlotTouchEvent)])
        [self.plotDelegate plotSpace:space handleTouchDownEvent:event pointIndex:point];
    return YES;
}

- (BOOL) plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(UIEvent *)event atPoint:(CGPoint)point {
    if([self.plotDelegate conformsToProtocol:@protocol(SFAActigraphyPlotTouchEvent)])
        [self.plotDelegate plotspace:space handleTouchUpEvent:event pointIndex:point];
    return YES;
}

- (BOOL) plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(UIEvent *)event atPoint:(CGPoint)point {
    if([self.plotDelegate conformsToProtocol:@protocol(SFAActigraphyPlotTouchEvent)])
        [self.plotDelegate plotspace:space handleTouchUpEvent:event pointIndex:point];
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (_isActigraphy) ? 0 : self.sleepRecord.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SleepDatabaseEntity *sleepDatabaseEntity = [self.sleepRecord objectAtIndex:indexPath.row];
    SFASleepDataCell *sleepDataCell = [tableView dequeueReusableCellWithIdentifier:@"SleepDataCell"];
    
    sleepDataCell.sleepDuration.text = [NSString stringWithFormat:@"%02ih %imin", sleepDatabaseEntity.sleepDuration.integerValue/60, sleepDatabaseEntity.sleepDuration.integerValue % 60];
    
    /*NSString *sleepTime = nil;
    NSString *ampm = nil;
    
    if(sleepDatabaseEntity.sleepStartHour.integerValue > 12) {
        sleepTime = [NSString stringWithFormat:@"%02i:", sleepDatabaseEntity.sleepStartHour.integerValue % 12];
        ampm = LS_PM;
    } else {
        sleepTime = [NSString stringWithFormat:@"%02i:", sleepDatabaseEntity.sleepStartHour.integerValue];
        ampm = LS_AM;
    }
    
    sleepTime = [sleepTime stringByAppendingString:[NSString stringWithFormat:@"%02i %@ - ", sleepDatabaseEntity.sleepStartMin.integerValue, ampm]];
    
    if(sleepDatabaseEntity.sleepEndHour.integerValue > 12) {
        sleepTime = [sleepTime stringByAppendingString:[NSString stringWithFormat:@"%02i:", sleepDatabaseEntity.sleepEndHour.integerValue % 12]];
        ampm = LS_PM;
    } else {
        sleepTime = [sleepTime stringByAppendingString:[NSString stringWithFormat:@"%02i:", sleepDatabaseEntity.sleepEndHour.integerValue]];
        ampm = LS_AM;
    }
    
    sleepTime = [sleepTime stringByAppendingString:[NSString stringWithFormat:@"%02i %@", sleepDatabaseEntity.sleepEndMin.integerValue, ampm]];*/
    
    TimeDate *timeDate = [TimeDate getData];
    
    NSString *startTime = [self formatTimeWithHourFormat:timeDate.hourFormat hour:sleepDatabaseEntity.sleepStartHour.integerValue minute:sleepDatabaseEntity.sleepStartMin.integerValue];
     NSString *endTime = [self formatTimeWithHourFormat:timeDate.hourFormat hour:sleepDatabaseEntity.sleepEndHour.integerValue minute:sleepDatabaseEntity.sleepEndMin.integerValue];
    
    if (timeDate.hourFormat == _24_HOUR) {
        startTime = [startTime removeTimeHourFormat];
        endTime = [endTime removeTimeHourFormat];
    }
    
    sleepDataCell.sleepTime.text = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
    
    return sleepDataCell;
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UITableViewCell new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:@"SleepLogHeaderCell"];
    return _cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (self.isActigraphy) ? 1 : tableView.sectionHeaderHeight;
}

#pragma mark - Actigraphy graph view controller delegate
- (void)didChangeActiveCount:(NSNumber *)activeTime
{
    // special case for French since time = fois and times = fois
    self.labelActiveCount.text = LANGUAGE_IS_FRENCH ? [NSString stringWithFormat:@"%@ fois", activeTime] : [NSString stringWithFormat:@"%@ time%@", activeTime, (activeTime.integerValue > 1 ? @"s" : @"s")];
}

- (void)didChangeDeepSleepCount:(NSNumber *)deepSleepCount
{
    // special case for French since time = fois and times = fois
    self.labelDeepSleepCount.text = LANGUAGE_IS_FRENCH ? [NSString stringWithFormat:@"%@ fois", deepSleepCount] : [NSString stringWithFormat:@"%@ time%@", deepSleepCount, (deepSleepCount.integerValue > 1 ? @"s" : @"s")];
}

- (void)didChangeLightSleepCount:(NSNumber *)lightSleepCount
{
    // special case for French since time = fois and times = fois
    self.labelLightSleepCount.text = LANGUAGE_IS_FRENCH ? [NSString stringWithFormat:@"%@ fois", lightSleepCount] : [NSString stringWithFormat:@"%@ time%@", lightSleepCount, (lightSleepCount.integerValue > 1 ? @"s" : @"s")];
}

- (void)didChangeWorkoutCount:(NSNumber *)workoutCount
{
    // special case for French since time = fois and times = fois
    self.labelWorkoutCount.text = LANGUAGE_IS_FRENCH ? [NSString stringWithFormat:@"%@ fois", workoutCount] : [NSString stringWithFormat:@"%@ time%@", workoutCount, (workoutCount.integerValue > 1 ? @"s" : @"s")];
}

- (void)didChangeTotalActiveTime:(NSString *)totalActiveTime
{
    self.totalActiveTime.text = totalActiveTime;
}

- (void)didChangeTotalSleepTime:(NSString *)totalSleepTime
{
    self.totalSleepTime.text = totalSleepTime;
}

- (void)didChangeTotalSedentaryTime:(NSString *)totalSedentaryTime
{
    self.totalSedentaryTime.text = totalSedentaryTime;
}

- (void)didChangeTotalActiveTimeHour:(NSInteger)totalActiveTimeHour
{
    self.totalSleepTimeHr.text = [NSString stringWithFormat:@"%i", totalActiveTimeHour];
}

- (void)didChangeTotalActiveTimeMinute:(NSInteger)totalActiveTimeMinute
{
    self.totalSleepTimeMin.text = [NSString stringWithFormat:@"%i", totalActiveTimeMinute];
}

- (void)didChangeCurrentDay:(NSString *)currentDay
{
    if ((self.calendarController.calendarMode == SFACalendarMonth ||
        self.calendarController.calendarMode == SFACalendarYear) ||
        self.calendarController.calendarMode == SFACalendarWeek) {
        self.labelMonthRange.text = currentDay;
    }
}

#pragma mark - Private Methods

- (UIColor *)colorForPercent:(CGFloat)percent
{
    if (percent >= 100.0f)
    {
        return PERCENT_100_COLOR;
    }
    else if (percent >= 75.0f)
    {
        return PERCENT_75_COLOR;
    }
    else if (percent >= 50.0f)
    {
        return PERCENT_50_COLOR;
    }
    else if (percent >= 25.0f)
    {
        return PERCENT_25_COLOR;
    }
    
    return PERCENT_0_COLOR;
}

- (UIImage *)goalImageForPercent:(CGFloat)percent
{
    if (percent >= 100.0f)
    {
        return [UIImage imageNamed:@"FitnessResultsIconGoal100"];
    }
    else if (percent >= 75.0f)
    {
        return [UIImage imageNamed:@"FitnessResultsIconGoal75"];
    }
    else if (percent >= 50.0f)
    {
        return [UIImage imageNamed:@"FitnessResultsIconGoal50"];
    }
    else if (percent >= 25.0f)
    {
        return [UIImage imageNamed:@"FitnessResultsIconGoal25"];
    }
    
    return [UIImage imageNamed:@"FitnessResultsIconGoal0"];
}


- (void)getSleepRecordForDate:(NSDate *)date
{
    NSDate *yesterday           = [date dateByAddingTimeInterval:-DAY_SECONDS];
    NSArray *yesterdaySleeps    = [SleepDatabaseEntity sleepDatabaseForDate:yesterday];
    NSArray *sleeps             = [SleepDatabaseEntity sleepDatabaseForDate:date];
    NSMutableArray *sleepRecord = [NSMutableArray new];
    NSInteger hour              = 0;
    CGFloat minute              = 0;
    _sleepValue                 = 0;
    
    for (SleepDatabaseEntity *sleep in yesterdaySleeps)
    {
        NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6) + (sleep.sleepStartMin.integerValue / 10);
//        NSInteger endIndex      = (sleep.sleepEndHour.integerValue * 6) + (sleep.sleepEndMin.integerValue / 10);
        NSInteger endIndex      = sleep.adjustedSleepEndMinutes/10;
        
        if (startIndex >= endIndex || sleep.sleepEndHour.integerValue == 23)
        {
            _sleepValue += sleep.sleepDuration.integerValue;
            [sleepRecord addObject:sleep];
        }
    }
    
    for (SleepDatabaseEntity *sleep in sleeps)
    {
        NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6) + (sleep.sleepStartMin.integerValue / 10);
        NSInteger endIndex      = (sleep.sleepEndHour.integerValue * 6) + (sleep.sleepEndMin.integerValue / 10);
        endIndex                = endIndex >= DAY_DATA_MAX_COUNT - 1 ? DAY_DATA_MAX_COUNT - 1 : endIndex;
        
        if (startIndex < endIndex && sleep.sleepEndHour.integerValue < 23)
        {
            _sleepValue += sleep.sleepDuration.integerValue;
            [sleepRecord addObject:sleep];
        }
    }
    
    hour            = _sleepValue / 60;
    minute          = _sleepValue - (hour * 60);
    
    self.totalSleepTimeHr.text  = [NSString stringWithFormat:@"%i", hour];
    self.totalSleepTimeMin.text = [NSString stringWithFormat:@"%02.f", minute];
    self.sleepRecord            = sleepRecord.copy;
    self.tableView.hidden       = (sleepRecord.count < 1 && !_isActigraphy);
    
    //Set goal
    NSInteger _percent = 0;
    NSInteger _goalHour = 0;
    CGFloat _goalMinute = 0;
    CGFloat sleepGoal = 0;
    
    if ([date isToday]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [userDefaults objectForKey:SLEEP_SETTING];
        SleepSetting *_sleepSetting = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        sleepGoal = _sleepSetting.sleep_goal_lo + (_sleepSetting.sleep_goal_hi << 8);
        
        if(sleepGoal > 0) {
            _percent = (_sleepValue / sleepGoal) * 100;
            //_percent = floor(_percent);
        }
        
        _goalHour       = floorf(sleepGoal / 60.0f);
        _goalMinute     = floorf(fmodf(sleepGoal, 60.0f));
    } else {
        GoalsEntity *_goalsEntity   = [SFAGoalsData goalsFromNearestDate:[NSDate date]
                                                              macAddress:[self macAddress]
                                                           managedObject:[[JDACoreData sharedManager] context]];
        
        sleepGoal = _goalsEntity.sleep.floatValue;
        
        if(sleepGoal > 0) {
            _percent = (_sleepValue / sleepGoal) * 100;
            //_percent = floor(_percent);
        }
        
        //_percent                    = (_percent > 100) ? 100 : _percent;
        _goalHour         = floorf(_goalsEntity.sleep.floatValue / 60.0f);
        _goalMinute         = floorf(fmodf(_goalsEntity.sleep.floatValue, 60.0f));
    }
    
    self.labelGoal.text                         = [NSString stringWithFormat:@"%ih %02.fm", _goalHour, _goalMinute];
    self.labelGoalPercent.text                  = [NSString stringWithFormat:@"%i%%", _percent];
    self.labelGoalPercent.textColor             = [self colorForPercent:_percent];
    self.imageGoal.image                        = [self goalImageForPercent:_percent];
    self.viewProgressBar.backgroundColor        = [self colorForPercent:_percent];
    
    
    if(sleepGoal > 0) {
        self.progressViewWidthConstriant.constant   = (_sleepValue / sleepGoal) *
                                                                self.viewProgressBackground.frame.size.width;
    } else {
        self.progressViewWidthConstriant.constant = 0;
    }

    [self.tableView reloadData];
}

- (void)changeDateRange:(SFADateRange)dateRange
{
    if (dateRange == SFADateRangeDay)
    {
        self.pickerView.selectedIndex = 0;
    }
    else if (dateRange == SFADateRangeWeek)
    {
        self.pickerView.selectedIndex = 1;
    }
    else if (dateRange == SFADateRangeMonth)
    {
        self.pickerView.selectedIndex = 2;
    }
    else if (dateRange == SFADateRangeYear)
    {
        self.pickerView.selectedIndex = 3;
    }
}

#pragma mark - SFASleepLogDataViewControllerDelegate Methods

- (void)sleepLogDataViewController:(SFASleepLogDataViewController *)viewController didUpdateSleepDatabaseEntity:(SleepDatabaseEntity *)sleepDatabaseEntity
{
    [self getSleepRecordForDate:self.calendarController.selectedDate];
}

#pragma mark - Lazy loading of properties

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

@end
