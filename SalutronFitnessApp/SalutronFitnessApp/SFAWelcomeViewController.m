//
//  SFAWelcomeViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/17/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "JDACoreData.h"

#import "SFAWelcomeWatchCell.h"

#import "SFAGoalsData.h"

#import "SFASalutronFitnessAppDelegate.h"

#import "DeviceEntity+Data.h"
#import "UserProfileEntity+Data.h"
#import "TimeDateEntity+Data.h"
#import "NotificationEntity+Data.h"
#import "SleepSettingEntity+Data.h"
#import "CalibrationDataEntity+Data.h"
#import "DayLightAlertEntity+Data.h"
#import "NightLightAlertEntity+Data.h"
#import "WakeupEntity+Data.h"
#import "InactiveAlertEntity+Data.h"

#import "DayLightAlert+Entity.h"
#import "NightLightAlert+Entity.h"
#import "Wakeup+Entity.h"
#import "InactiveAlert+Entity.h"

#import "DayLightAlert+Data.h"
#import "NightLightAlert+Data.h"
#import "Wakeup+Data.h"
#import "InactiveAlert+Data.h"


#import "SalutronUserProfile+Data.h"
#import "TimeDate+Data.h"
#import "Notification+Data.h"
#import "SleepSetting+Data.h"
#import "CalibrationData+Data.h"

#import "SFAServerSyncManager.h"
#import "SFAServerAccountManager.h"

#import "SFAServerSyncViewController.h"
#import "SFAServerSyncNavigationViewController.h"
#import "SFAWelcomeViewController.h"
#import "SFAIntroViewController.h"
#import "UIViewController+Helper.h"
#import "SFALoadingViewController.h"

#import "AFNetworkReachabilityManager.h"
#import "SFAWatchManager.h"
#import "Flurry.h"

#define WATCH_CELL_STYLE_1              @"SFAWelcomeWatchCell1"
#define WATCH_CELL_STYLE_2              @"SFAWelcomeWatchCell2"
#define SLIDING_SEGUE_IDENTIFIER        @"WelcomeToSliding"
#define SERVER_SYNC_SEGUE_IDENTIFIER    @"WelcomeToServerSync"
#define WELCOME_TO_INTRO_SEGUE_IDENTIFIER   @"WelcomeToIntro"
#define WELCOME_TO_SERVER_UP_SEGUE_IDENTIFIER @"WelcomeToServerUpSegueIdentifier"
#define WELCOME_VIEW_UNWIND             @"WelcomeViewControllerUnwind"

@interface SFAWelcomeViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (weak, nonatomic) IBOutlet UILabel        *connectToWatchLabel;
@property (weak, nonatomic) IBOutlet UIImageView    *logoImageView;


//BROWNBAG ITEM - Monitoring changes in a property
@property (strong, nonatomic) NSArray               *watches;
@property (strong, nonatomic) NSIndexPath           *indexPath;
@property (strong, nonatomic) DeviceEntity          *device;

@property (strong, nonatomic) UIAlertView           *deleteAlertView;
@property (strong, nonatomic) UIAlertView           *logoutAlertView;

@end

@implementation SFAWelcomeViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [self initializeObjects];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToDashboard) name:autoSyncNotificationName object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:autoSyncNotificationName object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [Flurry logEvent:DEVICE_LISTING_PAGE];
    [super viewDidAppear:animated];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AutoSync"] isEqualToString:@"Undone"]) {
        [self notifyDashboardToStartSync];
    }
    //[[NSUserDefaults standardUserDefaults] setObject:@"Done" forKey:@"AutoSync"];
}

- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    SFAIntroViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAIntroViewController"];
    return [viewController viewControllerForUnwindSegueAction:action fromViewController:self withSender:sender];
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

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SERVER_SYNC_SEGUE_IDENTIFIER]) {
        SFAServerSyncNavigationViewController *navigation = (SFAServerSyncNavigationViewController *)segue.destinationViewController;
        SFAServerSyncViewController *viewController = (SFAServerSyncViewController *)navigation.viewControllers[0];
        viewController.deviceEntity = self.device;
    }
}

- (IBAction)welcomeViewUnwindSegue:(UIStoryboardSegue *)segue
{
    SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
    [manager logOut];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:PROMPT_CHANGE_SETTINGS];
    [userDefaults synchronize];
    DDLogInfo(@"PROMPT_CHANGE_SETTINGS : %d", [userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]);
}

- (IBAction)welcomeViewUnwindSegueWithoutLogout:(UIStoryboardSegue *)segue
{
    [self initializeObjects];
    [self.tableView reloadData];
}

- (IBAction)connectWatchButtonClicked:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Signup_Main" bundle:nil];
    SFAIntroViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"SFAFiveEasyStepsViewController"];
    [self.navigationController pushViewController:ivc animated:YES];//presentViewController:ivc animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.watches.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *cellIdentifier = indexPath.row % 2 == 0 ? WATCH_CELL_STYLE_1 : WATCH_CELL_STYLE_2;
        SFAWelcomeWatchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        [cell setContentsWithDevice:self.watches[indexPath.row]];
        return cell;
    }
    
    return [UITableViewCell new];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.indexPath              = indexPath;
    DeviceEntity *deviceEntity  = self.watches[self.indexPath.row];
    
    if ([self connected] == NO) {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS_NO_INTERNET
                                                                                     message:LS_DELETE_WATCH_WARNING
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LS_NO_INTERNET
                                                        message:LS_DELETE_WATCH_WARNING
                                                       delegate:nil
                                              cancelButtonTitle:BUTTON_TITLE_OK
                                              otherButtonTitles:nil, nil];
        [alert show];
        }
        
    }
    else{
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:WELCOME_DELETE_TITLE
                                                                                     message:WELCOME_DELETE_MESSAGE(deviceEntity.name)
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *noAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_NO
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
            UIAlertAction *yesAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_YES
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self deleteSelectedRow];
                                           self.deleteAlertView = nil;
                                       }];
            [alertController addAction:noAction];
            [alertController addAction:yesAction];
            
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{

        self.deleteAlertView      = [[UIAlertView alloc] initWithTitle:WELCOME_DELETE_TITLE
                                                             message:WELCOME_DELETE_MESSAGE(deviceEntity.name)
                                                            delegate:self
                                                   cancelButtonTitle:BUTTON_TITLE_NO
                                                   otherButtonTitles:BUTTON_TITLE_YES, nil];
        [self.deleteAlertView show];
        }
    }
    
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        self.device = self.watches[indexPath.row];
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
            [self performSegueWithIdentifier:WELCOME_TO_SERVER_UP_SEGUE_IDENTIFIER sender:self];
        }
        else {
            if (self.device.header.count > 0) {
                [self initializeGoals];
                [self initializeDeviceSettings];
                [self performSegueWithIdentifier:SLIDING_SEGUE_IDENTIFIER sender:self];
            }
            else {
                [self performSegueWithIdentifier:SERVER_SYNC_SEGUE_IDENTIFIER sender:self];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@"Done" forKey:@"AutoSync"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Check for internet
- (BOOL)connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView == self.deleteAlertView) {
        //check for internet
            [self deleteSelectedRow];
            self.deleteAlertView = nil;
    }
    else if (buttonIndex == 1 && alertView == self.logoutAlertView) {
//        SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
//        [manager logOut];
//        self.logoutAlertView = nil;
        
        /*
        SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
        [manager logOut];
        SFAIntroViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAIntroViewController"];
        [self presentViewController:viewController animated:YES completion:nil];
        [self dismissViewControllerAnimated:YES completion:^{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:NO forKey:PROMPT_CHANGE_SETTINGS];
            [userDefaults synchronize];
            DDLogInfo(@"PROMPT_CHANGE_SETTINGS : %d", [userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]);
        }];*/
        /*
        @try{
            [self performSegueWithIdentifier:WELCOME_VIEW_UNWIND sender:self];
        }
        @catch(NSException *exception){
            DDLogInfo(@"Exception: %@", exception);
            
            SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
            [manager logOut];
           
            //[self.navigationController popToRootViewControllerAnimated:YES];
            SFAIntroViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAIntroViewController"];
            [self.navigationController presentViewController:viewController animated:YES completion:^{
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:NO forKey:PROMPT_CHANGE_SETTINGS];
                [userDefaults synchronize];
                DDLogInfo(@"PROMPT_CHANGE_SETTINGS : %d", [userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]);
            }];
            
            return;
        }
        SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
        [manager logOut];
        [self dismissViewControllerAnimated:YES completion:^{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:NO forKey:PROMPT_CHANGE_SETTINGS];
            [userDefaults synchronize];
            DDLogInfo(@"PROMPT_CHANGE_SETTINGS : %d", [userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]);
        }];
        */
        [self logout];
    }
}

#pragma mark - Private Methods

- (void)initializeObjects
{
    // Update image logo for localization
    NSString *filePathName = @"lifetrak_logo";
    if (LANGUAGE_IS_FRENCH) {
        filePathName = @"lifetrak_logo_fr";
    }
    
    self.logoImageView.image = [UIImage imageNamed:filePathName];
    
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

    if (self.watches.count == 0) {
        self.connectToWatchLabel.hidden = YES;
    }
    else{
        self.connectToWatchLabel.hidden = NO;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:DEVICE_UUID];
    [userDefaults setObject:nil forKey:MAC_ADDRESS];
    [userDefaults setObject:@(NO) forKey:HAS_PAIRED];
    [userDefaults synchronize];
}

- (void)goToDashboard{
    NSMutableArray *deviceMacAddresses = [[NSMutableArray alloc] init];
    for (DeviceEntity *device in self.watches) {
        [deviceMacAddresses addObject:device.macAddress];
    }
    int lastMacAddressIndex = [deviceMacAddresses indexOfObject:[[NSUserDefaults standardUserDefaults] objectForKey:LAST_MAC_ADDRESS]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastMacAddressIndex inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]){
        [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        [self performSelector:@selector(notifyDashboardToStartSync) withObject:nil afterDelay:0.3f];
    }
}

- (void)notifyDashboardToStartSync
{
    [[NSNotificationCenter defaultCenter] postNotificationName:autoSyncNotificationName object:self];
}

- (void)deleteSelectedRow
{
    NSIndexPath *indexPath          = self.indexPath;
    self.indexPath                  = nil;
    NSMutableArray *watches         = [self.watches mutableCopy];
    DeviceEntity *deviceEntity      = watches[indexPath.row];
    JDACoreData *coreData           = [JDACoreData sharedManager];
    SFAServerSyncManager *manager   = [SFAServerSyncManager sharedManager];
    NSString *macAddress            = deviceEntity.macAddress.copy;
    
    [coreData.context deleteObject:deviceEntity];
    [coreData.context save:nil];
    [watches removeObject:deviceEntity];
    [manager deleteWithMacAddress:macAddress success:^{
        
        DDLogError(@"Delete device from server success.");
    } failure:^(NSError *error) {
        DDLogError(@"Delete device from server error: %@", error.localizedDescription);
    }];
    
    self.watches = [watches copy];
    
    /*
    if (self.watches.count == 0) {
        NSString *appDomain             = [[NSBundle mainBundle] bundleIdentifier];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        [userDefaults removePersistentDomainForName:appDomain];
    }
    */
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

#pragma mark - IBActions

- (IBAction)logoutButtonPressed:(id)sender
{
    if (self.isIOS8AndAbove) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kSettingsSignOut
                                                                                 message:MESSAGE_SIGN_OUT
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:BUTTON_TITLE_CANCEL
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
        UIAlertAction *okAction = [UIAlertAction
                                    actionWithTitle:BUTTON_TITLE_OK
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        [self logout];
                                    }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
    self.logoutAlertView  = [[UIAlertView alloc] initWithTitle:kSettingsSignOut
                                                         message:MESSAGE_SIGN_OUT
                                                        delegate:self
                                               cancelButtonTitle:BUTTON_TITLE_CANCEL
                                               otherButtonTitles:BUTTON_TITLE_OK, nil];
    
    [self.logoutAlertView show];
    }
}

- (void)logout{
    SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
    [manager logOut];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:PROMPT_CHANGE_SETTINGS];
    [userDefaults synchronize];
    DDLogInfo(@"PROMPT_CHANGE_SETTINGS : %d", [userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]);

    
    SFALoadingViewController *nav = (SFALoadingViewController*) self.view.window.rootViewController;
    //[self.navigationController popToViewController:nav animated:NO];
    [nav returnToRoot];
    //[nav popToRootViewControllerAnimated:NO];
    /*
    SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
    [manager logOut];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:PROMPT_CHANGE_SETTINGS];
    [userDefaults synchronize];
    DDLogInfo(@"PROMPT_CHANGE_SETTINGS : %d", [userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]);
     */
    //SFALoadingViewController *root = [nav.viewControllers objectAtIndex:0];
    //[root performSelector:@selector(returnToRoot)];
    /*
    SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
    SFAIntroViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFALoadingViewController"];
    [manager logOut];
    //[self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController presentViewController:viewController animated:YES completion:nil];
    */
    /*
    @try{
        [self performSegueWithIdentifier:@"WelcomeToLoadingUnwind" sender:self];
    }
    @catch(NSException *exception){
        DDLogInfo(@"Exception: %@", exception);
        
        SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
        [manager logOut];
        
        //[self.navigationController popToRootViewControllerAnimated:YES];
        SFAIntroViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFALoadingViewController"];
        [self.navigationController presentViewController:viewController animated:YES completion:^{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:NO forKey:PROMPT_CHANGE_SETTINGS];
            [userDefaults synchronize];
            DDLogInfo(@"PROMPT_CHANGE_SETTINGS : %d", [userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]);
        }];
        
        return;
    }
    SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
    [manager logOut];
    [self dismissViewControllerAnimated:YES completion:^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:NO forKey:PROMPT_CHANGE_SETTINGS];
        [userDefaults synchronize];
        DDLogInfo(@"PROMPT_CHANGE_SETTINGS : %d", [userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]);
    }];
    */
}

@end
