//
//  JDADatePicker.h
//  WomensCircle
//
//  Created by John Dwaine Alingarog on 11/15/13.
//  Copyright (c) 2013 John Dwaine Alingarog. All rights reserved.
//

#import <Foundation/Foundation.h>

//@protocol JDADatePickerDelegate;

@interface JDADatePicker : UIDatePicker

@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) NSString *dateFormat;
@property (assign, nonatomic) NSInteger hourValue;
@property (assign, nonatomic) NSInteger minuteValue;

- (id)initWithDate:(NSDate *)date;
- (id)initWithTextField:(UITextField *)mTextField;
- (id)initWithTextField:(UITextField *)mTextField date:(NSDate *)date;

@end

//@protocol JDADatePickerDelegate <NSObject>
//
//- (void)didReturnDatePicker;
//
//@end
