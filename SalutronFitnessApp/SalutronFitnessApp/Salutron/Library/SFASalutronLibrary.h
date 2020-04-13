//
//  SFASalutronLibrary.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/26/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "StatisticalDataPointEntity+StatisticalDataPointEntityCategory.h"
#import "DeviceEntity.h"

@interface SFASalutronLibrary : NSObject

- (id) initWithManagedObjectContext:(NSManagedObjectContext *) managedObjectContext;
- (BOOL) isStatisticalDataHeaderExists:(StatisticalDataHeader *) dataHeader entity:(StatisticalDataHeaderEntity **) entity;
- (BOOL) isStatisticalDataPointExists: (StatisticalDataPoint *) dataPoint
                               entity:(StatisticalDataPointEntity **) entity;
- (BOOL) isStatisticalDataHeaderUpdated:(StatisticalDataHeader *) dataHeader
                                 entity:(StatisticalDataHeaderEntity *) entity;
- (BOOL) saveChanges:(NSError **) error;
- (DeviceEntity *)deviceEntityWithMacAddress:(NSString *)macAddress;
- (DeviceEntity *)newDeviceEntityWithUUID:(NSString *)uuid
                                     name:(NSString *)name
                               macAddress:(NSString *)macAddress
                        modelNumberString:(NSString *)modelNumberString
                           modelNumberInt:(NSNumber *)modelNumberInt;

@end
