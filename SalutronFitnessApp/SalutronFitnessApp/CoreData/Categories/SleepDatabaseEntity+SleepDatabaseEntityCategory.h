//
//  SleepDatabaseEntity+SleepDatabaseEntityCategory.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/9/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SleepDatabaseEntity.h"
#import "SleepDatabase.h"

@interface SleepDatabaseEntity (SleepDatabaseEntityCategory)

+ (SleepDatabaseEntity *) sleepDatabaseEntityWithRecord: (SleepDatabase *) sleepDatabase
                                          managedObject:(NSManagedObjectContext *) managedObjectContext;


@end
