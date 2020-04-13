//
//  Timing+Data.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/10/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "Timing+Data.h"

@implementation Timing (Data)

+ (Timing *)timingWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        
        NSNumber *smartForSleep = [dictionary objectForKey:API_TIMING_SMART_FOR_SLEEP];
        
        Timing *timing = [[Timing alloc] init];
        timing.smartForSleep = smartForSleep.boolValue;
        timing.smartForWrist = [SFAUserDefaultsManager sharedManager].timing.smartForWrist;//smartForWrist.boolValue;
    
        [SFAUserDefaultsManager sharedManager].timing = timing;
        return timing;
    }
    return nil;

}

- (NSDictionary *)dictionary
{
    NSDictionary *dictionary    = @{API_TIMING_SMART_FOR_SLEEP  : @(self.smartForSleep)};
    return dictionary;
}

@end
