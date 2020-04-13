//
//  SFANotificationCell.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/23/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NOTIFICATION_INCOMING_CALL      NSLocalizedString(@"Incoming Call", nil)
#define NOTIFICATION_MISSED_CALL        NSLocalizedString(@"Missed Call", nil)
#define NOTIFICATION_SMS                NSLocalizedString(@"SMS", nil)
#define NOTIFICATION_MAIL               NSLocalizedString(@"Mail", nil)
#define NOTIFICATION_VOICE_MAIL         NSLocalizedString(@"Voice Mail", nil)
#define NOTIFICATION_SCHEDULE           NSLocalizedString(@"Schedule", nil)
#define NOTIFICATION_NEWS               NSLocalizedString(@"News", nil)
#define NOTIFICATION_SOCIAL             NSLocalizedString(@"IM/Social", nil)

@protocol SFANotificationCellDelegate;

@interface SFANotificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UIButton *notificationCheckbox;
@property (weak, nonatomic) id<SFANotificationCellDelegate> delegate;

- (IBAction)notificationSwitchValueChanged;
- (IBAction)notificationCheckboxClicked:(id)sender;

@end

typedef enum {
    NotificationTypeMail,
    NotificationTypeNews,
    NotificationTypeIncomingCall,
    NotificationTypeMissedCall,
    NotificationTypeSMS,
    NotificationTypeVoiceMail,
    NotificationTypeSchedule,
    NotificationTypeSocial
} NotificationType;

@protocol SFANotificationCellDelegate <NSObject>

- (void) didNotificationValueChanged:(id)sender notification:(NotificationType)notificationType;

@end
