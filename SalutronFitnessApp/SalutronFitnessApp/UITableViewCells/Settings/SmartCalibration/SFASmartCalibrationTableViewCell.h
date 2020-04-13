//
//  SFASmartCalibrationTableViewCell.h
//  SalutronFitnessApp
//
//  Created by Dana Elisa Nicolas on 1/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFASmartCalibrationTableViewCellDelegate;

@interface SFASmartCalibrationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (weak, nonatomic) IBOutlet UIButton *stepsOption;
@property (weak, nonatomic) IBOutlet UILabel *distanceCalLabel;

@property (weak, nonatomic) IBOutlet UISwitch *autoElSwitch;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *longerStridesLabel;
@property (weak, nonatomic) IBOutlet UILabel *shorterStridesLabel;
@property (strong, nonatomic) id<SFASmartCalibrationTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *checkButton;
- (IBAction)checkButtonClicked:(id)sender;

@end


@protocol SFASmartCalibrationTableViewCellDelegate <NSObject>

- (void)cellButtonClicked:(UIButton *)sender andCellTitle:(NSString *)cellTitle;

@end