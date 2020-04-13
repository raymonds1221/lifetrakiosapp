//
//  SFACaloriesScrollViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/2/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Comparison.h"

#import "SFAFitnessResultsScrollViewController.h"
#import "SFAMainViewController.h"
#import "SFAActigraphyViewController.h"
#import "SFASlidingViewController.h"
#import "UIViewController+Helper.h"

#define DAY_SECONDS 60 * 60 * 24

#define LEFT_FITNESS_RESULTS_SEGUE_IDENTIFIER       @"LeftFitnessResults"
#define CENTER_FITNESS_RESULTS_SEGUE_IDENTIFIER     @"CenterFitnessResults"
#define RIGHT_FITNESS_RESULTS_SEGUE_IDENTIFIER      @"RightFitnessResults"

@interface SFAFitnessResultsScrollViewController () <SFACalendarControllerDelegate, SFAFitnessResultsViewControllerDelegate>

@property (weak, nonatomic) SFAFitnessResultsViewController *leftFitnessResults;
@property (weak, nonatomic) SFAFitnessResultsViewController *centerFitnessResults;
@property (weak, nonatomic) SFAFitnessResultsViewController *rightFitnessResults;
@property (strong, nonatomic) SFAActigraphyViewController   *actigraphy;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftFitnessConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerFitnessConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightFitnessConstraints;
@property (nonatomic) BOOL isPortrait;

@end

@implementation SFAFitnessResultsScrollViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    DDLogInfo(@"");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initializeObjects];
}

- (void)viewWillLayoutSubviews
{
    DDLogInfo(@"");
    [super viewWillLayoutSubviews];
    if (!self.isIOS8AndAbove /*&& UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad*/)
    {
        if (self.isPortrait) {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            
            self.leftFitnessConstraints.constant = screenWidth;
            self.centerFitnessConstraints.constant = screenWidth;
            self.rightFitnessConstraints.constant = screenWidth;
        }
    }
    
    if (self.calendarController.calendarMode == SFADateRangeDay)
    {
        [self setContentsWithSelectedDate:self.calendarController.selectedDate];
    }
    else if (self.calendarController.calendarMode == SFADateRangeWeek)
    {
        [self setContentsWithSelectedWeek:self.calendarController.selectedWeek ofYear:self.calendarController.selectedYear];
    }
    else if (self.calendarController.calendarMode == SFADateRangeMonth)
    {
        [self setContentsWithSelectedMonth:self.calendarController.selectedMonth ofYear:self.calendarController.selectedYear];
    }
    else if (self.calendarController.calendarMode == SFADateRangeYear)
    {
        [self setContentsWithSelectedYear:self.calendarController.selectedYear];
    }
    
}



- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    DDLogInfo(@"");
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        self.isPortrait = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        if (self.isIOS8AndAbove) {
            self.leftFitnessConstraints.constant    = self.view.window.frame.size.height;
            self.rightFitnessConstraints.constant   = self.view.window.frame.size.height;
            self.centerFitnessConstraints.constant  = self.view.window.frame.size.height;
        }
        else{
            self.leftFitnessConstraints.constant    = self.view.window.frame.size.width;
            self.rightFitnessConstraints.constant   = self.view.window.frame.size.width;
            self.centerFitnessConstraints.constant  = self.view.window.frame.size.width;
        }
    }
    else
    {
        self.isPortrait = NO;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.calendarController hideCalendarView];
        if (self.isIOS8AndAbove) {
            self.leftFitnessConstraints.constant    = self.view.window.frame.size.width;
            self.rightFitnessConstraints.constant   = self.view.window.frame.size.width;
            self.centerFitnessConstraints.constant  = self.view.window.frame.size.width;
        }/*
        else if (!self.isIOS8AndAbove && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenHeight = screenRect.size.width;
            
            self.leftFitnessConstraints.constant = screenHeight;
            self.centerFitnessConstraints.constant = screenHeight;
            self.rightFitnessConstraints.constant = screenHeight;
        }*/
        else{
            self.leftFitnessConstraints.constant    = self.view.window.frame.size.height;
            self.rightFitnessConstraints.constant   = self.view.window.frame.size.height;
            self.centerFitnessConstraints.constant  = self.view.window.frame.size.height;
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    DDLogInfo(@"");
    self.scrollView.scrollEnabled = (fromInterfaceOrientation != UIInterfaceOrientationPortrait);
    
    if (self.isIOS8AndAbove || (!self.isIOS8AndAbove && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        //[self adjustViewFrames];
        
        //self.view.frame = viewFrame;
        
        if (fromInterfaceOrientation != UIInterfaceOrientationPortrait) {
            CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
            navigationBarFrame.origin = CGPointMake(0, 0);
            navigationBarFrame.size.height = 44;
            [self.navigationController.navigationBar setFrame:navigationBarFrame];
        }
    }
    
    [self.scrollView scrollRectToVisible:self.centerFitnessResultsView.frame animated:YES];
    [self.centerFitnessResults scrollToFirstRecord];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogInfo(@"");
    [super viewDidAppear:animated];
    
//    [self.centerFitnessResults scrollToFirstRecord];
}

- (void)viewWillDisappear:(BOOL)animated{
    DDLogInfo(@"");
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)viewDidLayoutSubviews
{
    DDLogInfo(@"");
    [super viewDidLayoutSubviews];
    
    if (self.isIOS8AndAbove) {
        [self adjustViewFrames];
        [self.scrollView scrollRectToVisible:self.centerFitnessResultsView.frame animated:NO];
        [self.scrollView setContentOffset:CGPointMake(self.centerFitnessResultsView.frame.size.width, 0)];
    }
    else{
        [self.scrollView scrollRectToVisible:self.centerFitnessResultsView.frame animated:NO];
        if (self.isPortrait) {
            [self.scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0)];
        }
        else{
            [self.scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.height, 0)];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:LEFT_FITNESS_RESULTS_SEGUE_IDENTIFIER])
    {
        self.leftFitnessResults             = (SFAFitnessResultsViewController *) segue.destinationViewController;
        self.leftFitnessResults.delegate    = self;
    }
    else if ([segue.identifier isEqualToString:CENTER_FITNESS_RESULTS_SEGUE_IDENTIFIER])
    {
        self.centerFitnessResults           = (SFAFitnessResultsViewController *) segue.destinationViewController;
        self.centerFitnessResults.delegate  = self;
    }
    else if ([segue.identifier isEqualToString:RIGHT_FITNESS_RESULTS_SEGUE_IDENTIFIER])
    {
        self.rightFitnessResults            = (SFAFitnessResultsViewController *) segue.destinationViewController;
        self.rightFitnessResults.delegate   = self;
    }
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    
    [self didScrollToDashboardAtIndex:index];
}

#pragma mark - SFACalendarController Methods

- (void)calendarController:(SFAMainViewController *)calendarController didSelectDate:(NSDate *)date
{
    [self setContentsWithSelectedDate:date];
}

- (void)calendarController:(SFAMainViewController *)calendarController didSelectWeek:(NSInteger)week ofYear:(NSInteger)year
{
    [self setContentsWithSelectedWeek:week ofYear:year];
}

- (void)calendarController:(SFAMainViewController *)calendarController didSelectMonth:(NSInteger)month ofYear:(NSInteger)year
{
    [self setContentsWithSelectedMonth:month ofYear:year];
}

- (void)calendarController:(SFAMainViewController *)calendarController didSelectYear:(NSInteger)year
{
    [self setContentsWithSelectedYear:year];
}

#pragma mark - SFAFitnessResultsViewControllerDelegate Methods

- (void)fitnessResultsViewController:(SFAFitnessResultsViewController *)viewController didAddGraphType:(SFAGraphType)graphType
{
    [self.leftFitnessResults addGraphType:graphType];
    [self.rightFitnessResults addGraphType:graphType];
}

- (void)fitnessResultsViewController:(SFAFitnessResultsViewController *)viewController didRemoveGraphType:(SFAGraphType)graphType
{
    [self.leftFitnessResults removeGraphType:graphType];
    [self.rightFitnessResults removeGraphType:graphType];
}

- (void)fitnessResultsViewController:(SFAFitnessResultsViewController *)viewController didChangeDateRange:(SFADateRange)dateRange
{
    self.calendarController.calendarMode = (SFACalendarMode)dateRange;
    
    if (dateRange == SFADateRangeDay)
    {
        [self setContentsWithSelectedDate:self.calendarController.selectedDate];
    }
    else if (dateRange == SFADateRangeWeek)
    {
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        NSDateComponents *components    = [calendar components:NSCalendarUnitWeekOfYear | NSCalendarUnitYear fromDate:self.calendarController.selectedDate];
        
        [self setContentsWithSelectedWeek:components.weekOfYear ofYear:components.year];
    }
    else if (dateRange == SFADateRangeMonth)
    {
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        NSDateComponents *components    = [calendar components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.calendarController.selectedDate];
        
        [self setContentsWithSelectedMonth:components.month ofYear:components.year];
    }
    else if (dateRange == SFADateRangeYear)
    {
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        NSDateComponents *components    = [calendar components:NSCalendarUnitYear fromDate:self.calendarController.selectedDate];
        
        [self setContentsWithSelectedYear:components.year];
    }
    else
    {
        return;
    }
    
    [self.leftFitnessResults changeDateRange:dateRange];
    [self.rightFitnessResults changeDateRange:dateRange];
}

#pragma mark - Private Methods

- (NSString *)graphStringForGraphType:(SFAGraphType)graphType
{
    if (graphType == SFAGraphTypeCalories)
    {
        return @"Calories";
    }
    else if (graphType == SFAGraphTypeDistance)
    {
        return @"Distance";
    }
    else if (graphType == SFAGraphTypeHeartRate)
    {
        return LS_HEART_RATE;
    }
    else if (graphType == SFAGraphTypeSteps)
    {
        return LS_STEPS_TITLE;
    }
    
    return nil;
}

- (void)initializeObjects
{
    //change to yes if you want to support landscape view
    SFASlidingViewController *_viewController = (SFASlidingViewController *)self.parentViewController.parentViewController.parentViewController;
    _viewController.shouldRotate = YES;
    
    self.isPortrait = YES;
    
    // Initialization
    [self.leftFitnessResults initializeGraph];
    [self.centerFitnessResults initializeGraph];
    [self.rightFitnessResults initializeGraph];
    
    // Initial Data
    [self.leftFitnessResults addGraphType:self.graphType];
    [self.centerFitnessResults addGraphType:self.graphType];
    [self.rightFitnessResults addGraphType:self.graphType];
    
    // Graph Type
    self.leftFitnessResults.graphType = self.graphType;
    self.centerFitnessResults.graphType = self.graphType;
    self.rightFitnessResults.graphType = self.graphType;
    
    // Navigation Bar Title
    self.navigationItem.title = [self graphStringForGraphType:self.graphType];
    
    
    [self setContentsWithSelectedDate:self.calendarController.selectedDate];
    
    CGRect frame = self.navigationController.navigationBar.frame;
    //DDLogError(@"navigation frame: %@", NSStringFromCGRect(frame));
}

- (void)didScrollToDashboardAtIndex:(NSInteger)index
{
    if (index != 1)
    {
        [self.scrollView scrollRectToVisible:self.centerFitnessResultsView.frame animated:NO];
        
        if (self.calendarController.calendarMode == SFADateRangeDay)
        {
            self.calendarController.selectedDate = index == 0 ? self.calendarController.previousDate : self.calendarController.nextDate;
        }
        else if (self.calendarController.calendarMode == SFADateRangeWeek)
        {
            NSInteger week = index == 0 ? self.calendarController.previousWeek : self.calendarController.nextWeek;
            NSInteger year = index == 0 ? self.calendarController.yearForPreviousWeek : self.calendarController.yearForNextWeek;
            
            [self.calendarController setSelectedWeek:week ofYear:year];
        }
        else if (self.calendarController.calendarMode == SFADateRangeMonth)
        {
            NSInteger month = index == 0 ? self.calendarController.previousMonth : self.calendarController.nextMonth;
            NSInteger year  = index == 0 ? self.calendarController.yearForPreviousMonth : self.calendarController.yearForNextMonth;
            
            [self.calendarController setSelectedMonth:month ofYear:year];
        }
        else if (self.calendarController.calendarMode == SFADateRangeYear)
        {
            self.calendarController.selectedYear = index == 0 ? self.calendarController.previousYear : self.calendarController.nextYear;
        }
    }
}

- (void)setScrollViewContentSize
{
    CGSize size                 = self.scrollView.frame.size;
    size.width                  *= (self.calendarController.selectedDate.isToday ? 2 : 3);
    self.scrollView.contentSize = size;
}

- (void)setContentsWithSelectedDate:(NSDate *)selectedDate
{
    [self.centerFitnessResults setContentsWithDate:self.calendarController.selectedDate];
    [self.leftFitnessResults setContentsWithDate:self.calendarController.previousDate];
    [self.rightFitnessResults setContentsWithDate:self.calendarController.nextDate];
    
    [self.centerFitnessResults scrollToFirstRecord];
}

- (void)setContentsWithSelectedWeek:(NSInteger)week ofYear:(NSInteger)year
{
    [self.centerFitnessResults setContentsWithWeek:self.calendarController.selectedWeek ofYear:self.calendarController.selectedYear];
    [self.leftFitnessResults setContentsWithWeek:self.calendarController.previousWeek ofYear:self.calendarController.yearForPreviousWeek];
    [self.rightFitnessResults setContentsWithWeek:self.calendarController.nextWeek ofYear:self.calendarController.yearForNextWeek];
    
    [self.centerFitnessResults scrollToFirstRecord];
}

- (void)setContentsWithSelectedMonth:(SPCalendarMonth)month ofYear:(NSInteger)year
{
    [self.centerFitnessResults setContentsWithMonth:self.calendarController.selectedMonth ofYear:self.calendarController.selectedYear];
    [self.leftFitnessResults setContentsWithMonth:self.calendarController.previousMonth ofYear:self.calendarController.yearForPreviousMonth];
    [self.rightFitnessResults setContentsWithMonth:self.calendarController.nextMonth ofYear:self.calendarController.yearForNextMonth];
    
    [self.centerFitnessResults scrollToFirstRecord];
}

- (void)setContentsWithSelectedYear:(NSInteger)year
{
    [self.centerFitnessResults setContentsWithYear:self.calendarController.selectedYear];
    [self.leftFitnessResults setContentsWithYear:self.calendarController.previousYear];
    [self.rightFitnessResults setContentsWithYear:self.calendarController.nextYear];
    
    [self.centerFitnessResults scrollToFirstRecord];
}

- (void)adjustViewFrames
{
    CGRect viewFrame = [UIScreen mainScreen].bounds;
    self.slidingViewController.topViewController.view.frame = viewFrame;
    self.scrollView.frame = viewFrame;
    
    CGRect leftFitnessResultsViewFrame          = self.leftFitnessResultsView.frame;
    CGRect centerFitnessResultsViewFrame        = self.centerFitnessResultsView.frame;
    CGRect rightFitnessResultsViewFrame         = self.rightFitnessResultsView.frame;
    
    leftFitnessResultsViewFrame.size.width      = self.scrollView.frame.size.width;
    leftFitnessResultsViewFrame.origin.x        = 0;
    
    centerFitnessResultsViewFrame.size.width    = self.scrollView.frame.size.width;
    centerFitnessResultsViewFrame.origin.x      = self.scrollView.frame.size.width;
    
    rightFitnessResultsViewFrame.size.width     = self.scrollView.frame.size.width;
    rightFitnessResultsViewFrame.origin.x       = self.scrollView.frame.size.width * 2;
    
    self.leftFitnessResultsView.frame           = leftFitnessResultsViewFrame;
    self.centerFitnessResultsView.frame         = centerFitnessResultsViewFrame;
    self.rightFitnessResultsView.frame          = rightFitnessResultsViewFrame;
    
    self.leftFitnessConstraints.constant        = self.scrollView.frame.size.width;
    self.centerFitnessConstraints.constant      = self.scrollView.frame.size.width;
    self.rightFitnessConstraints.constant       = self.scrollView.frame.size.width;
}

@end
