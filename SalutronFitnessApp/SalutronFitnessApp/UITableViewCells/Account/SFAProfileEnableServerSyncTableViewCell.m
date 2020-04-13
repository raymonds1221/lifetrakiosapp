//
//  SFAProfileEnableServerSyncTableViewCell.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 6/18/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAProfileEnableServerSyncTableViewCell.h"


@implementation SFAProfileEnableServerSyncTableViewCell

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
    
    if ([SFAUserDefaultsManager sharedManager].cloudSyncEnabled){
        [self.cellSwitch setOn:YES];
    }else{
        [self.cellSwitch setOn:NO];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
