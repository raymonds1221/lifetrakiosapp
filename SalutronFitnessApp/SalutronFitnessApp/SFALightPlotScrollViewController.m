//
//  SFALightPlotScrollViewController.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 8/22/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFALightPlotScrollViewController.h"
#import "SFASlidingViewController.h"
#import "SFAMainViewController.h"

#import "SFALightPlotViewController.h"
#import "NSDate+Comparison.h"
#import "UIViewController+Helper.h"

@interface SFALightPlotScrollViewController ()<SFACalendarControllerDelegate, SFALightPlotViewControllerDelegate>

#define LEFT_LIGHT_PLOT_SEGUE_IDENTIFIER       @"leftLightPlotVC"
#define CENTER_LIGHT_PLOT_SEGUE_IDENTIFIER     @"centerLightPlotVC"
#define RIGHT_LIGHT_PLOT_SEGUE_IDENTIFIER      @"rightLightPlotVC"

@property (weak, nonatomic) IBOutlet UIView *leftLightPlotView;
@property (weak, nonatomic) IBOutlet UIView *centerLightPlotView;
@property (weak, nonatomic) IBOutlet UIView *rightLightPlotView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftVCWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerVCWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightVCWidthConstraint;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) SFALightPlotViewController  *leftLightPlotVC;
@property (weak, nonatomic) SFALightPlotViewController  *centerLightPlotVC;
@property (weak, nonatomic) SFALightPlotViewController  *rightLightPlotVC;
@property (nonatomic) BOOL isPortrait;

@end

@implementation SFALightPlotScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeObjects];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (self.isIOS8AndAbove) {
        [self adjustViewFrames];
        [self.scrollView scrollRectToVisible:self.centerLightPlotView.frame animated:NO];
        [self.scrollView setContentOffset:CGPointMake(self.centerLightPlotView.frame.size.width, 0)];
    }
    else{
        [self.scrollView scrollRectToVisible:self.centerLightPlotView.frame animated:NO];
        if (self.isPortrait) {
            [self.scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0)];
        }
        else{
            [self.scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.height, 0)];
        }
    }
}

- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    if (!self.isIOS8AndAbove && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (self.isPortrait) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        self.leftVCWidthConstraint.constant = screenWidth;
        self.centerVCWidthConstraint.constant = screenWidth;
        self.rightVCWidthConstraint.constant = screenWidth;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.calendarController.calendarMode = SFACalendarDay;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.isPortrait = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        if (self.isIOS8AndAbove) {
            self.leftVCWidthConstraint.constant    = self.view.window.frame.size.height;
            self.rightVCWidthConstraint.constant   = self.view.window.frame.size.height;
            self.centerVCWidthConstraint.constant  = self.view.window.frame.size.height;
        }
        else{
            self.leftVCWidthConstraint.constant    = self.view.window.frame.size.width;
            self.rightVCWidthConstraint.constant   = self.view.window.frame.size.width;
            self.centerVCWidthConstraint.constant  = self.view.window.frame.size.width;
        }
        
        self.calendarController.calendarMode = SFACalendarDay;
        [self setContentsWithSelectedDate:self.calendarController.selectedDate];
    }
    else {
        self.isPortrait = NO;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.calendarController hideCalendarView];
        if (self.isIOS8AndAbove) {
            self.leftVCWidthConstraint.constant    = self.view.window.frame.size.width;
            self.rightVCWidthConstraint.constant   = self.view.window.frame.size.width;
            self.centerVCWidthConstraint.constant  = self.view.window.frame.size.width;
        }
        else{
            self.leftVCWidthConstraint.constant    = self.view.window.frame.size.height;
            self.rightVCWidthConstraint.constant   = self.view.window.frame.size.height;
            self.centerVCWidthConstraint.constant  = self.view.window.frame.size.height;
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.scrollView.scrollEnabled = (fromInterfaceOrientation != UIInterfaceOrientationPortrait);
    
    if (self.isIOS8AndAbove) {
        
        if (fromInterfaceOrientation != UIInterfaceOrientationPortrait) {
            CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
            navigationBarFrame.origin = CGPointMake(0, 0);
            navigationBarFrame.size.height = 44;
            [self.navigationController.navigationBar setFrame:navigationBarFrame];
        }
    }
    
    [self.scrollView scrollRectToVisible:self.centerLightPlotView.frame animated:YES];
    
    if (self.calendarController.calendarMode == SFACalendarDay) {
        if(fromInterfaceOrientation == UIInterfaceOrientationPortrait) {
            [self performSelector:@selector(scrollToFirstRecord) withObject:self afterDelay:0.5];
        }
        else{
            [self performSelector:@selector(scrollToFirstRecord) withObject:self afterDelay:0.05];
        }
    }
}

- (void)scrollToFirstRecord{
    [self setContentsWithSelectedDate:self.calendarController.selectedDate];
}

#pragma mark - navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:LEFT_LIGHT_PLOT_SEGUE_IDENTIFIER])
    {
        self.leftLightPlotVC = (SFALightPlotViewController *) segue.destinationViewController;
        self.leftLightPlotVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:CENTER_LIGHT_PLOT_SEGUE_IDENTIFIER])
    {
        self.centerLightPlotVC = (SFALightPlotViewController *) segue.destinationViewController;
        self.centerLightPlotVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:RIGHT_LIGHT_PLOT_SEGUE_IDENTIFIER])
    {
        self.rightLightPlotVC = (SFALightPlotViewController *) segue.destinationViewController;
        self.rightLightPlotVC.delegate = self;
    }
}

#pragma mark - private methods
- (void)initializeObjects
{
    //change to yes if you want to support landscape view
    SFASlidingViewController *_viewController = (SFASlidingViewController *)self.parentViewController.parentViewController.parentViewController;
    _viewController.shouldRotate = YES;
    self.isPortrait = YES;
    
    [self setContentsWithSelectedDate:self.calendarController.selectedDate];
}

- (void)setContentsWithSelectedDate:(NSDate *)date
{
    self.leftLightPlotVC.currentDate = self.calendarController.previousDate;
    [self.leftLightPlotVC setContentsWithDate:self.calendarController.previousDate];
    
    self.centerLightPlotVC.currentDate = date;
    [self.centerLightPlotVC setContentsWithDate:date];
    
    self.rightLightPlotVC.currentDate = self.calendarController.nextDate;
    [self.rightLightPlotVC setContentsWithDate:self.calendarController.nextDate];
}

- (void)setContentsWithSelectedWeek:(NSInteger)week ofYear:(NSInteger)year
{
    //[self.leftLightPlotVC setContentsWithWeek:self.calendarController.previousWeek ofYear:self.calendarController.yearForPreviousWeek];
    [self.centerLightPlotVC setContentsWithWeek:self.calendarController.selectedWeek ofYear:self.calendarController.selectedYear];
    //[self.rightLightPlotVC setContentsWithWeek:self.calendarController.nextWeek ofYear:self.calendarController.yearForPreviousWeek];
}

- (void)setContentsWithSelectedMonth:(SPCalendarMonth)month ofYear:(NSInteger)year
{
    //[self.leftLightPlotVC setContentsWithMonth:self.calendarController.previousMonth ofYear:self.calendarController.yearForPreviousMonth];
    [self.centerLightPlotVC setContentsWithMonth:self.calendarController.selectedMonth ofYear:self.calendarController.selectedYear];
    //[self.rightLightPlotVC setContentsWithMonth:self.calendarController.nextMonth ofYear:self.calendarController.yearForNextMonth];
    
}

- (void)setContentsWithSelectedYear:(NSInteger)year
{
    //[self.leftLightPlotVC setContentsWithYear:self.calendarController.previousYear];
    [self.centerLightPlotVC setContentsWithYear:self.calendarController.selectedYear];
    //[self.rightLightPlotVC setContentsWithYear:self.calendarController.nextYear];
}

- (void)didScrollToDashboardAtIndex:(NSInteger)index
{
    if (index != 1)
    {
        [self.scrollView scrollRectToVisible:self.centerLightPlotView.frame animated:NO];
        
        if (self.calendarController.calendarMode == SFADateRangeDay)
        {
            self.calendarController.selectedDate = index == 0 ? self.calendarController.previousDate : self.calendarController.nextDate;
        }
    }
}

- (void)adjustViewFrames
{
    self.slidingViewController.topViewController.view.frame = [UIScreen mainScreen].bounds;
    self.scrollView.frame                                   = [UIScreen mainScreen].bounds;
    
    CGRect leftLightPlotViewFrame                           = self.leftLightPlotView.frame;
    CGRect centerLightPlotViewFrame                         = self.centerLightPlotView.frame;
    CGRect rightLightPlotViewFrame                          = self.rightLightPlotView.frame;
    
    leftLightPlotViewFrame.size.width                       = self.scrollView.frame.size.width;
    leftLightPlotViewFrame.origin.x                         = 0;
    
    centerLightPlotViewFrame.size.width                     = self.scrollView.frame.size.width;
    centerLightPlotViewFrame.origin.x                       = self.scrollView.frame.size.width;
    
    rightLightPlotViewFrame.size.width                      = self.scrollView.frame.size.width;
    rightLightPlotViewFrame.origin.x                        = self.scrollView.frame.size.width * 2;
    
    self.leftLightPlotView.frame                            = leftLightPlotViewFrame;
    self.centerLightPlotView.frame                          = centerLightPlotViewFrame;
    self.rightLightPlotView.frame                           = rightLightPlotViewFrame;
    
    self.leftVCWidthConstraint.constant                     = self.scrollView.frame.size.width;
    self.centerVCWidthConstraint.constant                   = self.scrollView.frame.size.width;
    self.rightVCWidthConstraint.constant                    = self.scrollView.frame.size.width;
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    
    [self didScrollToDashboardAtIndex:index];
}

- (void)setScrollViewContentSize
{
    CGSize size                 = self.scrollView.frame.size;
    size.width                  *= (self.calendarController.selectedDate.isToday ? 2 : 3);
    self.scrollView.contentSize = size;
}

#pragma mark - SFACalendarControllerDelegate Methods

- (void)calendarController:(SFAMainViewController *)calendarController didSelectDate:(NSDate *)date
{
    NSComparisonResult result                       = [date compareToDate:[NSDate date]];
    self.navigationItem.rightBarButtonItem.enabled  = result == NSOrderedSame || result == NSOrderedAscending;
    
    [self setContentsWithSelectedDate:date];
}

#pragma mark - SFALightPlotViewControllerDelegate Methods
- (void)lightPlotViewController:(SFALightPlotViewController *)viewController didChangeDateRange:(SFADateRange)dateRange
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
    
}

@end
