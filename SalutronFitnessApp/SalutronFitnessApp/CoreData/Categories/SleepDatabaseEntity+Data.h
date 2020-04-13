//
//  SleepDatabaseEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SleepDatabaseEntity.h"

@interface SleepDatabaseEntity (Data)

+ (NSArray *)sleepDatabaseForDate:(NSDate *)date;
+ (NSArray *)sleepDatabasesDictionaryForDeviceEntity:(DeviceEntity *)device;
+ (NSArray *)sleepDatabasesWithArray:(NSArray *)array forDeviceEntity:(DeviceEntity *)deviceEntity;
+ (NSArray *)sleepDatabaseForDeviceEntity:(DeviceEntity *)device;
+ (NSArray *)sleepDatabasesWithStartingDateDictionaryForDeviceEntity:(DeviceEntity *)device;
+ (NSArray *)sleepDatabasesDictionaryForDeviceEntity:(DeviceEntity *)device forDate:(NSDate *)date;
- (NSInteger)adjustedSleepEndMinutes;
- (NSDictionary *)dictionary;

+ (void)setAllIsSyncedToServer:(BOOL)isSyncedToServer forDeviceEntity:(DeviceEntity *)deviceEntity;

@end
