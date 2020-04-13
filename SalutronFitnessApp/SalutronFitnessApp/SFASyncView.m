//
//  SFASyncView.m
//  SalutronFitnessApp
//
//  Created by Dana Elisa Nicolas on 11/21/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFASyncView.h"

@implementation SFASyncView

@synthesize syncImage       = _syncImage;
@synthesize syncTime        = _syncTime;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.syncImage = [[UIImageView alloc] init];
        
        self.syncTime = [[UILabel alloc] init];
        self.syncTime.textAlignment = NSTextAlignmentLeft;
        self.syncTime.textColor = [UIColor whiteColor];
        self.syncTime.backgroundColor = [UIColor clearColor];
        self.syncTime.font = [UIFont systemFontOfSize:12];
        
        [self addSubview:self.syncImage];
        [self addSubview:self.syncTime];
        
        self.backgroundColor = [UIColor colorWithRed:107.0/255.0 green:111.0/255.0 blue:120.0/255.0 alpha:1.0];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
    CGRect contentRect = self.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat boundsY = contentRect.origin.y;
    CGRect frame;
    CGPoint center;
 
    frame = CGRectMake(boundsX, boundsY, 50, 50);
    center = CGPointMake(25, self.frame.size.height/2);
    self.syncImage.frame = frame;
    self.syncImage.center = center;
    
    frame = CGRectMake(self.syncImage.frame.origin.x+self.syncImage.frame.size.width+5, 0, self.frame.size.width-50, self.frame.size.height);
    self.syncTime.frame = frame;
}

@end
