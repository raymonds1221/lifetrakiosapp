//
//  SFADashboardDistanceCell.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/3/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFADashboardCell.h"

@interface SFADashboardDistanceCell : SFADashboardCell

@property (weak, nonatomic) IBOutlet UILabel *distanceUnit;

- (void)setContentsWithDoubleValue:(double)value goal:(float)goal;

@end
