//
//  SFAErrorMessageViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/2/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFAErrorMessageViewControllerDelegate;

@interface SFAErrorMessageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *errorTitle;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage1;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage2;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage3;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage4;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *centerButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorMessage1TopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorMessage2TopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorMessage3TopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorMessage4TopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerButtonTopConst;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftButtonTopConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightButtonTopConst;

@property (strong, nonatomic) id<SFAErrorMessageViewControllerDelegate> delegate;


- (IBAction)leftButtonClicked:(id)sender;
- (IBAction)rightButtonClicked:(id)sender;
- (IBAction)centerButtonClicked:(id)sender;

- (void)setErrorTitle:(NSString *)errorTitle errorMessage1:(NSString *)errorMessage1 errorMessage2:(NSString *)errorMessage2 errorMessage3:(NSString *)errorMessage3 andErrorMessage4:(NSString *)errorMessage4 andButtonPosition:(int)position ButtonTitle1:(NSString *)buttonTitle1 andButtonTitle2:(NSString *)buttonTitle2;

- (void)showCenterButton;
- (void)hideCenterButton;
@end

@protocol SFAErrorMessageViewControllerDelegate <NSObject>

- (void)erroMessageRightButtonClicked;
- (void)erroMessageLeftButtonClicked;
- (void)erroMessageCenterButtonClicked;

@end
