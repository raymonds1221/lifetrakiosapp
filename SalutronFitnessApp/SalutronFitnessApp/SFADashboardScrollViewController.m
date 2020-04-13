
//
//  SFADashboardScrollViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/28/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFADashboardScrollViewController.h"

#import "NSDate+Comparison.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFAMainViewController.h"
#import "SFADashboardViewController+View.h"
#import "SFAFitnessResultsScrollViewController.h"
#import "SFAPairViewController.h"
#import "SFASlidingViewController.h"
#import "SFAIntroViewController.h"
#import "SFALoadingViewController.h"
#import "SFAContinuousHRPageViewController.h"
#import "SFAR420WorkoutPageViewController.h"

#import "SFASyncProgressView.h"
#import "SFASettingsPromptView.h"
#import "SVProgressHUD.h"
#import "SFADashboardCellPositionHelper.h"
#import "JDACoreData.h"
#import "SFAServerAccountManager.h"
#import "SFASalutronUpdateManager.h"

#import "SFAWatchManager.h"
#import "SFAServerSyncManager.h"
#import "SFAServerManager.h"
#import "SFASalutronSync.h"
#import "SFASessionExpiredErrorAlertView.h"
#import "UIViewController+Helper.h"
#import "NSDate+Formatter.h"
#import "NSDate+Format.h"
#import "StatisticalDataHeaderEntity+Data.h"
#import "WorkoutInfoEntity+Data.h"
#import "SleepDatabaseEntity+Data.h"
#import "SalutronUserProfile+Data.h"
#import "SFASalutronR420ModelSync.h"
#import "SFAServerSyncManager.h"

#import <HealthKit/HealthKit.h>
#import "SFAHealthKitManager.h"

#import "SFAFunFactsLifeTrakViewController.h"
#import "Flurry.h"
#import "SFAAmazonServiceManager.h"

#define LEFT_DASHBOARD_SEGUE_IDENTIFIER     @"LeftDashboard"
#define CENTER_DASHBOARD_SEGUE_IDENTIFIER   @"CenterDashboard"
#define RIGHT_DASHBOARD_SEGUE_IDENTIFIER    @"RightDashboard"
#define FITNESS_RESULTS_SEGUE_IDENTIFIER    @"DashboardScrollToFitnessResultsScroll"
#define FITNESS_RESULTS_PAGE_SEGUE_IDENTIFIER     @"DashboardScrollToFitnessResultsPageView"
#define HEART_RATE_SEGUE_IDENTIFIER         @"HeartRateSegueIdentifier"
#define WORKOUT_RESULTS_SEGUE_IDENTIFIER    @"DashboardToWorkoutList"
#define WORKOUT_GRAPH_SEGUE_IDENTIFIER      @"WorkoutResultsSegueIdentifier"
#define WORKOUT_LIST_SEGUE_IDENTIFIER       @"DashboardToWorkoutList"
#define ACTIGRAPHY_SEGUE_IDENTIFIER         @"DashboardToActigraphy"
#define ACTIGRAPHY_SCROLL_SEGUE_IDENTIFIER  @"DashboardToActigraphyScrollPage"
#define SLEEP_LOGS_SEGUE_IDENTIFIER         @"DashboardToSleepLogs"
#define PAIR_SEGUE_IDENTIFIER               @"DashboardToPair"
#define LIGHT_PLOT_SEGUE_IDENTIFIER         @"DashboardToLightPlot"
//#define WORKOUT_RESULTS_SEGUE_IDENTIFIER    @"WorkoutResultsSegueIdentifier"

@interface SFADashboardScrollViewController () <UIAlertViewDelegate, SFACalendarControllerDelegate, SFADashboardDelegate, SFAPairViewControllerDelegate, CBCentralManagerDelegate, SFASyncProgressViewDelegate, SFASettingsPromptViewDelegate, SFASessionExpiredErrorAlertViewDelegate, SFASalutronSyncDelegate, SFASalutronUpdateManagerDelegate, SFAHealthKitManagerDelegate, SFAAmazonServiceManagerDelegate>

@property (strong, nonatomic) SFASalutronCModelSync               *salutronSyncC300;
@property (strong, nonatomic) SFASalutronSync                   *salutronSync;
@property (strong, nonatomic) SFAUserDefaultsManager            *userDefaultsManager;
@property (strong, nonatomic) SFASalutronR420ModelSync          *salutronR420ModelSync;
@property (weak, nonatomic) SFADashboardViewController          *leftDashboard;
@property (weak, nonatomic) SFADashboardViewController          *centerDashboard;
@property (weak, nonatomic) SFADashboardViewController          *rightDashboard;
@property (weak, nonatomic) SFAPairViewController               *pairViewController;

@property (strong, nonatomic) SFADashboardCellPositionHelper    *dashboardPosition;
@property (readwrite, nonatomic) SFADashboardItem               dashBoardItem;

@property (readwrite, nonatomic) BOOL                           bluetoothOn;
@property (readwrite, nonatomic) BOOL                           isStillSyncing;
@property (readwrite, nonatomic) BOOL                           didCancel;
@property (readwrite, nonatomic) BOOL                           cancelSyncToCloudOperation;
@property (readwrite, nonatomic, getter=isDeviceFound) BOOL     deviceFound;

@property (strong, nonatomic) NSOperation                       *syncToCloudOperation;
@property (strong, nonatomic) CBCentralManager                  *centralManager;

@property (strong, nonatomic) SFASessionExpiredErrorAlertView *sessionExpiredAlertView;
@property (strong, nonatomic) DeviceEntity *device;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftFitnessWidthConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerFitnessWidthConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightFitnessWidthConstraints;

@end

@implementation SFADashboardScrollViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    DDLogInfo(@"");
    [super viewDidLoad];
    
    //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    //{
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        self.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        
        self.leftDashboardView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        self.centerDashboardView.frame = CGRectMake(screenWidth, 0, screenWidth, screenHeight);
        self.rightDashboardView.frame = CGRectMake(screenWidth*2, 0, screenWidth, screenHeight);
    //}
     
    
    [[SalutronSDK sharedInstance] clearDiscoveredDevice];
    [self initializeObjects];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [self setCloudSyncSwitchValue];
    self.isStillSyncing = NO;
}



- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"");
    [super viewWillAppear:animated];
    
    [Flurry logEvent:DASHBOARD_PAGE];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAutoSync) name:autoSyncNotificationName object:nil];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AutoSync"] isEqualToString:@"Undone"]) {
        [self notifyDashboardToStartSync];
    }
    
    [SFASyncProgressView progressView].delegate = self;
    
    if (self.userDefaultsManager.selectedDateFromCalendar)
        [self setContentsWithSelectedDate:self.userDefaultsManager.selectedDateFromCalendar];
    
    [self disableAutorotate];
    
}

- (void)notifyDashboardToStartSync
{
    [[NSNotificationCenter defaultCenter] postNotificationName:autoSyncNotificationName object:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:autoSyncNotificationName object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@"Done" forKey:@"AutoSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogInfo(@"");
    [super viewDidAppear:animated];
    
    if (self.userDefaultsManager.selectedDateFromCalendar)
        [self setContentsWithSelectedDate:self.userDefaultsManager.selectedDateFromCalendar];
    
    self.calendarController.calendarMode = SFACalendarDay;
//#warning uncomment after testing
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"justLaunched"] isEqualToString:@"YES"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"justLaunched"];
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AutoSync"] isEqualToString:@"Done"]) {
                UIViewController* vc;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    
                    vc = [[SFAFunFactsLifeTrakViewController alloc] initWithNibName:@"SFAFunFactsLifeTrakViewiPad" bundle:nil];
                }
                else{
                    vc = [SFAFunFactsLifeTrakViewController new];
                }
                [self presentViewController:vc animated:YES completion:nil];
            }
            else{
                [self startAutoSync];
            }
        }
        else{
        UIViewController* vc;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
             vc = [[SFAFunFactsLifeTrakViewController alloc] initWithNibName:@"SFAFunFactsLifeTrakViewiPad" bundle:nil];
        }
        else{
            vc = [SFAFunFactsLifeTrakViewController new];
        }
        [self presentViewController:vc animated:YES completion:nil];
        }
    }
    
    //[[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"InitialWatchToAppSync"];
    
    /*
    if (self.isIOS8AndAbove) {
        CGRect frame = self.centerDashboardView.frame;
        DDLogError(@"center dashboard frame: %@", NSStringFromCGRect(frame));
        [self.scrollView scrollRectToVisible:self.centerDashboardView.frame animated:NO];
    }*/
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    //{
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        self.leftFitnessWidthConstraints.constant = screenWidth;
        self.centerFitnessWidthConstraints.constant = screenWidth;
        self.rightFitnessWidthConstraints.constant = screenWidth;
        
        //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, screenWidth*3, screenHeight);
        //self.leftDashboardView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        //self.centerDashboardView.frame = CGRectMake(screenWidth, 0, screenWidth, screenHeight);
        //self.rightDashboardView.frame = CGRectMake(screenWidth*2, 0, screenWidth, screenHeight);
        //self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, screenWidth, self.scrollView.frame.size.height);
        //[self.scrollView setContentSize:CGSizeMake(screenWidth*3, self.scrollView.frame.size.height)];
    //}

}

- (void)viewDidLayoutSubviews
{
    DDLogInfo(@"");
    [super viewDidLayoutSubviews];
    //[self setScrollViewContentSize];
    
    CGRect frame = self.centerDashboardView.frame;
    //DDLogError(@"center dashboard frame: %@", NSStringFromCGRect(frame));
    
    if (!self.isIOS8AndAbove) {
        [self.scrollView scrollRectToVisible:frame animated:NO];
    }
    else{
        //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.scrollView setContentOffset:CGPointMake(self.centerFitnessWidthConstraints.constant, 0)];
        //}
        //else{
        //    [self.scrollView setContentOffset:CGPointMake(self.centerDashboardView.frame.size.width, 0)];
        //}
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dashboardSyncClick:(id)sender
{
    if(self.userDefaultsManager.isBlueToothOn) {
        [Flurry logEvent:DEVICE_SEARCH];
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            [self startSyncRModel];
        } else if(self.userDefaultsManager.watchModel == WatchModel_R420){
            [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
            [self startSyncR420Model];
        }else {
            [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
            [self startSyncCModel];
        }
    } else {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                     message:TURN_ON_BLUETOOTH
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
                                                            message:TURN_ON_BLUETOOTH
                                                           delegate:nil
                                                  cancelButtonTitle:BUTTON_TITLE_OK
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

#pragma mark - Start autosync

- (void)startAutoSync
{
    if (!self.isStillSyncing) {
        //[SFASyncProgressView progressView].delegate = self;
        //[SFASyncProgressView showWithMessage:LS_AUTO_SYNC_WATCH animate:YES showButton:NO];
        if(self.userDefaultsManager.isBlueToothOn) {
            if (self.userDefaultsManager.watchModel == WatchModel_R450) {
                [self startSyncRModel];
            } else if(self.userDefaultsManager.watchModel == WatchModel_R420){
                [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
                [self startSyncR420Model];
            } else {
                [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
                [self startSyncCModel];
            }
        } else {
            if (self.isIOS8AndAbove) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                         message:TURN_ON_BLUETOOTH
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
                                                                message:TURN_ON_BLUETOOTH
                                                               delegate:nil
                                                      cancelButtonTitle:BUTTON_TITLE_OK
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
        }

        /*
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            // [SFASalutronUpdateManager sharedInstance].managerDelegate = self;
            // [[SFASalutronUpdateManager sharedInstance] startUpdateNotificationStatusWithWatchModel:self.userDefaultsManager.watchModel notificationStatus:NO];
            // [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
            [self performSelector:@selector(startSyncRModel) withObject:nil afterDelay:5.0];
            
        } else {
            [self startSyncCModel];
        }
        */
    }
    
    //[[NSUserDefaults standardUserDefaults] setObject:@"Done" forKey:@"AutoSync"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Cloud sync value

- (void)setCloudSyncSwitchValue
{
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress];
    self.userDefaultsManager.cloudSyncEnabled = [deviceEntity.cloudSyncEnabled boolValue];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:LEFT_DASHBOARD_SEGUE_IDENTIFIER])
    {
        self.leftDashboard          = (SFADashboardViewController *) segue.destinationViewController;
        self.leftDashboard.delegate = self;
    }
    else if ([segue.identifier isEqualToString:CENTER_DASHBOARD_SEGUE_IDENTIFIER])
    {
        self.centerDashboard            = (SFADashboardViewController *) segue.destinationViewController;
        self.centerDashboard.delegate   = self;
    }
    else if ([segue.identifier isEqualToString:RIGHT_DASHBOARD_SEGUE_IDENTIFIER])
    {
        self.rightDashboard             = (SFADashboardViewController *) segue.destinationViewController;
        self.rightDashboard.delegate    = self;
    }
    else if ([segue.destinationViewController isKindOfClass:[SFAFitnessResultsScrollViewController class]])
    {
        if (self.dashBoardItem == self.dashboardPosition.caloriesRow)
        {
            [segue.destinationViewController setGraphType:SFAGraphTypeCalories];
        }
        else if (self.dashBoardItem == self.dashboardPosition.stepsRow)
        {
            [segue.destinationViewController setGraphType:SFAGraphTypeSteps];
        }
        else if (self.dashBoardItem == self.dashboardPosition.distanceRow)
        {
            [segue.destinationViewController setGraphType:SFAGraphTypeDistance];
        }
    }
    else if ([segue.identifier isEqualToString:ACTIGRAPHY_SEGUE_IDENTIFIER])
    {
        //SFAActigraphyScrollViewController *viewController = (SFAActigraphyScrollViewController *)segue.destinationViewController;
        
        //SFASlidingViewController *_slingidngViewController = (SFASlidingViewController *)self.parentViewController.parentViewController.parentViewController;
        //_viewController.isActigraphy                        = _slingidngViewController.isActigraphy;
    } else if ([segue.identifier isEqualToString:PAIR_SEGUE_IDENTIFIER]) {
        self.didCancel                                  = NO;
        self.pairViewController                         = (SFAPairViewController *)segue.destinationViewController;
        self.pairViewController.delegate                = self;
        self.pairViewController.watchModel              = self.userDefaultsManager.watchModel;
        self.pairViewController.showCancelSyncButton    = YES;
        
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            self.pairViewController.paired              = YES;
        } else {
            self.pairViewController.paired              = NO;
        }
        
        [self.leftDashboard hideTryAgainView];
        [self.centerDashboard hideTryAgainView];
        [self.rightDashboard hideTryAgainView];
        
        //SFAWatchManager *manager                = [SFAWatchManager sharedManager];
        //manager.autoSyncTriggered               = NO;
        
        
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:PAIR_SEGUE_IDENTIFIER]) {
        
        if(!self.bluetoothOn) {
            if (self.isIOS8AndAbove) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                         message:TURN_ON_BLUETOOTH
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
                                                                message:TURN_ON_BLUETOOTH
                                                               delegate:nil
                                                      cancelButtonTitle:BUTTON_TITLE_OK
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
            return NO;
        }

        
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            // Fix for bug #279
            //SFAWatchManager *manager                = [SFAWatchManager sharedManager];
            //manager.autoSyncTriggered               = NO;
            
            [self startSyncRModel];
            return NO;
        } else if (self.userDefaultsManager.watchModel == WatchModel_R420) {
            [self startSyncR420Model];
            return YES;
        } else{
            [self startSyncCModel];
            return YES;
        }
    }
    else if ([identifier isEqualToString:@"Cancel Sync"]) {
            return NO;
    }
     
    return YES;
}

#pragma mark - Start Sync

- (void)startSyncRModel
{
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    //[[SFASalutronUpdateManager sharedInstance] startUpdateNotificationStatusWithWatchModel:self.userDefaultsManager.watchModel notificationStatus:NO];

    self.salutronSync                              = [[SFASalutronSync alloc] init];
    self.salutronSync.delegate                     = self;
    self.salutronSync.selectedWatchModel           = WatchModel_R450;
    self.salutronSync.connectDevice                = NO;
    self.didCancel                                 = NO;
    //[SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:YES showButton:YES];
    
    /*[self.salutronSync startSync];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];*/
  
    self.salutronSync                              = [[SFASalutronSync alloc] init];
    self.salutronSync.delegate                     = self;
    self.salutronSync.selectedWatchModel           = WatchModel_R450;
    [self.salutronSync searchConnectedDevice];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startSyncConnectedRModel{
    self.salutronSync                              = [[SFASalutronSync alloc] init];
    self.salutronSync.delegate                     = self;
    self.salutronSync.selectedWatchModel           = WatchModel_R450;
    self.salutronSync.deviceFound                  = self.deviceFound;
    
    [SFASyncProgressView progressView].delegate = self;
    //[SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:YES showButton:YES];
    [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES onButtonClick:^{
        [self.salutronSync stopSync];
    }];
    
    [Flurry logEvent:DEVICE_RETRIEVE];
    [self.salutronSync startSync];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startSyncCModel
{
    self.salutronSyncC300.delegate = self;
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress];
    
    self.salutronSyncC300.updateTimeAndDate = self.userDefaultsManager.autoSyncTimeEnabled;
    
    [Flurry logEvent:DEVICE_RETRIEVE];
    [self.salutronSyncC300 startSyncWithDeviceEntity:deviceEntity watchModel:self.userDefaultsManager.watchModel];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startSyncR420Model
{
    self.salutronR420ModelSync.delegate = self;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    self.salutronR420ModelSync.delegate = self;
    self.salutronR420ModelSync.salutronSDK.delegate = self.salutronR420ModelSync;
    [self.salutronR420ModelSync searchDevice];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Server Sync

- (void)syncToServer
{
    DDLogInfo(@"");
    JDACoreData *coreData = [JDACoreData sharedManager];
    NSArray *devices = [coreData fetchEntityWithEntityName:DEVICE_ENTITY predicate:[NSPredicate predicateWithFormat:@"macAddress == %@", [[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]] limit:1];
    DeviceEntity *device = [DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress];//self.salutronSync.deviceEntity;//[devices firstObject];
	
    if ([devices count] > 0) {
        
        [SFASyncProgressView progressView].delegate = self;
        [SFASyncProgressView showWithMessage:LS_SYNC_TO_SERVER animate:YES showButton:YES onButtonClick:^{
            self.cancelSyncToCloudOperation = YES;
            [SFASyncProgressView hide];
            
            [self.syncToCloudOperation cancel];
            self.syncToCloudOperation = nil;
        }];
        
        //SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
		
        //get lastdaysynced (watch) and updatedsync (server)
        //get data from server starting updatedsync to present day
        //compare core data and retrieved data from server
        //check if there are core data that are not part of server response
        //upload these data
        
        /*[serverSyncManager restoreDeviceEntity:device
                                         startDateString:[NSDate dateToUTCString:device.lastDateSynced withFormat:API_DATE_FORMAT]
                                           endDateString:[NSDate dateToUTCString:[NSDate date] withFormat:API_DATE_FORMAT] success:^{
                                               
                                               -- UNCOMMENTED LINE [serverSyncManager syncDeviceEntity:device startDate:[NSDate UTCDateFromString:[device.lastDateSynced getDateString] withFormat:API_DATE_FORMAT] endDate:[NSDate UTCDateFromString:[[NSDate date] getDateString] withFormat:API_DATE_FORMAT] withSuccess:^(NSString *macAddress) {
            [self updateDataToServerWithDevice:device];
            //[self storeToServerWithMacAddress:device.macAddress];
        } failure:^(NSError *error) {
            if (!self.cancelSyncToCloudOperation){
                [self alertError:error];
            }
            [SFASyncProgressView hide];
            self.syncToCloudOperation       = nil;
            self.cancelSyncToCloudOperation = NO;
        }];*/

        
        SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
        [serverSyncManager getDeviceDataFromServerWithDevice:device userID:device.user.userID success:^(BOOL shouldRestoreFromServer) {
            
            if (shouldRestoreFromServer) {
                [self restoreDataFromServerWithDevice:device];
            }
            else{
                [self updateDataToServerWithDevice2:device];
//                if (self.userDefaultsManager.watchModel == WatchModel_R420){
//                    [self updateDataToServerWithDevice2:device];
//                }
//                else{
//                    [self updateDataToServerWithDevice:device];
//                }
            }
            
        } failure:^(NSError *error) {
            if (error.code == 1000) {
                [self updateDataToServerWithDevice2:device];
//                if (self.userDefaultsManager.watchModel == WatchModel_R420){
//                    [self updateDataToServerWithDevice2:device];
//                }
//                else{
//                   [self updateDataToServerWithDevice:device];
//                }
            }
            else{
                if (!self.cancelSyncToCloudOperation){
                    [self alertError:error];
                }
                [SFASyncProgressView hide];
                self.syncToCloudOperation       = nil;
                self.cancelSyncToCloudOperation = NO;
            }
        }];

        // [self restoreDataFromServerWithDevice:device];
       // [self updateDataToServerWithDevice:device];
        
        /*
		self.syncToCloudOperation = [serverSyncManager syncDeviceEntity:device startDate:[NSDate UTCDateFromString:[device.lastDateSynced getDateString] withFormat:API_DATE_FORMAT] endDate:[NSDate UTCDateFromString:[[NSDate date] getDateString] withFormat:API_DATE_FORMAT] withSuccess:^(NSString *macAddress) {
			[self storeToServerWithMacAddress:macAddress];
		} failure:^(NSError *error) {
			if (!self.cancelSyncToCloudOperation){
				[self alertError:error];
			}
			[SFASyncProgressView hide];
			self.syncToCloudOperation       = nil;
			self.cancelSyncToCloudOperation = NO;
		}];
         */
	}
}


- (void)restoreDataFromServerWithDevice:(DeviceEntity *)device{
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    //if ([device.modelNumber isEqualToNumber:@(WatchModel_R420)]) {
        [serverSyncManager restoreDeviceEntityAPIV2:device
                                startDateString:[NSDate dateToUTCString:device.lastDateSynced withFormat:API_DATE_FORMAT]
                                  endDateString:[NSDate dateToUTCString:[NSDate date] withFormat:API_DATE_FORMAT] success:^(NSDictionary *response) {
            NSString *bucketName = response[@"bucket"];
            NSString *folderName = response[@"uuid"];
            NSArray *filenames = response[@"files"];
            
            SFAAmazonServiceManager *amazonServiceManager = [SFAAmazonServiceManager sharedManager];
            amazonServiceManager.delegate = self;
                                      if (filenames.count > 0) {
                                          
                                          [amazonServiceManager downloadDataFromS3withBucketName:bucketName
                                                                                   andFilesNames:filenames
                                                                                   andFolderName:folderName
                                                                                 andDeviceEntity:device];
                                      }
                                      else{
                                          
                                          DDLogError(@"no files to download from s3, server response = %@", response);
                                          [SVProgressHUD dismiss];
                                          
                                          if (!self.cancelSyncToCloudOperation){
                                              [self alertWithTitle:ERROR_TITLE message:SERVER_ERROR_MESSAGE];
                                          }
                                          [SFASyncProgressView hide];
                                          self.syncToCloudOperation       = nil;
                                          self.cancelSyncToCloudOperation = NO;
                                      }
            
        } failure:^(NSError *error) {
            if (!self.cancelSyncToCloudOperation){
                [self alertError:error];
            }
            [SFASyncProgressView hide];
            self.syncToCloudOperation       = nil;
            self.cancelSyncToCloudOperation = NO;
        }];
//    }
//    else{
//        [serverSyncManager restoreDeviceEntity:device
//                               startDateString:[NSDate dateToUTCString:device.lastDateSynced withFormat:API_DATE_FORMAT]
//                                 endDateString:[NSDate dateToUTCString:[NSDate date] withFormat:API_DATE_FORMAT] success:^{
//                                     [self storeToServerWithMacAddress:device.macAddress];
//                                 } failure:^(NSError *error) {
//                                     if (!self.cancelSyncToCloudOperation){
//                                         [self alertError:error];
//                                     }
//                                     [SFASyncProgressView hide];
//                                     self.syncToCloudOperation       = nil;
//                                     self.cancelSyncToCloudOperation = NO;
//                                 }];
//    }
}



- (void)updateDataToServerWithDevice2:(DeviceEntity *)device{
    self.device = device;
    SFAAmazonServiceManager *amazonServiceManager = [SFAAmazonServiceManager sharedManager];
    amazonServiceManager.delegate = self;
    NSArray *daysOfData = [[SFAServerSyncManager sharedManager] jsonStringWithDeviceEntityForMultipleDays:device];
    if(daysOfData.count > 0){
        [amazonServiceManager uploadArrayOfDataToS3:daysOfData];
    }
    else{
        DDLogError(@"no data to upload to s3, days of data count = %lu", (unsigned long)daysOfData.count);
        [SVProgressHUD dismiss];
        
        if (!self.cancelSyncToCloudOperation){
            [self alertWithTitle:ERROR_TITLE message:SERVER_ERROR_MESSAGE];
        }
        [SFASyncProgressView hide];
        self.syncToCloudOperation       = nil;
        self.cancelSyncToCloudOperation = NO;
    }
}


- (void)amazonServiceUploadFinishedWithParameters:(NSDictionary *)parameters{
    
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    
    self.syncToCloudOperation = [serverSyncManager syncDeviceEntityWithParametersAPIV2:parameters withSuccess:^(NSString *macAddress) {
        //[self storeToServerWithMacAddress:macAddress];
        NSDate *date                    = [NSDate date];
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:data forKey:macAddress];
        [SFASyncProgressView hide];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
        // [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
        // if (self.userDefaultsManager.notificationStatus == YES) {
        //     [[SFASalutronUpdateManager sharedInstance] startUpdateNotificationStatusWithWatchModel:self.userDefaultsManager.watchModel notificationStatus:YES];
        // }
        
        
        //[SVProgressHUD showSuccessWithStatus:LS_SYNC_SERVER_SUCCESS];
        
        [SFASyncProgressView showWithMessage:LS_SYNC_SERVER_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
            
        }];//showButton:YES dismiss:NO];
        
        self.syncToCloudOperation       = nil;
        self.cancelSyncToCloudOperation = NO;
        [StatisticalDataHeaderEntity setAllIsSyncedToServer:YES forDeviceEntity:self.device];
        [WorkoutInfoEntity setAllIsSyncedToServer:YES forDeviceEntity:self.device];
        [SleepDatabaseEntity setAllIsSyncedToServer:YES forDeviceEntity:self.device];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (!self.cancelSyncToCloudOperation){
            [self alertError:error];
        }
        [SFASyncProgressView hide];
        self.syncToCloudOperation       = nil;
        self.cancelSyncToCloudOperation = NO;
    }];
}

- (void)amazonServiceUploadFailedWithError:(NSError *)error{
    if (!self.cancelSyncToCloudOperation){
        [self alertError:error];
    }
    [SFASyncProgressView hide];
    self.syncToCloudOperation       = nil;
    self.cancelSyncToCloudOperation = NO;
}

- (void)amazonServiceDownloadFinishedWithParameters:(NSDictionary *)parameters{
    NSDate *date                    = [NSDate date];
    NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    
    DeviceEntity *device = [DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress];
    [userDefaults setObject:data forKey:device.macAddress];
    [SFASyncProgressView hide];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    // [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
    // if (self.userDefaultsManager.notificationStatus == YES) {
    //     [[SFASalutronUpdateManager sharedInstance] startUpdateNotificationStatusWithWatchModel:self.userDefaultsManager.watchModel notificationStatus:YES];
    // }
    
    
    //[SVProgressHUD showSuccessWithStatus:LS_SYNC_SERVER_SUCCESS];
    
    [SFASyncProgressView showWithMessage:LS_SYNC_SERVER_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
        
    }];//showButton:YES dismiss:NO];
    
    self.syncToCloudOperation       = nil;
    self.cancelSyncToCloudOperation = NO;
}

- (void)amazonServiceDownloadFailedWithError:(NSError *)error{
    if (!self.cancelSyncToCloudOperation){
        [self alertError:error];
    }
    [SFASyncProgressView hide];
    self.syncToCloudOperation       = nil;
    self.cancelSyncToCloudOperation = NO;
}

- (void)amazonServiceProgress:(int)progress{
    //[[SFASyncProgressView progressView] setStatus:[NSString stringWithFormat:@"%@ (%i%@)", LS_SYNC_TO_SERVER, progress, @"%"]];
}


- (void)updateDataToServerWithDevice:(DeviceEntity *)device{
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    self.syncToCloudOperation = [serverSyncManager syncDeviceEntity:device startDate:[NSDate UTCDateFromString:[device.lastDateSynced getDateString] withFormat:API_DATE_FORMAT] endDate:[NSDate UTCDateFromString:[[NSDate date] getDateString] withFormat:API_DATE_FORMAT] withSuccess:^(NSString *macAddress) {
        [self storeToServerWithMacAddress:macAddress];
		[StatisticalDataHeaderEntity setAllIsSyncedToServer:YES forDeviceEntity:device];
		[WorkoutInfoEntity setAllIsSyncedToServer:YES forDeviceEntity:device];
		[SleepDatabaseEntity setAllIsSyncedToServer:YES forDeviceEntity:device];
		
    } failure:^(NSError *error) {
        if (!self.cancelSyncToCloudOperation){
            [self alertError:error];
        }
        [SFASyncProgressView hide];
        self.syncToCloudOperation       = nil;
        self.cancelSyncToCloudOperation = NO;
    }];
}

- (void)storeToServerWithMacAddress:(NSString *)macAddress
{
    DDLogInfo(@"");
    JDACoreData *coreData = [JDACoreData sharedManager];
    NSArray *devices = [coreData fetchEntityWithEntityName:DEVICE_ENTITY predicate:[NSPredicate predicateWithFormat:@"macAddress == %@ AND user.userID == %@", [[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID] limit:1];
    
    if ([devices count] > 0) {
        
        DeviceEntity *device = [devices objectAtIndex:0];
        
        SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
        
        [serverSyncManager storeWithMacAddress:macAddress success:^{
            
            NSDate *date                    = [NSDate date];
            NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
            NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:data forKey:device.macAddress];
            [SFASyncProgressView hide];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
           // [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
           // if (self.userDefaultsManager.notificationStatus == YES) {
           //     [[SFASalutronUpdateManager sharedInstance] startUpdateNotificationStatusWithWatchModel:self.userDefaultsManager.watchModel notificationStatus:YES];
           // }


            //[SVProgressHUD showSuccessWithStatus:LS_SYNC_SERVER_SUCCESS];
            
            [SFASyncProgressView showWithMessage:LS_SYNC_SERVER_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
                
            }];//showButton:YES dismiss:NO];
            
            self.syncToCloudOperation       = nil;
            self.cancelSyncToCloudOperation = NO;
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            if (!self.cancelSyncToCloudOperation){
                [self alertError:error];
            }
            [SFASyncProgressView hide];
            self.syncToCloudOperation       = nil;
            self.cancelSyncToCloudOperation = NO;
        }];
    }
}

#pragma mark - Cancel sync

- (IBAction)cancelSyncing:(UIStoryboardSegue *)segue
{
    DDLogInfo(@"");
    
    if ([segue.sourceViewController isKindOfClass:[SFAPairViewController class]]) {
        self.didCancel = YES;
        self.isStillSyncing = NO;
        
        [SFASyncProgressView hide];
        
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            //[self didDeviceDisconnected:NO];
            self.didCancel = YES;
            //[self cancelSyncing:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
        }
        else {
            [self.salutronSyncC300 disconnectWatch];
        }
    }
    
    if (self.userDefaultsManager.watchModel != WatchModel_R450) {
        [self.salutronSyncC300.salutronSDK commDone];
        [self.salutronSyncC300.salutronSDK disconnectDevice];
        [self.salutronSync.salutronSDK disconnectDevice];
    }
    
    self.salutronSyncC300.delegate = nil;
    self.salutronSyncC300.salutronSDK.delegate = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
   // [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
 //   if (self.userDefaultsManager.notificationStatus == YES) {
 //       [[SFASalutronUpdateManager sharedInstance] startUpdateNotificationStatusWithWatchModel:self.userDefaultsManager.watchModel notificationStatus:YES];
 //   }
    
    [[SFAServerSyncManager sharedManager] cancelOperation];
    [[SFAServerManager sharedManager] cancelOperation];
    [[SFAAmazonServiceManager sharedManager] cancelOperation];
}

- (void)cancelOnTimeoutClick
{
    [self.centerDashboard hideTryAgainView];
    [self.centerDashboard hideTryAgainView];
}

- (void)tryAgainOnTimeoutClick
{
    if(self.userDefaultsManager.isBlueToothOn) {
        [Flurry logEvent:DEVICE_SEARCH];
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            [self startSyncRModel];
        } else if(self.userDefaultsManager.watchModel == WatchModel_R420){
            [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
            [self startSyncR420Model];
        }
        else {
            [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
            [self startSyncCModel];
        }
    } else {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                     message:TURN_ON_BLUETOOTH
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
                                                            message:TURN_ON_BLUETOOTH
                                                           delegate:nil
                                                  cancelButtonTitle:BUTTON_TITLE_OK
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    [self.centerDashboard hideTryAgainView];
}

#pragma mark - Salutron sync delegate

- (void)didDeviceConnected
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (self.isStillSyncing) {
        
        [SFASyncProgressView progressView].delegate = self;
        [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES onButtonClick:^{
            [self.salutronSync stopSync];
        }];
    }
    
    //[self.centerDashboard.statisticalDataHeader deleteObject];
    //[SFASyncProgressView showWithMessage:LS_SYNCING animate:YES showButton:NO];
    //[SVProgressHUD showWithStatus:@"Begin sync" maskType:SVProgressHUDMaskTypeClear];
}

- (void)didPairWatch
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:YES showButton:YES];
    //[SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES onButtonClick:^{
        [self.salutronSync stopSync];
    }];
    
    if (self.isStillSyncing) {
        [SFASyncProgressView progressView].delegate = self;
        [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES onButtonClick:^{
            [self.salutronSync stopSync];
        }];
    }
}

- (void)didSyncStarted
{
    DDLogInfo(@"");
    self.didCancel = NO;
    self.isStillSyncing = YES;
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    [SFASyncProgressView hide];
    
    [SFASyncProgressView progressView].delegate = self;
    [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES onButtonClick:^{
        [self.salutronSync stopSync];
    }];
}

- (void)didDiscoverTimeout
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
   
    if (!self.didCancel) {
        [SFASyncProgressView hide];
        /*[SFASyncProgressView showWithMessage:SYNC_TIMEOUT animate:NO showOKButton:YES onButtonClick:^{
            [SFASyncProgressView hide];
        }];*/
         if ([self.centerDashboard respondsToSelector:@selector(showTryAgainViewWithTarget:cancelSelector:tryAgainSelector:)] && !self.didCancel) {
        [self.centerDashboard showTryAgainViewWithTarget:self
                                          cancelSelector:@selector(cancelOnTimeoutClick)
                                        tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
         }
        
    }
    else {
        
    }
    //[SVProgressHUD showErrorWithStatus:SYNC_NOT_FOUND_MESSAGE];
}

- (void)didDiscoverTimeoutWithDiscoveredDevices:(NSArray *)discoveredDevices
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    [self didDiscoverTimeout];
}

- (void)didDisconnectDevice
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (self.userDefaultsManager.watchModel == WatchModel_R450) {
        [SFASyncProgressView hide];
        //[SFASyncProgressView showWithMessage:SYNC_NOT_FOUND_MESSAGE animate:NO showButton:NO dismiss:YES];
         if ([self.centerDashboard respondsToSelector:@selector(showTryAgainViewWithTarget:cancelSelector:tryAgainSelector:)] && !self.didCancel) {
        [self.centerDashboard showTryAgainViewWithTarget:self
                                          cancelSelector:@selector(cancelOnTimeoutClick)
                                        tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
         }
    }
}

- (void)didRaiseError{
    [self didDeviceDisconnected:NO];
}

- (void)didUpdateFinish
{
    
    [self.centerDashboard.tableView reloadData];
    [self setContentsWithSelectedDate:[NSDate date]];
    self.isStillSyncing = NO;
    [SFASyncProgressView progressView].delegate = self;
    
    if (self.userDefaultsManager.cloudSyncEnabled) {
    //    [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showButton:NO dismiss:YES];
    }
    else{
        [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
            
        }];//showButton:YES dismiss:NO];
    }
    
    //[SVProgressHUD showSuccessWithStatus:SYNC_SUCCESS];
    
    if (self.userDefaultsManager.watchModel == WatchModel_Zone_C410 ||
        self.userDefaultsManager.watchModel == WatchModel_R420 ||
        self.userDefaultsManager.watchModel == WatchModel_Move_C300 ||
        self.userDefaultsManager.watchModel == WatchModel_Move_C300_Android||
        self.userDefaultsManager.watchModel == WatchModel_Core_C200)
        [self.salutronSyncC300.salutronSDK commDone];
    
    if (self.userDefaultsManager.cloudSyncEnabled) {
        //[self syncToServer];
        [self performSelector:@selector(syncToServer) withObject:nil afterDelay:1];
    }
    
    //[self setContentsWithSelectedDate:self.centerDashboard.date];
    
    self.userDefaultsManager.lastSyncedDate = [NSDate date];
    
    [self.calendarController reloadDatesWithData];

}

- (void)didSyncFinished:(DeviceEntity *)deviceEntity
{
    DDLogInfo(@"");
    
    [self setContentsWithSelectedDate:[NSDate date]];
    [self.centerDashboard.tableView reloadData];
    
    self.isStillSyncing = NO;
    [SFASyncProgressView progressView].delegate = self;
    if (self.userDefaultsManager.cloudSyncEnabled) {
        [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showButton:NO dismiss:YES];
    }
    else{
        [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
            
        }];//showButton:NO dismiss:YES];
    }
    //[SVProgressHUD showSuccessWithStatus:SYNC_SUCCESS];
    
    if (self.userDefaultsManager.watchModel == WatchModel_Zone_C410 ||
        self.userDefaultsManager.watchModel == WatchModel_R420 ||
        self.userDefaultsManager.watchModel == WatchModel_Move_C300 ||
        self.userDefaultsManager.watchModel == WatchModel_Move_C300_Android ||
        self.userDefaultsManager.watchModel == WatchModel_Core_C200)
        [self.salutronSyncC300.salutronSDK commDone];
    //[self syncToServer];
    [self performSelector:@selector(syncToServer) withObject:nil afterDelay:1];
    
    //[self setContentsWithSelectedDate:self.centerDashboard.date];
    
    self.userDefaultsManager.lastSyncedDate = [NSDate date];
    
    [self.calendarController reloadDatesWithData];
    self.salutronSync.delegate = nil;
    
    //    [self syncToServer];
}

- (void)didChecksumError
{
    [self didDeviceDisconnected:NO];
}

- (void)didDeviceDisconnected:(BOOL)isSyncFinished
{
    DDLogInfo(@"");
    
    if (self.userDefaultsManager.watchModel != WatchModel_R450) {
        [self setContentsWithSelectedDate:[NSDate date]];
    }
    [self.pairViewController dismissViewControllerAnimated:YES completion:NULL];
    [SFASettingsPromptView hide];
    
    if (isSyncFinished && !self.didCancel) {
        
        
        //if user select watch settings in prompt
        if (self.userDefaultsManager.cloudSyncEnabled) {
            [SFASyncProgressView progressView].delegate = self;
            [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showButton:NO dismiss:YES];
            //[self syncToServer];
            [self performSelector:@selector(syncToServer) withObject:nil afterDelay:1];
        }
        else {
            [SFASyncProgressView progressView].delegate = self;
            [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
            
            }];//showButton:NO dismiss:YES];
            [self.salutronSync stopSync];
        }
    }
    else {
        [self.salutronSync stopSync];
        [SFASyncProgressView hide];
        //[SFASyncProgressView showWithMessage:DEVICE_DISCONNECTED animate:NO showButton:NO dismiss:YES];
        /*
        [SFASyncProgressView showWithMessage:DEVICE_DISCONNECTED animate:NO showOKButton:YES onButtonClick:^{
            [SVProgressHUD dismiss];
            [SFASyncProgressView hide];
        }];
         */
         if ([self.centerDashboard respondsToSelector:@selector(showTryAgainViewWithTarget:cancelSelector:tryAgainSelector:)] && !self.didCancel) {
        [self.centerDashboard showTryAgainViewWithTarget:self
                                          cancelSelector:@selector(cancelOnTimeoutClick)
                                        tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
         }
    }
    
    self.isStillSyncing     = NO;
    self.didCancel          = NO;
}



- (void)didSyncFinished:(DeviceEntity *)deviceEntity profileUpdated:(BOOL)profileUpdated
{
    DDLogInfo(@"");
    
    [self setContentsWithSelectedDate:[NSDate date]];
    [self.centerDashboard.tableView reloadData];
    
    self.isStillSyncing = NO;
    //check if User enables sync to cloud, if not display "sync success"
    
    if (!self.userDefaultsManager.cloudSyncEnabled){
        [SFASyncProgressView progressView].delegate = self;
        [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
            
        }];//showButton:NO dismiss:YES];
    }
    
    if ((self.userDefaultsManager.watchModel == WatchModel_Zone_C410 ||
         self.userDefaultsManager.watchModel == WatchModel_R420 ||
         self.userDefaultsManager.watchModel == WatchModel_Move_C300 ||
         self.userDefaultsManager.watchModel == WatchModel_Move_C300_Android ||
         self.userDefaultsManager.watchModel == WatchModel_Core_C200) && profileUpdated) {
        [self.salutronSyncC300 disconnectWatch];
    }
    
    //[self setContentsWithSelectedDate:self.centerDashboard.date];
    
    self.userDefaultsManager.lastSyncedDate = [NSDate date];
    
    [self.calendarController reloadDatesWithData];
    self.salutronSync.delegate = nil;
    
    if (self.userDefaultsManager.cloudSyncEnabled){
        [self performSelector:@selector(syncToServer) withObject:nil afterDelay:1];
    }
}

- (void)didChangeSettings
{
        [SFASettingsPromptView settingsPromptView].delegate = self;
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
        [self.centerDashboard hideTryAgainView];
        [SFASettingsPromptView show];
    }
}

- (void)didSaveSettings
{
    DDLogInfo(@"");
    self.isStillSyncing = NO;
    
    //    [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showButton:NO dismiss:YES];
    //[SVProgressHUD showSuccessWithStatus:SYNC_SUCCESS];
}

- (void)didSearchConnectedWatch:(BOOL)found
{
    if (!self.didCancel) {
        self.deviceFound = found;
        if (found) {
            [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
            [self startSyncConnectedRModel];
        } else {
            if (!self.pairViewController.isViewLoaded && !self.pairViewController.view.window) {
                [SFASyncProgressView hide];
                [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
            }
            [self.salutronSync startSync];
        }
    }
}

- (void)didRetrieveDeviceFromSearching
{
    //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:NO showButton:YES];
    [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES onButtonClick:^{
        [self.salutronSync stopSync];
    }];
}

#pragma mark - Autorotate methods

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) shouldAutorotate
{
    return NO;
}

- (void)disableAutorotate
{
    SFASlidingViewController *_viewController = (SFASlidingViewController *)self.parentViewController.parentViewController.parentViewController;
    _viewController.shouldRotate = NO;
    
    if (_viewController.isActigraphy)
        [self performSegueWithIdentifier:ACTIGRAPHY_SEGUE_IDENTIFIER sender:self];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    [self didScrollToDashboardAtIndex:index];
}

#pragma mark - SFACalendarController Methods

- (void)calendarController:(SFAMainViewController *)calendarController didSelectDate:(NSDate *)date
{
    self.userDefaultsManager.selectedDateFromCalendar = date;
    [self setContentsWithSelectedDate:date];
}

#pragma mark - SFADashboardDelegate Methods

- (void)dashboardViewController:(SFADashboardViewController *)viewController didSelectDashboardItem:(SFADashboardItem)dashboardItem
{
    if(dashboardItem == self.dashboardPosition.bpmRow)
    {
        if (self.userDefaultsManager.watchModel == WatchModel_R420) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Graphs" bundle:nil];
            SFAContinuousHRPageViewController *hrPageVC = [storyboard instantiateViewControllerWithIdentifier:@"SFAContinuousHRPageViewController"];
            [self.navigationController pushViewController:hrPageVC animated:YES];
        }
        else{
            [self performSegueWithIdentifier:HEART_RATE_SEGUE_IDENTIFIER sender:self];
        }
    }
    else if (dashboardItem == self.dashboardPosition.caloriesRow ||
             dashboardItem == self.dashboardPosition.stepsRow ||
             dashboardItem == self.dashboardPosition.distanceRow)
    {
        self.dashBoardItem  = dashboardItem;
        [self performSegueWithIdentifier:FITNESS_RESULTS_SEGUE_IDENTIFIER sender:self];
    }
    else if (dashboardItem == self.dashboardPosition.actigraphyRow) {
        [self performSegueWithIdentifier:ACTIGRAPHY_SEGUE_IDENTIFIER sender:self];
    }
    else if (dashboardItem == self.dashboardPosition.sleepRow)
    {
        [self performSegueWithIdentifier:SLEEP_LOGS_SEGUE_IDENTIFIER sender:self];
    }
    else if (dashboardItem == self.dashboardPosition.workoutRow)
    {
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            [self performSegueWithIdentifier:WORKOUT_GRAPH_SEGUE_IDENTIFIER sender:self];
        }
        else if(self.userDefaultsManager.watchModel == WatchModel_R420){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Graphs" bundle:nil];
            SFAR420WorkoutPageViewController *hrPageVC = [storyboard instantiateViewControllerWithIdentifier:@"SFAR420WorkoutPageViewController"];
            [self.navigationController pushViewController:hrPageVC animated:YES];
        }
        else{
            [self performSegueWithIdentifier:WORKOUT_LIST_SEGUE_IDENTIFIER sender:self];
        }
    }
    else if (dashboardItem == self.dashboardPosition.lightPlotRow){
        [self performSegueWithIdentifier:LIGHT_PLOT_SEGUE_IDENTIFIER sender:self];
    }
}

- (void)didUpdateDashboardPositionInDashboardViewController:(SFADashboardViewController *)viewController
{
    [self.leftDashboard.tableView reloadData];
    [self.centerDashboard.tableView reloadData];
    [self.rightDashboard.tableView reloadData];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //    WatchModel _watchModel  = [[[NSUserDefaults standardUserDefaults] objectForKey:CONNECTED_WATCH_MODEL] integerValue];
    switch (buttonIndex)
    {
        case 0: {
            /*[self.salutronSyncC300 startSyncWithWatchModel:_watchModel];
             [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:_watchModel]) animate:YES showButton:YES];
             //[SVProgressHUD showWithStatus:SYNC_SEARCH([self watchModelStringForWatchModel:_watchModel]) maskType:SVProgressHUDMaskTypeClear];
             */
            
            SFAPairViewController *pairViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAPairViewController"];
            [self.navigationController pushViewController:pairViewController animated:YES];
            break;
        }
        case 1:
            /*[self.centerDashboard.statisticalDataHeader deleteObject];
             [self setContentsWithSelectedDate:self.centerDashboard.date];
             */
            [self.centerDashboard.tableView reloadData];
            [self syncToServer];
            break;
        default:
            break;
    }
}

#pragma mark - IBAction Methods

- (IBAction)menuButtonPressed:(UIBarButtonItem *)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)syncButtonPressed:(id)sender
{
    DDLogInfo(@"");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:BUTTON_TITLE_CANCEL destructiveButtonTitle: nil otherButtonTitles:@"ReSync", LS_SYNC_SERVER, nil];
    
    [actionSheet showInView:self.view.superview];
}

- (IBAction)buttonOptionsTouchedUp:(id)sender
{
    DDLogInfo(@"");
    /*UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
     delegate:self
     cancelButtonTitle:BUTTON_TITLE_CANCEL
     destructiveButtonTitle:nil
     otherButtonTitles:@"ReSync", BUTTON_TITLE_DELETE, nil];
     [actionSheet showInView:self.view.superview];
     
     WatchModel _watchModel  = [[[NSUserDefaults standardUserDefaults] objectForKey:CONNECTED_WATCH_MODEL] integerValue];
     [_salutronSyncC300 startSyncWithWatchModel:_watchModel];
     [SVProgressHUD showWithStatus:@"Searching for device" maskType:SVProgressHUDMaskTypeClear];
     
     if(!_bluetoothOn) {
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
     message:TURN_ON_BLUETOOTH
     delegate:nil
     cancelButtonTitle:BUTTON_TITLE_OK
     otherButtonTitles:nil, nil];
     [alert show];
     }*/
    
    /*NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
     WatchModel watchModel           = [userDefaults integerForKey:CONNECTED_WATCH_MODEL];
     NSString *model                 = [self watchModelStringForWatchModel:watchModel];
     BOOL isAutoSync                 = [self isAutoSyncForWatchModel:watchModel];
     UIAlertView *alertView          = [[UIAlertView alloc] initWithTitle:UPDATE_ALERT_TITLE
     message:UPDATE_ALERT_MESSAGE(model, isAutoSync)
     delegate:self
     cancelButtonTitle:BUTTON_TITLE_CANCEL
     otherButtonTitles:BUTTON_TITLE_CONTINUE, nil];
     
     [alertView show];*/
}

#pragma mark - UIAlertView methods

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
    DDLogInfo(@"");
    DDLogInfo(@"error title: %@ -  %@", error, title);
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
    [self alertWithTitle:title message:errorMessage];
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message
{
    DDLogInfo(@"");
    if (self.isIOS8AndAbove) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:BUTTON_TITLE_OK, nil];
        
        
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DDLogInfo(@"");
    if (alertView.tag == 200) {
        if (buttonIndex == 1) {
            [self saveDataToHealthStoreWithRequestPermission];
        }
        else{
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"HealthKitEnabled"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    /*if (alertView.tag == 1000) {
     if (buttonIndex == 0) {
     [self.salutronSyncC300 useAppSettings];
     
     } else if (buttonIndex == 1) {
     [self.salutronSyncC300 useWatchSettings];
     }
     
     return;
     }
     
     if (buttonIndex == 1)
     {
     SFASalutronFitnessAppDelegate *appDelegate = (SFASalutronFitnessAppDelegate *)[UIApplication sharedApplication].delegate;
     NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:DEVICE_ENTITY];
     NSString *macAddress = [[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS];
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"macAddress == %@", macAddress];
     fetchRequest.predicate = predicate;
     NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil];
     DeviceEntity *deviceEntity = nil;
     
     if(results.count > 0) {
     deviceEntity = (DeviceEntity *)[results firstObject];
     }
     
     WatchModel _watchModel  = [[[NSUserDefaults standardUserDefaults] objectForKey:CONNECTED_WATCH_MODEL] integerValue];
     self.salutronSyncC300.updateTimeAndDate = YES;
     //[self.salutronSyncC300 startSyncWithWatchModel:_watchModel];
     [self.salutronSyncC300 startSyncWithDeviceEntity:deviceEntity watchModel:_watchModel];
     [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:_watchModel]) animate:YES showButton:YES];
     //[SVProgressHUD showWithStatus:SYNC_SEARCH([self watchModelStringForWatchModel:_watchModel]) maskType:SVProgressHUDMaskTypeClear];
     }*/
    if (buttonIndex == 0) {
        
    }
    else {
        
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            _bluetoothOn = NO;
            break;
        case CBCentralManagerStatePoweredOn:
            _bluetoothOn = YES;
            break;
        default:
            break;
    }
    self.userDefaultsManager.bluetoothOn = _bluetoothOn;
}

#pragma mark - SFAPairViewControllerDelegate Methods

- (void)didPressContinueInPairViewController:(SFAPairViewController *)viewController
{
    DDLogInfo(@"");
    SFASalutronFitnessAppDelegate *appDelegate = (SFASalutronFitnessAppDelegate *)[UIApplication sharedApplication].delegate;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:DEVICE_ENTITY];
    NSString *macAddress = self.userDefaultsManager.macAddress;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"macAddress == %@", macAddress];
    fetchRequest.predicate = predicate;
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    DeviceEntity *deviceEntity = nil;
    
    if(results.count > 0) {
        deviceEntity = (DeviceEntity *)[results firstObject];
    }
    
    if (self.userDefaultsManager.watchModel == WatchModel_R450) {
        [self startSyncRModel];
    } else if(self.userDefaultsManager.watchModel == WatchModel_R420){
        [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
        [self startSyncR420Model];
    }else{
        [self startSyncCModel];
    }
}

- (void)didPressCancelInPairViewController:(SFAPairViewController *)viewController
{
    //self.salutronSync.delegate = nil;
    self.salutronSyncC300.delegate = nil;
    self.didCancel = YES;
}

#pragma mark - SFASyncProgressViewDelegate Methods

- (void)didPressButtonOnProgressView:(SFASyncProgressView *)progressView
{
    DDLogInfo(@"");
    
    self.didCancel = YES;
    [SFASyncProgressView hide];
    [self cancelSyncing:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
  //  [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
 //   if (self.userDefaultsManager.notificationStatus == YES) {
//        [[SFASalutronUpdateManager sharedInstance] startUpdateNotificationStatusWithWatchModel:self.userDefaultsManager.watchModel notificationStatus:YES];
  //  }


    
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
    if ([self.salutronSyncC300.salutronSDK getConnectedDeviceDetail].peripheral.state == CBPeripheralStateDisconnected){
        [SFASyncProgressView hide];
        [SFASyncProgressView progressView].delegate = self;
        [SFASyncProgressView showWithMessage:LS_SYNC_FAILED animate:NO showButton:NO dismiss:YES];
    }else{
        
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            [self.salutronSync useAppSettingsWithDelegate:self];
        } else if(self.userDefaultsManager.watchModel == WatchModel_R420) {
            [self.salutronR420ModelSync useAppSettingsWithDelegate:self];
        } else {
            [self.salutronSyncC300 useAppSettings];
        }
    }
}

- (void)didPressWatchButtonOnSettingsPromptView:(SFASettingsPromptView *)view
{
    DDLogInfo(@"");
    /*if (!self.userDefaultsManager.promptChangeSettings) {
        self.userDefaultsManager.syncOption = SyncOptionWatch;
    }
    */
    if ([self.salutronSyncC300.salutronSDK getConnectedDeviceDetail].peripheral.state == CBPeripheralStateDisconnected){
        [SFASyncProgressView hide];
        [SFASyncProgressView progressView].delegate = self;
        [SFASyncProgressView showWithMessage:LS_SYNC_FAILED animate:NO showButton:NO dismiss:YES];
    }else{
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            [self.salutronSync useWatchSettingsWithDelegate:self];
        } else if(self.userDefaultsManager.watchModel == WatchModel_R420) {
            [self.salutronR420ModelSync useWatchSettingsWithDelegate:self];
        } else {
            [self.salutronSyncC300 useWatchSettings];
        }
    }
}

#pragma mark - Other methods

- (void)initializeObjects
{
    DDLogInfo(@"");
    // Initial Dashboard Data
    self.calendarController.selectedDate = [NSDate date];
    
    //_salutronSyncC300           = [[SFASalutronSync alloc] initWithManagedObjectContext:[JDACoreData sharedManager].context];
    //_salutronSyncC300.delegate  = self;
    self.dashboardPosition      = [[SFADashboardCellPositionHelper alloc] init];
    
    if (LANGUAGE_IS_FRENCH && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        UILabel* tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
        tlabel.text = self.navigationItem.title;
        tlabel.textColor = [UIColor whiteColor];
        tlabel.textAlignment = NSTextAlignmentCenter;
        tlabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 11.5];
        self.navigationItem.titleView = tlabel;
    }
    
    if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]){
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"InitialWatchToAppSync"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"InitialWatchToAppSync"] isEqual:@(1)]) {
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HealthKitEnabled"]) {
                [self saveDataToHealthStore];
            }
            else{
                if (self.isIOS8AndAbove) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                             message:HEALTHAPP_ACCESS_MESSAGE
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *noAction = [UIAlertAction
                                               actionWithTitle:BUTTON_TITLE_NO
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"HealthKitEnabled"];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                               }];
                    UIAlertAction *continueAction = [UIAlertAction
                                               actionWithTitle:BUTTON_TITLE_CONTINUE
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   [self saveDataToHealthStoreWithRequestPermission];
                                               }];
                    
                    [alertController addAction:noAction];
                    [alertController addAction:continueAction];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:HEALTHAPP_ACCESS_MESSAGE
                                                                   delegate:nil
                                                          cancelButtonTitle:BUTTON_TITLE_NO
                                                          otherButtonTitles:BUTTON_TITLE_CONTINUE, nil];
                    alert.tag =  200;
                    alert.delegate = self;
                    [alert show];
                }
            }
        }
    }
}

- (void)didScrollToDashboardAtIndex:(NSInteger)index
{
    DDLogInfo(@"");
    if (index == 1)
    {
        return;
    }
    
    /*SFADashboardViewController *viewController  = index == 0 ? self.leftDashboard : self.rightDashboard;
     UIView *view                                = index == 0 ? self.leftDashboardView : self.rightDashboardView;
     
     [viewController.view removeFromSuperview];
     [self.centerDashboard.view removeFromSuperview];
     [view addSubview:self.centerDashboard.view];
     [self.centerDashboardView addSubview:viewController.view];
     
     self.leftDashboard      = index == 0 ? self.centerDashboard : self.leftDashboard;
     self.rightDashboard     = index == 2 ? self.centerDashboard : self.rightDashboard;
     self.centerDashboard    = viewController;*/
    
    NSDate *date = index == 0 ? self.calendarController.previousDate : self.calendarController.nextDate;
    
    [self setContentsWithSelectedDate:date];
    [self.scrollView scrollRectToVisible:self.centerDashboardView.frame animated:NO];
}

- (void)setContentsWithSelectedDate:(NSDate *)selectedDate
{
    NSDate *yesterday                       = [selectedDate dateByAddingTimeInterval:-DAY_SECONDS];
    NSDate *tomorrow                        = [selectedDate dateByAddingTimeInterval:DAY_SECONDS];
    
    self.calendarController.selectedDate    = selectedDate;
    
    [self.leftDashboard setContentsWithDate:yesterday];
    [self.centerDashboard setContentsWithDate:selectedDate];
    [self.rightDashboard setContentsWithDate:tomorrow];
    
    //[self setScrollViewContentSize];
    [self.centerDashboard.tableView reloadData];
}

- (void)setScrollViewContentSize
{
    DDLogInfo(@"");
    CGSize size                 = self.scrollView.frame.size;
    size.width                  *= (self.calendarController.selectedDate.isToday ? 2 : 3);
    self.scrollView.contentSize = size;
}

- (NSDictionary *)responseStringToDictionary:(NSString *)responseString
{
    NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *stringComponents = [responseString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{}:,"]];
    for (int i = 0; i < [stringComponents count]; i=i+2) {
        if ([[stringComponents objectAtIndex:i] isEqualToString:@""] && i+2< [stringComponents count])
            i++;
        if (i+2 > [stringComponents count])
            break;
        [responseDictionary setObject:[stringComponents objectAtIndex:i+1] forKey:[stringComponents objectAtIndex:i]];
    }
    
    return responseDictionary;
}

#pragma mark - Observer

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

#pragma mark - Notification handler

- (void)didBecomeActive
{
    DDLogInfo(@"");
//    SFAWatchManager *manager = [SFAWatchManager sharedManager];
    
//    if (manager.autoSyncTriggered && self.userDefaultsManager.watchModel == WatchModel_R450) {
//        manager.autoSyncTriggered = NO;
//        [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
//    }
}

#pragma mark - Lazy loading of properties

- (SFASalutronCModelSync *)salutronSyncC300
{
    if(!_salutronSyncC300) {
        JDACoreData *coreData = [JDACoreData sharedManager];
        _salutronSyncC300 = [[SFASalutronCModelSync alloc] initWithManagedObjectContext:coreData.context];
        _salutronSyncC300.delegate = self;
    }
    return _salutronSyncC300;
}

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

- (SFASalutronSync *)salutronSync
{
    if (!_salutronSync) {
        _salutronSync = [[SFASalutronSync alloc] init];
    }
    
    return _salutronSync;
}

- (SFASalutronR420ModelSync *)salutronR420ModelSync
{
    if (!_salutronR420ModelSync) {
        _salutronR420ModelSync = [[SFASalutronR420ModelSync alloc] init];
    }
    return _salutronR420ModelSync;
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

- (void)updateFinishedWithStatus:(Status)status{
    if (status == ERROR_DISCONNECT || status == ERROR_DISCOVER) {
        [self didDeviceDisconnected:YES];
    }
    else{
        [self startSyncRModel];
        //[SFASalutronUpdateManager sharedInstance].managerDelegate = nil;
    }
}

- (void)updateStarted{
    
}

#pragma mark - HealthStore Method

- (void)saveDataToHealthStore{
    DDLogInfo(@"");
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //    [self getResultSetFromDB:docids];
    //});
    //dispatch_async(dispatch_get_main_queue(), ^{
        if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
            //[[SFAHealthKitManager sharedManager] requestAuthorizationWithSuccess:^(BOOL success) {
            //    if (success) {
                    if([SFAHealthKitManager sharedManager].isHealthKitSyncOngoing){
                        [SFAHealthKitManager sharedManager].delegate = self;
                    }
                    else{
                        [SFAHealthKitManager sharedManager].delegate = nil;
                        SalutronUserProfile *userProfile = [SalutronUserProfile userProfile];
                        [[SFAHealthKitManager sharedManager] saveHeight:(double)(userProfile.height/100.0)];
                        [[SFAHealthKitManager sharedManager] saveWeight:round(userProfile.weight / 2.20462)];
                        DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress];
                        [[SFAHealthKitManager sharedManager] saveAllDataToHealthStoreFromDataHeaders:[StatisticalDataHeaderEntity dataHeadersForDeviceEntity:deviceEntity]];
                    }
                    
                    
            //    }
            //} failure:^(NSError *error) {
                
            //}];
        }
    });
}

- (void)saveDataToHealthStoreWithRequestPermission{
    DDLogInfo(@"");
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //});
    //dispatch_async(dispatch_get_main_queue(), ^{
        if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
            [[SFAHealthKitManager sharedManager] requestAuthorizationWithSuccess:^(BOOL success) {
                if (success) {
                    if([SFAHealthKitManager sharedManager].isHealthKitSyncOngoing){
                        [SFAHealthKitManager sharedManager].delegate = self;
                    }
                    else{
                        [SFAHealthKitManager sharedManager].delegate = nil;
                        SalutronUserProfile *userProfile = [SalutronUserProfile userProfile];
                        [[SFAHealthKitManager sharedManager] saveHeight:(double)(userProfile.height/100.0)];
                        [[SFAHealthKitManager sharedManager] saveWeight:round(userProfile.weight / 2.20462)];
                        DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress];
                        [[SFAHealthKitManager sharedManager] saveAllDataToHealthStoreFromDataHeaders:[StatisticalDataHeaderEntity dataHeadersForDeviceEntity:deviceEntity]];
                    }
                }
            } failure:^(NSError *error) {
                
            }];
        }
    });
}

- (void)syncingToHealthKitFinished{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //});
        //
    [SFAHealthKitManager sharedManager].delegate = nil;
    SalutronUserProfile *userProfile = [SalutronUserProfile userProfile];
    [[SFAHealthKitManager sharedManager] saveHeight:(double)(userProfile.height/100.0)];
    [[SFAHealthKitManager sharedManager] saveWeight:round(userProfile.weight / 2.20462)];
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress];
    [[SFAHealthKitManager sharedManager] saveAllDataToHealthStoreFromDataHeaders:[StatisticalDataHeaderEntity dataHeadersForDeviceEntity:deviceEntity]];
    });
}

@end