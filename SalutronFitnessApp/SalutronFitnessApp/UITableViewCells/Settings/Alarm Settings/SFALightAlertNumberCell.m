//
//  SFALightAlertNumberCell.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/1/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFALightAlertNumberCell.h"

@interface SFALightAlertNumberCell ()<UITextFieldDelegate>

@property (strong, nonatomic) UIToolbar *numPadToolbar;

@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxLabel;

@property (strong, nonatomic) NSString *originalUnit;

@end

@implementation SFALightAlertNumberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.numPadToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    self.numPadToolbar.barStyle = UIBarStyleBlackOpaque;
    self.numPadToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithTitle:BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)], nil];
    
    self.numberText.delegate = self;
    self.numberText.keyboardType = UIKeyboardTypeDecimalPad;
    self.numberText.inputAccessoryView = self.numPadToolbar;
    
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - properties

- (void)setMax:(NSInteger)max
{
    _max = max;
    self.slider.maximumValue = max;
    self.maxLabel.text = [NSString stringWithFormat:@"%i",max];
}

- (void)setMin:(NSInteger)min
{
    _min = min;
    self.slider.minimumValue = min;
    self.minLabel.text = [NSString stringWithFormat:@"%i",min];
}

- (void)setValue:(NSInteger)value
{
    _value = value;
    
    self.unit = value == 1 ? self.originalUnit : [self.originalUnit stringByAppendingString:(LANGUAGE_IS_FRENCH ? @"" : @"s")];
    self.numberText.text = [NSString stringWithFormat:@"%i",value];
    
    [self.slider setValue:value animated:NO];

}

- (void)setUnit:(NSString *)unit
{
    _unit = unit;
    if (!self.originalUnit){
        self.originalUnit = unit;
    }
    if ([self.originalUnit isEqualToString:@""]){
        self.unitLabel.text = @"";
    }else{
        self.unitLabel.text = unit;
    }

}

#pragma mark - ibaction

- (void)doneWithNumberPad
{
    [self.numberText resignFirstResponder];
    self.value = [self.numberText.text intValue];
    if (self.value > self.max){
        self.value = self.max;
        self.numberText.text = [NSString stringWithFormat:@"%i",self.value];
    }
    
    if (self.value < self.min){
        self.value = self.min;
        self.numberText.text = [NSString stringWithFormat:@"%i",self.value];
    }
    
    self.slider.value = self.value;
}

- (void)sliderValueChanged:(UISlider *)slider
{
    [self.numberText resignFirstResponder];
    self.value = self.slider.value;
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.numberText resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.numberText.text = @"";
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField.text length] > 2 && ![string isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

@end
