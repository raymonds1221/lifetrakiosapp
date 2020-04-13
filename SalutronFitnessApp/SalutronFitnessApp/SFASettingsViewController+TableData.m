//
//  SFASettingsViewController+TableData.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 5/22/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASettingsViewController+TableData.h"

#import "SFAWatchSettingsWatchCell.h"
#import "SFAWatchSettingsWatchNameCell.h"
#import "SFAWatchSettingsBatteryLevelCell.h"
#import "SFAAutoSyncCell.h"
#import "SFAProfileCell.h"
#import "SFAProfileGenderCell.h"
#import "SFASettingsPromptCell.h"
#import "SFASyncOptionCell.h"
#import "SFAWatchManager.h"
#import "SFAHealthKitManager.h"
#import "Constants.h"

#import "SFASettingsToggleCellWithDesc.h"
#import "SFASettingsCellWithDescription.h"
#import "SFASettingsToggleCell.h"
#import "SFASettingsCell.h"
#import "SFASettingsCellWithButton.h"
#import "SFASettingsIndentedToggleCell.h"
#import "SFASettingsIndentedCellWithButton.h"
#import "SFASettingsCellWithSyncButton.h"

#define WATCH_CELL              @"SFAWatchSettingsWatchCell"
#define WATCH_NAME_CELL         @"SFAWatchSettingsWatchNameCell"
#define BATTERY_LEVEL_CELL      @"SFAWatchSettingsBatteryLevelCell"
#define DISCONNECT_WATCH_CELL   @"SFAWatchSettingsDisconnectWatchCell"
#define NOTIFICATIONS_CELL      @"SFAWatchSettingsNotificationCell"
#define HEALTHAPP_CELL          @"SFAWatchSettingsHealthAppCell"
#define PROFILE_CELL            @"SFAProfileCell"
#define GENDER_CELL             @"SFAProfileGenderCell"
#define PREFERENCE_CELL         @"SFAPreferenceCell"
#define DATE_PREFERENCE_CELL    @"SFAProfileDateCell"
#define AUTO_SYNC_CELL          @"SFAWatchSettingsAutoSyncCell"
#define AUTO_SYNC_ALERT_CELL    @"SFAWatchSettingsAutoSyncAlertCell"
#define AUTO_SYNC_OPTION_CELL   @"SFAWatchSettingsAutoSyncOptionCell"
#define CALIBRATION_CELL        @"SFAWatchSettingsCalibrationCell"
#define ALARM_SETTINGS_CELL     @"SFAWatchSettingsAlarmSettingsCell"
#define SETTINGS_PROMPT_CELL    @"SFASettingsPromptCell"
#define AUTO_SYNC_TIME_CELL     @"SFAWatchSettingsAutoSyncTime"

#define SETTING_TOGGLE_CELL_WITH_DESC        @"SFASettingsToggleCellWithDesc"
#define SETTING_CELL_WITH_DESCRIPTION        @"SFASettingsCellWithDescription"
#define SETTING_TOGGLE_CELL                  @"SFASettingsToggleCell"
#define SETTING_CELL                         @"SFASettingsCell"
#define SETTING_CELL_WITH_BUTTON             @"SFASettingsCellWithButton"
#define SETTING_CELL_WITH_SYNC_BUTTON        @"SFASettingsCellWithSyncButton"
#define SETTING_INDENTED_TOGGLE_CELL         @"SFASettingsIndentedToggleCell"
#define SETTING_INDENTED_CELL_WITH_BUTTON    @"SFASettingsIndentedCellWithButton"
#define WATCH_CELL                           @"SFAWatchSettingsWatchCell"

#define HOUR_FORMAT_12                       0
#define HOUR_FORMAT_24                       1

#define HIDE_AUTO_EL                         1



static CGFloat  const DEFAULT_CELL_HEIGHT = 44.0f;
static CGFloat  const DEFAULT_SECTION_HEIGHT = 45.0f;
static CGFloat  const ZERO_CELL_HEIGHT = 0.1f;
static CGFloat  const ZERO_SECTION_HEIGHT = 0.1f;

@implementation SFASettingsViewController (TableData)

- (NSUInteger)numberOfRowsInSection:(NSUInteger)section watchModel:(WatchModel)watchModel
{
    switch (section) {
        case 0:
            if (watchModel == WatchModel_Move_C300 || watchModel == WatchModel_Move_C300_Android) {
                return 1;
            }
            else if (watchModel == WatchModel_R450){
                return 4;
            }
            return 1;
            break;
        case 1:
            if (watchModel == WatchModel_Move_C300 ||
                watchModel == WatchModel_Move_C300_Android) {
                return 7;
            }
            else if (watchModel == WatchModel_Zone_C410 ||
                     watchModel == WatchModel_R420){
                //if (HIDE_AUTO_EL) {
                //    return 8;
                //}
                return 9;
            }
            else if (watchModel == WatchModel_R450){
                //if (HIDE_AUTO_EL) {
                //    return 11;
                //}
                return 12;
            }
            break;
        case 2:
            return 2;
            break;
        case 3:
            return 3;
            break;
        /*
        case 0:
            if (watchModel == WatchModel_Zone_C410) {
                return 2;
            }
            else if (watchModel == WatchModel_Move_C300 || watchModel == WatchModel_Move_C300_Android){
                return 1;
            }
            else if (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) {
                if ([[self.userDefaults objectForKey:AUTO_SYNC_ALERT] boolValue]) {
//                    return 5;
                    return 3;//4;
                } else {
                    return 1;
                }
            }
            return 0;
            break;
        case 2:
            return (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) ? 3: 0;
            break;
            
        case 3:
            return (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) ? 4: 3;
            break;
            
        case 4:
            return 1;
            break;
            
        case 5:
            if (watchModel != WatchModel_R450 && watchModel != WatchModel_R500) {
                return ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) ? 1: 0;
            }
            else{
                return (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) ? 1: 0;
            }
            break;
            
        case 6:
            return 1;
            break;
        */
        default:
            return 0;
            break;
    }
    return 0;
}

- (CGFloat)heightForHeaderInSection:(NSUInteger)section watchModel:(WatchModel)watchModel
{
    switch (section) {
        case 0:
            return DEFAULT_SECTION_HEIGHT;
            break;
        case 1:
            return DEFAULT_SECTION_HEIGHT;
            break;
        case 2:
            return DEFAULT_SECTION_HEIGHT;
            break;
        case 3:
            return DEFAULT_SECTION_HEIGHT;
            break;
            
        default:
            return ZERO_SECTION_HEIGHT;
            break;
    }

}

- (CGFloat)heightForFooterInSection:(NSInteger)section watchModel:(WatchModel)watchModel
{
    switch (section) {
        /*
        case 5:
            if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable] && (watchModel != WatchModel_R450 && watchModel != WatchModel_R500)) {
                return ZERO_SECTION_HEIGHT;
            }
            return DEFAULT_SECTION_HEIGHT/2;
            break;
        */
        case 2: return DEFAULT_CELL_HEIGHT/2;
        default:
            return ZERO_SECTION_HEIGHT;
            break;
    }
}

- (NSString *)titleForHeaderInSection:(NSUInteger)section watchModel:(WatchModel)watchModel
{
    switch (section) {
        case 0:
            return SECTION_APP_SETTINGS;
            break;
            
        case 1:
            return SECTION_WATCH_SETTINGS;
            break;
            
        case 2:
            return SECTION_CLOUD_SETTINGS;
            break;
            
        case 3:
            return SECTION_WORKOUT_SETTINGS;
            break;
            
        default:
            return SECTION_BLANK;
            break;
    }
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath watchModel:(WatchModel)watchModel
{
    float heightMuntiplier = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 1.50f : 2.0f;
    switch (indexPath.section) {
        case 0:
            if (watchModel == WatchModel_R450) {
                if (indexPath.row == 0) {
                    return DEFAULT_CELL_HEIGHT;
                }
                if (self.autoSyncReminder) {
                    if (indexPath.row == 1 || indexPath.row == 2) {
                        return DEFAULT_CELL_HEIGHT;
                    }
                }
                else{
                    if (indexPath.row == 1 || indexPath.row == 2) {
                        return 0;
                    }
                }
            }
            return DEFAULT_CELL_HEIGHT*heightMuntiplier;
            break;
        case 1:
            if (watchModel == WatchModel_R450) {
                if (indexPath.row == 0){
                    return DEFAULT_CELL_HEIGHT*2;
                }
                if (indexPath.row == 9 || indexPath.row == 10) {
                    return DEFAULT_CELL_HEIGHT*heightMuntiplier;
                }
                if (indexPath.row == 7 && HIDE_AUTO_EL) {
                    return ZERO_CELL_HEIGHT;
                }
                return DEFAULT_CELL_HEIGHT;
            }
            else if (watchModel == WatchModel_Zone_C410 ||
                     watchModel == WatchModel_R420 ||
                     watchModel == WatchModel_Move_C300 ||
                     watchModel == WatchModel_Move_C300_Android){
                if (indexPath.row == 0) {
                    return DEFAULT_CELL_HEIGHT*2;
                }
                if ((watchModel == WatchModel_Zone_C410
                     || watchModel == WatchModel_R420) &&
                    (indexPath.row == 6 && HIDE_AUTO_EL)) {
                    return ZERO_CELL_HEIGHT;
                }
                if ((watchModel == WatchModel_Zone_C410
                     || watchModel == WatchModel_R420) &&
                    indexPath.row == 7) {
                    return DEFAULT_CELL_HEIGHT*heightMuntiplier;
                }
                return DEFAULT_CELL_HEIGHT;
            }
            return ZERO_CELL_HEIGHT;
            break;
        case 2:
            if (indexPath.row == 1) {
            if (self.enableSyncToCloud) {
                    return DEFAULT_CELL_HEIGHT;
                }
                else{
                    return ZERO_CELL_HEIGHT;
                }
            }
            return DEFAULT_CELL_HEIGHT;
            break;
            /*
            if (watchModel == WatchModel_Zone_C410) {
                return DEFAULT_CELL_HEIGHT;
            }
            else if (watchModel == WatchModel_Move_C300 || watchModel == WatchModel_Move_C300_Android){
                return DEFAULT_CELL_HEIGHT;
            }
            else if (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) {
                
                SyncSetupOption syncSetupOption = [[self.userDefaults objectForKey:AUTO_SYNC_OPTION] intValue];
                
                if (indexPath.row == 1) {
                    return DEFAULT_CELL_HEIGHT;
                }
                else if (indexPath.row == 2) {
                    if (syncSetupOption == SyncSetupOptionOnceAWeek){//SyncSetupOptionTwice) {
                        return DEFAULT_CELL_HEIGHT * 2;
                    }
                    else {
                        return DEFAULT_CELL_HEIGHT;
                    }
                }
                else if (indexPath.row == 3) {
                    if (syncSetupOption == SyncSetupOptionFourTimes) {
                        return DEFAULT_CELL_HEIGHT * 4;
                    }
                    else {
                        return DEFAULT_CELL_HEIGHT;
                    }
                }
                else {
                   return DEFAULT_CELL_HEIGHT;
                }
            }
            return ZERO_CELL_HEIGHT;
            break;
            
        case 2:
            return (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) ? DEFAULT_CELL_HEIGHT: ZERO_CELL_HEIGHT;
            break;
            
        case 3:
        case 4:
            return DEFAULT_CELL_HEIGHT;
            break;
            
        case 5:
            if ((watchModel == WatchModel_Core_C200 || watchModel == WatchModel_Move_C300 || watchModel == WatchModel_Move_C300_Android)) {
                return ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) ? DEFAULT_CELL_HEIGHT: ZERO_CELL_HEIGHT;
            }
            else{
                return (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) ? DEFAULT_CELL_HEIGHT: ZERO_CELL_HEIGHT;
            }
            break;
            
        case 6:
            return ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) ? DEFAULT_CELL_HEIGHT: ZERO_CELL_HEIGHT;
            break;
        */
        case 3:
            return DEFAULT_CELL_HEIGHT;
            break;
        default:
            return ZERO_CELL_HEIGHT;
            break;
    }
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath watchModel:(WatchModel)watchModel
{
    switch (indexPath.section) {
        case 0:
            if (watchModel == WatchModel_R450) {
                if (indexPath.row == 0) {
                    SFASettingsToggleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_TOGGLE_CELL];
                    cell.labelTitle.text = SETTINGS_SYNC_REMINDER;
                    [cell.toggleButton setOn:self.autoSyncReminder];
                    cell.delegate = self;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = (indexPath.section*100)+indexPath.row;
                    return cell;
                }
                if (indexPath.row == 1) {
                    SFASettingsIndentedCellWithButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_INDENTED_CELL_WITH_BUTTON];
                    cell.cellButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                    cell.lableTitle.text = SETTINGS_ONCE_A_DAY;
                    cell.cellButton.hidden = YES;
                    if (!self.autoSyncTime) {
                        self.autoSyncTime = [self timeIntervalFromHour:@"9" min:@"00" andAmPm:@"AM"];
                    }
                    [cell setAutoSyncTimeWithTimeData:self.timeDate autoSyncOption:SyncSetupOptionOnce autoSyncTime:self.autoSyncTime andAutoSyncDay:self.autoSyncDay];
                    cell.onOffButton.selected = NO;
                    if(self.autoSyncSetupOption == SyncSetupOptionOff){
                        if (self.autoSyncReminder) {
                            self.autoSyncSetupOption = SyncSetupOptionOnce;
                        }
                    }
                    if (self.autoSyncSetupOption == SyncSetupOptionOnce) {
                        cell.onOffButton.selected = YES;
                        cell.cellButton.hidden = NO;
                    }
                    cell.hidden = NO;
                    if (!self.autoSyncReminder) {
                        cell.hidden = YES;
                    }
                    cell.delegate = self;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = (indexPath.section*100)+indexPath.row;
                    return cell;
                }
                if (indexPath.row == 2) {
                    SFASettingsIndentedCellWithButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_INDENTED_CELL_WITH_BUTTON];
                    cell.cellButton.titleLabel.adjustsFontSizeToFitWidth = YES;
                    if (!self.autoSyncTime) {
                        self.autoSyncTime = [self timeIntervalFromHour:@"9" min:@"00" andAmPm:@"AM"];
                    }
                    if (!self.autoSyncDay) {
                        self.autoSyncDay = LS_MON;
                    }
                    cell.lableTitle.text = SETTINGS_ONCE_A_WEEK;
                    cell.cellButton.hidden = YES;
                    [cell setAutoSyncTimeWithTimeData:self.timeDate autoSyncOption:SyncSetupOptionOnceAWeek autoSyncTime:self.autoSyncTime andAutoSyncDay:self.autoSyncDay];
                    cell.onOffButton.selected = NO;
                    if (self.autoSyncSetupOption == SyncSetupOptionOnceAWeek) {
                        cell.cellButton.hidden = NO;
                        cell.onOffButton.selected = YES;
                    }
                    cell.delegate = self;
                    cell.hidden = NO;
                    if (!self.autoSyncReminder) {
                        cell.hidden = YES;
                    }
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = (indexPath.section*100)+indexPath.row;
                    return cell;
                }
                if (indexPath.row == 3) {
                    SFASettingsToggleCellWithDesc *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_TOGGLE_CELL_WITH_DESC];
                    cell.labelTitle.text = SETTINGS_PROMPT_TITLE;
                    cell.labelDescription.text = SETTINGS_PROMPT_DESC;
                    [cell.toggleButton setOn:self.promptChangeSettings];
                    cell.delegate = self;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = (indexPath.section*100)+indexPath.row;
                    return cell;
                }
            }
            else{
                if (indexPath.row == 0) {
                    SFASettingsToggleCellWithDesc *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_TOGGLE_CELL_WITH_DESC];
                    cell.labelTitle.text = SETTINGS_PROMPT_TITLE;
                    cell.labelDescription.text = SETTINGS_PROMPT_DESC;
                    [cell.toggleButton setOn:self.promptChangeSettings];
                    cell.delegate = self;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = (indexPath.section*100)+indexPath.row;
                    return cell;
                }
            }
            return [UITableViewCell new];
            break;
        case 1:
            if (indexPath.row == 0) {
                SFAWatchSettingsWatchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:WATCH_CELL];
                cell.watchModel.text    = [cell watchModelStringWithWatchModel:watchModel];
                cell.watchLastSync.text = [cell lastSyncDateWithDeviceEntity:self.deviceEntity];
                cell.watchImage.image = [cell watchImageWithWatchModel:watchModel];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;
            }
            if (indexPath.row == 1) {
                SFASettingsCellWithButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_BUTTON];
                cell.lableTitle.text = SETTINGS_DEVICE_NAME;
                cell.cellTextField.text = self.deviceEntity.name;
                cell.cellTextField.hidden = NO;
                cell.cellButton.hidden = YES;
                cell.delegate = self;
                //[cell.cellButton setTitle:WATCHNAME_BRITE_R450 forState:UIControlStateNormal];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;
            }
            if (indexPath.row == 2) {
                SFASettingsCellWithButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_BUTTON];
                cell.lableTitle.text = SETTINGS_TIME_FORMAT;
                if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
                    [cell.cellButton setTitle:SETTINGS_HOUR_FORMAT_12 forState:UIControlStateNormal];
                }
                else{
                    [cell.cellButton setTitle:SETTINGS_HOUR_FORMAT_24 forState:UIControlStateNormal];
                }
                cell.cellTextField.hidden = YES;
                cell.cellButton.hidden = NO;
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;
            }
            if (indexPath.row == 3) {
                SFASettingsIndentedToggleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_INDENTED_TOGGLE_CELL];
                cell.labelTitle.text = SETTINGS_SYNC_TIME_TO_PHONE;
                [cell.toggleButton setOn:self.syncTime];
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;
            }
            if (indexPath.row == 4) {
                SFASettingsCellWithButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_BUTTON];
                cell.lableTitle.text = SETTINGS_DATE_FORMAT;
                [cell setDateFormat:self.timeDate.dateFormat];
                cell.cellTextField.hidden = YES;
                cell.cellButton.hidden = NO;
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;
            }
            if (indexPath.row == 5) {
                SFASettingsCellWithButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_BUTTON];
                cell.lableTitle.text = SETTINGS_UNITS;
                if (self.userProfile.unit == IMPERIAL) {
                    [cell.cellButton setTitle:LS_IMPERIAL forState:UIControlStateNormal];
                }
                else{
                    [cell.cellButton setTitle:LS_METRIC forState:UIControlStateNormal];
                }
                cell.cellTextField.hidden = YES;
                cell.cellButton.hidden = NO;
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;
            }
            if (indexPath.row == 6) {
                if (watchModel == WatchModel_R450) {
                    SFASettingsCellWithButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_BUTTON];
                    cell.lableTitle.text = SETTINGS_WATCH_DISPLAY;
                    if (self.timeDate.watchFace == _SIMPLE) {
                        [cell.cellButton setTitle:LS_SIMPLE forState:UIControlStateNormal];
                    }
                    else{
                        [cell.cellButton setTitle:LS_FULL forState:UIControlStateNormal];
                    }
                    cell.cellTextField.hidden = YES;
                    cell.cellButton.hidden = NO;
                    cell.delegate = self;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = (indexPath.section*100)+indexPath.row;
                    return cell;
                }
                if (watchModel == WatchModel_Zone_C410 || watchModel == WatchModel_R420) {
                    if (HIDE_AUTO_EL) {
                        return [UITableViewCell new];
                    }
                    SFASettingsToggleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_TOGGLE_CELL];
                    cell.labelTitle.text = SETTINGS_AUTO_BACKLIGHT;
                    [cell.toggleButton setOn:self.calibrationData.autoEL];
                    cell.delegate = self;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = (indexPath.section*100)+indexPath.row;
                    return cell;
                }
                if (watchModel == WatchModel_Move_C300_Android || watchModel == WatchModel_Move_C300) {
                    SFASettingsCellWithSyncButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_SYNC_BUTTON];
                    cell.labelTitle.text = SETTINGS_SYNC_TO_WATCH;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = (indexPath.section*100)+indexPath.row;
                    return cell;
                }
            }
            if (indexPath.row == 7) {
                if (watchModel == WatchModel_R450) {
                    if (HIDE_AUTO_EL) {
                        return [UITableViewCell new];
                    }
                    SFASettingsToggleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_TOGGLE_CELL];
                    cell.labelTitle.text = SETTINGS_AUTO_BACKLIGHT;
                    [cell.toggleButton setOn:self.calibrationData.autoEL];
                    cell.delegate = self;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = (indexPath.section*100)+indexPath.row;
                    return cell;
                }
                if (watchModel == WatchModel_Zone_C410 || watchModel == WatchModel_R420) {
                    SFASettingsCellWithDescription *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_DESCRIPTION];
                    cell.labelTitle.text = SETTINGS_SMART_CALIBRATION_TITLE;
                    cell.labelDescription.text = SETTINGS_SMART_CALIBRATION_DESC;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = (indexPath.section*100)+indexPath.row;
                    return cell;
                }
            }
            if (indexPath.row == 8) {
                if (watchModel == WatchModel_Zone_C410 || watchModel == WatchModel_R420) {
                    SFASettingsCellWithSyncButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_SYNC_BUTTON];
                    cell.labelTitle.text = SETTINGS_SYNC_TO_WATCH;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = (indexPath.section*100)+indexPath.row;
                    return cell;
                }
                else{
                    SFASettingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL];
                    cell.labelTitle.text = SETTINGS_WATCH_ALARMS;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = (indexPath.section*100)+indexPath.row;
                    return cell;
                }
            }
            if (indexPath.row == 9) {
                SFASettingsCellWithDescription *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_DESCRIPTION];
                cell.labelTitle.text = SETTINGS_NOTIFICATION_TITLE;
                cell.labelDescription.text = SETTINGS_NOTIFICATION_DESC;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;
            }
            if (indexPath.row == 10) {
                SFASettingsCellWithDescription *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_DESCRIPTION];
                cell.labelTitle.text = SETTINGS_SMART_CALIBRATION_TITLE;
                cell.labelDescription.text = SETTINGS_SMART_CALIBRATION_DESC;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;
            }
            if (indexPath.row == 11) {
                SFASettingsCellWithSyncButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_SYNC_BUTTON];
                cell.labelTitle.text = SETTINGS_SYNC_TO_WATCH;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;
            }
            return [UITableViewCell new];
            break;
        case 2:
            if (indexPath.row == 0) {
                SFASettingsToggleCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_TOGGLE_CELL];
                cell.labelTitle.text = SETTINGS_ENABLE_SYNC_TO_CLOUD;
                [cell.toggleButton setOn:self.enableSyncToCloud];
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;
            }
            if (indexPath.row == 1) {
                SFASettingsCellWithSyncButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_SYNC_BUTTON];
                cell.labelTitle.text = SETTINGS_SYNC_TO_CLOUD;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (self.enableSyncToCloud) {
                    cell.labelTitle.hidden = NO;
                    cell.syncImage.hidden = NO;
                }
                else{
                    cell.labelTitle.hidden = YES;
                    cell.syncImage.hidden = YES;
                }
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;
            }
            return [UITableViewCell new];
            break;
            
        case 3:
            if (indexPath.row == 0) {
                SFASettingsCellWithButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_BUTTON];
                cell.lableTitle.text = SETTINGS_WS_HR_LOGGIN_RATE;
                [cell.cellButton setTitle:[NSString stringWithFormat:@"%@ %@", self.hrLoggingRate, @"sec"] forState:UIControlStateNormal];
                cell.cellTextField.hidden = YES;
                cell.cellButton.hidden = NO;
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;
            }
            if (indexPath.row == 1) {
                SFASettingsCellWithButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_BUTTON];
                cell.lableTitle.text = SETTINGS_WS_STORAGE_LEFT;
                
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
                [formatter setMaximumFractionDigits:1];
                [formatter setMinimumFractionDigits:1];
                
                [cell.cellButton setTitle:[NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:self.workoutStorageLeft], @"hours"] forState:UIControlStateNormal];
                cell.cellTextField.hidden = YES;
                cell.cellButton.hidden = NO;
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;
            }
            if (indexPath.row == 2) {
                SFASettingsCellWithButton *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTING_CELL_WITH_BUTTON];
                cell.lableTitle.text = SETTINGS_WS_RECONNECT_TIMEOUT;
                [cell.cellButton setTitle:[NSString stringWithFormat:@"%@ %@", self.reconnectTimeout, @"sec"] forState:UIControlStateNormal];
                cell.cellTextField.hidden = YES;
                cell.cellButton.hidden = NO;
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = (indexPath.section*100)+indexPath.row;
                return cell;            }
            return [UITableViewCell new];
            break;
            
        /*
        case 0:
            if (watchModel == WatchModel_Zone_C410) {
                SFAAutoSyncCell *cell = nil;
                
                switch    (indexPath.row) {
                    case 0:
                        cell = [self.tableView dequeueReusableCellWithIdentifier:CALIBRATION_CELL];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        return cell;
                    case 1:
                        cell = [self.tableView dequeueReusableCellWithIdentifier:AUTO_SYNC_TIME_CELL];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        self.autoSyncTimeSwitch = cell.autoSyncTimeSwitch;
                        self.autoSyncTimeSwitch.on = self.userDefaultsManager.autoSyncTimeEnabled;
                        [self.autoSyncTimeSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
                        
                        return cell;
                    default:
                        break;
                }
                
                return [UITableViewCell new];
            }
            else if (watchModel == WatchModel_Move_C300 || watchModel == WatchModel_Move_C300_Android){
                SFAAutoSyncCell *cell = nil;
                cell = [self.tableView dequeueReusableCellWithIdentifier:AUTO_SYNC_TIME_CELL];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                self.autoSyncTimeSwitch = cell.autoSyncTimeSwitch;
                self.autoSyncTimeSwitch.on = self.userDefaultsManager.autoSyncTimeEnabled;
                [self.autoSyncTimeSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
                
                return cell;
            }
            else if (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) {
                
                if (indexPath.row == 0) {
                    SFAAutoSyncCell *autoSyncCell = (SFAAutoSyncCell *)[self.tableView dequeueReusableCellWithIdentifier:AUTO_SYNC_CELL];
                    autoSyncCell.accessoryType = UITableViewCellAccessoryNone;
                    autoSyncCell.autoSyncSwitch.on = self.userDefaultsManager.autoSyncToWatchEnabled;
                    [autoSyncCell.autoSyncSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
                    self.autoSyncSwitch = autoSyncCell.autoSyncSwitch;
                    return autoSyncCell;
                }
                else if (indexPath.row > 0 && indexPath.row < 4){
                    
                    SFASyncOptionCell *syncOptionCell = (SFASyncOptionCell *)[self.tableView dequeueReusableCellWithIdentifier:AUTO_SYNC_OPTION_CELL];
                    syncOptionCell.accessoryType = UITableViewCellAccessoryNone;
                    [syncOptionCell hideAllTimeButtons:YES];
                    
                    SyncSetupOption syncSetupOption = [[self.userDefaults objectForKey:AUTO_SYNC_OPTION] intValue];
                    
                    if (syncSetupOption == SyncSetupOptionOff) {
                        
                        syncSetupOption = SyncSetupOptionOnce;
                        [self.userDefaults setInteger:SyncSetupOptionOnce forKey:AUTO_SYNC_OPTION];
                        [self.userDefaults synchronize];
                    }

                    if (self.userDefaultsManager.autoSyncToWatchEnabled) {
                        
                        [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
                        if (indexPath.row == 1) {
                            syncOptionCell.optionlabel.text = OPTION_ONCE_LABEL;
                            
                            if (syncSetupOption == SyncSetupOptionOnce) {
                                [syncOptionCell showTimeButtonForSyncSetupOption:SyncSetupOptionOnce];
                            }
                        }
                        else if (indexPath.row == 2) {
                            syncOptionCell.optionlabel.text = OPTION_ONCE_A_WEEK_LABEL;
                            
                            if (syncSetupOption == SyncSetupOptionOnceAWeek) {
                                [syncOptionCell showTimeButtonForSyncSetupOption:SyncSetupOptionOnceAWeek];
                            }
                            
                        }
                        / *
                         else if (indexPath.row == 2) {
                         syncOptionCell.optionlabel.text = OPTION_TWICE_LABEL;
                         
                         if (syncSetupOption == SyncSetupOptionTwice) {
                         [syncOptionCell showTimeButtonForSyncSetupOption:SyncSetupOptionTwice];
                         }
                         }
                         * /
                        else {
                            syncOptionCell.optionlabel.text = OPTION_FOUR_TIMES_LABEL;
                            
                            if (syncSetupOption == SyncSetupOptionFourTimes) {
                                [syncOptionCell showTimeButtonForSyncSetupOption:SyncSetupOptionFourTimes];
                            }
                        }
                        [syncOptionCell setAutoSyncTime];
                        return syncOptionCell;
                    }
                    else {
                        [[SFAWatchManager sharedManager] disableAutoSync];
                    }
                }
                else {
                    
                    SFAAutoSyncCell *autoSyncCell = (SFAAutoSyncCell *)[self.tableView dequeueReusableCellWithIdentifier:AUTO_SYNC_ALERT_CELL];
                    autoSyncCell.accessoryType = UITableViewCellAccessoryNone;
                    
                    [autoSyncCell.autoSyncAlertSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
                    self.autoSyncAlertSwitch = autoSyncCell.autoSyncAlertSwitch;
                    
                    return autoSyncCell;
                }
            }
            return [UITableViewCell new];
            break;
            
        case 1:
            return [UITableViewCell new];
            break;
            
        case 2:
            if (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) {
                
                if(indexPath.row == 0) {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ALARM_SETTINGS_CELL];
                    return cell;
                }
                else if (indexPath.row == 1) {
                    
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CALIBRATION_CELL];
                    return cell;
                } else if (indexPath.row == 2) {
                    SFAAutoSyncCell *cell = [self.tableView dequeueReusableCellWithIdentifier:AUTO_SYNC_TIME_CELL];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    self.autoSyncTimeSwitch = cell.autoSyncTimeSwitch;
                    self.autoSyncTimeSwitch.on = self.userDefaultsManager.autoSyncTimeEnabled;
                    [self.autoSyncTimeSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
                    
                    return cell;
                }
            }
            return [UITableViewCell new];
            break;
            
        case 3: {
            if((self.userDefaultsManager.watchModel == WatchModel_R450 ||
                self.userDefaultsManager.watchModel == WatchModel_R500) && indexPath.row == 0) {
                SFAPreferenceCell *cell = [self.tableView dequeueReusableCellWithIdentifier:DATE_PREFERENCE_CELL];
                
                [cell setContentWithPreferenceType:SFAPreferenceTypeDate];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                self.dateFormatButton = cell.dateFormatButton;
                [self.dateFormatButton addTarget:self action:@selector(dateFormatClick:) forControlEvents:UIControlEventTouchDown];
                return cell;
            } else {
                SFAPreferenceCell *cell = [self.tableView dequeueReusableCellWithIdentifier:PREFERENCE_CELL];
                cell.preferenceType = indexPath.row;
                [cell setContentWithPreferenceType:indexPath.row];
                cell.delegate = self;
                return cell;
            }
        }
            
        case 4: {
            SFASettingsPromptCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SETTINGS_PROMPT_CELL];
            [cell setContents];
            return cell;
            break;
        }
            
        case 5:
            if (watchModel == WatchModel_R450 || watchModel == WatchModel_R500) {
                UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NOTIFICATIONS_CELL];
                return cell;
            }
            else if ((watchModel == WatchModel_Core_C200 || watchModel == WatchModel_Move_C300 || watchModel == WatchModel_Move_C300_Android) && [[SFAHealthKitManager sharedManager] isHealthKitAvailable]){
                UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:HEALTHAPP_CELL];
                return cell;
            }
            return [UITableViewCell new];
            break;
            
        case 6:
            if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
                UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:HEALTHAPP_CELL];
                return cell;
            }
            return [UITableViewCell new];
            break;
       */
        default:
            return [UITableViewCell new];
            break;
    }
    
    return [UITableViewCell new];
}

#pragma mark - SFAPreferenceCell methods

- (void)reloadSectionAfterDelay
{
    // crude fix for time delay because of database saving.
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    SyncSetupOption syncSetupOption = [[self.userDefaults objectForKey:AUTO_SYNC_OPTION] intValue];
    NSIndexPath *indexPathDaily = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathWeekly = [NSIndexPath indexPathForRow:2 inSection:0];
    if (self.userDefaultsManager.autoSyncToWatchEnabled) {
        if(syncSetupOption == SyncSetupOptionOnce){
            [self.tableView reloadRowsAtIndexPaths:@[indexPathDaily] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if(syncSetupOption == SyncSetupOptionOnceAWeek){
            [self.tableView reloadRowsAtIndexPaths:@[indexPathWeekly] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)preferenceCell:(SFAPreferenceCell *)cell didChangeHourFormat:(HourFormat)hourFormat
{
    [self performSelector:@selector(reloadSectionAfterDelay) withObject:nil afterDelay:0.5f];
    TimeDate *timeDate = [SFAUserDefaultsManager sharedManager].timeDate;
    timeDate.hourFormat = hourFormat;
    [SFAUserDefaultsManager sharedManager].timeDate = timeDate;
}

- (void)preferenceCell:(SFAPreferenceCell *)cell didChangeUnit:(Unit)unit
{
    // Update profile units
    SalutronUserProfile *salutronUserProfile = [SFAUserDefaultsManager sharedManager].salutronUserProfile;
    salutronUserProfile.unit = unit;
    [SFAUserDefaultsManager sharedManager].salutronUserProfile = salutronUserProfile;
    
    //[self.tableView reloadData];
}

- (void)preferenceCell:(SFAPreferenceCell *)cell didChangeDateFormat:(DateFormat)dateFormat
{
    // Update profile units
    TimeDate *timeDate = [SFAUserDefaultsManager sharedManager].timeDate;
    timeDate.dateFormat = dateFormat;
    [SFAUserDefaultsManager sharedManager].timeDate = timeDate;
    
   // [self.tableView reloadData];
}

#pragma mark - SFASettingsToggleCellWithDescDelegate
- (void)toggleButtonWithDescValueChanged:(id)sender withValue:(BOOL)isOn andLabelTitle:(NSString *)title andCellTag:(int)cellTag{
    self.modifyingSettingName = title;
    if ([title isEqualToString:SETTINGS_PROMPT_TITLE]) {
        self.promptChangeSettings = isOn;
    }
    [self showCancelAndSave];
    [self hidePickerView];
}

#pragma mark - SFASettingsToggleCellDelegate
- (void)toggleButtonValueChanged:(id)sender withValue:(BOOL)isOn andLabelTitle:(NSString *)title withCellTag:(int)cellTag{
    self.modifyingSettingName = title;
    if ([title isEqualToString:SETTINGS_AUTO_BACKLIGHT]) {
        self.calibrationData.autoEL = isOn;
    }
    else if ([title isEqualToString:SETTINGS_ENABLE_SYNC_TO_CLOUD]){
        self.enableSyncToCloud = isOn;
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else if ([title isEqualToString:SETTINGS_SYNC_REMINDER]){
        self.autoSyncReminder = isOn;
        if (self.autoSyncSetupOption == SyncSetupOptionOff) {
            self.autoSyncSetupOption = isOn ? SyncSetupOptionOnce : SyncSetupOptionOff;
        }
        [self.tableView reloadData];
    }
    [self showCancelAndSave];
    [self hidePickerView];
}

#pragma mark - SFASettingsIndentedToggleCellDelegate
- (void)indentedToggleButtonValueChanged:(id)sender withValue:(BOOL)isOn andLabelTitle:(NSString *)title withCellTag:(int)cellTag{
    self.modifyingSettingName = title;
    if ([title isEqualToString:SETTINGS_SYNC_TIME_TO_PHONE]) {
        self.syncTime = isOn;
    }
    [self showCancelAndSave];
    [self hidePickerView];
}

#pragma mark - SFASettingsCellWithButtonDelegate
- (void)didButtonClicked:(UIButton *)sender withLabelTitle:(NSString *)title andCellTag:(int)cellTag{
    self.modifyingSettingName = title;
    if (/*[self.modifyingSettingName isEqualToString:SETTINGS_WS_RECONNECT_TIMEOUT] || */[self.modifyingSettingName isEqualToString:SETTINGS_WS_STORAGE_LEFT]){
        
    }
    else{
        [self showPickerView];
    }
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:cellTag%100 inSection:cellTag/100] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    if (/*[self.modifyingSettingName isEqualToString:SETTINGS_WS_RECONNECT_TIMEOUT] || */[self.modifyingSettingName isEqualToString:SETTINGS_WS_STORAGE_LEFT]){
        
    }
    else{
        [self showCancelAndSave];
    }
}

- (void)didTextFieldEditDone:(UITextField *)sender withLabelTitle:(NSString *)title andValue:(NSString *)textFieldValue andCellTag:(int)cellTag{
    self.modifyingSettingName = title;

    if ([title isEqualToString:SETTINGS_DEVICE_NAME]) {
        self.deviceEntity.name = textFieldValue;
    }
    [self showCancelAndSave];
}

- (void)didTextFieldClicked:(UITextField *)sender withLabelTitle:(NSString *)title andValue:(NSString *)textFieldValue andCellTag:(int)cellTag{
    
    [self hidePickerView];
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 10, 50, 30);
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, -0, -0)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    [button setTitle:BUTTON_TITLE_DONE forState:UIControlStateNormal];
    [button addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithCustomView:button];

    
    /*initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(resignFirstResponder)];*/
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor blackColor];
    
    sender.inputAccessoryView = toolBar;
    self.modifyingSettingName = title;
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:cellTag/100] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}

#pragma mark - SFASettingsIndentedCellWithButtonDelegate
- (void)indentedCellButtonClicked:(UIButton *)sender withLabelTitle:(NSString *)title withCellTag:(int)cellTag{
    self.modifyingSettingName = title;
    [self showPickerView];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:cellTag%100 inSection:cellTag/100] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [self showCancelAndSave];
}

- (void)indentedCellOnOffButtonClicked:(UIButton *)sender withLabelTitle:(NSString *)title withCellTag:(int)cellTag{
    self.modifyingSettingName = title;
    if ([title isEqualToString:SETTINGS_ONCE_A_DAY]) {
        self.autoSyncSetupOption = SyncSetupOptionOnce;
    }
    else if ([title isEqualToString:SETTINGS_ONCE_A_WEEK]){
        self.autoSyncSetupOption = SyncSetupOptionOnceAWeek;
    }
    [self.tableView reloadData];
    [self hidePickerView];
    [self showCancelAndSave];
    
}

- (void)resignFirstResponder
{
    [self.view endEditing:YES];
}

@end
