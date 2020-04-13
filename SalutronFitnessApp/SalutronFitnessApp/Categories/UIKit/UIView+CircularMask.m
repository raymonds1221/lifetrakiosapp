//
//  UIView+CircularMask.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 5/15/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//
// Source : http://bit.ly/1jxoxm7

#import "UIView+CircularMask.h"

@implementation UIView (CircularMask)

- (void)addCircularMaskToBounds:(CGRect)maskBounds
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    
    CGPathRef maskPath = CGPathCreateWithEllipseInRect(maskBounds, NULL);
    maskLayer.bounds = maskBounds;
    [maskLayer setPath:maskPath];
    [maskLayer setFillColor:[[UIColor blackColor] CGColor]];
    maskLayer.position = CGPointMake(maskBounds.size.width/2, maskBounds.size.height/2);
    
    [self.layer setMask:maskLayer];
}

@end
