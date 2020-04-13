//
//  SFASleepLogsGraphViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/27/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFASleepLogsGraphViewControllerDelegate;

@interface SFASleepLogsGraphViewController : UIViewController

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *graphView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftPaddingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightPaddingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewWidthConstraint;
@property (weak, nonatomic) id <SFASleepLogsGraphViewControllerDelegate> delegate;

- (void)setContentsWithDate:(NSDate *)date sleepLogs:(NSArray *)sleepLogs;

@end

@protocol SFASleepLogsGraphViewControllerDelegate <NSObject>

- (void)sleepLogsGraphViewController:(SFASleepLogsGraphViewController *)viewController didSelectSleepLog:(SleepDatabaseEntity *)sleepLog;

@end