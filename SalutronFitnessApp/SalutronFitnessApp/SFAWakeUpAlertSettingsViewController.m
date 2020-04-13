//
//  SFAAlertSettingsViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 2/6/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAWakeUpAlertSettingsViewController.h"
#import "SFASettingsViewController.h"
#import "SFAFunFactsLifeTrakViewController.h"
#import "Wakeup+Data.h"

#import "SFAWakeUpAlarmSettingCell.h"
#import "JDADatePicker.h"

#define WAKEUP_ALERT_CELL       @"SFAWakeupAlertCellIdentifier"
#define WAKEUP_TIME_CELL        @"SFAWakeupTimeCellIdentifier"
#define WINDDOW_CELL            @"SFAWindowCellIdentifier"
#define SNOOZE_CELL             @"SFASnoozeCellIdentifier"
#define SNOOZE_TIME_CELL        @"SFASnoozeTimeIdentifier"

@interface SFAWakeUpAlertSettingsViewController () <SFAWakeUpAlarmSettingCellDelegate>

@property (strong, nonatomic) JDADatePicker                          *datePicker;
@property (assign, nonatomic,getter = isWakeUpAlertOn) BOOL          wakeUpAlert;
@property (assign, nonatomic) NSInteger                              wakeUpAlertHour;
@property (assign, nonatomic) NSInteger                              wakeUpAlertMinute;
@property (assign, nonatomic) NSInteger                              windowTimeValue;
@property (assign, nonatomic,getter = isSnoozeOn) BOOL               snooze;
@property (assign, nonatomic) NSInteger                              snoozeTimeValue;
@property (assign, nonatomic) NSInteger                              wakeupTimeHour;
@property (assign, nonatomic) NSInteger                              wakeupTimeMinute;
@property (strong, nonatomic) Wakeup                                 *wakeup;
@property (weak, nonatomic) SFASettingsViewController                *syncSetupViewController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SFAWakeUpAlertSettingsViewController

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
    self.wakeup = [[SFAUserDefaultsManager sharedManager] wakeUp];
    DDLogInfo(@"self.wakeup = %@", self.wakeup);
    UINavigationController *navigationController = (UINavigationController *)self.parentViewController;
    self.syncSetupViewController = (SFASettingsViewController *)navigationController.viewControllers[0];
    
   // UIViewController* vc = [SFAFunFactsLifeTrakViewController new];
   // [self presentViewController:vc animated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [SFAUserDefaultsManager sharedManager].wakeUp = self.wakeup;
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    [WakeupEntity wakeupWithWakeup:self.wakeup forDeviceEntity:deviceEntity];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (UIDatePicker *)datePicker {
    if(!_datePicker) {
        _datePicker = [[JDADatePicker alloc] initWithFrame:CGRectMake(0, 250, 325, 250)];
        _datePicker.datePickerMode = UIDatePickerModeTime;
    }
    return _datePicker;
}

- (void)setWakeUpAlert:(BOOL)wakeUpAlert
{
    _wakeUpAlert = wakeUpAlert;
    self.wakeup.wakeup_mode = wakeUpAlert ? 1 : 0;
    //self.syncSetupViewController.wakeupEntity = self.wakeupEntity;
}

- (void)setWakeUpAlertHour:(NSInteger)wakeUpAlertHour
{
    _wakeUpAlertHour = wakeUpAlertHour;
    self.wakeup.wakeup_hr = wakeUpAlertHour;
    //self.syncSetupViewController.wakeupEntity = self.wakeupEntity;
}

- (void)setWakeUpAlertMinute:(NSInteger)wakeUpAlertMinute
{
    _wakeUpAlertMinute = wakeUpAlertMinute;
    self.wakeup.wakeup_min = wakeUpAlertMinute;
    //self.syncSetupViewController.wakeupEntity = self.wakeupEntity;
}

- (void)setWindowTimeValue:(NSInteger)windowTimeValue
{
    _windowTimeValue = windowTimeValue;
    self.wakeup.wakeup_window = windowTimeValue;
    //self.syncSetupViewController.wakeupEntity = self.wakeupEntity;
}

- (void)setSnooze:(BOOL)snooze
{
    _snooze = snooze;
    self.wakeup.snooze_mode = snooze ? 1 : 0;
    //self.syncSetupViewController.wakeupEntity = self.wakeupEntity;
}

- (void)setSnoozeTimeValue:(NSInteger)snoozeTimeValue {
    _snoozeTimeValue = snoozeTimeValue;
    self.wakeup.snooze_min = snoozeTimeValue;
    //self.syncSetupViewController.wakeupEntity = self.wakeupEntity;
}

#pragma mark - SFAAlarmSettingCellDelegate

- (void)alarmSetting:(SFAAlarmSettingEnum)alarmSetting didChangeStatusValue:(BOOL)value
{
    switch (alarmSetting) {
        case AlarmSettingAlarmStatus:
            self.wakeUpAlert = value;
            break;
        case AlarmSettingSnoozeStatus:
            self.snooze = value;
            break;
        default:
            break;
    }
}

- (void)alarmSetting:(SFAAlarmSettingEnum)alarmSetting didStepperValueChanged:(id)sender
{
    UIStepper *stepper = (UIStepper *)sender;
    UITextField *numberTextField = (UITextField *)sender;
    
    switch (alarmSetting) {
        case AlarmSettingWindow:
            self.windowTimeValue = numberTextField.text.integerValue;
            break;
        case AlarmSettingSnoozeTime:
            self.snoozeTimeValue = stepper.value;
            break;
        default:
            break;
    }
}

- (void)alarmsetting:(SFAAlarmSettingEnum)alarmSetting didWakeupTimeChangedWithHour:(NSInteger)hour minute:(NSInteger)minute {
    self.wakeupTimeHour = hour;
    self.wakeupTimeMinute = minute;
    self.wakeUpAlertHour = hour;
    self.wakeUpAlertMinute = minute;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.wakeup.wakeup_mode == 1){
        return 3;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFAWakeUpAlarmSettingCell *cell = nil;
    
    switch (indexPath.row) {
        case 0: {
            cell = (SFAWakeUpAlarmSettingCell *)[tableView dequeueReusableCellWithIdentifier:WAKEUP_ALERT_CELL];
            [cell setAlarmStatusSwitch:(self.wakeup.wakeup_mode == 1 ? YES : NO)];
            [cell.wakeupAlertSwitch addTarget:self action:@selector(wakeupModeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 1: {
            cell = (SFAWakeUpAlarmSettingCell *)[tableView dequeueReusableCellWithIdentifier:WAKEUP_TIME_CELL];
            
            TimeDate *timeDate = [TimeDate getData];
            
            if(timeDate.hourFormat == _12_HOUR) {
                NSInteger wakeupHour = self.wakeup.wakeup_hr;
                NSInteger hour = wakeupHour > 12 ? wakeupHour - 12 : wakeupHour;
                [cell setWakeupTimeValue:[NSString stringWithFormat:@"%i:%02i %@", hour, self.wakeup.wakeup_min, wakeupHour > 12 ? LS_PM : LS_AM]];
            } else {
                [cell setWakeupTimeValue:[NSString stringWithFormat:@"%i:%02i", self.wakeup.wakeup_hr, self.wakeup.wakeup_min]];
            }
            break;
        }
        case 2: {
            cell = (SFAWakeUpAlarmSettingCell *)[tableView dequeueReusableCellWithIdentifier:WINDDOW_CELL];
            [cell setWindowTimeStepperValue:self.wakeup.wakeup_window];
            //[cell setWindowTimeTextValue:[NSString stringWithFormat:@"%i %@", self.wakeupEntity.wakeupWindow.integerValue, (self.wakeupEntity.wakeupWindow.integerValue != 1) ? @"minutes" : @"minute"]];
            [cell setWindowTimeValue:self.wakeup.wakeup_window];
            break;
        }
        case 3: {
            cell = (SFAWakeUpAlarmSettingCell *)[tableView dequeueReusableCellWithIdentifier:SNOOZE_CELL];
            [cell setSnoozeStatusSwitch:(self.wakeup.snooze_mode == 1 ? YES : NO)];
            break;
        }
        case 4: {
            cell = (SFAWakeUpAlarmSettingCell *)[tableView dequeueReusableCellWithIdentifier:SNOOZE_TIME_CELL];
            [cell setSnoozeTimeStepperValue:self.wakeup.snooze_min];
            [cell setSnoozeTimeTextValue:[NSString stringWithFormat:@"%i %@", self.wakeup.snooze_min, (self.wakeup.snooze_min > 1 ? @"minutes" : @"minute")]];
            break;
        }
        default:
            break;
    }
    
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        SFAWakeUpAlarmSettingCell *cell = (SFAWakeUpAlarmSettingCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell.wakeupTimeTextField becomeFirstResponder];
    }
}

#pragma mark - ibactions
- (void)wakeupModeSwitchChanged:(id)sender
{
    [self.tableView reloadData];
}

@end
