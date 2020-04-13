//
//  SFAButtonCell.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAButtonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) IBOutlet UIButton *checkBox;
@property (strong, nonatomic) IBOutlet UILabel *label;

@end
