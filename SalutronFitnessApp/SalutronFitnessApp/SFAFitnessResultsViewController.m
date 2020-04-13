//
//  SFACaloriesViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/2/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "JDAPickerView.h"
#import "JDAKeyboardAccessory.h"

#import "UISegmentedControl+Theme.h"
#import "NSDate+Comparison.h"

#import "SFASalutronFitnessAppDelegate.h"

#import "SFAFitnessResultsViewController.h"
#import "SFAMainViewController.h"
#import "SFAFitnessGraphViewController.h"
#import "SFANotesViewController.h"

#import "NoteEntity.h"
#import "GoalsEntity.h"
#import "SFAGoalsData.h"

#import "JDACoreData.h"

#import "SalutronUserProfile+Data.h"
#import "SFASlidingViewController.h"
#import "UIViewController+Helper.h"

#import "TimeDate+Data.h"

#define FITNESS_GRAPH_SEGUE_IDENTIFIER              @"FitnessGraph"
#define FITNESS_RESULTS_TO_NOTES_SEGUE_IDENTIFIER   @"FitnessResultsToNotes"

#define CALORIES_ACTIVE_IMAGE   [UIImage imageNamed:@"FitnessResultsCaloriesActive"]
#define HEART_RATE_ACTIVE_IMAGE [UIImage imageNamed:@"FitnessResultsHeartRateActive"]
#define STEPS_ACTIVE_IMAGE      [UIImage imageNamed:@"FitnessResultsStepsActive"]
#define DISTANCE_ACTIVE_IMAGE   [UIImage imageNamed:@"FitnessResultsDistanceActive"]
#define INACTIVE_IMAGE          [UIImage imageNamed:@"FitnessResultsInactive"]

#define CLEAR_COLOR         [UIColor clearColor]
#define LIGHT_GRAY_COLOR    [UIColor lightGrayColor]
#define WHEEL_0_COLOR       [UIColor colorWithRed:217/255.0f green:189/255.0f blue:55/255.0f alpha:1]
#define WHEEL_25_COLOR      [UIColor colorWithRed:229/255.0f green:210/255.0f blue:80/255.0f alpha:1]
#define WHEEL_50_COLOR      [UIColor colorWithRed:144/255.0f green:204/255.0f blue:41/255.0f alpha:1]
#define WHEEL_75_COLOR      [UIColor colorWithRed:104/255.0f green:196/255.0f blue:89/255.0f alpha:1]
#define WHEEL_100_COLOR     [UIColor colorWithRed:75/255.0f green:157/255.0f blue:83/255.0f alpha:1]

static const NSUInteger progressViewWidth = 60;

@interface UILabel (helper)

- (void)setHiddenWithNumber:(NSNumber *)number;

@end

@implementation UILabel (helper)

- (void)setHiddenWithNumber:(NSNumber *)number
{
    self.hidden = number.boolValue;
}

@end

@interface SFAFitnessResultsViewController () <UITableViewDataSource, UITableViewDelegate, SFAFitnessGraphViewControllerDelegate, SFANotesViewControllerDelegate, JDAPickerViewDelegate>
{
    SalutronUserProfile     *_userProfile;
}

@property (weak, nonatomic) IBOutlet UIView             *viewSegmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewVerticalSpace;
@property (weak, nonatomic) IBOutlet UIImageView        *imagePlayeHead;
@property (weak, nonatomic) IBOutlet UIView             *leftGraphView;
@property (weak, nonatomic) IBOutlet UIView             *rightGraphView;
@property (readwrite, nonatomic) CGFloat                oldTableViewVerticalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playHeaderHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphBackgroundHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphXBackgroundTopConstraint;

@property (nonatomic, strong) JDAPickerView             *pickerView;

// Graph View Controller
@property (weak, nonatomic) SFAFitnessGraphViewController *graphViewController;

// Core Data
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// Data
@property (strong, nonatomic) NSArray *calories;
@property (strong, nonatomic) NSArray *heartRate;
@property (strong, nonatomic) NSArray *steps;
@property (strong, nonatomic) NSArray *distance;

@property (readwrite, nonatomic) NSInteger month;
@property (readwrite, nonatomic) NSInteger year;

@property (strong, nonatomic) NSArray *notes;

// Ranges
@property (strong, nonatomic) NSNumber *caloriesMaxY;
@property (strong, nonatomic) NSNumber *heartRateMaxY;
@property (strong, nonatomic) NSNumber *stepsMaxY;
@property (strong, nonatomic) NSNumber *distanceMaxY;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (readwrite, nonatomic) int    stepsGoal;
@property (readwrite, nonatomic) double distanceGoal;
@property (readwrite, nonatomic) int    caloriesGoal;

@end


@implementation SFAFitnessResultsViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initializeObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initializeViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:FITNESS_GRAPH_SEGUE_IDENTIFIER])
    {
        self.graphViewController            = (SFAFitnessGraphViewController *)segue.destinationViewController;
        self.graphViewController.delegate   = self;
    }
    else if ([segue.identifier isEqualToString:FITNESS_RESULTS_TO_NOTES_SEGUE_IDENTIFIER])
    {
        SFANotesViewController *viewController  = (SFANotesViewController *)segue.destinationViewController;
        viewController.delegate                 = self;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        self.tableViewVerticalSpace.constant    = _oldTableViewVerticalSpace;
        self.viewSegmentedControl.hidden        = NO;
        self.activeTimeLabel.hidden             = YES;
        self.imagePlayeHead.hidden              = YES;
        self.leftGraphView.hidden               = NO;
        self.rightGraphView.hidden              = NO;
        self.landscapeMetricsView.hidden        = YES;
        
        [self.textFieldDateRange resignFirstResponder];
        [self addGraphType:self.graphType];
        
        if (self.buttonCalories.tag && self.graphType != SFAGraphTypeCalories) {
            [self removeGraphType:SFAGraphTypeCalories];
        }
        
        if (self.buttonDistance.tag && self.graphType != SFAGraphTypeDistance) {
            [self removeGraphType:SFAGraphTypeDistance];
        }
        
        if (self.buttonHeartRate.tag && self.graphType != SFAGraphTypeHeartRate) {
            [self removeGraphType:SFAGraphTypeHeartRate];
        }
        
        if (self.buttonSteps.tag && self.graphType != SFAGraphTypeSteps) {
            [self removeGraphType:SFAGraphTypeSteps];
        }
    }
    else
    {
        self.tableViewVerticalSpace.constant    = 0;
        self.viewSegmentedControl.hidden        = YES;
        self.activeTimeLabel.hidden             = NO;
        self.imagePlayeHead.hidden              = NO;
        self.leftGraphView.hidden               = YES;
        self.rightGraphView.hidden              = YES;
        self.landscapeMetricsView.hidden        = NO;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.notes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.notes.count > section)
    {
        NSArray *notes = self.notes[section];
        return notes.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.notes.count > indexPath.section)
    {
        NSArray *notes = self.notes[indexPath.section];
        
        if (notes.count > indexPath.row)
        {
            NoteEntity *note        = notes[indexPath.row];
            UITableViewCell *cell   = [UITableViewCell new];
            cell.textLabel.text     = note.note;
            
            return cell;
        }
    }
    
    return [UITableViewCell new];
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
    
    if ([self.delegate conformsToProtocol:@protocol(SFAFitnessResultsViewControllerDelegate)])
    {
        [self.delegate fitnessResultsViewController:self didChangeDateRange:dateRange];
    }
}

#pragma mark - Getters

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext)
    {
        SFASalutronFitnessAppDelegate *appDelegate  = [UIApplication sharedApplication].delegate;
        _managedObjectContext                       = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

#pragma mark - SFAFitnessGraphViewControllerDelegate Methods

- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didChangeTime:(NSString *)time
{
    self.activeTimeLabel.text = time;
}

- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didChangeCalories:(NSInteger)calories
{
    /*if (self.buttonCalories.selected)
     {
     self.caloriesLabel.text = [NSString stringWithFormat:@"%i", calories];
     }*/
    
    if (/*self.graphType == SFAGraphTypeCalories || */self.buttonCalories.tag)
    {
        self.caloriesLabel.text = [NSString stringWithFormat:@"%i", calories];
    }
}

- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didChangeDistance:(CGFloat)distance
{
    /*if (self.buttonDistance.selected)
     {
     if (_userProfile.unit == IMPERIAL) {
     self.distanceLabel.text = [NSString stringWithFormat:@"%.2f", (distance * 0.621371)];
     }
     else {
     self.distanceLabel.text = [NSString stringWithFormat:@"%.2f", distance];
     }
     }*/
    
    if (/*self.graphType == SFAGraphTypeDistance || */self.buttonDistance.tag)
    {
        if (_userProfile.unit == IMPERIAL) {
            self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", (distance * 0.621371)];
        }
        else {
            self.distanceLabel.text = [NSString stringWithFormat:@"%.2f km", distance];
        }
    }
}

- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didChangeHeartRate:(NSInteger)heartRate
{
    /*if (self.buttonHeartRate.selected)
     {
     self.heartRateLabel.text = [NSString stringWithFormat:@"%i", heartRate];
     }*/
    
    if (/*self.graphType == SFAGraphTypeHeartRate || */self.buttonHeartRate.tag)
    {
        self.heartRateLabel.text = [NSString stringWithFormat:@"%i", heartRate];
        //self.valueLabel.text = [NSString stringWithFormat:@"%i", heartRate];
    }
}

- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didChangeSteps:(NSInteger)steps
{
    /*if (self.buttonSteps.selected)
     {
     self.stepsLabel.text = [NSString stringWithFormat:@"%i", steps];
     }*/
    
    if (/*self.graphType == SFAGraphTypeSteps || */self.buttonSteps.tag)
    {
        self.stepsLabel.text = [NSString stringWithFormat:@"%i", steps];
    }
}

- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didGetTotalCalories:(NSInteger)calories
{
    CGFloat goal                                = [self goalForGraphType:SFAGraphTypeCalories];
    //goal                                        *= [self goalMultiplier];
    CGFloat progress                            = goal != 0 ? (calories / goal > 1 ? 1 : calories / goal): 0;
    CGRect frame                                = self.caloriesProgressView.frame;
    frame.size.width                            = progress * progressViewWidth;
    self.caloriesProgressView.frame             = frame;
    progress                                    *= 100.0f;
    self.caloriesProgressView.backgroundColor   = [self colorForPercent:progress];
    
    if (self.graphType == SFAGraphTypeCalories) {
        CGFloat goal = [self goalForGraphType:self.graphType];
        //goal *= [self goalMultiplier];
        [self setGoalsViewWithValue:calories goal:goal];
    }
}

- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didGetTotalHeartRate:(NSInteger)heartRate
{
    if (self.graphType == SFAGraphTypeHeartRate) {
        CGFloat goal = [self goalForGraphType:self.graphType];
        //goal *= [self goalMultiplier];
        [self setGoalsViewWithValue:heartRate goal:goal];
    }
}

- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didGetTotalSteps:(NSInteger)steps
{
    CGFloat goal                            = [self goalForGraphType:SFAGraphTypeSteps];
    //goal                                    *= [self goalMultiplier];
    CGFloat progress                        = goal != 0 ? (steps / goal > 1 ? 1 : steps / goal): 0;
    CGRect frame                            = self.stepsProgressView.frame;
    frame.size.width                        = progress * progressViewWidth;
    self.stepsProgressView.frame            = frame;
    progress                                *= 100.0f;
    self.stepsProgressView.backgroundColor  = [self colorForPercent:progress];
    
    if (self.graphType == SFAGraphTypeSteps) {
        CGFloat goal = [self goalForGraphType:self.graphType];
        //goal *= [self goalMultiplier];
        [self setGoalsViewWithValue:steps goal:goal];
    }
}

- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didGetTotalDistance:(CGFloat)distance
{
    if (_userProfile.unit == IMPERIAL) {
        distance *= 0.621371;
    }
    
    CGFloat goal                                = [self goalForGraphType:SFAGraphTypeDistance];
    //goal                                        *= [self goalMultiplier];
    CGFloat progress                            = goal != 0 ? (distance / goal > 1 ? 1 : distance / goal):0;
    CGRect frame                                = self.distanceProgressView.frame;
    frame.size.width                            = progress * progressViewWidth;
    self.distanceProgressView.frame             = frame;
    progress                                    *= 100.0f;
    self.distanceProgressView.backgroundColor   = [self colorForPercent:progress];
    
    if (self.graphType == SFAGraphTypeDistance) {
        CGFloat goal = [self goalForGraphType:self.graphType];
        //goal *= [self goalMultiplier];
        [self setGoalsViewWithValue:distance goal:goal];
    }
}

#pragma mark - SFANoteViewControllerDelegate Methods

- (void)notesViewController:(SFANotesViewController *)viewController didAddNote:(NSString *)note
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:self.calendarController.selectedDate];
    JDACoreData *coreData           = [JDACoreData sharedManager];
    NoteEntity *noteEntity          = [coreData insertNewObjectWithEntityName:NOTE_ENTITY];
    noteEntity.date                 = [calendar dateFromComponents:components];
    noteEntity.note                 = note;
    
    [coreData save];
    [self getNotesForDate:self.calendarController.selectedDate];
}

#pragma mark - IBAction Methods

- (IBAction)didChangeDateRange:(id)sender
{
    UISegmentedControl *segmentedControler  = (UISegmentedControl *)sender;
    NSInteger selectedIndex                 = segmentedControler.selectedSegmentIndex;
    self.pickerView.selectedIndex           = selectedIndex;
    SFADateRange dateRange                  = SFADateRangeDay;
    
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
    
    if ([self.delegate conformsToProtocol:@protocol(SFAFitnessResultsViewControllerDelegate)])
    {
        [self.delegate fitnessResultsViewController:self didChangeDateRange:dateRange];
    }
}

- (IBAction)caloriesButtonPressed:(id)sender
{
    UIButton *button = sender;
    
    if (button.tag)
    {
        if (self.graphViewController.barPlotCount > 1)
        {
            [self removeGraphType:SFAGraphTypeCalories];
            
            if ([self.delegate conformsToProtocol:@protocol(SFAFitnessResultsViewControllerDelegate)])
            {
                [self.delegate fitnessResultsViewController:self didRemoveGraphType:SFAGraphTypeCalories];
            }
        }
    }
    else
    {
        [self addGraphType:SFAGraphTypeCalories];
        
        if ([self.delegate conformsToProtocol:@protocol(SFAFitnessResultsViewControllerDelegate)])
        {
            [self.delegate fitnessResultsViewController:self didAddGraphType:SFAGraphTypeCalories];
        }
    }
}

- (IBAction)heartRateButtonPressed:(id)sender
{
    UIButton *button = sender;
    
    if (button.tag)
    {
        if (self.graphViewController.barPlotCount > 1)
        {
            [self removeGraphType:SFAGraphTypeHeartRate];
            
            if ([self.delegate conformsToProtocol:@protocol(SFAFitnessResultsViewControllerDelegate)])
            {
                [self.delegate fitnessResultsViewController:self didRemoveGraphType:SFAGraphTypeHeartRate];
            }
        }
    }
    else
    {
        [self addGraphType:SFAGraphTypeHeartRate];
        
        if ([self.delegate conformsToProtocol:@protocol(SFAFitnessResultsViewControllerDelegate)])
        {
            [self.delegate fitnessResultsViewController:self didAddGraphType:SFAGraphTypeHeartRate];
        }
    }
}

- (IBAction)stepsButtonPressed:(id)sender
{
    UIButton *button = sender;
    
    if (button.tag)
    {
        if (self.graphViewController.barPlotCount > 1)
        {
            [self removeGraphType:SFAGraphTypeSteps];
            
            if ([self.delegate conformsToProtocol:@protocol(SFAFitnessResultsViewControllerDelegate)])
            {
                [self.delegate fitnessResultsViewController:self didRemoveGraphType:SFAGraphTypeSteps];
            }
        }
    }
    else
    {
        [self addGraphType:SFAGraphTypeSteps];
        
        if ([self.delegate conformsToProtocol:@protocol(SFAFitnessResultsViewControllerDelegate)])
        {
            [self.delegate fitnessResultsViewController:self didAddGraphType:SFAGraphTypeSteps];
        }
    }
}

- (IBAction)distanceButtonPressed:(id)sender
{
    UIButton *button = sender;
    
    if (button.tag)
    {
        if (self.graphViewController.barPlotCount > 1)
        {
            [self removeGraphType:SFAGraphTypeDistance];
            
            if ([self.delegate conformsToProtocol:@protocol(SFAFitnessResultsViewControllerDelegate)])
            {
                [self.delegate fitnessResultsViewController:self didRemoveGraphType:SFAGraphTypeDistance];
            }
        }
    }
    else
    {
        [self addGraphType:SFAGraphTypeDistance];
        
        if ([self.delegate conformsToProtocol:@protocol(SFAFitnessResultsViewControllerDelegate)])
        {
            [self.delegate fitnessResultsViewController:self didAddGraphType:SFAGraphTypeDistance];
        }
    }
}

#pragma mark - Private Methods

- (NSString *)graphStringForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return @"CALORIES";
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        return @"DISTANCE";
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        return LS_HEART_RATE_ALL_CAPS;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        return LS_STEPS_ALL_CAPS;
    }
    
    return nil;
}

- (UIImage *)graphImageForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return [UIImage imageNamed:@"FitnessResultsIconCalories"];
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        return [UIImage imageNamed:@"FitnessResultsIconDistance"];
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        return [UIImage imageNamed:@"FitnessResultsIconHeartRate"];
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        return [UIImage imageNamed:@"FitnessResultsIconSteps"];
    }
    
    return nil;
}

- (void)initializeObjects
{
    _userProfile = [SalutronUserProfile getData];
    
    // Segmented Control
    [self.segmentedControl themeWithSegmentedControlTheme:UISegmentedControlThemeGreen];
    
    TimeDate *timeDate = [TimeDate getData];
    NSString *initialTimeLabelText = @"12:00 AM";
    
    if (LANGUAGE_IS_FRENCH && timeDate.hourFormat == _24_HOUR) {
        initialTimeLabelText = [initialTimeLabelText stringByReplacingOccurrencesOfString:@"12:" withString:@"00h"];
    }
    
    initialTimeLabelText = [initialTimeLabelText stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM];
    
    // Active time
    self.activeTimeLabel.text = initialTimeLabelText;
    
    // Data
    self.caloriesLabel.text     = @"...";
    self.heartRateLabel.text    = @"...";
    self.stepsLabel.text        = @"...";
    self.distanceLabel.text     = @"...";
    
    //
    self.pickerView = [[JDAPickerView alloc] initWithArray:@[LS_DAILY, LS_WEEKLY, LS_MONTHLY, LS_YEARLY]
                                                  delegate:self];
    self.pickerView.textField = self.textFieldDateRange;
    self.textFieldDateRange.inputView = self.pickerView;
    JDAKeyboardAccessory *keyboardAccessory = [[JDAKeyboardAccessory alloc] initWithDoneAccessoryWithBarStyle:UIBarStyleDefault];
    keyboardAccessory.currentView = self.textFieldDateRange;
    self.textFieldDateRange.inputAccessoryView = keyboardAccessory;
    
    // initial for Fitness
    self.textFieldDateRange.text = LS_DAILY;
    
    //store old constraint
    _oldTableViewVerticalSpace = self.tableViewVerticalSpace.constant;
    
    self.activeTimeLabel.hidden = YES;
    self.imagePlayeHead.hidden  = YES;
}

- (void)updateGoals
{
    NSInteger stepGoal = self.stepsGoal;// * [self goalMultiplier];
    CGFloat distanceGoal = self.distanceGoal;// * [self goalMultiplier];
    NSInteger caloriesGoal = self.caloriesGoal;// * [self goalMultiplier];
    
    self.stepsGoalLabel.text = [NSString stringWithFormat:@"%@ %@", LS_GOAL_ALL_CAPS,[self stringForValue:stepGoal]];
    self.distanceGoalLabel.text = [NSString stringWithFormat:@"%@ %@", LS_GOAL_ALL_CAPS, [self stringForValue:distanceGoal]];
    self.caloriesGoalLabel.text = [NSString stringWithFormat:@"%@ %@", LS_GOAL_ALL_CAPS, [self stringForValue:caloriesGoal]];
    
    NSString *goalString    = [self goalStringForGraphType:self.graphType];
    NSString *unit          = [self unitForGraphType:self.graphType];
    self.goalLabel.text     = [NSString stringWithFormat:@"%@ %@", goalString, unit];
    
    float stepsValue = [self valueForGraphType:SFAGraphTypeSteps];
    float distanceValue = [self valueForGraphType:SFAGraphTypeDistance];
    float caloriesValue = [self valueForGraphType:SFAGraphTypeCalories];
    
    [self setGoalofGraphType:SFAGraphTypeSteps
                    WithGoal:stepGoal
                    andValue:stepsValue];//[self valueForGraphType:SFAGraphTypeSteps]];
    
    [self setGoalofGraphType:SFAGraphTypeDistance
                    WithGoal:distanceGoal
                    andValue:distanceValue];//[self valueForGraphType:SFAGraphTypeDistance]];
    
    [self setGoalofGraphType:SFAGraphTypeCalories
                    WithGoal:caloriesGoal
                    andValue:caloriesValue];//[self valueForGraphType:SFAGraphTypeCalories]];
}

- (void)initializeViews
{
    // Set Title and Image
    self.titleLabel.text    = [self graphStringForGraphType:self.graphType];
    self.graphImage.image   = [self graphImageForGraphType:self.graphType];
    
    // Set initial Goal Values
    CGFloat value = [self valueForGraphType:self.graphType];
    CGFloat goal = [self goalForGraphType:self.graphType];
    [self setGoalsViewWithValue:value goal:goal];
    
    // Set distance unit label
    if (self.graphType == SFAGraphTypeDistance) {
        self.metricLabel.text = _userProfile.unit == IMPERIAL ? @"mi" : @"km";
    }
    
    // Set date range border
    self.dateRangeBackgroundView.layer.borderWidth = 1.0f;
    self.dateRangeBackgroundView.layer.borderColor = DISTANCE_LINE_COLOR.CGColor;
    self.dateRangeBackgroundView.layer.cornerRadius = 10.0f;
}

- (SFADateRange)dateRangeForSegmentControlIndex:(NSInteger)index
{
    if (index == 0)
    {
        return SFADateRangeDay;
    }
    else if (index == 1)
    {
        return SFADateRangeWeek;
    }
    else if (index == 2)
    {
        return SFADateRangeMonth;
    }
    else if (index == 3)
    {
        return SFADateRangeYear;
    }
    
    return SFADateRangeDay;
}

- (UIButton *)buttonForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return self.buttonCalories;
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        return self.buttonDistance;
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        return self.buttonHeartRate;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        return self.buttonSteps;
    }
    
    return nil;
}

- (UIImage *)imageForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return CALORIES_ACTIVE_IMAGE;
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        return DISTANCE_ACTIVE_IMAGE;
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        return HEART_RATE_ACTIVE_IMAGE;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        return STEPS_ACTIVE_IMAGE;
    }
    
    return nil;
}

- (UILabel *)labelForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return self.caloriesLabel;
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        return self.distanceLabel;
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        return self.heartRateLabel;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        return self.stepsLabel;
    }
    
    return nil;
}

- (NSString *)stringValueForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return [NSString stringWithFormat:@"%i", self.graphViewController.currentCalories];
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        if (_userProfile.unit == IMPERIAL) {
        return [NSString stringWithFormat:@"%.2f mi", (self.graphViewController.currentDistance * 0.621371)];
        }
        else{
            return [NSString stringWithFormat:@"%.2f km", self.graphViewController.currentDistance];
        }
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        return [NSString stringWithFormat:@"%i", self.graphViewController.currentHeartRate];
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        return [NSString stringWithFormat:@"%i", self.graphViewController.currentSteps];
    }
    
    return nil;
}

- (void)getNotesForDate:(NSDate *)date
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:date];
    NSDate *newDate                 = [calendar dateFromComponents:components];
    NSPredicate *predicate          = [NSPredicate predicateWithFormat:@"date == %@", newDate];
    NSSortDescriptor *descriptor    = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSFetchRequest *fetchRequest    = [NSFetchRequest fetchRequestWithEntityName:NOTE_ENTITY];
    fetchRequest.predicate          = predicate;
    fetchRequest.sortDescriptors    = @[descriptor];
    NSError *error                  = nil;
    NSArray *data                   = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    self.notes                      = @[data];
    
    [self.tableView reloadData];
}

- (void)getNotesForWeek:(NSInteger)week ofYear:(NSInteger)year
{
    /*NSCalendar *calendar            = [NSCalendar currentCalendar];
     NSDateComponents *components    = [NSDateComponents new];
     components.weekOfYear           = week;
     components.weekday              = 1;
     components.year                 = year;
     NSDate *newDate                 = [calendar dateFromComponents:components];
     NSMutableArray *
     
     for (int a = 1; a < 7; a++)
     {
     
     }
     
     components.weekday              = 7;
     NSDate *endDate                 = [calendar dateFromComponents:components];
     NSPredicate *predicate          = [NSPredicate predicateWithFormat:@"date == %@", startDate, endDate];
     NSSortDescriptor *descriptor    = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
     NSFetchRequest *fetchRequest    = [NSFetchRequest fetchRequestWithEntityName:NOTE_ENTITY];
     fetchRequest.predicate          = predicate;
     fetchRequest.sortDescriptors    = @[descriptor];
     NSError *error                  = nil;
     NSArray *data                   = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
     self.notes                      = @[data];
     
     [self.tableView reloadData];*/
}

- (void)getNotesForMonth:(NSInteger)month ofYear:(NSInteger)year
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.month                = month;
    components.year                 = year;
    NSDate *startDate               = [calendar dateFromComponents:components];
    NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:startDate];
    components.day                  = range.length;
    NSDate *endDate                 = [calendar dateFromComponents:components];
    NSPredicate *predicate          = [NSPredicate predicateWithFormat:@"date BETWEEN %@ AND %@", startDate, endDate];
    NSSortDescriptor *descriptor    = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSFetchRequest *fetchRequest    = [NSFetchRequest fetchRequestWithEntityName:NOTE_ENTITY];
    fetchRequest.predicate          = predicate;
    fetchRequest.sortDescriptors    = @[descriptor];
    NSError *error                  = nil;
    NSArray *data                   = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    self.notes                      = @[data];
    
    [self.tableView reloadData];
}

- (void)getNotesForYear:(NSInteger)year
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.year                 = year;
    NSDate *startDate               = [calendar dateFromComponents:components];
    components.month                = 12;
    components.day                  = 31;
    NSDate *endDate                 = [calendar dateFromComponents:components];
    NSPredicate *predicate          = [NSPredicate predicateWithFormat:@"date BETWEEN %@ AND %@", startDate, endDate];
    NSSortDescriptor *descriptor    = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    NSFetchRequest *fetchRequest    = [NSFetchRequest fetchRequestWithEntityName:NOTE_ENTITY];
    fetchRequest.predicate          = predicate;
    fetchRequest.sortDescriptors    = @[descriptor];
    NSError *error                  = nil;
    NSArray *data                   = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    self.notes                      = @[data];
    
    [self.tableView reloadData];
}

// Goal Progress View

- (CGFloat)valueForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return self.graphViewController.totalCalories;
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        CGFloat distance = self.graphViewController.totalDistance;
        
        if (_userProfile.unit == IMPERIAL)
        {
            distance *= 0.621371;
        }
        
        return distance;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        return self.graphViewController.totalSteps;
    }
    
    return 0.0f;
}

- (CGFloat)goalForGraphType:(SFAGraphType)graphType
{
    CGFloat goal = 0.0f;
    
    if (graphType == SFAGraphTypeCalories)
    {
        goal = self.caloriesGoal;
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        goal = self.distanceGoal;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        goal = self.stepsGoal;
    }
    
    //SFADateRange dateRange = [self dateRangeForSegmentControlIndex:self.segmentedControl.selectedSegmentIndex];
    //goal = [self totalGoalForDateRange:dateRange goal:goal];
    
    return goal;
}

- (NSString *)valueStringForGraphType:(SFAGraphType)graphType
{
    CGFloat value                           = [self valueForGraphType:graphType];
    NSNumber *number                        = [NSNumber numberWithFloat:value];
    NSNumberFormatter *numberFormatter      = [NSNumberFormatter new];
    numberFormatter.numberStyle             = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits   = 2;
    
    /*if (graphType == SFAGraphTypeCalories)
     {
     return [NSString stringWithFormat:@"%.f", value];
     }
     else if (graphType == SFAGraphTypeDistance)
     {
     return [NSString stringWithFormat:@"%.2f", value];
     }
     else if (graphType == SFAGraphTypeSteps)
     {
     return [NSString stringWithFormat:@"%.f", value];
     }*/
    
    if (graphType == SFAGraphTypeDistance) {
        numberFormatter.positiveFormat      = @"0.00";
    }
    
    NSString *valueString = [numberFormatter stringFromNumber:number];
    
    return valueString;
}

- (NSString *)stringForValue:(CGFloat)value
{
    NSNumber *number                        = [NSNumber numberWithFloat:value];
    NSNumberFormatter *numberFormatter      = [NSNumberFormatter new];
    numberFormatter.numberStyle             = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits   = 2;
    
    if (self.graphType == SFAGraphTypeDistance) {
        numberFormatter.positiveFormat      = @"#.00";
    }
    
    NSString *valueString = [numberFormatter stringFromNumber:number];
    
    return valueString;
}

- (NSString *)goalStringForGraphType:(SFAGraphType)graphType
{
    CGFloat goal = [self goalForGraphType:graphType];
    
    //SFADateRange dateRange = [self dateRangeForSegmentControlIndex:self.segmentedControl.selectedSegmentIndex];
    //goal = [self totalGoalForDateRange:dateRange goal:goal];
    
    //goal *= [self goalMultiplier];
    
    NSNumber *number                    = [NSNumber numberWithFloat:goal];
    NSNumberFormatter *numberFormatter  = [NSNumberFormatter new];
    numberFormatter.numberStyle         = NSNumberFormatterDecimalStyle;
    
    if (graphType == SFAGraphTypeDistance) {
        numberFormatter.positiveFormat      = @"#.00";
    }
    
    NSString *goalString                = [numberFormatter stringFromNumber:number];
    
    return goalString;
}

/*- (CGFloat)totalGoalForDateRange:(SFADateRange)dateRange goal:(CGFloat)value {
 CGFloat goal = value;
 switch (dateRange) {
 case SFADateRangeWeek:
 goal *= 7;
 break;
 case SFADateRangeMonth: {
 NSCalendar *calendar    = [NSCalendar currentCalendar];
 NSRange range           = [calendar rangeOfUnit:NSDayCalendarUnit
 inUnit:NSMonthCalendarUnit
 forDate:self.calendarController.selectedDate];
 goal *= range.length;
 break;
 }
 case SFADateRangeYear: {
 NSDate *firstDateOfYear = [self firstDateOfYear:self.calendarController.selectedYear];
 NSDate *firstDateOfNextYear = [self firstDateOfYear:self.calendarController.selectedYear + 1];
 NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:firstDateOfYear toDate:firstDateOfNextYear options:0];
 goal *= [components day];
 break;
 }
 default:
 break;
 }
 return goal;
 }*/

- (NSDate*) firstDateOfYear:(NSInteger) year {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 1;
    components.month = 1;
    components.year = year;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (UIImage *)goalImageForPercent:(CGFloat)percent
{
    if (percent >= 100.0f)
    {
        return [UIImage imageNamed:@"FitnessResultsIconGoal100"];
    }
    else if (percent >= 75.0f)
    {
        return [UIImage imageNamed:@"FitnessResultsIconGoal100"];
    }
    else if (percent >= 50.0f)
    {
        return [UIImage imageNamed:@"FitnessResultsIconGoal75"];
    }
    else if (percent >= 25.0f)
    {
        return [UIImage imageNamed:@"FitnessResultsIconGoal50"];
    }
    else if (percent > 0.0f)
    {
        return [UIImage imageNamed:@"FitnessResultsIconGoal25"];
    }
    
    return [UIImage imageNamed:@"FitnessResultsIconGoal0"];
}

- (NSString *)unitForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return @"kcal";
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        if (_userProfile.unit == IMPERIAL)
        {
            return @"mi";
        }
        else
        {
            return @"km";
        }
    }
    
    return @"";
}

- (UIColor *)colorForPercent:(CGFloat)percent
{
    if (percent >= 100.0f){
        return PERCENT_COMPLETE_COLOR;
    } else if (percent >= 75.0f) {
        return PERCENT_100_COLOR;
    } else if (percent >= 50.0f) {
        return PERCENT_75_COLOR;
    } else if (percent >= 25.0f) {
        return PERCENT_50_COLOR;
    } else if (percent > 0.0f) {
        return PERCENT_25_COLOR;
    }
    
    return PERCENT_0_COLOR;
}

- (void)setGoalsViewWithValue:(CGFloat)value goal:(CGFloat)goal
{
    CGFloat percent                             = goal!=0 ? (value / goal):0;
    CGFloat progress                            = percent * 100.0f;
    progress                                    = floor(progress);
    self.valueLabel.text                        = [self valueStringForGraphType:self.graphType];
    self.percentLabel.text                      = [NSString stringWithFormat:@"%.f%%", progress];
    self.percentLabel.textColor                 = [self colorForPercent:progress];
    self.goalImage.image                        = [self goalImageForPercent:progress];
    self.progressView.backgroundColor           = [self colorForPercent:progress];
    percent                                     = percent > 1 ? 1 : percent;
    self.progressViewWidthConstraint.constant   = percent * self.progressBackgroundView.frame.size.width;
}

/*- (CGFloat)goalMultiplier
 {
 if (self.calendarController.calendarMode == SFACalendarDay) {
 return 1.0f;
 } else if (self.calendarController.calendarMode == SFACalendarWeek) {
 return 7.0f;
 } else if (self.calendarController.calendarMode == SFACalendarMonth) {
 // Date
 NSCalendar *calendar            = [NSCalendar currentCalendar];
 NSDateComponents *components    = [NSDateComponents new];
 components.month                = self.month;
 components.year                 = self.year;
 NSDate *date                    = [calendar dateFromComponents:components];
 NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
 
 return range.length;
 } else if (self.calendarController.calendarMode == SFACalendarYear) {
 return 365.0f;
 }
 return 0.0f;
 }*/

- (void)setGoalsWithDate:(NSDate *)date
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //NSComparisonResult result = [date compareToDate:[NSDate date]];
    
    NSString *macAddress        = [userDefaults stringForKey:MAC_ADDRESS];
    GoalsEntity *goalsEntity    = [SFAGoalsData goalsFromNearestDate:date macAddress:macAddress managedObject:self.managedObjectContext];
    
    //if ([date isToday]) {
    if (goalsEntity == nil)
    {
        // Goals
        self.stepsGoal      = [userDefaults integerForKey:STEP_GOAL];
        self.distanceGoal   = [userDefaults doubleForKey:DISTANCE_GOAL];
        self.caloriesGoal   = [userDefaults integerForKey:CALORIE_GOAL];
    } else {
        self.stepsGoal              = goalsEntity.steps.integerValue;
        self.distanceGoal           = goalsEntity.distance.floatValue;
        self.caloriesGoal           = goalsEntity.calories.integerValue;
    }
    
    if (_userProfile.unit == IMPERIAL) {
        self.distanceGoal *= 0.621371;
    }
}

- (void)setGoalsWithWeek:(NSInteger)week ofYear:(NSInteger)year
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSString *macAddress            = [userDefaults stringForKey:MAC_ADDRESS];
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.weekOfYear           = week;
    components.year                 = year;
    components.weekday              = 7;
    NSDate *toDate                  = [calendar dateFromComponents:components];
    NSArray *goals                  = [SFAGoalsData goalsEntitesToDate:toDate
                                                            macAddress:macAddress
                                                         managedObject:self.managedObjectContext];
    for (GoalsEntity *goal in goals) {
        DDLogInfo(@"goals = %i", goal.calories.integerValue);
        DDLogInfo(@"goals = %@", goal.date);
    }
    
    NSInteger stepsGoal     = 0;
    CGFloat distanceGoal    = 0;
    NSInteger caloriesGoal  = 0;
    
    for (NSInteger weekday = 1; weekday <= 7; weekday ++) {
        components.weekday          = weekday;
        NSDate *date                = [calendar dateFromComponents:components];
       // NSComparisonResult result   = [date compareToDate:[NSDate date]];
        
        /*
        if (result != NSOrderedAscending) {
            stepsGoal       += [userDefaults integerForKey:STEP_GOAL];
            distanceGoal    += [userDefaults doubleForKey:DISTANCE_GOAL];
            caloriesGoal    += [userDefaults integerForKey:CALORIE_GOAL];
            
            DDLogInfo(@"----------date = %@", date);
            DDLogInfo(@"---------[userDefaults integerForKey:CALORIE_GOAL] = %i", [userDefaults integerForKey:CALORIE_GOAL]);
        } else {
            GoalsEntity *goalEntity;
            
            if (goals.count == 1) {
                goalEntity = goals.firstObject;
            } else {
                for (GoalsEntity *goal in goals) {
                    if ([date compareToDate:goal.date] != NSOrderedAscending) {
                        goalEntity = goal;
                    } else {
                        break;
                    }
                }
                
                if (!goalEntity) {
                    goalEntity = goals.lastObject;
                }
            }
            
            stepsGoal       += goalEntity.steps.integerValue;
            distanceGoal    += goalEntity.distance.floatValue;
            caloriesGoal    += goalEntity.calories.integerValue;
            DDLogInfo(@"----------date = %@", date);
            DDLogInfo(@"---------goalEntity.calories.integerValue = %i", goalEntity.calories.integerValue);
         
        
        }
         */
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //NSComparisonResult result = [date compareToDate:[NSDate date]];
        
        NSString *macAddress        = [userDefaults stringForKey:MAC_ADDRESS];
        GoalsEntity *goalsEntity    = [SFAGoalsData goalsFromNearestDate:date macAddress:macAddress managedObject:self.managedObjectContext];
        
        //if ([date isToday]) {
        if (goalsEntity == nil)
        {
            // Goals
            stepsGoal      += [userDefaults integerForKey:STEP_GOAL];
            distanceGoal   += [userDefaults doubleForKey:DISTANCE_GOAL];
            caloriesGoal   += [userDefaults integerForKey:CALORIE_GOAL];
        } else {
            stepsGoal              += goalsEntity.steps.integerValue;
            distanceGoal           += goalsEntity.distance.floatValue;
            caloriesGoal           += goalsEntity.calories.integerValue;
        }
    }
    
    self.stepsGoal      = stepsGoal;
    self.distanceGoal   = distanceGoal;
    self.caloriesGoal   = caloriesGoal;
    
    DDLogInfo(@"---------self.caloriesGoal = %i", self.caloriesGoal);
    
    if (_userProfile.unit == IMPERIAL) {
        self.distanceGoal *= 0.621371;
    }
}

- (void)setGoalsWithMonth:(NSInteger)month ofYear:(NSInteger)year
{
    //NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    //NSString *macAddress            = [userDefaults stringForKey:MAC_ADDRESS];
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.month                = month;
    components.year                 = year;
    NSDate *date                    = [calendar dateFromComponents:components];
    NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    components.day                  = range.length;
    //NSDate *toDate                  = [calendar dateFromComponents:components];
    //NSArray *goals                  = [SFAGoalsData goalsEntitesToDate:toDate
    //                                                        macAddress:macAddress
    //                                                     managedObject:self.managedObjectContext];
    
    NSInteger stepsGoal     = 0;
    CGFloat distanceGoal    = 0;
    NSInteger caloriesGoal  = 0;
    
    for (NSInteger day = 1; day <= range.length; day ++) {
        components.day              = day;
        NSDate *date                = [calendar dateFromComponents:components];
        /*
        NSComparisonResult result   = [date compareToDate:[NSDate date]];
        
        if (result != NSOrderedAscending) {
            stepsGoal       += [userDefaults integerForKey:STEP_GOAL];
            distanceGoal    += [userDefaults doubleForKey:DISTANCE_GOAL];
            caloriesGoal    += [userDefaults integerForKey:CALORIE_GOAL];
        } else {
            GoalsEntity *goalEntity;
            
            if (goals.count == 1) {
                goalEntity = goals.firstObject;
            } else {
                for (GoalsEntity *goal in goals) {
                    if ([date compareToDate:goal.date] != NSOrderedAscending) {
                        goalEntity = goal;
                    } else {
                        break;
                    }
                }
                
                if (!goalEntity) {
                    goalEntity = goals.lastObject;
                }
            }
            
            stepsGoal       += goalEntity.steps.integerValue;
            distanceGoal    += goalEntity.distance.floatValue;
            caloriesGoal    += goalEntity.calories.integerValue;
        }
         */
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //NSComparisonResult result = [date compareToDate:[NSDate date]];
        
        NSString *macAddress        = [userDefaults stringForKey:MAC_ADDRESS];
        GoalsEntity *goalsEntity    = [SFAGoalsData goalsFromNearestDate:date macAddress:macAddress managedObject:self.managedObjectContext];
        
        //if ([date isToday]) {
        if (goalsEntity == nil)
        {
            // Goals
            stepsGoal      += [userDefaults integerForKey:STEP_GOAL];
            distanceGoal   += [userDefaults doubleForKey:DISTANCE_GOAL];
            caloriesGoal   += [userDefaults integerForKey:CALORIE_GOAL];
        } else {
            stepsGoal              += goalsEntity.steps.integerValue;
            distanceGoal           += goalsEntity.distance.floatValue;
            caloriesGoal           += goalsEntity.calories.integerValue;
        }
    }
    
    self.stepsGoal      = stepsGoal;
    self.distanceGoal   = distanceGoal;
    self.caloriesGoal   = caloriesGoal;
    
    if (_userProfile.unit == IMPERIAL) {
        self.distanceGoal *= 0.621371;
    }
}

- (void)setGoalsWithYear:(NSInteger)year
{
    //NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    //NSString *macAddress            = [userDefaults stringForKey:MAC_ADDRESS];
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.month                = 1;
    components.day                  = 1;
    components.year                 = year;
    NSDate *fromDate                = [calendar dateFromComponents:components];
    components.month                = 12;
    components.day                  = 31;
    
    //NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:date];
    //NSRange range                   = NSMakeRange(0, 365);
    NSDate *toDate                  = [calendar dateFromComponents:components];
    NSInteger days                  = [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:toDate];
   // NSArray *goals                  = [SFAGoalsData goalsEntitesToDate:toDate
    //                                                        macAddress:macAddress
     //                                                    managedObject:self.managedObjectContext];
    
    NSInteger stepsGoal     = 0;
    double distanceGoal    = 0;
    NSInteger caloriesGoal  = 0;
    
    for (NSInteger day = 0; day < days; day ++) {
        NSDate *date                = [fromDate dateByAddingTimeInterval:DAY_SECONDS * day];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *macAddress        = [userDefaults stringForKey:MAC_ADDRESS];
        GoalsEntity *goalsEntity    = [SFAGoalsData goalsFromNearestDate:date macAddress:macAddress managedObject:self.managedObjectContext];
        
        if (goalsEntity == nil)
        {
            stepsGoal      += [userDefaults integerForKey:STEP_GOAL];
            distanceGoal   += [userDefaults doubleForKey:DISTANCE_GOAL];
            caloriesGoal   += [userDefaults integerForKey:CALORIE_GOAL];
        } else {
            stepsGoal              += goalsEntity.steps.integerValue;
            distanceGoal           += goalsEntity.distance.doubleValue;
            caloriesGoal           += goalsEntity.calories.integerValue;
        }
        if (year == 2015)
            DDLogInfo(@"date: %@, distanceGoal: \t%f", date, goalsEntity.distance.doubleValue);
        //DDLogError(@"distance goal year: %i, value: %f", year, distanceGoal);
    }
    
    self.stepsGoal      = stepsGoal;
    self.distanceGoal   = distanceGoal;
    self.caloriesGoal   = caloriesGoal;
    
    if (_userProfile.unit == IMPERIAL) {
        self.distanceGoal *= 0.621371;
    }
}

#pragma mark - Public Methods

// Graph Methods

- (void)initializeGraph
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        self.graphContainerHeight.constant = 155;
        self.playHeaderHeight.constant = 155;
        self.graphBackgroundHeight.constant = 220;
        self.graphXBackgroundTopConstraint.constant = -180;
    }
    [self.graphViewController initializeGraph];
}

- (void)initializeDummyGraph
{
    [self.graphViewController initializeDummyGraph];
}

- (void)selectGraphType:(SFAGraphType)graphType
{
    UILabel *label      = [self labelForGraphType:graphType];
    label.text          = [self stringValueForGraphType:graphType];
    UIButton *button    = [self buttonForGraphType:graphType];
    button.tag          = 1;
    //UIImage *image      = [self imageForGraphType:graphType];
    
    //[button setImage:image forState:UIControlStateNormal];
}

- (void)deselectGraphType:(SFAGraphType)graphType
{
    UILabel *label      = [self labelForGraphType:graphType];
    label.text          = @"...";
    UIButton *button    = [self buttonForGraphType:graphType];
    button.tag          = 0;
    
    //[button setImage:INACTIVE_IMAGE forState:UIControlStateNormal];
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

- (void)scrollToFirstRecord
{
    if (!self.graphViewController.isPortrait)
        [self.graphViewController scrollToFirstRecord];
}

// Date Methods

- (void)changeDateRange:(SFADateRange)dateRange
{
    if (dateRange == SFADateRangeDay)
    {
        self.segmentedControl.selectedSegmentIndex = 0;
        self.pickerView.selectedIndex = 0;
    }
    else if (dateRange == SFADateRangeWeek)
    {
        self.segmentedControl.selectedSegmentIndex = 1;
        self.pickerView.selectedIndex = 1;
    }
    else if (dateRange == SFADateRangeMonth)
    {
        self.segmentedControl.selectedSegmentIndex = 2;
        self.pickerView.selectedIndex = 2;
    }
    else if (dateRange == SFADateRangeYear)
    {
        self.segmentedControl.selectedSegmentIndex = 3;
        self.pickerView.selectedIndex = 3;
    }
}

// Data Methods

- (void)setContentsWithDate:(NSDate *)date
{
    [self setGoalsWithDate:date];
    [self.graphViewController setContentsWithDate:date];
    [self updateGoals];
}

- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year
{
    // Get last day of week
    /*NSCalendar *calendar = [NSCalendar currentCalendar];
     NSDateComponents *dateComponents = [NSDateComponents new];
     dateComponents.week = week;
     dateComponents.year = year;
     dateComponents.weekday = 7;
     NSDate *date = [calendar dateFromComponents:dateComponents];*/
    
    //[self setGoalsWithDate:date];
    [self setGoalsWithWeek:week ofYear:year];
    [self.graphViewController setContentsWithWeek:week ofYear:year];
    [self updateGoals];
}

- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year
{
    self.month = month;
    self.year = year;
    
    // Date
    /*NSCalendar *calendar            = [NSCalendar currentCalendar];
     NSDateComponents *components    = [NSDateComponents new];
     components.month                = month;
     components.year                 = year;
     NSDate *date                    = [calendar dateFromComponents:components];
     NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
     
     // Get last day of the month
     components = [NSDateComponents new];
     components.month = month;
     components.year = year;
     components.day = range.length;
     date = [calendar dateFromComponents:components];*/
    
    //[self setGoalsWithDate:date];
    [self setGoalsWithMonth:month ofYear:year];
    [self.graphViewController setContentsWithMonth:month ofYear:year];
    [self updateGoals];
}

- (void)setContentsWithYear:(NSInteger)year
{
    // Get last day of the year
    /*NSCalendar *calendar = [NSCalendar currentCalendar];
     NSDateComponents *dateComponents = [NSDateComponents new];
     dateComponents.year = year;
     dateComponents.month = 12;
     dateComponents.day = 31;
     NSDate *date = [calendar dateFromComponents:dateComponents];
     
     [self setGoalsWithDate:date];*/
    [self setGoalsWithYear:year];
    [self.graphViewController setContentsWithYear:year];
    [self updateGoals];
}

- (void)setGoalofGraphType:(int)type WithGoal:(float)goal andValue:(float)value{
    UIView *view;
    if (type == SFAGraphTypeCalories) {
        view = self.caloriesGoalProgress;
    }
    else if (type == SFAGraphTypeDistance){
        view = self.distanceGoalProgress;
    }
    else if (type == SFAGraphTypeSteps){
        view = self.stepsGoalProgress;
    }
    
    float percent           = isnan(value / goal) ? 0.0f : value / goal;
    
    if (percent > 1) {
        percent = 1;
    }
    
    view.frame = CGRectMake(12.0f, 45.0f, 60*percent, 5.0);
    
    if (percent >= 1)
    {
        view.backgroundColor = WHEEL_100_COLOR;
    }
    else if (percent >= 0.75f)
    {
        view.backgroundColor = WHEEL_75_COLOR;
    }
    else if (percent >= 0.5f)
    {
        view.backgroundColor = WHEEL_50_COLOR;
    }
    else if (percent >= 0.25)
    {
        view.backgroundColor = WHEEL_25_COLOR;
    }
    else if (percent > 0)
    {
        view.backgroundColor = WHEEL_0_COLOR;
    }
    else
    {
        view.backgroundColor = CLEAR_COLOR;
    }
    /*
    if (percent >=  1) {
        if (type == SFAGraphTypeCalories) {
            self.caloriesGoalSuccess.hidden = NO;
        }
        else if (type == SFAGraphTypeDistance){
            self.distanceGoalSuccess.hidden = NO;
        }
        else if (type == SFAGraphTypeSteps){
            self.stepsGoalSuccess.hidden = NO;
        }
    }
    else{
        if (type == SFAGraphTypeCalories) {
            self.caloriesGoalSuccess.hidden = YES;
        }
        else if (type == SFAGraphTypeDistance){
            self.distanceGoalSuccess.hidden = YES;
        }
        else if (type == SFAGraphTypeSteps){
            self.stepsGoalSuccess.hidden = YES;
        }
    }
    */

}

@end

