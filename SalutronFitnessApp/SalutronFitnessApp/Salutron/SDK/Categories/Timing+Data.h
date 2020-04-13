//
//  Timing+Data.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/10/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "Timing.h"

@interface Timing (Data)

+ (Timing *)timingWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionary;

@end
