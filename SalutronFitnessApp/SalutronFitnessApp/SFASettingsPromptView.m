//
//  SFASettingsPromptView.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/1/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASettingsPromptView.h"

@interface SFASettingsPromptView ()

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *appButton;
@property (weak, nonatomic) IBOutlet UIButton *watchButton;
@property (weak, nonatomic) IBOutlet UIButton *showPromptButton;


@end

@implementation SFASettingsPromptView

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        NSArray *viewHeirarchy = [[NSBundle mainBundle] loadNibNamed:@"SFASettingsPromptView"
                                                               owner:nil
                                                             options:nil];
        
        for (UIView *view in viewHeirarchy) {
            if ([view isKindOfClass:[SFASettingsPromptView class]]) {
                self = (SFASettingsPromptView *)view;
                break;
            }
        }
        
        self.frame = [[UIScreen mainScreen] bounds];
        self.backgroundView.layer.cornerRadius = 10.0f;
        self.backgroundView.clipsToBounds = YES;
        self.appButton.layer.borderWidth = 1.0f;
        self.watchButton.layer.borderWidth = 1.0f;
        self.appButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.watchButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    return self;
}


#pragma mark - Class Methods

+ (SFASettingsPromptView *)settingsPromptView
{
    static SFASettingsPromptView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SFASettingsPromptView alloc] init];
    });
    return instance;
}

#pragma mark - Instance Methods

+ (void)show
{
    [[self settingsPromptView].showPromptButton setSelected:NO];
    if (![self settingsPromptView].superview) {
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
        
        for (UIWindow *window in frontToBackWindows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                [window addSubview:[self settingsPromptView]];
                break;
            }
        }
    }
}

#pragma mark - Private Methods

+ (void)hide
{
    [[self settingsPromptView] removeFromSuperview];
}

#pragma mark - IBAction Methods

- (IBAction)appButtonPressed:(id)sender
{
    if ([self.delegate conformsToProtocol:@protocol(SFASettingsPromptViewDelegate)] &&
        [self.delegate respondsToSelector:@selector(didPressAppButtonOnSettingsPromptView:)]) {
        [self.delegate didPressAppButtonOnSettingsPromptView:self];
    }

    [SFASettingsPromptView hide];
}

- (IBAction)watchButtonPressed:(id)sender
{
    if ([self.delegate conformsToProtocol:@protocol(SFASettingsPromptViewDelegate)] &&
        [self.delegate respondsToSelector:@selector(didPressWatchButtonOnSettingsPromptView:)]) {
        [self.delegate didPressWatchButtonOnSettingsPromptView:self];
    }
    
    [SFASettingsPromptView hide];
}

- (IBAction)promptButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    DDLogInfo(@"button selected: %@", sender.selected ? BUTTON_TITLE_YES_ALL_CAPS : BUTTON_TITLE_NO_ALL_CAPS);
    SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    userDefaultsManager.promptChangeSettings = !sender.selected;
    userDefaultsManager.syncOption = SyncOptionWatch;//SyncOptionApp;
}

@end
