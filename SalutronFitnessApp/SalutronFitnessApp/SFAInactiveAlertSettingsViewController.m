//
//  SFAInactiveAlertSettingsViewController.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/1/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAInactiveAlertSettingsViewController.h"
#import "UIViewController+Helper.h"
#import "SFALightAlertNumberCell.h"
#import "SFALightAlertPickerCell.h"
#import "SFALightAlertSwitchCell.h"

#import "SFAUserDefaultsManager.h"
#import "TimeDate+Data.h"

#import "InactiveAlertEntity+Data.h"
#import "InactiveAlert+Coding.h"


@interface SFAInactiveAlertSettingsViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) SFALightAlertSwitchCell *statusCell;
@property (weak, nonatomic) SFALightAlertPickerCell *timeDurationCell;
@property (weak, nonatomic) SFALightAlertNumberCell *stepsThresholdCell;
@property (weak, nonatomic) SFALightAlertPickerCell *startTimeCell;
@property (weak, nonatomic) SFALightAlertPickerCell *endTimeCell;

//@property (strong, nonatomic) InactiveAlertEntity *inactiveAlert;
@property (strong, nonatomic) InactiveAlert *inactiveAlert;

@property (assign, nonatomic) BOOL adjustKeyboard;

@end

@implementation SFAInactiveAlertSettingsViewController

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

#pragma mark - private methods

- (void)initializeObjects
{
    self.inactiveAlert = [[SFAUserDefaultsManager sharedManager] inactiveAlert];
    //self.navigationItem.title = ALERT_SETTING_INACTIVITY;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SFALightAlertSwitchCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:switchCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SFALightAlertPickerCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:pickerCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SFALightAlertNumberCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:numberCellIdentifier];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    
     self.navigationItem.leftBarButtonItem = newBackButton;
    
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
}

- (void)saveToUserDefaults
{
    self.inactiveAlert.status = self.statusCell.status.on == YES? 1:0;
    self.inactiveAlert.time_duration = self.timeDurationCell.durationValue;
    self.inactiveAlert.steps_threshold = self.stepsThresholdCell.value;
    self.inactiveAlert.start_hour = self.startTimeCell.hour;
    self.inactiveAlert.start_min = self.startTimeCell.minute;
    self.inactiveAlert.end_hour = self.endTimeCell.hour;
    self.inactiveAlert.end_min = self.endTimeCell.minute;
    
    [SFAUserDefaultsManager sharedManager].inactiveAlert = self.inactiveAlert;
}

#pragma mark - ibaction
- (void)back:(UIBarButtonItem *)sender
{
    NSInteger startTime = self.startTimeCell.hour*60 + self.startTimeCell.minute;
    NSInteger endTime = self.endTimeCell.hour*60 + self.endTimeCell.minute;
    NSInteger startTimeEndTimeDifference = endTime - startTime;
    NSInteger timeDuration = self.timeDurationCell.durationValue;
    
    
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
    
    if ( !(startTimeEndTimeDifference >= 30)){
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
    
    [self saveToUserDefaults];
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.inactiveAlert.status){
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
            self.statusCell.status.on = self.inactiveAlert.status == 0? false:true;
            [self.statusCell.status addTarget:self action:@selector(statusCellChanged:) forControlEvents:UIControlEventValueChanged];
            return self.statusCell;
        case 1:
            self.timeDurationCell = [tableView dequeueReusableCellWithIdentifier:pickerCellIdentifier];
            self.timeDurationCell.titleLabel.text = LS_TIME_DURATION;
            self.timeDurationCell.durationValue = self.inactiveAlert.time_duration;
            self.timeDurationCell.maxMinutesDuration = 299;
            self.timeDurationCell.minMinutesDuration = 0;
            self.timeDurationCell.cellType = SFALightPickerCellTypeDuration;
            return self.timeDurationCell;
        case 2:
            self.startTimeCell = [tableView dequeueReusableCellWithIdentifier:pickerCellIdentifier];
            self.startTimeCell.titleLabel.text = LS_START_TIME;
            self.startTimeCell.minute = self.inactiveAlert.start_min;
            self.startTimeCell.hour = self.inactiveAlert.start_hour;
            self.startTimeCell.cellType = SFALightPickerCellTypeTime;
            self.startTimeCell.pickerText.delegate = self;
            return self.startTimeCell;
        case 3:
            self.endTimeCell = [tableView dequeueReusableCellWithIdentifier:pickerCellIdentifier];
            self.endTimeCell.titleLabel.text = LS_END_TIME;
            self.endTimeCell.minute = self.inactiveAlert.end_min;
            self.endTimeCell.hour = self.inactiveAlert.end_hour;
            self.endTimeCell.cellType = SFALightPickerCellTypeTime;
            self.endTimeCell.pickerText.delegate = self;
            return self.endTimeCell;
        case 4:
            self.stepsThresholdCell = [tableView dequeueReusableCellWithIdentifier:numberCellIdentifier];
            self.stepsThresholdCell.titleLabel.text = LS_STEPS_THRESHOLD;
            self.stepsThresholdCell.unit = NSLocalizedString(@"step", nil);
            self.stepsThresholdCell.value = self.inactiveAlert.steps_threshold;
            self.stepsThresholdCell.slider.value = self.inactiveAlert.steps_threshold;
            self.stepsThresholdCell.min = 1.0f;
            self.stepsThresholdCell.max = 999;
            return self.stepsThresholdCell;
        default:
            return nil;
            break;
    }
}

#pragma mark - uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if cell is light alert numbercell, adjust height
    switch (indexPath.row) {
        case 4:
            return 97.0f;
        default:
            return 45.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - private methods
- (void)statusCellChanged:(UISwitch *)statusSwitch
{
    if (self.statusCell.status.on){
        self.inactiveAlert.status = 1;
        [SFAUserDefaultsManager sharedManager].inactiveAlert = self.inactiveAlert;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    if ((textField == self.startTimeCell.pickerText && ![self isiPhone5]) || textField == self.endTimeCell.pickerText){
        self.adjustKeyboard = YES;
    }
}

@end
