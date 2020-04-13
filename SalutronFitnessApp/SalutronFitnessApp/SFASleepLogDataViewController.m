//
//  SFASleepLogDataViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/13/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SleepDatabaseEntity.h"
#import "SleepDatabaseEntity+Data.h"
#import "TimeDate+Data.h"
#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "DeviceEntity+Data.h"
#import "DateEntity.h"

#import "JDACoreData.h"
#import "JDAKeyboardAccessory.h"

#import "SFAMainViewController.h"
#import "SFASleepLogDataViewController.h"
#import "UIViewController+Helper.h"

@interface SFASleepLogDataViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *selectedDate;
@property (weak, nonatomic) IBOutlet UITextField *startTime;
@property (weak, nonatomic) IBOutlet UITextField *endTime;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) JDAKeyboardAccessory *keyboardAccessory;

@property (readwrite, nonatomic) HourFormat hourFormat;
@property (strong, nonatomic) NSDate *startDate;
@property (readwrite, nonatomic) NSInteger startHour;
@property (readwrite, nonatomic) NSInteger startMinute;
@property (readwrite, nonatomic) NSInteger endHour;
@property (readwrite, nonatomic) NSInteger endMinute;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation SFASleepLogDataViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initializeObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.mode == SFASleepLogDataModeAdd) {
        // Navigation bar title
        self.navigationItem.title = BUTTON_TITLE_ADD;
        self.navigationItem.rightBarButtonItem = nil;
        
        // Time
        self.startHour      = 0;
        self.startMinute    = 0;
        self.endHour        = 0;
        self.endMinute      = 0;
        
        // Date
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"MMMM dd, YYYY"];
        self.selectedDate.text = [dateFormatter stringFromDate:self.calendarController.selectedDate];
        
    } else if (self.mode == SFASleepLogDataModeEdit) {
        // Navigation bar title
        self.navigationItem.title = BUTTON_TITLE_EDIT;
        
        // Time
        self.startHour      = self.sleepDatabaseEntity.sleepStartHour.integerValue;
        self.startMinute    = self.sleepDatabaseEntity.sleepStartMin.integerValue;
        self.endHour        = self.sleepDatabaseEntity.sleepEndHour.integerValue;
        self.endMinute      = self.sleepDatabaseEntity.sleepEndMin.integerValue;
        
        // Date
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"MMMM dd, YYYY"];
        self.selectedDate.text = [dateFormatter stringFromDate:self.sleepDatabaseEntity.dateInNSDate];
    }
    
    
    
    self.startTime.text = [self formatTimeWithHourFormat:self.hourFormat hour:self.startHour minute:self.startMinute];
    self.endTime.text   = [self formatTimeWithHourFormat:self.hourFormat hour:self.endHour minute:self.endMinute];
    
    // remove AM or PM
    TimeDate *timeDate = [TimeDate getData];
    if (timeDate.hourFormat == _24_HOUR) {
        self.startTime.text = [self.startTime.text removeTimeHourFormat];
        self.endTime.text = [self.endTime.text removeTimeHourFormat];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.calendarController hideCalendar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.calendarController showCalendar];
}

#pragma mark - Setters

- (void)setMode:(SFASleepLogDataMode)mode
{
    _mode = mode;
    
    if (mode == SFASleepLogDataModeAdd) {
        self.navigationItem.rightBarButtonItem = nil;
    } else if (mode == SFASleepLogDataModeEdit) {
        
    }
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSDateComponents *dateComponents = [NSDateComponents new];
    self.keyboardAccessory.currentView = textField;
    
    if (textField == self.selectedDate) {
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        self.datePicker.date = self.startDate;
        self.datePicker.maximumDate = [NSDate date];
        return;
    } else if (textField == self.startTime) {
        dateComponents.hour = self.startHour;
        dateComponents.minute = self.startMinute;
    } else if (textField == self.endTime) {
        dateComponents.hour = self.endHour;
        dateComponents.minute = self.endMinute;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    self.datePicker.date = [calendar dateFromComponents:dateComponents];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:self.datePicker.date];
    
    if (textField == self.selectedDate) {
        self.startDate = self.datePicker.date;
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"MMMM dd, YYYY"];
        self.selectedDate.text = [dateFormatter stringFromDate:self.startDate];
    } else if (textField == self.startTime) {
        self.startHour = dateComponents.hour;
        self.startMinute = dateComponents.minute;
        textField.text = [self formatTimeWithHourFormat:self.hourFormat hour:self.startHour minute:self.startMinute];
    } else if (textField == self.endTime) {
        self.endHour = dateComponents.hour;
        self.endMinute = dateComponents.minute;
        textField.text = [self formatTimeWithHourFormat:self.hourFormat hour:self.endHour minute:self.endMinute];
    }
    
    // remove AM or PM
    TimeDate *timeDate = [TimeDate getData];
    if (timeDate.hourFormat == _24_HOUR && (textField == self.startTime || textField == self.endTime)) {
        textField.text = [textField.text removeTimeHourFormat];
    }
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Remove sleep from previous statistical data header
        NSDate *date            = self.sleepDatabaseEntity.dateInNSDate;
        NSInteger startHour     = self.sleepDatabaseEntity.sleepStartHour.integerValue;
        NSInteger startMinute   = self.sleepDatabaseEntity.sleepStartMin.integerValue;
        NSInteger endHour       = self.sleepDatabaseEntity.sleepEndHour.integerValue;
        NSInteger endMinute     = self.sleepDatabaseEntity.sleepEndMin.integerValue;
        
        if (startHour > endHour ||
            (startHour == endHour &&
             startMinute >= endMinute)) {
                date = [date dateByAddingTimeInterval:DAY_SECONDS];
            }
        
        StatisticalDataHeaderEntity *dataHeader = [StatisticalDataHeaderEntity statisticalDataHeaderEntityForDate:date];
        dataHeader.totalSleep = @(dataHeader.totalSleep.integerValue - self.sleepDatabaseEntity.sleepDuration.integerValue);
        
        NSString *macAddress = [[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS];
        DeviceEntity *device = [DeviceEntity deviceEntityForMacAddress:macAddress];
        [device removeSleepdatabaseObject:self.sleepDatabaseEntity];
        [[JDACoreData sharedManager] deleteEntityObjectWithObject:self.sleepDatabaseEntity];
        [[JDACoreData sharedManager] save];
        
        if ([self.delegate conformsToProtocol:@protocol(SFASleepLogDataViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(didDeleteInSleepLogDataViewController:)]) {
            [self.delegate didDeleteInSleepLogDataViewController:self];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - IBAction Methods

- (IBAction)saveButtonPressed:(id)sender
{
    if ([self hasData]) {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                     message:LS_SLEEP_LOG_WARNING
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_OK
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                            message:LS_SLEEP_LOG_WARNING
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:BUTTON_TITLE_OK, nil];
        
        [alertView show];
        }
        return;
    }
    
    if ([self isFuture]) {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                     message:LS_INVALID_END_TIME
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_OK
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                            message:LS_INVALID_END_TIME
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:BUTTON_TITLE_OK, nil];
        
        [alertView show];
        }
        
        return;
    }
    
    if ([self isValidEndTime]) {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                     message:LS_INVALID_END_TIME
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_OK
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                            message:LS_INVALID_END_TIME
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:BUTTON_TITLE_OK, nil];
        
        [alertView show];
        }
        
        return;
    }
    
    
    if ([self isMoreThanMaxSleep]) {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                     message:LS_INVALID_SLEEP_TIME_MAX
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_OK
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                            message:LS_INVALID_SLEEP_TIME_MAX
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:BUTTON_TITLE_OK, nil];
        
        [alertView show];
        }
        return;
    }
    
    if ([self isLessThanMinSleep]) {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                     message:LS_INVALID_SLEEP_TIME_MIN
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_OK
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                            message:LS_INVALID_SLEEP_TIME_MIN
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:BUTTON_TITLE_OK, nil];
        
        [alertView show];
        }
        return;
    }
    
    
    if (self.mode == SFASleepLogDataModeAdd) {
        self.sleepDatabaseEntity = [[JDACoreData sharedManager] insertNewObjectWithEntityName:SLEEP_DATABASE_ENTITY];
        self.sleepDatabaseEntity.date = [[JDACoreData sharedManager] insertNewObjectWithEntityName:DATE_ENTITY];
    } else if (self.mode == SFASleepLogDataModeEdit) {
        // Remove sleep from previous statistical data header
        NSDate *date            = self.sleepDatabaseEntity.dateInNSDate;
        NSInteger startHour     = self.sleepDatabaseEntity.sleepStartHour.integerValue;
        NSInteger startMinute   = self.sleepDatabaseEntity.sleepStartMin.integerValue;
        NSInteger endHour       = self.sleepDatabaseEntity.sleepEndHour.integerValue;
        NSInteger endMinute     = self.sleepDatabaseEntity.sleepEndMin.integerValue;
        
        if (startHour > endHour ||
            (startHour == endHour &&
             startMinute > endMinute)) {
                date = [date dateByAddingTimeInterval:DAY_SECONDS];
            }
        
        StatisticalDataHeaderEntity *dataHeader = [StatisticalDataHeaderEntity statisticalDataHeaderEntityForDate:date];
        dataHeader.totalSleep = @(dataHeader.totalSleep.integerValue - self.sleepDatabaseEntity.sleepDuration.integerValue);
    }
    
    NSInteger sleepDuration = 0;
    NSDate *date = [self.startDate copy];
    
    if (self.endHour > self.startHour ||
        (self.endHour == self.startHour &&
         self.endMinute > self.startMinute)) {
            sleepDuration = (self.endHour * 60 + self.endMinute) - (self.startHour * 60 + self.startMinute);
        } else {
            self.startDate = [self.startDate dateByAddingTimeInterval:-DAY_SECONDS];
            sleepDuration = (24 * 60) - (self.startHour * 60 + self.startMinute);
            sleepDuration += (self.endHour * 60 + self.endMinute);
        }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit fromDate:self.startDate];
    
    self.sleepDatabaseEntity.sleepStartHour = @(self.startHour);
    self.sleepDatabaseEntity.sleepStartMin  = @(self.startMinute);
    self.sleepDatabaseEntity.sleepEndHour   = @(self.endHour);
    self.sleepDatabaseEntity.sleepEndMin    = @(self.endMinute);
    self.sleepDatabaseEntity.sleepDuration  = @(sleepDuration);
    self.sleepDatabaseEntity.dateInNSDate   = self.startDate;
    self.sleepDatabaseEntity.date.month     = @(dateComponents.month);
    self.sleepDatabaseEntity.date.day       = @(dateComponents.day);
    self.sleepDatabaseEntity.date.year      = @(dateComponents.year - 1900);
    
    // Add sleep to selected statistical data header
    StatisticalDataHeaderEntity *dataHeader = [StatisticalDataHeaderEntity statisticalDataHeaderEntityForDate:date];
    dataHeader.totalSleep = @(dataHeader.totalSleep.integerValue + sleepDuration);
    
    if (self.mode == SFASleepLogDataModeAdd) {
        NSString *macAddress = [[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS];
        DeviceEntity *device = [DeviceEntity deviceEntityForMacAddress:macAddress];
        [device addSleepdatabaseObject:self.sleepDatabaseEntity];
    }
    
    [[JDACoreData sharedManager] save];
    
    if (self.mode == SFASleepLogDataModeAdd) {
        if ([self.delegate conformsToProtocol:@protocol(SFASleepLogDataViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(sleepLogDataViewController:didAddSleepDatabaseEntity:)]) {
            [self.delegate sleepLogDataViewController:self didAddSleepDatabaseEntity:self.sleepDatabaseEntity];
        }
    } else if (self.mode == SFASleepLogDataModeEdit) {
        if ([self.delegate conformsToProtocol:@protocol(SFASleepLogDataViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(sleepLogDataViewController:didUpdateSleepDatabaseEntity:)]) {
            [self.delegate sleepLogDataViewController:self didUpdateSleepDatabaseEntity:self.sleepDatabaseEntity];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)deleteButtonPressed:(id)sender
{
    if (self.isIOS8AndAbove) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:BUTTON_TITLE_DELETE
                                                                                 message:LS_DELETE_RECORD_WARNING
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *noAction = [UIAlertAction
                                   actionWithTitle:BUTTON_TITLE_NO
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
        
        UIAlertAction *yesAction = [UIAlertAction
                                   actionWithTitle:BUTTON_TITLE_YES
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self deleteSleep];
                                   }];
        [alertController addAction:noAction];
        [alertController addAction:yesAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:BUTTON_TITLE_DELETE
                                                        message:LS_DELETE_RECORD_WARNING
                                                       delegate:self
                                              cancelButtonTitle:BUTTON_TITLE_NO
                                              otherButtonTitles:BUTTON_TITLE_YES, nil];
    [alertView show];
    }
}

- (void)deleteSleep{
    // Remove sleep from previous statistical data header
    NSDate *date            = self.sleepDatabaseEntity.dateInNSDate;
    NSInteger startHour     = self.sleepDatabaseEntity.sleepStartHour.integerValue;
    NSInteger startMinute   = self.sleepDatabaseEntity.sleepStartMin.integerValue;
    NSInteger endHour       = self.sleepDatabaseEntity.sleepEndHour.integerValue;
    NSInteger endMinute     = self.sleepDatabaseEntity.sleepEndMin.integerValue;
    
    if (startHour > endHour ||
        (startHour == endHour &&
         startMinute >= endMinute)) {
            date = [date dateByAddingTimeInterval:DAY_SECONDS];
        }
    
    StatisticalDataHeaderEntity *dataHeader = [StatisticalDataHeaderEntity statisticalDataHeaderEntityForDate:date];
    dataHeader.totalSleep = @(dataHeader.totalSleep.integerValue - self.sleepDatabaseEntity.sleepDuration.integerValue);
    
    NSString *macAddress = [[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS];
    DeviceEntity *device = [DeviceEntity deviceEntityForMacAddress:macAddress];
    [device removeSleepdatabaseObject:self.sleepDatabaseEntity];
    [[JDACoreData sharedManager] deleteEntityObjectWithObject:self.sleepDatabaseEntity];
    [[JDACoreData sharedManager] save];
    
    if ([self.delegate conformsToProtocol:@protocol(SFASleepLogDataViewControllerDelegate)] &&
        [self.delegate respondsToSelector:@selector(didDeleteInSleepLogDataViewController:)]) {
        [self.delegate didDeleteInSleepLogDataViewController:self];
    }
    
    [self.navigationController popViewControllerAnimated:YES];

}

#pragma mark - Private Methods

- (void)initializeObjects
{
    self.navigationItem.title = LS_SLEEP_LOGS;
    
    // Hour Format
    self.hourFormat = [[TimeDate getData] hourFormat];
    
    // Date Picker
    self.datePicker = [UIDatePicker new];
    self.datePicker.maximumDate = [NSDate date];
    self.datePicker.locale = self.hourFormat == _24_HOUR ? [NSLocale localeWithLocaleIdentifier:@"NL"] : nil;
    self.keyboardAccessory = [[JDAKeyboardAccessory alloc] initWithDoneAccessoryWithBarStyle:UIBarStyleDefault];
    
    // Selected date
    self.selectedDate.inputView = self.datePicker;
    self.selectedDate.inputAccessoryView = self.keyboardAccessory;
    
    // Start time
    self.startTime.inputView = self.datePicker;
    self.startTime.inputAccessoryView = self.keyboardAccessory;
    
    // End time
    self.endTime.inputView = self.datePicker;
    self.endTime.inputAccessoryView = self.keyboardAccessory;
    
    // Start Date
    self.startDate = self.calendarController.selectedDate;
    
    // Save Button
    self.saveButton.layer.borderColor = UIColorFromRGB(115, 115, 115).CGColor;
    self.saveButton.layer.borderWidth = 1.0f;
    self.saveButton.layer.cornerRadius = 5.0f;
}

- (NSString *)formatTimeWithHourFormat:(HourFormat)hourFormat hour:(NSInteger)hour minute:(NSInteger)minute
{
    NSString *timeAMPM = @"";
    
    if (hourFormat == _12_HOUR) {
        timeAMPM = hour < 12 ? LS_AM : LS_PM;
        hour = hour > 12 ? hour - 12 : hour;
        hour = hour == 0 ? 12 : hour;
    }
    
    NSString *minuteString = [NSString stringWithFormat:@"%@%i", minute < 10 ? @"0" : @"", minute];
    NSString *time = [NSString stringWithFormat:@"%i:%@ %@", hour, minuteString, timeAMPM];
    
    return time;
}

- (BOOL)hasData
{
    NSDate *yesterday           = [self.calendarController.selectedDate dateByAddingTimeInterval:-DAY_SECONDS];
    NSArray *yesterdaySleeps    = [SleepDatabaseEntity sleepDatabaseForDate:yesterday];
    NSArray *sleeps             = [SleepDatabaseEntity sleepDatabaseForDate:self.calendarController.selectedDate];
    
    NSInteger newSleepStart     = self.startHour * 60 + self.startMinute;
    NSInteger newSleepEnd       = self.endHour * 60 + self.endMinute;
    
    if (newSleepStart < newSleepEnd) {
        newSleepStart += 24 * 60;
    } else if (newSleepStart == 0 &&
               newSleepEnd == 0) {
        newSleepStart   += 24 * 60;
        newSleepEnd     += 24 * 60;
    }
    
    newSleepEnd += 24 * 60;
    
    for (SleepDatabaseEntity *sleep in yesterdaySleeps) {
        NSInteger sleepStart    = sleep.sleepStartHour.integerValue * 60 + sleep.sleepStartMin.integerValue;
        NSInteger sleepEnd      = sleep.sleepEndHour.integerValue * 60 + sleep.sleepEndMin.integerValue;
        
        if (sleepStart > sleepEnd) {
            sleepEnd += 24 * 60;
        }
        
        if (self.mode == SFASleepLogDataModeEdit &&
            sleep == self.sleepDatabaseEntity) {
            
        } else if (newSleepStart >= sleepStart &&
                   newSleepStart <= sleepEnd) {
            return YES;
        } else if (newSleepEnd >= sleepStart &&
                   newSleepEnd <= sleepEnd) {
            return YES;
        } else if (sleepStart >= newSleepStart &&
                   sleepStart <= newSleepEnd) {
            return YES;
        } else if (sleepEnd >= newSleepStart &&
                   sleepEnd <= newSleepEnd) {
            return YES;
        }
    }
    
    for (SleepDatabaseEntity *sleep in sleeps)
    {
        NSInteger sleepStart    = sleep.sleepStartHour.integerValue * 60 + sleep.sleepStartMin.integerValue + 24 * 60;
        NSInteger sleepEnd      = sleep.sleepEndHour.integerValue * 60 + sleep.sleepEndMin.integerValue + 24 * 60;
        
        if (self.mode == SFASleepLogDataModeEdit &&
            sleep == self.sleepDatabaseEntity) {
            
        } else if (newSleepStart >= sleepStart &&
                   newSleepStart <= sleepEnd) {
            return YES;
        } else if (newSleepEnd >= sleepStart &&
                   newSleepEnd <= sleepEnd) {
            return YES;
        } else if (sleepStart >= newSleepStart &&
                   sleepStart <= newSleepEnd) {
            return YES;
        } else if (sleepEnd >= newSleepStart &&
                   sleepEnd <= newSleepEnd) {
            return YES;
        }
        
    }
    
    
    return NO;
}

- (BOOL)isFuture
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                                               fromDate:self.calendarController.selectedDate];
    components.hour = self.endHour;
    components.minute = self.endMinute;
    
    NSDate *date = [calendar dateFromComponents:components];
    
    return [date compare:[NSDate date]] == NSOrderedDescending;
}

- (BOOL)isMoreThanMaxSleep{
    NSInteger startTimeInMinutes = self.startHour * 60 + self.startMinute;
    NSInteger endTimeInMinutes = self.endHour * 60 + self.endMinute;
    NSInteger maxSleepInMinutes = 14 * 60 + 50;
    if (endTimeInMinutes - startTimeInMinutes > maxSleepInMinutes) {
        return YES;
    }
    return NO;
}

- (BOOL)isLessThanMinSleep{
    NSInteger startTimeInMinutes = self.startHour * 60 + self.startMinute;
    NSInteger endTimeInMinutes = self.endHour * 60 + self.endMinute;
    if (endTimeInMinutes - startTimeInMinutes < 1) {
        return YES;
    }
    return NO;
}

- (BOOL)isValidEndTime{
    NSInteger startTimeInMinutes = self.startHour * 60 + self.startMinute;
    NSInteger endTimeInMinutes = self.endHour * 60 + self.endMinute;
    if (endTimeInMinutes - startTimeInMinutes < 0) {
        return YES;
    }
    return NO;
}
@end
