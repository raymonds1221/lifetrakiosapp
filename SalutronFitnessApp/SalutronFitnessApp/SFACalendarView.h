//
//  SFACalendarView.h
//  SalutronFitnessApp
//
//  Created by John Bennedict Lorenzo on 12/13/13.
//  Copyright (c) 2013 Stratpoint. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SFACalendarDay,
    SFACalendarWeek,
    SFACalendarMonth,
    SFACalendarYear,
    SFACalendarCount
} SFACalendarMode;

@protocol SFACalendarViewDelegate;

@interface SFACalendarView : UIView

@property (strong, nonatomic) NSString *dateHeaderString;
@property (nonatomic,assign) id <SFACalendarViewDelegate> delegate;
/** Please update this value whenever the calendar mode should be changed */
@property (nonatomic,assign) SFACalendarMode calendarMode;
/** An NSDate that is currently selected, the selected dates is computed from this and the current calendar mode */
@property (nonatomic,strong) NSDate *selectedDate;
/** A collection of dates with data for indicating in the view */
@property (nonatomic,strong) NSArray *datesWithData;

@property (weak, nonatomic) IBOutlet UIButton *nextDateButton;
@property (weak, nonatomic) IBOutlet UIButton *previousDateButton;

/** Singleton of the calendar instance */
+ (SFACalendarView *)activeCalendarView;
/** Returns the active NSCalendar instance */
+ (NSCalendar *)activeCalendar;
/** Refreshes the calendar position so that it shows the currently 
  * selected date(s) on its center */
- (void)refreshCalendar;

/** Returns if the cell date is currently selected */
- (BOOL)isCellDateSelected:(NSDate *)date;
/** Returns the next date as per the calendar mode set */
- (NSDate *)nextDate;
/** Returns the previous date as per the calendar mode set */
- (NSDate *)previousDate;

@end

@protocol SFACalendarViewDelegate <NSObject>

- (void)calendar:(SFACalendarView *)calendar didSelectDate:(NSDate *)date;
- (void)calendarDidTapHeader:(SFACalendarView *)calendar;

@end