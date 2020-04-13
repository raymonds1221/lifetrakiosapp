//
//  SFAGoalsData.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/17/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoalsEntity.h"
#import "DeviceEntity.h"

@interface SFAGoalsData : NSObject

+ (GoalsEntity *)goalsFromNearestDate:(NSDate *)dated
                               macAddress:(NSString *)macAddress
                        managedObject:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)goalsEntitesToDate:(NSDate *)toDate
                     macAddress:(NSString *)macAddress
                  managedObject:(NSManagedObjectContext *)managedObjectContext;

+ (GoalsEntity *)goalsForDate:(NSDate *)date
                  macAddress:(NSString *)macAddress
               managedObject:(NSManagedObjectContext *)managedObjectContext;

+ (BOOL)addGoalsWithSteps:(NSUInteger)steps
                 distance:(CGFloat)distance
                 calories:(NSUInteger)calories
                    sleep:(NSUInteger)sleep
                   device:(DeviceEntity *)device
            managedObject:(NSManagedObjectContext *)managedObjectContext;

@end