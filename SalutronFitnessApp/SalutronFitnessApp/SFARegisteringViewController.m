//
//  SFARegisteringViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/1/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFARegisteringViewController.h"
#import "SFAServerAccountManager.h"
#import "SFAErrorMessageViewController.h"
#import "SFAFacebookManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SFAServerSyncManager.h"

@interface SFARegisteringViewController ()

@end

@implementation SFARegisteringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.navigationController.navigationBarHidden = YES;
    
    [self initializeObjects];
    
    if (self.isFacebookSignup) {
       // SFAFacebookManager *manager = [SFAFacebookManager sharedManager];
        
        //[manager logInWithFacebookWithSuccess:^(NSString *accessToken) {
            [self logInWithFacebookAccessToken:self.accessToken];
        //} failure:^(NSError *error) {
            //[SVProgressHUD dismiss];
            //[self alertError:error];
          //  [self dismissViewControllerAnimated:NO completion:^{
          //      [self.delegate registeringVCDismissedWithError:error withViewController:self];
                //[self alertError:error];
          //  }];
        //}];

    }
    else{
        SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
        
        //[SVProgressHUD showWithStatus:STATUS_REGISTER maskType:SVProgressHUDMaskTypeBlack];
        [serverAccountManager registerWithEmailAddress:self.email password:self.password firstName:self.firstName lastName:self.lastName userImage:self.userImage success:^{
            //[SVProgressHUD showSuccessWithStatus:STATUS_REGISTER_SUCCESS];
            //[SVProgressHUD dismiss];
            [self getProfile];
            //[self performSegueWithIdentifier:@"RegisteringToWelcomeUser" sender:self];
        } failure:^(NSError *error) {
            //[SVProgressHUD dismiss];
            //[self.navigationController popViewControllerAnimated:YES];
            //[self performSegueWithIdentifier:@"unwindToSignup" sender:self];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                    [self.delegate registeringVCDismissedWithError:error withViewController:self];
                }];
            });
            //[self dismissViewControllerAnimated:NO completion:^{
//                 [self.delegate registeringVCDismissedWithError:error withViewController:self];
                //[self alertError:error];
            //}];
             
            //[self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)initializeObjects{
    self.navigationController.navigationBarHidden = YES;
    self.mainLabel.text = REGISTERING_ACCOUNT;
    self.subLabel.text  = PLEASE_WAIT;
}

- (void)getProfile
{
    SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
    [manager getProfileWithSuccess:^{
        //[self performSegueWithIdentifier:@"RegisteringToWelcomeUser" sender:self];
        //[SVProgressHUD dismiss];
        [self getDeviceEntities];
        
    } failure:^(NSError *error) {
        //[SVProgressHUD dismiss];
        //[self alertError:error];
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate registeringVCDismissedWithError:error withViewController:self];
            //[self alertError:error];
        }];
    }];
}

- (void)getDeviceEntities
{
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    
    [serverSyncManager getDevicesWithSuccess:^(NSArray *deviceEntities) {
        
        [self performSegueWithIdentifier:@"RegisteringToWelcomeUser" sender:self];
        
    } failure:^(NSError *error) {
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate registeringVCDismissedWithError:error withViewController:self];
            //[self alertError:error];
        }];
    }];
}

- (void)logInWithFacebookAccessToken:(NSString *)accessToken
{
    SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
    
    [manager logInWithFacebookAccessToken:accessToken success:^{
        [self getProfile];
    } failure:^(NSError *error) {
        //[SVProgressHUD dismiss];
        //[self alertError:error];
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate registeringVCDismissedWithError:error withViewController:self];
            //[self alertError:error];
        }];
    }];
    
    //[SVProgressHUD showWithStatus:LS_SIGN_UP_VIA_FACEBOOK maskType:SVProgressHUDMaskTypeBlack];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
