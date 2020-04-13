//
//  SFAHeartRateScrollViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/4/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAHeartRateScrollViewController.h"
#import "SFAHeartRateViewController.h"
#import "SFAMainViewController.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "StatisticalDataPointEntity.h"
#import "NSDate+Comparison.h"
#import "SFASlidingViewController.h"
#import "UIViewController+Helper.h"

#define DAY_SECONDS 60 * 60 * 24

#define LEFT_HEART_RATE_SEGUE_IDENTIFIER    @"LeftHeartRate"
#define CENTER_HEART_RATE_SEGUE_IDENTIFIER  @"CenterHeartRate"
#define RIGHT_HEART_RATE_SEGUE_IDENTIFIER   @"RightHeartRate"

@interface SFAHeartRateScrollViewController () <SFACalendarControllerDelegate, SFAHeartRateViewControllerDelegate>

@property (strong, nonatomic) SFAHeartRateViewController    *leftHeartRateViewController;
@property (strong, nonatomic) SFAHeartRateViewController    *centerHeartRateViewController;
@property (strong, nonatomic) SFAHeartRateViewController    *rightHeartRateViewController;

@property (readwrite, nonatomic) NSInteger currentWeek;
@property (readwrite, nonatomic) NSInteger currentMonth;
@property (readwrite, nonatomic) NSInteger currentYear;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftHearRateConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerHeartRateConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightHeartRateConstraints;

@property (nonatomic) BOOL isPortrait;
@end

@implementation SFAHeartRateScrollViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeObjects];
}

- (void)viewWillLayoutSubviews
{
    
    [super viewWillLayoutSubviews];
        if (!self.isIOS8AndAbove && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if (self.isPortrait) {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            
            self.leftHearRateConstraints.constant = screenWidth;
            self.centerHeartRateConstraints.constant = screenWidth;
            self.rightHeartRateConstraints.constant = screenWidth;
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
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.isPortrait = YES;
        if (self.isIOS8AndAbove) {
            self.leftHearRateConstraints.constant    = self.view.window.frame.size.height;
            self.rightHeartRateConstraints.constant   = self.view.window.frame.size.height;
            self.centerHeartRateConstraints.constant  = self.view.window.frame.size.height;
        }
        else{
            self.leftHearRateConstraints.constant    = self.view.window.frame.size.width;
            self.rightHeartRateConstraints.constant   = self.view.window.frame.size.width;
            self.centerHeartRateConstraints.constant  = self.view.window.frame.size.width;
        }
    }
    else
    {
        self.isPortrait = NO;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.calendarController hideCalendarView];
        if (self.isIOS8AndAbove) {
            self.leftHearRateConstraints.constant    = self.view.window.frame.size.width;
            self.rightHeartRateConstraints.constant   = self.view.window.frame.size.width;
            self.centerHeartRateConstraints.constant  = self.view.window.frame.size.width;
        }
        else{
            self.leftHearRateConstraints.constant    = self.view.window.frame.size.height;
            self.rightHeartRateConstraints.constant   = self.view.window.frame.size.height;
            self.centerHeartRateConstraints.constant  = self.view.window.frame.size.height;
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.scrollView.scrollEnabled = (fromInterfaceOrientation != UIInterfaceOrientationPortrait);
    
    if (self.isIOS8AndAbove) {
        //[self adjustViewFrames];
        
        if (fromInterfaceOrientation != UIInterfaceOrientationPortrait) {
            CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
            navigationBarFrame.origin = CGPointMake(0, 0);
            navigationBarFrame.size.height = 44;
            [self.navigationController.navigationBar setFrame:navigationBarFrame];
        }
    }
    
    [self.scrollView scrollRectToVisible:self.centerHeartRate.frame animated:YES];
    
    [self.centerHeartRateViewController scrollToFirstRecord];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.centerHeartRateViewController scrollToFirstRecord];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.isIOS8AndAbove) {
        [self adjustViewFrames];
        [self.scrollView scrollRectToVisible:self.centerHeartRate.frame animated:NO];
        [self.scrollView setContentOffset:CGPointMake(self.centerHeartRate.frame.size.width, 0)];
    }
    else{
        [self.scrollView scrollRectToVisible:self.centerHeartRate.frame animated:NO];
        if (self.isPortrait) {
            [self.scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0)];
        }
        else{
            [self.scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.height, 0)];
        }
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:LEFT_HEART_RATE_SEGUE_IDENTIFIER])
    {
        self.leftHeartRateViewController            = segue.destinationViewController;
        self.leftHeartRateViewController.delegate   = self;
    }
    else if ([segue.identifier isEqualToString:CENTER_HEART_RATE_SEGUE_IDENTIFIER])
    {
        self.centerHeartRateViewController          = segue.destinationViewController;
        self.centerHeartRateViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:RIGHT_HEART_RATE_SEGUE_IDENTIFIER])
    {
        self.rightHeartRateViewController           = segue.destinationViewController;
        self.rightHeartRateViewController.delegate  = self;
    }
}

#pragma mark - Private Methods

- (void)setScrollViewContentSize
{
    CGSize size                 = self.scrollView.frame.size;
    size.width                  *= (self.calendarController.selectedDate.isToday ? 2 : 3);
    self.scrollView.contentSize = size;
}

- (void) initializeObjects
{
    //change to yes if you want to support landscape view
    SFASlidingViewController *_viewController = (SFASlidingViewController *)self.parentViewController.parentViewController.parentViewController;
    _viewController.shouldRotate = YES;
    self.isPortrait = YES;
    
    [self setContentsWithSelectedDate:self.calendarController.selectedDate];
}

- (void)didScrollToHearRateAtIndex:(NSUInteger)index
{
    if (index != 1)
    {
        [self.scrollView scrollRectToVisible:self.centerHeartRate.frame animated:NO];
        
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

- (void)setContentsWithSelectedDate:(NSDate *)selectedDate
{
    [self.centerHeartRateViewController setContentsWithDate:self.calendarController.selectedDate];
    [self.leftHeartRateViewController setContentsWithDate:self.calendarController.previousDate];
    [self.rightHeartRateViewController setContentsWithDate:self.calendarController.nextDate];
    
    [self.centerHeartRateViewController scrollToFirstRecord];
}

- (void)setContentsWithSelectedWeek:(NSInteger)week ofYear:(NSInteger)year
{
    [self.centerHeartRateViewController setContentsWithWeek:self.calendarController.selectedWeek ofYear:self.calendarController.selectedYear];
    [self.leftHeartRateViewController setContentsWithWeek:self.calendarController.previousWeek ofYear:self.calendarController.yearForPreviousWeek];
    [self.rightHeartRateViewController setContentsWithWeek:self.calendarController.nextWeek ofYear:self.calendarController.yearForNextWeek];
    
    [self.centerHeartRateViewController scrollToFirstRecord];
}

- (void)setContentsWithSelectedMonth:(SPCalendarMonth)month ofYear:(NSInteger)year
{
    [self.centerHeartRateViewController setContentsWithMonth:self.calendarController.selectedMonth ofYear:self.calendarController.selectedYear];
    [self.leftHeartRateViewController setContentsWithMonth:self.calendarController.previousMonth ofYear:self.calendarController.yearForPreviousMonth];
    [self.rightHeartRateViewController setContentsWithMonth:self.calendarController.nextMonth ofYear:self.calendarController.yearForNextMonth];
    
    [self.centerHeartRateViewController scrollToFirstRecord];
}

- (void)setContentsWithSelectedYear:(NSInteger)year
{
    [self.centerHeartRateViewController setContentsWithYear:self.calendarController.selectedYear];
    [self.leftHeartRateViewController setContentsWithYear:self.calendarController.previousYear];
    [self.rightHeartRateViewController setContentsWithYear:self.calendarController.nextYear];
    
    [self.centerHeartRateViewController scrollToFirstRecord];
}

- (void)adjustViewFrames
{
    self.slidingViewController.topViewController.view.frame = [UIScreen mainScreen].bounds;
    self.scrollView.frame                                   = [UIScreen mainScreen].bounds;
    
    CGRect leftHeartRateViewFrame                           = self.leftHeartRate.frame;
    CGRect centerHeartRateViewFrame                         = self.centerHeartRate.frame;
    CGRect rightHeartRateViewFrame                          = self.rightHeartRate.frame;
    
    leftHeartRateViewFrame.size.width                       = self.scrollView.frame.size.width;
    leftHeartRateViewFrame.origin.x                         = 0;
    
    centerHeartRateViewFrame.size.width                     = self.scrollView.frame.size.width;
    centerHeartRateViewFrame.origin.x                       = self.scrollView.frame.size.width;
    
    rightHeartRateViewFrame.size.width                      = self.scrollView.frame.size.width;
    rightHeartRateViewFrame.origin.x                      = self.scrollView.frame.size.width * 2;
    
    self.leftHeartRate.frame                                = leftHeartRateViewFrame;
    self.centerHeartRate.frame                              = centerHeartRateViewFrame;
    self.rightHeartRate.frame                               = rightHeartRateViewFrame;
    
    self.leftHearRateConstraints.constant                   = self.scrollView.frame.size.width;
    self.centerHeartRateConstraints.constant                = self.scrollView.frame.size.width;
    self.rightHeartRateConstraints.constant                 = self.scrollView.frame.size.width;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    
    [self didScrollToHearRateAtIndex:index];
}

#pragma mark - SFACalendarControllerDelegate Methods

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

#pragma mark - SFAHeartRateViewControllerDelegate Methods

- (void)heartRateViewController:(SFAHeartRateViewController *)viewController didChangeDateRange:(SFADateRange)dateRange
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
    
    [self.centerHeartRateViewController changeDateRange:dateRange];
    [self.leftHeartRateViewController changeDateRange:dateRange];
    [self.rightHeartRateViewController changeDateRange:dateRange];

}

@end
