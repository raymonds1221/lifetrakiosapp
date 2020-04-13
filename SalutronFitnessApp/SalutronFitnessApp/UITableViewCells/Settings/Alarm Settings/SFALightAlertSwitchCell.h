//
//  SFALightAlertSwitchCell.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/1/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const switchCellIdentifier = @"lightAlertSwitchCell";

@interface SFALightAlertSwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *status;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end
