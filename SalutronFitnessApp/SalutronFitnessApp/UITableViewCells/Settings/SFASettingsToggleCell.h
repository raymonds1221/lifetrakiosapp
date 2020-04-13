//
//  SFASettingsToggleCell.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 5/4/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFASettingsToggleCellDelegate;

@interface SFASettingsToggleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UISwitch *toggleButton;
@property (strong, nonatomic) id<SFASettingsToggleCellDelegate> delegate;

- (IBAction)buttonToggled:(id)sender;

@end


@protocol SFASettingsToggleCellDelegate <NSObject>

- (void)toggleButtonValueChanged:(id)sender withValue:(BOOL)isOn andLabelTitle:(NSString *)title withCellTag:(int)cellTag;

@end