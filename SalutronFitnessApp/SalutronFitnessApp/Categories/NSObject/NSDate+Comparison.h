//
//  NSDate+Comparison.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/12/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Comparison)

- (NSComparisonResult)compareToDate:(NSDate *)date;
- (BOOL)isToday;
- (BOOL)isTomorrow;
- (BOOL)isYesterday;

@end
