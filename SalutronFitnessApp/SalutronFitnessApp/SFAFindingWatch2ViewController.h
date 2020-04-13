//
//  SFAFindingWatch2ViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/3/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAFindingWatch2ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIView *progressBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarWidth;

- (IBAction)leftButtonClicked:(id)sender;
- (IBAction)rightButtonCicked:(id)sender;

@end
