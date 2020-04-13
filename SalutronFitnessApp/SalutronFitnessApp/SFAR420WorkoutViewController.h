//
//  SFAR420WorkoutViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 11/6/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SFALinePlot.h"

@class SFAGraphView;

@protocol SFAR420WorkoutViewControllerDelegate;

@interface SFAR420WorkoutViewController : UIViewController

@property (nonatomic) BOOL isPortrait;
@property NSDate *date;

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

@property (weak, nonatomic) id <SFAR420WorkoutViewControllerDelegate> delegate;

- (IBAction)caloriesButtonPressed:(id)sender;
- (IBAction)heartRateButtonPressed:(id)sender;
- (IBAction)stepsButtonPressed:(id)sender;
- (IBAction)distanceButtonPressed:(id)sender;

- (void)setContentsWithDate:(NSDate *)date workoutIndex:(NSInteger)workoutIndex;
- (void)addGraphType:(SFAGraphType)graphType;
- (void)removeGraphType:(SFAGraphType)graphType;
- (void)resetScrollViewOffset;

@end

@protocol SFAR420WorkoutViewControllerDelegate <NSObject>

- (void)workoutResultsViewController:(SFAR420WorkoutViewController *)viewController didAddGraphType:(SFAGraphType)graphType;
- (void)workoutResultsViewController:(SFAR420WorkoutViewController *)viewController didRemoveGraphType:(SFAGraphType)graphType;

@end
