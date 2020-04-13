//
//  SFAFindingWatchViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/2/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAFindingWatchViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

- (IBAction)leftButtonClicked:(id)sender;
- (IBAction)rightButtonCicked:(id)sender;
@end
