//
//  SleepDatabaseEntity.h
//  Pods
//
//  Created by Patricia Marie Cesar on 11/28/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DateEntity, DeviceEntity;

@interface SleepDatabaseEntity : NSManagedObject

@property (nonatomic, retain) NSDate * dateInNSDate;
@property (nonatomic, retain) NSNumber * deepSleepCount;
@property (nonatomic, retain) NSNumber * extraInfo;
@property (nonatomic, retain) NSNumber * lapses;
@property (nonatomic, retain) NSNumber * lightSleepCount;
@property (nonatomic, retain) NSNumber * sleepDuration;
@property (nonatomic, retain) NSNumber * sleepEndHour;
@property (nonatomic, retain) NSNumber * sleepEndMin;
@property (nonatomic, retain) NSNumber * sleepOffset;
@property (nonatomic, retain) NSNumber * sleepStartHour;
@property (nonatomic, retain) NSNumber * sleepStartMin;
@property (nonatomic, retain) NSNumber * isSyncedToServer;
@property (nonatomic, retain) DateEntity *date;
@property (nonatomic, retain) DeviceEntity *device;

@end
