//
//  SFARewardsTableViewCell.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 6/16/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFARewardsTableViewCell.h"


@implementation SFARewardsTableViewCell

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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.connectButton addTarget:self action:@selector(connectButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showConnectButton
{
    [self.connectButton setTitle:BUTTON_TITLE_CONNECT forState:UIControlStateNormal];
    [self.connectButton setTitleColor:[UIColor colorWithRed:62.0f/255.0f green:190.0f/255.0f blue:107.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [self.connectButton setBackgroundImage:[UIImage imageNamed:@"rewards_connectbutton"] forState:UIControlStateNormal];

}

- (void)showDisconnectButton
{
    [self.connectButton setTitle:BUTTON_TITLE_DISCONNECT forState:UIControlStateNormal];
    [self.connectButton setTitleColor:[UIColor colorWithRed:238.0f/255.0f green:101.0f/255.0f blue:85.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [self.connectButton setBackgroundImage:[UIImage imageNamed:@"rewards_disconnect button"] forState:UIControlStateNormal];
}

- (void)connectButtonSelected:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(connectButtonSelected:)]){
        [self.delegate connectButtonSelected:self];
    }
}

@end
