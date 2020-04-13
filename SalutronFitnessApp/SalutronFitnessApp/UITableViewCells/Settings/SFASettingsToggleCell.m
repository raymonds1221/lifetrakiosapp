//
//  SFASettingsToggleCell.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 5/4/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFASettingsToggleCell.h"

@implementation SFASettingsToggleCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonToggled:(id)sender {
    [self.delegate toggleButtonValueChanged:sender withValue:self.toggleButton.isOn andLabelTitle:self.labelTitle.text withCellTag:self.tag];
}
@end
