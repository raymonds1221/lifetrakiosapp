//
//  UISegmentedControl+Theme.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UISegmentedControlThemeGreen
} UISegmentedControlTheme;

@interface UISegmentedControl (Theme)

// Set Theme

- (void)themeWithSegmentedControlTheme:(UISegmentedControlTheme)theme;

@end
