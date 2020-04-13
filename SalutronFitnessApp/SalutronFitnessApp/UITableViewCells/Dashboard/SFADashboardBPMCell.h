//
//  SFADashboardBPMCell.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/21/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFADashboardBPMCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView             *statusView;
@property (weak, nonatomic) IBOutlet UILabel            *value;
@property (weak, nonatomic) IBOutlet UILabel            *percent;
@property (weak, nonatomic) IBOutlet UIImageView        *percentImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *percentViewLeftConstraint;
@property (weak, nonatomic) IBOutlet UIImageView        *wheelImage;

- (void)setStatusViewWithValue:(int)value minValue:(int)minValue maxValue:(int)maxValue;
- (void)setContentsWithIntValue:(int)value minValue:(int)minValue maxValue:(int)maxValue;

@end
