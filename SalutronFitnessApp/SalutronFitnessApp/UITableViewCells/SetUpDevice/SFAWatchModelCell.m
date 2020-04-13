//
//  SFAWatchModelCell.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/22/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAWatchModelCell.h"

@interface SFAWatchModelCell ()

- (void) connectToDeviceClick;

@end

@implementation SFAWatchModelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) displayInfo {
    if (self.watchModel == WatchModel_Move_C300_Android){
        self.watchModel = WatchModel_Move_C300;
    }
    switch (self.watchModel) {
        case WatchModel_Move_C300:
            self.watchImage.image = [UIImage imageNamed:WATCHIMAGE_C300];
            self.watchModelName.text = WATCHNAME_MOVE_C300;
            break;
        case WatchModel_Core_C200:
            self.watchImage.image = [UIImage imageNamed:@"core_c200.png"];
            self.watchModelName.text = WATCHNAME_CORE_C200;
            break;
        case WatchModel_Zone_C410:
            self.watchImage.image = [UIImage imageNamed:WATCHIMAGE_C410];
            self.watchModelName.text = WATCHNAME_ZONE_C410;
            break;
        case WatchModel_R420:
            self.watchImage.image = [UIImage imageNamed:WATCHIMAGE_R420];
            self.watchModelName.text = WATCHNAME_R420;
            break;
        case WatchModel_R450:
            self.watchImage.image = [UIImage imageNamed:@"WatchR415"];
            self.watchModelName.text = WATCHNAME_BRITE_R450;
            break;
        case WatchModel_R500:
            self.watchImage.image = [UIImage imageNamed:@"WatchR500"];
            self.watchModelName.text = WATCHNAME_R500;
            break;
        default:
            self.watchImage.image = [UIImage imageNamed:@"WatchC300"];
            break;
    }
    
    self.connectToDevice.layer.cornerRadius = 10;
//    self.connectToDevice.layer.borderWidth = 0.5f;
//    self.connectToDevice.layer.borderColor = [UIColor colorWithRed:0 green:112.0f/255.0f blue:1.0f alpha:1].CGColor;
    [self.connectToDevice addTarget:self action:@selector(connectToDeviceClick) forControlEvents:UIControlEventTouchDown];
}

- (void) connectToDeviceClick {
    if(self.delegate != nil)
        [self.delegate didClickOnConnectWithWatchModel:self.watchModel];
}

@end
