//
//  SFAInputViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAViewController.h"

@protocol SFAInputViewControllerDelegate;

@interface SFAInputViewController : SFAViewController <UITextFieldDelegate>

@property (weak, nonatomic) UIScrollView *inputContainer;

- (void)resignFirstResponder;

@end

/*@protocol SFAInputViewControllerDelegate <NSObject>

@optional
- (void)keyboardWillShowWithKeyboardSize:(CGRect)keyboardSize;
- (void)keyboardDidShowWithKeyboardSize:(CGRect)keyboardSize;
- (void)keyboardWillHideWithKeyboardSize:(CGRect)keyboardSize;
- (void)keyboardDidHideWithKeyboardSize:(CGRect)keyboardSize;

@end*/
