//
//  SFAWelcomeWatchCell.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/17/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceEntity;

@interface SFAWelcomeWatchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *watchImage;
@property (weak, nonatomic) IBOutlet UIImageView *watchBackgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *watchModel;
@property (weak, nonatomic) IBOutlet UILabel *watchLastSync;

- (void)setContentsWithDevice:(DeviceEntity *)device;

@end
