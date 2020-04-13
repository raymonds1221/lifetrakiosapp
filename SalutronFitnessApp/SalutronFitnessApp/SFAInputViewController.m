//
//  SFAInputViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAInputViewController.h"

@interface SFAInputViewController ()

@property (strong, nonatomic) UIToolbar *inputAccessory;
@property (weak, nonatomic) UITextField *activeField;
@property (readwrite, nonatomic) CGSize keyboardSize;

@end

@implementation SFAInputViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Register Keyboard Notification for Keyboard
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(keyboardWillShowWithNotification:)
                               name:UIKeyboardWillShowNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardDidShowWithNotification:)
                               name:UIKeyboardDidShowNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardWillHideWithNotification:)
                               name:UIKeyboardWillHideNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardDidHideWithNotification:)
                               name:UIKeyboardDidHideNotification
                             object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // Register Keyboard Notification for Keyboard
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(keyboardWillShowWithNotification:)
                               name:UIKeyboardWillShowNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardDidShowWithNotification:)
                               name:UIKeyboardDidShowNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardWillHideWithNotification:)
                               name:UIKeyboardWillHideNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(keyboardDidHideWithNotification:)
                               name:UIKeyboardDidHideNotification
                             object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) shouldAutorotate
{
    return NO;
}

#pragma mark - Getters

- (UIToolbar *)inputAccessory
{
    if (!_inputAccessory) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BUTTON_TITLE_DONE
                                                                       style:UIBarButtonItemStyleBordered target:self
                                                                      action:@selector(inputAccessoryDoneButtonPressed:)];
        _inputAccessory             = [UIToolbar new];
        _inputAccessory.items       = @[doneButton];
        [_inputAccessory sizeToFit];
    }
    return _inputAccessory;
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView    = self.inputAccessory;
    self.activeField                = textField;
    
    [self.inputContainer setContentOffset:self.inputContainer.contentOffset animated:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.inputAccessoryView    = nil;
    self.activeField                = nil;
}

#pragma mark - Private Methods

- (void)keyboardWillShowWithNotification:(NSNotification *)notification
{
    
}

- (void)keyboardDidShowWithNotification:(NSNotification *)notification
{
    NSDictionary *userInfo      = [notification userInfo];
    self.keyboardSize           = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets  = UIEdgeInsetsMake(0.0f, 0.0f, self.keyboardSize.height, 0.0f);
    
    [UIView animateWithDuration:0.1f animations:^{
        self.inputContainer.contentInset            = contentInsets;
        self.inputContainer.scrollIndicatorInsets   = contentInsets;
    } completion:^(BOOL finished) {
        [self scrollToActiveField];
    }];
}

- (void)keyboardWillHideWithNotification:(NSNotification *)notification
{
    UIEdgeInsets contentInsets                  = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.inputContainer.contentInset            = contentInsets;
    self.inputContainer.scrollIndicatorInsets   = contentInsets;
}

- (void)keyboardDidHideWithNotification:(NSNotification *)notification
{
    [self.inputContainer scrollRectToVisible:CGRectZero animated:YES];
}

- (void)inputAccessoryDoneButtonPressed:(id)sender
{
    [self.activeField resignFirstResponder];
}

- (void)scrollToActiveField
{
    /*CGRect frame        = self.inputContainer.frame;
    frame.size.height   -= self.keyboardSize.height;
    CGPoint point       = [self.inputContainer convertPoint:self.activeField.center fromView:self.activeField.superview.superview];
    
    if (!CGRectContainsPoint(frame, point) ) {
        CGFloat y       =  self.activeField.frame.origin.y + (self.activeField.frame.size.height / 2);
        y               -= (self.inputContainer.frame.size.height - self.keyboardSize.height) / 2;
        CGPoint point   = CGPointMake(0, y);
        
        [self.inputContainer setContentOffset:point animated:YES];
    }*/
}

- (void)resignFirstResponder
{
    [self.activeField resignFirstResponder];
}

@end
