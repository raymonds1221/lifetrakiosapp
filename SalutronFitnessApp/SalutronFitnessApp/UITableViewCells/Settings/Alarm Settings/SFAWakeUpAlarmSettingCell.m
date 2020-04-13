//
//  SFAWakeUpAlarmSettingCell.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 2/6/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAWakeUpAlarmSettingCell.h"
#import "JDADatePicker.h"
#import "JDAKeyboardAccessory.h"
#import "TimeDate+Data.h"

@interface SFAWakeUpAlarmSettingCell() <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISwitch       *snoozeSwitch;
@property (weak, nonatomic) IBOutlet UIStepper      *windowStepper;
@property (weak, nonatomic) IBOutlet UITextField    *windowTextField;
@property (weak, nonatomic) IBOutlet UIStepper      *snoozeTimeStepper;
@property (weak, nonatomic) IBOutlet UITextField    *snoozeTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField    *numberText;

@property (strong, nonatomic) TimeDate              *timeDate;
@property (strong, nonatomic) JDADatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *numPadToolbar;
@property (nonatomic) NSInteger windowValue;

@end

@implementation SFAWakeUpAlarmSettingCell

-(void)awakeFromNib
{
    self.numPadToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    self.numPadToolbar.barStyle = UIBarStyleBlackOpaque;
    self.numPadToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithTitle:BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)], nil];
    
    self.numberText.delegate = self;
    self.numberText.keyboardType = UIKeyboardTypeDecimalPad;
    self.numberText.inputAccessoryView = self.numPadToolbar;
    
    self.windowTextField.text = @"minute";
    self.windowTextField.delegate = self;
//    if(self.wakeupTimeTextField) {
//        self.datePicker = [[JDADatePicker alloc] initWithTextField:self.wakeupTimeTextField];
//        self.datePicker.datePickerMode = UIDatePickerModeTime;
//        self.datePicker.dateFormat = @"HH:mm";
//        JDAKeyboardAccessory *accessory = [[JDAKeyboardAccessory alloc] initWithDoneAccessoryWithBarStyle:UIBarStyleDefault];
//        accessory.currentView = self.wakeupTimeTextField;
//        self.wakeupTimeTextField.inputAccessoryView = accessory;
//        self.wakeupTimeTextField.inputView = self.datePicker;
//        self.wakeupTimeTextField.delegate = self;
//    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - Public Methods

- (void)setWindowTimeValue:(NSInteger)windowTimeValue
{
    _windowTimeValue = windowTimeValue;
    self.numberText.text = [NSString stringWithFormat:@"%i", windowTimeValue];
    self.windowTextField.text = [NSString stringWithFormat:@"%@ %@", windowTimeValue > 1 ? @"minutes": @"minute", LS_EARLIER];
}

- (void)setSnoozeTimeValue:(NSInteger)snoozeTimeValue
{
    _snoozeTimeValue = snoozeTimeValue;
    self.snoozeTimeTextField.text = [NSString stringWithFormat:@"%i %@", snoozeTimeValue, snoozeTimeValue > 1 ? @"minutes": @"minute"];
}

- (void)setAlarmStatusSwitch:(BOOL)isOn
{
    if(self.wakeupAlertSwitch)
        self.wakeupAlertSwitch.on = isOn;
}

- (void)setSnoozeStatusSwitch:(BOOL)isOn
{
    if(self.snoozeSwitch)
        self.snoozeSwitch.on = isOn;
}

- (void)setWakeupTimeValue:(NSString *)value
{
    if(self.wakeupTimeTextField) {
        
        SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
        
        self.wakeupTimeTextField.text = value;
        NSDate *date = [self pickerDateWithFormat:userDefaultsManager.timeDate.hourFormat];
    
        self.datePicker = [self datePickerWithHourFormat:userDefaultsManager.timeDate.hourFormat date:date];
        
        JDAKeyboardAccessory *accessory = [[JDAKeyboardAccessory alloc] initWithDoneAccessoryWithBarStyle:UIBarStyleDefault];
        accessory.currentView = self.wakeupTimeTextField;
        
        self.wakeupTimeTextField.inputAccessoryView = accessory;
        self.wakeupTimeTextField.inputView = self.datePicker;
        self.wakeupTimeTextField.delegate = self;
    }
}

- (NSDate *)pickerDateWithFormat:(HourFormat)hourFormat
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.timeZone = [NSTimeZone localTimeZone];
    dateFormat.dateFormat = hourFormat == _24_HOUR ? @"HH:mm" : @"hh:mm a";
    dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:hourFormat == _24_HOUR ? @"en_GB" : @"en_US_POSIX"];
    return [dateFormat dateFromString:self.wakeupTimeTextField.text];
}

- (JDADatePicker *)datePickerWithHourFormat:(HourFormat)hourFormat date:(NSDate *)date
{
    self.datePicker = [[JDADatePicker alloc] initWithTextField:self.wakeupTimeTextField date:date];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    self.datePicker.dateFormat = hourFormat == _24_HOUR ? @"HH:mm" : @"hh:mm a";
    self.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:hourFormat == _24_HOUR ? @"en_GB" : @"en_US_POSIX"];
    return self.datePicker;
}

- (void)setWindowTimeStepperValue:(NSInteger)value
{
    if(self.windowStepper)
        self.windowStepper.value = value;
}

- (void)setWindowTimeTextValue:(NSString *)value
{
    if(self.windowTextField){
        self.windowTextField.text = value;
    }
}

- (void)setSnoozeTimeStepperValue:(NSInteger)value
{
    if(self.snoozeTimeStepper)
        self.snoozeTimeStepper.value = value;
}

- (void)setSnoozeTimeTextValue:(NSString *)value
{
    if(self.snoozeTimeTextField)
        self.snoozeTimeTextField.text = value;
}

#pragma mark - IBActions

- (IBAction)didSwitchValueChanged:(id)sender
{
    if(sender == self.wakeupAlertSwitch) {
        if([self.delegate conformsToProtocol:@protocol(SFAWakeUpAlarmSettingCellDelegate)] &&
           [self.delegate respondsToSelector:@selector(alarmSetting:didChangeStatusValue:)]) {
            [self.delegate alarmSetting:AlarmSettingAlarmStatus didChangeStatusValue:[sender isOn]];
        }
    } else if(sender == self.snoozeSwitch) {
        if([self.delegate conformsToProtocol:@protocol(SFAWakeUpAlarmSettingCellDelegate)] &&
           [self.delegate respondsToSelector:@selector(alarmSetting:didChangeStatusValue:)]) {
            [self.delegate alarmSetting:AlarmSettingSnoozeStatus didChangeStatusValue:[sender isOn]];
        }
    }
}

- (IBAction)didStepperValueChanged:(id)sender
{
    if(sender == self.windowStepper) {
        if([self.delegate conformsToProtocol:@protocol(SFAWakeUpAlarmSettingCellDelegate)] &&
           [self.delegate respondsToSelector:@selector(alarmSetting:didStepperValueChanged:)]) {
            [self.delegate alarmSetting:AlarmSettingWindow didStepperValueChanged:sender];
            self.windowTimeValue = self.windowStepper.value;
        }
    } else if(sender == self.snoozeTimeStepper) {
        if([self.delegate conformsToProtocol:@protocol(SFAWakeUpAlarmSettingCellDelegate)] &&
           [self.delegate respondsToSelector:@selector(alarmSetting:didStepperValueChanged:)]) {
            [self.delegate alarmSetting:AlarmSettingSnoozeTime didStepperValueChanged:sender];
            self.snoozeTimeValue = self.snoozeTimeStepper.value;
        }
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.wakeupTimeTextField) {
        if([self.delegate conformsToProtocol:@protocol(SFAWakeUpAlarmSettingCellDelegate)] &&
           [self.delegate respondsToSelector:@selector(alarmsetting:didWakeupTimeChangedWithHour:minute:)]) {
            
            [self.delegate alarmsetting:AlarmSettingWakeupTime didWakeupTimeChangedWithHour:self.datePicker.hourValue minute:self.datePicker.minuteValue];
        }
    }
}

/*
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
*/
#pragma mark - ibaction

- (void)doneWithNumberPad
{
    [self.numberText resignFirstResponder];
    self.windowValue = [self.numberText.text intValue];
    if (self.windowValue > 59){
        self.windowValue = 59;
        self.numberText.text = [NSString stringWithFormat:@"%i",self.windowValue];
    }
    
    if (self.windowValue < 0){
        self.windowValue = 0;
        self.numberText.text = [NSString stringWithFormat:@"%i",self.windowValue];
    }
    if ([self.numberText.text length] == 0) {
        self.numberText.text = [NSString stringWithFormat:@"%i",self.windowValue];
    }
    
    if([self.delegate conformsToProtocol:@protocol(SFAWakeUpAlarmSettingCellDelegate)] &&
       [self.delegate respondsToSelector:@selector(alarmSetting:didStepperValueChanged:)]) {
        [self.delegate alarmSetting:AlarmSettingWindow didStepperValueChanged:self.numberText];
        self.windowTimeValue = self.numberText.text.integerValue;
    }
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
    if ([textField.text length] > 1 && ![string isEqualToString:@""]) {
        return NO;
    }
    return YES;
}


@end
