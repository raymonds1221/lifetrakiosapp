//
//  NightLightAlert+Data.h
//  SalutronFitnessApp
//
//  Created by Aci Cartagena on 9/5/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NightLightAlert.h"

@interface NightLightAlert (Data)

+ (NightLightAlert *)nightLightAlert;
+ (NightLightAlert *)nightLightAlertWithDictionary:(NSDictionary *)dictionary;
+ (NightLightAlert *)nightLightAlertWithDefaultValues;

- (BOOL)isEqualToNightLightAlert:(NightLightAlert *)nightLightAlert;
- (NSDictionary *)dictionary;

@end
