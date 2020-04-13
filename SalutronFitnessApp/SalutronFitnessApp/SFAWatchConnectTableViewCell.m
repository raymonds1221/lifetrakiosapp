//
//  SFAWatchConnectTableViewCell.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/4/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAWatchConnectTableViewCell.h"

@implementation SFAWatchConnectTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)watchButtonClicked:(id)sender {
    [self.delegate watchButtonClickedWithWatchName:self.watchModel.text andCellTag:self.tag];
}
@end
