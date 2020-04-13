//
//  SFAAddDetailsViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/3/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAAddDetailsViewController.h"
#import "Flurry.h"

#import "NSDate+Age.h"

#import "UIViewController+Helper.h"
#import "SFAAddDetailsTableViewCell.h"
#import "SFAProfileGenderCell.h"
#import "SFASmartCalibrationCellHeader.h"
#import "SFAInputCell.h"
#import "SFAButtonCell.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFAErrorMessageViewController.h"
#import "SFALoadingViewController.h"

#import "JDADatePicker.h"
#import "JDAKeyboardAccessory.h"

#import "SalutronUserProfile+Data.h"
#import "TimeDate+Data.h"
#import "DeviceEntity+Data.h"
#import "UserProfileEntity+Data.h"
#import "SFASalutronCModelSync.h"

@interface SFAAddDetailsViewController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SFAAddDetailsTableViewCellDelegate, SFAProfileGenderCellDelegate, SFASalutronSyncDelegate, SFAErrorMessageViewControllerDelegate>

//@property (strong, nonatomic) SFASalutronCModelSync     *salutronCModelSync;
@property (strong, nonatomic) NSManagedObjectContext    *managedObjectContext;
@property (strong, nonatomic) SalutronUserProfile       *oldUserProfile;
@property (strong, nonatomic) JDADatePicker             *jdaDatePicker;
@property (strong, nonatomic) NSString                  *oldWeightValue;
@property (strong, nonatomic) NSString                  *oldHeightValue;

- (void)_configureView;
- (void)_setGenderContent;

@property (strong, nonatomic) IBOutlet UITextField  *textFieldWeight;
@property (strong, nonatomic) IBOutlet UITextField  *textFieldHeight;
@property (strong, nonatomic) IBOutlet UITextField  *textFieldBirthday;
@property (strong, nonatomic) IBOutlet UIButton     *buttonMale;
@property (strong, nonatomic) IBOutlet UIButton     *buttonFemale;
@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet UILabel        *weightUnit;

@property (strong, nonatomic) NSTimer *timer;


@property (strong, nonatomic) SalutronUserProfile *salutronUserProfile;

@property (strong, nonatomic) UIPickerView *pickerView;

- (IBAction)buttonMaleTouchedUp:(id)sender;
- (IBAction)buttonFemaleTouchedUp:(id)sender;
- (IBAction)buttonSaveTouchedUp:(id)sender;
- (IBAction)buttonCancelTouchedUp:(id)sender;

@end

/*
 Step 4: Modify personal details and update it on the watch. If watch is no longer connected when continue was pressed, a dialog will show and user can continue to next step.
 */

@implementation SFAAddDetailsViewController


static NSString *_normalCellID  = @"ProfileCell";
static NSString *_genderCellID  = @"ProfileGenderCell";

/*
- (SFASalutronCModelSync *)salutronCModelSync
{
    if (!_salutronCModelSync) {
        _salutronCModelSync = [[SFASalutronCModelSync alloc] initWithManagedObjectContext:self.managedObjectContext];
        _salutronCModelSync.delegate = self;
    }
    return _salutronCModelSync;
}
*/
#pragma mark - View controller methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title                                  = ADD_DETAILS_TITLE;
    self.inputContainer                         = self.tableView;
    self.salutronUserProfile                    = [SalutronUserProfile getData];
    SFASalutronFitnessAppDelegate *appDelegate  = [UIApplication sharedApplication].delegate;
    self.managedObjectContext                   = appDelegate.managedObjectContext;
    
    DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    
    if ([deviceEntity.modelNumber isEqual:@(WatchModel_Zone_C410)] ||
        [deviceEntity.modelNumber isEqual:@(WatchModel_R420)] ||
        [deviceEntity.modelNumber isEqual:@(WatchModel_Move_C300)]) {
        [self makeConnectionAlive];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(makeConnectionAlive) userInfo:nil repeats:YES];
    }
    [self addKeyboardObserver];
    
    
}

- (void)makeConnectionAlive{
    DDLogInfo(@"");
    self.salutronCModelSync.delegate = nil;
    [self.salutronCModelSync.salutronSDK getCurrentTimeAndDate];
}

- (void)disconnect{
    DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    if ([deviceEntity.modelNumber isEqual:@(WatchModel_Zone_C410)] ||
        [deviceEntity.modelNumber isEqual:@(WatchModel_Move_C300)] ||
        [deviceEntity.modelNumber isEqual:@(WatchModel_R420)]) {
    self.salutronCModelSync.delegate = nil;
    [self.salutronCModelSync.salutronSDK disconnectDevice];
    [self.salutronCModelSync.salutronSDK commDone];
    [self.salutronCModelSync deleteDevice];
    }
    else{
    
    self.salutronRModelSync.delegate = nil;
    self.salutronRModelSync.initialSync = YES;
    self.salutronRModelSync.syncType = SyncTypeInitial;
    [self.salutronRModelSync.salutronSDK disconnectDevice];
    [self.salutronRModelSync deleteDevice];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    SFALoadingViewController *rootController=(SFALoadingViewController *)((SFASalutronFitnessAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    rootController.isSwitchWatch = YES;
    [rootController returnToRoot];
    
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    //[self disconnect];
    /*
    self.salutronCModelSync.delegate = nil;
    [self.salutronCModelSync.salutronSDK disconnectDevice];
    [self.salutronCModelSync.salutronSDK commDone];
    [self.salutronCModelSync deleteDevice];
     */
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) shouldAutorotate
{
    return NO;
}

- (void)addKeyboardObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - Keyboard observer handler

- (void)keyboardDidAppear:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    //    self.scrollView.contentInset = contentInsets;
    //    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGSize contentSize = self.scrollView.frame.size;
    contentSize.height += keyboardSize.height;
    self.scrollView.contentSize = contentSize;
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    self.scrollView.contentSize = self.scrollView.frame.size;
}

#pragma mark - Text field delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIView *_textFieldSuperView = [textField superview];
    
    //Set keyboard accessory
    JDAKeyboardAccessory *_keyboardAccessory    = [[JDAKeyboardAccessory alloc] initWithPrevNextDoneAccessoryWithBarStyle:UIBarStyleDefault];
    _keyboardAccessory.nextView                 = [_textFieldSuperView viewWithTag:textField.tag + 1];
    _keyboardAccessory.previousView             = [_textFieldSuperView viewWithTag:textField.tag - 1];
    _keyboardAccessory.currentView              = textField;
    textField.inputAccessoryView                = _keyboardAccessory;
    
    //clear text
    //textField.placeholder                       = textField.text;
    textField.text                              = @"";
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self _saveProfileWithTextField:textField];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIView *_textFieldSuperView = [textField superview];
    NSInteger _textFieldNextTag =  textField.tag + 1;
    UITextField *_viewNextTag   = (UITextField *)[_textFieldSuperView viewWithTag:_textFieldNextTag];
    
    if (_viewNextTag)
    {
        //Focus on next text field
        [_viewNextTag becomeFirstResponder];
    }
    else
    {
        //Dismiss keyboard and start register
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.textFieldWeight || textField == self.textFieldHeight) {
        if(textField.text.length >= 10 && range.length == 0) {
            return NO;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == ProfileTypeWeight) {
        /*
         // Convert weight to lbs
         NSInteger weight = textField.text.integerValue * 2.20462;
         */
        NSInteger weight = textField.text.integerValue;
        
        // Validate weight if in range
        if (weight < PROFILE_MIN_WEIGHT) {
            weight = PROFILE_MIN_WEIGHT;
        } else if (weight > PROFILE_MAX_WEIGHT) {
            weight = PROFILE_MAX_WEIGHT;
        }
        
        /*
         //Commented this because US uses lbs, making it the default
         // Convert weight back to user preferred unit
         weight = ceil(weight / 2.20462);
         */
        
        // Convert weight to string
        textField.text = [NSString stringWithFormat:@"%i", weight];
        
        SalutronUserProfile *userProfile = [SalutronUserProfile getData];
        userProfile.weight = weight;
        [SalutronUserProfile saveWithSalutronUserProfile:userProfile];
        DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
        [UserProfileEntity userProfileWithSalutronUserProfile:userProfile forDeviceEntity:deviceEntity];
        
        
    } else if (textField.tag == ProfileTypeHeight) {
        /*
         // Convert height to cm
         NSInteger height = textField.text.integerValue;
         
         // Validate height if in range
         if (height < PROFILE_MIN_HEIGHT) {
         height = PROFILE_MIN_HEIGHT;
         } else if (height > PROFILE_MAX_HEIGHT) {
         height = PROFILE_MAX_HEIGHT;
         }
         
         // Convert cm to inches, since US uses inches as default
         NSInteger feet = (int)(height / 30.48);
         NSInteger inch = lround((height - (feet*30.48))/2.54);
         if (inch > 11) {
         inch = 0;
         feet++;
         }
         
         if (feet == 7) {
         inch                = 0;
         height              = 213;
         }
         
         //_oldValue       = [NSString stringWithFormat:@"%i' %i\"", feet, inch];
         
         // Convert height to string
         //textField.text = [NSString stringWithFormat:@"%i", height];
         textField.text = [NSString stringWithFormat:@"%i' %i\"", feet, inch];
         */
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
        SalutronUserProfile *userProfile = [SalutronUserProfile getData];
        NSInteger height    = lround((feet * 30.48) + (inch * 2.54));//(inch + (feet * 12)) * 2.54;
        userProfile.height = height;
        
        [SalutronUserProfile saveWithSalutronUserProfile:userProfile];
        DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
        [UserProfileEntity userProfileWithSalutronUserProfile:userProfile forDeviceEntity:deviceEntity];
        
        // Convert height to string
        textField.text = [NSString stringWithFormat:@"%i' %i\"", feet, inch];
    }
    
    /*if(textField.tag == ProfileTypeWeight) {
     NSInteger maxValue = 440 / 2.2;
     
     if(textField.text.integerValue > maxValue) {
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"You entered an invalid value" delegate:nil cancelButtonTitle:BUTTON_TITLE_OK_NORMAL otherButtonTitles:nil, nil];
     [alertView show];
     SalutronUserProfile *userProfile = [SalutronUserProfile getData];
     self.textFieldWeight.text = [[NSNumber numberWithInteger:userProfile.weight / 2.2] stringValue];
     return;
     }
     }*/
}

#pragma mark - IBAction methods
- (IBAction)buttonMaleTouchedUp:(id)sender
{
    self.buttonMale.selected            = YES;
    self.buttonFemale.selected          = NO;
    SalutronUserProfile *_userProfile   = [SalutronUserProfile getData];
    _userProfile.gender                 = MALE;
    [SalutronUserProfile saveWithSalutronUserProfile:_userProfile];
    DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    [UserProfileEntity userProfileWithSalutronUserProfile:_userProfile forDeviceEntity:deviceEntity];
}

- (IBAction)buttonFemaleTouchedUp:(id)sender
{
    self.buttonMale.selected            = NO;
    self.buttonFemale.selected          = YES;
    SalutronUserProfile *_userProfile   = [SalutronUserProfile getData];
    _userProfile.gender                 = FEMALE;
    [SalutronUserProfile saveWithSalutronUserProfile:_userProfile];
    DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    [UserProfileEntity userProfileWithSalutronUserProfile:_userProfile forDeviceEntity:deviceEntity];
}

- (IBAction)buttonSaveTouchedUp:(id)sender
{
    [self disconnect];
    [self dismissViewControllerAnimated:YES completion:nil];
    /*
    if ([self.delegate conformsToProtocol:@protocol(SFAYourProfileViewControllerDelegate)] &&
        [self.delegate respondsToSelector:@selector(didPressSaveInYourProfileViewController:)]) {
        [self.delegate didPressSaveInYourProfileViewController:self];
    }
     */
}

- (IBAction)buttonCancelTouchedUp:(id)sender
{
    //revert original userprofile
    [SalutronUserProfile saveWithSalutronUserProfile:_oldUserProfile];
    DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    [UserProfileEntity userProfileWithSalutronUserProfile:_oldUserProfile forDeviceEntity:deviceEntity];
    [self disconnect];
    [self dismissViewControllerAnimated:YES completion:nil];
    /*
    if ([self.delegate conformsToProtocol:@protocol(SFAYourProfileViewControllerDelegate)] &&
        [self.delegate respondsToSelector:@selector(didPressCancelInYourProfileViewController:)]) {
        [self.delegate didPressCancelInYourProfileViewController:self];
    }
     */
}

#pragma mark - Private instance methods
- (void)_configureView
{
    _oldUserProfile                     = [SalutronUserProfile getData];
    SalutronUserProfile *_userProfile   = [SalutronUserProfile getData];
    
    //Set gender from user profile data
    [self _setGenderContent];
    
    //Set weight data
    NSInteger _userWeight       = _userProfile.weight;// / 2.2;
    
    NSString *_stringWeight     = [[NSNumber numberWithInteger:_userWeight] stringValue];
    _oldWeightValue             = _stringWeight;
    self.textFieldWeight.text   = _stringWeight;
    
    //Set height data
    NSString *_stringHeight     = [[NSNumber numberWithInteger:_userProfile.height] stringValue];
    _oldHeightValue             = _stringHeight;
    self.textFieldHeight.text   = _stringHeight;
    
    NSInteger feet = (int)(_userProfile.height / 30.48);
    NSInteger inch = lround((_userProfile.height - (feet*30.48))/2.54);
    if (inch > 11) {
        inch = 0;
        feet++;
    }
    
    if (feet == 7) {
        inch                = 0;
        _userProfile.height  = 213;
    }
    
    _oldHeightValue       = [NSString stringWithFormat:@"%i' %i\"", feet, inch];
    self.textFieldHeight.text   = _oldHeightValue;
    if (feet < 3) {
        feet = 3;
        inch = 4;
    }
    
    // Select current value in picker view
    [self.pickerView selectRow:feet - 3 inComponent:0 animated:NO];
    [self.pickerView selectRow:inch inComponent:1 animated:NO];
    
    self.textFieldHeight.inputView = self.pickerView;
    
    //Get birthday data
    SH_Date *_birthday          = _userProfile.birthday;
    NSString *_birthDateString  = [NSString stringWithFormat:@"%i-%i-%i",
                                   _birthday.month, _birthday.day, _birthday.year + DATE_YEAR_ADDER];
    NSDate *_convertedDate      = [_birthDateString getDateFromStringWithFormat:@ "MM-dd-yyyy"];
    NSDate *_birthDate          = ([_birthDateString isEqualToString:@"0-0-1900"] ||
                                   [_birthDateString isEqualToString:@"0-0-0"]) ? [NSDate date] : _convertedDate;
    
    // Set birthday date picker
    _jdaDatePicker                      = [[JDADatePicker alloc] initWithTextField:self.textFieldBirthday date:_birthDate];
    _jdaDatePicker.dateFormat           = @"MMM dd, yyyy";
    self.textFieldBirthday.inputView    = _jdaDatePicker;
    
    // Set date picker maximum date
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
    
    // Set birthday content
    self.textFieldBirthday.text = [_birthDate getDateStringWithFormat:@"MMM dd, yyyy"];
    self.textFieldBirthday.tag = ProfileTypeBirth;
    self.textFieldHeight.tag = ProfileTypeHeight;
    self.textFieldWeight.tag = ProfileTypeWeight;
}

- (void)_setGenderContent
{
    SalutronUserProfile *_userProfile   = [SalutronUserProfile getData];
    Gender _gender                      = _userProfile.gender;
    switch (_gender) {
        case MALE:
            [self buttonMaleTouchedUp:self];
            break;
        case FEMALE:
            [self buttonFemaleTouchedUp:self];
            break;
        default:
            break;
    }
}

- (void)_saveProfileWithTextField:(UITextField *)textField
{
    SalutronUserProfile *_userProfile   = [SalutronUserProfile getData];
    NSDate *_date;
    
    switch (textField.tag) {
        case ProfileTypeWeight:
            textField.text      = ([textField.text isEmpty]) ? _oldWeightValue : textField.text;
            _oldWeightValue     = [textField.text copy];
            textField.text      = (_oldWeightValue.integerValue < PROFILE_MIN_WEIGHT) ? [[NSNumber numberWithInt:PROFILE_MIN_WEIGHT] stringValue] : textField.text;
            textField.text      = (_oldWeightValue.integerValue > PROFILE_MAX_WEIGHT) ? [[NSNumber numberWithInt:PROFILE_MAX_WEIGHT] stringValue] : textField.text;
            _oldWeightValue     = textField.text;
            _userProfile.weight = ceil(textField.text.integerValue * 2.2);
            break;
        case ProfileTypeHeight:
            textField.text      = ([textField.text isEmpty]) ? _oldHeightValue : textField.text;
            _oldHeightValue     = [textField.text copy];
            textField.text      = (_oldHeightValue.integerValue < PROFILE_MIN_HEIGHT) ? [[NSNumber numberWithInt:PROFILE_MIN_HEIGHT] stringValue] : textField.text;
            textField.text      = (_oldHeightValue.integerValue > PROFILE_MAX_HEIGHT) ? [[NSNumber numberWithInt:PROFILE_MAX_HEIGHT] stringValue] : textField.text;
            _oldHeightValue     = textField.text;
            _userProfile.height = textField.text.integerValue;
            break;
        case ProfileTypeBirth:
            _date               = [textField.text getDateFromStringWithFormat:@"MMM dd, yyyy"];
            
            if ([_date timeIntervalSinceNow] > 1)
            {
                //avoid choosing date later than current date
                _jdaDatePicker.date = [NSDate date];
                if (self.isIOS8AndAbove) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS_INVALID_BIRTHDAY
                                                                                             message:LS_INVALID_BIRTHDAY_MESSAGE
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:BUTTON_TITLE_OK_NORMAL
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                               }];
                    
                    [alertController addAction:okAction];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                else{
                    [[[UIAlertView alloc] initWithTitle:LS_INVALID_BIRTHDAY
                                                message:LS_INVALID_BIRTHDAY_MESSAGE
                                               delegate:self cancelButtonTitle:BUTTON_TITLE_OK_NORMAL otherButtonTitles:nil, nil] show];
                }
                return;
            }
            
            _userProfile.birthday.day       = [[_date getDateStringWithFormat:@"dd"] integerValue];
            _userProfile.birthday.month     = [[_date getDateStringWithFormat:@"MM"] integerValue];
            _userProfile.birthday.year      = [[_date getDateStringWithFormat:@"yyyy"] integerValue] - DATE_YEAR_ADDER;
            break;
        default:
            break;
    }
    
    [Flurry setAge:_date.age];
    [Flurry setGender:_userProfile.gender == MALE ? @"m" : @"f"];
    [SalutronUserProfile saveWithSalutronUserProfile:_userProfile];
    DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    [UserProfileEntity userProfileWithSalutronUserProfile:_userProfile forDeviceEntity:deviceEntity];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return indexPath.row == 4 ? 96 : 68;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SFASmartCalibrationCellHeader *cell = [tableView dequeueReusableCellWithIdentifier:@"SFASmartCalibrationCellHeader"];
    cell.titleLabel.text        = ENTER_PERSONAL_DETAILS;
    cell.descriptionLabel.text  = PERSONAL_DETAILS_DESC;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 88;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //SFAInputCell *cell;
   /* if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SFASignupCell"];
        cell.inputTitle.text            = LS_WEIGHT;
        cell.inputTextField.placeholder = LS_WEIGHT_WITH_UNIT;
        self.textFieldWeight            = cell.inputTextField;
        self.textFieldWeight.delegate   = self;
    }
    else if (indexPath.row == 1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"SFASignupCell"];
        cell.inputTitle.text            = LS_HEIGHT;
        cell.inputTextField.placeholder = LS_HEIGHT_WITH_UNIT;
        self.textFieldHeight            = cell.inputTextField;
        self.textFieldHeight.delegate   = self;
    }
    else if (indexPath.row == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"SFASignupCell"];
        cell.inputTitle.text            = LS_BIRTHDAY;
        cell.inputTextField.placeholder = LS_BIRTHDAY_WITH_UNIT;
        self.textFieldBirthday          = cell.inputTextField;
        self.textFieldBirthday.delegate = self;
    }*/
    if (indexPath.row < 3) {
        SFAAddDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFAAddDetailsTableViewCell"];
        cell.salutronUserProfile = self.salutronUserProfile;
        [cell setContentsWithProfileType:indexPath.row+3];
        cell.delegate = self;
        cell.labelTitle.hidden = NO;
        return cell;

    }
    else if (indexPath.row == 3){
        SFAProfileGenderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFAProfileGenderCell"];
        cell.delegate = self;
        cell.salutronUserProfile = self.salutronUserProfile;
        cell.labelTitle.text = LS_GENDER;
        cell.femaleLabel.text = LS_FEMALE;
        cell.maleLabel.text = LS_MALE;
        [cell setGenderContent];
        return cell;
        /*
        SFAProfileGenderCell *genderCell = [tableView dequeueReusableCellWithIdentifier:@"SFAProfileGenderCell"];
        genderCell.femaleLabel.text = LS_FEMALE_CAP_FIRST;
        genderCell.maleLabel.text   = LS_MALE_CAP_FIRST;
        self.buttonMale             = genderCell.buttonMale;
        self.buttonFemale           = genderCell.buttonFemale;
        [self.buttonMale addTarget:self action:@selector(buttonMaleTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonFemale addTarget:self action:@selector(buttonFemaleTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
        return genderCell;
         */
    }
    else if (indexPath.row == 4){
        SFAButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContinueButtonCell"];
        [cell.button addTarget:self action:@selector(updateUserProfileDetails) forControlEvents:UIControlEventTouchUpInside];
        [cell.button setTitle:LS_CONTINUE_CAPS forState:UIControlStateNormal];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
        //SFAProfileGenderCell
    //ContinueButtonCell
    return [UITableViewCell new];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)leftButtonClicked:(id)sender{
    [self disconnect];
}

- (void)rightButtonCicked:(id)sender{
    //[self performSegueWithIdentifier:@"AddDetailsToBackupData" sender:self];
}

- (void)goToBackupData{
    //[self initializeDevice];
    
    DeviceEntity *deviceEntity                                = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    [SFAUserDefaultsManager sharedManager].lastSyncedDate     = [NSDate date];
    [SFAUserDefaultsManager sharedManager].watchModel         = deviceEntity.modelNumber.integerValue;
    [SFAUserDefaultsManager sharedManager].hasPaired          = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[SFAUserDefaultsManager sharedManager].macAddress forKey:LAST_MAC_ADDRESS];
    [userDefaults synchronize];
    [self performSegueWithIdentifier:@"AddDetailsToBackupData" sender:self];
}


- (void)initializeDevice
{
    DeviceEntity *deviceEntity                                = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    [SFAUserDefaultsManager sharedManager].lastSyncedDate     = [NSDate date];
    [SFAUserDefaultsManager sharedManager].watchModel         = deviceEntity.modelNumber.integerValue;
    [SFAUserDefaultsManager sharedManager].hasPaired          = YES;
}

#pragma mark - SFAProfileGenderCellDelegate
- (void)genderValueChangedWithSalutronUserProfile:(SalutronUserProfile *)salutronUserProfile{
    [SalutronUserProfile saveWithSalutronUserProfile:salutronUserProfile];
    DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    [UserProfileEntity userProfileWithSalutronUserProfile:salutronUserProfile forDeviceEntity:deviceEntity];
}

#pragma mark - SFAProfileCellDelegate
- (void)profileDataChangedWithSalutronUserProfile:(SalutronUserProfile *)salutronUserProfile{
    [SalutronUserProfile saveWithSalutronUserProfile:salutronUserProfile];
    DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    [UserProfileEntity userProfileWithSalutronUserProfile:salutronUserProfile forDeviceEntity:deviceEntity];
}

- (void)updateUserProfileDetails
{
    DDLogInfo(@"");
    
    Status updateUserStatus = [self.salutronCModelSync.salutronSDK updateUserProfile:[SFAUserDefaultsManager sharedManager].salutronUserProfile];
    
    if (updateUserStatus == NO_ERROR) {
        NSUndoManager *undoManager = [[NSUndoManager alloc] init];
        self.managedObjectContext.undoManager = undoManager;
        
        [undoManager beginUndoGrouping];
        
        NSError *error = nil;
        
        if ([self.managedObjectContext save:&error]) {
            [undoManager endUndoGrouping];
        } else {
            [undoManager undo];
        }
        
        WatchModel watchModel = [SFAUserDefaultsManager sharedManager].watchModel;
        if (watchModel == WatchModel_Move_C300 ||
            watchModel == WatchModel_Move_C300_Android ||
            watchModel == WatchModel_Zone_C410 ||
            watchModel == WatchModel_R420) {
            [self.salutronCModelSync.salutronSDK commDone];
        }
        
        [self goToBackupData];
    }
    else{
        SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
        vc.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc setErrorTitle:ERROR_TITLE
                errorMessage1:SYNCING_DETAILS_FAILED
                errorMessage2:SYNCING_DETAILS_SUGGESTION
                errorMessage3:@""
             andErrorMessage4:@""
            andButtonPosition:0
                 ButtonTitle1:LS_CONTINUE
              andButtonTitle2:@""];
        });
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)erroMessageCenterButtonClicked{
    [self goToBackupData];
}

- (void)erroMessageLeftButtonClicked{
    [self performSelector:@selector(disconnect) withObject:nil afterDelay:0.5];
}

- (void)erroMessageRightButtonClicked{
    
}

- (void)didSyncStarted{
    
}

- (void)didSyncFinished:(DeviceEntity *)deviceEntity profileUpdated:(BOOL)profileUpdated{
    
}

- (void)didChangeSettings{
    
}

- (void)didSaveSettings{
    
}

@end
