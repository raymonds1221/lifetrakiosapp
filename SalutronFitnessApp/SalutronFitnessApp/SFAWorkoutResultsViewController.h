//
//  SFAWorkoutResultsViewController.h
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/6/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFALinePlot.h"

@class SFAGraphView;

@protocol SFAWorkoutResultsViewControllerDelegate;

@interface SFAWorkoutResultsViewController : UIViewController

@property (nonatomic) BOOL isPortrait;

@property (weak, nonatomic) IBOutlet UILabel *labelCalories;
@property (weak, nonatomic) IBOutlet UILabel *labelActiveTime;
@property (weak, nonatomic) IBOutlet UILabel *labelHeartRate;
@property (weak, nonatomic) IBOutlet UILabel *labelSteps;
@property (weak, nonatomic) IBOutlet UILabel *labelMiles;

@property (weak, nonatomic) IBOutlet UIButton *caloriesButton;
@property (weak, nonatomic) IBOutlet UIButton *heartRateButton;
@property (weak, nonatomic) IBOutlet UIButton *stepsButton;
@property (weak, nonatomic) IBOutlet UIButton *distanceButton;

@property (weak, nonatomic) IBOutlet UIImageView *imagePlayHead;
@property (assign, nonatomic) NSUInteger workoutIndex;

@property (weak, nonatomic) id <SFAWorkoutResultsViewControllerDelegate> delegate;

- (IBAction)caloriesButtonPressed:(id)sender;
- (IBAction)heartRateButtonPressed:(id)sender;
- (IBAction)stepsButtonPressed:(id)sender;
- (IBAction)distanceButtonPressed:(id)sender;

- (void)setContentsWithDate:(NSDate *)date workoutIndex:(NSInteger)workoutIndex;
- (void)addGraphType:(SFAGraphType)graphType;
- (void)removeGraphType:(SFAGraphType)graphType;
- (void)resetScrollViewOffset;

@end

@protocol SFAWorkoutResultsViewControllerDelegate <NSObject>

- (void)workoutResultsViewController:(SFAWorkoutResultsViewController *)viewController didAddGraphType:(SFAGraphType)graphType;
- (void)workoutResultsViewController:(SFAWorkoutResultsViewController *)viewController didRemoveGraphType:(SFAGraphType)graphType;

@end
