//
//  SFAAlarmSettingsViewController.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 8/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAAlarmSettingsViewController.h"
#import "SFAAlarmSettingsMenuCell.h"
#import "SFASettingsToggleCellWithDesc.h"
#import "SFASettingsCellWithButton.h"
#import "DeviceEntity+Data.h"
#import "WakeupEntity+Data.h"
#import "DayLightAlertEntity+Data.h"
#import "NightLightAlertEntity+Data.h"
#import "InactiveAlertEntity+Data.h"
#import "UIViewController+Helper.h"

#define ALARM_SETTINGS_CELL                     @"SFAAlarmSettingsCellIdentifier"
#define SETTING_TOGGLE_CELL_WITH_DESC           @"SFASettingsToggleCellWithDesc"
#define SETTING_CELL_WITH_BUTTON                @"SFASettingsCellWithButton"
#define SETTING_CELL_WITH_BUTTON_WITH_SLIDER    @"SFASettingsCellWithButtonWithSlider"

#define WAKEUP_SEGUE_ID             @"AlarmSettingsToWakeUpAlertSettings"
#define DAYLIGHT_SEGUE_ID           @"AlarmSettingsToDayLightAlertSettings"
#define NIGHTLIGHT_SEGUE_ID         @"AlarmSettingsToNightLightAlertSettings"
#define INACTIVE_SEGUE_ID           @"AlarmSettingsToInactiveAlertSettings"

#define HOUR_FORMAT_12                       0
#define HOUR_FORMAT_24                       1

@interface SFAAlarmSettingsViewController () <UITableViewDataSource, UITableViewDelegate, SFASettingsCellWithButtonDelegate, SFASettingsToggleCellWithDescDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) Wakeup            *wakeUpAlert;
@property (strong, nonatomic) DayLightAlert     *dayLightAlert;
@property (strong, nonatomic) NightLightAlert   *nightLightAlert;
@property (strong, nonatomic) InactiveAlert     *inactiveAlert;
@property (strong, nonatomic) UIPickerView      *pickerView;
@property (strong, nonatomic) UIView            *genericPickerView;
@property (strong, nonatomic) NSString          *modifyingSettingName;
@property (nonatomic) int                       modifyingSection;
@end

@implementation SFAAlarmSettingsViewController

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
    
    self.navigationItem.title = WATCH_ALARMS_TITLE;
    [self hideCancelAndSave];
    [self getCurrentSettings];
    [self addGenericPickerView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getCurrentSettings{
    self.wakeUpAlert = [[SFAUserDefaultsManager sharedManager] wakeUp];
    self.dayLightAlert = [[SFAUserDefaultsManager sharedManager] dayLightAlert];
    self.nightLightAlert = [[SFAUserDefaultsManager sharedManager] nightLightAlert];
    self.inactiveAlert = [[SFAUserDefaultsManager sharedManager] inactiveAlert];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 66.0f;
    }
    if (section == 3) {
        return 78.0f;
    }
    return 88.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //if (indexPath.section == 3 && indexPath.row == 0) {
    //    return 88.0f;
    //}
    switch (indexPath.section) {
        case 0:
            if (self.wakeUpAlert.wakeup_mode) {
                return 44.0f;
            }
            return 0;
            break;
        case 1:
            if (self.dayLightAlert.status) {
                return 44.0f;
            }
            return 0;
            break;
        case 2:
            if (self.nightLightAlert.status) {
                return 44.0f;
            }
            return 0;
            break;
        case 3:
            if (self.inactiveAlert.status) {
                if(indexPath.row == 0)
                    return 88.0f;
                return 44.0f;
            }
            return 0;
            break;
        default:
            break;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SFASettingsToggleCellWithDesc *cell = (SFASettingsToggleCellWithDesc *)[tableView dequeueReusableCellWithIdentifier:SETTING_TOGGLE_CELL_WITH_DESC];
    switch (section) {
        case 0:
            cell.labelTitle.text = WATCH_ALARMS_WAKE_UP;
            cell.labelDescription.text = WATCH_ALARMS_WAKE_UP_DESC;
            [cell.toggleButton setOn:self.wakeUpAlert.wakeup_mode];
            break;
        case 1:
            cell.labelTitle.text = WATCH_ALARMS_DAYLIGHT;
            cell.labelDescription.text = WATCH_ALARMS_DAYLIGHT_DESC;
            [cell.toggleButton setOn:self.dayLightAlert.status];
            break;
        case 2:
            cell.labelTitle.text = WATCH_ALARMS_NIGHTLIGHT;
            cell.labelDescription.text = WATCH_ALARMS_NIGHTLIGHT_DESC;
            [cell.toggleButton setOn:self.nightLightAlert.status];
            break;
        case 3:
            cell.labelTitle.text = WATCH_ALARMS_INACTIVITY;
            cell.labelDescription.text = WATCH_ALARMS_INACTIVITY_DESC;
            [cell.toggleButton setOn:self.inactiveAlert.status];
            break;
        default:
            break;
    }
    cell.delegate = self;
    UIView *view = [[UIView alloc] initWithFrame:[cell frame]];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, screenWidth, 88.0f);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, screenWidth, 66.0f);
    }
    else if (section == 3) {
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, screenWidth, 78.0f);
    }
    view.backgroundColor = [UIColor whiteColor];
    [view addSubview:cell];
    
    return view;
    //return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            //if (self.wakeUpAlert.wakeup_mode) {
                return 2;
            //}
            //return 0;
            break;
        case 1:
            //if (self.dayLightAlert.status) {
                return 4;
            //}
            //return 0;
            break;
        case 2:
            //if (self.nightLightAlert.status) {
                return 3;
            //}
            //return 0;
            break;
        case 3:
            //if (self.inactiveAlert.status) {
                return 3;
            //}
            //return 0;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFASettingsCellWithButton *cell = (SFASettingsCellWithButton *)[tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_BUTTON];
    cell.cellButton.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    
//    if (cell == nil){
//        cell = [[SFAAlarmSettingsMenuCell alloc] initWithStyle:UITableViewCellStyle reuseIdentifier:ALARM_SETTINGS_CELL];
//    }
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                cell.lableTitle.text = LS_WAKEUP_TIME;
                
                SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
                //int wakeUpSeconds = self.wakeUpAlert.wakeup_hr*3600 + self.wakeUpAlert.wakeup_min*60;
                NSString *timeString = [self convertTimestampToStringWithHour:self.wakeUpAlert.wakeup_hr andMinute:self.wakeUpAlert.wakeup_min withTimeDate:userDefaultsManager.timeDate];
                [cell.cellButton setTitle:timeString forState:UIControlStateNormal];
            }
            else if (indexPath.row == 1) {
                cell.lableTitle.text = LS_WAKEUP_TIME_STARTS;
                NSString *timeStartsString = [NSString stringWithFormat:@"%i %@ %@", self.wakeUpAlert.wakeup_window, self.wakeUpAlert.wakeup_window > 1 ? @"mins": @"min", LS_EARLIER];
                [cell.cellButton setTitle:timeStartsString forState:UIControlStateNormal];
            }
            if(!self.wakeUpAlert.wakeup_mode)
                cell.hidden = YES;
            break;
        case 1:
            if (indexPath.row == 0) {
                cell.lableTitle.text = LS_EXPOSURE_LEVEL;
                [cell.cellButton setTitle:[[self arrayOfLevels] objectAtIndex:self.dayLightAlert.level] forState:UIControlStateNormal];
            }
            else if (indexPath.row == 1) {
                cell.lableTitle.text = LS_LIGHT_EXPOSURE_GOAL;
                NSInteger hour = self.dayLightAlert.duration/60;
                NSInteger minute = self.dayLightAlert.duration%60;
                NSString *hrString = LS_HR;
                NSString *minString = LS_MIN;
                if (hour > 1) {
                    hrString = LS_HRS;
                }
                if (minute > 1) {
                    minString = LS_MINS;
                }
                NSString *durationString = [NSString stringWithFormat:@"%i %@ %i %@", hour, hrString, minute, minString];
                [cell.cellButton setTitle:durationString forState:UIControlStateNormal];
            }
            else if (indexPath.row == 2) {
                cell.lableTitle.text = LS_ALERT_WINDOW;
                
                SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
                //int startSeconds = self.dayLightAlert.start_hour*3600 + self.dayLightAlert.start_min*60;
                NSString *startTimeString = [self convertTimestampToStringWithHour:self.dayLightAlert.start_hour andMinute:self.dayLightAlert.start_min withTimeDate:userDefaultsManager.timeDate];
                
                //int endSeconds = self.dayLightAlert.end_hour*3600 + self.dayLightAlert.end_min*60;
                NSString *endTimeString = [self convertTimestampToStringWithHour:self.dayLightAlert.end_hour andMinute:self.dayLightAlert.end_min withTimeDate:userDefaultsManager.timeDate];
                
                NSString *stringAlertWindow = [NSString stringWithFormat:@"%@ %@ %@", startTimeString, LS_TO, endTimeString];
                [cell.cellButton setTitle:stringAlertWindow forState:UIControlStateNormal];
            }
            else if (indexPath.row == 3) {
                cell.lableTitle.text = LS_ALERT_INTERVAL;
                NSString *minString = @"min";
                if (self.dayLightAlert.interval > 1) {
                    minString = @"mins";
                }
                NSString *durationString = [NSString stringWithFormat:@"%i %@", self.dayLightAlert.interval, minString];
                [cell.cellButton setTitle:durationString forState:UIControlStateNormal];
            }
            if(!self.dayLightAlert.status)
                cell.hidden = YES;
            break;
        case 2:
            if (indexPath.row == 0) {
                cell.lableTitle.text = LS_EXPOSURE_LEVEL;
                [cell.cellButton setTitle:[[self arrayOfLevels] objectAtIndex:self.nightLightAlert.level] forState:UIControlStateNormal];
            }
            else if (indexPath.row == 1) {
                cell.lableTitle.text = LS_LIGHT_EXPOSURE_GOAL;
                NSInteger hour = self.nightLightAlert.duration/60;
                NSInteger minute = self.nightLightAlert.duration%60;
                NSString *hrString = LS_HR;
                NSString *minString = LS_MIN;
                if (hour > 1) {
                    hrString = LS_HRS;
                }
                if (minute > 1) {
                    minString = LS_MINS;
                }
                NSString *durationString = [NSString stringWithFormat:@"%i %@ %i %@", hour, hrString, minute, minString];
                [cell.cellButton setTitle:durationString forState:UIControlStateNormal];
            }
            else if (indexPath.row == 2) {
                cell.lableTitle.text = LS_ALERT_WINDOW;
                SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
                //int startSeconds = self.dayLightAlert.start_hour*3600 + self.dayLightAlert.start_min*60;
                NSString *startTimeString = [self convertTimestampToStringWithHour:self.nightLightAlert.start_hour andMinute:self.nightLightAlert.start_min withTimeDate:userDefaultsManager.timeDate];
                
                //int endSeconds = self.dayLightAlert.end_hour*3600 + self.dayLightAlert.end_min*60;
                NSString *endTimeString = [self convertTimestampToStringWithHour:self.nightLightAlert.end_hour andMinute:self.nightLightAlert.end_min withTimeDate:userDefaultsManager.timeDate];
                
                NSString *stringAlertWindow = [NSString stringWithFormat:@"%@ %@ %@", startTimeString, LS_TO, endTimeString];
                [cell.cellButton setTitle:stringAlertWindow forState:UIControlStateNormal];
            }
            
            if(!self.nightLightAlert.status)
                cell.hidden = YES;
            break;
        case 3:
            if (indexPath.row == 0) {
                SFASettingsCellWithButton *cell2 = (SFASettingsCellWithButton *)[tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_BUTTON_WITH_SLIDER];
                cell = cell2;
                [cell.cellSlider setMaximumValue:999];
                [cell.cellSlider setMinimumValue:1];
                cell.sliderMultipleIncrement = 5;
                [cell.cellSlider setValue:self.inactiveAlert.steps_threshold];
                cell.lableTitle.text = LS_STEPS_THRESHOLD;
                NSString *stepsString = [NSString stringWithFormat:@"%i %@", self.inactiveAlert.steps_threshold, LS_STEPS];
                if (self.inactiveAlert.steps_threshold == 1) {
                    stepsString = [NSString stringWithFormat:@"%i %@", self.inactiveAlert.steps_threshold, LS_STEP];
                }
                cell.leftSmallLabel.text = [NSString stringWithFormat:@"1 %@", LS_STEP];
                cell.rightSmallLabel.text = [NSString stringWithFormat:@"999 %@", LS_STEPS];
                [cell.cellButton setTitle:stepsString forState:UIControlStateNormal];
            }
            else if (indexPath.row == 1) {
                cell.lableTitle.text = LS_ALERT_WINDOW;
                SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
                //int startSeconds = self.dayLightAlert.start_hour*3600 + self.dayLightAlert.start_min*60;
                NSString *startTimeString = [self convertTimestampToStringWithHour:self.inactiveAlert.start_hour andMinute:self.inactiveAlert.start_min withTimeDate:userDefaultsManager.timeDate];
                
                //int endSeconds = self.dayLightAlert.end_hour*3600 + self.dayLightAlert.end_min*60;
                NSString *endTimeString = [self convertTimestampToStringWithHour:self.inactiveAlert.end_hour andMinute:self.inactiveAlert.end_min withTimeDate:userDefaultsManager.timeDate];
                
                NSString *stringAlertWindow = [NSString stringWithFormat:@"%@ %@ %@", startTimeString, LS_TO, endTimeString];
                [cell.cellButton setTitle:stringAlertWindow forState:UIControlStateNormal];
            }
            else if (indexPath.row == 2) {
                cell.lableTitle.text = LS_ALERT_INTERVAL;
                [cell.cellButton setTitle:@"5 mins" forState:UIControlStateNormal];
               /*
                NSString *minString = @"min";
                if (self.dayLightAlert.interval > 1) {
                    minString = @"mins";
                }
                NSString *durationString = [NSString stringWithFormat:@"%i %@", self.dayLightAlert.interval, minString];
                [cell.cellButton setTitle:durationString forState:UIControlStateNormal];
                */
                NSInteger hour = self.inactiveAlert.time_duration/60;
                NSInteger minute = self.inactiveAlert.time_duration%60;
                NSString *hrString = LS_HR;
                NSString *minString = LS_MIN;
                if (hour > 1) {
                    hrString = LS_HRS;
                }
                if (minute > 1) {
                    minString = LS_MINS;
                }
                NSString *durationString = [NSString stringWithFormat:@"%i %@ %i %@", hour, hrString, minute, minString];
                [cell.cellButton setTitle:durationString forState:UIControlStateNormal];

            }
            if(!self.inactiveAlert.status)
                cell.hidden = YES;
            break;
        default:
            break;
    }
//    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = indexPath.section*100 + indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - SFASettingsCellWithButtonDelegate
- (void)didButtonClicked:(UIButton *)sender withLabelTitle:(NSString *)title andCellTag:(int)cellTag{
    self.modifyingSettingName = title;
    self.modifyingSection = cellTag/100;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:cellTag%100 inSection:cellTag/100] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [self showPickerView];
    [self showCancelAndSave];
}

#pragma mark - UIViewPickerViewDelegate
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        tView.font = [UIFont systemFontOfSize:21.0];
        if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
            tView.font = [UIFont systemFontOfSize:18.0];
        }
        if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME] && LANGUAGE_IS_FRENCH) {
            if ([SFAUserDefaultsManager sharedManager].timeDate.hourFormat == HOUR_FORMAT_12) {
                if (component == 2) {
                    tView.font = [UIFont systemFontOfSize:15.0];
                }
            }
        }
        tView.textAlignment = NSTextAlignmentCenter;
        // Setup label properties - frame, font, colors etc
        tView.text = @"";
    }
    // Fill the label text here
    if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME]) {
        SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
        if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
            if (component == 0) {
                tView.text = [[self arrayOf12Hours] objectAtIndex:row];
            }
            else if (component == 1){
                tView.text = [[self arrayOfMinutes] objectAtIndex:row];
            }
            else if (component == 2){
                tView.text = [[self arrayOfAmPm] objectAtIndex:row];;
            }
        }
        else{
            if (component == 0) {
                tView.text = [[self arrayOf24Hours] objectAtIndex:row];
            }
            else if (component == 1){
                tView.text = [[self arrayOfMinutes] objectAtIndex:row];
            }
        }
    }
    else if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME_STARTS]) {
        tView.text = [[self arrayOfMinutes] objectAtIndex:row];
    }
    if ([self.modifyingSettingName isEqualToString:LS_EXPOSURE_LEVEL]) {
        tView.text = [[self arrayOfLevels] objectAtIndex:row];
    }
    else if ([self.modifyingSettingName isEqualToString:LS_LIGHT_EXPOSURE_GOAL]) {
        if (component == 0) {
            tView.text = [[self arrayOf2Hours] objectAtIndex:row];
        }
        else if (component == 1){
            tView.text = LS_HR;
        }
        else if (component == 2){
            tView.text = [[self arrayOfMinutes] objectAtIndex:row];;
        }
        else if (component == 3) {
            tView.text = LS_MIN;
        }
        
    }
    else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
        SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
        if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
            if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad && LANGUAGE_IS_FRENCH) {
                tView.font = [UIFont systemFontOfSize:12];
            }
            if (component == 0) {
                tView.text = [[self arrayOf12Hours] objectAtIndex:row];
            }
            else if (component == 1){
                tView.text = [[self arrayOfMinutes] objectAtIndex:row];
            }
            else if (component == 2){
                tView.text = [[self arrayOfAmPm] objectAtIndex:row];;
            }
            else if (component == 3) {
                tView.text = LS_TO;
            }
            else if (component == 4){
                tView.text = [[self arrayOf12Hours] objectAtIndex:row];
            }
            else if (component == 5){
                tView.text = [[self arrayOfMinutes] objectAtIndex:row];;
            }
            else if (component == 6){
                tView.text = [[self arrayOfAmPm] objectAtIndex:row];
            }
        }
        else{
            if (component == 0) {
                tView.text = [[self arrayOf24Hours] objectAtIndex:row];
            }
            else if (component == 1){
                tView.text = [[self arrayOfMinutes] objectAtIndex:row];
            }
            else if (component == 2) {
                tView.text = LS_TO;
            }
            else if (component == 3){
                tView.text = [[self arrayOf24Hours] objectAtIndex:row];
            }
            else if (component == 4){
                tView.text = [[self arrayOfMinutes] objectAtIndex:row];;
            }
        }
    }
    else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL] && self.modifyingSection == 1) {
        tView.text = [NSString stringWithFormat:@"%i", row+5];
    }
    else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL] && self.modifyingSection == 3) {
        if (component == 0) {
            tView.text = [[self arrayOf4Hours] objectAtIndex:row];
        }
        else if (component == 1){
            tView.text = LS_HR;
        }
        else if (component == 2){
            tView.text = [[self arrayOfMinutes] objectAtIndex:row];;
        }
        else if (component == 3) {
            tView.text = LS_MIN;
        }
    }
    if ([self.modifyingSettingName isEqualToString:LS_STEPS_THRESHOLD]) {
        if (row == 0) {
            tView.text = [NSString stringWithFormat:@"1"];
        }if (row == 200) {
            tView.text = [NSString stringWithFormat:@"999"];
        }
        tView.text = [NSString stringWithFormat:@"%i", row*5];
    }
    return tView;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME]) {
        SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
        if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
            if (component == 0) {
                return [[self arrayOf12Hours] count];
            }
            else if (component == 1){
                return [[self arrayOfMinutes] count];
            }
            else if (component == 2){
                return [[self arrayOfAmPm] count];;
            }
        }
        else{
            if (component == 0) {
                return [[self arrayOf24Hours] count];
            }
            else if (component == 1){
                return [[self arrayOfMinutes] count];
            }
        }
    }
    else if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME_STARTS]) {
        return [[self arrayOfMinutes] count];
    }
    if ([self.modifyingSettingName isEqualToString:LS_EXPOSURE_LEVEL]) {
        return [[self arrayOfLevels] count];
    }
    else if ([self.modifyingSettingName isEqualToString:LS_LIGHT_EXPOSURE_GOAL]) {
        if (component == 0) {
            return [[self arrayOf2Hours] count];
        }
        else if (component == 1){
            return 1;
        }
        else if (component == 2){
            return [[self arrayOfMinutes] count];;
        }
        else if (component == 3) {
            return 1;
        }
        
    }
    else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
        SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
        if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
            if (component == 0) {
                return [[self arrayOf12Hours] count];
            }
            else if (component == 1){
                return [[self arrayOfMinutes] count];
            }
            else if (component == 2){
                return [[self arrayOfAmPm] count];;
            }
            else if (component == 3) {
                return 1;
            }
            else if (component == 4){
                return [[self arrayOf12Hours] count];
            }
            else if (component == 5){
                return [[self arrayOfMinutes] count];
            }
            else if (component == 6){
                return [[self arrayOfAmPm] count];
            }
        }
        else{
            if (component == 0) {
                return [[self arrayOf24Hours] count];
            }
            else if (component == 1){
                return [[self arrayOfMinutes] count];
            }
            else if (component == 2) {
                return 1;
            }
            else if (component == 3){
                return [[self arrayOf24Hours] count];
            }
            else if (component == 4){
                return [[self arrayOfMinutes] count];;
            }
        }
    }
    else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL] && self.modifyingSection == 1) {
        return 116;
    }
    else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL] && self.modifyingSection == 3){
        if (component == 0) {
            return [[self arrayOf4Hours] count];
        }
        else if (component == 2){
            return [[self arrayOfMinutes] count];
        }
        return 1;
    }
    else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
        SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
        if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
            if (component == 0) {
                return [[self arrayOf12Hours] count];
            }
            else if (component == 1){
                return [[self arrayOfMinutes] count];
            }
            else if (component == 2){
                return [[self arrayOfAmPm] count];;
            }
            else if (component == 3) {
                return 1;
            }
            else if (component == 4){
                return [[self arrayOf12Hours] count];
            }
            else if (component == 5){
                return [[self arrayOfMinutes] count];;
            }
            else if (component == 6){
                return [[self arrayOfAmPm] count];
            }
        }
        else{
            if (component == 0) {
                return [[self arrayOf24Hours] count];
            }
            else if (component == 1){
                return [[self arrayOfMinutes] count];
            }
            else if (component == 2) {
                return 1;
            }
            else if (component == 3){
                return [[self arrayOf24Hours] count];
            }
            else if (component == 4){
                return [[self arrayOfMinutes] count];
            }
        }
    }
    if ([self.modifyingSettingName isEqualToString:LS_STEPS_THRESHOLD]) {
        return 201;
    }
    
    return 1;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    switch (self.modifyingSection) {
        case 0:
            if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME]) {
                SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
                if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
                    return 3;
                }
                return 2;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME_STARTS]) {
                return 1;
            }
            break;
        case 1:
            if ([self.modifyingSettingName isEqualToString:LS_EXPOSURE_LEVEL]) {
                return 1;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_LIGHT_EXPOSURE_GOAL]) {
                return 4;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
                SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
                if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
                    return 7;
                }
                return 5;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL]) {
                return 1;
            }
            break;
        case 2:
            if ([self.modifyingSettingName isEqualToString:LS_EXPOSURE_LEVEL]) {
                return 1;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_LIGHT_EXPOSURE_GOAL]) {
                return 4;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
                SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
                if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
                    return 7;
                }
                return 5;
            }
            break;
        case 3:
            if ([self.modifyingSettingName isEqualToString:LS_STEPS_THRESHOLD]) {
                return 1;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
                SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
                if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
                    return 7;
                }
                return 5;

            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL]) {
                return 4;
            }
            break;
        default:
            break;
    }
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    switch (self.modifyingSection) {
        case 0:
            if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME]) {
                if (LANGUAGE_IS_FRENCH) {
                    if ([SFAUserDefaultsManager sharedManager].timeDate.hourFormat == HOUR_FORMAT_12) {
                        if (component == 2) {
                            return 100;
                        }
                    }
                }
                return 50;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME_STARTS]) {
                return self.view.frame.size.width;
            }
            break;
        case 1:
            if ([self.modifyingSettingName isEqualToString:LS_EXPOSURE_LEVEL]) {
                return self.view.frame.size.width;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_LIGHT_EXPOSURE_GOAL]) {
                return 50;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
                if ([SFAUserDefaultsManager sharedManager].timeDate.hourFormat == HOUR_FORMAT_12 && LANGUAGE_IS_FRENCH) {
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        if (component == 2 || component == 6) {
                            return 150;
                        }
                        return 40;
                    }
                    else{
                        if (component == 2 || component == 6) {
                            return 80;
                        }
                        return 20;
                    }
                }
                return 40;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL]) {
                return self.view.frame.size.width;
            }
            break;
        case 2:
            if ([self.modifyingSettingName isEqualToString:LS_EXPOSURE_LEVEL]) {
                return self.view.frame.size.width;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_LIGHT_EXPOSURE_GOAL]) {
                return 50;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
                if ([SFAUserDefaultsManager sharedManager].timeDate.hourFormat == HOUR_FORMAT_12  && LANGUAGE_IS_FRENCH) {
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        if (component == 2 || component == 6) {
                            return 150;
                        }
                        return 40;
                    }
                    else{
                    if (component == 2 || component == 6) {
                        return 80;
                    }
                    return 20;
                    }
                }
                return 40;
            }
            break;
        case 3:
            if ([self.modifyingSettingName isEqualToString:LS_STEPS_THRESHOLD]) {
                return self.view.frame.size.width;
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
                if ([SFAUserDefaultsManager sharedManager].timeDate.hourFormat == HOUR_FORMAT_12 && LANGUAGE_IS_FRENCH) {
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        if (component == 2 || component == 6) {
                            return 150;
                        }
                        return 40;
                    }
                    else{
                    if (component == 2 || component == 6) {
                        return 80;
                    }
                    return 20;
                    }
                }
                return 40;
                
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL]) {
                return 50;
            }
            break;
        default:
            break;
    }
    return 50;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
            if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME]) {
                SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
                if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
                    if (component == 0) {
                        return [[self arrayOf12Hours] objectAtIndex:row];
                    }
                    else if (component == 1){
                        return [[self arrayOfMinutes] objectAtIndex:row];
                    }
                    else if (component == 2){
                        return [[self arrayOfAmPm] objectAtIndex:row];;
                    }
                }
                else{
                    if (component == 0) {
                        return [[self arrayOf24Hours] objectAtIndex:row];
                    }
                    else if (component == 1){
                        return [[self arrayOfMinutes] objectAtIndex:row];
                    }
                }
            }
            else if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME_STARTS]) {
                return [[self arrayOfMinutes] objectAtIndex:row];
            }
            if ([self.modifyingSettingName isEqualToString:LS_EXPOSURE_LEVEL]) {
                return [[self arrayOfLevels] objectAtIndex:row];
            }
            else if ([self.modifyingSettingName isEqualToString:LS_LIGHT_EXPOSURE_GOAL]) {
                if (component == 0) {
                    return [[self arrayOf2Hours] objectAtIndex:row];
                }
                else if (component == 1){
                    return LS_HR;
                }
                else if (component == 2){
                    return [[self arrayOfMinutes] objectAtIndex:row];;
                }
                else if (component == 3) {
                    return LS_MIN;
                }

            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
                SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
                if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
                    if (component == 0) {
                        return [[self arrayOf12Hours] objectAtIndex:row];
                    }
                    else if (component == 1){
                        return [[self arrayOfMinutes] objectAtIndex:row];
                    }
                    else if (component == 2){
                        return [[self arrayOfAmPm] objectAtIndex:row];;
                    }
                    else if (component == 3) {
                        return LS_TO;
                    }
                    else if (component == 4){
                        return [[self arrayOf12Hours] objectAtIndex:row];
                    }
                    else if (component == 5){
                        return [[self arrayOfMinutes] objectAtIndex:row];;
                    }
                    else if (component == 6){
                        return [[self arrayOfAmPm] objectAtIndex:row];
                    }
                }
                else{
                    if (component == 0) {
                        return [[self arrayOf24Hours] objectAtIndex:row];
                    }
                    else if (component == 1){
                        return [[self arrayOfMinutes] objectAtIndex:row];
                    }
                    else if (component == 2) {
                        return LS_TO;
                    }
                    else if (component == 3){
                        return [[self arrayOf24Hours] objectAtIndex:row];
                    }
                    else if (component == 4){
                        return [[self arrayOfMinutes] objectAtIndex:row];;
                    }
                }
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL] && self.modifyingSection == 1) {
                return [NSString stringWithFormat:@"%i", row+5];
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL] && self.modifyingSection == 3) {
                if (component == 0) {
                    return [[self arrayOf4Hours] objectAtIndex:row];
                }
                else if (component == 1){
                    return LS_HR;
                }
                else if (component == 2){
                    return [[self arrayOfMinutes] objectAtIndex:row];;
                }
                else if (component == 3) {
                    return LS_MIN;
                }
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
                SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
                if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
                    if (component == 0) {
                        return [[self arrayOf12Hours] objectAtIndex:row];
                    }
                    else if (component == 1){
                        return [[self arrayOfMinutes] objectAtIndex:row];
                    }
                    else if (component == 2){
                        return [[self arrayOfAmPm] objectAtIndex:row];;
                    }
                    else if (component == 3) {
                        return LS_TO;
                    }
                    else if (component == 4){
                        return [[self arrayOf12Hours] objectAtIndex:row];
                    }
                    else if (component == 5){
                        return [[self arrayOfMinutes] objectAtIndex:row];;
                    }
                    else if (component == 6){
                        return [[self arrayOfAmPm] objectAtIndex:row];
                    }
                }
                else{
                    if (component == 0) {
                        return [[self arrayOf24Hours] objectAtIndex:row];
                    }
                    else if (component == 1){
                        return [[self arrayOfMinutes] objectAtIndex:row];
                    }
                    else if (component == 2) {
                        return LS_TO;
                    }
                    else if (component == 3){
                        return [[self arrayOf24Hours] objectAtIndex:row];
                    }
                    else if (component == 4){
                        return [[self arrayOfMinutes] objectAtIndex:row];;
                    }
                }
            }
            if ([self.modifyingSettingName isEqualToString:LS_STEPS_THRESHOLD]) {
                if (row == 0) {
                    return [NSString stringWithFormat:@"1"];
                }if (row == 200) {
                    return [NSString stringWithFormat:@"999"];
                }
                return [NSString stringWithFormat:@"%i", row*5];
            }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME]) {
        int hour = 9;
        int min  = 0;
        BOOL isPM = NO;
        SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
        hour = self.wakeUpAlert.wakeup_hr;
        min  = self.wakeUpAlert.wakeup_min;
        if (userDefaultsManager.timeDate.hourFormat == _12_HOUR) {
            if (hour >= 12) {
                hour = hour - 12;
                isPM = YES;
            }
        }
        if (component == 0) {
            if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
                hour = [[[self arrayOf12Hours] objectAtIndex:row] intValue];
                hour = (isPM && hour!=12) ? hour + 12 : hour;
                if (!isPM && hour == 12) {
                    hour = hour - 12;
                }
                else if (isPM && hour == 12) {
                    hour = 12;
                }
            }
            else{
                hour = [[[self arrayOf24Hours] objectAtIndex:row] intValue];
            }
        }
        else if (component == 1) {
            min = [[[self arrayOfMinutes] objectAtIndex:row] intValue];
        }
        else if (component == 2) {
            if (row == 1 && hour<12) {
                hour = hour + 12;
            }
            else if (row == 0  && hour>=12) {
                hour = hour - 12;
            }
        }
        
        self.wakeUpAlert.wakeup_min = min;
        self.wakeUpAlert.wakeup_hr = hour;

    }
    else if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME_STARTS]) {
        self.wakeUpAlert.wakeup_window = [[[self arrayOfMinutes] objectAtIndex:row] intValue];
    }
    if ([self.modifyingSettingName isEqualToString:LS_EXPOSURE_LEVEL]) {
        if (self.modifyingSection == 1) {
            self.dayLightAlert.level = row;
        }
        else if(self.modifyingSection == 2)
            self.nightLightAlert.level = row;
    }
    else if ([self.modifyingSettingName isEqualToString:LS_LIGHT_EXPOSURE_GOAL]) {
        if (self.modifyingSection == 1) {
        int hour = self.dayLightAlert.duration/60;
        int min = self.dayLightAlert.duration%60;
        if (component == 0) {
            hour = [[[self arrayOf2Hours] objectAtIndex:row] intValue];
 //           return [[self arrayOf4Hours] objectAtIndex:row];
        }
        else if (component == 1){
  //          return @"hr";
        }
        else if (component == 2){
            min = [[[self arrayOfMinutes] objectAtIndex:row] intValue];
        }
        else if (component == 3) {
      //      return @"min";
        }
            
            self.dayLightAlert.duration = hour*60 + min;
            
            NSInteger total = hour*60 + min;
            int maxMinutes = 120;
            int minMinutes = 10;
            int maxHour = 2;
            if (total > maxMinutes){
                [pickerView selectRow:maxHour inComponent:0 animated:YES];
                [pickerView selectRow:0 inComponent:2 animated:YES];
                self.dayLightAlert.duration = maxMinutes;
            }else if (total < minMinutes){
                [pickerView selectRow:0 inComponent:0 animated:YES];
                [pickerView selectRow:minMinutes inComponent:2 animated:YES];
                self.dayLightAlert.duration = minMinutes;
            }
    }
        else if(self.modifyingSection == 2){
            int hour = self.nightLightAlert.duration/60;
            int min = self.nightLightAlert.duration%60;
            if (component == 0) {
                hour = [[[self arrayOf2Hours] objectAtIndex:row] intValue];
                //           return [[self arrayOf4Hours] objectAtIndex:row];
            }
            else if (component == 1){
                //          return @"hr";
            }
            else if (component == 2){
                min = [[[self arrayOfMinutes] objectAtIndex:row] intValue];
            }
            else if (component == 3) {
                //      return @"min";
            }
            self.nightLightAlert.duration = hour*60 + min;
            
            NSInteger total = hour*60 + min;
            int maxMinutes = 120;
            int minMinutes = 10;
            int maxHour = 2;
            if (total > maxMinutes){
                [pickerView selectRow:maxHour inComponent:0 animated:YES];
                [pickerView selectRow:0 inComponent:2 animated:YES];
                self.nightLightAlert.duration = maxMinutes;
            }else if (total < minMinutes){
                [pickerView selectRow:0 inComponent:0 animated:YES];
                [pickerView selectRow:minMinutes inComponent:2 animated:YES];
                self.nightLightAlert.duration = minMinutes;
            }
        }
        
    }
    else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
        SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
        int startHour;
        int startMin;
        int endHour;
        int endMin;
        if (self.modifyingSection == 1) {
            startHour = self.dayLightAlert.start_hour;
            startMin = self.dayLightAlert.start_min;
            endHour = self.dayLightAlert.end_hour;
            endMin = self.dayLightAlert.end_min;
        }
        else if (self.modifyingSection == 2) {
            startHour = self.nightLightAlert.start_hour;
            startMin = self.nightLightAlert.start_min;
            endHour = self.nightLightAlert.end_hour;
            endMin = self.nightLightAlert.end_min;
        }
        else if (self.modifyingSection == 3) {
            startHour = self.inactiveAlert.start_hour;
            startMin = self.inactiveAlert.start_min;
            endHour = self.inactiveAlert.end_hour;
            endMin = self.inactiveAlert.end_min;
        }
        if (userDefaultsManager.timeDate.hourFormat == HOUR_FORMAT_12) {
            
            if (component == 0) {
                BOOL isPM = NO;
                if (startHour >= 12) {
                    startHour = startHour - 12;
                    isPM = YES;
                }
                startHour = [[[self arrayOf12Hours] objectAtIndex:row] intValue];
                startHour = (isPM && startHour!=12) ? startHour + 12 : startHour;
                if (!isPM && startHour == 12) {
                    startHour = startHour - 12;
                }
                else if (isPM && startHour == 12) {
                    startHour = 12;
                }
            }
            else if (component == 1){
                startMin = [[[self arrayOfMinutes] objectAtIndex:row] intValue];
            }
            else if (component == 2){
                BOOL isPM = NO;
                if (startHour >= 12) {
                    startHour = startHour - 12;
                    isPM = YES;
                }
                if (row == 1 && startHour < 12) {
                    startHour = startHour + 12;
                }
                else if (row == 0  && startHour >= 12) {
                    startHour = startHour - 12;
                }
            }
            else if (component == 3) {
                //       return LS_TO;
            }
            
            else if (component == 4){
                BOOL isPM2 = NO;
                if (endHour >= 12) {
                    endHour = endHour - 12;
                    isPM2 = YES;
                }
                endHour = [[[self arrayOf12Hours] objectAtIndex:row] intValue];
                endHour = (isPM2 && endHour!=12) ? endHour + 12 : endHour;
                if (!isPM2 && endHour == 12) {
                    endHour = endHour - 12;
                }
                else if (isPM2 && endHour == 12) {
                    endHour = 12;
                }

            }
            else if (component == 5){
                endMin = [[[self arrayOfMinutes] objectAtIndex:row] intValue];
            }
            else if (component == 6){BOOL isPM2 = NO;
                if (endHour >= 12) {
                    endHour = endHour - 12;
                    isPM2 = YES;
                }
                if (row == 1  && endHour < 12) {
                    endHour = endHour + 12;
                }
                else if (row == 0  && endHour >= 12) {
                    endHour = endHour - 12;
                }
            }
        }
        else{
            if (component == 0) {
                startHour =  [[[self arrayOf24Hours] objectAtIndex:row] intValue];
            }
            else if (component == 1){
                startMin = [[[self arrayOfMinutes] objectAtIndex:row] intValue];
            }
            else if (component == 2) {
                //        return LS_TO;
            }
            else if (component == 3){
                endHour = [[[self arrayOf24Hours] objectAtIndex:row] intValue];
            }
            else if (component == 4){
                endMin = [[[self arrayOfMinutes] objectAtIndex:row] intValue];
            }
        }
        if (self.modifyingSection == 1) {
            self.dayLightAlert.start_hour = startHour;
            self.dayLightAlert.start_min = startMin;
            self.dayLightAlert.end_hour = endHour;
            self.dayLightAlert.end_min = endMin;
        }
        else if (self.modifyingSection == 2) {
            self.nightLightAlert.start_hour = startHour;
            self.nightLightAlert.start_min = startMin;
            self.nightLightAlert.end_hour = endHour;
            self.nightLightAlert.end_min = endMin;
        }
        else if (self.modifyingSection == 3) {
            self.inactiveAlert.start_hour = startHour;
            self.inactiveAlert.start_min = startMin;
            self.inactiveAlert.end_hour = endHour;
            self.inactiveAlert.end_min = endMin;
        }
    }
    else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL] && self.modifyingSection == 1) {
        self.dayLightAlert.interval = row+5;
    }
    else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL] && self.modifyingSection == 3) {
        int hour = self.inactiveAlert.time_duration/60;
        int min = self.inactiveAlert.time_duration%60;
        if (component == 0) {
            hour = [[[self arrayOf4Hours] objectAtIndex:row] intValue];
            //           return [[self arrayOf4Hours] objectAtIndex:row];
        }
        else if (component == 1){
            //          return @"hr";
        }
        else if (component == 2){
            min = [[[self arrayOfMinutes] objectAtIndex:row] intValue];
        }
        else if (component == 3) {
            //      return @"min";
        }
        self.inactiveAlert.time_duration = hour*60 + min;
    }
    if ([self.modifyingSettingName isEqualToString:LS_STEPS_THRESHOLD]) {
        if (row == 0) {
            self.inactiveAlert.steps_threshold = 1;
        }
        else if (row == 200) {
            self.inactiveAlert.steps_threshold = 999;
        }
        else{
            self.inactiveAlert.steps_threshold = row*5;
        }
    }
    [self.tableView reloadData];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
   // [self hidePickerView];
   // [self.view endEditing:YES];
}


#pragma mark - SFASettingsToggleCellWithDescDelegate
- (void)toggleButtonWithDescValueChanged:(id)sender withValue:(BOOL)isOn andLabelTitle:(NSString *)title andCellTag:(int)cellTag{
    int index = 0;
    self.modifyingSettingName = title;
    if ([title isEqualToString:WATCH_ALARMS_WAKE_UP]) {
        self.wakeUpAlert.wakeup_mode = isOn;
        index = 0;
    }
    else if ([title isEqualToString:WATCH_ALARMS_DAYLIGHT]) {
        self.dayLightAlert.status = isOn;
        index = 1;
    }
    else if ([title isEqualToString:WATCH_ALARMS_NIGHTLIGHT]) {
        self.nightLightAlert.status = isOn;
        index = 2;
    }
    else if ([title isEqualToString:WATCH_ALARMS_INACTIVITY]) {
        self.inactiveAlert.status = isOn;
        index = 3;
    }
    [self showCancelAndSave];
    [self hidePickerView];
    /*
    dispatch_async(dispatch_get_main_queue()
                   , ^{
                       [self.tableView reloadData];
                       
                   });
    
    */
    [self.tableView beginUpdates];
    //[self.tableView reloadData];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didCellSliderValueChanged:(UISlider *)sender withTitleLabel:(NSString *)title andValue:(int)sliderValue{
    self.inactiveAlert.steps_threshold = sliderValue;
    [self showCancelAndSave];
    /*
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];*/
}

#pragma mark - Picker View Methods

- (void)addGenericPickerView{
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(hidePickerView)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor blackColor];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.showsSelectionIndicator = YES;
    [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    
    
    self.genericPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (toolBar.frame.size.height + self.pickerView.frame.size.height), self.view.frame.size.width, toolBar.frame.size.height + self.pickerView.frame.size.height)];
    [self.genericPickerView addSubview:self.pickerView];
    [self.genericPickerView addSubview:toolBar];
    self.genericPickerView.hidden = YES;
    
    [self.view addSubview:self.genericPickerView];
}



- (void)showPickerView
{
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, self.pickerView.frame.size.height-20, 0)];
    
    [self.pickerView reloadAllComponents];
    self.genericPickerView.hidden = NO;
    SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    switch (self.modifyingSection) {
        case 0:
            if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME]) {
                NSString *timeString = [self convertTimestampToStringWithHour:self.wakeUpAlert.wakeup_hr andMinute:self.wakeUpAlert.wakeup_min withTimeDate:userDefaultsManager.timeDate];
                NSString *hour;
                NSString *min;
                NSString *amPm;
                
                if (userDefaultsManager.timeDate.hourFormat == _12_HOUR) {
                    hour = [[timeString componentsSeparatedByString:@":"] objectAtIndex:0];
                    min  = [[[[timeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
                    amPm =[[[[timeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1];
                    amPm =  [amPm uppercaseString];
                    if (([amPm isEqualToString:@"AM"] || [amPm isEqualToString:@"PM"]) && LANGUAGE_IS_FRENCH) {
                        amPm = [amPm isEqualToString:@"AM"] ? LS_AM : LS_PM;
                    }
                    [self.pickerView selectRow:[[self arrayOf12Hours] indexOfObject:hour] inComponent:0 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:1 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfAmPm] indexOfObject:amPm] inComponent:2 animated:NO];
                } else {
                    if (LANGUAGE_IS_FRENCH && [timeString rangeOfString:@"h"].location != NSNotFound) {
                        timeString = [timeString stringByReplacingOccurrencesOfString:@"h" withString:@":"];
                    }
                    hour = [[timeString componentsSeparatedByString:@":"] objectAtIndex:0];;
                    min = [[timeString componentsSeparatedByString:@":"] objectAtIndex:1];
                    [self.pickerView selectRow:[[self arrayOf24Hours] indexOfObject:hour] inComponent:0 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:1 animated:NO];
                }
            }
            else if ([self.modifyingSettingName isEqualToString:LS_WAKEUP_TIME_STARTS]) {
                NSString *wakeUpWindow = [NSString stringWithFormat:@"%02i", self.wakeUpAlert.wakeup_window];
                [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:wakeUpWindow] inComponent:0 animated:NO];
            }
            break;
        case 1:
            if ([self.modifyingSettingName isEqualToString:LS_EXPOSURE_LEVEL]) {
                [self.pickerView selectRow:self.dayLightAlert.level inComponent:0 animated:NO];
            }
            else if ([self.modifyingSettingName isEqualToString:LS_LIGHT_EXPOSURE_GOAL]) {
                [self.pickerView selectRow:self.dayLightAlert.duration/60 inComponent:0 animated:NO];
                [self.pickerView selectRow:self.dayLightAlert.duration%60 inComponent:2 animated:NO];
                
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
                NSString *startTimeString = [self convertTimestampToStringWithHour:self.dayLightAlert.start_hour andMinute:self.dayLightAlert.start_min withTimeDate:userDefaultsManager.timeDate];
                NSString *endTimeString = [self convertTimestampToStringWithHour:self.dayLightAlert.end_hour andMinute:self.dayLightAlert.end_min withTimeDate:userDefaultsManager.timeDate];
                NSString *hour;
                NSString *min;
                NSString *amPm;
                if (userDefaultsManager.timeDate.hourFormat == _12_HOUR) {
                    hour = [[startTimeString componentsSeparatedByString:@":"] objectAtIndex:0];
                    min  = [[[[startTimeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
                    amPm =[[[[startTimeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1];
                    amPm =  [amPm uppercaseString];
                    [self.pickerView selectRow:[[self arrayOf12Hours] indexOfObject:hour] inComponent:0 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:1 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfAmPm] indexOfObject:amPm] inComponent:2 animated:NO];
                    
                    hour = [[endTimeString componentsSeparatedByString:@":"] objectAtIndex:0];
                    min  = [[[[endTimeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
                    amPm =[[[[endTimeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1];
                    amPm =  [amPm uppercaseString];
                    [self.pickerView selectRow:[[self arrayOf12Hours] indexOfObject:hour] inComponent:4 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:5 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfAmPm] indexOfObject:amPm] inComponent:6 animated:NO];
                    
                } else {
                    if (LANGUAGE_IS_FRENCH && [startTimeString rangeOfString:@"h"].location != NSNotFound) {
                        startTimeString = [startTimeString stringByReplacingOccurrencesOfString:@"h" withString:@":"];
                    }
                    hour = [[startTimeString componentsSeparatedByString:@":"] objectAtIndex:0];;
                    min = [[startTimeString componentsSeparatedByString:@":"] objectAtIndex:1];
                    [self.pickerView selectRow:[[self arrayOf24Hours] indexOfObject:hour] inComponent:0 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:1 animated:NO];
                    
                    if (LANGUAGE_IS_FRENCH && [endTimeString rangeOfString:@"h"].location != NSNotFound) {
                        endTimeString = [endTimeString stringByReplacingOccurrencesOfString:@"h" withString:@":"];
                    }
                    hour = [[endTimeString componentsSeparatedByString:@":"] objectAtIndex:0];
                    min = [[endTimeString componentsSeparatedByString:@":"] objectAtIndex:1];
                    [self.pickerView selectRow:[[self arrayOf24Hours] indexOfObject:hour] inComponent:3 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:4 animated:NO];
                }

            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL]) {
                [self.pickerView selectRow:self.dayLightAlert.interval-5 inComponent:0 animated:NO];
            }
            break;
        case 2:
            if ([self.modifyingSettingName isEqualToString:LS_EXPOSURE_LEVEL]) {
                [self.pickerView selectRow:self.nightLightAlert.level inComponent:0 animated:NO];
            }
            else if ([self.modifyingSettingName isEqualToString:LS_LIGHT_EXPOSURE_GOAL]) {
                [self.pickerView selectRow:self.nightLightAlert.duration/60 inComponent:0 animated:NO];
                [self.pickerView selectRow:self.nightLightAlert.duration%60 inComponent:2 animated:NO];
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
                NSString *startTimeString = [self convertTimestampToStringWithHour:self.nightLightAlert.start_hour andMinute:self.nightLightAlert.start_min withTimeDate:userDefaultsManager.timeDate];
                NSString *endTimeString = [self convertTimestampToStringWithHour:self.nightLightAlert.end_hour andMinute:self.nightLightAlert.end_min withTimeDate:userDefaultsManager.timeDate];
                NSString *hour;
                NSString *min;
                NSString *amPm;
                if (userDefaultsManager.timeDate.hourFormat == _12_HOUR) {
                    hour = [[startTimeString componentsSeparatedByString:@":"] objectAtIndex:0];
                    min  = [[[[startTimeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
                    amPm =[[[[startTimeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1];
                    amPm =  [amPm uppercaseString];
                    [self.pickerView selectRow:[[self arrayOf12Hours] indexOfObject:hour] inComponent:0 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:1 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfAmPm] indexOfObject:amPm] inComponent:2 animated:NO];
                    
                    hour = [[endTimeString componentsSeparatedByString:@":"] objectAtIndex:0];
                    min  = [[[[endTimeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
                    amPm =[[[[endTimeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1];
                    amPm =  [amPm uppercaseString];
                    [self.pickerView selectRow:[[self arrayOf12Hours] indexOfObject:hour] inComponent:4 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:5 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfAmPm] indexOfObject:amPm] inComponent:6 animated:NO];
                    
                } else {
                    if (LANGUAGE_IS_FRENCH && [startTimeString rangeOfString:@"h"].location != NSNotFound) {
                        startTimeString = [startTimeString stringByReplacingOccurrencesOfString:@"h" withString:@":"];
                    }
                    hour = [[startTimeString componentsSeparatedByString:@":"] objectAtIndex:0];;
                    min = [[startTimeString componentsSeparatedByString:@":"] objectAtIndex:1];
                    [self.pickerView selectRow:[[self arrayOf24Hours] indexOfObject:hour] inComponent:0 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:1 animated:NO];
                    
                    if (LANGUAGE_IS_FRENCH && [endTimeString rangeOfString:@"h"].location != NSNotFound) {
                        endTimeString = [endTimeString stringByReplacingOccurrencesOfString:@"h" withString:@":"];
                    }
                    hour = [[endTimeString componentsSeparatedByString:@":"] objectAtIndex:0];
                    min = [[endTimeString componentsSeparatedByString:@":"] objectAtIndex:1];
                    [self.pickerView selectRow:[[self arrayOf24Hours] indexOfObject:hour] inComponent:3 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:4 animated:NO];
                }

            }
            break;
        case 3:
            if ([self.modifyingSettingName isEqualToString:LS_STEPS_THRESHOLD]) {
                if (self.inactiveAlert.steps_threshold == 1) {
                    [self.pickerView selectRow:0 inComponent:0 animated:NO];
                }
                else if(self.inactiveAlert.steps_threshold == 999){
                    [self.pickerView selectRow:200 inComponent:0 animated:NO];
                }
                else{
                    [self.pickerView selectRow:self.inactiveAlert.steps_threshold/5 inComponent:0 animated:NO];
                }
            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_WINDOW]) {
                NSString *startTimeString = [self convertTimestampToStringWithHour:self.inactiveAlert.start_hour andMinute:self.inactiveAlert.start_min withTimeDate:userDefaultsManager.timeDate];
                NSString *endTimeString = [self convertTimestampToStringWithHour:self.inactiveAlert.end_hour andMinute:self.inactiveAlert.end_min withTimeDate:userDefaultsManager.timeDate];
                NSString *hour;
                NSString *min;
                NSString *amPm;
                if (userDefaultsManager.timeDate.hourFormat == _12_HOUR) {
                    hour = [[startTimeString componentsSeparatedByString:@":"] objectAtIndex:0];
                    min  = [[[[startTimeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
                    amPm =[[[[startTimeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1];
                    amPm =  [amPm uppercaseString];
                    [self.pickerView selectRow:[[self arrayOf12Hours] indexOfObject:hour] inComponent:0 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:1 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfAmPm] indexOfObject:amPm] inComponent:2 animated:NO];
                    
                    hour = [[endTimeString componentsSeparatedByString:@":"] objectAtIndex:0];
                    min  = [[[[endTimeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
                    amPm =[[[[endTimeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1];
                    amPm =  [amPm uppercaseString];
                    [self.pickerView selectRow:[[self arrayOf12Hours] indexOfObject:hour] inComponent:4 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:5 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfAmPm] indexOfObject:amPm] inComponent:6 animated:NO];
                    
                } else {
                    if (LANGUAGE_IS_FRENCH && [startTimeString rangeOfString:@"h"].location != NSNotFound) {
                        startTimeString = [startTimeString stringByReplacingOccurrencesOfString:@"h" withString:@":"];
                    }
                    hour = [[startTimeString componentsSeparatedByString:@":"] objectAtIndex:0];;
                    min = [[startTimeString componentsSeparatedByString:@":"] objectAtIndex:1];
                    [self.pickerView selectRow:[[self arrayOf24Hours] indexOfObject:hour] inComponent:0 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:1 animated:NO];
                    
                    if (LANGUAGE_IS_FRENCH && [endTimeString rangeOfString:@"h"].location != NSNotFound) {
                        endTimeString = [endTimeString stringByReplacingOccurrencesOfString:@"h" withString:@":"];
                    }
                    hour = [[endTimeString componentsSeparatedByString:@":"] objectAtIndex:0];
                    min = [[endTimeString componentsSeparatedByString:@":"] objectAtIndex:1];
                    [self.pickerView selectRow:[[self arrayOf24Hours] indexOfObject:hour] inComponent:3 animated:NO];
                    [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:4 animated:NO];
                }

            }
            else if ([self.modifyingSettingName isEqualToString:LS_ALERT_INTERVAL]) {
                
                [self.pickerView selectRow:self.inactiveAlert.time_duration/60 inComponent:0 animated:NO];
                [self.pickerView selectRow:self.inactiveAlert.time_duration%60 inComponent:2 animated:NO];
            }
            break;
        default:
            break;
    }
}

- (void)hidePickerView{
    self.genericPickerView.hidden = YES;
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)showCancelAndSave{
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChanges)];//[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    //self.saveButton.hidden = NO;
    UIBarButtonItem *newBackButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSettings)];//[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.rightBarButtonItem = newBackButton2;
    
}

- (void)hideCancelAndSave{
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    //[newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    /*UIBarButtonItem *newBackButton2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SyncNavigation"] style:UIBarButtonItemStyleBordered target:self action:@selector(syncButtonPressed:)];
     [newBackButton2 setImageInsets:UIEdgeInsetsMake(0, -15, 0, 15)];
     */
    self.navigationItem.rightBarButtonItem = nil;
    [self hidePickerView];
}

- (void)cancelChanges{
    [self getCurrentSettings];
    [self hidePickerView];
    [self hideCancelAndSave];
    [self.tableView reloadData];
}

- (void)saveSettings{
    
    if ([self validateDayLightAlert] && [self validateNightLightAlert] && [self validateInactiveAlert]) {
        [SFAUserDefaultsManager sharedManager].wakeUp           = self.wakeUpAlert;
        [SFAUserDefaultsManager sharedManager].dayLightAlert    = self.dayLightAlert;
        [SFAUserDefaultsManager sharedManager].nightLightAlert  = self.nightLightAlert;
        [SFAUserDefaultsManager sharedManager].inactiveAlert    = self.inactiveAlert;
        DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
        [WakeupEntity wakeupWithWakeup:self.wakeUpAlert forDeviceEntity:deviceEntity];
        [DayLightAlertEntity dayLightAlertWithDayLightAlert:self.dayLightAlert forDeviceEntity:deviceEntity];
        [NightLightAlertEntity nightLightAlertWithNightLightAlert:self.nightLightAlert forDeviceEntity:deviceEntity];
        [InactiveAlertEntity inactiveAlertWithInactiveAlert:self.inactiveAlert forDeviceEntity:deviceEntity];
        [self hidePickerView];
        [self hideCancelAndSave];
    }
}

#pragma mark - Alarm Data Validators

- (BOOL)validateDayLightAlert{
    NSInteger startTime = self.dayLightAlert.start_hour*60 + self.dayLightAlert.start_min;
    NSInteger endTime = self.dayLightAlert.end_hour*60 + self.dayLightAlert.end_min;
    NSInteger startTimeEndTimeDifference = endTime - startTime;
    NSInteger timeDuration = self.dayLightAlert.duration;
    
    if (!self.dayLightAlert.status){
        return YES;
    }
    
    if (endTime <startTime){
        [self showAlertWithTitle:WATCH_ALARMS_DAYLIGHT andDescription:LS_END_TIME_WARNING];
        return NO;
    }
    
    if (endTime == startTime){
        [self showAlertWithTitle:WATCH_ALARMS_DAYLIGHT andDescription:LS_START_TIME_WARNING];
        return NO;
    }
    
    if (startTimeEndTimeDifference < 30){
        [self showAlertWithTitle:WATCH_ALARMS_DAYLIGHT andDescription:LS_INTERVAL_TIME_WARNING];
        return NO;
    }
    
    if (startTimeEndTimeDifference < timeDuration){
        [self showAlertWithTitle:WATCH_ALARMS_DAYLIGHT andDescription:LS_EXPOSURE_DURATION_WARNING];
        return NO;
    }
    
    //check if daylight alert settings start and end time overlaps with nightlight alert start and end time
    NSInteger nightLightStartTime = self.nightLightAlert.start_hour*60 + self.nightLightAlert.start_min;
    if (nightLightStartTime <= endTime && self.nightLightAlert.status == 1){
        [self showAlertWithTitle:WATCH_ALARMS_DAYLIGHT andDescription:LS_OVERLAP_WARNING];
        return NO;
    }
    return YES;
}

- (BOOL)validateNightLightAlert{
    NSInteger startTime = self.nightLightAlert.start_hour*60 + self.nightLightAlert.start_min;
    NSInteger endTime = self.nightLightAlert.end_hour*60 + self.nightLightAlert.end_min;
    NSInteger startTimeEndTimeDifference = endTime - startTime;
    NSInteger timeDuration = self.nightLightAlert.duration;
    
    if (!self.nightLightAlert.status){
        return YES;
    }
    
    if (endTime <startTime){
        [self showAlertWithTitle:WATCH_ALARMS_NIGHTLIGHT andDescription:LS_END_TIME_WARNING];
        return NO;
    }
    
    if (endTime == startTime){
        [self showAlertWithTitle:WATCH_ALARMS_NIGHTLIGHT andDescription:LS_START_TIME_WARNING];
        return NO;
    }
    
    if (startTimeEndTimeDifference < 30){
        [self showAlertWithTitle:WATCH_ALARMS_NIGHTLIGHT andDescription:LS_INTERVAL_TIME_WARNING];
        return NO;
    }
    
    if (startTimeEndTimeDifference < timeDuration){
        [self showAlertWithTitle:WATCH_ALARMS_NIGHTLIGHT andDescription:LS_EXPOSURE_DURATION_WARNING];
        return NO;
    }
    
    //check if daylight alert settings start and end time overlaps with nightlight alert start and end time
    NSInteger dayLightAlertEndTime = self.dayLightAlert.end_hour*60 + self.dayLightAlert.end_min;
    if (startTime <= dayLightAlertEndTime && self.dayLightAlert.status == 1){
        [self showAlertWithTitle:WATCH_ALARMS_NIGHTLIGHT andDescription:LS_OVERLAP_WARNING];
        return NO;
    }
    return YES;
}

- (BOOL)validateInactiveAlert{
    NSInteger startTime = self.inactiveAlert.start_hour*60 + self.inactiveAlert.start_min;
    NSInteger endTime = self.inactiveAlert.end_hour*60 + self.inactiveAlert.end_min;
    NSInteger startTimeEndTimeDifference = endTime - startTime;
    NSInteger timeDuration = self.inactiveAlert.time_duration;
    
    
    if (!self.inactiveAlert.status){
        return YES;
    }
    
    if (endTime < startTime){
        [self showAlertWithTitle:WATCH_ALARMS_INACTIVITY andDescription:LS_END_TIME_WARNING];
        return NO;
    }
    
    if (endTime == startTime){
        [self showAlertWithTitle:WATCH_ALARMS_INACTIVITY andDescription:LS_START_TIME_WARNING];
        return NO;
    }
    
    if ( !(startTimeEndTimeDifference >= 30)){
        [self showAlertWithTitle:WATCH_ALARMS_INACTIVITY andDescription:LS_INTERVAL_TIME_WARNING];
        return NO;
    }
    
    if (startTimeEndTimeDifference < timeDuration){
        [self showAlertWithTitle:WATCH_ALARMS_INACTIVITY andDescription:LS_EXPOSURE_DURATION_WARNING];
        return NO;
    }
    return YES;
}
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Array of PickerView Titles

- (NSArray *)arrayOfMinutes{
    return @[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09",
             @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19",
             @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29",
             @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39",
             @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49",
             @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59"];
}

- (NSArray *)arrayOf12Hours{
    return @[@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12"];
}

- (NSArray *)arrayOf4Hours{
    return @[@"00", @"01", @"02", @"03", @"04"];
}

- (NSArray *)arrayOf2Hours{
    return @[@"00", @"01", @"02"];
}


- (NSArray *)arrayOf24Hours{
    return @[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10",
             @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20",
             @"21", @"22", @"23"];
}

- (NSArray *)arrayOfAmPm{
    return @[LS_AM, LS_PM];
}

- (NSArray *)arrayOfLevels{
    return @[LS_LOW, LS_MEDIUM, LS_HIGH];
}

- (NSString *)convertTimestampToStringWithHour:(int)hour andMinute:(int)minute withTimeDate:(TimeDate *)timeDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.hour = hour;
    dateComponents.minute = minute;

    NSDate *date = [calendar dateFromComponents:dateComponents];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //TimeDate *timeDate = [TimeDate getData];
    
    if (timeDate.hourFormat == _12_HOUR) {
        [dateFormatter setDateFormat:@"hh:mm a"];
    } else {
        [dateFormatter setDateFormat:@"HH:mm"];
    }

    if ([dateFormatter stringFromDate:date]) {
        
        NSString *finalDateString = [dateFormatter stringFromDate:date];
        NSString *timeString = finalDateString;
        if(timeDate.hourFormat == _12_HOUR){
            NSString *time = [[finalDateString componentsSeparatedByString:@" "] objectAtIndex:0];
            if(hour > 11){
                timeString = [NSString stringWithFormat:@"%@ %@", time, LS_PM];
            }
            else{
                timeString = [NSString stringWithFormat:@"%@ %@", time, LS_AM];
            }
        }
        finalDateString = timeString;
        
        if (timeDate.hourFormat == _24_HOUR && LANGUAGE_IS_FRENCH) {
            finalDateString = [finalDateString stringByReplacingOccurrencesOfString:@":" withString:@"h"];
        }
        
        finalDateString = [[finalDateString stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
        return finalDateString;
    }
    return nil;
}


- (NSString *)convertTimestampToString:(NSNumber *)timestamp withTimeDate:(TimeDate *)timeDate andAutoSyncDay:(NSString *)autoSyncDay
{
    NSTimeInterval interval = [timestamp doubleValue];
    NSDate *date = [NSDate date];
    date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //TimeDate *timeDate = [TimeDate getData];
    
    if (timeDate.hourFormat == _12_HOUR) {
        [dateFormatter setDateFormat:@"hh:mm a"];
    } else {
        [dateFormatter setDateFormat:@"HH:mm"];
    }
    
    if (!timestamp) {
        return nil;
    }
    else if ([dateFormatter stringFromDate:date]) {
        
        NSString *finalDateString = [dateFormatter stringFromDate:date];
        
        if (LANGUAGE_IS_FRENCH && timeDate.hourFormat == _24_HOUR) {
            finalDateString = [finalDateString stringByReplacingOccurrencesOfString:@":" withString:@"h"];
        }
        
        finalDateString = [[finalDateString stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
        
        if (autoSyncDay) {
            finalDateString = [NSString stringWithFormat:@"%@, %@", autoSyncDay, finalDateString];
        }
        return finalDateString;
    }
    return nil;
}


- (void)showAlertWithTitle:(NSString *)errorTitle andDescription:(NSString *)errorDescription{
    if (self.isIOS8AndAbove) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:errorTitle
                                                                                 message:errorDescription
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
        [[[UIAlertView alloc] initWithTitle:errorTitle message:errorDescription delegate:nil cancelButtonTitle:BUTTON_TITLE_OK_NORMAL otherButtonTitles:nil] show];
    }

}



@end
