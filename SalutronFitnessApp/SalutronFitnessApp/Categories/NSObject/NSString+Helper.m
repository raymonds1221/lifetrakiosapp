//
//  NSString+Helper.m
//  WomensCircle
//
//  Created by John Dwaine Alingarog on 11/3/13.
//  Copyright (c) 2013 John Dwaine Alingarog. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

#pragma mark - Public instance methods
- (NSDate *)getDateFromStringWithFormat:(NSString *)dateFormat
{
    NSDateFormatter *_formatter    = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:dateFormat];
    return [_formatter dateFromString:self];
}

- (NSString *)removeWhiteSpaces
{
    NSString *_string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    return _string;
}

- (NSString *)extractFromString:(NSString *)firstString toString:(NSString *)toString
{
    NSRange _stringRange    = [self rangeOfString:firstString];
    NSString *_extracted    = [self substringFromIndex:_stringRange.location + 1];
    _stringRange            = [_extracted rangeOfString:toString];
    _extracted              = [_extracted substringToIndex:_stringRange.location];
    return _extracted;
}

- (NSString *)regexReplaceWithPattern:(NSString *)pattern
                             template:(NSString *)strTemplate
                              options:(NSMatchingOptions)options
{
    
    NSError *_error;
    NSString *_regExPattern         = pattern;
    NSRegularExpression *_regex     = [NSRegularExpression regularExpressionWithPattern:_regExPattern options:0 error:&_error];
    NSString *_replace              = [_regex stringByReplacingMatchesInString:self
                                                                       options:options
                                                                         range:NSMakeRange(0, self.length)
                                                                  withTemplate:strTemplate];
    return _replace;
}

- (NSString *)removeTimeHourFormat
{
    return [[self stringByReplacingOccurrencesOfString:LS_AM withString:@""] stringByReplacingOccurrencesOfString:LS_PM withString:@""];
}

- (BOOL)isEmpty
{
    NSString *_string   = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL _stringIsEmpty = (_string == NULL || _string == nil || [_string isEqual:[NSNull null]] || [_string isEqualToString:@""]);
    return _stringIsEmpty;
}

- (BOOL)isEmail
{
    NSString *regex = @"^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{1,})$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:self];
    
}

@end
