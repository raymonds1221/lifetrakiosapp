//
//  WorkoutSettingEntity+CoreDataProperties.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/2/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WorkoutSettingEntity+CoreDataProperties.h"

@implementation WorkoutSettingEntity (CoreDataProperties)

@dynamic type;
@dynamic hrLogRate;
@dynamic autoSplitType;
@dynamic autoSplitThreshold;
@dynamic zoneTrainType;
@dynamic zone0Upper;
@dynamic zone0Lower;
@dynamic zone1Lower;
@dynamic zone2Lower;
@dynamic zone3Lower;
@dynamic zone4Lower;
@dynamic zone5Lower;
@dynamic zone5Upper;
@dynamic reserved;
@dynamic databaseUsage;
@dynamic databaseUsageMax;
@dynamic reconnectTimeout;
@dynamic device;

@end
