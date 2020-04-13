//
//  JDADatePicker.m
//  WomensCircle
//
//  Created by John Dwaine Alingarog on 11/15/13.
//  Copyright (c) 2013 John Dwaine Alingarog. All rights reserved.
//

#import "JDADatePicker.h"
#import "TimeDate+Data.h"

@implementation JDADatePicker
@synthesize textField, dateFormat;

#pragma mark - Constructors
- (id)init
{
    self = [super init];
    if (self) {
        self.datePickerMode = UIDatePickerModeDate;
        [self addTarget:self
                 action:@selector(datePickerValueChanged:)
       forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (id)initWithDate:(NSDate *)date
{
    self = [super init];
    if (self)
    {
        self.datePickerMode = UIDatePickerModeDate;
        self.date           = date;
        [self addTarget:self
                 action:@selector(datePickerValueChanged:)
       forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (id)initWithTextField:(UITextField *)mTextField
{
    self = [super init];
    if (self) {
        self.datePickerMode = UIDatePickerModeDate;
        textField           = mTextField;
        [self addTarget:self
                 action:@selector(datePickerValueChanged:)
       forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (id)initWithTextField:(UITextField *)mTextField date:(NSDate *)date
{
    self = [super init];
    if (self) {
        self.datePickerMode = UIDatePickerModeDate;
        if (date) {
            self.date           = date;
        }
        textField           = mTextField;
        [self addTarget:self
                 action:@selector(datePickerValueChanged:)
       forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

#pragma mark - Date picker methods
- (void)didMoveToWindow
{
    if(self.datePickerMode == UIDatePickerModeTime) {
        textField.text = [self timeString];
    } else {
        textField.text = [self dateString];
    }
}

#pragma mark - Private actions
- (void)datePickerValueChanged:(id)sender
{
    if(self.datePickerMode == UIDatePickerModeTime) {
        textField.text = [self timeString];
    } else {
        textField.text = [self dateString];
    }
}

#pragma mark - Private instance methods
- (NSString *)dateString
{
    dateFormat                      = (dateFormat == nil || [dateFormat isEqualToString:@""]) ? @"MM-dd-yyyy" : dateFormat;
    NSDateFormatter *_dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat       = dateFormat;
    return [_dateFormatter stringFromDate:self.date];
}

- (NSString *)timeString
{
    TimeDate *timeDate = [TimeDate getData];
    NSString *timeFormat = @"";
    
    if(timeDate.hourFormat == _12_HOUR) {
        timeFormat = @"hh:mm a";
    } else {
        timeFormat = @"HH:mm";
    }
    
    NSDateFormatter *_dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat       = timeFormat;
    return [_dateFormatter stringFromDate:self.date];
}

- (NSInteger)hourValue {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit
                                                                   fromDate:self.date];
    return [components hour];
}

- (NSInteger)minuteValue {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit
                                                                   fromDate:self.date];
    return [components minute];
}

@end
