//
//  SFADashboardCell.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/15/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFADashboardCell.h"

#define CLEAR_COLOR         [UIColor clearColor]
#define LIGHT_GRAY_COLOR    [UIColor lightGrayColor]
#define WHEEL_0_COLOR       [UIColor colorWithRed:217/255.0f green:189/255.0f blue:55/255.0f alpha:1]
#define WHEEL_25_COLOR      [UIColor colorWithRed:229/255.0f green:210/255.0f blue:80/255.0f alpha:1]
#define WHEEL_50_COLOR      [UIColor colorWithRed:144/255.0f green:204/255.0f blue:41/255.0f alpha:1]
#define WHEEL_75_COLOR      [UIColor colorWithRed:104/255.0f green:196/255.0f blue:89/255.0f alpha:1]

#define WHEEL_LIGHT_0_COLOR       [UIColor colorWithRed:181/255.0f green:184/255.0f blue:188/255.0f alpha:1]
#define WHEEL_LIGHT_25_COLOR      [UIColor colorWithRed:153/255.0f green:174/255.0f blue:178/255.0f alpha:1]
#define WHEEL_LIGHT_50_COLOR      [UIColor colorWithRed:129/255.0f green:169/255.0f blue:179/255.0f alpha:1]
#define WHEEL_LIGHT_75_COLOR      [UIColor colorWithRed:83/255.0f green:161/255.0f blue:178/255.0f alpha:1]
#define WHEEL_LIGHT_100_COLOR      [UIColor colorWithRed:65/255.0f green:162/255.0f blue:189/255.0f alpha:1]

#define PROGRESS_RADIUS     35.0f
#define PROGRESS_LINE_WIDTH 4.0f

@interface SFADashboardCell ()

@property (strong, nonatomic) CAShapeLayer *progress;

@end

@implementation SFADashboardCell

#pragma mark - UIView Methods

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.progressView.layer addSublayer:self.progress];
    [self.progressView bringSubviewToFront:self.percent];
}

#pragma mark - Getters

- (CAShapeLayer *)progress
{
    if (!_progress)
    {
        _progress = [self circleWithRadius:PROGRESS_RADIUS
                                 lineWidth:PROGRESS_LINE_WIDTH
                               strokeColor:LIGHT_GRAY_COLOR
                                 fillColor:CLEAR_COLOR
                                   percent:0.0f];
    }
    return _progress;
}

#pragma mark - Private Methods

- (CGPoint)getProgressViewCenter
{
    float xCenter   = self.progressView.frame.size.width / 2;
    float yCenter   = self.progressView.frame.size.height / 2;
    CGPoint center  = CGPointMake(xCenter, yCenter);
    return center;
}

- (CAShapeLayer *)circleWithRadius:(float)radius
                         lineWidth:(float)lineWidth
                       strokeColor:(UIColor *)strokeColor
                         fillColor:(UIColor *)fillColor
                           percent:(float)percent
{
    percent                 = percent > 1 ? 1 : percent;
    CGPoint center          = [self getProgressViewCenter];
    CAShapeLayer *circle    = [CAShapeLayer layer];
    circle.lineWidth        = lineWidth;
    circle.fillColor        = fillColor.CGColor;
    circle.strokeColor      = strokeColor.CGColor;
    circle.path             = [UIBezierPath bezierPathWithArcCenter:center
                                                             radius:radius
                                                         startAngle:- M_PI_2
                                                           endAngle:((M_PI_2 * 4) * percent - M_PI_2)
                                                          clockwise:YES].CGPath;
    
    return circle;
}

- (CGPathRef)pathWithCenter:(CGPoint)center
                     radius:(float)radius
                    percent:(float)percent
{
    CGPathRef path = [UIBezierPath bezierPathWithArcCenter:center
                                                    radius:radius
                                                startAngle:- M_PI_2
                                                  endAngle:((M_PI_2 * 4) * percent - M_PI_2)
                                                 clockwise:YES].CGPath;
    return path;
}

- (void)setProgressLabelWithPercent:(float)percent
{
    int progress        = percent * 100;
    self.percent.text   = [NSString stringWithFormat:@"%i%%", progress];
    self.percent.hidden = percent >= 1;
}

- (UIImage *)wheelImageWithPercent:(CGFloat)percent
{
    if ([self.type isEqualToString:@"SFADashboardLightCell"]) {
        if (percent >= 1.0f)
        {
            return [UIImage imageNamed:@"DashboardWheelLightFull"];
        } else if(percent > 0)
            return [UIImage imageNamed:@"DashboardWheelLight100Solid"];
        else{
            return [UIImage imageNamed:@"DashboardWheelNone"];
        }
    }
    else{
        if (percent >= 1.0f)
        {
            return [UIImage imageNamed:@"DashboardWheel100"];
        }
        else if (percent >= 0.75f)
        {
            return [UIImage imageNamed:@"DashboardWheel75"];
        }
        else if (percent >= 0.5f)
        {
            return [UIImage imageNamed:@"DashboardWheel50"];
        }
        else if (percent >= 0.25f)
        {
            return [UIImage imageNamed:@"DashboardWheel25"];
        }
        else if (percent > 0)
        {
            return [UIImage imageNamed:@"DashboardWheel0"];
        }
    }
    
    return [UIImage imageNamed:@"DashboardWheelNone"];
}

#pragma mark - Public Methods

- (void)setProgressViewWithValue:(float)value goal:(float)goal
{
    float percent           = isnan(value / goal) ? 0.0f : value / goal;
    CGPoint center          = [self getProgressViewCenter];
    self.progress.path      = [self pathWithCenter:center radius:PROGRESS_RADIUS percent:percent];
    self.wheelImage.image   = [self wheelImageWithPercent:percent];
    
    
    [self setProgressLabelWithPercent:percent];
    
    if (![self.type isEqualToString:@"SFADashboardLightCell"]) {
        if (percent >= 1)
        {
            self.progress.strokeColor = CLEAR_COLOR.CGColor;
        }
        else if (percent >= 0.75f)
        {
            self.progress.strokeColor = WHEEL_75_COLOR.CGColor;
        }
        else if (percent >= 0.5f)
        {
            self.progress.strokeColor = WHEEL_50_COLOR.CGColor;
        }
        else if (percent >= 0.25)
        {
            self.progress.strokeColor = WHEEL_25_COLOR.CGColor;
        }
        else if (percent > 0)
        {
            self.progress.strokeColor = WHEEL_0_COLOR.CGColor;
        }
        else
        {
            self.progress.strokeColor = CLEAR_COLOR.CGColor;
        }
    }
    else{
        if (percent > 0)
        {
            self.progress.strokeColor = WHEEL_LIGHT_100_COLOR.CGColor;
        }
        else
        {
            self.progress.strokeColor = CLEAR_COLOR.CGColor;
        }
        
    }
}

- (void)setContentsWithDoubleValue:(double)value goal:(float)goal
{
    self.value.text = [NSString stringWithFormat:@"%.1f", value];
    
    [self setProgressViewWithValue:value goal:goal];
}

- (void)setContentsWithIntValue:(int)value goal:(int)goal
{
    self.value.text = [NSString stringWithFormat:@"%i", value];
    
    [self setProgressViewWithValue:value goal:goal];
}

@end
