//
//  SFASyncPageViewController.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 1/3/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFASyncPageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imageSync;
@property (assign, nonatomic) unsigned short int watchModel;
@property (assign, nonatomic) BOOL updateTimeAndDate;

- (IBAction)cancelPressed;

@end
