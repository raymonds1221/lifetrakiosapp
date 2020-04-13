//
//  SFAContinuousHRPageViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 11/26/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//


#import "SFAContinuousHRPageViewController.h"
#import "SFAMainViewController.h"
#import "SFASlidingViewController.h"
#import "SFAContinuousHRViewController.h"
#import "UIViewController+Helper.h"

#import "SFAR420WorkoutViewController.h"

#define PAGE_COUNT 3

@interface SFAContinuousHRPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, SFACalendarControllerDelegate>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic) BOOL transitionCompleted;

@property (nonatomic) BOOL isForwardTransition;
@property (nonatomic) BOOL isPortrait;

@end

@implementation SFAContinuousHRPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    SFASlidingViewController *_viewController = (SFASlidingViewController *)self.parentViewController.parentViewController.parentViewController;
    _viewController.shouldRotate = YES;
    
    self.isPortrait = YES;
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    self.navigationItem.title = LS_HEART_RATE;
    
    [self setPageContent];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    if (self.isIOS8AndAbove && !self.isPortrait) {
        CGRect viewFrame = [UIScreen mainScreen].bounds;
        self.slidingViewController.topViewController.view.frame = viewFrame;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPageContent{
    SFAContinuousHRViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Graphs" bundle:nil];
    SFAContinuousHRViewController *pageContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"SFAContinuousHRViewController"];
    pageContentViewController.date = self.calendarController.previousDate;
    
    return pageContentViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    // Create a new view controller and pass suitable data.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Graphs" bundle:nil];
    SFAContinuousHRViewController *pageContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"SFAContinuousHRViewController"];
    pageContentViewController.date = self.calendarController.nextDate;
    
    return pageContentViewController;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    // If the page did not turn
    if (!completed)
    {
        // You do nothing because whatever page you thought
        // the book was on before the gesture started is still the correct page
        return;
    }
    self.transitionCompleted = YES;
    
    if (self.isForwardTransition) {
        self.calendarController.selectedDate = self.calendarController.nextDate;
    }
    else{
        self.calendarController.selectedDate = self.calendarController.previousDate;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
    SFAContinuousHRViewController *hrVC = (SFAContinuousHRViewController *)pendingViewControllers[0];
    DDLogInfo(@"%@ ? %@", hrVC.date, self.calendarController.selectedDate);
    if ([hrVC.date compare:self.calendarController.selectedDate] == NSOrderedAscending) {
        self.isForwardTransition = NO;
    }
    else{
        self.isForwardTransition = YES;
    }
}

- (SFAContinuousHRViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // Create a new view controller and pass suitable data.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Graphs" bundle:nil];
    SFAContinuousHRViewController *pageContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"SFAContinuousHRViewController"];
    pageContentViewController.date = self.calendarController.selectedDate;
    return pageContentViewController;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    CGRect viewFrame = [UIScreen mainScreen].bounds;
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        //self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        if (self.isIOS8AndAbove) {
            self.slidingViewController.topViewController.view.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
        }
        else{
            self.slidingViewController.topViewController.view.bounds = CGRectMake(0, 0, viewFrame.size.height, viewFrame.size.width);
        }
        
        self.isPortrait = YES;
        //self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    else{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.calendarController hideCalendarView];
        [self.calendarController hideCalendar];
        
        self.isPortrait = NO;
       // self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        //self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
    }
    
    /*
     if (fromInterfaceOrientation == UIInterfaceOrientationPortrait) {
     
     }
     else{
     
     }
     */
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    
    CGRect viewFrame = [UIScreen mainScreen].bounds;
    if (fromInterfaceOrientation == UIInterfaceOrientationPortrait) {
        if (self.isIOS8AndAbove) {
            self.slidingViewController.topViewController.view.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
        }
        else{
            self.slidingViewController.topViewController.view.bounds = CGRectMake(0, 0, viewFrame.size.height, viewFrame.size.width);
        }
        
        self.isPortrait = NO;
    }
    else{
        //self.slidingViewController.topViewController.view.frame = CGRectMake(0, 20, viewFrame.size.width, viewFrame.size.height);
        
        self.isPortrait = YES;
    }
    
    
    if (fromInterfaceOrientation != UIInterfaceOrientationPortrait) {
        CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
        navigationBarFrame.origin = CGPointMake(0, 0);
        navigationBarFrame.size.height = 44;
        [self.navigationController.navigationBar setFrame:navigationBarFrame];
    }
    
    //disable iupageviewcontroller scroll
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = (fromInterfaceOrientation != UIInterfaceOrientationPortrait);
        }
    }
    
    //self.pageViewController.view.frame = self.view.frame;
}

- (void)calendarController:(SFAMainViewController *)calendarController didSelectDate:(NSDate *)date{
    //self.pageViewController.dataSource = nil;
    //self.pageViewController.dataSource = self;
    //self.calendarController.selectedDate = date;
    //[self setPageContent];
    if (!self.transitionCompleted) {
        [self setPageContent];
    }
    self.transitionCompleted = NO;
}

@end
