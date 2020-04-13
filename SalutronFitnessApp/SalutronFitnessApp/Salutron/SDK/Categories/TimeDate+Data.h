//
//  TimeDate+Data.h
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/19/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "TimeDate.h"

@class TimeDateEntity;

@interface TimeDate (Data)

+ (void)saveWithTimeDate:(TimeDate *)timeDate;
+ (TimeDate *)getData;
+ (TimeDate *)getDataWithMACAddress:(NSString *)macAdress;
+ (TimeDate *)getUpdatedData;

+ (TimeDate *)timeDate;
+ (TimeDate *)timeDateWithDictionary:(NSDictionary *)dictionary;
+ (TimeDate *)timeDateWithTimeDateEntity:(TimeDateEntity *)entity;

- (NSDictionary *)dictionary;

- (BOOL)isEqualToTimeDate:(TimeDate *)timeDate;

@end
