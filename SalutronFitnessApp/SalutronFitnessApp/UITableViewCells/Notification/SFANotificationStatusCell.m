
//
//  SFANotificationStatusCell.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 9/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFANotificationStatusCell.h"

@implementation SFANotificationStatusCell

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

- (IBAction)didNotificationStatusValueChanged:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(didNotificationStatusValueChanged:)]) {
        [self.delegate didNotificationStatusValueChanged:sender];
    }
}

@end
