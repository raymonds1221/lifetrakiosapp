//
//  UISegmentedControl+Theme.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

/*
 
 Green Theme
 
 Segmented Control:
 1. Tint Color          - RGB (35, 202, 117)
 
 Default Segment:
 1. Text Color          - RGB (40, 229, 133)
 
 Selected Segment:
 1. Text Color          - RGB(255, 255, 255)
 
 */

#define GREEN_TINT_COLOR                [UIColor colorWithRed:35/255.0f green:202/255.0f blue:117/255.0f alpha:1]
#define GREEN_DEFAULT_TEXT_COLOR        [UIColor colorWithRed:40/255.0f green:229/255.0f blue:133/255.0f alpha:1]
#define GREEN_HIGHLIGHTED_TEXT_COLOR    [UIColor colorWithRed:7/255.0f green:132/255.0f blue:58/255.0f alpha:1]
#define GREEN_SELECTED_TEXT_COLOR       [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1]

#import "UISegmentedControl+Theme.h"

@implementation UISegmentedControl (Theme)

#pragma mark - Set Theme

- (void)themeWithSegmentedControlTheme:(UISegmentedControlTheme)theme
{
    NSDictionary *defaultTextAttribute;
    NSDictionary *highlightedTextAttribute;
    NSDictionary *selectedTextAttribute;
    
    if (theme == UISegmentedControlThemeGreen)
    {
        self.tintColor              = GREEN_TINT_COLOR;
        defaultTextAttribute        = @{NSForegroundColorAttributeName  : GREEN_DEFAULT_TEXT_COLOR,
                                        NSFontAttributeName             : [UIFont fontWithName:@"DroidSans" size:12.0f]};
        highlightedTextAttribute    = @{NSForegroundColorAttributeName  : GREEN_HIGHLIGHTED_TEXT_COLOR,
                                        NSFontAttributeName             : [UIFont fontWithName:@"DroidSans" size:12.0f]};
        selectedTextAttribute       = @{NSForegroundColorAttributeName  : GREEN_SELECTED_TEXT_COLOR,
                                        NSFontAttributeName             : [UIFont fontWithName:@"DroidSans" size:12.0f]};
    }
    
    [self setTitleTextAttributes:defaultTextAttribute forState:UIControlStateNormal];
    [self setTitleTextAttributes:highlightedTextAttribute forState:UIControlStateHighlighted];
    [self setTitleTextAttributes:selectedTextAttribute forState:UIControlStateSelected];
}


@end
