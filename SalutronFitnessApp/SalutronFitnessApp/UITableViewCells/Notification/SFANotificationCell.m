//
//  SFANotificationCell.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/23/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFANotificationCell.h"

@implementation SFANotificationCell

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

    // Configure the view for the selected state
}

#pragma mark - IBActions

- (IBAction)notificationSwitchValueChanged {
    if([self.delegate conformsToProtocol:@protocol(SFANotificationCellDelegate)] &&
       [self.delegate respondsToSelector:@selector(didNotificationValueChanged:notification:)])
    {
        if([self.notificationLabel.text isEqualToString:NOTIFICATION_INCOMING_CALL])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeIncomingCall];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_MISSED_CALL])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeMissedCall];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_SMS])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeSMS];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_MAIL])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeMail];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_VOICE_MAIL])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeVoiceMail];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_SCHEDULE])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeSchedule];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_NEWS])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeNews];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_SOCIAL])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeSocial];
        }
    }
}

- (IBAction)notificationCheckboxClicked:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if([self.delegate conformsToProtocol:@protocol(SFANotificationCellDelegate)] &&
       [self.delegate respondsToSelector:@selector(didNotificationValueChanged:notification:)])
    {
        if([self.notificationLabel.text isEqualToString:NOTIFICATION_INCOMING_CALL])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeIncomingCall];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_MISSED_CALL])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeMissedCall];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_SMS])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeSMS];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_MAIL])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeMail];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_VOICE_MAIL])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeVoiceMail];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_SCHEDULE])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeSchedule];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_NEWS])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeNews];
        }
        else if([self.notificationLabel.text isEqualToString:NOTIFICATION_SOCIAL])
        {
            [self.delegate didNotificationValueChanged:self notification:NotificationTypeSocial];
        }
    }
}

@end
