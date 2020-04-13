//
//  DateEntity.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/21/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SleepDatabaseEntity, StatisticalDataHeaderEntity;

@interface DateEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * month;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) StatisticalDataHeaderEntity *header;
@property (nonatomic, retain) SleepDatabaseEntity *sleepdatabase;

@end
