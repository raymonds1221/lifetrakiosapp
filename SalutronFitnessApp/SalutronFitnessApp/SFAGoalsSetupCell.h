//
//  SFAGoalsSetupCell.h
//  SalutronFitnessApp
//
//  Created by Dana Elisa Nicolas on 11/14/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAGoalsSetupCell : UITableViewCell

@property (strong, nonatomic) UILabel *goalName;
@property (strong, nonatomic) UITextField *goalCurrentValue;
@property (strong, nonatomic) UILabel *goalMinValue;
@property (strong, nonatomic) UILabel *goalMaxValue;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UILabel *goalUnit;
@property (strong, nonatomic) UIView *cellSeparator;

@end
