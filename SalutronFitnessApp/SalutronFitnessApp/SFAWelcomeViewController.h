//
//  SFAWelcomeViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/17/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAWelcomeViewController : UIViewController

- (IBAction)welcomeViewUnwindSegue:(UIStoryboardSegue *)segue;
- (IBAction)welcomeViewUnwindSegueWithoutLogout:(UIStoryboardSegue *)segue;
- (IBAction)connectWatchButtonClicked:(id)sender;

@end
