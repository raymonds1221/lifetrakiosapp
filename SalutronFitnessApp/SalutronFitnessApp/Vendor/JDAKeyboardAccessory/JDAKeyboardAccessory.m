//
//  JDAKeyboardAccessory.m
//  WomensCircle
//
//  Created by John Dwaine Alingarog on 11/15/13.
//  Copyright (c) 2013 Stratpoint Technologies. All rights reserved.
//

#import "JDAKeyboardAccessory.h"

@implementation JDAKeyboardAccessory
@synthesize previousView, nextView, currentView;

#pragma mark - Constructors
- (id)initWithPrevNextDoneAccessoryWithBarStyle:(UIBarStyle)barStyle
{
    self = [super init];
    if (self) {
        self.barStyle = barStyle;
        [self sizeToFit];
        UIBarButtonItem *_prevButton = [[UIBarButtonItem alloc] initWithTitle:@"Prev"
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(previous:)];
        UIBarButtonItem *_nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(next:)];
        
        UIBarButtonItem *_flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                            target:nil
                                                                                            action:nil];
        UIBarButtonItem* _doneButton = [[UIBarButtonItem alloc] initWithTitle:BUTTON_TITLE_DONE
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(done:)];
        [self setItems:@[_prevButton, _nextButton, _flexibleSpaceLeft, _doneButton]];
    }
    return self;
}

- (id)initWithDoneAccessoryWithBarStyle:(UIBarStyle)barStyle
{
    self = [super init];
    if (self) {
        self.barStyle = barStyle;
        [self sizeToFit];
        
        UIBarButtonItem *_flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                            target:nil
                                                                                            action:nil];
        UIBarButtonItem* _doneButton = [[UIBarButtonItem alloc] initWithTitle:BUTTON_TITLE_DONE
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(done:)];
        [self setItems:@[_doneButton, _flexibleSpaceLeft]];
    }
    return self;
}

#pragma mark - Private actions
- (void)previous:(id)sender
{
    [previousView becomeFirstResponder];
}

- (void)next:(id)sender
{
    [nextView becomeFirstResponder];
}

- (void)done:(id)sender
{
    [currentView resignFirstResponder];
}
@end
