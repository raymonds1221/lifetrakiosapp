//
//  SFAViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/11/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAConnectionViewController.h"
#import "UIViewController+Helper.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFAWatchModelCell.h"

#import "SFAYourProfileViewController.h"
#import "SFASyncPageViewController.h"
#import "SFAPairViewController.h"

#import "SFASalutronLibrary.h"
#import "SFASalutronSyncC300.h"
#import "SFASalutronSyncCModel.h"
#import "SFASalutronSync.h"

#import "SFASettingsPromptView.h"
#import "SFAServerAccountManager.h"
#import "SalutronUserProfile+Data.h"


#import "SFAConnectionViewController+View.h"
#import "TimeDate+Data.h"
#import "SFASyncProgressView.h"
#import "Flurry.h"

@interface SFAConnectionViewController () <UIAlertViewDelegate, SFAWatchModelCellDelegate, SFASalutronSyncDelegate, SFAPairViewControllerDelegate, SFAYourProfileViewControllerDelegate, CBCentralManagerDelegate, SFASettingsPromptViewDelegate>

@property (assign, nonatomic) BOOL profileUpdated;
@property (assign, nonatomic) BOOL syncComplete;
@property (assign, nonatomic) BOOL pairPressed;
@property (assign, nonatomic) BOOL pairDone;
@property (assign, nonatomic) BOOL timeAndDateAsked;
@property (assign, nonatomic) BOOL updateTimeAndDate;
@property (assign, nonatomic) BOOL foundDevice;
@property (assign, nonatomic) BOOL bluetoothOn;
@property (assign, nonatomic, getter = isFromRetrieveDevice) BOOL fromRetrieveDevice;

@property (strong, nonatomic) SFASalutronLibrary        *salutronLibrary;
@property (strong, nonatomic) SFASalutronSyncC300           *salutronSyncC300;
@property (strong, nonatomic) SFASalutronSyncCModel     *salutronSyncC300CModel;
@property (strong, nonatomic) SFASalutronSync          *salutronSync;

@property (weak, nonatomic)   SFAPairViewController     *pairViewController;
@property (assign, nonatomic) WatchModel                currentWatchModel;

@property (strong, nonatomic) NSMutableArray    *statisticalDataHeaderEntities;
@property (strong, nonatomic) DeviceEntity      *deviceEntity;
@property (strong, nonatomic) CBCentralManager  *centralManager;
@property (assign, nonatomic) NSUInteger        deviceIndex;
@property (assign, nonatomic) int               index;
@property (assign, nonatomic) BOOL              hideErrorView;
@property (assign, nonatomic) BOOL              watchDisconnected;
@property (assign, nonatomic) BOOL              isPaired;

@property (strong, nonatomic) SFAUserDefaultsManager            *userDefaultsManager;

@end

@implementation SFAConnectionViewController

@synthesize index;

static NSString * const pairSegueIdentifier         = @"ConnectionToPair";
static NSString * const profileSegueIdentifier      = @"YourProfileSegueIdentifier";
static NSString * const registerSegueIdentifier     = @"ConnectionToRegister";
static NSString * const serverSegueIdentifier       = @"ConnectionToServerUpload";
static NSString * const syncPageSegueIdentifier     = @"SyncPageViewController";
static const unsigned int discoverTimeoutInSeconds  = 15;
//static const double delay                           = 0;

#pragma mark - Lazy loading of properties

- (SFASyncConnectionView *)syncView
{
    if (!_syncView) {
        
        SFASalutronFitnessAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        
        _syncView = [[SFASyncConnectionView alloc] initWithFrame:CGRectMake(0, 0, appDelegate.window.bounds.size.width, appDelegate.window.bounds.size.height)];
        _syncView.accessibilityValue = @"syncView";
        _syncView.tag = 1001;
        _syncView.delegate = self;
        [self.view addSubview:_syncView];
    }

    return _syncView;
}

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

- (SFASalutronSyncC300 *)salutronSyncC300
{
    
    if (!_salutronSyncC300) {
        _salutronSyncC300 = [[SFASalutronSyncC300 alloc] initWithManagedObjectContext:self.managedObjectContext];
        //_salutronSyncC300.delegate = self;
    }
    return _salutronSyncC300;
}

- (SFASalutronLibrary *) salutronLibrary
{
    if (!_salutronLibrary)
        _salutronLibrary = [[SFASalutronLibrary alloc] initWithManagedObjectContext:self.managedObjectContext];
    return _salutronLibrary;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    DDLogInfo(@"");
    [super viewDidLoad];
    
    self.profileUpdated = NO;
    
    SFASalutronFitnessAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    self.salutronSDK = [SalutronSDK sharedInstance];
    self.salutronSyncC300CModel = [SFASalutronSyncCModel salutronSyncC300];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.salutronSync.deviceEntity = nil;
    
    Status s = [self.salutronSDK clearDiscoveredDevice];
    DDLogError(@"status: %@", [ErrorCodeToStringConverter convertToString:s]);
    
    self.statisticalDataHeaderEntities = [[NSMutableArray alloc] init];
    
    self.pairPressed = NO;
    self.pairDone = NO;
    self.timeAndDateAsked = NO;
    self.syncView.hidden = YES;
    /*
    UIImage *buttonImage = [UIImage imageNamed:@"st_v4_navbar_ic_back"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setTitle:@"CANCEL" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 20, 20);
    [button addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
    */
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(backPressed:)];
    [customBarItem2 setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    
    //UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithCustomView:button];
    
 //   UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    self.navigationController.navigationBar.translucent = NO;
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    
    /*
    UIImage *buttonImage = [UIImage imageNamed:@"st_v4_navbar_ic_back"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setTitle:@"CANCEL" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 40, 20);
    [button addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
   
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
     */
    
    self.watchDisconnected = NO;
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.profileUpdated) {
        self.syncView.hidden = NO;
        UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
        self.navigationItem.leftBarButtonItem = customBarItem2;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [Flurry logEvent:SETUP_DEVICE_PAGE];
    //[self updateUserProfile];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Observer

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActiveHandler)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - Start sync

- (void)startSyncCModel
{
    self.salutronSyncC300.updateTimeAndDate = YES;
    self.salutronSyncC300.initialSync = YES;
    [self.salutronSyncC300 startSyncWithWatchModel:self.currentWatchModel];
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startSyncRModel
{
    self.foundDevice                                = NO;
    
    self.userDefaultsManager.macAddress             = nil;
    self.userDefaultsManager.salutronUserProfile    = nil;
    self.userDefaultsManager.timeDate               = nil;
    self.userDefaultsManager.notificationStatus     = YES;
    
    self.salutronSync                              = [[SFASalutronSync alloc] init];
    self.salutronSync.delegate                     = self;
    self.salutronSync.selectedWatchModel           = WatchModel_R450;
    self.salutronSync.syncType                     = SyncTypeInitial;
    
    self.userDefaultsManager.macAddress             = nil;
    self.userDefaultsManager.promptChangeSettings   = YES;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [SFASyncProgressView hide];
    [self.salutronSync startSync];
}

#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DDLogInfo(@"");
    
    if ([segue.identifier isEqualToString:syncPageSegueIdentifier]) {
        
        SFASyncPageViewController *syncPage = (SFASyncPageViewController *)segue.destinationViewController;
        syncPage.watchModel = self.currentWatchModel;
        syncPage.updateTimeAndDate = self.updateTimeAndDate;
        
    } else if ([segue.identifier isEqualToString:pairSegueIdentifier]) {

        self.pairViewController                         = (SFAPairViewController *)segue.destinationViewController;
        self.pairViewController.delegate                = self;
        self.pairViewController.watchModel              = self.currentWatchModel;
        self.pairViewController.showCancelSyncButton    = YES;
        self.pairViewController.paired                  = self.isPaired;
        self.pairViewController.startedFromConnectionView = YES;
        
        self.salutronSyncC300.delegate              = self;
        self.salutronSyncC300.updateTimeAndDate     = YES;
        self.hideErrorView = NO;
        
        if (self.currentWatchModel == WatchModel_Move_C300 ||
            self.currentWatchModel == WatchModel_Move_C300_Android ||
            self.currentWatchModel == WatchModel_Zone_C410 ||
            self.currentWatchModel == WatchModel_R420) {
            [self startSyncCModel];
        } else {
            [self startSyncRModel];
        }
        
        /*if (self.currentWatchModel != WatchModel_R450) {
            [self startSyncCModel];
        }*/
        
    } else if ([segue.identifier isEqualToString:profileSegueIdentifier]) {
        
        SFAYourProfileViewController *viewController    = (SFAYourProfileViewController *)segue.destinationViewController;
        viewController.delegate                         = self;
    }
}

#pragma mark - IBActions

- (IBAction)backPressed:(id)sender
{
    DDLogInfo(@"");
    
    if (self.syncView.hidden) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    self.hideErrorView = YES;
    self.syncView.hidden = YES;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(backPressed:)];
    [customBarItem2 setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView stopAnimating];
    
    [self.salutronSyncC300.salutronSDK commDone];
    Status status = [self.salutronSyncC300.salutronSDK disconnectDevice];
    if (status != WARNING_BUSY) {
        [self disconnectOnBackPress];
        self.salutronSyncC300.delegate = nil;
        self.salutronSyncC300.salutronSDK.delegate = nil;
    }
    else{
        self.salutronSyncC300.delegate = nil;
        self.salutronSyncC300.salutronSDK.delegate = nil;
        [self performSelector:@selector(disconnectOnBackPress) withObject:nil afterDelay:4.0];
    }

    //[self cancelSync:nil];
}

- (void)cancelSync:(id)sender
{
    DDLogInfo(@"");
    self.hideErrorView = YES;
    self.syncView.hidden = YES;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(backPressed:)];
    [customBarItem2 setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView stopAnimating];
    
    
    
    [self.salutronSyncC300.salutronSDK commDone];
    //Status status =
    [self.salutronSyncC300.salutronSDK disconnectDevice];
    [self disconnectOnBackPress];

}

- (void)disconnectOnBackPress{
    DDLogInfo(@"");
    //NSString *macAddress = nil;
    // Status status = [self.salutronSyncC300.salutronSDK getMacAddress:&macAddress];
    [self.salutronSyncC300.salutronSDK commDone];
    //Status status2 =
    [self.salutronSyncC300.salutronSDK disconnectDevice];
    [self.salutronSyncC300 deleteDevice];
    [self.salutronSync deleteDevice];
    
    [self.salutronSync.salutronSDK disconnectDevice];
    
    [self hideTryAgainView];
    self.foundDevice = NO;
    
    self.salutronSync.delegate = nil;
    self.salutronSync.salutronSDK.delegate = nil;
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)tryAgainClicked:(id)sender
{
    DDLogInfo(@"");
    [self hideTryAgainView];
    
    self.pairPressed            = YES;
    if ([self.view viewWithTag:7])
        [[self.view viewWithTag:7] removeFromSuperview];
    
    [self.salutronSDK clearDiscoveredDevice];
    [self.salutronSyncC300 deleteDevice];
    [self.salutronSync deleteDevice];
    self.salutronSync.delegate = self;
    
    if (self.currentWatchModel == WatchModel_R450) {
        if (!self.salutronSync) {
            self.salutronSync = [[SFASalutronSync alloc] init];
        }
        self.salutronSync.delegate = self;
        [self.salutronSync searchConnectedDevice];
    } else {
        self.isPaired = NO;
        [self performSegueWithIdentifier:pairSegueIdentifier sender:self];
    }
    //[self performSegueWithIdentifier:pairSegueIdentifier sender:self];
}

#pragma mark - SalutronSDKDelegate

- (void) didSearchConnectedWatch:(BOOL)found
{
    if (found) {
        /*
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
        [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.currentWatchModel]) animate:YES showButton:YES];
        
        [self startSyncRModel];
        */
        self.isPaired = YES;
    } else {
        self.isPaired = NO;
       /*
        if (!self.pairViewController.isViewLoaded && !self.pairViewController.view.window)
            [self performSegueWithIdentifier:pairSegueIdentifier sender:self];
        [self.salutronSync setRModelSyncType:SyncTypeInitial];
        */
        //[self.salutronSync startSync];
    }
    [self performSegueWithIdentifier:pairSegueIdentifier sender:self];
}

- (void)didRetrieveConnectedDevice:(int)numDevice withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if (numDevice > 0) {
        [self.salutronSDK connectDevice:0];
        self.fromRetrieveDevice = YES;
    } else {
        [self.salutronSDK discoverDevice:discoverTimeoutInSeconds];
    }
}

- (void)didDisconnectDevice:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    /*
    if (!self.syncComplete && ![self.view viewWithTag:6]) [self.syncView showFail];
    [[self.view viewWithTag:5] removeFromSuperview];
    [[self.view viewWithTag:6] removeFromSuperview];
    self.foundDevice = NO;
     */
}

- (void)didDiscoverDevice:(int)numDevice withStatus:(Status)status {
   
    DDLogInfo(@"\n---------------> STATUS: %@ NUM DEVICE : %d\n", Status_toString[status], numDevice);
    if (numDevice > 0) {
        if (self.deviceIndex < numDevice) {
            if (status == UPDATE)
                [self.salutronSDK connectDevice:self.deviceIndex];
        } else {
            if (!self.foundDevice)
                [self raiseDiscoverTimeout];
        }
        
        //if (status == UPDATE) {
        //    if (self.deviceIndex < numDevice) {
        //        [self.salutronSDK connectDevice:self.deviceIndex];
        //    } else {
        //        if (!self.foundDevice)
        //            [self raiseDiscoverTimeout];
        //    }
        //}
    } else {
        [[self.view viewWithTag:5] removeFromSuperview];
        [[self.view viewWithTag:6] removeFromSuperview];
        [[self.view viewWithTag:7] removeFromSuperview];
        [self raiseDiscoverTimeout];
    }
}

- (void)didGetModelNumber:(ModelNumber *)modelNumber withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    //if (modelNumber.number == self.currentWatchModel) {
    
    if (self.currentWatchModel == WatchModel_R450) {
        
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
        self.userDefaultsManager.watchModel = self.currentWatchModel;
        
        [[self.view viewWithTag:5] removeFromSuperview];
        [[self.view viewWithTag:6] removeFromSuperview];
        
        [self performSelector:@selector(requestDateAndTimeFromWatch) withObject:nil afterDelay:0];
        [self requestDateAndTimeFromWatch];
        
        /*if (self.timeAndDateAsked) {
            self.timeAndDateAsked = NO;
            [self performSelector:@selector(requestDateAndTimeFromWatch) withObject:nil afterDelay:5];
        }*/
        //[self navigateToMainViewController];
    } else {
        self.deviceIndex++;
        int numDevice = 0;
        Status s = [self.salutronSDK getNumDiscoveredDevice:&numDevice];
        
        if (s == NO_ERROR) {
            [self didDiscoverDevice:numDevice withStatus:s];
        }
    }
}

- (void)didConnectAndSetupDeviceWithStatus:(Status)status
{
    NSString *macAddress = nil;
    Status s0 = [self.salutronSDK getMacAddress:&macAddress];
    //DDLogError(@"macAddress status: %@", [ErrorCodeToStringConverter convertToString:s0]);
    DDLogInfo(@"\n---------------> STATUS: %@ ---> MAC ADDRESS : %@ ---> MAC ADDRESS STATUS : %@\n", Status_toString[status], macAddress, [ErrorCodeToStringConverter convertToString:s0]);
    
    NSString *firmwareRevision = @"";
    Status _status = [self.salutronSDK getFirmwareRevision:&firmwareRevision];
    
    if (_status == NO_ERROR) {
        DDLogError(@"%@", firmwareRevision);
    }
    
    NSString *softwareRevision = @"";
    _status = [self.salutronSDK getSoftwareRevision:&softwareRevision];
    
    if (_status == NO_ERROR) {
        DDLogError(@"%@", softwareRevision);
    }
    
    if (macAddress != nil && self.isFromRetrieveDevice) {
        Status model = [self.salutronSDK getModelNumber];
        DDLogError(@"getModelNumber status: %@", [ErrorCodeToStringConverter convertToString:model]);
        self.fromRetrieveDevice = NO;
    }
    
}

- (void)didGetCurrentTimeAndDate:(TimeDate *)timeDate withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
    if (timeDate.date.day == 1 &&
       timeDate.date.month == 1 &&
       (timeDate.date.year == 113 || timeDate.date.year == 114)) {
        self.updateTimeAndDate = YES;
        [self navigateToMainViewController];
    } else {
        [self navigateToMainViewController];
    }
}

- (void)didGetBattLevel:(NSString *)battLevelString withStatus:(Status)status
{
    DDLogInfo(@"\n---------------> STATUS: %@\n", Status_toString[status]);
    
}

- (void)didChangeSettings
{
    if (!self.userDefaultsManager.promptChangeSettings) {
        switch (self.userDefaultsManager.syncOption) {
            case SyncOptionWatch:
                [self didPressWatchButtonOnSettingsPromptView:nil];
                break;
            case SyncOptionApp:
                [self didPressAppButtonOnSettingsPromptView:nil];
                break;
            case SyncOptionNone:
                [self didPressWatchButtonOnSettingsPromptView:nil];
                break;
            default:
                [self didPressAppButtonOnSettingsPromptView:nil];
                break;
        }
    }
    else {
        [SFASettingsPromptView settingsPromptView].delegate = self;
        [SFASettingsPromptView show];
    }
}

- (void)didSaveSettings
{
    DDLogInfo(@"");
    self.salutronSyncC300.delegate = nil;
    [self finishUpdate];
}

#pragma mark - SyncConnectionViewDelegate

- (void)cancelButtonDidClicked:(id)sender
{
    DDLogInfo(@"");
    if (self.userDefaultsManager.watchModel == WatchModel_Move_C300 ||
        self.userDefaultsManager.watchModel == WatchModel_Move_C300_Android ||
        self.userDefaultsManager.watchModel== WatchModel_Zone_C410 ||
        self.userDefaultsManager.watchModel== WatchModel_R420) {
        [self.salutronSDK commDone];
    }

    [self.salutronSyncC300 deleteDevice];
    [self.salutronSync deleteDevice];
    [[[UIApplication sharedApplication].delegate.window viewWithTag:1001] removeFromSuperview];
}

- (void)tryAgainButtonDidClicked:(id)sender
{
    //[[[UIApplication sharedApplication].delegate.window viewWithTag:1001] removeFromSuperview];
    //[self discoverDevice];
    DDLogInfo(@"");
    
    self.foundDevice = NO;
    
    if (self.syncView){
        [self.syncView removeFromSuperview];
        self.syncView = nil;
    }
    
    if ([self.view viewWithTag:5])
        [[self.view viewWithTag:5] removeFromSuperview];
    if ([self.view viewWithTag:6])
        [[self.view viewWithTag:6] removeFromSuperview];
    if ([self.view viewWithTag:7])
        [[self.view viewWithTag:7] removeFromSuperview];
    
    [self performSegueWithIdentifier:pairSegueIdentifier sender:self];
}

#pragma mark - UITableViewDelegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return (R500_SUPPORTED) ? 4 : ((R450_SUPPORTED) ? 3 : 2);
    }    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"WatchModel";
    SFAWatchModelCell *watchModelCell = (SFAWatchModelCell *) [UITableViewCell new];
    
    switch (indexPath.row) {
        case 0:
            watchModelCell = [tableView dequeueReusableCellWithIdentifier:identifier];
            [watchModelCell setWatchModel:WatchModel_Move_C300];
            break;
        case 1:
            watchModelCell = [tableView dequeueReusableCellWithIdentifier:identifier];
            [watchModelCell setWatchModel:WatchModel_Zone_C410];
            break;
        case 2:
            watchModelCell = [tableView dequeueReusableCellWithIdentifier:identifier];
            [watchModelCell setWatchModel:WatchModel_R450];
            break;
        case 3:
            watchModelCell = [tableView dequeueReusableCellWithIdentifier:identifier];
            [watchModelCell setWatchModel:WatchModel_R500];
            break;
        default:
            break;
    }
    
    [watchModelCell displayInfo];
    watchModelCell.delegate = self;
    
    return watchModelCell;
}

#pragma mark - SFAWatchModelCellDelegate

- (void)didClickOnConnectWithWatchModel:(WatchModel)watchModel
{
    self.currentWatchModel           = watchModel;
    self.pairPressed            = YES;
    
    if (self.bluetoothOn) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
        
        if (watchModel == WatchModel_R450) {
            if (!self.salutronSync) {
                self.salutronSync = [[SFASalutronSync alloc] init];
            }
            self.salutronSync.delegate = self;
            [self.salutronSync searchConnectedDevice];
        } else {
            self.isPaired = NO;
            [self performSegueWithIdentifier:pairSegueIdentifier sender:self];
        }
        //[self performSegueWithIdentifier:pairSegueIdentifier sender:self];
        
    } else {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                     message:TURN_ON_BLUETOOTH preferredStyle:UIAlertControllerStyleAlert];
            
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:TURN_ON_BLUETOOTH
                                                           delegate:nil
                                                  cancelButtonTitle:BUTTON_TITLE_OK
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

#pragma mark - Other methods

- (void)discoverDevice
{
    DDLogInfo(@"");
    //[self.salutronSDK clearDiscoveredDevice];
    //[self.salutronSDK discoverDevice:discoverTimeout];
    self.salutronSDK.delegate = self;
    [self.salutronSDK clearDiscoveredDevice];
    [self.salutronSDK retrieveConnectedDevice];
    DDLogInfo(@"RETRIEVE CONNECTED DEVICE");
    self.foundDevice = NO;
    /*[self performSelector:@selector(raiseDiscoverTimeout)
     withObject:nil
     afterDelay:discoverTimeoutInSeconds];*/
    //[self showProgress];
}

- (Status)updateUserProfileAndTime
{
    DDLogInfo(@"");
    self.salutronSDK.delegate = self;
    
    if (self.profileUpdated)
    {
        Status updateUserStatus = [self.salutronSDK updateUserProfile:self.userDefaultsManager.salutronUserProfile];
        
        if (updateUserStatus == NO_ERROR) {
            
            self.profileUpdated = NO;
            
        } else {
            self.foundDevice = NO;
            
            // Added 02/06/2015
            self.profileUpdated = NO;
            [self finishUpdate];
            
            //[self showTryAgainFailView];
        }
        
        return updateUserStatus;
    }
    return ERROR_UPDATE;
}


- (void)didUpdateUserProfileWithStatus:(Status)status
{
    DDLogInfo(@"");
    [self.salutronSDK updateTimeAndDate:[TimeDate getUpdatedData]];
}

- (void)didUpdateTimeAndDateWithStatus:(Status)status
{
    DDLogInfo(@"");
    //[SFASyncProgressView hide];
    [self finishUpdate];
}

- (void)updateLastSync
{
    DDLogInfo(@"");
    self.userDefaultsManager.hasPaired = YES;
    self.userDefaultsManager.macAddress = self.deviceEntity.macAddress;
    self.userDefaultsManager.lastSyncedDate = [NSDate date];
    self.deviceEntity.lastDateSynced = self.userDefaultsManager.lastSyncedDate;
}

- (void)requestDateAndTimeFromWatch
{
    DDLogInfo(@"");
    static NSUInteger retryCount;
    Status status = [self.salutronSDK getCurrentTimeAndDate];
    
    DDLogError(@"getCurrentTimeAndDate status: %@", [ErrorCodeToStringConverter convertToString:status]);
    
    if (status == WARNING_NOT_CONNECTED) {
        self.timeAndDateAsked = YES;
        retryCount++;
        
        if (retryCount == 2) {
            NSString *watchModel = [self watchModelStringForWatchModel:self.currentWatchModel];
            if (self.isIOS8AndAbove) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                         message:SYNC_FAILED(watchModel)
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:SYNC_FAILED(watchModel)
                                                               delegate:nil
                                                      cancelButtonTitle:BUTTON_TITLE_OK
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
            return;
        }
        
        [self discoverDevice];
    } else if (status == NO_ERROR) {
        DDLogError(@"requestDateAndTimeFromWatch error: %@", [ErrorCodeToStringConverter convertToString:status]);
        [self navigateToMainViewController];
    } else {
        [self showTryAgainFailView];
    }
}

- (void)finishUpdate
{
    DDLogInfo(@"");
   
    if (self.profileUpdated) {
        //self.syncView.hidden = YES;
        [self performSegueWithIdentifier:profileSegueIdentifier sender:self];
        return;
    }
    else {
        NSUndoManager *undoManager = [[NSUndoManager alloc] init];
        self.managedObjectContext.undoManager = undoManager;
        
        [undoManager beginUndoGrouping];
        
        NSError *error = nil;
        
        if ([self.managedObjectContext save:&error]) {
            [undoManager endUndoGrouping];
        } else {
            [undoManager undo];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.view viewWithTag:5].layer.opacity = 0.0f;
        } completion:^(BOOL finished) {
            self.syncComplete   = YES;
            [self hideChecksumErrorView];
            [self hideEstablishingConnectionView];
            [self hideTryAgainView];
            [self.syncView stopAnimating];
            
            [self performSelector:@selector(showSuccess) withObject:nil afterDelay:0];
            
            if (self.currentWatchModel == WatchModel_Move_C300 || self.currentWatchModel ==WatchModel_Move_C300_Android || self.currentWatchModel == WatchModel_Zone_C410) {
                [self.salutronSDK commDone];
//                [self.salutronSDK disconnectDevice];
//                [self performSelector:@selector(disconnectDevice) withObject:nil afterDelay:delay];
            }
            else {
                //[self.salutronSDK disconnectDevice];
            }
        
            self.salutronSDK.delegate = nil;
            self.salutronSDK = nil;
        }];
    }
}

- (void)navigateToMainViewController
{
    DDLogInfo(@"");
    if (self.currentWatchModel == WatchModel_Core_C200 ||
        self.currentWatchModel == WatchModel_Move_C300 ||
        self.currentWatchModel == WatchModel_Move_C300_Android ||
        self.currentWatchModel == WatchModel_Zone_C410) {
        return;
    }
    
    self.salutronSDK.delegate = nil;
    [self performSegueWithIdentifier:syncPageSegueIdentifier sender:self];
}

#pragma mark - UI stuff

- (void)showProgress
{
    DDLogInfo(@"");
    
    [self hideEstablishingConnectionView];
    UIView *viewOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    UIView *viewContent = [[UIView alloc] init];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    viewOverlay.tag = 5;
    viewOverlay.backgroundColor = [UIColor blackColor];
    viewOverlay.layer.opacity = 0.5;
    
    float contentWidth = self.view.bounds.size.width-60;
    float contentHeight = 130.0f;
    CGRect contentFrame = CGRectMake((viewOverlay.bounds.size.width / 2) - (contentWidth /  2),
                                     (viewOverlay.bounds.size.height / 2) - (contentHeight / 2),
                                     contentWidth, contentHeight);
    viewContent.frame = contentFrame;
    viewContent.backgroundColor = [UIColor whiteColor];
    viewContent.layer.cornerRadius = 10;
    viewContent.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewContent.layer.shadowRadius = 5.0f;
    viewContent.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    viewContent.layer.shadowOpacity = 1.0f;
    
    UILabel *label = [[UILabel alloc] init];
    UILabel *reminderLabel = [[UILabel alloc] init];
    
    label.tag = 7;
    if (self.currentWatchModel == WatchModel_Move_C300_Android) {
        self.currentWatchModel = WatchModel_Move_C300;
    }
    switch (self.currentWatchModel) {
        case WatchModel_Move_C300:
            label.text = SYNC_SEARCH(WATCHNAME_MOVE_C300);
            break;
        case WatchModel_Core_C200:
            label.text = SYNC_SEARCH(WATCHNAME_CORE_C200);
            break;
        case WatchModel_Zone_C410:
            label.text = SYNC_SEARCH(WATCHNAME_ZONE_C410);
            break;
        case WatchModel_R420:
            label.text = SYNC_SEARCH(WATCHNAME_R420);
            break;
        case WatchModel_R450:
            label.text = SYNC_SEARCH(WATCHNAME_BRITE_R450);
            break;
        case WatchModel_R500:
            label.text = SYNC_SEARCH(WATCHNAME_R500);
            break;
        default:
            label.text = SYNC_SEARCH(WATCHNAME_DEFAULT);
            break;
    }
    
    label.font = [label.font fontWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    CGRect labelFrame = CGRectMake(0, 0, label.bounds.size.width, 20);
    label.frame = labelFrame;
    label.center = CGPointMake(viewContent.frame.size.width/2, 30);
    
    reminderLabel.font = [reminderLabel.font fontWithSize:12];
    reminderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    reminderLabel.numberOfLines = 2;
    reminderLabel.textAlignment = NSTextAlignmentCenter;
    
    UIImageView *syncImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_connect_1finding.png"]];
    syncImage.frame = CGRectMake((viewContent.bounds.size.width / 2) - (syncImage.bounds.size.width / 2), label.frame.origin.y + 40, syncImage.bounds.size.width, syncImage.bounds.size.height);
    
    reminderLabel.frame = CGRectMake(0, 0, viewContent.bounds.size.width-60, 40);
    reminderLabel.center = CGPointMake(viewContent.bounds.size.width/2, syncImage.frame.origin.y + syncImage.frame.size.height + 36);
    
    [closeButton setImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_0_xcancel.png"] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(viewContent.frame.size.width-35, 0, 30, 30);
    [closeButton addTarget:self action:@selector(cancelSync:) forControlEvents:UIControlEventTouchUpInside];
    
    viewContent.layer.opacity = 1.0;
    viewContent.tag = 6;
    [viewContent addSubview:label];
    [viewContent addSubview:syncImage];
    [viewContent addSubview:reminderLabel];
    [viewContent addSubview:closeButton];
    [viewContent bringSubviewToFront:closeButton];
    [self.view addSubview:viewOverlay];
    [self.view bringSubviewToFront:viewOverlay];
    [self.view insertSubview:viewContent aboveSubview:viewOverlay];
}

- (void)showChecksumFailView
{
    DDLogInfo(@"");
    [self hideEstablishingConnectionView];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    
    if (!self.hideErrorView) {
      //  [self showChecksumFailViewWithTarget:self cancelSelector:@selector(cancelSync:) tryAgainSelector:@selector(tryAgainClicked:)];
    }
}

- (void)showTryAgainFailView
{
    DDLogInfo(@"");
    
    [self hideEstablishingConnectionView];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    
    if (!self.hideErrorView) {
         if ([self respondsToSelector:@selector(showTryAgainViewWithTarget:cancelSelector:tryAgainSelector:)]) {
             [self showTryAgainViewWithTarget:self cancelSelector:@selector(cancelSync:) tryAgainSelector:@selector(tryAgainClicked:)];
         }
    }
}

- (void)showSuccess
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
    
    if (manager.isLoggedIn) {
        [self performSegueWithIdentifier:serverSegueIdentifier sender:self];
    }
    else {
        [self performSegueWithIdentifier:registerSegueIdentifier sender:self];
    }
}

- (void)raiseDiscoverTimeout
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (!self.hideErrorView) {
        [self showTryAgainFailView];
    }
}

- (void)disconnectDevice
{
    DDLogInfo(@"");
    
    if(self.userDefaultsManager.watchModel == WatchModel_Move_C300 ||
       self.userDefaultsManager.watchModel == WatchModel_Move_C300_Android ||
       self.userDefaultsManager.watchModel == WatchModel_Zone_C410) {
        [self.salutronSyncC300 disconnectWatch];
        [self.salutronSyncC300 deleteDevice];
    }
    
    [self.salutronSync deleteDevice];
}

#pragma mark - Notification handler

- (void)didBecomeActiveHandler
{
    DDLogInfo(@"");
    if (self.pairPressed &&
       self.currentWatchModel == WatchModel_R450) {
        //[self navigateToMainViewController];
        [[self.view viewWithTag:5] removeFromSuperview];
        [[self.view viewWithTag:6] removeFromSuperview];
        //[[self.view viewWithTag:7] removeFromSuperview];
        self.pairPressed = NO;
        //[SVProgressHUD showWithStatus:LS_PAIRING_DEVICE maskType:SVProgressHUDMaskTypeBlack];
        //[self performSelector:@selector(requestDateAndTimeFromWatch) withObject:nil afterDelay:15];
        
        [self hideEstablishingConnectionView];
        if (!self.watchDisconnected) {
            [self showEstablishingConnectionview];
        }
    
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    }
    self.pairDone = YES;
    self.watchDisconnected = NO;
}

- (void)didEnterBackground
{
    DDLogInfo(@"");
    self.pairPressed = NO;
    self.pairDone = NO;
}

- (NSString *)watchModelStringForWatchModel:(WatchModel)watchModel
{
    DDLogInfo(@"");
    if (watchModel == WatchModel_Core_C200)
    {
        return WATCHNAME_CORE_C200;
    }
    else if (watchModel == WatchModel_Move_C300 || watchModel == WatchModel_Move_C300_Android)
    {
        return WATCHNAME_MOVE_C300;
    }
    else if (watchModel == WatchModel_Zone_C410)
    {
        return WATCHNAME_ZONE_C410;
    }
    else if (watchModel == WatchModel_R420)
    {
        return WATCHNAME_R420;
    }
    else if (watchModel == WatchModel_R450)
    {
        return WATCHNAME_BRITE_R450;
    }
    else if (watchModel == WatchModel_R500)
    {
        return WATCHNAME_R500;
    }
    else {
        return WATCHNAME_DEFAULT;
    }
    return nil;
}

#pragma mark - SFASalutronSyncDelegate

- (void)didDeviceDisconnected:(BOOL)isSyncFinished
{
    DDLogInfo(@"");
    //[SFASyncProgressView hide];
    [self hideEstablishingConnectionView];
    [SFASettingsPromptView hide];
    self.syncView.hidden = YES;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(backPressed:)];
    [customBarItem2 setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView stopAnimating];
    self.watchDisconnected = YES;
    if (self.currentWatchModel == WatchModel_R450) {
        self.syncView.hidden = YES;
        UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(backPressed:)];
        [customBarItem2 setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];self.navigationItem.leftBarButtonItem = customBarItem2;
        [self.salutronSync deleteDevice];
    }
    else {
        if (self.deviceEntity) {
            [self.salutronSyncC300 deleteDevice];
            self.deviceEntity = nil;
        }
        if (!isSyncFinished) {
            [self showTryAgainFailView];
        }
        
    }
}


- (void)didDeviceConnected
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    /*if (self.currentWatchModel == WatchModel_Move_C300 || self.currentWatchModel == WatchModel_Zone_C410) {
        [self navigateToMainViewController];
    }*/
}

- (void)didPairWatch
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    [self showEstablishingConnectionview];
}

- (void)syncStartedWithDeviceEntity:(DeviceEntity *)deviceEntity
{
    DDLogInfo(@"");
    self.deviceEntity = deviceEntity;
}

- (void)didSyncStarted
{
    DDLogInfo(@"");
    self.hideErrorView = NO;
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    [self hideEstablishingConnectionView];
    [SFASyncProgressView hide];
    self.foundDevice = YES;
    
    [Flurry logEvent:SYNCING_PAGE];
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView beginAnimating];
}

- (void)didUpdateFinish
{
    DDLogInfo(@"");
    self.syncView.hidden = YES;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(backPressed:)];
    [customBarItem2 setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    
    self.userDefaultsManager.lastSyncedDate     = [NSDate date];
    self.userDefaultsManager.watchModel         = self.currentWatchModel;
    self.userDefaultsManager.hasPaired          = YES;
    
    self.profileUpdated                         = YES;
    
    if (self.currentWatchModel != WatchModel_R450) {
        
        if (!self.salutronSyncC300.updatedSettings) {
            self.salutronSyncC300.delegate = nil;
            [self finishUpdate];
        }
    }
    else {
        self.salutronSyncC300.delegate = nil;
        [self finishUpdate];
    }
}

- (void)didSyncFinished:(DeviceEntity *)deviceEntity profileUpdated:(BOOL)profileUpdated
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    
    self.userDefaultsManager.lastSyncedDate     = [NSDate date];
    self.userDefaultsManager.watchModel         = self.currentWatchModel;
    self.userDefaultsManager.hasPaired          = YES;
    self.userDefaultsManager.deviceUUID         = deviceEntity.uuid;
    self.userDefaultsManager.macAddress         = deviceEntity.macAddress;
    
    self.profileUpdated                         = YES;
    
    if (self.currentWatchModel != WatchModel_R450) {
        
        if (!self.salutronSyncC300.updatedSettings) {
            self.salutronSyncC300.delegate = nil;
            [self finishUpdate];
        }
    }
    else {
        self.salutronSyncC300.delegate = nil;
        [self finishUpdate];
    }
}

- (void)didDiscoverTimeout
{
    DDLogInfo(@"");
    [self cancelSync:nil];
    self.hideErrorView = NO;
    [self showTryAgainFailView];
}

- (void)didDiscoverTimeoutWithDiscoveredDevices:(NSArray *)discoveredDevices
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = YES;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(backPressed:)];
    [customBarItem2 setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];self.navigationItem.leftBarButtonItem = customBarItem2;
    [self didDiscoverTimeout];
}

- (void)didChecksumError
{
    DDLogInfo(@"");
    self.syncView.hidden = YES;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(backPressed:)];
    [customBarItem2 setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self showChecksumFailView];
    [self disconnectDevice];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    
}

- (void)didRaiseError
{
    DDLogInfo(@"");
    self.syncView.hidden = YES;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(backPressed:)];
    [customBarItem2 setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self showTryAgainFailView];
    [self disconnectDevice];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    
}


- (void)didSyncOnDataHeaders
{
    DDLogInfo(@"");
    [self.syncView beginAnimating];
    [self hideTryAgainView];
    [self hideChecksumErrorView];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = NO;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView setLabelValue:SYNC_MESSAGE(NSLocalizedString(@"Syncing data headers", nil))];
}

- (void)didSyncOnDataPoints:(NSInteger)percent
{
    DDLogInfo(@"");
    [self.syncView beginAnimating];
    NSString *status = [NSString stringWithFormat:NSLocalizedString(@"FITNESS RESULTS - %i%%",nil), percent];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = NO;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView setLabelValue:SYNC_MESSAGE(status)];
}

- (void)didSyncOnLightDataPoints
{
    DDLogInfo(@"");
    [self.syncView beginAnimating];
    [self hideTryAgainView];
    [self hideChecksumErrorView];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = NO;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView setLabelValue:SYNC_MESSAGE(NSLocalizedString(@"Syncing light data points", nil))];
}

- (void)didSyncOnDataPoints
{
    DDLogInfo(@"");
    [self.syncView beginAnimating];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = NO;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView setLabelValue:SYNC_MESSAGE(NSLocalizedString(@"Syncing fitness results", nil))];
}

- (void)didSyncOnStepGoal
{
    DDLogInfo(@"");
    [self.syncView beginAnimating];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = NO;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView setLabelValue:SYNC_MESSAGE(NSLocalizedString(@"Syncing step goal", nil))];
}

- (void)didSyncOnDistanceGoal
{
    DDLogInfo(@"");
    [self.syncView beginAnimating];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = NO;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView setLabelValue:SYNC_MESSAGE(NSLocalizedString(@"Syncing distance goal", nil))];
}

- (void)didSyncOnCalorieGoal
{
    DDLogInfo(@"");
    [self.syncView beginAnimating];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = NO;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView setLabelValue:SYNC_MESSAGE(NSLocalizedString(@"Syncing calorie goal", nil))];
}

- (void)didSyncOnSleepSettings
{
    [self.syncView beginAnimating];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = NO;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView setLabelValue:SYNC_MESSAGE(NSLocalizedString(@"Syncing sleep settings", nil))];
}

- (void)didSyncOnCalibrationData
{
    DDLogInfo(@"");
    [self.syncView beginAnimating];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = NO;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView setLabelValue:SYNC_MESSAGE(NSLocalizedString(@"Syncing calibration data", nil))];
}

- (void)didSyncOnWorkoutDatabase
{
    DDLogInfo(@"");
    [self.syncView beginAnimating];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = NO;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView setLabelValue:SYNC_MESSAGE(NSLocalizedString(@"Syncing workout database", nil))];
}

- (void)didSyncOnSleepDatabase
{
    DDLogInfo(@"");
    [self.syncView beginAnimating];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = NO;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView setLabelValue:SYNC_MESSAGE(NSLocalizedString(@"Syncing sleep database", nil))];
}

- (void)didSyncOnUserProfile
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = NO;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView setLabelValue:SYNC_MESSAGE(NSLocalizedString(@"Syncing user profile", nil))];
}

- (void)didSyncOnTimeAndDate
{
    DDLogInfo(@"");
    [self.syncView beginAnimating];
    [self hideEstablishingConnectionView];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = NO;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backPressed:)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    [self.syncView setLabelValue:SYNC_MESSAGE(NSLocalizedString(@"Syncing time and date", nil))];
}

- (void)didSyncFinishOnUserProfile
{
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    self.syncView.hidden = YES;
    UIBarButtonItem *customBarItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(backPressed:)];
    [customBarItem2 setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = customBarItem2;
    self.profileUpdated = NO;
}

- (void)didRetrieveDeviceFromSearching
{
    //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:NO showButton:YES];
    [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.currentWatchModel]) animate:YES showButton:YES onButtonClick:^{
        [SFASyncProgressView hide];
        [self.salutronSync stopSync];
    }];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            self.updateTimeAndDate = YES;
        } else {
            self.updateTimeAndDate = NO;
        }
        [self navigateToMainViewController];
        self.timeAndDateAsked = YES;
        
    } else {
        if (buttonIndex == 1)
        {
            if (self.currentWatchModel == WatchModel_Move_C300 || self.currentWatchModel == WatchModel_Move_C300_Android || self.currentWatchModel == WatchModel_Zone_C410) {
                [self.salutronSyncC300 startSyncWithWatchModel:self.currentWatchModel];
            } else {
                [self discoverDevice];
            }
            [self showProgress];
        }
    }
}

#pragma mark - SFAPairViewControllerDelegate Methods

- (void)didPressContinueInPairViewController:(SFAPairViewController *)viewController
{
    DDLogInfo(@"");
    if (self.currentWatchModel == WatchModel_Move_C300 || self.currentWatchModel == WatchModel_Move_C300_Android || self.currentWatchModel == WatchModel_Zone_C410) {
        [self startSyncCModel];
    } else {
        [self startSyncRModel];
    }
    
    [self showProgress];
}

- (void)didPressCancelInPairViewController:(SFAPairViewController *)viewController
{
    self.salutronSyncC300.delegate = nil;
    self.salutronSync.delegate = nil;
  //  [self disconnectDevice];
    [self cancelSync:nil];
}

#pragma mark - SFAYourProfileViewControllerDelegate Methods

- (void)didPressSaveInYourProfileViewController:(SFAYourProfileViewController *)viewController
{
    DDLogInfo(@"");
    
    //[SFASyncProgressView showWithMessage:@"Syncing time and date" animate:YES showButton:NO];
    [self updateUserProfileAndTime];
}

- (void)didPressCancelInYourProfileViewController:(SFAYourProfileViewController *)viewController
{
    DDLogInfo(@"");
    //[SFASyncProgressView showWithMessage:@"Syncing time and date" animate:YES showButton:NO];
    [self updateUserProfileAndTime];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    DDLogInfo(@"");
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            self.bluetoothOn = YES;
            break;
        case CBCentralManagerStatePoweredOff:
            self.bluetoothOn = NO;
            break;
        default:
            break;
    }
    self.userDefaultsManager.bluetoothOn = self.bluetoothOn;
}

#pragma mark - SFASettingsPromptViewDelegate Methods

- (void)didPressAppButtonOnSettingsPromptView:(SFASettingsPromptView *)view
{
    DDLogInfo(@"");
    /*
    if (!self.userDefaultsManager.promptChangeSettings) {
        self.userDefaultsManager.syncOption = SyncOptionApp;
    }
    */
    if (self.currentWatchModel == WatchModel_R450) {
        [self.salutronSync useAppSettingsWithDelegate:self];
    }
    else {
        [self.salutronSyncC300 useAppSettings];
    }

}

- (void)didPressWatchButtonOnSettingsPromptView:(SFASettingsPromptView *)view
{
    DDLogInfo(@"");
    /*
    if (!self.userDefaultsManager.promptChangeSettings) {
        self.userDefaultsManager.syncOption = SyncOptionWatch;
    }
    */
    if (self.currentWatchModel == WatchModel_R450) {
        [self.salutronSync useWatchSettingsWithDelegate:self];
    }
    else {
        [self.salutronSyncC300 useWatchSettings];
    }
}

@end
