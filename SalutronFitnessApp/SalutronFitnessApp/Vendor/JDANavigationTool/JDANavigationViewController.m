//
//  JDANavigationViewController.m
//
//  Created by John Dwaine Alingarog on 9/30/13.
//  Copyright (c) 2013 Mobilemo. All rights reserved.
//

#import "JDANavigationViewController.h"
#import "ECSlidingViewController.h"

@interface JDANavigationViewController ()

@property (strong, nonatomic, retain) UIView *leftSlidingView;
- (void)addLeftEdgeSlidingView;

@end

@implementation JDANavigationViewController

#pragma mark - UIViewController methods
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Add pan gesture on the left side of the view
    [self addLeftEdgeSlidingView];
    [_leftSlidingView addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [_leftSlidingView removeGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.view.frame.origin.x == 240.0f)
    {
        //If side bar is shown, remove left edge pan gesture to whole view pan gesture
        [_leftSlidingView removeGestureRecognizer:self.slidingViewController.panGesture];
        [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    }
    else
    {
        //If side bar is hidden, remove whole view pan gesture to left edge pan gesture
        [_leftSlidingView addGestureRecognizer:self.slidingViewController.panGesture];
        [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
    }
}

#pragma mark - Private instance methods
- (void)addLeftEdgeSlidingView
{
    //Create subview on the left side of the view
    CGRect leftSlidingViewFrame         = CGRectMake(0, 0, 10.0f, self.view.frame.size.height);
    _leftSlidingView                    = [[UIView alloc] initWithFrame:leftSlidingViewFrame];
    _leftSlidingView.backgroundColor    = [UIColor clearColor];
    [self.view addSubview:_leftSlidingView];
}

@end
