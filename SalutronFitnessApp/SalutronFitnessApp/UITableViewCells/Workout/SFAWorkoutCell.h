//
//  SFAWorkoutCell.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/24/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WorkoutInfoEntity;

@interface SFAWorkoutCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *workoutTitle;
@property (weak, nonatomic) IBOutlet UILabel *totalCalories;
@property (weak, nonatomic) IBOutlet UILabel *totalSteps;
@property (weak, nonatomic) IBOutlet UILabel *totalDistance;
@property (weak, nonatomic) IBOutlet UILabel *workoutStartTime;
@property (weak, nonatomic) IBOutlet UILabel *totalWorkoutTime;

- (void)setContentsWithWorkout:(WorkoutInfoEntity *)workout workoutIndex:(NSInteger)workoutIndex;

@end
