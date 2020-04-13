//
//  SFASettingsPromptCell.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/1/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASettingsPromptCell.h"

@implementation SFASettingsPromptCell

- (void)setContents
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL promptChangeSettings = [userDefaults boolForKey:PROMPT_CHANGE_SETTINGS];
    
    self.labelYes.text = BUTTON_TITLE_YES_ALL_CAPS;
    self.labelNo.text = BUTTON_TITLE_NO_ALL_CAPS;
    
    if (promptChangeSettings) {
        self.yesButton.selected         = YES;
        self.noButton.selected          = NO;
    } else {
        self.yesButton.selected         = NO;
        self.noButton.selected          = YES;
    }
}

- (IBAction)yesButtonPressed:(id)sender
{
    self.yesButton.selected         = YES;
    self.noButton.selected          = NO;
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:PROMPT_CHANGE_SETTINGS];
    [userDefaults synchronize];
    DDLogInfo(@"PROMPT_CHANGE_SETTINGS : %d", [userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]);
}

- (IBAction)noButtonPressed:(id)sender
{
    self.yesButton.selected         = NO;
    self.noButton.selected          = YES;
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:PROMPT_CHANGE_SETTINGS];
    [userDefaults setInteger:/*SyncOptionApp*/SyncOptionWatch forKey:SYNC_OPTION];
    [userDefaults synchronize];
    DDLogInfo(@"PROMPT_CHANGE_SETTINGS : %d", [userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]);
}

@end
