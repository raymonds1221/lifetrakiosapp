//
//  SFALightAlertPickerCell.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/1/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFALightAlertPickerCell.h"
#import "JDADatePicker.h"
#import "JDAPickerView.h"
#import "JDAKeyboardAccessory.h"
#import "TimeDate+Data.h"

@interface SFALightAlertPickerCell ()<UITextFieldDelegate, JDAPickerViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) JDADatePicker *datePicker;
@property (strong, nonatomic) JDAPickerView *stringPicker;
@property (strong, nonatomic) UIPickerView *durationPicker;

@property (assign, nonatomic) NSInteger maxHour;


@property (assign, nonatomic) BOOL initial;

@end

@implementation SFALightAlertPickerCell

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

    self.initial = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - property
//must be set last, initialization method
- (void)setCellType:(SFALightPickerCellType)cellType
{
    _cellType = cellType;
    
    JDAKeyboardAccessory *accessory = [[JDAKeyboardAccessory alloc] initWithDoneAccessoryWithBarStyle:UIBarStyleDefault];
    accessory.currentView = self.pickerText;
    self.pickerText.inputAccessoryView = accessory;
    self.pickerText.delegate = self;
    
    switch (cellType) {
        case SFALightPickerCellTypeTime:{
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            dateComponents.hour = _hour;
            dateComponents.minute = _minute;
            self.pickerText.text = [self formatTimeWithHour:_hour minute:_minute];
            self.datePicker = [self datePickerWithHourFormat:[TimeDate getData].hourFormat date:[calendar dateFromComponents:dateComponents]];
            
            self.pickerText.inputView = self.datePicker;
            
            break;
        }case SFALightPickerCellTypeString:{
            self.pickerText.inputView = [self stringPickerWithArray:self.stringValuesArray];
            break;
        }case SFALightPickerCellTypeDuration:{
            self.pickerText.inputView = [self durationPickerWithMaxMinutes:self.maxMinutesDuration];
            [self.durationPicker selectRow:self.durationValue/60 inComponent:0 animated:YES];
            [self.durationPicker selectRow:self.durationValue%60 inComponent:1 animated:YES];
            break;
        }
    }
    
}

- (void)setStringValue:(NSString *)value
{
    _stringValue = value;
    self.pickerText.text = _stringValue;
}

- (void)setDurationValue:(NSInteger)durationValue
{
    _durationValue = durationValue;
    NSInteger hour = _durationValue/60;
    NSInteger minute = _durationValue%60;
    self.pickerText.text = [NSString stringWithFormat:@"%i h %i m",hour, minute];
}

- (NSInteger)hour
{
    return self.datePicker.hourValue;

}

- (NSInteger)minute
{
    return self.datePicker.minuteValue;
}

#pragma mark - private methods

- (JDADatePicker *)datePickerWithHourFormat:(HourFormat)hourFormat date:(NSDate *)date
{
    self.datePicker = [[JDADatePicker alloc] initWithTextField:self.pickerText date:date];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    self.datePicker.dateFormat = hourFormat == _24_HOUR ? @"HH:mm" : @"hh:mm a";
    self.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:hourFormat == _24_HOUR ? @"en_GB" : @"en_US_POSIX"];
    return self.datePicker;
}

- (UIPickerView *)stringPickerWithArray:(NSArray *)stringsArray
{
    self.stringPicker = [[JDAPickerView alloc] initWithArray:@[LS_LOW, LS_MEDIUM, LS_HIGH]
                                                    delegate:self];
    self.stringPicker.selectedIndex = [@[LS_LOW, LS_MEDIUM, LS_HIGH] indexOfObject:self.stringValue];
    return self.stringPicker;
}

- (UIPickerView *)durationPickerWithMaxMinutes:(NSInteger)max
{
    self.durationPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 100, 320, 200)];
    self.durationPicker.dataSource = self;
    self.durationPicker.delegate = self;
    
    UILabel *hourLabel;
    UILabel *minsLabel;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(270, self.durationPicker.frame.size.height / 2 - 15, 75, 30)];
        hourLabel.text = @"  h";
        
        minsLabel = [[UILabel alloc] initWithFrame:CGRectMake(380 + (self.durationPicker.frame.size.width / 2), self.durationPicker.frame.size.height / 2 - 15, 75, 30)];
        minsLabel.text = @"  m";
    
    }
    else{
        
        hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, self.durationPicker.frame.size.height / 2 - 15, 75, 30)];
        hourLabel.text = @"  h";
        
        minsLabel = [[UILabel alloc] initWithFrame:CGRectMake(40 + (self.durationPicker.frame.size.width / 2), self.durationPicker.frame.size.height / 2 - 15, 75, 30)];
        minsLabel.text = @"  m";
        
    }
    [self.durationPicker addSubview:hourLabel];
    [self.durationPicker addSubview:minsLabel];
    
    self.maxHour = max/60;
    
    return self.durationPicker;
}


- (NSString *)formatTimeWithHour:(NSInteger)hour minute:(NSInteger)minute
{
    HourFormat hourFormat = [TimeDate getData].hourFormat;
    
    NSString *timeAMPM = @"";
    
    if (hourFormat == _12_HOUR) {
        timeAMPM = hour < 12 ? LS_AM : LS_PM;
        hour = hour > 12 ? hour - 12 : hour;
        hour = hour == 0 ? 12 : hour;
    }
    
    NSString *minuteString = [NSString stringWithFormat:@"%@%i", minute < 10 ? @"0" : @"", minute];
    NSString *time = [NSString stringWithFormat:@"%i:%@ %@", hour, minuteString, timeAMPM];
    
    return time;
}

#pragma mark - JDAPickerViewDelegate - string picker only

- (void)pickerViewDidSelectIndex:(NSInteger)selectedIndex
{
    self.stringValue = self.stringPicker.selectedValue;
    if ([self.stringDelegate conformsToProtocol:@protocol(SFAStringLightAlertPickerCellDelegate)] &&
        [self.stringDelegate respondsToSelector:@selector(lightAlertPickerCell:stringValueChangedTo:)]){
        [self.stringDelegate lightAlertPickerCell:self stringValueChangedTo:self.stringValue];
    }
}

#pragma mark - pickerview delegate (duration picker only)
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%i",row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *columnView = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 320/2 - 35, 30)];
    columnView.text = [NSString stringWithFormat:@"%lu", (long)row];
    columnView.font = [UIFont systemFontOfSize:24.0f];
    if (component == 0){
        columnView.textAlignment = NSTextAlignmentRight;
    }else{
        columnView.textAlignment = NSTextAlignmentLeft;
    }
    
    return columnView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger hourInMinutes = [pickerView selectedRowInComponent:0] * 60;
    NSInteger minutes = [pickerView selectedRowInComponent:1];
    
    NSInteger total = hourInMinutes + minutes;
    if (total > self.maxMinutesDuration){
        NSInteger remainingMinutes = self.maxMinutesDuration - self.maxHour*60;
        [pickerView selectRow:self.maxHour inComponent:0 animated:YES];
        [pickerView selectRow:remainingMinutes inComponent:1 animated:YES];
        
        self.durationValue = self.maxMinutesDuration;
        return;
    }else if (total < self.minMinutesDuration){
        [pickerView selectRow:0 inComponent:0 animated:YES];
        [pickerView selectRow:self.minMinutesDuration inComponent:1 animated:YES];
        self.durationValue = self.minMinutesDuration;
        return;
    }
    //since value is nsstring, convert to nsstring
    self.durationValue = total;
}

#pragma mark - pickerview data source (duration picker only)

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0){
        return self.maxHour+1;
    }else{
        return 60;
    }
}


@end
