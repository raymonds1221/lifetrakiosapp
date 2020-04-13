//
//  NSString+Helper.h
//  WomensCircle
//
//  Created by John Dwaine Alingarog on 11/3/13.
//  Copyright (c) 2013 John Dwaine Alingarog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

- (NSDate *)getDateFromStringWithFormat:(NSString *)dateFormat;

- (NSString *)removeWhiteSpaces;
- (NSString *)extractFromString:(NSString *)firstString toString:(NSString *)toString;
- (NSString *)regexReplaceWithPattern:(NSString *)pattern
                             template:(NSString *)strTemplate
                              options:(NSMatchingOptions)options;

- (NSString *)removeTimeHourFormat;

- (BOOL)isEmpty;

- (BOOL)isEmail;

@end
