//
//  SFARegisterUserCell.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFARegisterUserCell.h"

@implementation SFARegisterUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    /*
    NSString *addPhotoImagePath = @"RegisterAddPicture";
    
    if (LANGUAGE_IS_FRENCH) {
        addPhotoImagePath = @"RegisterAddPicture_fr";
    }
    */
    [self.userImageButton setBackgroundImage:[UIImage imageNamed:@"frame_empty"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
