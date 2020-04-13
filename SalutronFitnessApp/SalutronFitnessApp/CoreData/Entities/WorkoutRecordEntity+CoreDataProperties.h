//
//  WorkoutRecordEntity+CoreDataProperties.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/2/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WorkoutRecordEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutRecordEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *hr1;
@property (nullable, nonatomic, retain) NSNumber *hr2;
@property (nullable, nonatomic, retain) NSNumber *hr3;
@property (nullable, nonatomic, retain) NSNumber *hr4;
@property (nullable, nonatomic, retain) NSNumber *hr5;
@property (nullable, nonatomic, retain) NSNumber *hr6;
@property (nullable, nonatomic, retain) NSNumber *hr7;
@property (nullable, nonatomic, retain) NSNumber *hr8;
@property (nullable, nonatomic, retain) NSNumber *stopHour;
@property (nullable, nonatomic, retain) NSNumber *stopMinute;
@property (nullable, nonatomic, retain) NSNumber *stopSecond;
@property (nullable, nonatomic, retain) NSNumber *stopHundredths;
@property (nullable, nonatomic, retain) NSNumber *calories;
@property (nullable, nonatomic, retain) NSNumber *distance;
@property (nullable, nonatomic, retain) NSNumber *steps;
@property (nullable, nonatomic, retain) NSNumber *splitHour;
@property (nullable, nonatomic, retain) NSNumber *splitMinute;
@property (nullable, nonatomic, retain) NSNumber *splitSecond;
@property (nullable, nonatomic, retain) NSNumber *splitHundredhts;
@property (nullable, nonatomic, retain) NSNumber *recordType;
@property (nullable, nonatomic, retain) WorkoutHeaderEntity *workoutHeader;

@end

NS_ASSUME_NONNULL_END
