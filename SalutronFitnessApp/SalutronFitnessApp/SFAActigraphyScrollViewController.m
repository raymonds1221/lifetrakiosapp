//
//  SFAActigraphyScrollViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/11/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Comparison.h"

#import "SFAActigraphyScrollViewController.h"
#import "SFAActigraphyViewController.h"
#import "SFAMainViewController.h"
#import "NSDate+Comparison.h"
#import "SFASlidingViewController.h"
#import "SFANavigation.h"
#import "SFASlidingViewController.h"
#import "SFASleepLogDataViewController.h"
#import "UIViewController+Helper.h"


#define LEFT_ACTIGRAPHY_SEGUE_IDENTIFIER @"LeftActigraphy"
#define CENTER_ACTIGRAPHY_SEGUE_IDENTIFIER @"CenterActigraphy"
#define RIGHT_ACTIGRAPHY_SEGUE_IDENTIFIER @"RightActigraphy"
#define SLEEP_DATA_SEGUE_IDENTIFIER @"ActigraphyToSleepData"

#define DAY_SECONDS 60 * 60 * 24

@interface SFAActigraphyScrollViewController () <SFACalendarControllerDelegate, SFAActigraphyPlotTouchEvent, SFASleepLogDataViewControllerDelegate>

@property (strong, nonatomic) UIView *disableLeftSlidingView;
@property (strong, nonatomic) SFAActigraphyViewController *leftActigraphyViewController;
@property (strong, nonatomic) SFAActigraphyViewController *centerActigraphyViewController;
@property (strong, nonatomic) SFAActigraphyViewController *rightActigraphyViewController;
@property (readwrite, nonatomic) CGRect oldContainerFrame;
@property (readwrite, nonatomic) BOOL didTouchButtonActigraphy;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftActigraphyWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerActigraphyWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightActigraphyWidthConstraint;
- (IBAction)buttonActigraphyTouched:(id)sender;
@property (weak, nonatomic) IBOutlet SFANavigation *navigationBarSFA;
@property (strong, nonatomic) SFAUserDefaultsManager *userDefaultsManager;
@property (nonatomic) BOOL isPortrait;

@end

@implementation SFAActigraphyScrollViewController

- (void)viewDidLoad
{
    DDLogInfo(@"");
    [super viewDidLoad];
    
    SFASlidingViewController *_viewController = (SFASlidingViewController *)self.parentViewController.parentViewController.parentViewController;
    _viewController.isActigraphy = YES;
    
    if (_viewController.isActigraphy)
    {
        //Show menu button for actigraphy
        //[self.navigationBarSFA showMenuButton];
        //[self.navigationBarSFA.buttonMenu addTarget:self
        //                                     action:@selector(buttonMenuTouched:)
        //                           forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    _viewController.shouldRotate = _viewController.isActigraphy;
    [self setContentsWithSelectedDate:self.calendarController.selectedDate];
    _oldContainerFrame          = self.leftActigraphyViewController.view.frame;
    _didTouchButtonActigraphy   = NO;
    self.isPortrait = YES;
}



- (void)viewWillLayoutSubviews
{
    DDLogInfo(@"");
    [super viewWillLayoutSubviews];
    
    if (!self.isIOS8AndAbove && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (self.isPortrait) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        self.leftActigraphyWidthConstraint.constant = screenWidth;
        self.centerActigraphyWidthConstraint.constant = screenWidth;
        self.rightActigraphyWidthConstraint.constant = screenWidth;
        }
    }
    [self setContentsWithSelectedDate:self.calendarController.selectedDate];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    DDLogInfo(@"");
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        self.isPortrait = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        if (self.isIOS8AndAbove) {
            self.leftActigraphyWidthConstraint.constant     = [UIScreen mainScreen].bounds.size.height;
            self.rightActigraphyWidthConstraint.constant    = [UIScreen mainScreen].bounds.size.height;
            self.centerActigraphyWidthConstraint.constant   = [UIScreen mainScreen].bounds.size.height;
        }
        else{
            self.leftActigraphyWidthConstraint.constant     = [UIScreen mainScreen].bounds.size.width;
            self.rightActigraphyWidthConstraint.constant    = [UIScreen mainScreen].bounds.size.width;
            self.centerActigraphyWidthConstraint.constant   = [UIScreen mainScreen].bounds.size.width;
        }
        self.calendarController.calendarMode = SFACalendarDay;
        [self setContentsWithSelectedDate:self.calendarController.selectedDate];
        if (!_didTouchButtonActigraphy) return;
        self.centerActigraphyViewController.view.frame  = _oldContainerFrame;    }
    else
    {
        self.isPortrait = NO;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.calendarController hideCalendarView];
        if (self.isIOS8AndAbove) {
            self.leftActigraphyWidthConstraint.constant    = self.view.window.frame.size.width;
            self.rightActigraphyWidthConstraint.constant   = self.view.window.frame.size.width;
            self.centerActigraphyWidthConstraint.constant  = self.view.window.frame.size.width;
        }
        else{
            self.leftActigraphyWidthConstraint.constant    = self.view.window.frame.size.height;
            self.rightActigraphyWidthConstraint.constant   = self.view.window.frame.size.height;
            self.centerActigraphyWidthConstraint.constant  = self.view.window.frame.size.height;
        }
        
//        if (!_didTouchButtonActigraphy) return;
//        CGRect _landscapeFrame = CGRectMake(0, 0,
//                                            self.view.window.frame.size.height,
//                                            self.centerActigraphyViewController.view.frame.size.width - 20);
//        self.centerActigraphyViewController.view.frame  = _landscapeFrame;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    DDLogInfo(@"");
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
        [self.scrollView scrollRectToVisible:self.centerActigraphy.frame animated:YES];
    
}

- (void) viewDidLayoutSubviews {
    DDLogInfo(@"");
    [super viewDidLayoutSubviews];
    if (self.isIOS8AndAbove) {
        [self adjustViewFrames];
        [self.scrollView scrollRectToVisible:self.centerActigraphy.frame animated:NO];
        [self.scrollView setContentOffset:CGPointMake(self.centerActigraphy.frame.size.width, 0)];
    }
    else{
        [self.scrollView scrollRectToVisible:self.centerActigraphy.frame animated:NO];
        if (self.isPortrait) {
            [self.scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0)];
        }
        else{
            [self.scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.height, 0)];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"");
    [super viewWillAppear:animated];
    
    //SFASlidingViewController *_viewController = (SFASlidingViewController *)self.parentViewController.parentViewController.parentViewController;
    //self.isActigraphy = _viewController.isActigraphy;
    self.isActigraphy = YES;
    
    //disable autorotate
    self.calendarController.calendarMode = SFACalendarDay;
    
    if (self.userDefaultsManager.selectedDateFromCalendar)
        [self setContentsWithSelectedDate:self.userDefaultsManager.selectedDateFromCalendar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    DDLogInfo(@"");
    [super viewWillDisappear:animated];
    SFASlidingViewController *_viewController = (SFASlidingViewController *)self.parentViewController.parentViewController.parentViewController;
    _viewController.isActigraphy = NO;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //SFASlidingViewController *_viewController = (SFASlidingViewController *)self.parentViewController.parentViewController.parentViewController;
    //self.isActigraphy = _viewController.isActigraphy;
    self.isActigraphy = YES;
    
    if([segue.identifier isEqualToString:LEFT_ACTIGRAPHY_SEGUE_IDENTIFIER]) {
        self.leftActigraphyViewController = segue.destinationViewController;
        self.leftActigraphyViewController.plotDelegate = self;
        self.leftActigraphyViewController.isActigraphy = self.isActigraphy;
        self.leftActigraphyViewController.navItem = self.navigationItem;
    } else if([segue.identifier isEqualToString:CENTER_ACTIGRAPHY_SEGUE_IDENTIFIER]) {
        self.centerActigraphyViewController = segue.destinationViewController;
        self.centerActigraphyViewController.plotDelegate = self;
        self.centerActigraphyViewController.isActigraphy = self.isActigraphy;
        self.centerActigraphyViewController.navItem = self.navigationItem;
    } else if([segue.identifier isEqualToString:RIGHT_ACTIGRAPHY_SEGUE_IDENTIFIER]) {
        self.rightActigraphyViewController = segue.destinationViewController;
        self.rightActigraphyViewController.plotDelegate = self;
        self.rightActigraphyViewController.isActigraphy = self.isActigraphy;
        self.rightActigraphyViewController.navItem = self.navigationItem;
    } else if ([segue.identifier isEqualToString:SLEEP_DATA_SEGUE_IDENTIFIER]) {
        SFASleepLogDataViewController *viewController = (SFASleepLogDataViewController *)segue.destinationViewController;
        viewController.delegate = self;
        viewController.mode = SFASleepLogDataModeAdd;
    }
}

#pragma mark - Private Methods
- (void)setScrollViewContentSize
{
    CGSize size                 = self.scrollView.frame.size;
    size.width                  *= (self.calendarController.selectedDate.isToday ? 2 : 3);
    self.scrollView.contentSize = size;
}


- (void)didScrollToHearRateAtIndex:(NSUInteger) index
{
    if (index == 1)
    {
        return;
    }
    /*else
    {
        SFAActigraphyViewController *viewController = index == 0 ? self.leftActigraphyViewController : self.rightActigraphyViewController;
        UIView *view                               = index == 0 ? self.leftActigraphy : self.rightActigraphy;
        
        [viewController.view removeFromSuperview];
        [self.centerActigraphyViewController.view removeFromSuperview];
        [view addSubview:self.centerActigraphyViewController.view];
        [self.centerActigraphy addSubview:viewController.view];
        
        self.leftActigraphyViewController   = index == 0 ? self.centerActigraphyViewController : self.leftActigraphyViewController;
        self.rightActigraphyViewController  = index == 2 ? self.centerActigraphyViewController : self.rightActigraphyViewController;
        self.centerActigraphyViewController = viewController;
    }*/
    
//    NSInteger seconds   = index == 0 ? - DAY_SECONDS : DAY_SECONDS;
//    NSDate *date        = [self.calendarController.selectedDate dateByAddingTimeInterval:seconds];

    // Get next/previous date from calendar (depends on calendar mode) --JB
    NSDate *date = index == 0 ? self.calendarController.previousDate : self.calendarController.nextDate;
    
    [self setContentsWithSelectedDate:date];
    [self.scrollView scrollRectToVisible:self.centerActigraphy.frame animated:NO];
}

- (void) setContentsWithSelectedDate:(NSDate *) selectedDate {
    NSDate *yesterday                       = [selectedDate dateByAddingTimeInterval:-DAY_SECONDS];
    NSDate *tomorrow                        = [selectedDate dateByAddingTimeInterval:DAY_SECONDS];
    self.calendarController.selectedDate    = selectedDate;
    
    [self.leftActigraphyViewController setContentsWithDate:yesterday];
    [self.centerActigraphyViewController setContentsWithDate:selectedDate];
    [self.rightActigraphyViewController setContentsWithDate:tomorrow];
    
    NSComparisonResult result = [selectedDate compareToDate:[NSDate date]];
    self.navigationItem.rightBarButtonItem.enabled = result == NSOrderedSame || result == NSOrderedAscending;
}

- (void)setContentsWithSelectedWeek:(NSInteger)week ofYear:(NSInteger)year
{
    [self.centerActigraphyViewController setContentsWithWeek:self.calendarController.selectedWeek ofYear:self.calendarController.selectedYear];
    [self.leftActigraphyViewController setContentsWithWeek:self.calendarController.previousWeek ofYear:self.calendarController.yearForPreviousWeek];
    [self.rightActigraphyViewController setContentsWithWeek:self.calendarController.nextWeek ofYear:self.calendarController.yearForPreviousWeek];
}


- (void)setContentsWithSelectedMonth:(SPCalendarMonth)month ofYear:(NSInteger)year
{
    [self.centerActigraphyViewController setContentsWithMonth:self.calendarController.selectedMonth ofYear:self.calendarController.selectedYear];
    [self.leftActigraphyViewController setContentsWithMonth:self.calendarController.previousMonth ofYear:self.calendarController.yearForPreviousMonth];
    [self.rightActigraphyViewController setContentsWithMonth:self.calendarController.nextMonth ofYear:self.calendarController.yearForNextMonth];
}

- (void)setContentsWithSelectedYear:(NSInteger)year
{
    [self.centerActigraphyViewController setContentsWithYear:self.calendarController.selectedYear];
    [self.leftActigraphyViewController setContentsWithYear:self.calendarController.previousYear];
    [self.rightActigraphyViewController setContentsWithYear:self.calendarController.nextYear];
}

- (void)_disableLeftSlidingView
{
    //Create subview on the left side of the view
    CGRect leftSlidingViewFrame                 = CGRectMake(0,
                                                             self.view.window.frame.size.height - 10.0f,
                                                             self.view.window.frame.size.width,
                                                             10.0f);
    _disableLeftSlidingView                     = [[UIView alloc] initWithFrame:leftSlidingViewFrame];
    _disableLeftSlidingView.backgroundColor     = [UIColor clearColor];
    [self.view.window addSubview:_disableLeftSlidingView];
}


#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    [self didScrollToHearRateAtIndex:index];
}

#pragma mark - SFACalendarControllerDelegate

- (void) calendarController:(SFAMainViewController *)calendarController
              didSelectDate:(NSDate *)date {
    self.userDefaultsManager.selectedDateFromCalendar = date;
    self.calendarController.selectedDate = date;
    [self setContentsWithSelectedDate:date];
}

#pragma mark - SFAActigraphyPlotTouchEvent

- (void)plotSpace:(CPTPlotSpace *)plotSpace handleTouchDownEvent:(UIEvent *)event pointIndex:(CGPoint)point {
    //self.scrollView.scrollEnabled = NO;
}

- (void)plotspace:(CPTPlotSpace *)plotSpace handleTouchUpEvent:(UIEvent *)event pointIndex:(CGPoint)point {
    //self.scrollView.scrollEnabled = YES;
}

- (void)plotSpace:(CPTPlotSpace *)plotSpace handleDraggedEvent:(UIEvent *)event pointIndex:(CGPoint)point {
    //self.scrollView.scrollEnabled = NO;
}

#pragma mark - Private actions
- (void)buttonMenuTouched:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)actigraphyViewController:(SFAActigraphyViewController *)viewController didChangeDateRange:(SFADateRange)dateRange
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
    
    [self.leftActigraphyViewController changeDateRange:dateRange];
    [self.rightActigraphyViewController changeDateRange:dateRange];
}

- (void)adjustViewFrames
{
    self.slidingViewController.topViewController.view.frame = [UIScreen mainScreen].bounds;
    self.scrollView.frame                                   = [UIScreen mainScreen].bounds;
    
    CGRect leftActigraphyFrame                              = self.leftActigraphy.frame;
    CGRect centerActigraphyFrame                            = self.centerActigraphy.frame;
    CGRect rightActigraphyFrame                             = self.rightActigraphy.frame;
    
    leftActigraphyFrame.size.width                          = self.scrollView.frame.size.width;
    leftActigraphyFrame.origin.x                            = 0;
    
    centerActigraphyFrame.size.width                        = self.scrollView.frame.size.width;
    centerActigraphyFrame.origin.x                          = self.scrollView.frame.size.width;
    
    rightActigraphyFrame.size.width                         = self.scrollView.frame.size.width;
    rightActigraphyFrame.origin.x                           = self.scrollView.frame.size.width * 2;
    
    self.leftActigraphy.frame                               = leftActigraphyFrame;
    self.centerActigraphy.frame                             = centerActigraphyFrame;
    self.rightActigraphy.frame                              = rightActigraphyFrame;
    
    self.leftActigraphyWidthConstraint.constant             = self.scrollView.frame.size.width;
    self.centerActigraphyWidthConstraint.constant           = self.scrollView.frame.size.width;
    self.rightActigraphyWidthConstraint.constant            = self.scrollView.frame.size.width;
}

#pragma mark - IBAction methods
- (IBAction)buttonActigraphyTouched:(id)sender
{
    SFASlidingViewController *_viewController = (SFASlidingViewController *)self.parentViewController.parentViewController.parentViewController;
    
    _didTouchButtonActigraphy = YES;
    
    //set actigraphy value
    if (_viewController.isActigraphy)
    {
        _viewController.isActigraphy                        = NO;
        self.leftActigraphyViewController.isActigraphy      = NO;
        self.centerActigraphyViewController.isActigraphy    = NO;
        self.rightActigraphyViewController.isActigraphy     = NO;
    }
    else
    {
        _viewController.isActigraphy                        = YES;
        self.leftActigraphyViewController.isActigraphy      = YES;
        self.centerActigraphyViewController.isActigraphy    = YES;
        self.rightActigraphyViewController.isActigraphy     = YES;
    }

    //Reload views
    [self.centerActigraphyViewController reloadView];
    [self.leftActigraphyViewController reloadView];
    [self.rightActigraphyViewController reloadView];
    
    //Set data
    [self setContentsWithSelectedDate:self.calendarController.selectedDate];
}

#pragma mark - SFASleepLogDataViewControllerDelegate Methods

- (void)sleepLogDataViewController:(SFASleepLogDataViewController *)viewController didAddSleepDatabaseEntity:(SleepDatabaseEntity *)sleepDatabaseEntity
{
    [self setContentsWithSelectedDate:self.calendarController.selectedDate];
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
