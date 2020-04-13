
//
//  SFALightAlertNumberCell.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/1/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const numberCellIdentifier = @"lightAlertNumberCell";

@interface SFALightAlertNumberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *numberText;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;

//always set slider.value in the initialization
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (assign, nonatomic) NSInteger max;
@property (assign, nonatomic) NSInteger min;
@property (assign, nonatomic) NSInteger value;

@property (strong, nonatomic) NSString *unit;

@end
