//
//  SFACalendarView.m
//  SalutronFitnessApp
//
//  Created by John Bennedict Lorenzo on 12/13/13.
//  Copyright (c) 2013 Stratpoint. All rights reserved.
//

#import "SFACalendarView.h"
#import "SFAYearTableView.h"
#import "DayFlow.h"

#import "TimeDate+Data.h"


static NSString *const kCalendarDateFormat1  = @"MMM dd, yyyy";
static NSString *const kCalendarDateFormat2  = @"dd MMM, yyyy";
static NSString *const kCalendarMonthFormat = @"MMMM YYYY";
static NSString *const kCalendarYearFormat  = @"YYYY";

@interface SFACalendarView () <DFDatePickerViewControllerDelegate,UITableViewDelegate>
{
    DFDatePickerViewController  *_pickerController;
    IBOutlet UILabel            *_dateHeaderLabel;
    IBOutlet UIView             *_pickerTarget;
    IBOutlet SFAYearTableView   *_yearTableView;
    
    TimeDate                    *_timeDate;
}

- (IBAction)didTapHeader:(id)sender;

- (NSString *)dateStringFromDate:(NSDate *)date;
- (NSDate *)calendarDateFromDate:(NSDate *)date;

- (void)updateCalendarHighlighting;
- (IBAction)calendarViewDidPressNextButton:(id)sender;
- (IBAction)calendarViewDidPressPreviousButton:(id)sender;

@end

@implementation SFACalendarView

@synthesize selectedDate=_selectedDate;

static SFACalendarView *_activeInstance = nil;

+ (SFACalendarView *)activeCalendarView
{
    return _activeInstance;
}

+ (NSCalendar *)activeCalendar
{
    return [NSCalendar currentCalendar];
}

- (void)commonInit
{
    _activeInstance = self;
    
    _pickerController.delegate = nil;
    [_pickerController.datePickerView removeFromSuperview];
    _pickerController = nil;
    _pickerController = [DFDatePickerViewController new];
    _pickerController.delegate = self;
    _pickerController.view.frame = _pickerTarget.frame;
    
    _timeDate = [TimeDate getData];
    
    self.backgroundColor = UIColorFromRGB(54, 60, 64);
    _dateHeaderLabel.textColor = UIColorFromRGB(195,217,230);
    
    [self addSubview:_pickerController.view];
    _pickerController.datePickerView.selectedDate = [self calendarDateFromDate:[NSDate date]];

    [self updateHeaderLabel];
}

- (void)didMoveToSuperview
{
    [self commonInit];
}

#pragma mark - Public

- (void)setSelectedDate:(NSDate *)selectedDate
{
    if (![_pickerController.datePickerView.selectedDate isEqualToDate:selectedDate])
        _pickerController.datePickerView.selectedDate = selectedDate;//[self calendarDateFromDate:selectedDate];
    
    [self refreshCalendar];
}

- (NSDate *)selectedDate
{
    return _pickerController.datePickerView.selectedDate;
}

- (void)setCalendarMode:(SFACalendarMode)calendarMode
{
    _calendarMode = calendarMode;
    
    if (calendarMode == SFACalendarYear) {
        _yearTableView.hidden = NO;
        _pickerController.view.hidden = YES;
    } else {
        _yearTableView.hidden = YES;
        _pickerController.view.hidden = NO;
    }
    
    [self updateCalendarHighlighting];
    [self updateHeaderLabel];
    [_pickerController.datePickerView reload];
}

- (void)setDatesWithData:(NSArray *)datesWithData
{
    _datesWithData = datesWithData;
    _pickerController.datePickerView.datesWithData = datesWithData;
}

- (void)refreshCalendar
{
    [_pickerController.datePickerView scrollCollectionViewToSelectedDate];
    [_pickerController.datePickerView reload];
    [self updateHeaderLabel];
}

- (BOOL)isCellDateSelected:(NSDate *)date
{
    NSInteger componentFlags = NSYearCalendarUnit|NSMonthCalendarUnit;

    switch (self.calendarMode) {
        case SFACalendarDay:
            componentFlags |= NSDayCalendarUnit;
            break;
        case SFACalendarWeek:
            componentFlags |= NSYearForWeekOfYearCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit;
            break;
        default:
            break;
    }
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:componentFlags
                                                                       fromDate:date];
    NSDateComponents *selectedDateComponents
        = [[NSCalendar currentCalendar] components:componentFlags
                                          fromDate:self.selectedDate];
    
    BOOL isSameDay = dateComponents.day == selectedDateComponents.day;
    BOOL isSameMonth = dateComponents.month == selectedDateComponents.month;
    BOOL isSameYear = dateComponents.year == selectedDateComponents.year;
    BOOL isSameWeek = NO;
    
    if (self.calendarMode == SFACalendarWeek) {
        [dateComponents setWeekday:1];
        [selectedDateComponents setWeekday:1];
        dateComponents.day = NSNotFound;
        selectedDateComponents.day = NSNotFound;
        
        NSDate *d = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        NSDate *sd = [[NSCalendar currentCalendar] dateFromComponents:selectedDateComponents];
        isSameWeek = [d isEqualToDate:sd];//dateComponents.weekOfYear == selectedDateComponents.weekOfYear;
    }
    
    switch (self.calendarMode) {
        case SFACalendarDay:
            return isSameDay && isSameMonth && isSameYear;
        case SFACalendarWeek:
            return isSameWeek;
        case SFACalendarMonth:
            return isSameMonth && isSameYear;
        case SFACalendarYear:
            return isSameYear;
        default:
            break;
    }
    
    return NO;
}

#pragma mark - Private

- (NSDate *)calendarDateFromDate:(NSDate *)date
{
    return ^{
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *now = [calendar dateFromComponents:[calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                               fromDate:date]];
        return now;
    }();
}

- (NSString *)dateStringFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        if (_timeDate.dateFormat == 0) {
            formatter.dateFormat = kCalendarDateFormat2;
        }
        else {
            formatter.dateFormat = kCalendarDateFormat1;
        }
//        formatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    });
    
    return [formatter stringFromDate:date];
}

- (NSString *)weekStringFromDate:(NSDate *)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps = [calendar components:NSYearForWeekOfYearCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
    
    [comps setWeekday:1]; //1: sunday
    NSDate *startOfWeekDate = [calendar dateFromComponents:comps];
    [comps setWeekday:7]; //7: saturday
    NSDate *endOfWeekDate = [calendar dateFromComponents:comps];
    
    NSString *dayString = [self dateStringFromDate:startOfWeekDate];
    NSString *endDayString = [self dateStringFromDate:endOfWeekDate];
    NSString *weekString = [NSString stringWithFormat:@"%@ - %@",dayString,endDayString];
    return weekString;
}

- (NSString *)monthStringFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = kCalendarMonthFormat;
    });
    
    return [formatter stringFromDate:date];
}

- (NSString *)yearStringFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = kCalendarYearFormat;
    });
    
    return [formatter stringFromDate:date];
}

- (NSDate *)dateByAdding:(NSUInteger)units selector:(SEL)sel
{
    NSDate *currentDate = _pickerController.datePickerView.selectedDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* dateComponents = [[NSDateComponents alloc]init];

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[dateComponents methodSignatureForSelector:sel]];
    [inv setSelector:sel];
    [inv setTarget:dateComponents];
    [inv setArgument:&units atIndex:2];
    [inv invoke];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents
                                                toDate:currentDate
                                               options:0];
    
    return newDate;
}

- (NSDate *)dateByAddingMonths:(NSUInteger)months
{
    return [self dateByAdding:months selector:@selector(setMonth:)];
}

- (NSDate *)dateByAddingDays:(NSUInteger)days
{
    return [self dateByAdding:days selector:@selector(setDay:)];
}

- (NSDate *)dateByAddingWeeks:(NSUInteger)weeks
{
    return [self dateByAdding:weeks selector:@selector(setWeek:)];
}

- (NSDate *)dateByAddingYears:(NSUInteger)years
{
    return [self dateByAdding:years selector:@selector(setYear:)];
}

- (NSDate *)previousDayDate
{
    return [self dateByAddingDays:-1];
}

- (NSDate *)nextDayDate
{
    return [self dateByAddingDays:1];
}

- (NSDate *)previousWeekDate
{
    return [self dateByAddingWeeks:-1];
}

- (NSDate *)nextWeekDate
{
    return [self dateByAddingWeeks:1];
}

- (NSDate *)previousMonthDate
{
    return [self dateByAddingMonths:-1];
}

- (NSDate *)nextMonthDate
{
    return [self dateByAddingMonths:1];
}

- (NSDate *)previousYearDate
{
    return [self dateByAddingYears:-1];
}

- (NSDate *)nextYearDate
{
    return [self dateByAddingYears:1];
}

- (NSDate *)nextDate
{
    switch (self.calendarMode) {
        case SFACalendarDay:
            return [self nextDayDate];
        case SFACalendarWeek:
            return [self nextWeekDate];
        case SFACalendarMonth:
            return [self nextMonthDate];
        case SFACalendarYear:
            return [self nextYearDate];
        default:
            break;
    }

    return nil;
}

- (NSDate *)previousDate
{
    switch (self.calendarMode) {
        case SFACalendarDay:
            return [self previousDayDate];
        case SFACalendarWeek:
            return [self previousWeekDate];
        case SFACalendarMonth:
            return [self previousMonthDate];
        case SFACalendarYear:
            return [self previousYearDate];
        default:
            break;
    }
    
    return nil;
}

- (void)updateCalendarHighlighting
{
    
}

- (void)updateHeaderLabel
{
    switch (self.calendarMode) {
        case SFACalendarDay:
            _dateHeaderLabel.text = [self dateStringFromDate:self.selectedDate];
            break;
        case SFACalendarWeek:
            _dateHeaderLabel.text = [self weekStringFromDate:self.selectedDate];
            break;
        case SFACalendarMonth:
            _dateHeaderLabel.text = [self monthStringFromDate:self.selectedDate];
            break;
        case SFACalendarYear:
            _dateHeaderLabel.text = [self yearStringFromDate:self.selectedDate];
        default:
            break;
    }
    
    self.dateHeaderString = _dateHeaderLabel.text;
}

#pragma mark - IBActions

- (void)didTapHeader:(id)sender
{
    if ([_delegate respondsToSelector:@selector(calendarDidTapHeader:)])
        [_delegate calendarDidTapHeader:self];
}

- (IBAction)calendarViewDidPressNextButton:(id)sender
{
    /*NSDateComponents *day = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[self nextDate]];
    NSDateComponents *day2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    
    if ([day day] > [day2 day] && [day month] >= [day2 month] && [day year] >= [day2 year]) {
        return;
    }*/
    
    _pickerController.datePickerView.selectedDate = [self nextDate];
    [self datePickerViewController:nil
                     didSelectDate:_pickerController.datePickerView.selectedDate];
}

- (IBAction)calendarViewDidPressPreviousButton:(id)sender
{
    _pickerController.datePickerView.selectedDate = [self previousDate];
    [self datePickerViewController:nil
                     didSelectDate:_pickerController.datePickerView.selectedDate];
}

#pragma mark - DFDatePickerViewControllerDelegate

- (void)datePickerViewController:(DFDatePickerViewController *)controller
                   didSelectDate:(NSDate *)date
{
    [self updateHeaderLabel];
    
    [SFAUserDefaultsManager sharedManager].selectedDateFromCalendar = date;
    
    if ([_delegate respondsToSelector:@selector(calendar:didSelectDate:)]) {
        [_delegate calendar:self didSelectDate:date];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *year = [cell textLabel].text;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                                   fromDate:self.selectedDate];

    components.year = [year integerValue];
    
    self.selectedDate = [[SFACalendarView activeCalendar] dateFromComponents:components];
}

@end
