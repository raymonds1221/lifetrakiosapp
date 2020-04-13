//
//  NSMutableArray+Helper.h
//  GMOVIES
//
//  Created by John Dwaine Alingarog on 11/20/13.
//  Copyright (c) 2013 John Dwaine Alingarog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Helper)

- (void)invertData;
- (void)sortArrayWithKey:(NSString *)sort ascending:(BOOL)ascending;

@end
