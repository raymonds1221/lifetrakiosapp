//
//  SFANavigation.m
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 1/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFANavigation.h"

@implementation SFANavigation

- (void)showMenuButton
{
    _buttonMenu = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
    [_buttonMenu setBackgroundImage:[UIImage imageNamed:@"MenuIcon"] forState:UIControlStateNormal];
    UIBarButtonItem *_barButton = [[UIBarButtonItem alloc] initWithCustomView:_buttonMenu];
    [self setLeftBarButtonItem:_barButton animated:YES];
}

@end
