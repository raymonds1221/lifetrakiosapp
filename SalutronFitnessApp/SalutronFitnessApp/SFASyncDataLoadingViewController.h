//
//  SFASyncDataLoadingViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/3/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFASyncDataLoadingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (nonatomic) int deviceIndex;
@property (nonatomic) NSString *deviceModelString;
@property (nonatomic) Status status;
@property (nonatomic) WatchModel watchModel;
@property (weak, nonatomic) IBOutlet UIView *progressBar;
@property (weak, nonatomic) IBOutlet UIView *progressBarGray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarConstraint;

- (IBAction)leftButtonClicked:(id)sender;
- (IBAction)rightButtonCicked:(id)sender;


@end
