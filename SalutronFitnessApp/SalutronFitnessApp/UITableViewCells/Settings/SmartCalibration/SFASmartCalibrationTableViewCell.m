//
//  SFASmartCalibrationTableViewCell.m
//  SalutronFitnessApp
//
//  Created by Dana Elisa Nicolas on 1/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASmartCalibrationTableViewCell.h"

@implementation SFASmartCalibrationTableViewCell

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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)checkButtonClicked:(id)sender {
    [self.delegate cellButtonClicked:sender andCellTitle:self.titleLabel.text];
}
@end
