//
//  SFASyncProgressView.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SFASyncProgressView.h"

@interface SFASyncProgressView ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (nonatomic, copy) void (^onButtonClick)(void);

@end

@implementation SFASyncProgressView

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        NSArray *viewHeirarchy = [[NSBundle mainBundle] loadNibNamed:@"SFASyncProgressView"
                                                               owner:nil
                                                             options:nil];
        
        for (UIView *view in viewHeirarchy) {
            if ([view isKindOfClass:[SFASyncProgressView class]]) {
                self = (SFASyncProgressView *)view;
                break;
            }
        }
        
        self.frame = [[UIScreen mainScreen] bounds];
        self.backgroundView.layer.cornerRadius = 10.0f;
        
        // December 11, 2014
        self.statusLabel.minimumScaleFactor = 0.30f;
        self.statusLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    return self;
}

#pragma mark - Class Methods

+ (SFASyncProgressView *)progressView
{
    static SFASyncProgressView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SFASyncProgressView alloc] init];
    });
    return instance;
}

#pragma mark - Instance Methods

+ (void)show
{
    if (![self progressView].superview) {
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
        
        for (UIWindow *window in frontToBackWindows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                [window addSubview:[self progressView]];
                break;
            }
        }
    }
}

+ (void)showWithMessage:(NSString *)message
{
    [self show];
    
    [self progressView].statusLabel.text    = message;
}

+ (void)showWithMessage:(NSString *)message animate:(BOOL)animate
{
    [self showWithMessage:message];
    
    [[self progressView].button setTitle:BUTTON_TITLE_CANCEL forState:UIControlStateNormal];
    
    [self progressView].isAnimating = animate;
}

+ (void)showWithMessage:(NSString *)message animate:(BOOL)animate showButton:(BOOL)showButton
{
    [self showWithMessage:message animate:animate];
    
    [self progressView].showButton  = showButton;
}

+ (void)showWithMessage:(NSString *)message animate:(BOOL)animate showButton:(BOOL)showButton dismiss:(BOOL)dismiss
{
    [self showWithMessage:message animate:animate showButton:showButton];
    
    if (dismiss) {
        [[SFASyncProgressView progressView] hideAfterTimeInterval:2.0];
    }
}

+ (void)showWithMessage:(NSString *)message animate:(BOOL)animate showOKButton:(BOOL)showButton onButtonClick:(void (^)(void))onClick
{
    [self showWithMessage:message animate:animate];
    [[self progressView].button setTitle:BUTTON_TITLE_OK_NORMAL forState:UIControlStateNormal];
    [self progressView].showButton = showButton;
    [self progressView].onButtonClick = onClick;
}

+ (void)hide
{
    [[self progressView] removeFromSuperview];
}

+ (void)showWithMessage:(NSString *)message animate:(BOOL)animate showButton:(BOOL)showButton onButtonClick:(void (^)(void))onClick
{
    [self showWithMessage:message animate:animate showButton:showButton];
    [self progressView].onButtonClick   = onClick;
}

#pragma mark - Private Methods

- (void)hide
{
    
    self.onButtonClick = nil;
    [self removeFromSuperview];
}

- (void)hideAfterTimeInterval:(NSTimeInterval)timeInterval
{
    [self performSelector:@selector(hide) withObject:nil afterDelay:timeInterval];
}

#pragma mark - Setters

- (void)setStatus:(NSString *)status
{
    if (![_status isEqualToString:self.statusLabel.text]) {
        _status = status;
        self.statusLabel.text = status;
    }
}

- (void)setIsAnimating:(BOOL)isAnimating
{
    if (_isAnimating != isAnimating) {
        _isAnimating = isAnimating;
        
        if (isAnimating) {
            [self.activityIndicatorView startAnimating];
        } else {
            [self.activityIndicatorView stopAnimating];
        }
    }
}

- (void)setShowButton:(BOOL)showButton
{
    if (self.button.hidden == showButton) {
        self.button.hidden = !showButton;
    }
}

#pragma mark - IBAction Methods

- (IBAction)buttonPressed:(id)sender
{
    if ([self.delegate conformsToProtocol:@protocol(SFASyncProgressViewDelegate)] &&
        [self.delegate respondsToSelector:@selector(didPressButtonOnProgressView:)]) {
        [self.delegate didPressButtonOnProgressView:self];
    }
    
    if (self.onButtonClick){
        self.onButtonClick();
        return;
    }
    
}

@end
