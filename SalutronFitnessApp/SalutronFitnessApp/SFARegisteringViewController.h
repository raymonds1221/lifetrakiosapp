//
//  SFARegisteringViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/1/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFAViewController.h"

@protocol SFARegisteringViewControllerDelegate <NSObject>

- (void)registeringVCDismissedWithError:(NSError *)error withViewController:(UIViewController *)vc;

@end

@interface SFARegisteringViewController : SFAViewController
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) UIImage *userImage;
@property (nonatomic) BOOL isFacebookSignup;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) id<SFARegisteringViewControllerDelegate> delegate;

@end
