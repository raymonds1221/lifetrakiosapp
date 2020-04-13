//
//  SFASettingsToggleCellWithDescription.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 5/4/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFASettingsToggleCellWithDescDelegate;

@interface SFASettingsToggleCellWithDesc : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UISwitch *toggleButton;
@property (strong, nonatomic) id<SFASettingsToggleCellWithDescDelegate> delegate;

- (IBAction)buttonToggled:(id)sender;

@end


@protocol SFASettingsToggleCellWithDescDelegate <NSObject>

- (void)toggleButtonWithDescValueChanged:(id)sender withValue:(BOOL)isOn andLabelTitle:(NSString *)title andCellTag:(int)cellTag;

@end