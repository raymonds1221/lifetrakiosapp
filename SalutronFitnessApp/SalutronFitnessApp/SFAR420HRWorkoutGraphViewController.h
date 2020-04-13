//
//  SFAR420HRWorkoutGraphViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 11/11/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFAGraphView;
@protocol SFAR420HRWorkoutGraphViewControllerDelegate;

@interface SFAR420HRWorkoutGraphViewController : UIViewController

@property (nonatomic) BOOL isLandscape;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewHorizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewRightHorizontalSpace;


@property (weak, nonatomic) IBOutlet SFAGraphView           *graphView;
@property (weak, nonatomic) IBOutlet UIScrollView           *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *graphViewWidthConstraint;

@property (weak, nonatomic) IBOutlet UIView             *loadingView;
@property (weak, nonatomic) IBOutlet UILabel            *loadingLabel;

@property (readwrite, nonatomic) CGFloat                oldGraphViewHorizontalSpace;

@property (strong, nonatomic) NSMutableArray    *visiblePlots;

// Current Values
@property (strong, nonatomic) NSString      *currentTime;
@property (readwrite, nonatomic) NSInteger  currentCalories;
@property (readwrite, nonatomic) NSInteger  currentHeartRate;
@property (readwrite, nonatomic) NSInteger  currentSteps;
@property (readwrite, nonatomic) CGFloat    currentDistance;

@property (weak, nonatomic) id<SFAR420HRWorkoutGraphViewControllerDelegate> delegate;


- (void)addGraphType:(SFAGraphType)graphType;
- (void)removeGraphType:(SFAGraphType)graphType;
- (void)resetScrollViewOffset;

- (void)setContentsWithDate:(NSDate *)date workoutIndex:(NSInteger )index;

@end

@protocol SFAR420HRWorkoutGraphViewControllerDelegate <NSObject>

- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didChangeTime:(NSString *)time;
- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didChangeCalories:(NSInteger)calories;
- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didChangeHeartRate:(NSInteger)heartRate;
- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didChangeMinHeartRate:(NSInteger)heartRate;
- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didChangeMaxHeartRate:(NSInteger)heartRate;
- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didChangeSteps:(NSInteger)steps;
- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didChangeDistance:(CGFloat)distance;

- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didScroll:(CGPoint)offset;
- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didEndScroll:(CGPoint)offset;

- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didChangeDataPoint:(NSInteger)index;
- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didChangeTotalWorkoutTime:(NSInteger)workoutSeconds;
- (void)hrgraphViewController:(SFAR420HRWorkoutGraphViewController *)graphViewController didChangeWorkoutEndTime:(NSString *)time;


- (void)hrgraphViewControllerTouchStarted;

- (void)hrgraphViewControllerTouchEnded;


@end
