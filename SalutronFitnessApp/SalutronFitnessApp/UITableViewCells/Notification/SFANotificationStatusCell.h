//
//  SFANotificationStatusCell.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 9/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFANotificationStatusCellDelegate;

@interface SFANotificationStatusCell : UITableViewCell

@property (weak, nonatomic) id<SFANotificationStatusCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;

- (IBAction)didNotificationStatusValueChanged:(UISwitch *)sender;

@end

@protocol SFANotificationStatusCellDelegate <NSObject>

- (void)didNotificationStatusValueChanged:(UISwitch *)sender;

@end
