//
//  SFAMainViewController.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/11/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SPCalendarMonthJanuary = 1,
    SPCalendarMonthFebruary,
    SPCalendarMonthMarch,
    SPCalendarMonthApril,
    SPCalendarMonthMay,
    SPCalendarMonthJune,
    SPCalendarMonthJuly,
    SPCalendarMonthAugust,
    SPCalendarMonthSeptember,
    SPCalendarMonthOctober,
    SPCalendarMonthNovember,
    SPCalendarMonthDecember
} SPCalendarMonth;

@class CKCalendarView;
@class SFACalendarView;
@class DFDatePickerView;

@interface SFAMainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *calendarView;

@property (strong, nonatomic) NSDate                *selectedDate;
@property (readwrite, nonatomic) NSInteger          selectedWeek;
@property (readwrite, nonatomic) SPCalendarMonth    selectedMonth;
@property (readwrite, nonatomic) NSInteger          selectedYear;
@property (readwrite, nonatomic) SFACalendarMode    calendarMode;
@property (strong, nonatomic) SFACalendarView           *datePicker;

- (IBAction)overlayViewDidTap:(UITapGestureRecognizer *)sender;
- (IBAction)calendarViewDidPan:(UIPanGestureRecognizer *)sender;
- (IBAction)calendarViewDidTap:(UITapGestureRecognizer *)sender;
- (IBAction)calendarViewDidSwipeToUp:(id)sender;
- (IBAction)calendarViewDidSwipeToDown:(id)sender;

- (void)showCalendar;
- (void)hideCalendar;

- (void)showCalendarView;
- (void)hideCalendarView;

// Date Tools
- (NSDate *)nextDate;
- (NSDate *)previousDate;
- (NSInteger)nextWeek;
- (NSInteger)previousWeek;
- (SPCalendarMonth)nextMonth;
- (SPCalendarMonth)previousMonth;
- (NSInteger)yearForNextWeek;
- (NSInteger)yearForPreviousWeek;
- (NSInteger)yearForNextMonth;
- (NSInteger)yearForPreviousMonth;
- (NSInteger)nextYear;
- (NSInteger)previousYear;

- (void)setSelectedWeek:(NSInteger)selectedWeek ofYear:(NSInteger)year;
- (void)setSelectedMonth:(SPCalendarMonth)selectedMonth ofYear:(NSInteger)year;

- (void)reloadDatesWithData;

// Index Methods
- (NSString *)timeForIndex:(NSInteger)index;
- (NSString *)timeOfWeekStringForIndex:(NSInteger)index;
- (NSString *)dayOfMonthStringForIndex:(NSInteger)index month:(NSInteger)month year:(NSInteger)year;
- (NSString *)monthForIndex:(NSInteger)index;
- (NSString *)currentTimeForIndex:(NSInteger)index month:(NSInteger)month year:(NSInteger)year;

@end

@interface UIViewController (CalendarControllerExtension)

- (SFAMainViewController *)calendarController;

@end

@protocol SFACalendarControllerDelegate <NSObject>

@optional
- (void)calendarController:(SFAMainViewController *)calendarController didSelectDate:(NSDate *)date;
- (void)calendarController:(SFAMainViewController *)calendarController didSelectWeek:(NSInteger)week ofYear:(NSInteger)year;
- (void)calendarController:(SFAMainViewController *)calendarController didSelectMonth:(NSInteger)month ofYear:(NSInteger)year;
- (void)calendarController:(SFAMainViewController *)calendarController didSelectYear:(NSInteger)year;

@end