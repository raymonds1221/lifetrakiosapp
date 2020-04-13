//
//  SFANightLightAlertSettingsViewController.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/1/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFANightLightAlertSettingsViewController.h"
#import "UIViewController+Helper.h"

#import "SFALightAlertNumberCell.h"
#import "SFALightAlertPickerCell.h"
#import "SFALightAlertSwitchCell.h"

#import "SFAUserDefaultsManager.h"
#import "TimeDate+Data.h"

#import "NightLightAlertEntity+Data.h"
#import "NightLightAlert+Coding.h"

@interface SFANightLightAlertSettingsViewController ()<UITableViewDelegate, UITableViewDataSource, SFAStringLightAlertPickerCellDelegate, UITextFieldDelegate>

@property (strong, nonatomic) SFALightAlertSwitchCell *statusCell;
@property (strong, nonatomic) SFALightAlertPickerCell *exposureLevelCell;
@property (strong, nonatomic) SFALightAlertPickerCell *exposureDurationCell;
@property (strong, nonatomic) SFALightAlertPickerCell *startTimeCell;
@property (strong, nonatomic) SFALightAlertPickerCell *endTimeCell;
@property (strong, nonatomic) SFALightAlertNumberCell *intervalCell;
@property (strong, nonatomic) SFALightAlertNumberCell *levelLowThresholdCell;
@property (strong, nonatomic) SFALightAlertNumberCell *levelMidThresholdCell;
@property (strong, nonatomic) SFALightAlertNumberCell *levelHighThresholdCell;

@property (strong, nonatomic) NightLightAlert *nightLightAlert;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) BOOL adjustKeyboard;

@end

@implementation SFANightLightAlertSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeObjects];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self saveToUserDefaults];
    [self unregisterKeyboardNotifications];
}

#pragma mark - private
- (void)initializeObjects
{
    self.nightLightAlert = [[SFAUserDefaultsManager sharedManager] nightLightAlert];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SFALightAlertSwitchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:switchCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SFALightAlertPickerCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:pickerCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SFALightAlertNumberCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:numberCellIdentifier];
    
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem=newBackButton;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)saveToUserDefaults
{
    self.nightLightAlert.status = self.statusCell.status.on == YES? 1:0;
    self.nightLightAlert.level = [self.exposureLevelCell.stringValuesArray indexOfObject:self.exposureLevelCell.stringValue];
    self.nightLightAlert.duration = self.exposureDurationCell.durationValue;
    self.nightLightAlert.start_hour = self.startTimeCell.hour;
    self.nightLightAlert.start_min = self.startTimeCell.minute;
    self.nightLightAlert.end_hour = self.endTimeCell.hour;
    self.nightLightAlert.end_min = self.endTimeCell.minute;
    self.nightLightAlert.level_low = self.levelLowThresholdCell.value;
    self.nightLightAlert.level_mid = self.levelMidThresholdCell.value;
    self.nightLightAlert.level_hi = self.levelHighThresholdCell.value;
    
    [SFAUserDefaultsManager sharedManager].nightLightAlert = self.nightLightAlert;
    
    DDLogInfo(@"self.nightLightAlert = %@", self.nightLightAlert);
    
}

#pragma mark - ibaction
- (void)back:(UIBarButtonItem *)sender
{
    NSInteger startTime = self.startTimeCell.hour*60 + self.startTimeCell.minute;
    NSInteger endTime = self.endTimeCell.hour*60 + self.endTimeCell.minute;
    NSInteger startTimeEndTimeDifference = endTime - startTime;
    NSInteger timeDuration = self.exposureDurationCell.durationValue;
    
    if (!self.statusCell.status.on){
        [self saveToUserDefaults];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (endTime <startTime){
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                     message:LS_END_TIME_WARNING
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
            [[[UIAlertView alloc] initWithTitle:ERROR_TITLE message:LS_END_TIME_WARNING delegate:nil cancelButtonTitle:BUTTON_TITLE_OK_NORMAL otherButtonTitles:nil] show];
        }
        return;
    }
    
    if (endTime == startTime){
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                     message:LS_START_TIME_WARNING
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
            [[[UIAlertView alloc] initWithTitle:ERROR_TITLE message:LS_START_TIME_WARNING delegate:nil cancelButtonTitle:BUTTON_TITLE_OK_NORMAL otherButtonTitles:nil] show];
        }
        return;
    }
    
    if (startTimeEndTimeDifference < 30){
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                     message:LS_INTERVAL_TIME_WARNING
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
            [[[UIAlertView alloc] initWithTitle:ERROR_TITLE message:LS_INTERVAL_TIME_WARNING delegate:nil cancelButtonTitle:BUTTON_TITLE_OK_NORMAL otherButtonTitles:nil] show];
        }
        
        return;
    }
    
    if (startTimeEndTimeDifference < timeDuration){
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                     message:LS_EXPOSURE_DURATION_WARNING
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
            [[[UIAlertView alloc] initWithTitle:ERROR_TITLE message:LS_EXPOSURE_DURATION_WARNING delegate:nil cancelButtonTitle:BUTTON_TITLE_OK_NORMAL otherButtonTitles:nil] show];
        }
        return;
    }
    
    //check if daylight alert settings start and end time overlaps with nightlight alert start and end time
    DayLightAlert *dayLightAlert = [SFAUserDefaultsManager sharedManager].dayLightAlert;
    NSInteger dayLightAlertEndTime = dayLightAlert.end_hour*60 + dayLightAlert.end_min;
    if (startTime <= dayLightAlertEndTime && dayLightAlert.status == 1){
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                     message:LS_OVERLAP_WARNING
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
            [[[UIAlertView alloc] initWithTitle:ERROR_TITLE message:LS_OVERLAP_WARNING delegate:nil cancelButtonTitle:BUTTON_TITLE_OK_NORMAL otherButtonTitles:nil] show];
        }
        return;
    }
    
    [self saveToUserDefaults];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.nightLightAlert.status){
        return 5;
    }else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            self.statusCell = [tableView dequeueReusableCellWithIdentifier:switchCellIdentifier];
            self.statusCell.titleLabel.text = LS_STATUS_TITLE;
            self.statusCell.status.on = self.nightLightAlert.status == 0? false:true;
            [self.statusCell.status addTarget:self action:@selector(statusCellChanged:) forControlEvents:UIControlEventValueChanged];
            return self.statusCell;
        case 1:
            self.exposureLevelCell = [tableView dequeueReusableCellWithIdentifier:pickerCellIdentifier];
            self.exposureLevelCell.titleLabel.text = LS_EXPOSURE_LEVEL;
            self.exposureLevelCell.stringValuesArray = @[LS_LOW,LS_MEDIUM,LS_HIGH];
            self.exposureLevelCell.stringValue = self.exposureLevelCell.stringValuesArray[self.nightLightAlert.level];
            self.exposureLevelCell.cellType = SFALightPickerCellTypeString;
//            self.exposureLevelCell.stringDelegate = self;
            return self.exposureLevelCell;
        case 2:
            self.exposureDurationCell = [tableView dequeueReusableCellWithIdentifier:pickerCellIdentifier];
            self.exposureDurationCell.titleLabel.text = LS_EXPOSURE_DURATION;
            self.exposureDurationCell.durationValue = self.nightLightAlert.duration;
            self.exposureDurationCell.maxMinutesDuration = 120;
            self.exposureDurationCell.minMinutesDuration = 10;
            self.exposureDurationCell.cellType = SFALightPickerCellTypeDuration;
            return self.exposureDurationCell;
        case 3:
            self.startTimeCell = [tableView dequeueReusableCellWithIdentifier:pickerCellIdentifier];
            self.startTimeCell.titleLabel.text = LS_START_TIME;
            self.startTimeCell.minute = self.nightLightAlert.start_min;
            self.startTimeCell.hour = self.nightLightAlert.start_hour;
            self.startTimeCell.cellType = SFALightPickerCellTypeTime;
            self.startTimeCell.pickerText.delegate = self;
            return self.startTimeCell;
        case 4:
            self.endTimeCell = [tableView dequeueReusableCellWithIdentifier:pickerCellIdentifier];
            self.endTimeCell.titleLabel.text = LS_END_TIME;
            self.endTimeCell.minute = self.nightLightAlert.end_min;
            self.endTimeCell.hour = self.nightLightAlert.end_hour;
            self.endTimeCell.cellType = SFALightPickerCellTypeTime;
            self.endTimeCell.pickerText.delegate = self;
            return self.endTimeCell;
        default:
            return nil;
            break;
    }
}

#pragma mark - private methods
- (void)statusCellChanged:(UISwitch *)statusSwitch
{
    if (self.statusCell.status.on){
        self.nightLightAlert.status = 1;
        [SFAUserDefaultsManager sharedManager].nightLightAlert = self.nightLightAlert;
    }else{
        [self saveToUserDefaults];
    }
    [self.tableView reloadData];
}

- (BOOL)isiPhone5
{
    CGRect screenRect       = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight    = screenRect.size.height;
    return screenHeight == 568;
}

#pragma mark - uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if cell is light alert numbercell, adjust height
    switch (indexPath.row) {
        case 5:
        case 6:
        case 7:
            return 97.0f;
        default:
            return 45.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - string type SFALightAlertPickerCel Delegate
- (void)lightAlertPickerCell:(SFALightAlertPickerCell *)cell stringValueChangedTo:(NSString *)valueChanged
{
    if (cell != self.exposureLevelCell){
        return;
    }
    self.nightLightAlert.level = [self.exposureLevelCell.stringValuesArray indexOfObject:valueChanged];
    [SFAUserDefaultsManager sharedManager].nightLightAlert = self.nightLightAlert;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - keyboard
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)unregisterKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (self.adjustKeyboard){
        
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
        self.adjustKeyboard = NO;
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(64.0f, 0.0f, 0.0f, 0.0f);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
}

#pragma mark - uitextfield delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ((textField == self.startTimeCell.pickerText || textField == self.endTimeCell.pickerText) && ![self isiPhone5]){
        self.adjustKeyboard = YES;
    }
}

@end
