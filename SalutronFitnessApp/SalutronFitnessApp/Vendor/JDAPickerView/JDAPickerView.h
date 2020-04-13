//
//  JDAPickerView.h
//  WomensCircle
//
//  Created by John Dwaine Alingarog on 11/16/13.
//  Copyright (c) 2013 John Dwaine Alingarog. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JDAPickerViewDelegate;

@interface JDAPickerView : UIPickerView<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, readwrite) NSInteger selectedIndex;
@property (nonatomic, readonly) NSString *selectedValue;
@property (strong, nonatomic) UITextField *textField;

- (id)initWithArray:(NSArray *)pickerViewArray
           delegate:(id)delegate;

@end

@protocol JDAPickerViewDelegate <NSObject>

- (void)pickerViewDidSelectIndex:(NSInteger)selectedIndex;

@end