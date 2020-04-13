//
//  SFANotificationsViewController+View.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 10/11/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFANotificationsViewController.h"

@interface SFANotificationsViewController (Utilities)

- (void)showTryAgainViewWithTarget:(id)target cancelSelector:(SEL)cancelSelector tryAgainSelector:(SEL)tryAgainSelector;

- (void)hideTryAgainView;

@end
