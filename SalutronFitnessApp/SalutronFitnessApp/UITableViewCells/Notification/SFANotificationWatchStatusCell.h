//
//  SFANotificationWatchStatusCell.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 9/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFANotificationWatchStatusCellDelegate;

@interface SFANotificationWatchStatusCell : UITableViewCell

@property (weak, nonatomic) id<SFANotificationWatchStatusCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *watchStatusButton;

- (IBAction)didNotificationWatchStatusClicked:(UIButton *)sender;

@end

@protocol SFANotificationWatchStatusCellDelegate <NSObject>

- (void)didNotificationWatchStatusClicked:(UIButton *)sender;

@end
