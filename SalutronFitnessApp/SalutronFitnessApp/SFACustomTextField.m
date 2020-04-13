//
//  SFACustomTextField.m
//  SalutronFitnessApp
//
//  Created by Adrian Cayaco on 12/16/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFACustomTextField.h"

@interface SFACustomTextField ()

@end

@implementation SFACustomTextField

@synthesize text            = _text;
@synthesize textColor       = _textColor;
@synthesize backgroundColor = _backgroundColor;

#pragma mark - Override text field methods

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.textLabel layoutSubviews];
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    return CGRectZero;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setText:(NSString *)text
{
    _text = text;
    self.textLabel.text = text;
    
    [self layoutSubviews];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = [UIColor clearColor];
    self.textLabel.textColor = textColor;
    
    [self layoutSubviews];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = [UIColor clearColor];
    self.textLabel.backgroundColor = backgroundColor;
    
    [self layoutSubviews];
}

- (UILabel *)textLabel
{
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:frame];
        _textLabel.font = self.font;
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.minimumScaleFactor = 0.3f;
        _textLabel.tag = 100;
        
        if ([self viewWithTag:100] == nil) {
            [self addSubview:self.textLabel];
            [self sendSubviewToBack:self.textLabel];
        }
    }
    _textLabel.frame = frame;
    return _textLabel;
}


@end
