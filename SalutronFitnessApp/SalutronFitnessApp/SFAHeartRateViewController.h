//
//  SFAHeartRateViewController.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/4/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFALiveHeartRateView.h"

@protocol SFAHeartRateViewControllerDelegate;

@interface SFAHeartRateViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel                *bpmLabel;
@property (weak, nonatomic) IBOutlet UILabel                *activeTimeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl     *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel                *percent;
@property (weak, nonatomic) IBOutlet UIImageView            *percentImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *percentViewLeftConstraint;
@property (weak, nonatomic) IBOutlet SFALiveHeartRateView   *liveHeartRateView;

@property (weak, nonatomic) id <SFAHeartRateViewControllerDelegate> delegate;

- (IBAction)didChangeDateRange:(id)sender;

- (void)changeDateRange:(SFADateRange)dateRange;
- (void)setContentsWithDate:(NSDate *)date;
- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year;
- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year;
- (void)setContentsWithYear:(NSInteger)year;
- (void)scrollToFirstRecord;

@end

@protocol SFAHeartRateViewControllerDelegate <NSObject>

- (void)heartRateViewController:(SFAHeartRateViewController *)viewController didChangeDateRange:(SFADateRange)dateRange;

@end
