//
//  SFASettingsViewController+View.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 3/3/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFASettingsViewController.h"

@interface SFASettingsViewController (View)

- (void)showTryAgainViewWithTarget:(id)target cancelSelector:(SEL)cancelSelector tryAgainSelector:(SEL)tryAgainSelector;

- (void)hideTryAgainView;

@end
