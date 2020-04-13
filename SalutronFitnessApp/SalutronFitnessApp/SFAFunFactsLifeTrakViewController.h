//
//  SFAFunFactsLifeTrakViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 12/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAFunFactsLifeTrakViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *funFactsView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIImageView *funFactIcon;
@property (weak, nonatomic) IBOutlet UILabel *funFactTitle;
@property (weak, nonatomic) IBOutlet UILabel *funFactContent;
@property (weak, nonatomic) IBOutlet UIButton *moreFactsButton1;
@property (weak, nonatomic) IBOutlet UIButton *moreFactsButton2;
@property (weak, nonatomic) IBOutlet UIButton *moreFactsButton3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonConstraint1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonConstraint2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonConstraint3;
- (IBAction)closeButtonClicked:(id)sender;
- (IBAction)moreFactsButton1Clicked:(id)sender;
- (IBAction)moreFactsButton2Clicked:(id)sender;
- (IBAction)moreFactsButton3Clicked:(id)sender;
- (IBAction)moreButtonChartClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *funFactChartView;
@property (weak, nonatomic) IBOutlet UILabel *funChartTitle;
@property (weak, nonatomic) IBOutlet UILabel *funFactChartContent;
@property (weak, nonatomic) IBOutlet UIImageView *funFactChartImage;
@property (weak, nonatomic) IBOutlet UIButton *funFactChartMoreButton;

@property (nonatomic) BOOL isLightPlot;




@end
