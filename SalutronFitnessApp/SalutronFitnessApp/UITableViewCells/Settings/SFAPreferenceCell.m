//
//  SFAPreferenceCell.m
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/19/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAPreferenceCell.h"

#import "TimeDate.h"
#import "TimeDate+Data.h"
#import "SalutronUserProfile.h"
#import "SalutronUserProfile+Data.h"
#import "SleepSetting+Data.h"
#import "DeviceEntity+Data.h"
#import "UserProfileEntity+Data.h"

@interface SFAPreferenceCell ()

- (IBAction)buttonFirstTouchedUp:(id)sender;
- (IBAction)buttonSecondTouchedUp:(id)sender;

@property (strong, nonatomic) SFAUserDefaultsManager *userDefaultsManager;

@end

@implementation SFAPreferenceCell

#pragma mark - Public instance methods

- (void)setContentWithPreferenceType:(SFAPreferenceType)preferenceType
{
    switch (preferenceType) {
        case SFAPreferenceTypeTime:
            [self setTimeContent];
            break;
            
        case SFAPreferenceTypeDate:
            [self setDateContent];
            break;
            
        case SFAPreferenceTypeUnit:
            [self setUnitContent];
            break;
            
        case SFAPreferenceFaceWatch:
            [self setWatchFace];
            break;

        case SFAPreferenceSleepMode:
            [self setWatchSleepMode];
            break;
    
        default:
            break;
    }
}

#pragma mark - Private instance methods

- (void)setDateContent
{
    TimeDate *timeDate     = [TimeDate getData];
    
    self.labelTitle.text    = NSLocalizedString(@"Date Format", nil);
    self.labelFirst.text    = DATE_FORMAT_DDMMYY;
    self.labelSecond.text   = DATE_FORMAT_MMDDYY;
    self.buttonFirst.tag    = _DDMM;
    self.buttonSecond.tag   = _MMDD;
    
    if (self.userDefaultsManager.watchModel == WatchModel_R450 ||
       self.userDefaultsManager.watchModel == WatchModel_R500) {
        switch (timeDate.dateFormat) {
            case 0:
                [self.dateFormatButton setTitle:DATE_FORMAT_DDMMYY forState:UIControlStateNormal];
                break;
            case 1:
                [self.dateFormatButton setTitle:DATE_FORMAT_MMDDYY forState:UIControlStateNormal];
                break;
            case 2:
                [self.dateFormatButton setTitle:DATE_FORMAT_DDMMM forState:UIControlStateNormal];
                break;
            case 3:
                [self.dateFormatButton setTitle:DATE_FORMAT_MMMDD forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    } else {
        if (timeDate.dateFormat == _DDMM) {
            self.buttonFirst.selected   = YES;
            self.buttonSecond.selected  = NO;
        }
        else {
            self.buttonFirst.selected   = NO;
            self.buttonSecond.selected  = YES;
        }
    }
}

- (void)setTimeContent
{
    TimeDate *timeDate      = [TimeDate getData];
    
    self.labelTitle.text    = NSLocalizedString(@"Time Format", nil);
    self.labelFirst.text    = NSLocalizedString(@"12HR", @"time format");
    self.labelSecond.text   = NSLocalizedString(@"24HR", @"time format");
    self.buttonFirst.tag    = _12_HOUR;
    self.buttonSecond.tag   = _24_HOUR;
    
    if (timeDate.hourFormat == _12_HOUR) {
        [self buttonFirstTouchedUp:self];
    }
    else {
        [self buttonSecondTouchedUp:self];
    }
}

- (void)setUnitContent
{
    SalutronUserProfile *userProfile    = [SalutronUserProfile getData];
    
    self.labelTitle.text                = NSLocalizedString(@"Unit", nil);
    self.labelFirst.text                = LS_IMPERIAL_CAPS;
    self.labelSecond.text               = LS_METRIC_CAPS;
    self.buttonFirst.tag                = IMPERIAL;
    self.buttonSecond.tag               = METRIC;
    
    if (userProfile.unit == IMPERIAL) {
        self.buttonFirst.selected   = YES;
        self.buttonSecond.selected  = NO;
    }
    else {
        self.buttonFirst.selected   = NO;
        self.buttonSecond.selected  = YES;
    }
}

- (void)setWatchFace
{
    TimeDate *timeDate                  = [TimeDate getData];
    
    self.labelTitle.text                = NSLocalizedString(@"Watch Display", nil);
    self.labelFirst.text                = NSLocalizedString(@"SIMPLE", nil);
    self.labelSecond.text               = NSLocalizedString(@"FULL", nil);
    self.buttonFirst.tag                = _SIMPLE;
    self.buttonSecond.tag               = _FULL;
    
    if (timeDate.watchFace == _SIMPLE) {
        self.buttonFirst.selected   = YES;
        self.buttonSecond.selected  = NO;
    }
    else {
        self.buttonFirst.selected   = NO;
        self.buttonSecond.selected  = YES;
    }
}

- (void)setWatchSleepMode
{
    SleepSetting *sleepSettings         = [SleepSetting sleepSetting];
    
    self.labelTitle.text                = NSLocalizedString(@"Sleep Mode", nil);
    self.labelFirst.text                = NSLocalizedString(@"MANUAL", @"a sleep mode");
    self.labelSecond.text               = NSLocalizedString(@"AUTO", @"a sleep mode");
    self.buttonFirst.tag                = MANUAL;
    self.buttonSecond.tag               = AUTO;
    
    if (sleepSettings.sleep_mode == MANUAL) {
        self.buttonFirst.selected   = YES;
        self.buttonSecond.selected  = NO;
    }
    else {
        self.buttonFirst.selected   = NO;
        self.buttonSecond.selected  = YES;
    }
}

#pragma mark - IBAction methods

- (IBAction)buttonFirstTouchedUp:(id)sender
{
    self.buttonFirst.selected   = YES;
    self.buttonSecond.selected  = NO;
    [self saveSettingsWithTag:self.buttonFirst.tag];
}

- (void)buttonSecondTouchedUp:(id)sender
{
    self.buttonFirst.selected   = NO;
    self.buttonSecond.selected  = YES;
    [self saveSettingsWithTag:self.buttonSecond.tag];
}

- (void)saveSettingsWithTag:(NSInteger)tag
{
    NSData *userData                   = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PROFILE];
    SalutronUserProfile *userProfile   = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    TimeDate *timeDate                 = [TimeDate getData];
    SleepSetting *sleepSettings        = [SleepSetting sleepSetting];
    
    switch (self.preferenceType) {
            
        case SFAPreferenceTypeTime:
            
            timeDate.hourFormat = tag;
            if ([self.delegate conformsToProtocol:@protocol(SFAPreferenceCellDelegate)] &&
                [self.delegate respondsToSelector:@selector(preferenceCell:didChangeHourFormat:)]) {
                [self.delegate preferenceCell:self didChangeHourFormat:timeDate.hourFormat];
            }
            
            break;
            
        case SFAPreferenceTypeDate:
            
            timeDate.dateFormat = tag;
            if ([self.delegate conformsToProtocol:@protocol(SFAPreferenceCellDelegate)] &&
                [self.delegate respondsToSelector:@selector(preferenceCell:didChangeDateFormat:)]) {
                [self.delegate preferenceCell:self didChangeDateFormat:self.buttonSecond.tag];
            }
            break;
            
        case SFAPreferenceTypeUnit:
            
            userProfile.unit = tag;
            if ([self.delegate conformsToProtocol:@protocol(SFAPreferenceCellDelegate)] &&
                [self.delegate respondsToSelector:@selector(preferenceCell:didChangeUnit:)]) {
                [self.delegate preferenceCell:self didChangeUnit:self.buttonSecond.tag];
            }
            break;
        
        case SFAPreferenceFaceWatch:
            
            timeDate.watchFace = tag;
            self.userDefaultsManager.watchFace = tag;
            
            break;
            
        case SFAPreferenceSleepMode:
            
            sleepSettings.sleep_mode = tag;
            self.userDefaultsManager.sleepSetting.sleep_mode = tag;
            
            break;
            
        default:
            break;
    }
    
    [TimeDate saveWithTimeDate:timeDate];
    [SalutronUserProfile saveWithSalutronUserProfile:userProfile];
    
    DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    [UserProfileEntity userProfileWithSalutronUserProfile:userProfile forDeviceEntity:deviceEntity];
    
}

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

@end
