//
//  SFAActigraphyGraphViewController.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/11/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFAGraphView.h"

@protocol SFAActigraphyGraphViewControllerDelegate;
@interface SFAActigraphyGraphViewController : UIViewController

@property (strong, nonatomic) IBOutlet SFAGraphView *graphView;
@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewWidthConstraint;
@property (weak, nonatomic) id <SFAActigraphyGraphViewControllerDelegate> delegate;

@property (readwrite, nonatomic) BOOL isPortrait;

- (void)setContentsWithDate:(NSDate *)date;
- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year;
- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year;
- (void)setContentsWithYear:(NSInteger)year;

@end

@protocol SFAActigraphyGraphViewControllerDelegate <NSObject>

- (void)didChangeActiveCount:(NSNumber *)activeTime;
- (void)didChangeWorkoutCount:(NSNumber *)workoutCount;
- (void)didChangeDeepSleepCount:(NSNumber *)deepSleepCount;
- (void)didChangeLightSleepCount:(NSNumber *)lightSleepCount;

- (void)didChangeTotalActiveTime:(NSString *)totalActiveTime;
- (void)didChangeTotalSleepTime:(NSString *)totalSleepTime;
- (void)didChangeTotalSedentaryTime:(NSString *)totalSedentaryTime;

- (void)didChangeTotalActiveTimeHour:(NSInteger)totalActiveTimeHour;
- (void)didChangeTotalActiveTimeMinute:(NSInteger)totalActiveTimeMinute;

- (void)didChangeCurrentDay:(NSString *)currentDay;

@end