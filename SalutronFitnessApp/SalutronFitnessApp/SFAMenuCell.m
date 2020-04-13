//
//  SFAMenuCell.m
//  SalutronFitnessApp
//
//  Created by Dana Elisa Nicolas on 11/21/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAMenuCell.h"

@implementation SFAMenuCell

- (void)setContentsWithImage:(UIImage *)image label:(NSString *)label withSeparator:(BOOL)withSeparator
{
    self.image.image        = image;
    self.label.text         = label;
    self.separator.hidden   = !withSeparator;
}

//@synthesize icon            = _icon;
//@synthesize text            = _text;
//@synthesize line            = _line;
//
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        // Initialization code
//        
//        self.icon = [[UIImageView alloc] init];
//        
//        self.text = [[UILabel alloc] init];
//        self.text.textAlignment = NSTextAlignmentLeft;
//        self.text.textColor = [UIColor whiteColor];
//        self.text.font = [UIFont systemFontOfSize:18];
//        
//        self.line = [[UIView alloc] init];
//        self.line.backgroundColor = [UIColor colorWithRed:107.0/255.0 green:111.0/255.0 blue:120.0/255.0 alpha:1.0];
//        
//        [self addSubview:self.icon];
//        [self addSubview:self.text];
//        [self addSubview:self.line];
//        
//        self.backgroundColor = [UIColor colorWithRed:119.0/255.0 green:123.0/255.0 blue:133.0/255.0 alpha:1.0];
//    }
//    return self;
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}
//
//- (void)layoutSubviews
//{
//    CGRect contentRect = self.bounds;
//    CGFloat boundsX = contentRect.origin.x;
//    CGFloat boundsY = contentRect.origin.y;
//    CGRect frame;
//    CGPoint center;
//    
//    frame = CGRectMake(boundsX, boundsY, 50, 50);
//    center = CGPointMake(25, self.frame.size.height/2);
//    self.icon.frame = frame;
//    
//    frame = CGRectMake(self.icon.frame.origin.x+self.icon.frame.size.width+10, 0, self.frame.size.width-self.icon.frame.size.width-10, self.frame.size.height);
//    self.text.frame = frame;
//    
//    frame = CGRectMake(50, self.frame.size.height-1, self.frame.size.width-50, 1);
//    self.line.frame = frame;
//}

@end
