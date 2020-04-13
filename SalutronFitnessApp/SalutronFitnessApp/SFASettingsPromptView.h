//
//  SFASettingsPromptView.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/1/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFASettingsPromptViewDelegate;

@interface SFASettingsPromptView : UIView

@property (weak, nonatomic) id <SFASettingsPromptViewDelegate> delegate;

+ (SFASettingsPromptView *)settingsPromptView;
+ (void)show;
+ (void)hide;

@end

@protocol SFASettingsPromptViewDelegate <NSObject>

- (void)didPressAppButtonOnSettingsPromptView:(SFASettingsPromptView *)view;
- (void)didPressWatchButtonOnSettingsPromptView:(SFASettingsPromptView *)view;

@end