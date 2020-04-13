//
//  SFAWorkoutResultsScrollViewController.m
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/6/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAWorkoutResultsScrollViewController.h"
#import "SFAMainViewController.h"
#import "SFAWorkoutResultsViewController.h"
#import "NSDate+Comparison.h"
#import "SFASlidingViewController.h"

#import "WorkoutInfoEntity+Data.h"
#import "UIViewController+Helper.h"

#define DAY_SECONDS 60 * 60 * 24

#define LEFT_FITNESS_RESULTS_SEGUE_IDENTIFIER       @"LeftWorkoutResults"
#define CENTER_FITNESS_RESULTS_SEGUE_IDENTIFIER     @"CenterWorkoutResults"
#define RIGHT_FITNESS_RESULTS_SEGUE_IDENTIFIER      @"RightWorkoutResults"

@interface SFAWorkoutResultsScrollViewController () <SFAWorkoutResultsViewControllerDelegate, SFACalendarControllerDelegate>

@property (weak, nonatomic) SFAWorkoutResultsViewController  *leftWorkoutResults;
@property (weak, nonatomic) SFAWorkoutResultsViewController  *centerWorkoutResults;
@property (weak, nonatomic) SFAWorkoutResultsViewController  *rightWorkoutResults;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftWorkoutWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerWorkoutWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightWorkoutWidthConstraint;
@property (nonatomic) BOOL isPortrait;

@end

@implementation SFAWorkoutResultsScrollViewController

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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //change to yes if you want to support landscape view
    SFASlidingViewController *_viewController = (SFASlidingViewController *)self.parentViewController.parentViewController.parentViewController;
    _viewController.shouldRotate = YES;
    
    //[self setScrollViewContentSize];
    //[self scrollToWorkoutIndex:self.workoutIndex withWorkoutCount:self.workoutCount];
    if (self.isIOS8AndAbove) {
        [self adjustViewFrames];
        [self.scrollView scrollRectToVisible:self.centerWorkoutResultsView.frame animated:NO];
        [self.scrollView setContentOffset:CGPointMake(self.centerWorkoutResultsView.frame.size.width, 0)];
    }
    else{
        [self.scrollView scrollRectToVisible:self.centerWorkoutResultsView.frame animated:NO];
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
        
        self.leftWorkoutWidthConstraint.constant = screenWidth;
        self.centerWorkoutWidthConstraint.constant = screenWidth;
        self.rightWorkoutWidthConstraint.constant = screenWidth;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        self.isPortrait = YES;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        if (self.isIOS8AndAbove) {
            self.leftWorkoutWidthConstraint.constant    = self.view.window.frame.size.height;
            self.rightWorkoutWidthConstraint.constant   = self.view.window.frame.size.height;
            self.centerWorkoutWidthConstraint.constant  = self.view.window.frame.size.height;
        }
        else{
            self.leftWorkoutWidthConstraint.constant    = self.view.window.frame.size.width;
            self.rightWorkoutWidthConstraint.constant   = self.view.window.frame.size.width;
            self.centerWorkoutWidthConstraint.constant  = self.view.window.frame.size.width;
        }
    }
    else
    {
        self.isPortrait = NO;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.calendarController hideCalendarView];
        if (self.isIOS8AndAbove) {
            self.leftWorkoutWidthConstraint.constant    = self.view.window.frame.size.width;
            self.rightWorkoutWidthConstraint.constant   = self.view.window.frame.size.width;
            self.centerWorkoutWidthConstraint.constant  = self.view.window.frame.size.width;
        }
        else{
            self.leftWorkoutWidthConstraint.constant    = self.view.window.frame.size.height;
            self.rightWorkoutWidthConstraint.constant   = self.view.window.frame.size.height;
            self.centerWorkoutWidthConstraint.constant  = self.view.window.frame.size.height;
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
    
    [self.scrollView scrollRectToVisible:self.centerWorkoutResultsView.frame animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:LEFT_FITNESS_RESULTS_SEGUE_IDENTIFIER])
    {
        self.leftWorkoutResults = (SFAWorkoutResultsViewController *) segue.destinationViewController;
        self.leftWorkoutResults.delegate = self;
    }
    else if ([segue.identifier isEqualToString:CENTER_FITNESS_RESULTS_SEGUE_IDENTIFIER])
    {
        self.centerWorkoutResults = (SFAWorkoutResultsViewController *) segue.destinationViewController;
        self.centerWorkoutResults.delegate = self;
    }
    else if ([segue.identifier isEqualToString:RIGHT_FITNESS_RESULTS_SEGUE_IDENTIFIER])
    {
        self.rightWorkoutResults = (SFAWorkoutResultsViewController *) segue.destinationViewController;
        self.rightWorkoutResults.delegate = self;
    }
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    [self didScrollToDashboardAtIndex:index];
}

#pragma mark - SFAWorkoutResultsViewControllerDelegate Methods

- (void)workoutResultsViewController:(SFAWorkoutResultsViewController *)viewController didAddGraphType:(SFAGraphType)graphType
{
    if (viewController == self.leftWorkoutResults)
    {
        [self.centerWorkoutResults addGraphType:graphType];
        [self.rightWorkoutResults addGraphType:graphType];
    }
    else if (viewController == self.centerWorkoutResults)
    {
        [self.leftWorkoutResults addGraphType:graphType];
        [self.rightWorkoutResults addGraphType:graphType];
    }
    else if (viewController == self.rightWorkoutResults)
    {
        [self.leftWorkoutResults addGraphType:graphType];
        [self.centerWorkoutResults addGraphType:graphType];
    }
}

- (void)workoutResultsViewController:(SFAWorkoutResultsViewController *)viewController didRemoveGraphType:(SFAGraphType)graphType
{
    if (viewController == self.leftWorkoutResults)
    {
        [self.centerWorkoutResults removeGraphType:graphType];
        [self.rightWorkoutResults removeGraphType:graphType];
    }
    else if (viewController == self.centerWorkoutResults)
    {
        [self.leftWorkoutResults removeGraphType:graphType];
        [self.rightWorkoutResults removeGraphType:graphType];
    }
    else if (viewController == self.rightWorkoutResults)
    {
        [self.leftWorkoutResults removeGraphType:graphType];
        [self.centerWorkoutResults removeGraphType:graphType];
    }
}

#pragma mark - Getters

- (NSInteger)workoutCount
{
    if (_workoutCount == 0)
    {
        NSArray *workouts = [WorkoutInfoEntity getWorkoutInfoWithDate:self.calendarController.selectedDate];
        _workoutCount = workouts.count;
    }
    
    return _workoutCount;
}

#pragma mark - Private Methods

- (void)setScrollViewContentSize
{
    CGSize size                 = self.scrollView.frame.size;
    size.width                  *= self.workoutCount > 3 ? 3 : self.workoutCount;
    self.scrollView.contentSize = size;
}

- (void)initializeObjects
{
    //change to yes if you want to support landscape view
    SFASlidingViewController *_viewController = (SFASlidingViewController *)self.parentViewController.parentViewController.parentViewController;
    _viewController.shouldRotate = YES;
    
    self.workoutIndex = 0;
    
    self.isPortrait = YES;
    
    self.navigationItem.title = LS_WORKOUT;
    
    // Initial Calories Data
    [self setContentsWithWorkoutIndex:self.workoutIndex workoutCount:self.workoutCount];
    
    //self.navigationItem.title = [NSString stringWithFormat:LS_WORKOUT_VARIABLE, self.workoutIndex + 1];
}

- (void)scrollToWorkoutIndex:(NSInteger)workoutIndex withWorkoutCount:(NSInteger)workoutCount
{
    if (workoutIndex == 0)
    {
        [self.scrollView scrollRectToVisible:self.leftWorkoutResultsView.frame animated:NO];
        return;
    }
    else if (workoutIndex != 1 && workoutIndex == workoutCount - 1)
    {
        [self.scrollView scrollRectToVisible:self.rightWorkoutResultsView.frame animated:NO];
        return;
    }
    
    [self.scrollView scrollRectToVisible:self.centerWorkoutResultsView.frame animated:NO];
}

- (void)didScrollToDashboardAtIndex:(NSInteger)index
{
    /*if (index == 0)
    {
        self.workoutIndex -= self.workoutIndex > 0 ? 1 : 0;
        
        if (self.workoutIndex > 0)
        {
            [self setContentsWithWorkoutIndex:self.workoutIndex workoutCount:self.workoutCount];
            [self scrollToWorkoutIndex:self.workoutIndex withWorkoutCount:self.workoutCount];
        }
    }
    else if (index == 1)
    {
        if (self.workoutIndex == 0)
        {
            self.workoutIndex ++;
        }
        else if (self.workoutIndex == self.workoutCount - 1)
        {
            self.workoutIndex --;
        }
    }
    else if (index == 2)
    {
        self.workoutIndex += self.workoutIndex < self.workoutCount - 1 ? 1 : 0;
        
        if (self.workoutIndex < self.workoutCount - 1)
        {
            [self setContentsWithWorkoutIndex:self.workoutIndex workoutCount:self.workoutCount];
            [self scrollToWorkoutIndex:self.workoutIndex withWorkoutCount:self.workoutCount];
        }
    }
    
    self.navigationItem.title = [NSString stringWithFormat:LS_WORKOUT_VARIABLE, self.workoutIndex + 1];
    [self.leftWorkoutResults resetScrollViewOffset];
    [self.centerWorkoutResults resetScrollViewOffset];
    [self.rightWorkoutResults resetScrollViewOffset];*/
        
    if (index != 1)
    {
        [self.scrollView scrollRectToVisible:self.centerWorkoutResultsView.frame animated:NO];
        
        if (self.calendarController.calendarMode == SFADateRangeDay) {
            self.calendarController.selectedDate = index == 0 ? self.calendarController.previousDate : self.calendarController.nextDate;
        }
    }
    
    self.centerWorkoutResults.workoutIndex = 0;
    self.leftWorkoutResults.workoutIndex = 0;
    self.rightWorkoutResults.workoutIndex = 0;
    [self.leftWorkoutResults resetScrollViewOffset];
    [self.centerWorkoutResults resetScrollViewOffset];
    [self.rightWorkoutResults resetScrollViewOffset];
}

- (void)setContentsWithWorkoutIndex:(NSInteger)workoutIndex workoutCount:(NSInteger)workoutCount
{
    [self.leftWorkoutResults setContentsWithDate:self.calendarController.previousDate workoutIndex:0];
    [self.centerWorkoutResults setContentsWithDate:self.calendarController.selectedDate workoutIndex:0];
    [self.rightWorkoutResults setContentsWithDate:self.calendarController.nextDate workoutIndex:0];
}

- (void)setContentsWithDate:(NSDate *)date
{
    [self.leftWorkoutResults setContentsWithDate:self.calendarController.previousDate workoutIndex:0];
    [self.centerWorkoutResults setContentsWithDate:date workoutIndex:0];
    [self.rightWorkoutResults setContentsWithDate:self.calendarController.nextDate workoutIndex:0];
}

- (void)adjustViewFrames
{
    self.slidingViewController.topViewController.view.frame = [UIScreen mainScreen].bounds;
    self.scrollView.frame                                   = [UIScreen mainScreen].bounds;
    
    CGRect leftWorkoutResultsViewFrame                      = self.leftWorkoutResultsView.frame;
    CGRect centerWorkoutResultsViewFrame                    = self.centerWorkoutResultsView.frame;
    CGRect rightWorkoutResultsViewFrame                     = self.rightWorkoutResultsView.frame;
    
    leftWorkoutResultsViewFrame.size.width                  = self.scrollView.frame.size.width;
    leftWorkoutResultsViewFrame.origin.x                    = 0;
    
    centerWorkoutResultsViewFrame.size.width                = self.scrollView.frame.size.width;
    centerWorkoutResultsViewFrame.origin.x                  = self.scrollView.frame.size.width;
    
    rightWorkoutResultsViewFrame.size.width                 = self.scrollView.frame.size.width;
    rightWorkoutResultsViewFrame.origin.x                   = self.scrollView.frame.size.width * 2;
    
    self.leftWorkoutResultsView.frame                       = leftWorkoutResultsViewFrame;
    self.centerWorkoutResultsView.frame                     = centerWorkoutResultsViewFrame;
    self.rightWorkoutResultsView.frame                      = rightWorkoutResultsViewFrame;
    
    self.leftWorkoutWidthConstraint.constant                = self.scrollView.frame.size.width;
    self.centerWorkoutWidthConstraint.constant              = self.scrollView.frame.size.width;
    self.rightWorkoutWidthConstraint.constant               = self.scrollView.frame.size.width;
}

#pragma mark - SFACalendarControllerDelegate

- (void)calendarController:(SFAMainViewController *)calendarController didSelectDate:(NSDate *)date {
    [self setContentsWithWorkoutIndex:self.workoutIndex workoutCount:self.workoutCount];
}

@end
