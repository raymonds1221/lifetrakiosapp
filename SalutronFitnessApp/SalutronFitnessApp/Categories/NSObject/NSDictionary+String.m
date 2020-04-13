//
//  NSDictionary+String.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDictionary+String.h"

@implementation NSDictionary (String)

- (NSString *)stringObjectForKey:(id)key
{
    id object = [self objectForKey:key];
    
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    } else {
        return [NSString stringWithFormat:@"%@", object];
    }
}

@end
