//
//  SFAFiveEasyStepsViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/2/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFAViewController.h"

@interface SFAFiveEasyStepsViewController : SFAViewController
@property (weak, nonatomic) IBOutlet UILabel *welcomeTitle;
@property (weak, nonatomic) IBOutlet UILabel *setupLabel;
@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;
@property (weak, nonatomic) IBOutlet UILabel *pleaseMakeSureLabel;
- (IBAction)getStartedButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *step1Label;
@property (weak, nonatomic) IBOutlet UILabel *step2Label;
@property (weak, nonatomic) IBOutlet UILabel *step3Label;
@property (weak, nonatomic) IBOutlet UILabel *step4Label;
@property (weak, nonatomic) IBOutlet UILabel *step5Label;

@end
