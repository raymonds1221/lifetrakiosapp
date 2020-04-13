//
//  BTGraphView.m
//  BLETest
//
//  Created by Mark John Revilla on 11/13/13.
//  Copyright (c) 2013 Stratpoint. All rights reserved.
//

#import "SFAGraphView.h"

@interface SFAGraphView ()

@end

@implementation SFAGraphView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.delegate graphTouchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.delegate graphTouchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.delegate graphTouchesEnded:touches withEvent:event];
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.delegate graphTouchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

@end
