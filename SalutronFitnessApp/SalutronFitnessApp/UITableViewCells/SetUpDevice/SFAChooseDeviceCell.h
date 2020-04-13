//
//  SFAChooseDeviceCell.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 1/24/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAChooseDeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *watchImage;
@property (weak, nonatomic) IBOutlet UILabel     *watchModelName;
@property (weak, nonatomic) IBOutlet UILabel     *signalStrengthLabel;
@property (weak, nonatomic) IBOutlet UIButton    *connectToDevice;

@end
