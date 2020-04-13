//
//  SFASyncPageViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 1/3/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAServerAccountManager.h"

#import "SFASyncPageViewController.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFASalutronCModelSync.h"
#import "ErrorCodeToStringConverter.h"
#import "SFAConnectionViewController.h"
#import "SFASlidingViewController.h"
#import "SFASettingsPromptView.h"

#define YOUR_PROFILE_SEGUE @"YourProfile2Segue"
#define REGISTER_SEGUE_IDENTIFIER @"SyncPageToRegister"
#define SERVER_UPLOAD_SEGUE         @"SyncPageToServerUpload"


@interface SFASyncPageViewController () <SFASalutronSyncDelegate, SFASettingsPromptViewDelegate>

@property (strong, nonatomic) SFASalutronCModelSync *salutronSyncC300;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (assign, nonatomic) BOOL profileUpdated;
@property (assign, nonatomic) SFAConnectionViewController *connectionViewController;
@property (assign, nonatomic, getter = isSyncFinished) BOOL syncFinished;

@end

@implementation SFASyncPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSArray *images = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_connect_2syncing.png"], [UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_connect_0beginsync.png"], nil];
    
    NSArray *images = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"ll_preloader_default.png"], [UIImage imageNamed:@"ll_preloader_radar_01.png"], [UIImage imageNamed:@"ll_preloader_radar_02.png"], [UIImage imageNamed:@"ll_preloader_radar_03.png"], [UIImage imageNamed:@"ll_preloader_radar_04.png"], [UIImage imageNamed:@"ll_preloader_radar_05.png"], [UIImage imageNamed:@"ll_preloader_radar_06.png"], [UIImage imageNamed:@"ll_preloader_radar_07.png"], [UIImage imageNamed:@"ll_preloader_radar_08.png"], [UIImage imageNamed:@"ll_preloader_radar_09.png"], [UIImage imageNamed:@"ll_preloader_radar_10.png"], [UIImage imageNamed:@"ll_preloader_radar_11.png"], [UIImage imageNamed:@"ll_preloader_default.png"], [UIImage imageNamed:@"ll_preloader_radar_01.png"], [UIImage imageNamed:@"ll_preloader_radar_02.png"], [UIImage imageNamed:@"ll_preloader_radar_03.png"], [UIImage imageNamed:@"ll_preloader_radar_04.png"], [UIImage imageNamed:@"ll_preloader_radar_05.png"], [UIImage imageNamed:@"ll_preloader_radar_06.png"], [UIImage imageNamed:@"ll_preloader_radar_07.png"], [UIImage imageNamed:@"ll_preloader_radar_08.png"], [UIImage imageNamed:@"ll_preloader_radar_09.png"], [UIImage imageNamed:@"ll_preloader_radar_10.png"], [UIImage imageNamed:@"ll_preloader_radar_11.png"], [UIImage imageNamed:@"ll_preloader_default.png"], [UIImage imageNamed:@"ll_preloader_arrow_01.png"], [UIImage imageNamed:@"ll_preloader_arrow_02.png"], [UIImage imageNamed:@"ll_preloader_arrow_03.png"], [UIImage imageNamed:@"ll_preloader_arrow_04.png"], [UIImage imageNamed:@"ll_preloader_arrow_05.png"], [UIImage imageNamed:@"ll_preloader_arrow_06.png"], [UIImage imageNamed:@"ll_preloader_arrow_07.png"], [UIImage imageNamed:@"ll_preloader_default.png"], [UIImage imageNamed:@"ll_preloader_arrow_01.png"], [UIImage imageNamed:@"ll_preloader_arrow_02.png"], [UIImage imageNamed:@"ll_preloader_arrow_03.png"], [UIImage imageNamed:@"ll_preloader_arrow_04.png"], [UIImage imageNamed:@"ll_preloader_arrow_05.png"], [UIImage imageNamed:@"ll_preloader_arrow_06.png"], [UIImage imageNamed:@"ll_preloader_arrow_07.png"], [UIImage imageNamed:@"ll_preloader_default.png"], nil];
    
    self.imageSync.animationImages = images;
    self.imageSync.animationDuration = 3.0f;
    [self.imageSync startAnimating];
    
    UINavigationController *navController = (UINavigationController *)[self presentingViewController];
    self.connectionViewController = (SFAConnectionViewController *)navController.viewControllers[0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(checkConnectedDevice) withObject:nil afterDelay:0];
    [self _updateUserProfile];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions

- (IBAction)cancelPressed {
    if ([SFAUserDefaultsManager sharedManager].watchModel == WatchModel_Move_C300 ||
        [SFAUserDefaultsManager sharedManager].watchModel == WatchModel_Move_C300_Android ||
        [SFAUserDefaultsManager sharedManager].watchModel== WatchModel_Zone_C410 ||
        [SFAUserDefaultsManager sharedManager].watchModel== WatchModel_R420) {
        [[SalutronSDK sharedInstance] commDone];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Properties

- (SFASalutronCModelSync *)salutronSyncC300 {
    if(!_salutronSyncC300) {
        _salutronSyncC300 = [[SFASalutronCModelSync alloc] initWithManagedObjectContext:self.managedObjectContext];
        _salutronSyncC300.delegate = self;
    }
    return _salutronSyncC300;
}

- (NSManagedObjectContext *)managedObjectContext {
    if(!_managedObjectContext) {
        SFASalutronFitnessAppDelegate *appDelegate = (SFASalutronFitnessAppDelegate *)[UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (NSUserDefaults *)userDefaults {
    if(!_userDefaults)
        _userDefaults = [NSUserDefaults standardUserDefaults];
    return _userDefaults;
}

#pragma mark - Private Methods

- (void)checkConnectedDevice {
    if(!self.isSyncFinished) {
        self.salutronSyncC300.updateTimeAndDate = self.updateTimeAndDate;
        [self.salutronSyncC300 startSyncWithWatchModel:self.watchModel];
    }
}

- (void)_finishUpdate
{
    if (_profileUpdated)
    {
        //[self _updateLastSync];
        [self performSegueWithIdentifier:YOUR_PROFILE_SEGUE sender:self];
        return;
    }
    else
    {
        NSUndoManager *undoManager = [[NSUndoManager alloc] init];
        self.managedObjectContext.undoManager = undoManager;
        
        [undoManager beginUndoGrouping];
        
        NSError *error = nil;
        
        if([self.managedObjectContext save:&error]) {
            [undoManager endUndoGrouping];
        } else {
            [undoManager undo];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.view viewWithTag:5].layer.opacity = 0.0f;
        } completion:^(BOOL finished) {
            SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
            
            if (manager.isLoggedIn) {
                [self performSegueWithIdentifier:SERVER_UPLOAD_SEGUE sender:self];
            } else {
                [self performSegueWithIdentifier:REGISTER_SEGUE_IDENTIFIER sender:self];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
            /*_syncComplete   = YES;
            [[self.view viewWithTag:5] removeFromSuperview];
            [[self.view viewWithTag:6] removeFromSuperview];
            //[self _updateLastSync];
            [syncView stopAnimating];
            [self performSelector:@selector(showSuccess) withObject:nil afterDelay:1.5];
            [self navigateToMainViewController];
            
            if(_currentWatch == WatchModel_Core_C200 ||
               _currentWatch == WatchModel_Move_C300 ||
               _currentWatch == WatchModel_Zone_C410)
                [_salutronSDK disconnectDevice];*/
        }];
        self.salutronSyncC300.delegate = nil;
        self.salutronSyncC300 = nil;
    }
}

- (Status)_updateUserProfile
{
    
    if (_profileUpdated)
    {
        NSData *_userData                   = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PROFILE];
        SalutronUserProfile *_userProfile   = [NSKeyedUnarchiver unarchiveObjectWithData:_userData];
        SalutronSDK *salutronSDK            = [SalutronSDK sharedInstance];
        NSInteger watchModel                = [_userDefaults integerForKey:CONNECTED_WATCH_MODEL];
        
        if(watchModel == WatchModel_Move_C300 ||
           watchModel == WatchModel_Move_C300_Android ||
           watchModel == WatchModel_Zone_C410 ||
           watchModel == WatchModel_R420)
            [salutronSDK commDone];
        
        Status _updateUserStatus            = [[SalutronSDK sharedInstance] updateUserProfile:_userProfile];
        
        /*if (_updateUserStatus == NO_ERROR)
        {
            _profileUpdated = NO;
            [self _finishUpdate];
        }*/
        _profileUpdated = NO;
        [self _finishUpdate];
        
        return _updateUserStatus;
    }
    return ERROR_UPDATE;
}

#pragma mark - SFASalutronSyncDelegate

- (void)didDeviceConnected {
    
}

- (void)didSyncStarted {
    
}

- (void)didDiscoverTimeout {
    
}

- (void)didDiscoverTimeoutWithDiscoveredDevices:(NSArray *)discoveredDevices {
    
}

- (void)didDeviceDisconnected:(BOOL)isSyncFinished {
    [self.salutronSyncC300 deleteDevice];
    [self.connectionViewController showTryAgainFailView];
    [SFASettingsPromptView hide];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSyncFinished:(DeviceEntity *)deviceEntity profileUpdated:(BOOL)profileUpdated {
    [self.userDefaults setBool:YES forKey:HAS_PAIRED];
    [self.userDefaults setObject:deviceEntity.uuid forKey:DEVICE_UUID];
    [self.userDefaults setObject:deviceEntity.macAddress forKey:MAC_ADDRESS];
    
    NSDate *lastSyncDate = [NSDate date];
    NSData *dataLastSyncDate = [NSKeyedArchiver archivedDataWithRootObject:lastSyncDate];
    
    [self.userDefaults setObject:dataLastSyncDate forKey:LAST_SYNC_DATE];
    [self.userDefaults synchronize];
    _profileUpdated = profileUpdated;
    self.syncFinished = YES;
    
    //[self _finishUpdate];
    
    if (!self.salutronSyncC300.updatedSettings) {
        [self _finishUpdate];
    }
}

- (void)didRetrieveDevice:(NSInteger)numDevice {
    if(numDevice == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didSyncOnDataHeaders
{
    self.labelStatus.text = SYNC_MESSAGE(NSLocalizedString(@"Syncing data headers", nil));
}

- (void)didSyncOnLightDataPoints
{
    self.labelStatus.text = SYNC_MESSAGE(NSLocalizedString(@"Syncing light data points", nil));
}

- (void)didSyncOnDataPoints:(NSInteger)percent {
    NSString *status = [NSString stringWithFormat:NSLocalizedString(@"FITNESS RESULTS - %i%%", nil), percent];
    self.labelStatus.text = SYNC_MESSAGE(status);
}

- (void)didChecksumError {
    [self.connectionViewController showChecksumFailView];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.salutronSyncC300 disconnectWatch];
}

- (void)didRaiseError {
    [self.connectionViewController showTryAgainFailView];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.salutronSyncC300 disconnectWatch];
}

- (void)didSyncOnStepGoal {
    self.labelStatus.text = SYNC_MESSAGE(NSLocalizedString(@"Syncing step goal", nil));
}

- (void)didSyncOnDistanceGoal{
    self.labelStatus.text = SYNC_MESSAGE(NSLocalizedString(@"Syncing distance goal", nil));
}
- (void)didSyncOnCalorieGoal {
    self.labelStatus.text = SYNC_MESSAGE(NSLocalizedString(@"Syncing calorie goal", nil));
}

- (void)didSyncOnNotification {
    self.labelStatus.text = SYNC_MESSAGE(NSLocalizedString(@"Syncing notifications", nil));
}

- (void)didSyncOnSleepSettings {
    self.labelStatus.text = SYNC_MESSAGE(NSLocalizedString(@"Syncing sleep settings", nil));
}

- (void)didSyncOnCalibrationData {
    self.labelStatus.text = SYNC_MESSAGE(NSLocalizedString(@"Syncing calibration data", nil));
}

- (void)didSyncOnWorkoutDatabase {
    self.labelStatus.text = SYNC_MESSAGE(NSLocalizedString(@"Syncing workout database", nil));
}

- (void)didSyncOnSleepDatabase {
    self.labelStatus.text = SYNC_MESSAGE(NSLocalizedString(@"Syncing sleep database", nil));
}

- (void)didSyncOnUserProfile {
    self.labelStatus.text = SYNC_MESSAGE(NSLocalizedString(@"Syncing user profile", nil));
}

- (void)didChangeSettings
{
//    [SFASettingsPromptView settingsPromptView].delegate = self;
//    [SFASettingsPromptView show];
    [self.salutronSyncC300 useWatchSettings];
}

- (void)didSaveSettings
{
    [self _finishUpdate];
}

#pragma mark - SFASettingsPromptViewDelegate Methods

- (void)didPressAppButtonOnSettingsPromptView:(SFASettingsPromptView *)view
{/*
    if (![SFAUserDefaultsManager sharedManager].promptChangeSettings) {
        [SFAUserDefaultsManager sharedManager].syncOption = SyncOptionApp;
    }
    */
    [self.salutronSyncC300 useAppSettings];
}

- (void)didPressWatchButtonOnSettingsPromptView:(SFASettingsPromptView *)view
{/*
    if (![SFAUserDefaultsManager sharedManager].promptChangeSettings) {
        [SFAUserDefaultsManager sharedManager].syncOption = SyncOptionWatch;
    }
    */
    [self.salutronSyncC300 useWatchSettings];
}

@end
