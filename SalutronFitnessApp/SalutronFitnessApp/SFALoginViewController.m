//
//  SFALoginViewController.m
//  SalutronFitnessApp
//
//  Created by Dana Nicolas on 4/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "ECSlidingViewController.h"
#import "UIViewController+Helper.h"
#import "AFHTTPRequestOperationManager.h"
#import "SVProgressHUD.h"

#import "DeviceEntity+Data.h"

#import "SFAServerAccountManager.h"
#import "SFAFacebookManager.h"
#import "SFAServerSyncManager.h"

#import "SFAInputCell.h"
#import "SFALogInButtonCell.h"

#import "SFALoginViewController.h"
#import "SFALoadingViewController.h"
#import "SFARegistrationViewController.h"
#import "SFADevicesViewController.h"
#import "SFAUserDefaultsManager.h"
#import "SDImageCache.h"


#import "SFAServerSyncNavigationViewController.h"
#import "SFAServerSyncViewController.h"
#import "UserProfileEntity+Data.h"
#import "TimeDate+Data.h"
#import "NotificationEntity+Data.h"
#import "SleepSetting+Data.h"
#import "Notification+Data.h"
#import "TimeDate+Data.h"
#import "TimeDateEntity+Data.h"
#import "CalibrationData+Data.h"
#import "CalibrationDataEntity+Data.h"
#import "SleepSettingEntity+Data.h"
#import "JDACoreData.h"
#import "DayLightAlert+Data.h"
#import "NightLightAlert+Data.h"
#import "InactiveAlert+Data.h"
#import "Wakeup+Data.h"
#import "DayLightAlertEntity+Data.h"
#import "NightLightAlertEntity+Data.h"
#import "InactiveAlertEntity+Data.h"
#import "WakeupEntity+Data.h"
#import "Wakeup+Entity.h"
#import "DayLightAlert+Entity.h"
#import "NightLightAlert+Entity.h"
#import "InactiveAlert+Entity.h"
#import "SFAGoalsData.h"


#import "Flurry.h"

//#define DEVICES_SEGUE_IDENTIFIER            @"LoginToDevices"
#define WELCOME_VIEW_ID                     @"SFAWelcomeViewNavigationController"
#define FORGOT_PASSWORD_SEGUE_IDENTIFIER    @"LoginToForgotPassword"
#define SLIDING_SEGUE_IDENTIFIER            @"SigninToSliding"
#define SLIDING_VIEW_ID                     @"SFASlidingViewController"
#define SERVER_SYNC_SEGUE_IDENTIFIER        @"SigninToServerSync"
#define SERVER_SYNC_VIEW_ID                 @"SFAServerSyncNavigationViewController"
#define WELCOME_TO_SERVER_UP_SEGUE_IDENTIFIER @"SigninToServerUpSegueIdentifier"
#define SERVER_UPLOAD_VIEW_ID               @"ServerUploadNavigationController"

#define LOG_IN_EMAIL_CELL           @"SFALogInEmailCell"
#define LOG_IN_PASSWORD_CELL        @"SFALogInPasswordCell"
#define LOG_IN_BUTTON_CELL          @"SFALogInButtonCell"

#define IMAGE_CHECKBOX_UNCHECKED    [UIImage imageNamed:@"Checkbox_empty"]
#define IMAGE_CHECKBOX_CHECKED      [UIImage imageNamed:@"Checkbox_check"]

#define KEY_USERNAME                @"RememberUsername"
#define KEY_PASSWORD                @"RememberPassword"

@interface SFALoginViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton       *checkboxButton;
@property (weak, nonatomic) IBOutlet UIButton       *loginButton;
@property (weak, nonatomic) IBOutlet UIButton       *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet UIButton       *rememberPasswordButton;

@property (weak, nonatomic) IBOutlet UIButton       *loginFBButton;

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (strong, nonatomic) NSArray *deviceEntites;

@property (strong, nonatomic) NSArray               *watches;
@property (strong, nonatomic) DeviceEntity          *device;

@property (strong, nonatomic) SFAUserDefaultsManager *userDefaultsManager;

@end

@implementation SFALoginViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [Flurry logEvent:SIGNIN_PAGE];
    self.inputContainer = self.tableView;
    self.title = SIGNIN_SMALL;
    /*
    NSString *imagePath = @"LogInFacebookButton";
    if (LANGUAGE_IS_FRENCH) {
        imagePath = @"LogInFacebookButton_fr";
    }
    */
    //[self.loginFBButton setImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
    [self.loginFBButton setTitle:SIGNIN_FB forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) shouldAutorotate
{
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*if ([segue.identifier isEqualToString:DEVICES_SEGUE_IDENTIFIER]) {
        SFADevicesViewController *viewController = (SFADevicesViewController *)segue.destinationViewController;
        viewController.deviceEntities = self.deviceEntites;
    }*/
    if ([segue.identifier isEqualToString:SERVER_SYNC_SEGUE_IDENTIFIER]) {
        SFAServerSyncNavigationViewController *navigation = (SFAServerSyncNavigationViewController *)segue.destinationViewController;
        SFAServerSyncViewController *viewController = (SFAServerSyncViewController *)navigation.viewControllers[0];
        viewController.deviceEntity = self.device;
    }

}

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 168.0f;
    }
    
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        SFALogInButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:LOG_IN_BUTTON_CELL];
        [cell.logInButton setTitle:SIGNIN forState:UIControlStateNormal];
        cell.rememberMeLabel.text = REMEMBER_ME;
        [cell.forgotPasswordButton setTitle:FORGOT_YOUR_PASSWORD forState:UIControlStateNormal];
        self.loginButton = cell.logInButton;
        self.rememberPasswordButton = cell.rememberPasswordButton;
        self.rememberPasswordButton.tag = [self checkboxSelected];
        //[self.rememberPasswordButton setTitle:LS_FORGOT_PASSWORD forState:UIControlStateNormal];
        [self updateCheckbox:self.rememberPasswordButton];
        cell.forgotPasswordButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.forgotPasswordButton = cell.forgotPasswordButton;
        [self.loginButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:245/255.0 alpha:1];
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 72.0f;
        }
        else if (indexPath.row == 1) {
            return 62.0f;
        }
        else if (indexPath.row == 2) {
            return [SFALogInButtonCell height];
        }
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return LS_SIGN_IN_EMAIL;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            SFAInputCell *cell              = [tableView dequeueReusableCellWithIdentifier:LOG_IN_EMAIL_CELL];
            cell.inputTitle.hidden          = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERNAME] ? NO : YES;
            cell.inputTextField.placeholder = LS_EMAIL;
            cell.inputTitle.text            = LS_EMAIL;
            self.emailTextField             = cell.inputTextField;
            self.emailTextField.text        = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERNAME] ?: self.emailTextField.text;
            self.emailTextField.delegate    = self;
            self.emailLabel                 = cell.inputTitle;
            self.emailCellSeparator         = cell.cellSeparator;
            return cell;
        } else if (indexPath.row == 1) {
            SFAInputCell *cell              = [tableView dequeueReusableCellWithIdentifier:LOG_IN_PASSWORD_CELL];
            cell.inputTitle.hidden          = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_PASSWORD] ? NO : YES;
            cell.inputTextField.placeholder = LS_PASSWORD;
            cell.inputTitle.text            = LS_PASSWORD;
            self.passwordTextField          = cell.inputTextField;
            self.passwordTextField.text     = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_PASSWORD] ?: self.passwordTextField.text;
            self.passwordTextField.delegate = self;
            self.passwordLabel              = cell.inputTitle;
            self.passwordCellSeparator      = cell.cellSeparator;
            return cell;
        }
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        self.emailCellSeparator.backgroundColor = LIFETRAK_COLOR;
        self.emailLabel.textColor               = LIFETRAK_COLOR;
        self.emailLabel.hidden                  = NO;
        [self.emailTextField becomeFirstResponder];
    }
    else if (indexPath.row == 1) {
        self.passwordCellSeparator.backgroundColor = LIFETRAK_COLOR;
        self.passwordLabel.textColor               = LIFETRAK_COLOR;
        self.passwordLabel.hidden                  = NO;
        [self.passwordTextField becomeFirstResponder];
    }
}

#pragma mark - Remember username and password

- (void)toggleCheckbox:(UIButton *)sender
{
    sender.tag = !sender.tag;
    
    [self updateCheckbox:sender];
}

- (void)updateCheckbox:(UIButton *)sender
{
    UIImage *checkBoxImage = sender.tag ? IMAGE_CHECKBOX_CHECKED : IMAGE_CHECKBOX_UNCHECKED;
    
    [sender setImage:checkBoxImage forState:UIControlStateNormal];
    [sender setImage:checkBoxImage forState:UIControlStateHighlighted];
    [sender setImage:checkBoxImage forState:UIControlStateSelected];
}

- (void)rememberUsernameAndPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.emailTextField.text forKey:KEY_USERNAME];
    [userDefaults setObject:self.passwordTextField.text forKey:KEY_PASSWORD];
    [userDefaults synchronize];
}

- (BOOL)checkboxSelected
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USERNAME] ? YES : NO;
}

- (void)forgetUsernameAndPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:KEY_USERNAME];
    [userDefaults removeObjectForKey:KEY_PASSWORD];
    [userDefaults synchronize];
}

#pragma mark - IBAction Methods

- (IBAction)checkboxButtonClicked:(UIButton *)sender
{
    [self toggleCheckbox:sender];
}

- (IBAction)menuButtonPressed:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)facebookLoginButtonClicked:(id)sender
{
    SFAFacebookManager *manager = [SFAFacebookManager sharedManager];
    
    [manager logInWithFacebookWithSuccess:^(NSString *accessToken) {
        [self logInWithFacebookAccessToken:accessToken];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self alertError:error];
    }];
    
    [self resignFirstResponder];
}

- (IBAction)loginButtonClicked:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:PROMPT_CHANGE_SETTINGS];
    [userDefaults synchronize];
    DDLogInfo(@"PROMPT_CHANGE_SETTINGS : %d", [userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]);
    
    if ([self hasValidInput]) {
        
        NSData *lastLoginDateData = [NSKeyedArchiver archivedDataWithRootObject:[NSDate date]];
        //[[NSUserDefaults standardUserDefaults] setObject:lastLoginDateData forKey:LAST_LOGIN_DATE];
        [userDefaults setObject:lastLoginDateData forKey:LAST_LOGIN_DATE];
        [userDefaults synchronize];
    
        if (self.rememberPasswordButton.tag) {
            [self rememberUsernameAndPassword];
        }
        else {
            [self forgetUsernameAndPassword];
        }
        
        SFAServerAccountManager *serverAccountManager = [SFAServerAccountManager sharedManager];
        
        [serverAccountManager logInWithEmailAddress:self.emailTextField.text password:self.passwordTextField.text success:^{
            self.userDefaultsManager.notificationStatus = YES;
            self.userDefaultsManager.promptChangeSettings = YES;
            [self getProfile];
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            [self alertError:error];
        }];
        
        [SVProgressHUD showWithStatus:LS_SIGN_IN_MESSAGE maskType:SVProgressHUDMaskTypeBlack];
    }

    [self resignFirstResponder];
}

- (IBAction)forgotPasswordButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    [self performSegueWithIdentifier:FORGOT_PASSWORD_SEGUE_IDENTIFIER sender:sender];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods

- (BOOL)hasValidInput
{
    NSString *emailAddress  = self.emailTextField.text;
    NSString *password      = self.passwordTextField.text;
    
    // Check if all fields has text
    if (emailAddress.length > 0 &&
        password.length     > 0 ) {
        
        if ([emailAddress isEmail]) {
            return YES;
        }
        else {
            [self alertWithTitle:ERROR_TITLE message:ERROR_REGISTER_EMAIL];
        }
    } else {
        [self alertWithTitle:ERROR_TITLE message:ERROR_LOG_IN_MISSING_FIELDS];
    }
    
    return NO;
}


- (void)logInWithFacebookAccessToken:(NSString *)accessToken
{
    SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
    
    [manager logInWithFacebookAccessToken:accessToken success:^{
        [self getProfile];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self alertError:error];
    }];
    
    [SVProgressHUD showWithStatus:LS_SIGN_IN_FACEBOOK maskType:SVProgressHUDMaskTypeBlack];
}

- (void)getProfile
{
    SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
    
    [manager getProfileWithSuccess:^{
        [self getDeviceEntities];
        SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
        [[SDImageCache sharedImageCache] removeImageForKey:manager.user.imageURL fromDisk:YES];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self alertError:error];
    }];
    
    [SVProgressHUD setStatus:LS_FETCHING_USER_PROFILE];
}

- (void)getDeviceEntities
{
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    
    [serverSyncManager getDevicesWithSuccess:^(NSArray *deviceEntities) {
        self.deviceEntites = [DeviceEntity deviceEntities];
        //self.deviceEntites = deviceEntities;
        
        [SVProgressHUD dismiss];

        //Dont remove, might be needed on next release
        //[self isAccountActivated];
            [self initializeObjects];
//            [self performSegueWithIdentifier:DEVICES_SEGUE_IDENTIFIER sender:self];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self alertError:error];
    }];
    
    [SVProgressHUD setStatus:LS_FETCHING_DEVICES];
}

- (void)isAccountActivated
{
    BOOL _isActivated = [[NSUserDefaults standardUserDefaults] boolForKey:API_USER_ACTIVATED];
    
    if (!_isActivated) {
        SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
        
        if (!manager.isFacebookLogIn) {
            if (self.isIOS8AndAbove) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                         message:LS_VALIDATE_EMAIL_MESSAGE
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:LS_REMIND_LATER
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               
                                           }];
                
                [alertController addAction:okAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else{
                UIAlertView *activateAlert = [[UIAlertView alloc] initWithTitle:@"" message:LS_VALIDATE_EMAIL_MESSAGE delegate:self cancelButtonTitle:LS_REMIND_LATER otherButtonTitles: nil];
                [activateAlert show];
            }
        }
        
    }
}

#pragma mark - UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.emailTextField]){
        NSString *resultingString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
        return [resultingString rangeOfCharacterFromSet:whitespaceSet].location == NSNotFound ? YES:NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (textField == self.emailTextField) {
        self.emailLabel.textColor                   = [UIColor lightGrayColor];
        self.emailCellSeparator.backgroundColor     = LIFETRAK_COLOR_INACTIVE;
    }
    if (textField == self.passwordTextField) {
        self.passwordLabel.textColor                = [UIColor lightGrayColor];
        self.passwordCellSeparator.backgroundColor  = LIFETRAK_COLOR_INACTIVE;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.emailTextField) {
        self.emailLabel.hidden                      = NO;
        self.emailLabel.textColor                   = LIFETRAK_COLOR;
        self.emailCellSeparator.backgroundColor     = LIFETRAK_COLOR;
    }
    if (textField == self.passwordTextField) {
        self.passwordLabel.hidden                   = NO;
        self.passwordLabel.textColor                = LIFETRAK_COLOR;
        self.passwordCellSeparator.backgroundColor  = LIFETRAK_COLOR;
    }
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0) {
        if (textField == self.emailTextField) {
            self.emailLabel.hidden = YES;
        }
        if (textField == self.passwordTextField) {
            self.passwordLabel.hidden = YES;
        }
    }
    
}


#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}


- (void)goToDashboard{
    self.device = self.watches[0];
    [self initializeDevice];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.device.macAddress forKey:LAST_MAC_ADDRESS];
    [userDefaults synchronize];
    
    /*
     NSDate *lastLoginDate = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOGIN_DATE]];
     
     if ([lastLoginDate compare:self.device.lastDateSynced] == NSOrderedAscending) {
     [self performSegueWithIdentifier:SERVER_SYNC_SEGUE_IDENTIFIER sender:self];
     return;
     }*/
    
    
    if (![self.device.isSyncedToServer boolValue] && [self.device.cloudSyncEnabled boolValue]) {//self.userDefaultsManager.autoSyncToWatchEnabled
        //[self performSegueWithIdentifier:WELCOME_TO_SERVER_UP_SEGUE_IDENTIFIER sender:self];
        //SERVER_UPLOAD_VIEW_ID
        NSString *storyBoardName = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"Main" : @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
        UIViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:SERVER_UPLOAD_VIEW_ID];
        [self presentViewController:ivc animated:YES completion:nil];
    }
    else {
        if (self.device.header.count > 0) {
            [self initializeGoals];
            [self initializeDeviceSettings];
            //[self performSegueWithIdentifier:SLIDING_SEGUE_IDENTIFIER sender:self];
                NSString *storyBoardName = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"Main" : @"Main";
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
                UIViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"SFASlidingViewController"];
                [self presentViewController:ivc animated:YES completion:nil];
        }
        else {
            //[self performSegueWithIdentifier:SERVER_SYNC_SEGUE_IDENTIFIER sender:self];
            NSString *storyBoardName = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"Main" : @"Main";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
            UIViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:SERVER_SYNC_VIEW_ID];
            SFAServerSyncNavigationViewController *navigation = (SFAServerSyncNavigationViewController *)ivc;
            SFAServerSyncViewController *viewController = (SFAServerSyncViewController *)navigation.viewControllers[0];
            viewController.deviceEntity = self.device;
            [self presentViewController:navigation animated:YES completion:nil];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Done" forKey:@"AutoSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)initializeObjects
{
    // Update image logo for localization
    NSString *filePathName = @"lifetrak_logo";
    if (LANGUAGE_IS_FRENCH) {
        filePathName = @"lifetrak_logo_fr";
    }
    
    SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
    self.watches = [manager.user.device allObjects];
    
    NSArray *sortedWatches = [self.watches sortedArrayUsingComparator:^NSComparisonResult(id firstDevice, id secondDevice) {
        NSDate *first = [(DeviceEntity *)firstDevice lastDateSynced];
        NSDate *second = [(DeviceEntity *)secondDevice lastDateSynced];
        return [second compare:first];
    }];
    
    self.watches = sortedWatches;
    
    for (DeviceEntity *deviceEntity in self.watches) {
        DDLogError(@"deviceEntity: %@ %@ %@", deviceEntity.name, deviceEntity.lastDateSynced, deviceEntity.modelNumberString);
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:DEVICE_UUID];
    [userDefaults setObject:nil forKey:MAC_ADDRESS];
    [userDefaults setObject:@(NO) forKey:HAS_PAIRED];
    [userDefaults synchronize];
    
    
    [[SDImageCache sharedImageCache] removeImageForKey:manager.user.imageURL fromDisk:YES];
    if (self.watches.count == 1) {
        [self goToDashboard];
    }
    else{
       // [self performSegueWithIdentifier:DEVICES_SEGUE_IDENTIFIER sender:self];
        NSString *storyBoardName = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"Main" : @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
        UIViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:WELCOME_VIEW_ID];
        [self presentViewController:ivc animated:YES completion:nil];
    }
}



- (void)initializeDevice
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    
    if (self.device.lastDateSynced) {
        NSData *dataLastSyncDate        = [NSKeyedArchiver archivedDataWithRootObject:self.device.lastDateSynced];
        [userDefaults setObject:dataLastSyncDate forKey:LAST_SYNC_DATE];
    }
    
    [userDefaults setObject:self.device.uuid forKey:DEVICE_UUID];
    [userDefaults setObject:self.device.macAddress forKey:MAC_ADDRESS];
    [userDefaults setObject:self.device.modelNumber forKey:CONNECTED_WATCH_MODEL];
    [userDefaults setBool:TRUE forKey:HAS_PAIRED];
    [userDefaults synchronize];
}

- (void)initializeDeviceSettings
{
    [self initializeUserProfile];
    [self initializeTimeDate];
    [self initializeNotification];
    [self initializeSleepSetting];
    [self initializeCalibrationData];
    if ([self.device.modelNumber isEqualToNumber:@(WatchModel_R450)]) {
        [self initializeAlertSettings];
    }
}

- (void)initializeUserProfile
{
    if (!self.device.userProfile) {
        SalutronUserProfile *userProfile = [SalutronUserProfile userProfile];
        [UserProfileEntity userProfileWithSalutronUserProfile:userProfile forDeviceEntity:self.device];
    } else {
        [SalutronUserProfile userProfileWithUserProfileEntity:self.device.userProfile];
    }
}

- (void)initializeTimeDate
{
    if (!self.device.timeDate) {
        TimeDate *timeDate = [TimeDate timeDate];
        [TimeDateEntity timeDateWithTimeDate:timeDate forDeviceEntity:self.device];
    } else {
        [TimeDate timeDateWithTimeDateEntity:self.device.timeDate];
    }
}

- (void)initializeNotification
{
    //  if (!self.device.notification) {
    Notification *notification  = [Notification notification];
    [NotificationEntity notificationWithNotification:notification notificationStatus:[SFAUserDefaultsManager sharedManager].notificationStatus forDeviceEntity:self.device];
    [SFAUserDefaultsManager sharedManager].notification = notification;
    
    //  } else {
    //      [Notification notificationWithNotificationEntity:self.device.notification];
    //  }
}

- (void)initializeSleepSetting
{
    if (!self.device.sleepSetting) {
        SleepSetting *sleepSetting = [SleepSetting sleepSetting];
        [SleepSettingEntity sleepSettingWithSleepSetting:sleepSetting forDeviceEntity:self.device];
    } else {
        [SleepSetting sleepSettingWithSleepSettingEntity:self.device.sleepSetting];
    }
}

- (void)initializeCalibrationData
{
    if (!self.device.calibrationData) {
        CalibrationData *calibrationData = [CalibrationData calibrationData];
        [CalibrationDataEntity calibrationDataWithCalibrationData:calibrationData forDeviceEntity:self.device];
    } else {
        //        CalibrationData *calibrationData = [CalibrationData calibrationDataWithCalibrationDataEntity:self.device.calibrationData];
        //        [CalibrationData calibrationDataWithCalibrationDataEntity:self.device.calibrationData];
    }
}

- (void)initializeGoals
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    JDACoreData *coreData           = [JDACoreData sharedManager];
    GoalsEntity *goal               = [SFAGoalsData goalsFromNearestDate:[NSDate date]
                                                              macAddress:self.device.macAddress
                                                           managedObject:coreData.context];
    
    [userDefaults setObject:goal.steps forKey:STEP_GOAL];
    [userDefaults setObject:goal.distance forKey:DISTANCE_GOAL];
    [userDefaults setObject:goal.calories forKey:CALORIE_GOAL];
    [userDefaults setObject:goal.sleep forKey:SLEEP_GOAL];
}

- (void)initializeAlertSettings
{
    [DayLightAlertEntity dayLightAlertEntityForDeviceEntity:self.device];
    [NightLightAlertEntity nightLightAlertEntityForDeviceEntity:self.device];
    [InactiveAlertEntity inactiveAlertEntityForDeviceEntity:self.device];
    [WakeupEntity wakeupEntityForDeviceEntity:self.device];
    
    if ([[DayLightAlert alloc] respondsToSelector:@selector(initWithEntity:)]) {
        [SFAUserDefaultsManager sharedManager].dayLightAlert = [[DayLightAlert alloc] initWithEntity:self.device.dayLightAlert];
    }
    else{
        [SFAUserDefaultsManager sharedManager].dayLightAlert = [DayLightAlert dayLightAlertWithDefaultValues];
    }
    
    if ([[NightLightAlert alloc] respondsToSelector:@selector(initWithEntity:)]) {
        [SFAUserDefaultsManager sharedManager].nightLightAlert = [[NightLightAlert alloc] initWithEntity:self.device.nightLightAlert];
    }
    else{
        [SFAUserDefaultsManager sharedManager].nightLightAlert = [NightLightAlert nightLightAlertWithDefaultValues];
    }
    
    if ([[InactiveAlert alloc] respondsToSelector:@selector(initWithEntity:)]) {
        [SFAUserDefaultsManager sharedManager].inactiveAlert = [[InactiveAlert alloc] initWithEntity:self.device.inactiveAlert];
    }
    else{
        [SFAUserDefaultsManager sharedManager].inactiveAlert = [InactiveAlert inactiveAlertWithDefaultValues];
    }
    
    if ([[Wakeup alloc] respondsToSelector:@selector(initWithEntity:)]) {
        [SFAUserDefaultsManager sharedManager].wakeUp = [[Wakeup alloc] initWithEntity:self.device.wakeup];
    }
    else{
        [SFAUserDefaultsManager sharedManager].wakeUp = [Wakeup wakeupDefaultValues];
    }
    
}



@end
