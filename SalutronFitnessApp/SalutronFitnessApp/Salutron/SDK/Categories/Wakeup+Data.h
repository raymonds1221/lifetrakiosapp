//
//  Wakeup+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "Wakeup.h"

@interface Wakeup (Data)

+ (Wakeup *)wakeup;
+ (Wakeup *)wakeupWithDictionary:(NSDictionary *)dictionary;
+ (Wakeup *)wakeupDefaultValues;

- (NSDictionary *)dictionary;

- (BOOL)isEqualToWakeupAlert:(Wakeup *)wakeup;

@end
