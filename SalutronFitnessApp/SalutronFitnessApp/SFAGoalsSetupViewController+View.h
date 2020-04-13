//
//  SFAGoalsSetupViewController+View.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 3/2/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAGoalsSetupViewController.h"

@interface SFAGoalsSetupViewController (View)

- (void)showTryAgainViewWithTarget:(id)target cancelSelector:(SEL)cancelSelector tryAgainSelector:(SEL)tryAgainSelector;

- (void)hideTryAgainView;

- (BOOL)isTryAgainShowing;

@end
