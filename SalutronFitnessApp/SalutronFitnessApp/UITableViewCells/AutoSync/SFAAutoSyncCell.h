//
//  SFAAutoSyncCell.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/27/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAAutoSyncCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *pairUnpairButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *autoSyncOptions;
@property (weak, nonatomic) IBOutlet UISwitch *autoSyncAlertSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoSyncSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoSyncTimeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *autoSyncAlertLabel;
@property (weak, nonatomic) IBOutlet UILabel *syncFrequencyLabel;
@property (weak, nonatomic) IBOutlet UIButton *syncFrequencyButton;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *syncDate;
@property (weak, nonatomic) IBOutlet UILabel *modelNumberString;
@property (weak, nonatomic) IBOutlet UIImageView *modelImage;
@property (weak, nonatomic) IBOutlet UIButton *manualSyncButton;


@end
