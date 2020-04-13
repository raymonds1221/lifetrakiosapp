//
//  SFASettingsCellWithButton.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 5/4/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFASettingsCellWithButtonDelegate;

@interface SFASettingsCellWithButton : UITableViewCell <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *cellButton;
@property (weak, nonatomic) IBOutlet UILabel *lableTitle;
@property (weak, nonatomic) IBOutlet UITextField *cellTextField;
@property (strong, nonatomic) id<SFASettingsCellWithButtonDelegate> delegate;
@property (strong, nonatomic) NSString *previousTextFieldValue;
@property (weak, nonatomic) IBOutlet UISlider *cellSlider;
- (IBAction)cellSliderValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *leftSmallLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightSmallLabel;
@property (nonatomic) int sliderMultipleIncrement;


- (IBAction)buttonClicked:(id)sender;
- (void)setDateFormat:(DateFormat)dateFormat;
@end


@protocol SFASettingsCellWithButtonDelegate <NSObject>

- (void)didButtonClicked:(UIButton *)sender withLabelTitle:(NSString *)title andCellTag:(int)cellTag;
@optional
- (void)didTextFieldEditDone:(UITextField *)sender withLabelTitle:(NSString *)title andValue:(NSString *)textFieldValue andCellTag:(int)cellTag;
- (void)didTextFieldClicked:(UITextField *)sender withLabelTitle:(NSString *)title andValue:(NSString *)textFieldValue andCellTag:(int)cellTag;
@optional
- (void)didCellSliderValueChanged:(UISlider *)sender withTitleLabel:(NSString *)title andValue:(int)sliderValue;
@end