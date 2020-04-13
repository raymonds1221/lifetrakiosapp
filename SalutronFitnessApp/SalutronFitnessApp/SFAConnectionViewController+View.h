//
//  SFAConnectionViewController+View.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 6/25/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAConnectionViewController.h"

@interface SFAConnectionViewController (Utilities)

- (void)showEstablishingConnectionview;

- (void)hideEstablishingConnectionView;

- (void)showTryAgainViewWithTarget:(id)target cancelSelector:(SEL)cancelSelector tryAgainSelector:(SEL)tryAgainSelector;

- (void)hideTryAgainView;

- (void)showChecksumFailViewWithTarget:(id)target cancelSelector:(SEL)cancelSelector tryAgainSelector:(SEL)tryAgainSelector;

- (void)hideChecksumErrorView;

@end
