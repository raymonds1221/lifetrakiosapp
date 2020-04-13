//
//  SFASettingsViewController+TableData.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 5/22/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASettingsViewController.h"

#import "SFAPreferenceCell.h"
#import "SFASettingsToggleCellWithDesc.h"
#import "SFASettingsCellWithDescription.h"
#import "SFASettingsToggleCell.h"
#import "SFASettingsCell.h"
#import "SFASettingsCellWithButton.h"
#import "SFASettingsIndentedToggleCell.h"
#import "SFASettingsIndentedCellWithButton.h"

@interface SFASettingsViewController (TableData) <SFAPreferenceCellDelegate, SFASettingsToggleCellWithDescDelegate, SFASettingsToggleCellDelegate, SFASettingsIndentedToggleCellDelegate, SFASettingsCellWithButtonDelegate, SFASettingsIndentedCellWithButtonDelegate>

- (NSUInteger)numberOfRowsInSection:(NSUInteger)section watchModel:(WatchModel)watchModel;

- (CGFloat)heightForHeaderInSection:(NSUInteger)section watchModel:(WatchModel)watchModel;

- (CGFloat)heightForFooterInSection:(NSInteger)section watchModel:(WatchModel)watchModel;

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath watchModel:(WatchModel)watchModel;

- (NSString *)titleForHeaderInSection:(NSUInteger)section watchModel:(WatchModel)watchModel;

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath watchModel:(WatchModel)watchModel;

@end
