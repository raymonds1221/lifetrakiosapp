//
//  Calibration_Data.h
//  BLEManager
//
//  Created by Kevin on 23/7/13.
//  Copyright (c) 2013 Salutron Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Notification : NSObject

@property (assign, nonatomic) unsigned char type;                           //
@property (assign, nonatomic) bool noti_simpleAlert;                        // 0 - Off, 1 - ON
@property (assign, nonatomic) bool noti_email;                              // 0 - Off, 1 - ON
@property (assign, nonatomic) bool noti_news;                               // 0 - Off, 1 - ON
@property (assign, nonatomic) bool noti_incomingCall;                       // 0 - Off, 1 - ON
@property (assign, nonatomic) bool noti_missedCall;                         // 0 - Off, 1 - ON
@property (assign, nonatomic) bool noti_sms;                                // 0 - Off, 1 - ON
@property (assign, nonatomic) bool noti_voiceMail;                          // 0 - Off, 1 - ON
@property (assign, nonatomic) bool noti_schedule;                           // 0 - Off, 1 - ON
@property (assign, nonatomic) bool noti_hightPrio;                          // 0 - Off, 1 - ON
@property (assign, nonatomic) bool noti_social;                             // 0 - Off, 1 - ON

@end
