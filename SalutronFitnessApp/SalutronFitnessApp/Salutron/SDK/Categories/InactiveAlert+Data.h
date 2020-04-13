//
//  InactiveAlert+Data.h
//  SalutronFitnessApp
//
//  Created by Aci Cartagena on 9/5/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "InactiveAlert.h"

@interface InactiveAlert (Data)
+ (InactiveAlert *)inactiveAlert;
+ (InactiveAlert *)inactiveAlertWithDictionary:(NSDictionary *)dictionary;
+ (InactiveAlert *)inactiveAlertWithDefaultValues;

- (BOOL)isEqualToInactiveAlert:(InactiveAlert *)inactiveAlert;
- (NSDictionary *)dictionary;

@end
