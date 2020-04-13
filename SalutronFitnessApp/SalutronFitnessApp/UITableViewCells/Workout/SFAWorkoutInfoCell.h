//
//  SFAWorkoutInfoCell.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 8/6/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WorkoutInfoEntity;
@class WorkoutHeaderEntity;

@interface SFAWorkoutInfoCell : UITableViewCell

@property (assign, nonatomic) NSInteger workoutIndex;

//date to be used in checking if spill over workout from previous day
@property (strong, nonatomic) NSDate *date;

- (void)setContentsWithWorkout:(WorkoutInfoEntity *)workout workoutIndex:(NSInteger)workoutIndex;

- (void)setContentsWithWorkoutHeader:(WorkoutHeaderEntity *)workout workoutIndex:(NSInteger)workoutIndex;
@end
