//
//  SFASleepLogsScrollViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/27/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Comparison.h"

#import "SFAMainViewController.h"
#import "SFASleepLogsViewController.h"
#import "SFASleepLogDataViewController.h"
#import "SFASleepLogsScrollViewController.h"
#import "SFASlidingViewController.h"
#import "UIViewController+Helper.h"

#define LEFT_SLEEP_LOGS_SEGUE_IDENTIFIER    @"LeftSleepLogs"
#define CENTER_SLEEP_LOGS_SEGUE_IDENTIFIER  @"CenterSleepLogs"
#define RIGHT_SLEEP_LOGS_SEGUE_IDENTIFIER   @"RightSleepLogs"
#define ADD_SLEEP_LOG_SEGUE_IDENTIFIER      @"SleepLogsToAddSleepLog"

@interface SFASleepLogsScrollViewController () <UIScrollViewDelegate, SFACalendarControllerDelegate, SFASleepLogDataViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *leftSleepLogsView;
@property (weak, nonatomic) IBOutlet UIView *centerSleepLogsView;
@property (weak, nonatomic) IBOutlet UIView *rightSleepLogsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftSleepLogsWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerSleepLogsWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightSleepLogsWidthConstraint;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) SFASleepLogsViewController  *leftSleepLogs;
@property (weak, nonatomic) SFASleepLogsViewController  *centerSleepLogs;
@property (weak, nonatomic) SFASleepLogsViewController  *rightSleepLogs;

@property (nonatomic) BOOL isPortrait;

@end

@implementation SFASleepLogsScrollViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initializeObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    SFASlidingViewController *viewController    = (SFASlidingViewController *)self.slidingViewController;
    viewController.shouldRotate                 = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    SFASlidingViewController *viewController    = (SFASlidingViewController *)self.slidingViewController;
    viewController.shouldRotate                 = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    if (!self.isIOS8AndAbove && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (self.isPortrait) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        self.leftSleepLogsWidthConstraint.constant = screenWidth;
        self.centerSleepLogsWidthConstraint.constant = screenWidth;
        self.rightSleepLogsWidthConstraint.constant = screenWidth;
        }
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.isIOS8AndAbove) {
        [self adjustViewFrames];
        [self.scrollView scrollRectToVisible:self.centerSleepLogsView.frame animated:NO];
        [self.scrollView setContentOffset:CGPointMake(self.centerSleepLogsView.frame.size.width, 0)];
    }
    else{
        [self.scrollView scrollRectToVisible:self.centerSleepLogsView.frame animated:NO];
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
    if ([segue.identifier isEqualToString:LEFT_SLEEP_LOGS_SEGUE_IDENTIFIER])
    {
        self.leftSleepLogs = (SFASleepLogsViewController *) segue.destinationViewController;
        self.leftSleepLogs.delegate = self;
    }
    else if ([segue.identifier isEqualToString:CENTER_SLEEP_LOGS_SEGUE_IDENTIFIER])
    {
        self.centerSleepLogs = (SFASleepLogsViewController *) segue.destinationViewController;
        self.centerSleepLogs.delegate = self;
    }
    else if ([segue.identifier isEqualToString:RIGHT_SLEEP_LOGS_SEGUE_IDENTIFIER])
    {
        self.rightSleepLogs = (SFASleepLogsViewController *) segue.destinationViewController;
        self.rightSleepLogs.delegate = self;
    } else if ([segue.identifier isEqualToString:ADD_SLEEP_LOG_SEGUE_IDENTIFIER]) {
        SFASleepLogDataViewController *viewController   = (SFASleepLogDataViewController *)segue.destinationViewController;
        viewController.delegate                         = self;
        viewController.mode                             = SFASleepLogDataModeAdd;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.isPortrait = YES;
        if (self.isIOS8AndAbove) {
            self.leftSleepLogsWidthConstraint.constant      = self.view.window.frame.size.height;
            self.centerSleepLogsWidthConstraint.constant    = self.view.window.frame.size.height;
            self.rightSleepLogsWidthConstraint.constant     = self.view.window.frame.size.height;
        }
        else{
            self.leftSleepLogsWidthConstraint.constant      = self.view.window.frame.size.width;
            self.centerSleepLogsWidthConstraint.constant    = self.view.window.frame.size.width;
            self.rightSleepLogsWidthConstraint.constant     = self.view.window.frame.size.width;
        }
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        self.isPortrait = NO;
        if (self.isIOS8AndAbove) {
            self.leftSleepLogsWidthConstraint.constant      = self.view.window.frame.size.width;
            self.centerSleepLogsWidthConstraint.constant    = self.view.window.frame.size.width;
            self.rightSleepLogsWidthConstraint.constant     = self.view.window.frame.size.width;
        }
        else{
            self.leftSleepLogsWidthConstraint.constant      = self.view.window.frame.size.height;
            self.centerSleepLogsWidthConstraint.constant    = self.view.window.frame.size.height;
            self.rightSleepLogsWidthConstraint.constant     = self.view.window.frame.size.height;
        }
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.calendarController hideCalendarView];
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
    
    [self.scrollView scrollRectToVisible:self.centerSleepLogsView.frame animated:YES];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    [self didScrollToSleepLogsAtIndex:index];
}

#pragma mark - Private Methods

- (void)initializeObjects
{
    self.navigationItem.title = LS_SLEEP_LOGS;
    
    [self setContentsWithDate:self.calendarController.selectedDate];
    self.isPortrait = YES;
}

- (void)didScrollToSleepLogsAtIndex:(NSInteger)index
{
    if (index != 1)
    {
        [self.scrollView scrollRectToVisible:self.centerSleepLogsView.frame animated:NO];
        
        if (self.calendarController.calendarMode == SFADateRangeDay) {
            self.calendarController.selectedDate = index == 0 ? self.calendarController.previousDate : self.calendarController.nextDate;
        }
    }
}

- (void)setContentsWithDate:(NSDate *)date
{
    [self.leftSleepLogs setContentsWithDate:self.calendarController.previousDate];
    [self.centerSleepLogs setContentsWithDate:date];
    [self.rightSleepLogs setContentsWithDate:self.calendarController.nextDate];
}

- (void)adjustViewFrames
{
    self.slidingViewController.topViewController.view.frame = [UIScreen mainScreen].bounds;
    self.scrollView.frame                                   = [UIScreen mainScreen].bounds;
    
    CGRect leftSleepLogsViewFrame                           = self.leftSleepLogsView.frame;
    CGRect centerSleepLogsViewFrame                         = self.centerSleepLogsView.frame;
    CGRect rightSleepLogsViewFrame                          = self.rightSleepLogsView.frame;
    
    leftSleepLogsViewFrame.size.width                       = self.scrollView.frame.size.width;
    leftSleepLogsViewFrame.origin.x                         = 0;
    
    centerSleepLogsViewFrame.size.width                     = self.scrollView.frame.size.width;
    centerSleepLogsViewFrame.origin.x                       = self.scrollView.frame.size.width;
    
    rightSleepLogsViewFrame.size.width                      = self.scrollView.frame.size.width;
    rightSleepLogsViewFrame.origin.x                        = self.scrollView.frame.size.width * 2;
    
    self.leftSleepLogsView.frame                            = leftSleepLogsViewFrame;
    self.centerSleepLogsView.frame                          = centerSleepLogsViewFrame;
    self.rightSleepLogsView.frame                           = rightSleepLogsViewFrame;
    
    self.leftSleepLogsWidthConstraint.constant              = self.scrollView.frame.size.width;
    self.centerSleepLogsWidthConstraint.constant            = self.scrollView.frame.size.width;
    self.rightSleepLogsWidthConstraint.constant             = self.scrollView.frame.size.width;
}

#pragma mark - SFACalendarControllerDelegate Methods

- (void)calendarController:(SFAMainViewController *)calendarController didSelectDate:(NSDate *)date
{
    NSComparisonResult result                       = [date compareToDate:[NSDate date]];
    self.navigationItem.rightBarButtonItem.enabled  = result == NSOrderedSame || result == NSOrderedAscending;
    
    [self setContentsWithDate:date];
}

#pragma mark - SFASleepLogDataViewControllerDelegate Methods

- (void)sleepLogDataViewController:(SFASleepLogDataViewController *)viewController didAddSleepDatabaseEntity:(SleepDatabaseEntity *)sleepDatabaseEntity
{
    [self setContentsWithDate:self.calendarController.selectedDate];
}

@end
