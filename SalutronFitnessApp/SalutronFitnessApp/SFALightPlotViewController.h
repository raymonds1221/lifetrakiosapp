//
//  SFALightPlotViewController.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 8/22/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFALightPlotViewControllerDelegate;

@interface SFALightPlotViewController : UIViewController

@property (weak, nonatomic) id<SFALightPlotViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *textFieldDateRange;
@property (weak, nonatomic) IBOutlet UIView *dateRangeBackgroundView;
@property (strong, nonatomic) NSDate *currentDate;

- (void)setContentsWithDate:(NSDate *)date;
- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year;
- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year;
- (void)setContentsWithYear:(NSInteger)year;
- (IBAction)showTableDataClicked:(UIButton *)sender;

@end


@protocol SFALightPlotViewControllerDelegate <NSObject>

- (void)lightPlotViewController:(SFALightPlotViewController *)viewController didChangeDateRange:(SFADateRange)dateRange;

@end