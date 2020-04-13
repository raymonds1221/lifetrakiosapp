//
//  SFAHeartRateGraphViewController.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/5/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFAGraphView.h"

@protocol SFAHeartRateGraphViewControllerDelegate;

@interface SFAHeartRateGraphViewController : UIViewController

@property (readwrite, nonatomic) BOOL isPortrait;

@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic) IBOutlet SFAGraphView       *graphView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewWidthConstraint;

// Current Values
@property (strong, nonatomic) NSString      *currentTime;
@property (readwrite, nonatomic) NSInteger  currentHeartRate;
@property (readwrite, nonatomic) NSInteger  maxHeartRate;
@property (readwrite, nonatomic) NSInteger  minHeartRate;

@property (weak, nonatomic) id <SFAHeartRateGraphViewControllerDelegate> delegate;

// Graph Methods

- (void)scrollToFirstRecord;

// Data Methods

- (void)setContentsWithDate:(NSDate *)date;
- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year;
- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year;
- (void)setContentsWithYear:(NSInteger)year;

@end

@protocol SFAHeartRateGraphViewControllerDelegate <NSObject>

- (void)graphViewController:(SFAHeartRateGraphViewController *)graphViewController didChangeTime:(NSString *)time;
- (void)graphViewController:(SFAHeartRateGraphViewController *)graphViewController didChangeHeartRate:(NSInteger)heartRate;
- (void)graphViewController:(SFAHeartRateGraphViewController *)graphViewController didChangeMaxHeartRate:(NSInteger)maxHeartRate;
- (void)graphViewController:(SFAHeartRateGraphViewController *)graphViewController didChangeMinHeartRate:(NSInteger)minHeartRate;

@end