//
//  SFAProfileCell.m
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/10/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAProfileCell.h"
#import "SFAYourProfileViewController.h"

#import "JDADatePicker.h"
#import "JDAKeyboardAccessory.h"
#import "JDAPickerView.h"

#import "SalutronUserProfile.h"
#import "SalutronUserProfile+Data.h"
#import "DeviceEntity+Data.h"
#import "UserProfileEntity+Data.h"
#import "SFAHealthKitManager.h"

#import "TimeDate+Data.h" 

@interface SFAProfileCell () <UIPickerViewDataSource, UIPickerViewDelegate  >

@property (strong, nonatomic) NSString *oldValue;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) JDADatePicker *jdaDatePicker;

- (void)_textFieldReturned:(id)sender;
- (void)_textFieldStartEditing:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *labelRightDetail;

@end

@implementation SFAProfileCell

#pragma mark - Public instance methods

- (void)setContentsWithProfileType:(ProfileType)profileType
{
    switch (profileType)
    {
        case ProfileTypeWeight:
            [self setWeightContent];
            break;
        case ProfileTypeHeight:
            [self setHeightContent];
            break;
        case ProfileTypeBirth:
            [self setBirthDateContent];
            break;
        default:
            break;
    }
}

- (void)setWeightContent
{
    // Set title
    self.labelTitle.text = LS_WEIGHT;
    
    // Get user preferences
    //SalutronUserProfile *userProfile = [SalutronUserProfile getData];
    
    // Set values according to user preference
    NSInteger weight            = self.salutronUserProfile.unit == IMPERIAL ? self.salutronUserProfile.weight : round(self.salutronUserProfile.weight / 2.20462);
    self.labelRightDetail.text  = self.salutronUserProfile.unit == IMPERIAL ? @" lbs" : @" kg";
    
    //Set textfield keyboard accessory
    JDAKeyboardAccessory *_keyboardAccessory    = [[JDAKeyboardAccessory alloc] initWithDoneAccessoryWithBarStyle:UIBarStyleDefault];
    _keyboardAccessory.currentView              = self.textField;
    self.textField.inputAccessoryView           = _keyboardAccessory;
    self.textField.tag                          = ProfileTypeWeight;
    
    _oldValue                                   = [[NSNumber numberWithInteger:weight] stringValue];
    self.textField.text                         = _oldValue;
    
    //Set text field events
    [self.textField addTarget:self action:@selector(_textFieldStartEditing:) forControlEvents:UIControlEventEditingDidBegin];
    [self.textField addTarget:self action:@selector(_textFieldReturned:) forControlEvents:UIControlEventEditingDidEnd];
}

- (void)setHeightContent
{
    // Set title
    self.labelTitle.text = LS_HEIGHT;
    
    // Get user preferences
    //SalutronUserProfile *userProfile = [SalutronUserProfile getData];
    
    // Set values according to user preferences
    self.labelRightDetail.text  = self.salutronUserProfile.unit == IMPERIAL ? @"" : @" cm";
    if (self.salutronUserProfile.unit == IMPERIAL) {
       /*
        NSInteger inch  = ceil(userProfile.height / 2.54);
        NSInteger feet  = inch / 12;
        inch            -= feet * 12;
        feet            = feet == 0 ? 3 : feet;
        */
        NSInteger feet = (int)(self.salutronUserProfile.height / 30.48);
        NSInteger inch = lround((self.salutronUserProfile.height - (feet*30.48))/2.54);
        if (inch > 11) {
            inch = 0;
            feet++;
        }
        
        if (feet == 7) {
            inch                = 0;
            self.salutronUserProfile.height  = 213;
            //[self.delegate profileDataChangedWithSalutronUserProfile:self.salutronUserProfile];
        }
        
        _oldValue       = [NSString stringWithFormat:@"%i' %i\"", feet, inch];
        
        // Select current value in picker view
        if (feet < 3) {
            feet = 3;
            inch = 4;
        }
        [self.pickerView selectRow:feet - 3 inComponent:0 animated:NO];
        [self.pickerView selectRow:inch inComponent:1 animated:NO];
    } else {
        NSInteger height = self.salutronUserProfile.unit == IMPERIAL ?  : self.salutronUserProfile.height;
        _oldValue = [NSString stringWithFormat:@"%i", height];
    }
    
    //Set user profile
    //SalutronUserProfile *_userProfile           = [SalutronUserProfile getData];
    self.textField.tag                          = ProfileTypeHeight;
    
    // Set textfield keyboard input view
    if (self.salutronUserProfile.unit == IMPERIAL) {
        self.textField.inputView = self.pickerView;
    } else {
        self.textField.inputView = nil;
    }
    
    //Set textfield keyboard accessory
    JDAKeyboardAccessory *_keyboardAccessory    = [[JDAKeyboardAccessory alloc] initWithDoneAccessoryWithBarStyle:UIBarStyleDefault];
    _keyboardAccessory.currentView              = self.textField;
    self.textField.inputAccessoryView           = _keyboardAccessory;
    
    //Set text field weight data
    
    self.textField.text                         = _oldValue;
    
    //Set text field events
    [self.textField addTarget:self action:@selector(_textFieldStartEditing:) forControlEvents:UIControlEventEditingDidBegin];
    [self.textField addTarget:self action:@selector(_textFieldReturned:) forControlEvents:UIControlEventEditingDidEnd];
    
    
}

- (void)setBirthDateContent
{
    self.labelRightDetail.text = @"";
    
    //get birthdate
    //SalutronUserProfile *_userProfile           = [SalutronUserProfile getData];
    TimeDate *_timeDate                         = [TimeDate getData];
    SH_Date *_birthday                          = self.salutronUserProfile.birthday;
    NSString *_birthDateString;
    NSDate *_birthDate;
    if (_timeDate.dateFormat == 0) {
        _birthDateString = [NSString stringWithFormat:@"%i-%i-%i",
                            _birthday.day, _birthday.month, _birthday.year + DATE_YEAR_ADDER];
        _birthDate = ([_birthDateString isEqualToString:@"0-0-1900"] || [_birthDateString isEqualToString:@"0-0-0"]) ? [NSDate date] : [_birthDateString getDateFromStringWithFormat:@ "dd-MM-yyyy"];
        _jdaDatePicker                              = [[JDADatePicker alloc] initWithTextField:self.textField date:_birthDate];
        _jdaDatePicker.dateFormat                   = @"dd MMM, yyyy";
        _oldValue                                   = [_birthDate getDateStringWithFormat:@"dd MMM, yyyy"];
    }
    else {
        _birthDateString = [NSString stringWithFormat:@"%i-%i-%i",
                                                   _birthday.month, _birthday.day, _birthday.year + DATE_YEAR_ADDER];
        _birthDate = ([_birthDateString isEqualToString:@"0-0-1900"] || [_birthDateString isEqualToString:@"0-0-0"]) ? [NSDate date] : [_birthDateString getDateFromStringWithFormat:@ "MM-dd-yyyy"];
        _jdaDatePicker                              = [[JDADatePicker alloc] initWithTextField:self.textField date:_birthDate];
        _jdaDatePicker.dateFormat                   = @"MMM dd, yyyy";
        _oldValue                                   = [_birthDate getDateStringWithFormat:@"MMM dd, yyyy"];
    }
    
    self.textField.tag                          = ProfileTypeBirth;
    
    // set date picker maximum date
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.month = 1;
    dateComponents.day = 1;
    dateComponents.year = 1900;
    _jdaDatePicker.minimumDate  = [calendar dateFromComponents:dateComponents];
    dateComponents.month = 12;
    dateComponents.day = 31;
    dateComponents.year = 2013;
    _jdaDatePicker.maximumDate  = [calendar dateFromComponents:dateComponents];
    
    //set date picker
    self.textField.inputView                    = _jdaDatePicker;
    
    //set keyboard accessory
    JDAKeyboardAccessory *_keyboardAccessory    = [[JDAKeyboardAccessory alloc] initWithDoneAccessoryWithBarStyle:UIBarStyleDefault];
    _keyboardAccessory.currentView              = self.textField;
    self.textField.inputAccessoryView           = _keyboardAccessory;
    
    //set content with birhtdate
    self.labelTitle.text                        = LS_BIRTHDAY;
    self.textField.text                         = _oldValue;
    
    //Set text field events
    [self.textField addTarget:self action:@selector(_textFieldReturned:) forControlEvents:UIControlEventEditingDidEnd];
}

#pragma mark - Private actions
- (void)_textFieldStartEditing:(id)sender
{
    self.textField.text = @"";
    self.textField.placeholder = _oldValue;
}

- (void)_textFieldReturned:(id)sender
{
    //SalutronUserProfile *_userProfile   = [SalutronUserProfile getData];
    TimeDate *_timeDate                 = [TimeDate getData];
    NSDate *_date;
    
    switch (self.textField.tag) {
        case ProfileTypeWeight:
            self.textField.text = ([self.textField.text isEmpty]) ? _oldValue : self.textField.text;
            _oldValue           = self.textField.text;
            
            // Convert weight to lbs
            NSInteger weight = self.salutronUserProfile.unit == IMPERIAL ? _oldValue.floatValue : _oldValue.floatValue * 2.20462;
            
            // Validate weight if in range
            if (weight < PROFILE_MIN_WEIGHT) {
                weight = PROFILE_MIN_WEIGHT;
            } else if (weight > PROFILE_MAX_WEIGHT) {
                weight = PROFILE_MAX_WEIGHT;
            }
            
            // Save weight to user profile
            self.salutronUserProfile.weight = weight;
            
            // Convert weight back to user preferred unit
            weight = self.salutronUserProfile.unit == IMPERIAL ? weight : ceil(weight / 2.20462);
        
            // Convert weight to string
            _oldValue = [NSString stringWithFormat:@"%i", weight];
            self.textField.text = _oldValue;
            
            break;
        case ProfileTypeHeight:
            
            if (self.salutronUserProfile.unit == IMPERIAL) {
                NSInteger feet      = [self.pickerView selectedRowInComponent:0] + 3;
                NSInteger inch      = [self.pickerView selectedRowInComponent:1];
                
                // Validation
                if (feet <= 3 && inch < 4) {
                    feet = 3;
                    inch = 4;
                } else if (feet >= 7 && inch > 0) {
                    feet = 7;
                    inch = 0;
                }
                
                // Save height to user profile
                NSInteger height    = lround((feet * 30.48) + (inch * 2.54));//(inch + (feet * 12)) * 2.54;
                self.salutronUserProfile.height = height;
                
                // Convert height to string
                _oldValue = [NSString stringWithFormat:@"%i' %i\"", feet, inch];
                self.textField.text = _oldValue;
            } else {
                self.textField.text = ([self.textField.text isEmpty]) ? _oldValue : self.textField.text;
                _oldValue           = self.textField.text;
                
                // Convert height to cm
                NSInteger height = _oldValue.floatValue;
                
                // Validate height if in range
                if (height < PROFILE_MIN_HEIGHT) {
                    height = PROFILE_MIN_HEIGHT;
                } else if (height > PROFILE_MAX_HEIGHT) {
                    height = PROFILE_MAX_HEIGHT;
                }
                
                // Save height to user profile
                self.salutronUserProfile.height = height;
                
                // Convert height to string
                _oldValue = [NSString stringWithFormat:@"%i", height];
                self.textField.text = _oldValue;
            }
            
            break;
        case ProfileTypeBirth:
            if (_timeDate.dateFormat == 0) {
                _date                           = [self.textField.text getDateFromStringWithFormat:@"dd MMM, yyyy"];
            }
            else {
                _date                           = [self.textField.text getDateFromStringWithFormat:@"MMM dd, yyyy"];
                
            }
            if ([_date timeIntervalSinceNow] > 1)
            {
                //avoid choosing date later than current date
                _jdaDatePicker.date = [NSDate date];
                [[[UIAlertView alloc] initWithTitle:LS_INVALID_BIRTHDAY
                                            message:LS_INVALID_BIRTHDAY_MESSAGE
                                           delegate:self cancelButtonTitle:BUTTON_TITLE_OK_NORMAL otherButtonTitles:nil, nil] show];
                return;
            }
            
            self.salutronUserProfile.birthday.day       = [[_date getDateStringWithFormat:@"dd"] integerValue];
            self.salutronUserProfile.birthday.month     = [[_date getDateStringWithFormat:@"MM"] integerValue];
            self.salutronUserProfile.birthday.year      = [[_date getDateStringWithFormat:@"yyyy"] integerValue] - DATE_YEAR_ADDER;
            break;
        default:
            break;
    }
    [self.delegate profileDataChangedWithSalutronUserProfile:self.salutronUserProfile];
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == self.pickerView) {
        return 2;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.pickerView) {
        if (component == 0) {
            return 5;
        } else if (component == 1) {
            return 12;
        }
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.pickerView) {
        if (component == 0) {
            return [NSString stringWithFormat:@"%i'", row + 3];
        } else {
            return [NSString stringWithFormat:@"%i\"", row];
        }
    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.pickerView) {
        // Check if current value is less than minimum value
        // or greater than maximum value
        
        NSInteger feet = [pickerView selectedRowInComponent:0] + 3;
        NSInteger inch = [pickerView selectedRowInComponent:1];
        
        if (feet == 3) {
            if (inch < 4) {
                [pickerView selectRow:4 inComponent:1 animated:YES];
            }
        } else if (feet == 7) {
            if (inch > 0) {
                [pickerView selectRow:0 inComponent:1 animated:YES];
            }
        }
    }
}

#pragma mark - Getters

- (UIPickerView *)pickerView
{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.delegate = self;
    }
    
    return _pickerView;
}


- (void)saveHeightAndWeightToHealthStore{
    DDLogInfo(@"");
    if([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
       // [[SFAHealthKitManager sharedManager] requestAuthorizationWithSuccess:^(BOOL success) {
       //     if (success) {
                SalutronUserProfile *userProfile = [SalutronUserProfile userProfile];
                [[SFAHealthKitManager sharedManager] saveHeight:(double)(userProfile.height/100.0)];
                [[SFAHealthKitManager sharedManager] saveWeight:round(userProfile.weight / 2.20462)];
      //      }
      //  } failure:^(NSError *error) {
            
      //  }];
    }
}

@end
