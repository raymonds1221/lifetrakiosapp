//
//  SFAR420WorkoutGraphViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 11/9/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFAGraphView;
@protocol SFAR420WorkoutGraphViewControllerDelegate;

@interface SFAR420WorkoutGraphViewController : UIViewController

@property (nonatomic) BOOL isLandscape;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewRightHorizontalSpace;


@property (weak, nonatomic) IBOutlet SFAGraphView           *graphView;
@property (weak, nonatomic) IBOutlet UIScrollView           *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *graphViewWidthConstraint;

@property (readwrite, nonatomic) CGFloat                oldGraphViewHorizontalSpace;

@property (strong, nonatomic) NSMutableArray    *visiblePlots;

// Current Values
@property (strong, nonatomic) NSString      *currentTime;
@property (readwrite, nonatomic) NSInteger  currentCalories;
@property (readwrite, nonatomic) NSInteger  currentHeartRate;
@property (readwrite, nonatomic) NSInteger  currentSteps;
@property (readwrite, nonatomic) CGFloat    currentDistance;

@property (weak, nonatomic) id<SFAR420WorkoutGraphViewControllerDelegate> delegate;


- (void)addGraphType:(SFAGraphType)graphType;
- (void)removeGraphType:(SFAGraphType)graphType;
- (void)resetScrollViewOffset;

- (void)setContentsWithDate:(NSDate *)date workoutIndex:(NSInteger )index;

@end

@protocol SFAR420WorkoutGraphViewControllerDelegate <NSObject>

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeTime:(NSString *)time;
- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeCalories:(NSInteger)calories;
- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeHeartRate:(NSInteger)heartRate;
- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeMinHeartRate:(NSInteger)heartRate;
- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeMaxHeartRate:(NSInteger)heartRate;

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeSteps:(NSInteger)steps;
- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeDistance:(CGFloat)distance;

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeDataPoint:(NSInteger)index;
- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeTotalWorkoutTime:(NSInteger)workoutSeconds;
- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didChangeWorkoutEndTime:(NSString *)time;



- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didScroll:(CGPoint)yValue;

- (void)graphViewController:(SFAR420WorkoutGraphViewController *)graphViewController didEndScroll:(CGPoint)yValue;


- (void)graphViewControllerTouchStarted;

- (void)graphViewControllerTouchEnded;

@end