//
//  SFAAutoSyncCell.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/27/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAAutoSyncCell.h"

@implementation SFAAutoSyncCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.syncFrequencyButton.titleLabel.minimumScaleFactor = 0.3f;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
