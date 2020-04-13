//
//  SFAWorkoutGraphViewController.h
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/6/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFAGraphView;
@protocol SFAWorkoutGraphViewControllerDelegate;

@interface SFAWorkoutGraphViewController : UIViewController

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

@property (weak, nonatomic) id<SFAWorkoutGraphViewControllerDelegate> delegate;


- (void)addGraphType:(SFAGraphType)graphType;
- (void)removeGraphType:(SFAGraphType)graphType;
- (void)resetScrollViewOffset;

- (void)setContentsWithDate:(NSDate *)date workoutIndex:(NSInteger )index;

@end

@protocol SFAWorkoutGraphViewControllerDelegate <NSObject>

- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeTime:(NSString *)time;
- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeCalories:(NSInteger)calories;
- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeHeartRate:(NSInteger)heartRate;
- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeSteps:(NSInteger)steps;
- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeDistance:(CGFloat)distance;

- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeDataPoint:(NSInteger)index;
- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeTotalWorkoutTime:(NSInteger)workoutSeconds;
- (void)graphViewController:(SFAWorkoutGraphViewController *)graphViewController didChangeWorkoutEndTime:(NSString *)time;


@end