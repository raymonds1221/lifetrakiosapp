//
//  SFAAppDelegate.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/11/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "Flurry.h"
#import "ATConnect.h"
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

#import "SFASalutronFitnessAppDelegate.h"
#import "ErrorCodeToStringConverter.h"
#import "SFASalutronCModelSync.h"
#import "DeviceEntity+Data.h"
#import "DateEntity.h"
#import "TimeEntity.h"
#import "JDACoreData.h"
#import "SalutronUserProfile+SalutronUserProfileCategory.h"
#import "SleepSetting+SleepSettingCategory.h"
#import "CalibrationData+CalibrationDataCategory.h"
#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "StatisticalDataPointEntity+StatisticalDataPointEntityCategory.h"
#import "SleepDatabase.h"
#import "SleepDatabaseEntity+SleepDatabaseEntityCategory.h"
#import "WorkoutInfo.h"
#import "WorkoutInfoEntity+Data.h"

#import "SFASalutronSync.h"
#import "SFAServerAccountManager.h"

#import "SFASlidingViewController.h"
#import "SFADashboardScrollViewController.h"
#import "SFAMainViewController.h"
#import "SFAWelcomeViewNavigationController.h"

#define DISCOVERY_TIMEOUT 3
#define SELECTOR_DELAY 0.75

#define IS_IOS7_OR_NEWER (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)

@interface SFASalutronFitnessAppDelegate()

@property (assign, nonatomic) BOOL shouldClearDevicesAndCoreData;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (strong, nonatomic) SFASalutronSync *backgroundModeSync;
@property (strong, nonatomic) SFAUserDefaultsManager *userDefaultsManager;
@property (assign, nonatomic) BOOL shouldAutoRotateViewController;
@property (assign, nonatomic) BOOL isSyncingOngoing;

@end

@implementation SFASalutronFitnessAppDelegate

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

dispatch_source_t timer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.shouldClearDevicesAndCoreData = YES;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"justLaunched"];
    // Override point for customization after application launch.

    /* Initialize logging system */
    [SFALoggingFramework sharedInstance];

    /* Flurry */
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:FLURRY_API_KEY];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
    
    /*
#if HIDE_SDK_LOGS == 1
    / * Logs * /
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = @"LifeTrak.txt";
    NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];

    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
#endif
    */
    
    [JDACoreData managerWithContext:self.managedObjectContext];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNavigationBarAppearance];
    [self setTextFieldAppearance];
    
    UIColor *navbarColor = [UIColor colorWithRed:31.0/255.0 green:178.0/255.0 blue:103.0/255.0 alpha:1.0];
    // Fix for frame issue in iOS7.
    if (IS_IOS7_OR_NEWER) {
        [UINavigationBar appearance].barTintColor = navbarColor;
    } else {
        // Emulate defaults in iOS 7
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [UINavigationBar appearance].backgroundColor = navbarColor;
    }
    
    /* User Defaults */
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{@"UserAgent" : WEB_VIEW_USER_AGENT}];
    
    /* Apptentive */
    [ATConnect sharedConnection].apiKey = APPTENTIVE_API_KEY;
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    self.shouldAutoRotateViewController = YES;
    
    self.isSyncingOngoing = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSyncToOngoing) name:SYNCING_ON_GOING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unsetSyncToOngoing) name:SYNCING_FINISHED object:nil];
    
    [self deleteDevicesWithNoUser];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldAutoRotateViewController:) name:AutoRotateNotificationName object:nil];
    
    // Handle launching from a notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        [[NSUserDefaults standardUserDefaults] setObject:@"Undone" forKey:@"AutoSync"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:@"Done" forKey:@"AutoSync"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    /* Crashlytics */
    //[Crashlytics startWithAPIKey:CRASHLYTICS_API_KEY];
    [Fabric with:@[CrashlyticsKit]];
    
    /* AWS setup */
    //Cognito is in US East 1
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:@"us-east-1:83239ddc-6033-4a53-9e26-56f06bb46325"];
    //Bucket is in US West 2
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
    
    [AWSS3TransferManager registerS3TransferManagerWithConfiguration:configuration forKey:@"USWest2S3TransferManager"];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    return YES;
}


//July 15, 2015
//Check for possible devices on core data that has no user and delete them. Previous sign up flow needs to store devices with no associated user but new signup flow don't need it anymore.
- (void)deleteDevicesWithNoUser{
    NSArray *devicesWithNoUser = [DeviceEntity deviceEntitiesWithNoUser];
    DDLogInfo(@"[DeviceEntity deviceEntitiesWithNoUser] count] = %i", [devicesWithNoUser count]);
    
    //Delete devices with no associated user
    if ([devicesWithNoUser count] > 0) {
        for (DeviceEntity *device in devicesWithNoUser) {
            [self deleteDeviceWithMacAddress:device.macAddress];
        }
    }
}

- (void)deleteDeviceWithMacAddress:(NSString *)macAddress
{
    DDLogInfo(@"");
    
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress];
    
    if (deviceEntity.modelNumber.integerValue == WatchModel_R450) {
        [[JDACoreData sharedManager].context deleteObject:deviceEntity];
        [[JDACoreData sharedManager].context save:nil];
        deviceEntity = nil;
    }
    
    if (deviceEntity) {
        [self.managedObjectContext deleteObject:deviceEntity];
        [self.managedObjectContext save:nil];
        deviceEntity = nil;
    }
}


- (void)setSyncToOngoing{
    self.isSyncingOngoing = YES;
}

- (void)unsetSyncToOngoing{
    self.isSyncingOngoing = NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //breakpoint here
    
    self.shouldClearDevicesAndCoreData = !self.shouldClearDevicesAndCoreData;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([SFAUserDefaultsManager sharedManager].watchModel == WatchModel_R450) {
        if (self.isSyncingOngoing == NO) {
            [self goToDashboardSyncWithNotification:notification];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@"Undone" forKey:@"AutoSync"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSUserDefaults standardUserDefaults] setObject:@"Done" forKey:@"AutoSync"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
    
    self.shouldClearDevicesAndCoreData = !self.shouldClearDevicesAndCoreData;
    
    if (self.shouldClearDevicesAndCoreData) {
        [self clearDevices];
    }
}
//
//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    
//    if ([[SFASalutronFitnessAppDelegate topMostController] isKindOfClass:[SFASlidingViewController class]]) {
//
//        SFASlidingViewController *slidingVC = (SFASlidingViewController *)[SFASalutronFitnessAppDelegate topMostController];
//        
//        if (self.shouldAutoRotateViewController) {
//            slidingVC.shouldRotate = YES;
//            return UIInterfaceOrientationMaskAllButUpsideDown;
//        }
//        else {
//            slidingVC.shouldRotate = NO;
//            return UIInterfaceOrientationMaskPortrait;
//        }
//    }
//    // Unlock landscape view orientations for this view controller
//    return UIInterfaceOrientationMaskAllButUpsideDown;
//}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //Fix for issue #773, don't clear core data. if syncing issue occurs, clear core data and solve login issue
    SalutronSDK *salutronSDK = [SalutronSDK sharedInstance];
    [salutronSDK clearDiscoveredDevice];
    
    //Fix for issue #839, delete device entity when terminated during sign up
    NSString *signUpDeviceMacAddress = self.userDefaultsManager.signUpDeviceMacAddress;
    
    if (signUpDeviceMacAddress){
        DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:signUpDeviceMacAddress];
        UserEntity *user = deviceEntity.user;
        if (deviceEntity && user == nil){
            [self.managedObjectContext deleteObject:[DeviceEntity deviceEntityForMacAddress:signUpDeviceMacAddress]];
            [self.managedObjectContext save:nil];
        }
    }
    [SFAHealthKitManager sharedManager].isHealthKitSyncOngoing = NO;
    [[NSUserDefaults standardUserDefaults] setObject:@"Done" forKey:@"AutoSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)shouldAutoRotateViewController:(NSNotification *)notification
{
    NSNumber *enable = (NSNumber *)notification.object;
    self.shouldAutoRotateViewController = [enable boolValue];
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL handleURL = YES;
#if WALGREENS
    //walgreens url
    if ([url.absoluteString rangeOfString:@"walgreensios://"].location != NSNotFound){
        //based on return value from backend
        if ([[url query] hasSuffix:WALGREENS_CONNECT_SUCCESS]){
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WALGREENS_CONNECT_SUCCESS object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WALGREENS_CONNECT_FAILED object:nil];
        }
    }else{
#endif
        //facebook (default)
        handleURL = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
#if WALGREENS
    }
#endif
    return handleURL;
}

#pragma mark - Background sync

/*
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    DDLogInfo(@"");
    
    if ([self shouldPerformBackgroundSync]) {
        
        if (![self isMultitaskingSupported]) {
            return;
        }
        
        self.backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
            // Clean up any unfinished task business by marking where you
            // stopped or ending the task outright.
            [application endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }];
        
        [self performBackgroundSyncing:application];
    }
}

- (void)performBackgroundSyncing:(UIApplication *)application
{
    DDLogInfo(@"");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Do the work associated with the task, preferably in chunks.
        self.backgroundModeSync.selectedWatchModel = WatchModel_R450;
        self.backgroundModeSync.watchModel = WatchModel_R450;
        [self.backgroundModeSync startBackgroundSyncWithErrorHandler:^(Status status) {
            self.backgroundTask = UIBackgroundTaskInvalid;
            
        }];
        [application endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    });
    
}

- (BOOL)isMultitaskingSupported
{
    DDLogInfo(@"");
    
    UIDevice *device = [UIDevice currentDevice];
    
    BOOL backgroundSupported = NO;
    
    if ([device respondsToSelector:@selector(isMultitaskingSupported)])
        backgroundSupported = device.multitaskingSupported;
    
    if (!backgroundSupported) {
        return NO;
    }
    return YES;
}

- (BOOL)shouldPerformBackgroundSync
{
    DDLogInfo(@"");
    
    if (self.userDefaultsManager.autoSyncToWatchEnabled && self.userDefaultsManager.watchModel == WatchModel_R450)
        return YES;
    
    return NO;
}

 */

#pragma mark - Private Methods

- (void)setNavigationBarAppearance
{
    id navigationBarAppearance  = [UINavigationBar appearance];
    NSDictionary *dictionary    = @{NSFontAttributeName             : [UIFont fontWithName:@"DroidSans-Bold" size:16.0f],
                                    NSForegroundColorAttributeName  : [UIColor whiteColor]};
    [navigationBarAppearance setTitleTextAttributes:dictionary];
}

- (void)setTextFieldAppearance
{
    [[UITextField appearance] setTintColor:[UIColor blackColor]];
}

#pragma mark - Other methods

- (void)clearDevices
{
    SalutronSDK *salutronSDK = [SalutronSDK sharedInstance];
    [salutronSDK clearDiscoveredDevice];
    [self resetCoreData];
}


+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

#pragma mark - Lazy loading of properties

- (SalutronSDK *) salutronSDK
{
    if(!_salutronSDK)
        _salutronSDK = [SalutronSDK sharedInstance];
    return _salutronSDK;
}

- (SFASalutronSync *)backgroundModeSync
{
    if (!_backgroundModeSync) {
        _backgroundModeSync = [[SFASalutronSync alloc] init];
    }
    return _backgroundModeSync;
}

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

#pragma mark - Core data

- (void)resetCoreData
{
    // Taken from: http://stackoverflow.com/questions/2375888/how-do-i-delete-all-objects-from-my-persistent-store-in-core-data/8467628#8467628
    
    NSError * error;
    // retrieve the store URL
    NSURL * storeURL = [[self.managedObjectContext persistentStoreCoordinator] URLForPersistentStore:[[[self.managedObjectContext persistentStoreCoordinator] persistentStores] lastObject]];
    // lock the current context
    [self.managedObjectContext lock];
    [self.managedObjectContext reset];//to drop pending changes
    //delete the store from the current managedObjectContext
    if ([[self.managedObjectContext persistentStoreCoordinator] removePersistentStore:[[[self.managedObjectContext persistentStoreCoordinator] persistentStores] lastObject] error:&error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        //recreate the store like in the  appDelegate method
        [[self.managedObjectContext persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
    }
    [self.managedObjectContext unlock];
}

- (NSManagedObjectModel *) managedObjectModel
{
    /*_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
     return _managedObjectModel;*/
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSString *path      = [[NSBundle mainBundle] pathForResource:@"salutronfitnessapp" ofType:@"momd"];
    NSURL *momURL       = [NSURL fileURLWithPath:path];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
    return _managedObjectModel;
}

- (NSManagedObjectContext *) managedObjectContext
{
    if(_managedObjectContext != nil)
        return _managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if(coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = coordinator;
    }
    
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
    if(_persistentStoreCoordinator != nil)
        return _persistentStoreCoordinator;
    
    NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentDirectory] stringByAppendingString:DATABASE_NAME]];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@YES, NSMigratePersistentStoresAutomaticallyOption,
                             @YES, NSInferMappingModelAutomaticallyOption, nil];
    
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        DDLogError(@"error: %@", [error localizedDescription]);
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *) applicationDocumentDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - Local notification

//- (void)showSyncNotificationForSyncDate:(NSDate *)date
//{
//    UILocalNotification *localNotification  = [UILocalNotification new];
//    localNotification.alertBody             = @"LifeTrak will sync now.";
//    localNotification.fireDate              = [date dateByAddingTimeInterval:-60];
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//}

- (void)goToDashboardSyncWithNotification:(UILocalNotification *)notification
{
    DDLogInfo(@"");
    UIViewController *vc = [SFASalutronFitnessAppDelegate topMostController];//self.window.rootViewController;
    
    NSString *macAddress            = [notification.userInfo objectForKey:MAC_ADDRESS];
    
    if ([macAddress isEqualToString:self.userDefaultsManager.macAddress]) {
        
        id viewController = [SFASalutronFitnessAppDelegate topMostController];
        
        if ([viewController isKindOfClass:[SFASlidingViewController class]]) {
            SFASlidingViewController *sliding = (SFASlidingViewController *)viewController;
            [sliding showDashboard];
            
            [self performSelector:@selector(notifyDashboardToStartSync) withObject:nil afterDelay:0.3f];
        }
        else{
            
        }
    }
    else if([vc isKindOfClass:[SFAWelcomeViewNavigationController class]]){
        [self performSelector:@selector(notifyDashboardToStartSync) withObject:nil afterDelay:0.3f];
    }
}

- (void)notifyDashboardToStartSync
{
    [[NSNotificationCenter defaultCenter] postNotificationName:autoSyncNotificationName object:self];
    [[NSUserDefaults standardUserDefaults] setObject:@"Undone" forKey:@"AutoSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
