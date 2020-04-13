//
//  SFACompatibleAppsCell.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 1/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFACompatibleAppsCell.h"

#define ARGUS_URL [NSURL URLWithString:@"https://itunes.apple.com/ph/app/argus-motion-fitness-tracker/id624329444?mt=8"]
#define MAPMYFITNESS_URL [NSURL URLWithString:@"https://itunes.apple.com/ph/app/map-my-fitness-workout-trainer/id298903147?mt=8"]

@implementation SFACompatibleAppsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - IBActions

- (IBAction)didAddCompatibleApp {
    switch (self.compatibleApp) {
        case ARGUS:
            [[UIApplication sharedApplication] openURL:ARGUS_URL];
            break;
        case MAP_MY_FITNESS:
            [[UIApplication sharedApplication] openURL:MAPMYFITNESS_URL];
            break;
        default:
            break;
    }
}


@end
