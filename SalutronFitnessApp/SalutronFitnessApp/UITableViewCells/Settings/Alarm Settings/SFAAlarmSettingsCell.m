//
//  SFAAlarmSettingsCell.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 8/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAAlarmSettingsCell.h"

@implementation SFAAlarmSettingsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
