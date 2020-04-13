//
//  SFASessionExpiredErrorAlertView.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 8/11/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASessionExpiredErrorAlertView.h"

static NSString * const cancelButton = @"Cancel";
static NSString * const continueButton = @"Continue";

@interface SFASessionExpiredErrorAlertView ()  <UIAlertViewDelegate>

@property (weak, nonatomic) id<SFASessionExpiredErrorAlertViewDelegate>errorAlertViewDelegate;

@end

@implementation SFASessionExpiredErrorAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self addButtonWithTitle:BUTTON_TITLE_CANCEL];
        [self addButtonWithTitle:BUTTON_TITLE_CONTINUE];
        self.delegate = self;
    }
    return self;
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate
{
    self.title = title;
    self.message = message;
    self.errorAlertViewDelegate = delegate;
    [self show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if ([self.errorAlertViewDelegate respondsToSelector:@selector(sessionExpiredAlertViewCancelButtonClicked:)]) {
                [self.errorAlertViewDelegate sessionExpiredAlertViewCancelButtonClicked:self];
            }
            break;
        case 1:
            if ([self.errorAlertViewDelegate respondsToSelector:@selector(sessionExpiredAlertViewContinueButtonClicked:)]) {
                [self.errorAlertViewDelegate sessionExpiredAlertViewContinueButtonClicked:self];
            }
            break;
        default:
            break;
    }
}

@end
