//
//  JDAPickerView.m
//  WomensCircle
//
//  Created by John Dwaine Alingarog on 11/16/13.
//  Copyright (c) 2013 John Dwaine Alingarog. All rights reserved.
//

#import "JDAPickerView.h"

@interface JDAPickerView () <UITextFieldDelegate>

@property (strong, nonatomic) NSArray *pickerViewArray;
@property (strong, readwrite) NSString *selectedValue;
@property (weak, nonatomic) id<JDAPickerViewDelegate> pickerViewDelegate;

@end

@implementation JDAPickerView

#pragma mark - Constructors
- (id)initWithArray:(NSArray *)pickerViewArray
           delegate:(id)delegate
{
    self = [super init];
    if (self)
    {
        self.dataSource         = self;
        self.delegate           = self;
        self.pickerViewArray    = pickerViewArray;
        self.selectedIndex      = 0;
        self.selectedValue      = pickerViewArray.firstObject;
        self.pickerViewDelegate = delegate;
    }
    return self;
}

#pragma mark - Picker view methods
- (void)didMoveToWindow
{
    self.textField.text = self.pickerViewArray[self.selectedIndex];
}

#pragma mark - Picker view data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerViewArray.count;
}

#pragma mark - Picker view delegate
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return self.pickerViewArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    self.selectedIndex  = row;
    self.selectedValue  = self.pickerViewArray[row];
    self.textField.text = self.pickerViewArray[row];
    
    if (!self.textField.isEditing) {
        if ([self.pickerViewDelegate conformsToProtocol:@protocol(JDAPickerViewDelegate)]) {
            if ([self.pickerViewDelegate respondsToSelector:@selector(pickerViewDidSelectIndex:)]) {
                [self.pickerViewDelegate pickerViewDidSelectIndex:self.selectedIndex];
            }
        }
    }
}

#pragma mark - Text field delegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.pickerViewDelegate conformsToProtocol:@protocol(JDAPickerViewDelegate)]) {
        if ([self.pickerViewDelegate respondsToSelector:@selector(pickerViewDidSelectIndex:)]) {
            [self.pickerViewDelegate pickerViewDidSelectIndex:self.selectedIndex];
        }
    }
}

#pragma mark - Setters
- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    self.selectedValue  = self.pickerViewArray[selectedIndex];
    self.textField.text = self.selectedValue;
    _selectedIndex      = selectedIndex;
    
    [self selectRow:selectedIndex inComponent:0 animated:NO];
}

- (void)setTextField:(UITextField *)textField
{
    _textField = textField;
    _textField.delegate = self;
}

@end
