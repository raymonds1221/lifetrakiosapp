//
//  SFAViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAViewController.h"
#import "SFASessionExpiredErrorAlertView.h"
#import "SFAIntroViewController.h"
#import "SFAServerAccountManager.h"
#import "UIViewController+Helper.h"
#import "SFAErrorMessageViewController.h"
#import "SFALoadingViewController.h"
#import "SFASalutronFitnessAppDelegate.h"

@interface SFAViewController () <SFASessionExpiredErrorAlertViewDelegate>

@property (strong, nonatomic) SFASessionExpiredErrorAlertView *sessionExpiredAlertView;

@end

@implementation SFAViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

- (void)alertError:(NSError *)error
{
    if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
        [self.sessionExpiredAlertView showAlertViewWithTitle:LS_SESSION_EXPIRED message:LS_SESSION_EXPIRED_MESSAGE delegate:self];
    }
    else {
        [self alertError:error withTitle:ERROR_TITLE];
    }
}

- (void)alertError:(NSError *)error withTitle:(NSString *)title
{
    NSString *errorMessage = error.localizedDescription;
    if (error.code == 408 || error.code == 503 || error.code == 504 || [error.description rangeOfString:DEFAULT_SERVER_ERROR].location != NSNotFound || [error.description rangeOfString:SERVER_ERROR_2].location != NSNotFound) {
        errorMessage = SERVER_ERROR_MESSAGE;
    }
    else if ([errorMessage isEqualToString:LS_REQUEST_TIMEOUT] || [errorMessage rangeOfString:SERVER_ERROR_PARSE].location != NSNotFound) {
        errorMessage = SERVER_ERROR_MESSAGE;
    }
    else if ([errorMessage rangeOfString:SERVER_ERROR_COCOA].location != NSNotFound) {
        errorMessage = SERVER_ERROR_MESSAGE;
    }
    else if ([errorMessage rangeOfString:NO_INTERNET_ERROR].location != NSNotFound){
        errorMessage = NO_INTERNET_ERROR_MESSAGE;
    }else if ([error.description rangeOfString:FB_USER_CANCELLED_ERROR].location != NSNotFound){
        errorMessage = ERROR_FB_SIGNUP_CANCELLED;
        title = ERROR_FB_TITLE;
    }else if ([error.description rangeOfString:@"com.facebook.sdk"].location != NSNotFound){
        errorMessage = ERROR_FB_MESSAGE;
        title = ERROR_FB_TITLE;
    }
//    else{
//        errorMessage = SERVER_ERROR_MESSAGE;
//    }
    [self alertWithTitle:title message:errorMessage];
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message
{
    
    SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
    //vc.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [vc setErrorTitle:title errorMessage1:message errorMessage2:@"" errorMessage3:@"" andErrorMessage4:@"" andButtonPosition:0 ButtonTitle1:BUTTON_TITLE_OK andButtonTitle2:@""];
    });
    [self presentViewController:vc animated:YES completion:nil];
    /*
    if (self.isIOS8AndAbove) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(title, nil)
                                                                                 message:NSLocalizedString(message, nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:BUTTON_TITLE_OK
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil)
                                                        message:NSLocalizedString(message, nil)
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:BUTTON_TITLE_OK, nil];
    
    [alertView show];
    }
     */
}

#pragma mark - Lazy loading of properties

- (SFASessionExpiredErrorAlertView *)sessionExpiredAlertView
{
    if (!_sessionExpiredAlertView) {
        _sessionExpiredAlertView = [[SFASessionExpiredErrorAlertView alloc] init];
    }
    return _sessionExpiredAlertView;
}

#pragma mark - SFASessionExpiredErrorAlertView delegate methods

- (void)sessionExpiredAlertViewCancelButtonClicked:(SFASessionExpiredErrorAlertView *)errorAlertView
{
    
}

- (void)sessionExpiredAlertViewContinueButtonClicked:(SFASessionExpiredErrorAlertView *)errorAlertView
{
    SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
    [manager logOut];
    /*
    SFAIntroViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAIntroViewController"];
    
    [self presentViewController:viewController animated:YES completion:nil];
     */
    SFALoadingViewController *rootController=(SFALoadingViewController *)((SFASalutronFitnessAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    [rootController returnToRoot];
}


@end
