//
//  SFAInputCell.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAInputCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *inputTitle;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UIView *cellSeparator;

@end
