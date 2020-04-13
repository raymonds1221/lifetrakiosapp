//
//  SFADashboardDistanceCell.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/3/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SalutronUserProfile+Data.h"

#import "SFADashboardDistanceCell.h"

@implementation SFADashboardDistanceCell

- (void)setContentsWithDoubleValue:(double)value goal:(float)goal
{
    SalutronUserProfile *userProfile    = [SalutronUserProfile getData];
    CGFloat displayValue                = value;
    
    if (userProfile.unit == IMPERIAL)
    {
        self.distanceUnit.text  = @"mi";
        displayValue            *= 0.621371;
    }
    else if (userProfile.unit == METRIC)
    {
        self.distanceUnit.text = @"km";
    }
    
    self.value.text = [NSString stringWithFormat:@"%.2f", displayValue];
    
    [self setProgressViewWithValue:value goal:goal];
}


@end
