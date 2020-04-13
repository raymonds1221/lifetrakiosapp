//
//  Notification+Coding.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/24/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "Notification+Coding.h"

#define TYPE                @"type"
#define NOTI_SIMPLE_ALERT   @"simple_alert"
#define NOTI_EMAIL          @"noti_email"
#define NOTI_NEWS           @"noti_news"
#define NOTI_INCOMING_CALL  @"noti_incoming_call"
#define NOTI_MISSED_CALL    @"noti_missed_call"
#define NOTI_SMS            @"noti_sms"
#define NOTI_VOICE_MAIL     @"noti_voice_mail"
#define NOTI_SCHEDULE       @"noti_schedule"
#define NOTI_HIGHTPRIO      @"noti_hightprio"
#define NOTI_SOCIAL         @"noti_social"

@implementation Notification (Coding)

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.type               = [aDecoder decodeIntForKey:TYPE];
        self.noti_simpleAlert   = [aDecoder decodeBoolForKey:NOTI_SIMPLE_ALERT];
        self.noti_email         = [aDecoder decodeBoolForKey:NOTI_EMAIL];
        self.noti_news          = [aDecoder decodeBoolForKey:NOTI_NEWS];
        self.noti_incomingCall  = [aDecoder decodeBoolForKey:NOTI_INCOMING_CALL];
        self.noti_missedCall    = [aDecoder decodeBoolForKey:NOTI_MISSED_CALL];
        self.noti_sms           = [aDecoder decodeBoolForKey:NOTI_SMS];
        self.noti_voiceMail     = [aDecoder decodeBoolForKey:NOTI_VOICE_MAIL];
        self.noti_schedule      = [aDecoder decodeBoolForKey:NOTI_SCHEDULE];
        self.noti_hightPrio     = [aDecoder decodeBoolForKey:NOTI_HIGHTPRIO];
        self.noti_social        = [aDecoder decodeBoolForKey:NOTI_SOCIAL];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.type forKey:TYPE];
    [aCoder encodeBool:self.noti_simpleAlert forKey:NOTI_SIMPLE_ALERT];
    [aCoder encodeBool:self.noti_email forKey:NOTI_EMAIL];
    [aCoder encodeBool:self.noti_news forKey:NOTI_NEWS];
    [aCoder encodeBool:self.noti_incomingCall forKey:NOTI_INCOMING_CALL];
    [aCoder encodeBool:self.noti_missedCall forKey:NOTI_MISSED_CALL];
    [aCoder encodeBool:self.noti_sms forKey:NOTI_SMS];
    [aCoder encodeBool:self.noti_voiceMail forKey:NOTI_VOICE_MAIL];
    [aCoder encodeBool:self.noti_schedule forKey:NOTI_SCHEDULE];
    [aCoder encodeBool:self.noti_hightPrio forKey:NOTI_HIGHTPRIO];
    [aCoder encodeBool:self.noti_social forKey:NOTI_SOCIAL];
}

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    
    [copy setType:self.type];
    [copy setNoti_simpleAlert:self.noti_simpleAlert];
    [copy setNoti_email:self.noti_email];
    [copy setNoti_news:self.noti_news];
    [copy setNoti_incomingCall:self.noti_incomingCall];
    [copy setNoti_missedCall:self.noti_missedCall];
    [copy setNoti_sms:self.noti_sms];
    [copy setNoti_voiceMail:self.noti_voiceMail];
    [copy setNoti_schedule:self.noti_schedule];
    [copy setNoti_hightPrio:self.noti_hightPrio];
    [copy setNoti_social:self.noti_social];
    
    return copy;
}

@end
