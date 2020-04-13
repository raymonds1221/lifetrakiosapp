//
//  SFASettingsCellWithButton.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 5/4/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFASettingsCellWithButton.h"

#import "DeviceEntity+Data.h"
#import "DeviceEntity+WatchName.h"

@implementation SFASettingsCellWithButton

- (void)awakeFromNib {
    // Initialization code
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(doneEditing)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor = [UIColor blackColor];
    self.cellTextField.inputAccessoryView       = toolBar;
    self.cellTextField.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cellSliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    if ([self.delegate respondsToSelector:@selector(didCellSliderValueChanged:withTitleLabel:andValue:)]) {
        int sliderValue = slider.value;
        if (slider.value == 1 || slider.value == 999) {
            [self.delegate didCellSliderValueChanged:sender withTitleLabel:self.lableTitle.text andValue:slider.value];
        }
        else{
            //slider.value = slider.value*self.sliderMultipleIncrement;
            [self.delegate didCellSliderValueChanged:sender withTitleLabel:self.lableTitle.text andValue:slider.value - (int)slider.value%self.sliderMultipleIncrement];
            sliderValue = slider.value - (int)slider.value%self.sliderMultipleIncrement;
        }
        NSString *stepsString = [NSString stringWithFormat:@"%i %@", sliderValue, LS_STEPS];
        if (sliderValue == 1) {
            stepsString = [NSString stringWithFormat:@"%i %@", sliderValue, LS_STEP];
        }
        [self.cellButton setTitle:stepsString forState:UIControlStateNormal];

    }
}

- (IBAction)buttonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didButtonClicked:withLabelTitle:andCellTag:)]) {
        [self.delegate didButtonClicked:sender withLabelTitle:self.lableTitle.text andCellTag:self.tag];
    }
}

- (void)setDateFormat:(DateFormat)dateFormat{
    switch (dateFormat) {
        case 0:
            [self.cellButton setTitle:DATE_FORMAT_DDMMYY forState:UIControlStateNormal];
            break;
        case 1:
            [self.cellButton setTitle:DATE_FORMAT_MMDDYY forState:UIControlStateNormal];
            break;
        case 2:
            [self.cellButton setTitle:DATE_FORMAT_DDMMM forState:UIControlStateNormal];
            break;
        case 3:
            [self.cellButton setTitle:DATE_FORMAT_MMMDD forState:UIControlStateNormal];
            break;
        default:
            break;
    }

}


#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.previousTextFieldValue = textField.text;
    [self.delegate didTextFieldClicked:textField withLabelTitle:self.lableTitle.text andValue:textField.text andCellTag:self.tag];
    //textField.text = @"";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location == textField.text.length && [string isEqualToString:@" "]) {
        // ignore replacement string and add your own
        if (textField.text.length == 0) {
            textField.text = [textField.text stringByAppendingString:@""];
        }
        else{
            textField.text = [textField.text stringByAppendingString:@"\u00a0"];
        }
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSCharacterSet *whitespace      = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedString         = [textField.text stringByTrimmingCharactersInSet:whitespace];
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
    DeviceEntity *deviceEntity      = [DeviceEntity deviceEntityForMacAddress:macAddress];
    
    if (trimmedString.length == 0) {
        if (textField.text.length == 0) {
            textField.text = self.previousTextFieldValue;
        } else {
            textField.text = [deviceEntity defaultWatchName];
        }
    }
    [self.delegate didTextFieldEditDone:textField withLabelTitle:self.lableTitle.text andValue:textField.text andCellTag:self.tag];
}

- (void)doneEditing{
    [self.cellTextField resignFirstResponder];
}


@end
