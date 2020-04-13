//
//  SFALoadingViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/17/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFALoadingViewController.h"

#import "DeviceEntity+Data.h"
#import "SFAServerAccountManager.h"
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
#import "SFAIntroViewController.h"
#import "SDImageCache.h"

#define INTRO_SEGUE_IDENTIFIER      @"LoadingToIntro"
#define WELCOME_SEGUE_IDENTIFIER    @"LoadingToWelcome"
#define SLIDING_SEGUE_IDENTIFIER        @"LoadingToSliding"
#define SERVER_SYNC_SEGUE_IDENTIFIER    @"LoadingToServerSync"
#define WELCOME_TO_SERVER_UP_SEGUE_IDENTIFIER @"LoadingToServerUpSegueIdentifier"

@interface SFALoadingViewController ()

@property (strong, nonatomic) NSArray               *watches;
@property (strong, nonatomic) DeviceEntity          *device;

@end

@implementation SFALoadingViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.isSwitchWatch) {
        [self showInitialViewController];
    }
    else{
        SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
        [[SDImageCache sharedImageCache] removeImageForKey:manager.user.imageURL fromDisk:YES];
        [self initializeObjects];
    }
    //[self showInitialViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)showInitialViewController
{
    self.isSwitchWatch = NO;
    SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
    
    if (manager.isLoggedIn) {
        [[SDImageCache sharedImageCache] removeImageForKey:manager.user.imageURL fromDisk:YES];
        [self performSegueWithIdentifier:WELCOME_SEGUE_IDENTIFIER sender:self];
    } else {
        //[self performSegueWithIdentifier:INTRO_SEGUE_IDENTIFIER sender:self];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Signup_Main" bundle:nil];
        SFAIntroViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"SFAIntroViewController"];
        [self presentViewController:ivc animated:YES completion:nil];
    }
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
    /*
    [[NSUserDefaults standardUserDefaults] setObject:@"Done" forKey:@"AutoSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
     */
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
    
    if (self.watches.count == 1 && manager.isLoggedIn) {
        [self goToDashboard];
    }
    else{
        [self showInitialViewController];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SERVER_SYNC_SEGUE_IDENTIFIER]) {
        SFAServerSyncNavigationViewController *navigation = (SFAServerSyncNavigationViewController *)segue.destinationViewController;
        SFAServerSyncViewController *viewController = (SFAServerSyncViewController *)navigation.viewControllers[0];
        viewController.deviceEntity = self.device;
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

-(IBAction)reset:(UIStoryboardSegue *)segue {
    //do stuff
    SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
    [manager logOut];
}

- (void)returnToRoot {
    //SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
    //[manager logOut];
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

@end
