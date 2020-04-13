//
//  SFAAlarmSettingCell.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 2/6/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFAWakeUpAlarmSettingCellDelegate;

typedef enum {
    AlarmSettingAlarmStatus,
    AlarmSettingWakeupTime,
    AlarmSettingWindow,
    AlarmSettingSnoozeStatus,
    AlarmSettingSnoozeTime
} SFAAlarmSettingEnum;

@interface SFAWakeUpAlarmSettingCell : UITableViewCell

@property (weak, nonatomic) id<SFAWakeUpAlarmSettingCellDelegate> delegate;
@property (assign, nonatomic) NSInteger windowTimeValue;
@property (assign, nonatomic) NSInteger snoozeTimeValue;

@property (weak, nonatomic) IBOutlet UITextField    *wakeupTimeTextField;
@property (weak, nonatomic) IBOutlet UISwitch       *wakeupAlertSwitch;

- (void)setAlarmStatusSwitch:(BOOL)isOn;
- (void)setSnoozeStatusSwitch:(BOOL)isOn;
- (void)setWakeupTimeValue:(NSString *)value;
- (void)setWindowTimeStepperValue:(NSInteger)value;
- (void)setWindowTimeTextValue:(NSString *)value;
- (void)setSnoozeTimeStepperValue:(NSInteger)value;
- (void)setSnoozeTimeTextValue:(NSString *)value;

@end


@protocol SFAWakeUpAlarmSettingCellDelegate <NSObject>

- (void)alarmSetting:(SFAAlarmSettingEnum)alarmSetting didChangeStatusValue:(BOOL)value;
- (void)alarmSetting:(SFAAlarmSettingEnum)alarmSetting didStepperValueChanged:(id)sender;
- (void)alarmsetting:(SFAAlarmSettingEnum)alarmSetting didWakeupTimeChangedWithHour:(NSInteger)hour minute:(NSInteger)minute;

@end