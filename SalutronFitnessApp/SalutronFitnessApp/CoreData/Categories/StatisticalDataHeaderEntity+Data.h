//
//  StatisticalDataHeaderEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/7/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "StatisticalDataHeaderEntity.h"

@class StatisticalDataHeader, DeviceEntity;

@interface StatisticalDataHeaderEntity (Data)

+ (StatisticalDataHeaderEntity *)statisticalDataHeaderEntityWithStatisticalDataHeader:(StatisticalDataHeader *)statisticalDataHeader
                                                                         deviceEntity:(DeviceEntity *)deviceEntity
                                                                 managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSArray *)dataHeadersDictionaryForDeviceEntity:(DeviceEntity *)device;
+ (NSArray *)dataHeadersDictionaryWithContext:(NSManagedObjectContext *)context device:(DeviceEntity *)device;
+ (NSArray *)dataHeadersWithArray:(NSArray *)array forDeviceEntity:(DeviceEntity *)device;
+ (NSArray *)dataHeadersForDeviceEntity:(DeviceEntity *)device;
+ (void)setAllIsSyncedToServer:(BOOL)isSyncedToServer forDeviceEntity:(DeviceEntity *)deviceEntity;

+ (NSArray *)dataHeadersWithStartedDateDictionaryWithContext:(NSManagedObjectContext *)context device:(DeviceEntity *)device;

- (NSDictionary *)dictionary;

@end
