//
//  SFASlidingViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/14/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "ECSlidingViewController.h"

@interface SFASlidingViewController : ECSlidingViewController

@property (readwrite, nonatomic) BOOL shouldRotate;
@property (readwrite, nonatomic) BOOL isActigraphy;

- (void)showDashboard;
- (void)showGoalsSetup;
- (void)showActigraphy;
- (void)showSyncSetup;
- (void)showPulsewave;
- (void)showSettings;
- (void)showMyAccount;
- (void)showPartners;

@end
