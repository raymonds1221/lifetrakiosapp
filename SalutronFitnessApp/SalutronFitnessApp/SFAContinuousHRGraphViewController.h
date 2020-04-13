//
//  SFAContinuousHRGraphViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 11/26/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFAGraphView.h"

@protocol SFAContinuousHRGraphViewControllerDelegate;

@interface SFAContinuousHRGraphViewController : UIViewController

@property (readwrite, nonatomic) BOOL isPortrait;

@property (weak, nonatomic) IBOutlet UIScrollView       *scrollView;
@property (weak, nonatomic) IBOutlet SFAGraphView       *graphView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewWidthConstraint;

@property (strong, nonatomic) NSDate *date;
@property (weak, nonatomic) IBOutlet UIView             *loadingView;

// Current Values
@property (strong, nonatomic) NSString      *currentTime;
@property (readwrite, nonatomic) NSInteger  currentHeartRate;
@property (readwrite, nonatomic) NSInteger  maxHeartRate;
@property (readwrite, nonatomic) NSInteger  minHeartRate;

@property (weak, nonatomic) id <SFAContinuousHRGraphViewControllerDelegate> delegate;

// Graph Methods

- (void)scrollToFirstRecord;

// Data Methods

- (void)getDataForDate:(NSDate *)date;

@end

@protocol SFAContinuousHRGraphViewControllerDelegate <NSObject>

- (void)graphViewController:(SFAContinuousHRGraphViewController *)graphViewController didChangeTime:(NSString *)time;
- (void)graphViewController:(SFAContinuousHRGraphViewController *)graphViewController didChangeHeartRate:(NSInteger)heartRate;
- (void)graphViewController:(SFAContinuousHRGraphViewController *)graphViewController didChangeMaxHeartRate:(NSInteger)maxHeartRate;
- (void)graphViewController:(SFAContinuousHRGraphViewController *)graphViewController didChangeMinHeartRate:(NSInteger)minHeartRate;

- (void)hrgraphViewControllerTouchStarted;
- (void)hrgraphViewControllerTouchEnded;


@end
