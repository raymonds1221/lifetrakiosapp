//
//  SFAFitnessGraphViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/4/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFAGraphView, StatisticalDataPointEntity;

@protocol SFAFitnessGraphViewControllerDelegate;

@interface SFAFitnessGraphViewController : UIViewController

@property (readwrite, nonatomic) BOOL isPortrait;

@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic) IBOutlet SFAGraphView       *graphView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewWidthConstraint;

@property (weak, nonatomic) id <SFAFitnessGraphViewControllerDelegate, UIScrollViewDelegate> delegate;

// Current Values
@property (strong, nonatomic) NSString      *currentTime;
@property (readwrite, nonatomic) NSInteger  currentCalories;
@property (readwrite, nonatomic) NSInteger  currentHeartRate;
@property (readwrite, nonatomic) NSInteger  currentSteps;
@property (readwrite, nonatomic) CGFloat    currentDistance;

// Total Values

@property (readwrite, nonatomic) NSInteger  totalCalories;
@property (readwrite, nonatomic) NSInteger  totalHeartRate;
@property (readwrite, nonatomic) CGFloat    totalSteps;
@property (readwrite, nonatomic) CGFloat    totalDistance;

// Graph Methods

- (void)initializeGraph;
- (void)initializeDummyGraph;
- (void)reloadGraph;
- (void)addGraphType:(SFAGraphType)graphType;
- (void)removeGraphType:(SFAGraphType)graphType;
- (NSInteger)barPlotCount;
- (void)scrollToFirstRecord;

// Data Methods

- (void)setContentsWithDate:(NSDate *)date;
- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year;
- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year;
- (void)setContentsWithYear:(NSInteger)year;

@end

@protocol SFAFitnessGraphViewControllerDelegate <NSObject>

- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didChangeTime:(NSString *)time;
- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didChangeCalories:(NSInteger)calories;
- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didChangeHeartRate:(NSInteger)heartRate;
- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didChangeSteps:(NSInteger)steps;
- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didChangeDistance:(CGFloat)distance;

@optional

- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didGetTotalCalories:(NSInteger)calories;
- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didGetTotalHeartRate:(NSInteger)heartRate;
- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didGetTotalSteps:(NSInteger)steps;
- (void)graphViewController:(SFAFitnessGraphViewController *)graphViewController didGetTotalDistance:(CGFloat)distance;

@end