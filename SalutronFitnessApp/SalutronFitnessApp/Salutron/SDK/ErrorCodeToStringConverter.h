//
//  ErrorCodeToStringConverter.h
//  BLEManager
//
//  Created by Herman on 2/27/13.
//  Copyright (c) 2013 GV Concepts Inc. All rights reserved.
//
//  All information and materials contained herein are owned by GV Concepts, Inc.
//  and is protected by U.S. and international copyright laws.
//  All use, disclosure, dissemination, transfer, publication or reproduction
//  of these materials, in whole or in part, is prohibited, unless authorized
//  in writing by GV Concepts, Inc.
//  If copies of these materials are made with written authorization of
//  GV Concepts, Inc, all copies must contain this notice.
//

#import <Foundation/Foundation.h>
#import "ErrorCodes.h"

@interface ErrorCodeToStringConverter : NSObject

+ (NSString *)convertToString:(Status)status;

@end
