//
//  SFALoginViewController.h
//  SalutronFitnessApp
//
//  Created by Dana Nicolas on 4/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAInputViewController.h"

@interface SFALoginViewController : SFAInputViewController

@property (weak, nonatomic) IBOutlet UITextField    *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField    *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel        *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel        *passwordLabel;
@property (weak, nonatomic) IBOutlet UIView         *emailCellSeparator;
@property (weak, nonatomic) IBOutlet UIView         *passwordCellSeparator;

- (IBAction)facebookLoginButtonClicked:(id)sender;
- (IBAction)loginButtonClicked:(id)sender;

@end
