//
//  SFADashboardViewController+View.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 10/4/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFADashboardViewController.h"

@interface SFADashboardViewController (Utilities)

- (void)showTryAgainViewWithTarget:(id)target cancelSelector:(SEL)cancelSelector tryAgainSelector:(SEL)tryAgainSelector;

- (void)hideTryAgainView;

@end
