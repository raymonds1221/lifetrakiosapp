//
//  SFAErrorMessageViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/2/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAErrorMessageViewController.h"

@interface SFAErrorMessageViewController () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>


@end

@implementation SFAErrorMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.rightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.leftButton.titleLabel.minimumScaleFactor = 0.5;
    self.rightButton.titleLabel.minimumScaleFactor = 0.5;
    self.centerButton.titleLabel.minimumScaleFactor = 0.5;
    self.leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.centerButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.leftButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.rightButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.centerButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    // Do any additional setup after loading the view from its nib.    [self initializeObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setErrorTitle:(NSString *)errorTitle errorMessage1:(NSString *)errorMessage1 errorMessage2:(NSString *)errorMessage2 errorMessage3:(NSString *)errorMessage3 andErrorMessage4:(NSString *)errorMessage4 andButtonPosition:(int)position ButtonTitle1:(NSString *)buttonTitle1 andButtonTitle2:(NSString *)buttonTitle2{
    //dispatch_async(dispatch_get_main_queue(), ^{
        if (errorTitle.length == 0) {
            self.errorTitle.font = [UIFont systemFontOfSize:12.0f];
            self.errorTitle.text = errorMessage1;
            self.errorMessage1.text = errorMessage2;
            self.errorMessage2.text = errorMessage3;
            self.errorMessage3.text = errorMessage4;
            self.errorMessage4.text = @"";
        }
        else{
            self.errorTitle.font = [UIFont boldSystemFontOfSize:16.0f];
            self.errorTitle.text = errorTitle;
            self.errorMessage1.text = errorMessage1;
            self.errorMessage2.text = errorMessage2;
            self.errorMessage3.text = errorMessage3;
            self.errorMessage4.text = errorMessage4;
        }
        self.errorMessage1TopConst.constant = self.errorMessage1.text.length == 0 ? 0 : 20.0f;
        self.errorMessage2TopConst.constant = self.errorMessage2.text.length == 0 ? 0 : 20.0f;
        self.errorMessage3TopConst.constant = self.errorMessage3.text.length == 0 ? 0 : 20.0f;
        self.errorMessage4TopConst.constant = self.errorMessage4.text.length == 0 ? 0 : 20.0f;
    //});
    if (position == 0) {
        [self showCenterButton];
        [self.centerButton setTitle:buttonTitle1 forState:UIControlStateNormal];
    }
    else{
        [self hideCenterButton];
        [self.leftButton setTitle:buttonTitle1 forState:UIControlStateNormal];
        [self.rightButton setTitle:buttonTitle2 forState:UIControlStateNormal];
    }

}

- (void)showCenterButton{
    //dispatch_async(dispatch_get_main_queue(), ^{
    self.centerButton.hidden = NO;
    self.leftButton.hidden = YES;
    self.rightButton.hidden = YES;
    self.centerButton.userInteractionEnabled = YES;
    self.leftButton.userInteractionEnabled = NO;
    self.rightButton.userInteractionEnabled = NO;
    //});
}

- (void)hideCenterButton{
    //dispatch_async(dispatch_get_main_queue(), ^{
    self.centerButton.hidden = YES;
    self.rightButton.hidden = NO;
    self.leftButton.hidden = NO;
    self.centerButton.userInteractionEnabled = NO;
    self.leftButton.userInteractionEnabled = YES;
    self.rightButton.userInteractionEnabled = YES;
    //});
}


-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                 presentingController:(UIViewController *)presenting
                                                                     sourceController:(UIViewController *)source {
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController* vc1 =[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* vc2 =[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView* con = [transitionContext containerView];
    UIView* v1 = vc1.view;
    UIView* v2 = vc2.view;
    
    if (vc2 == self) { // presenting
        [con addSubview:v2];
        v2.frame                    = v1.frame;
        self.errorView.transform    = CGAffineTransformMakeScale(1.6,1.6);
        v2.alpha                    = 0;
        v1.tintAdjustmentMode       = UIViewTintAdjustmentModeDimmed;
        [UIView animateWithDuration:0.25 animations:^{
            v2.alpha                    = 1;
            v2.backgroundColor          = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
            self.errorView.transform    = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else { // dismissing
        [UIView animateWithDuration:0.25 animations:^{
            self.errorView.transform    = CGAffineTransformMakeScale(0.5,0.5);
            v1.alpha                    = 0;
        } completion:^(BOOL finished) {
            v2.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            [transitionContext completeTransition:YES];
        }];
    }
    
}

/*
 - (IBAction) doDismiss: (id) sender {
 [self.presentingViewController
 dismissViewControllerAnimated:YES completion:nil];
 }
 
 */

-(void)setDismissOnOutsideViewTap{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapsOutside)];
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.numberOfTouchesRequired = 1;
    // [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)userTapsOutside{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)leftButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(erroMessageLeftButtonClicked)]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        [self.delegate erroMessageLeftButtonClicked];
    }
    else{
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)rightButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(erroMessageRightButtonClicked)]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        [self.delegate erroMessageRightButtonClicked];
    }
    else{
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)centerButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(erroMessageCenterButtonClicked)]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        [self.delegate erroMessageCenterButtonClicked];
    }
    else{
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
