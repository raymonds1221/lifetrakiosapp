//
//  AlertnessResetsDB.m
//  BLEManager
//
//  Created by Kevin on 11/11/14.
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

#import "AlertnessResetsDB.h"
#import "SH_Time.h"
#import "SH_Date.h"

@implementation AlertnessResets

@synthesize time;
@synthesize date;


static const bool LOG = NO;

/**
 * This method converts the ojbect to a readable string.
 *
 * @return string   NSString representation of the object.
 */
- (NSString *)description
{
    if (LOG) NSLog(@"AlertnessResets - description");
    return [NSString stringWithFormat:@"time: %@ date: %@", [time description], [date description]];
}

@end
