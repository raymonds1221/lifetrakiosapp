//
//  SFABackupDataViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/3/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFABackupDataViewController.h"
#import "SFAErrorMessageViewController.h"

#import "SFAServerSyncManager.h"
#import "SFAServerAccountManager.h"

#import "DeviceEntity+Data.h"
#import "UserProfileEntity+Data.h"

#import "UIViewController+Helper.h"
#import "SFASessionExpiredErrorAlertView.h"
#import "SFAServerSyncManager.h"
#import "SFAIntroViewController.h"
#import "SFALoadingViewController.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFAAmazonServiceManager.h"

@interface SFABackupDataViewController () <SFAErrorMessageViewControllerDelegate, SFASessionExpiredErrorAlertViewDelegate, SFAAmazonServiceManagerDelegate>

@property (strong, nonatomic) NSOperation *currentOperation;
@property (nonatomic, getter = isCancelSyncOperation) BOOL cancelSyncOperation;
@property (strong, nonatomic) SFASessionExpiredErrorAlertView *sessionExpiredAlertView;
@property (nonatomic) BOOL isNewlyLoaded;
@property (readwrite, nonatomic) BOOL                           cancelSyncToCloudOperation;
@property (strong, nonatomic) NSOperation                       *syncToCloudOperation;
@property (strong, nonatomic) DeviceEntity *device;

@end

/*
 Step 5: Sync watch data to cloud.
 */

@implementation SFABackupDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title          = BACKUP_DATA_TITLE;
    self.mainLabel.text = LS_SYNC_CLOUD;
    self.subLabel.text  = PLEASE_WAIT;
    
    self.isNewlyLoaded = YES;
    /*
    self.navigationItem.hidesBackButton     = YES;
    self.navigationItem.leftBarButtonItem   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelOperation:)];
    
    */
    self.imageView.animationDuration  = 1.0f;
    self.imageView.animationImages    = @[[UIImage imageNamed:@"ServerSync01"],
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
    
    [self.imageView startAnimating];
    [self saveDeviceToUser];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.imageView startAnimating];
    //self.navigationController.navigationBar.backItem.title = @"";
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isNewlyLoaded) {
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
        DeviceEntity *device            = [DeviceEntity deviceEntityForMacAddress:macAddress];
        
        [self updateDataToServerWithDevice2:device];
//        if([device.modelNumber isEqualToNumber:@(WatchModel_R420)]){
//            [self updateDataToServerWithDevice2:device];
//        }
//        else{
//            [self startServerSync];
//        }
        self.isNewlyLoaded = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.imageView stopAnimating];
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

- (void)leftButtonClicked:(id)sender{
    [self cancelOperation:self];
    //[self dismissViewControllerAnimated:NO completion:nil];
    /*
    SFALoadingViewController *rootController=(SFALoadingViewController *)((SFASalutronFitnessAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    //rootController.isSwitchWatch = YES;
    [rootController returnToRoot];
     */
    [self goToDashboard];
}

- (void)rightButtonCicked:(id)sender{
    
}

- (void)showErrorMessage{
    SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
    vc.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc setErrorTitle:ERROR_BACKUP_FAILED
            errorMessage1:ERROR_CHECK_YOUR_INTERNET
            errorMessage2:@""
            errorMessage3:@""
         andErrorMessage4:@""
        andButtonPosition:1
             ButtonTitle1:BUTTON_TITLE_CANCEL
          andButtonTitle2:LS_TRY_AGAIN];
    });
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)erroMessageCenterButtonClicked{
    
}

- (void)erroMessageLeftButtonClicked{
    [self goToDashboard];
}

- (void)erroMessageRightButtonClicked{
    
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
    DeviceEntity *device            = [DeviceEntity deviceEntityForMacAddress:macAddress];
    
    [self performSelector:@selector(updateDataToServerWithDevice2:) withObject:device afterDelay:0.5];
//    if([device.modelNumber isEqualToNumber:@(WatchModel_R420)]){
//        //[self updateDataToServerWithDevice2:device];
//        [self performSelector:@selector(updateDataToServerWithDevice2:) withObject:device afterDelay:0.5];
//    }
//    else{
//        [self performSelector:@selector(startServerSync) withObject:nil afterDelay:0.5];
//    }
    
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
    //[self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
   // [self goToDashboard];
}

#pragma mark - UIAlertView Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
        DeviceEntity *device            = [DeviceEntity deviceEntityForMacAddress:macAddress];
        
        [self updateDataToServerWithDevice2:device];
//        if([device.modelNumber isEqualToNumber:@(WatchModel_R420)]){
//            [self updateDataToServerWithDevice2:device];
//        }
//        else{
//            [self startServerSync];
//        }
    } else {
        //[self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
        [self goToDashboard];
    }
}

- (void)goToDashboard{
    
    NSString *storyBoardName = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"Main" : @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    UIViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"SFASlidingViewController"];
    [self presentViewController:ivc animated:YES completion:nil];
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
        SalutronUserProfile *userProfile = [SalutronUserProfile userProfile];
        device.user = manager.user;
        device.userProfile = [UserProfileEntity userProfileWithSalutronUserProfile:userProfile forDeviceEntity:device];
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
            //dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showErrorMessage];
            });
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
        
        //[self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
        [self showSyncSuccess];
        //[self performSelector:@selector(goToDashboard) withObject:nil afterDelay:1.0];
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
            
            SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
            vc.delegate = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [vc setErrorTitle:ERROR_TITLE
                    errorMessage1:errorMessage
                    errorMessage2:@""
                    errorMessage3:@""
                 andErrorMessage4:@""
                andButtonPosition:1
                     ButtonTitle1:BUTTON_TITLE_SKIP
                  andButtonTitle2:BUTTON_TITLE_RETRY];
            });
            [self presentViewController:vc animated:YES completion:nil];
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
        SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
        vc.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc setErrorTitle:ERROR_TITLE
                errorMessage1:SERVER_ERROR_MESSAGE
                errorMessage2:@""
                errorMessage3:@""
             andErrorMessage4:@""
            andButtonPosition:1
                 ButtonTitle1:BUTTON_TITLE_SKIP
              andButtonTitle2:BUTTON_TITLE_RETRY];
        });
        [self presentViewController:vc animated:YES completion:nil];
        self.syncToCloudOperation       = nil;
        self.cancelSyncToCloudOperation = NO;
    }

}


- (void)amazonServiceUploadFinishedWithParameters:(NSDictionary *)parameters{
    self.subLabel.text = PLEASE_WAIT;
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    self.syncToCloudOperation = [serverSyncManager syncDeviceEntityWithParametersAPIV2:parameters withSuccess:^(NSString *macAddress) {
        //NSDate *date                    = [NSDate date];
        //NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        //[userDefaults setObject:data forKey:macAddress];
        
        //[self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
        [self showSyncSuccess];
        //[self performSelector:@selector(goToDashboard) withObject:nil afterDelay:1.0];
        
        self.syncToCloudOperation       = nil;
        self.cancelSyncToCloudOperation = NO;
        
        NSString *macAddress2            = [userDefaults objectForKey:MAC_ADDRESS];
        DeviceEntity *device            = [DeviceEntity deviceEntityForMacAddress:macAddress2];
        [SFAUserDefaultsManager sharedManager].salutronUserProfile = [SalutronUserProfile userProfileWithUserProfileEntity:device.userProfile];
            device.user.newlyRegistered = [NSNumber numberWithBool:NO];
            device.isSyncedToServer = [NSNumber numberWithBool:YES];
        
        
        
    } failure:^(NSError *error) {
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
            
            SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
            vc.delegate = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [vc setErrorTitle:ERROR_TITLE
                    errorMessage1:errorMessage
                    errorMessage2:@""
                    errorMessage3:@""
                 andErrorMessage4:@""
                andButtonPosition:1
                     ButtonTitle1:BUTTON_TITLE_SKIP
                  andButtonTitle2:BUTTON_TITLE_RETRY];
            });
            [self presentViewController:vc animated:YES completion:nil];
        }

        self.syncToCloudOperation       = nil;
        self.cancelSyncToCloudOperation = NO;
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
        
        SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
        vc.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc setErrorTitle:ERROR_TITLE
                errorMessage1:errorMessage
                errorMessage2:@""
                errorMessage3:@""
             andErrorMessage4:@""
            andButtonPosition:1
                 ButtonTitle1:BUTTON_TITLE_SKIP
              andButtonTitle2:BUTTON_TITLE_RETRY];
        });
        [self presentViewController:vc animated:YES completion:nil];
    }
    self.syncToCloudOperation       = nil;
    self.cancelSyncToCloudOperation = NO;
}

- (void)amazonServiceProgress:(int)progress{
    self.subLabel.text = [NSString stringWithFormat:@"%i%@", progress, @"%"];
}


- (void)showSyncSuccess{
    self.mainLabel.text                 = SYNCING_SUCCESSFUL;
    self.subLabel.text                  = @"";
    
    [self.imageView stopAnimating];
    self.imageView.animationImages      = nil;
    self.imageView.image                = [UIImage imageNamed:@"ServerSyncSuccessful"];
    //self.progressBarGray.hidden         = YES;
    //self.progressBar.hidden             = YES;
    [self performSelector:@selector(goToDashboard) withObject:nil afterDelay:1.0];
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
