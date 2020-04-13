//
//  SFACaloriesViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/2/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFAFitnessGraphViewController.h"

@protocol SFAFitnessResultsViewControllerDelegate;

@interface SFAFitnessResultsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView        *tableView;

@property (weak, nonatomic) IBOutlet UILabel *activeTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UIButton *buttonCalories;
@property (weak, nonatomic) IBOutlet UIButton *buttonHeartRate;
@property (weak, nonatomic) IBOutlet UIButton *buttonSteps;
@property (weak, nonatomic) IBOutlet UIButton *buttonDistance;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *metricLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UILabel *goalLabel;
@property (weak, nonatomic) IBOutlet UIImageView *graphImage;
@property (weak, nonatomic) IBOutlet UIImageView *goalImage;
@property (weak, nonatomic) IBOutlet UIImageView *graphBackgroundImage;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIView *progressBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *landscapeMetricsView;

@property (weak, nonatomic) IBOutlet UILabel *stepsGoalLabel;
@property (weak, nonatomic) IBOutlet UILabel *caloriesGoalLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceGoalLabel;

@property (weak, nonatomic) IBOutlet UIView *heartRateView;
@property (weak, nonatomic) IBOutlet UIView *stepsView;
@property (weak, nonatomic) IBOutlet UIView *caloriesView;
@property (weak, nonatomic) IBOutlet UIView *distanceView;
@property (weak, nonatomic) IBOutlet UIView *stepsProgressView;
@property (weak, nonatomic) IBOutlet UIView *distanceProgressView;
@property (weak, nonatomic) IBOutlet UIView *caloriesProgressView;

@property (weak, nonatomic) IBOutlet UIImageView *stepsGoalSuccess;
@property (weak, nonatomic) IBOutlet UIView *stepsGoalProgress;

@property (weak, nonatomic) IBOutlet UIImageView *distanceGoalSuccess;
@property (weak, nonatomic) IBOutlet UIView *distanceGoalProgress;

@property (weak, nonatomic) IBOutlet UIImageView *caloriesGoalSuccess;
@property (weak, nonatomic) IBOutlet UIView *caloriesGoalProgress;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *goalLabels;

@property (weak, nonatomic) IBOutlet UITextField *textFieldDateRange;
@property (weak, nonatomic) IBOutlet UIView *dateRangeBackgroundView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidthConstraint;
@property (readwrite, nonatomic) SFAGraphType graphType;

@property (weak, nonatomic) id <SFAFitnessResultsViewControllerDelegate> delegate;

@property (assign, nonatomic) NSInteger index;

// IBAction Methods

- (IBAction)didChangeDateRange:(id)sender;
- (IBAction)caloriesButtonPressed:(id)sender;
- (IBAction)heartRateButtonPressed:(id)sender;
- (IBAction)stepsButtonPressed:(id)sender;
- (IBAction)distanceButtonPressed:(id)sender;

// Graph Methods

- (void)initializeGraph;
- (void)initializeDummyGraph;
- (void)selectGraphType:(SFAGraphType)graphType;
- (void)deselectGraphType:(SFAGraphType)graphType;
- (void)addGraphType:(SFAGraphType)graphType;
- (void)removeGraphType:(SFAGraphType)graphType;
- (void)scrollToFirstRecord;

// Date Methods

- (void)changeDateRange:(SFADateRange)dateRange;

// Data Methods

- (void)setContentsWithDate:(NSDate *)date;
- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year;
- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year;
- (void)setContentsWithYear:(NSInteger)year;

@end

@protocol SFAFitnessResultsViewControllerDelegate <NSObject>

- (void)fitnessResultsViewController:(SFAFitnessResultsViewController *)viewController didAddGraphType:(SFAGraphType)graphType;
- (void)fitnessResultsViewController:(SFAFitnessResultsViewController *)viewController didRemoveGraphType:(SFAGraphType)graphType;
- (void)fitnessResultsViewController:(SFAFitnessResultsViewController *)viewController didChangeDateRange:(SFADateRange)dateRange;

@end
