//
//  SFAViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAViewController : UIViewController

- (void)alertError:(NSError *)error;
- (void)alertError:(NSError *)error withTitle:(NSString *)title;
- (void)alertWithTitle:(NSString *)title message:(NSString *)message;

@end
