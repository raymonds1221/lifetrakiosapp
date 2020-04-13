//
//  SFADashboardCell.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/15/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFADashboardCell.h"

@interface SFADashboardCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView     *progressView;
@property (weak, nonatomic) IBOutlet UILabel    *percent;
@property (weak, nonatomic) IBOutlet UILabel    *value;
@property (weak, nonatomic) IBOutlet UIImageView *wheelImage;
@property (weak, nonatomic) IBOutlet NSString   *type;

- (void)setProgressViewWithValue:(float)value goal:(float)goal;
- (void)setContentsWithDoubleValue:(double)value goal:(float)goal;
- (void)setContentsWithIntValue:(int)value goal:(int)goal;

@end
