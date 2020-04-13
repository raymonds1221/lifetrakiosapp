//
//  SFADashboardLightCell.h
//  SalutronFitnessApp
//
//  Created by Adrian Cayaco on 12/2/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFADashboardCell.h"

@interface SFADashboardLightCell : SFADashboardCell

@property (weak, nonatomic) IBOutlet UILabel *hours;
@property (weak, nonatomic) IBOutlet UILabel *minutes;

@property (weak, nonatomic) IBOutlet UILabel *cellTitle;

- (void)setContentsWithIntValue:(float)value goal:(float)goal;
- (void)setContentsWithHours:(NSInteger)hours minutes:(NSInteger)minutes;

@end
