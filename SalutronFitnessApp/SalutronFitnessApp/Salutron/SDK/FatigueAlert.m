//
//  FatigueAlert.m
//  BLEManager
//
//  Created by Kevin on 11/11/14
//  Copyright (c) 2013 Salutron Inc. All rights reserved.
//

#import "FatigueAlert.h"

@implementation FatigueAlert

@synthesize type;                   // 0 - Status 1 - threshold
@synthesize status;                 // 0 - inactive 1 - active (Default Active)
@synthesize threshold;              // 1 - 80 (default 50%)
@synthesize interval;               // 1 - 6 (equivalent to 10-60 minites: default is 1)


static const bool LOG = NO;

/**
 * This method initializes the object.
 *
 * @return sleepSetting Initialized sleepSetting.
 */
- (id)init
{
    // Call the parent's init method.
    self = [super init];
    // Initialize own variables.
    if (self) {
    }
    return self;
}

/**
 * This method converts the ojbect to a readable string.
 *
 * @return string   NSString representation of the object.
 */
- (NSString *)description
{
    if (LOG) NSLog(@"FatigueAlert - description");
    return [NSString stringWithFormat:@"type: %i status: %i threshold: %i",
            type, status, threshold];
}

@end
