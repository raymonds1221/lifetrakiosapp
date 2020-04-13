//
//  NSDictionary+JSON.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/28/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

- (NSString *)JSONString
{
    NSData *data            = [NSJSONSerialization dataWithJSONObject:self
                                                              options:kNilOptions
                                                                error:nil];
    NSString *jsonString    = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

@end
