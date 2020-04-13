//
//  SFACustomTextField.h
//  SalutronFitnessApp
//
//  Created by Adrian Cayaco on 12/16/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFACustomTextField : UITextField

@property (copy, nonatomic) NSString    *text;
@property (strong, nonatomic) UILabel   *textLabel;
@property (strong, nonatomic) UIColor   *textColor;
@property (strong, nonatomic) UIColor   *backgroundColor;

@end
