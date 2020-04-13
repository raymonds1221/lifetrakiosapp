//
//  SFADroidSansBoldLabel.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 1/28/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFADroidSansBoldLabel.h"

@implementation SFADroidSansBoldLabel

#pragma mark - Initialization Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setFontStyle];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self setFontStyle];
    }
    
    return self;
}

#pragma mark - Overridden Methods

- (void)setFontStyle
{
    CGFloat fontSize = self.font.pointSize;
    [self setFont:[UIFont fontWithName:@"DroidSans-Bold" size:fontSize]];
}

@end
