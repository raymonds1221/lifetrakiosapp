//
//  UIColor+ColorAdditions.h
//  SalutronFitnessApp
//
//  Created by John Bennedict Lorenzo on 12/17/13.
//  Copyright (c) 2013 Stratpoint. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Specify RGBA components from 0-255 */
#define UIColorFromRGBA(r,g,b,a) \
    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/255.0f]

#define UIColorFromRGB(r,g,b) \
    UIColorFromRGBA(r,g,b,255)

@interface UIColor (ColorAdditions)

@end
