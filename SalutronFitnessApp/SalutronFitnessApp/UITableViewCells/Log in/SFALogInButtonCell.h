//
//  SFALogInButtonCell.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFALogInButtonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIButton *rememberPasswordButton;
@property (weak, nonatomic) IBOutlet UILabel *rememberMeLabel;

+ (CGFloat)height;

@end
