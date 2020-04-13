//
//  NSMutableArray+Helper.m
//  GMOVIES
//
//  Created by John Dwaine Alingarog on 11/20/13.
//  Copyright (c) 2013 John Dwaine Alingarog. All rights reserved.
//

#import "NSMutableArray+Helper.h"

@implementation NSMutableArray (Helper)

#pragma mark - Public instance methods
- (void)invertData
{
    NSMutableArray *_dataArray   = self.mutableCopy;
    
    [self removeAllObjects];
    //start inverting data
    for (int i = _dataArray.count - 1; i>= 0; i--)
    {
        [self addObject:_dataArray[i]];
    }
}

- (void)sortArrayWithKey:(NSString *)sort ascending:(BOOL)ascending
{
    NSSortDescriptor *_sortDescriptor   = [NSSortDescriptor sortDescriptorWithKey:sort ascending:ascending];
    [self sortUsingDescriptors:@[_sortDescriptor]];
}

@end
