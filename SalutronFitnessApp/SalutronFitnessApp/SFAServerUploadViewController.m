//
//  SFAServerUploadViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/16/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAServerSyncManager.h"
#import "SFAServerAccountManager.h"

#import "DeviceEntity+Data.h"
#import "UserProfileEntity+Data.h"
#import "StatisticalDataHeaderEntity.h"

#import "SFAServerUploadViewController.h"
#import "UIViewController+Helper.h"
#import "SFASessionExpiredErrorAlertView.h"
#import "SFAServerSyncManager.h"
#import "SFAIntroViewController.h"
#import "JDACoreData.h"
#import "SFALoadingViewController.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFAAmazonServiceManager.h"

#define DASHBOARD_SEGUE_IDENTIFIER @"ServerUploadToDashboard"

@interface SFAServerUploadViewController () <UIAlertViewDelegate, SFASessionExpiredErrorAlertViewDelegate, SFAAmazonServiceManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *serverSyncImage;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) NSOperation *currentOperation;
@property (nonatomic, getter = isCancelSyncOperation) BOOL cancelSyncOperation;
@property (strong, nonatomic) SFASessionExpiredErrorAlertView *sessionExpiredAlertView;
@property (nonatomic) BOOL isNewlyLoaded;
@property (strong, nonatomic) DeviceEntity *device;
@property (strong, nonatomic) NSOperation                       *syncToCloudOperation;

@end

@implementation SFAServerUploadViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isNewlyLoaded = YES;
    
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
    DeviceEntity *device            = [DeviceEntity deviceEntityForMacAddress:macAddress];
    
    self.device = device;
    self.navigationItem.hidesBackButton     = YES;
    self.navigationItem.leftBarButtonItem   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelOperation:)];
    self.serverSyncImage.animationDuration  = 1.0f;
    self.serverSyncImage.animationImages    = @[[UIImage imageNamed:@"ServerSync01"],
                                                [UIImage imageNamed:@"ServerSync02"],
                                                [UIImage imageNamed:@"ServerSync03"],
                                                [UIImage imageNamed:@"ServerSync04"],
                                                [UIImage imageNamed:@"ServerSync05"],
                                                [UIImage imageNamed:@"ServerSync06"],
                                                [UIImage imageNamed:@"ServerSync07"],
                                                [UIImage imageNamed:@"ServerSync08"],
                                                [UIImage imageNamed:@"ServerSync09"],
                                                [UIImage imageNamed:@"ServerSync10"],
                                                [UIImage imageNamed:@"ServerSync11"]];
    
    [self saveDeviceToUser];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.serverSyncImage startAnimating];
    self.navigationController.navigationBar.backItem.title = @"";
    self.title = CLOUD_SYNC;
    self.subLabel.text = CLOUD_SYNC_SUBLABEL;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.serverSyncImage stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isNewlyLoaded) {
        [self updateDataToServerWithDevice2:self.device];
//        if([self.device.modelNumber isEqualToNumber:@(WatchModel_R420)]){
//            [self updateDataToServerWithDevice2:self.device];
//        }
//        else{
//        [self startServerSync];
//        }
        self.isNewlyLoaded = NO;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
/*
- (BOOL)shouldAutorotate
{
    return NO;
}
*/
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBAction Methods
- (void)cancelOperation:(id)sender
{
    self.cancelSyncOperation = YES;
    
    [self.currentOperation cancel];
    self.currentOperation = nil;
    
    [[SFAServerSyncManager sharedManager] cancelOperation];
    [[SFAAmazonServiceManager sharedManager] cancelOperation];
    [self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
}

#pragma mark - UIAlertView Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self updateDataToServerWithDevice2:self.device];
//        if([self.device.modelNumber isEqualToNumber:@(WatchModel_R420)]){
//            [self updateDataToServerWithDevice2:self.device];
//        }
//        else{
//        [self startServerSync];
//        }
    } else {
        [self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
    }
}

#pragma mark - Private Methods

- (void)saveDeviceToUser
{
    NSUserDefaults *userDefaults        = [NSUserDefaults standardUserDefaults];
    SFAServerAccountManager *manager    = [SFAServerAccountManager sharedManager];
    
    if ([userDefaults objectForKey:MAC_ADDRESS]) {
        NSString *macAddress                = [userDefaults objectForKey:MAC_ADDRESS];
        DeviceEntity *device                = [DeviceEntity deviceEntityForMacAddress:macAddress];
        
        [manager.user addDeviceObject:device];
    }
    else {
        NSArray *devices = [DeviceEntity deviceEntities];
        manager.user.device = [NSSet setWithArray:devices];
        SalutronUserProfile *userProfile = [SalutronUserProfile userProfile];
        for (DeviceEntity *device in devices) {
            device.user = manager.user;
            device.userProfile = [UserProfileEntity userProfileWithSalutronUserProfile:userProfile forDeviceEntity:device];
        }
    }
    
    [[JDACoreData sharedManager] save];
}

- (void)startServerSync
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
    DeviceEntity *device            = [DeviceEntity deviceEntityForMacAddress:macAddress];
    SFAServerSyncManager *manager   = [SFAServerSyncManager sharedManager];
    [SFAUserDefaultsManager sharedManager].salutronUserProfile = [SalutronUserProfile userProfileWithUserProfileEntity:device.userProfile];
	
    __weak __block typeof(self) weakSelf = self;
    self.currentOperation = [manager syncDeviceEntity:device withSuccess:^(NSString *macAddress) {
        [self storeToServerWithMacAddress:macAddress];
        device.user.newlyRegistered = [NSNumber numberWithBool:NO];
        device.isSyncedToServer = [NSNumber numberWithBool:YES];
		
    } failure:^(NSError *error) {
        if (weakSelf.isCancelSyncOperation){
            return;
        }
        if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
            [self.sessionExpiredAlertView showAlertViewWithTitle:LS_SESSION_EXPIRED message:LS_SESSION_EXPIRED_MESSAGE delegate:self];
        }
        else {
            if (self.isIOS8AndAbove) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS_CLOUD_SYNC_ERROR
                                                                                         message:error.localizedDescription
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:BUTTON_TITLE_SKIP
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   [self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
                                               }];
                UIAlertAction *retryAction = [UIAlertAction
                                              actionWithTitle:BUTTON_TITLE_RETRY
                                              style:UIAlertActionStyleDefault                                              handler:^(UIAlertAction *action)

                                              {
                                                  [self updateDataToServerWithDevice2:self.device];
//                                                  if([self.device.modelNumber isEqualToNumber:@(WatchModel_R420)]){
//                    [self updateDataToServerWithDevice2:self.device];
//                }
//                                              else{
//                                                  [self startServerSync];
//                                              }
                                              }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:retryAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LS_CLOUD_SYNC_ERROR
                                                            message:error.localizedDescription
                                                            delegate:self
                                                            cancelButtonTitle:BUTTON_TITLE_SKIP
                                                            otherButtonTitles:BUTTON_TITLE_RETRY, nil];
        
            [alertView show];
            }
        }
    }];
}

- (void)storeToServerWithMacAddress:(NSString *)macAddress
{
    SFAServerSyncManager *manager   = [SFAServerSyncManager sharedManager];

    __weak __block typeof(self) weakSelf = self;
    self.currentOperation = [manager storeWithMacAddress:macAddress success:^{
        NSDate *date                    = [NSDate date];
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:data forKey:macAddress];
        
        [self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
    } failure:^(NSError *error) {
        if (weakSelf.cancelSyncOperation){
            return;
        }
        
        if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
            [self.sessionExpiredAlertView showAlertViewWithTitle:LS_SESSION_EXPIRED message:LS_SESSION_EXPIRED_MESSAGE delegate:self];
        }
        else {
            NSString *errorMessage = error.localizedDescription;
            if (error.code == 408 || error.code == 503 || error.code == 504 || [error.description rangeOfString:DEFAULT_SERVER_ERROR].location != NSNotFound) {
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
            }
            else{
                errorMessage = SERVER_ERROR_MESSAGE;
            }
            if (self.isIOS8AndAbove) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                         message:errorMessage
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:BUTTON_TITLE_SKIP
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   [self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
                                               }];
                UIAlertAction *retryAction = [UIAlertAction
                                              actionWithTitle:BUTTON_TITLE_RETRY
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action)
                                              {
                                                  [self updateDataToServerWithDevice2:self.device];
//                                                  if([self.device.modelNumber isEqualToNumber:@(WatchModel_R420)]){
//                                                      [self updateDataToServerWithDevice2:self.device];
//                                                  }
//                                                  else{
//                                                  [self startServerSync];
//                                                  }
                                              }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:retryAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                            message:errorMessage
                                                            delegate:self
                                                            cancelButtonTitle:BUTTON_TITLE_SKIP
                                                            otherButtonTitles:BUTTON_TITLE_RETRY, nil];
        
            [alertView show];
            }
        }
        
    }];
}


- (void)updateDataToServerWithDevice2:(DeviceEntity *)device{
    self.device = device;
    //device.user.newlyRegistered = [NSNumber numberWithBool:NO];
    //device.isSyncedToServer = [NSNumber numberWithBool:YES];
    SFAAmazonServiceManager *amazonServiceManager = [SFAAmazonServiceManager sharedManager];
    amazonServiceManager.delegate = self;
    //[amazonServiceManager uploadArrayOfDataToS3:[[SFAServerSyncManager sharedManager] jsonStringWithDeviceEntityForMultipleDays:device]];
    NSArray *daysOfData = [[SFAServerSyncManager sharedManager] jsonStringWithDeviceEntityForMultipleDays:device];
    if(daysOfData.count > 0){
        [amazonServiceManager uploadArrayOfDataToS3:daysOfData];
    }
    else{
        DDLogError(@"no data to upload to s3, days of data count = %lu", (unsigned long)daysOfData.count);
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                     message:SERVER_ERROR_MESSAGE
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:BUTTON_TITLE_SKIP
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               [self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
                                           }];
            UIAlertAction *retryAction = [UIAlertAction
                                          actionWithTitle:BUTTON_TITLE_RETRY
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *action)
                                          {
                                              [self updateDataToServerWithDevice2:self.device];
                                              
                                              //                                                  if([self.device.modelNumber isEqualToNumber:@(WatchModel_R420)]){
                                              //                                                      [self updateDataToServerWithDevice2:self.device];
                                              //                                                  }
                                              //                                                  else{
                                              //                                                  [self startServerSync];
                                              //                                                  }
                                          }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:retryAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                                message:SERVER_ERROR_MESSAGE
                                                               delegate:self
                                                      cancelButtonTitle:BUTTON_TITLE_SKIP
                                                      otherButtonTitles:BUTTON_TITLE_RETRY, nil];
            
            [alertView show];
        }
    }
}


- (void)amazonServiceUploadFinishedWithParameters:(NSDictionary *)parameters{
    self.subLabel.text = PLEASE_WAIT;
    __weak __block typeof(self) weakSelf = self;
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    self.syncToCloudOperation = [serverSyncManager syncDeviceEntityWithParametersAPIV2:parameters withSuccess:^(NSString *macAddress) {
        //NSDate *date                    = [NSDate date];
        //NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        //[userDefaults setObject:data forKey:macAddress];
        
        //[self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
        //[self showSyncSuccess];
        //[self performSelector:@selector(goToDashboard) withObject:nil afterDelay:1.0];
        
        self.syncToCloudOperation       = nil;
        //self.cancelSyncToCloudOperation = NO;
        
        NSString *macAddress2            = [userDefaults objectForKey:MAC_ADDRESS];
        DeviceEntity *device            = [DeviceEntity deviceEntityForMacAddress:macAddress2];
        [SFAUserDefaultsManager sharedManager].salutronUserProfile = [SalutronUserProfile userProfileWithUserProfileEntity:device.userProfile];
        device.user.newlyRegistered = [NSNumber numberWithBool:NO];
        device.isSyncedToServer = [NSNumber numberWithBool:YES];
        NSDate *date                    = [NSDate date];
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
        //NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        //[userDefaults setObject:data forKey:macAddress];
        
        [self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
        
        
        
        
    } failure:^(NSError *error) {
        if (weakSelf.cancelSyncOperation){
            return;
        }
        if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
            [self.sessionExpiredAlertView showAlertViewWithTitle:LS_SESSION_EXPIRED message:LS_SESSION_EXPIRED_MESSAGE delegate:self];
        }
        else {
            NSString *errorMessage = error.localizedDescription;
            if (error.code == 408 || error.code == 503 || error.code == 504 || [error.description rangeOfString:DEFAULT_SERVER_ERROR].location != NSNotFound) {
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
            }
            else{
                errorMessage = SERVER_ERROR_MESSAGE;
             }
            if (self.isIOS8AndAbove) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                         message:errorMessage
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:BUTTON_TITLE_SKIP
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   [self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
                                               }];
                UIAlertAction *retryAction = [UIAlertAction
                                              actionWithTitle:BUTTON_TITLE_RETRY
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action)
                                              {
                                                  [self updateDataToServerWithDevice2:self.device];

//                                                  if([self.device.modelNumber isEqualToNumber:@(WatchModel_R420)]){
//                                                      [self updateDataToServerWithDevice2:self.device];
//                                                  }
//                                                  else{
//                                                  [self startServerSync];
//                                                  }
                                              }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:retryAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                                    message:errorMessage
                                                                   delegate:self
                                                          cancelButtonTitle:BUTTON_TITLE_SKIP
                                                          otherButtonTitles:BUTTON_TITLE_RETRY, nil];
                
                [alertView show];
            }
        }
        

    }];
}

- (void)amazonServiceUploadFailedWithError:(NSError *)error{
    __weak __block typeof(self) weakSelf = self;
    if (weakSelf.cancelSyncOperation){
        return;
    }
    
    if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
        [self.sessionExpiredAlertView showAlertViewWithTitle:LS_SESSION_EXPIRED message:LS_SESSION_EXPIRED_MESSAGE delegate:self];
    }
    else {
        NSString *errorMessage = error.localizedDescription;
        if (error.code == 408 || error.code == 503 || error.code == 504 || [error.description rangeOfString:DEFAULT_SERVER_ERROR].location != NSNotFound) {
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
        }
        else{
            errorMessage = SERVER_ERROR_MESSAGE;
        }
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                     message:errorMessage
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:BUTTON_TITLE_SKIP
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               [self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
                                           }];
            UIAlertAction *retryAction = [UIAlertAction
                                          actionWithTitle:BUTTON_TITLE_RETRY
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *action)
                                          {
                                              [self updateDataToServerWithDevice2:self.device];
//                                              if([self.device.modelNumber isEqualToNumber:@(WatchModel_R420)]){
//                                                  [self updateDataToServerWithDevice2:self.device];
//                                              }
//                                              else{
//                                              [self startServerSync];
//                                              }
                                          }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:retryAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                                message:errorMessage
                                                               delegate:self
                                                      cancelButtonTitle:BUTTON_TITLE_SKIP
                                                      otherButtonTitles:BUTTON_TITLE_RETRY, nil];
            
            [alertView show];
        }
    }
    

    self.syncToCloudOperation       = nil;
    //self.cancelSyncToCloudOperation = NO;
}

- (void)amazonServiceProgress:(int)progress{
    self.subLabel.text = [NSString stringWithFormat:@"%@ (%i%@)", CLOUD_SYNC_SUBLABEL, progress, @"%"];
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
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
