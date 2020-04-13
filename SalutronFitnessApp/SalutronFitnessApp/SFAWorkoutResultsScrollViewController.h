//
//  SFAWorkoutResultsScrollViewController.h
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/6/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAWorkoutResultsScrollViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet UIView         *leftWorkoutResultsView;
@property (weak, nonatomic) IBOutlet UIView         *centerWorkoutResultsView;
@property (weak, nonatomic) IBOutlet UIView         *rightWorkoutResultsView;

@property (readwrite, nonatomic) NSInteger          workoutIndex;
@property (readwrite, nonatomic) NSInteger          workoutCount;

@end
