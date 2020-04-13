//
//  SFALightPlotGraphViewController.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 8/22/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFAGraphView;
@protocol SFALightPlotGraphViewControllerDelegate;

@interface SFALightPlotGraphViewController : UIViewController

@property (weak, nonatomic) id<SFALightPlotGraphViewControllerDelegate> delegate;
@property (assign, nonatomic) SFADateRange dateRangeSelected;
@property (strong, nonatomic) NSMutableDictionary *computeLightDictionary;
@property (assign, nonatomic) CGFloat maxYTipValue;
@property (assign, nonatomic) CGFloat maxYTipValueInLux;

- (void)setContentsWithDate:(NSDate *)date;
- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year;
- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year;
- (void)setContentsWithYear:(NSInteger)year;
- (void)scrollToFirstRecord;

@end

@protocol SFALightPlotGraphViewControllerDelegate <NSObject>

- (void)graphViewController:(SFALightPlotGraphViewController *)graphViewController didChangeDataPoint:(NSInteger)index;

@end
