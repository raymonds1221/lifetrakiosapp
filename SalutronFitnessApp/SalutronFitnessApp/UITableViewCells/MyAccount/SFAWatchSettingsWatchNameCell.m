//
//  SFAWatchSettingsWatchNameCell.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/16/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "JDACoreData.h"
#import "DeviceEntity+Data.h"
#import "DeviceEntity+WatchName.h"

#import "JDAKeyboardAccessory.h"

#import "SFAWatchSettingsWatchNameCell.h"

@interface SFAWatchSettingsWatchNameCell () <UITextFieldDelegate>

@property (strong, nonatomic) NSString *previousWatchName;

@end

@implementation SFAWatchSettingsWatchNameCell

#pragma mark - UIView Methods

- (void)awakeFromNib
{
    // Set text field delegate
    self.watchName.delegate = self;
    
    // Set watch name keyboard accessory
    JDAKeyboardAccessory *keyboardAccessory = [[JDAKeyboardAccessory alloc] initWithDoneAccessoryWithBarStyle:UIBarStyleDefault];
    keyboardAccessory.currentView           = self.watchName;
    self.watchName.inputAccessoryView       = keyboardAccessory;
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.previousWatchName = textField.text;
    //textField.text = @"";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location == textField.text.length && [string isEqualToString:@" "]) {
        // ignore replacement string and add your own
        if (textField.text.length == 0) {
            textField.text = [textField.text stringByAppendingString:@""];
        }
        else{
            textField.text = [textField.text stringByAppendingString:@"\u00a0"];
        }
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSCharacterSet *whitespace      = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedString         = [textField.text stringByTrimmingCharactersInSet:whitespace];
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
    DeviceEntity *deviceEntity      = [DeviceEntity deviceEntityForMacAddress:macAddress];
    
    if (trimmedString.length == 0) {
        if (textField.text.length == 0) {
            textField.text = self.previousWatchName;
        } else {
            textField.text = [deviceEntity defaultWatchName];
        }
    }
    
    deviceEntity.name = textField.text;
    [[JDACoreData sharedManager] save];
}

@end
