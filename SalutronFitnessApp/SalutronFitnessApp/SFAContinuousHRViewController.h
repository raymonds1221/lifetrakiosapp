//
//  SFAContinuousHRViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 11/26/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SFAContinuousHRViewControllerDelegate;

@interface SFAContinuousHRViewController : UIViewController

@property (nonatomic) BOOL isPortrait;
@property NSDate *date;

@property (weak, nonatomic) IBOutlet UILabel                *activeTimeLabel;


@property (weak, nonatomic) id <SFAContinuousHRViewControllerDelegate> delegate;

- (void)setContentsWithDate:(NSDate *)date;
- (void)scrollToFirstRecord;

@end

@protocol SFAContinuousHRViewControllerDelegate <NSObject>

- (void)heartRateViewController:(SFAContinuousHRViewController *)viewController didChangeDateRange:(SFADateRange)dateRange;

@end
