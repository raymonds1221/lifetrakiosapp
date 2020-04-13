//
//  SFAActigraphyViewController.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/10/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFAGraphView.h"

@protocol SFAActigraphyPlotTouchEvent;

@interface SFAActigraphyViewController : UIViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *totalSleepTimeHr;
@property (weak, nonatomic) IBOutlet UILabel *totalSleepTimeMin;
@property (weak, nonatomic) IBOutlet UILabel *sleepStart;
@property (weak, nonatomic) IBOutlet UILabel *sleepEnd;
@property (weak, nonatomic) IBOutlet UILabel *wokeUpCount;
@property (weak, nonatomic) IBOutlet UILabel *wokeUpLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UINavigationItem *navItem;
@property (strong, nonatomic) SFAGraphView *graphView;
@property (weak, nonatomic) id<SFAActigraphyPlotTouchEvent> plotDelegate;

@property (readwrite, nonatomic) BOOL isActigraphy;

- (void)changeDateRange:(SFADateRange)dateRange;

- (void)reloadView;
- (void)setContentsWithDate:(NSDate *) date;
- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year;
- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year;
- (void)setContentsWithYear:(NSInteger)year;

@end

@protocol SFAActigraphyPlotTouchEvent <NSObject>

- (void) plotSpace:(CPTPlotSpace *) plotSpace handleTouchDownEvent:(UIEvent *)event pointIndex:(CGPoint)point;
- (void) plotspace:(CPTPlotSpace *) plotSpace handleTouchUpEvent:(UIEvent *)event pointIndex:(CGPoint)point;
- (void) plotSpace:(CPTPlotSpace *) plotSpace handleDraggedEvent:(UIEvent *)event pointIndex:(CGPoint)point;
- (void)actigraphyViewController:(SFAActigraphyViewController *)viewController didChangeDateRange:(SFADateRange)dateRange;

@end
