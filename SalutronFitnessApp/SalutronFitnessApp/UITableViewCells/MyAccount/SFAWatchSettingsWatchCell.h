//
//  SFAWatchSettingsWatchCell.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/16/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAWatchSettingsWatchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView   *watchImage;
@property (weak, nonatomic) IBOutlet UILabel    *watchModel;
@property (weak, nonatomic) IBOutlet UILabel    *watchLastSync;

- (void)setContentsWithWatchModel:(WatchModel)model;
- (NSString *)watchModelStringWithWatchModel:(WatchModel)model;
- (UIImage *)watchImageWithWatchModel:(WatchModel)model;
- (NSString *)lastSyncDateWithDeviceEntity:(DeviceEntity *)device;
@end
