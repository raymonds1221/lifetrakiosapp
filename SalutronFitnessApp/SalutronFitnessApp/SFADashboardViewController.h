//
//  SFADashboardViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/26/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatisticalDataHeaderEntity.h"

typedef enum
{
    SFADashboardItemBPM,
    SFADashboardItemSteps,
    SFADashboardItemDistance,
    SFADashboardItemCalories,
    SFADashboardItemSleep,
    SFADashboardItemWorkout
} SFADashboardItem;

@protocol SFADashboardDelegate;

@interface SFADashboardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic)     IBOutlet UITableView            *tableView;
@property (weak, nonatomic)     id <SFADashboardDelegate>       delegate;
@property (strong, nonatomic)   StatisticalDataHeaderEntity     *statisticalDataHeader;
@property (strong, nonatomic)   NSDate                          *date;

- (void)setContentsWithDate:(NSDate *)date;

@end

@protocol SFADashboardDelegate <NSObject>

- (void)dashboardViewController:(SFADashboardViewController *)viewController didSelectDashboardItem:(SFADashboardItem)dashboardItem;

- (void)didUpdateDashboardPositionInDashboardViewController:(SFADashboardViewController *)viewController;

@end
