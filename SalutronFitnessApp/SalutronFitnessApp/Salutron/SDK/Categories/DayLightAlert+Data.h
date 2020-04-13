//
//  DayLightAlert+Data.h
//  SalutronFitnessApp
//
//  Created by Aci Cartagena on 9/5/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "DayLightAlert.h"

@interface DayLightAlert (Data)

+ (DayLightAlert *)dayLightAlert;
+ (DayLightAlert *)dayLightAlertWithDefaultValues;
+ (DayLightAlert *)dayLightAlertWithDictionary:(NSDictionary *)dictionary;


- (BOOL)isEqualToDayLightAlert:(DayLightAlert *)dayLightAlert;
- (NSDictionary *)dictionary;

@end
