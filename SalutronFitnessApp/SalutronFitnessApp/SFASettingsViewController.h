//
//  SFASyncSetup.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/25/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "CalibrationData+CalibrationDataCategory.h"
#import "WakeupEntity+Data.h"
#import "Wakeup+Entity.h"
#import "SFASettingsCellWithButton.h"
#import "SFAViewController.h"

@interface SFASettingsViewController : SFAViewController<UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *datePickerContainerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (strong, nonatomic) UISwitch *autoSyncSwitch;
@property (strong, nonatomic) UISwitch *autoSyncAlertSwitch;
@property (strong, nonatomic) UISwitch *autoSyncTimeSwitch;
@property (strong, nonatomic) UIButton *dateFormatButton;
@property (strong, nonatomic) NSUserDefaults *userDefaults;

@property (strong, nonatomic) WakeupEntity *wakeupEntity;
@property (strong, nonatomic) SFAUserDefaultsManager *userDefaultsManager;


@property (readwrite, nonatomic) BOOL promptChangeSettings;
@property (strong, nonatomic) DeviceEntity *deviceEntity;
@property (strong, nonatomic) TimeDate *timeDate;
@property (readwrite, nonatomic) BOOL syncTime;
@property (strong, nonatomic) SalutronUserProfile *userProfile;
@property (strong, nonatomic) CalibrationData *calibrationData;
@property (strong, nonatomic) WorkoutSetting *workoutSetting;
@property (readwrite, nonatomic) BOOL enableSyncToCloud;
@property (readwrite, nonatomic) BOOL autoSyncReminder;
@property (readwrite, nonatomic) SyncSetupOption autoSyncSetupOption;
@property (readwrite, nonatomic) NSNumber *autoSyncTime;
@property (readwrite, nonatomic) NSString *autoSyncDay;
@property (readwrite, nonatomic) NSNumber *hrLoggingRate;
@property (readwrite, nonatomic) NSNumber *reconnectTimeout;
@property (readwrite, nonatomic) NSNumber *workoutStorageLeft;
@property (readwrite, nonatomic) NSNumber *workoutReconnectTimeout;

@property (strong, nonatomic) NSString *modifyingSettingName;




- (IBAction)timeButtonClicked:(UIButton *)sender;
- (IBAction)menuButtonPressed:(id) sender;
- (IBAction)syncButtonPressed:(id)sender;
- (void)valueChanged:(id)sender;
- (void)dateFormatClick:(id)sender;
- (void)setAutoSyncFrequency:(id)sender;
- (IBAction)hidePicker:(id)sender;

- (void)showPickerView;
- (void)hidePickerView;
- (void)showCancelAndSave;

- (NSNumber *)timeIntervalFromHour:(NSString *)hour min:(NSString *)min andAmPm:(NSString *)amPm;

- (NSString *)convertAndroidToiOSMacAddress:(NSString *)macAddress;

@end
