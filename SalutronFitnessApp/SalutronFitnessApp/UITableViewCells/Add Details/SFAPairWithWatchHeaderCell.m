//
//  SFAPairWithWatchHeaderCell.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/10/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAPairWithWatchHeaderCell.h"

@implementation SFAPairWithWatchHeaderCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)headerButtonClicked:(id)sender {
    [self.delegate headerCellButtonClicked];
}
@end
