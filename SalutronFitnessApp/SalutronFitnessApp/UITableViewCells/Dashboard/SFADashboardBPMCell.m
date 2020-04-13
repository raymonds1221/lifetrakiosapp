//
//  SFADashboardBPMCell.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/21/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFADashboardBPMCell.h"

#import "SalutronUserProfile+Data.h"

#define LIGHT_GRAY_COLOR            [UIColor lightGrayColor]
#define STATUS_MARGIN               30.0f
#define PROGRESS_LINE_WIDTH         1.0f

@interface SFADashboardBPMCell ()

@end

@implementation SFADashboardBPMCell

#pragma mark - Private Methods

- (CGPoint)getStatusViewCenter
{
    float xCenter   = self.statusView.frame.size.width / 2;
    float yCenter   = self.statusView.frame.size.height / 2;
    CGPoint center  = CGPointMake(xCenter, yCenter);
    return center;
}

- (CGPoint)getStatusCenterAtIndex:(NSInteger)index
{
    float xCenter   = self.statusView.frame.size.width - (STATUS_MARGIN * 2);
    xCenter         = STATUS_MARGIN + ((xCenter / 4) * index);
    float yCenter   = self.statusView.frame.size.height / 2 + 5;
    CGPoint center  = CGPointMake(xCenter, yCenter);
    return center;
}

- (CAShapeLayer *)statusCircleWithRadius:(float)radius
                               lineWidth:(float)lineWidth
                             strokeColor:(UIColor *)strokeColor
                               fillColor:(UIColor *)fillColor
                                   index:(NSInteger)index
{
    CGPoint center          = [self getStatusCenterAtIndex:index];
    CAShapeLayer *circle    = [CAShapeLayer layer];
    circle.lineWidth        = lineWidth;
    circle.fillColor        = fillColor.CGColor;
    circle.strokeColor      = strokeColor.CGColor;
    circle.path             = [UIBezierPath bezierPathWithArcCenter:center
                                                             radius:radius
                                                         startAngle:- M_PI_2
                                                           endAngle:((M_PI_2 * 4) * 1 - M_PI_2)
                                                          clockwise:YES].CGPath;
    
    return circle;
}

- (CAShapeLayer *)lineWithStartPoint:(CGPoint)startPoint
                            endPoint:(CGPoint)endPoint
                           lineWidth:(float)lineWidth
                         strokeColor:(UIColor *)strokeColor
                           fillColor:(UIColor *)fillColor
{
    CAShapeLayer *line = [CAShapeLayer layer];
    line.path          = [self linePathWithStartPoint:startPoint endPoint:endPoint].CGPath;
    line.lineWidth     = PROGRESS_LINE_WIDTH;
    line.strokeColor   = LIGHT_GRAY_COLOR.CGColor;
    line.fillColor     = LIGHT_GRAY_COLOR.CGColor;
    
    return line;
}

- (UIBezierPath *)linePathWithStartPoint:(CGPoint)startPoint
                                endPoint:(CGPoint)endPoint
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    
    return path;
}

- (UIBezierPath *)linePathWithStartPoint:(CGPoint)startPoint
                                endPoint:(CGPoint)endPoint
                                 percent:(float)percent
{
    CGPoint newPoint    = [self pointWithStartPoint:startPoint endPoint:endPoint percent:percent];
    UIBezierPath *path  = [self linePathWithStartPoint:startPoint endPoint:newPoint];
    
    return path;
}

- (CGPoint)pointWithStartPoint:(CGPoint)startPoint
                      endPoint:(CGPoint)endPoint
                       percent:(float)percent
{
    CGPoint newPoint    = CGPointZero;
    
    // x
    float x             = endPoint.x - startPoint.x;
    x                   *= percent;
    x                   += startPoint.x;
    newPoint.x          = x;
    
    // y
    float y             = endPoint.y - startPoint.y;
    y                   *= percent;
    y                   += startPoint.y;
    newPoint.y          = y;
    
    return newPoint;
}

- (void)setProgressLabelWithStartPoint:(CGPoint)startPoint
                              endPoint:(CGPoint)endPoint
                               percent:(float)percent
{
    int progress                            = percent > 0 ? 100 * (percent / 2 + 0.5f) : 0;
    CGPoint newPoint                        = [self pointWithStartPoint:startPoint endPoint:endPoint percent:percent];
    CGPoint lineStartPoint                  = self.percent.center;
    lineStartPoint.x                        = newPoint.x;
    lineStartPoint.y                        = self.percent.frame.origin.y + self.percent.frame.size.height;
    self.percent.text                       = [NSString stringWithFormat:@"%i%%", progress];
    self.percentImage.image                 = [self percentImageWithPercent:progress];
    self.percentViewLeftConstraint.constant = lineStartPoint.x - (self.percent.frame.size.width / 2);
}

- (UIImage *)percentImageWithPercent:(CGFloat)percent
{
    if (percent >= 100.0f)
    {
        return [UIImage imageNamed:@"DashboardMarkerRed"];
    }
    else if (percent >= 75.0f)
    {
        return [UIImage imageNamed:@"DashboardMarkerOrange"];
    }
    else if (percent >= 50.0f)
    {
        return [UIImage imageNamed:@"DashboardMarkerDarkGreen"];
    }
    else if (percent >= 25.0f)
    {
        return [UIImage imageNamed:@"DashboardMarkerLightGreen"];
    }
    else if (percent >= 0.0f)
    {
       return [UIImage imageNamed:@"DashboardMarkerYellow"];
    }
    
    return [UIImage imageNamed:@"DashboardMarkerGray"];
}

- (UIImage *)wheelImageWithPercent:(CGFloat)percent
{
    if (percent >= 100.0f)
    {
        return [UIImage imageNamed:@"DashboardWheelBPMMax"];
    }
    else if (percent >= 75.0f)
    {
        return [UIImage imageNamed:@"DashboardWheelBPMHard"];
    }
    else if (percent >= 50.0f)
    {
        return [UIImage imageNamed:@"DashboardWheelBPMModerate"];
    }
    else if (percent >= 25.0f)
    {
        return [UIImage imageNamed:@"DashboardWheelBPMLight"];
    }
    else if (percent >= 0.0f)
    {
        return [UIImage imageNamed:@"DashboardWheelBPMVeryLight"];
    }
    
    return [UIImage imageNamed:@"DashboardWheelBPMVeryLight"];
}

#pragma mark - Public Methods

- (void)setStatusViewWithValue:(int)value minValue:(int)minValue maxValue:(int)maxValue
{
    CGPoint startPoint  = [self getStatusCenterAtIndex:0];
    CGPoint endPoint    = [self getStatusCenterAtIndex:4];
    float percent       = value >= minValue ? (float)(value - minValue) / (maxValue - minValue) : 0;
    
    [self setProgressLabelWithStartPoint:startPoint endPoint:endPoint percent:percent];
}

- (void)setContentsWithIntValue:(int)value minValue:(int)minValue maxValue:(int)maxValue
{
    float percent           = (float)value / [SalutronUserProfile maxBPM];
    NSInteger progress      = percent * 100 ;
    self.value.text         = [NSString stringWithFormat:@"%i", value];
    self.percent.text       = [NSString stringWithFormat:@"%i%%", progress];
    self.wheelImage.image   = [self wheelImageWithPercent:progress];
    
    //[self setStatusViewWithValue:value minValue:minValue maxValue:maxValue];
}

@end
