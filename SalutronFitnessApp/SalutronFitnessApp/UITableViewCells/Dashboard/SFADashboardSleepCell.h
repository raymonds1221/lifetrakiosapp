//
//  SFADashboardSleepCell.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/15/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFADashboardCell.h"

@interface SFADashboardSleepCell : SFADashboardCell

@property (weak, nonatomic) IBOutlet UILabel *hours;
@property (weak, nonatomic) IBOutlet UILabel *minutes;

@property (weak, nonatomic) IBOutlet UILabel *cellTitle;

- (void)setContentsWithIntValue:(float)value goal:(float)goal;
- (void)setContentsWithHours:(NSInteger)hours minutes:(NSInteger)minutes;

@end
