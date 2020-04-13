//
//  SFARewardsTableViewCell.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 6/16/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

#define REWARDS_CELL_IDENTIFIER @"RewardsCellIdentifier"

@protocol SFARewardsCellDelegate <NSObject>

- (void)connectButtonSelected:(id)sender;

@end

@interface SFARewardsTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *rewardsTitle;
@property (weak, nonatomic) IBOutlet UILabel *rewardsDescription;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, getter = isUserConnected) BOOL userConnected;
@property (weak, nonatomic) id<SFARewardsCellDelegate> delegate;

- (void)showConnectButton;
- (void)showDisconnectButton;


@end
