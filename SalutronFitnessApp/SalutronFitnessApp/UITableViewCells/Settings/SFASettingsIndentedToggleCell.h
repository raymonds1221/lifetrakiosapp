//
//  SFASettingsIndentedToggleCell.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 5/4/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFASettingsIndentedToggleCellDelegate;

@interface SFASettingsIndentedToggleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UISwitch *toggleButton;
@property (strong, nonatomic) id<SFASettingsIndentedToggleCellDelegate> delegate;

- (IBAction)buttonToggled:(id)sender;

@end


@protocol SFASettingsIndentedToggleCellDelegate <NSObject>

- (void)indentedToggleButtonValueChanged:(id)sender withValue:(BOOL)isOn andLabelTitle:(NSString *)title withCellTag:(int)cellTag;

@end