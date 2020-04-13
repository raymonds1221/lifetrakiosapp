//
//  SFAIntroViewController.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/19/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAIntroViewController : UIViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate, CBCentralManagerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) UIButton *setupDevice;
@property (strong, nonatomic) UIButton *seeYourStats;
@property (weak, nonatomic) SalutronSDK *salutronSDK;

- (IBAction)showStatisticsButtonPressed:(id)sender;
- (IBAction)unwindFromWelcomeView:(UIStoryboardSegue *)segue;

@end
