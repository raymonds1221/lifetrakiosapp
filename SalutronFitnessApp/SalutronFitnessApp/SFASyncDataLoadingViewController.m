//
//  SFASyncDataLoadingViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/3/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFASyncDataLoadingViewController.h"
#import "SFAErrorMessageViewController.h"
#import "SFASalutronLibrary.h"
#import "SFASalutronCModelSync.h"
#import "SFASalutronSync.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFASalutronCModelSync.h"
#import "SFASalutronRModelSync.h"
#import "SFAFindingWatchViewController.h"
#import "SFALoadingViewController.h"
#import "SFAAddDetailsViewController.h"
#import "SFASalutronR420ModelSync.h"

#define NO_OF_ITEMS_TO_SYNC   15
#define PROGRESS_BAR_WIDTH    160

@interface SFASyncDataLoadingViewController () <SFAErrorMessageViewControllerDelegate, SFASalutronSyncDelegate, CBCentralManagerDelegate>

@property (strong, nonatomic) SFASalutronCModelSync     *salutronCModelSync;
@property (strong, nonatomic) SFASalutronRModelSync     *salutronRModelSync;
@property (strong, nonatomic) SFASalutronR420ModelSync  *salutronR420ModelSync;
@property (strong, nonatomic) SFAUserDefaultsManager    *userDefaultsManager;
@property (strong, nonatomic) NSManagedObjectContext    *managedObjectContext;
@property (strong, nonatomic) CBCentralManager          *centralManager;
@property (strong, nonatomic) SFASalutronSync           *salutronSync;

@property (nonatomic) int loadingDataHeadersIndex;
@property (nonatomic) int loadingDataPointsIndex;
@property (nonatomic) int loadingStepGoalIndex;
@property (nonatomic) int loadingDistanceGoalIndex;
@property (nonatomic) int loadingCalorieGoalIndex;
@property (nonatomic) int loadingSleepSettingsIndex;
@property (nonatomic) int loadingNotificationIndex;
@property (nonatomic) int loadingCalibrationDataIndex;
@property (nonatomic) int loadingWorkoutDatabaseIndex;
@property (nonatomic) int loadingWorkoutStopDatabaseIndex;
@property (nonatomic) int loadingSleepDatabaseIndex;
@property (nonatomic) int loadingUserProfileIndex;
@property (nonatomic) int loadingLightDatapointsIndex;
@property (nonatomic) int loadingIndexesCount;

@end

/*
 Step 3: Sync data from watch to app. Check first if watch is C model or R model
 */

@implementation SFASyncDataLoadingViewController


- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

- (SFASalutronCModelSync *)salutronCModelSync
{
    
    if (!_salutronCModelSync) {
        _salutronCModelSync = [[SFASalutronCModelSync alloc] initWithManagedObjectContext:self.managedObjectContext];
        //_salutronCModelSync.singleCommandExecution = YES;
    }
    return _salutronCModelSync;
}

- (SFASalutronRModelSync *)salutronRModelSync
{
    if (!_salutronRModelSync) {
        _salutronRModelSync = [[SFASalutronRModelSync alloc] init];
    }
    _salutronRModelSync.initialSync = YES;
    _salutronRModelSync.syncType = SyncTypeInitial;
    return _salutronRModelSync
    ;
}

- (SFASalutronR420ModelSync *)salutronR420ModelSync
{
    if (!_salutronR420ModelSync) {
        _salutronR420ModelSync = [[SFASalutronR420ModelSync alloc] init];
    }
    _salutronR420ModelSync.syncType = SyncTypeInitial;
    return _salutronR420ModelSync;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title                          = SYNC_DATA_TITLE;
    self.mainLabel.text                 = SYNCING_WATCH_DATA;
    self.subLabel.text                  = PLEASE_WAIT;
    self.progressBarGray.hidden         = NO;
    self.progressBar.hidden             = NO;
    self.progressBarConstraint.constant = 0;
    
    if (LANGUAGE_IS_FRENCH && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        UILabel* tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
        tlabel.text = self.title;
        tlabel.textColor = [UIColor whiteColor];
        tlabel.textAlignment = NSTextAlignmentCenter;
        tlabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 11.5];
        self.navigationItem.titleView = tlabel;
    }
    
    NSArray *images = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"ll_preloader_default.png"], [UIImage imageNamed:@"ll_preloader_radar_01.png"], [UIImage imageNamed:@"ll_preloader_radar_02.png"], [UIImage imageNamed:@"ll_preloader_radar_03.png"], [UIImage imageNamed:@"ll_preloader_radar_04.png"], [UIImage imageNamed:@"ll_preloader_radar_05.png"], [UIImage imageNamed:@"ll_preloader_radar_06.png"], [UIImage imageNamed:@"ll_preloader_radar_07.png"], [UIImage imageNamed:@"ll_preloader_radar_08.png"], [UIImage imageNamed:@"ll_preloader_radar_09.png"], [UIImage imageNamed:@"ll_preloader_radar_10.png"], [UIImage imageNamed:@"ll_preloader_radar_11.png"], [UIImage imageNamed:@"ll_preloader_default.png"], [UIImage imageNamed:@"ll_preloader_radar_01.png"], [UIImage imageNamed:@"ll_preloader_radar_02.png"], [UIImage imageNamed:@"ll_preloader_radar_03.png"], [UIImage imageNamed:@"ll_preloader_radar_04.png"], [UIImage imageNamed:@"ll_preloader_radar_05.png"], [UIImage imageNamed:@"ll_preloader_radar_06.png"], [UIImage imageNamed:@"ll_preloader_radar_07.png"], [UIImage imageNamed:@"ll_preloader_radar_08.png"], [UIImage imageNamed:@"ll_preloader_radar_09.png"], [UIImage imageNamed:@"ll_preloader_radar_10.png"], [UIImage imageNamed:@"ll_preloader_radar_11.png"], [UIImage imageNamed:@"ll_preloader_default.png"], [UIImage imageNamed:@"ll_preloader_arrow_01.png"], [UIImage imageNamed:@"ll_preloader_arrow_02.png"], [UIImage imageNamed:@"ll_preloader_arrow_03.png"], [UIImage imageNamed:@"ll_preloader_arrow_04.png"], [UIImage imageNamed:@"ll_preloader_arrow_05.png"], [UIImage imageNamed:@"ll_preloader_arrow_06.png"], [UIImage imageNamed:@"ll_preloader_arrow_07.png"], [UIImage imageNamed:@"ll_preloader_default.png"], [UIImage imageNamed:@"ll_preloader_arrow_01.png"], [UIImage imageNamed:@"ll_preloader_arrow_02.png"], [UIImage imageNamed:@"ll_preloader_arrow_03.png"], [UIImage imageNamed:@"ll_preloader_arrow_04.png"], [UIImage imageNamed:@"ll_preloader_arrow_05.png"], [UIImage imageNamed:@"ll_preloader_arrow_06.png"], [UIImage imageNamed:@"ll_preloader_arrow_07.png"], [UIImage imageNamed:@"ll_preloader_default.png"], nil];
    
    self.imageView.animationImages = images;
    self.imageView.animationDuration = 3.0f;
    [self.imageView startAnimating];
    [self performSelector:@selector(initializeObjects) withObject:nil afterDelay:1.0];
}

- (void)initializeObjects{
    
    SFASalutronFitnessAppDelegate *appDelegate     = [UIApplication sharedApplication].delegate;

    self.managedObjectContext                      = appDelegate.managedObjectContext;
    
    
    self.salutronSync                              = [[SFASalutronSync alloc] init];
    self.salutronSync.delegate                     = self;
    self.salutronSync.selectedWatchModel           = self.watchModel;
    self.salutronSync.syncType                     = SyncTypeInitial;
    
    //self.salutronSync.deviceEntity = nil;
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    WatchModel model = WatchModel_Move_C300;
    if ([self.deviceModelString isEqualToString:WatchModel_C300_DeviceId]) {
        model = WatchModel_Move_C300;
        //[self.salutronCModelSync connectToDeviceWithIndex:self.deviceIndex withStatus:self.status];
    }
    else if ([self.deviceModelString isEqualToString:WatchModel_C410_DeviceId]) {
        model = WatchModel_Zone_C410;
        //[self.salutronCModelSync connectToDeviceWithIndex:self.deviceIndex withStatus:self.status];
    }
    else if ([self.deviceModelString isEqualToString:WatchModel_R420_DeviceId]) {
        model = WatchModel_R420;
        //[self.salutronCModelSync connectToDeviceWithIndex:self.deviceIndex withStatus:self.status];
    }
    else{// if ([self.deviceModelString isEqualToString:WatchModel_R450_DeviceId]){
        model = WatchModel_R450;
    }
    
    if (model == WatchModel_Move_C300 ||
        model == WatchModel_Zone_C410) {
        self.loadingIndexesCount = 15;
        
        self.loadingDataHeadersIndex = 1;
        self.loadingDataPointsIndex = 5;
        self.loadingStepGoalIndex = 7;
        self.loadingDistanceGoalIndex = 8;
        self.loadingCalorieGoalIndex = 9;
        self.loadingSleepSettingsIndex = 0;
        self.loadingNotificationIndex = 10;
        self.loadingCalibrationDataIndex = 11;
        self.loadingWorkoutDatabaseIndex = 12;
        self.loadingWorkoutStopDatabaseIndex = 13;
        self.loadingSleepDatabaseIndex = 13;//0;
        self.loadingUserProfileIndex = 14;
        self.loadingLightDatapointsIndex = 6;
        
        self.salutronCModelSync.delegate = self;
        self.salutronCModelSync.updateTimeAndDate = YES;
        [self.salutronCModelSync syncDataWithWatchModel:model andStatus:self.status];
    } else if (model == WatchModel_R420) {
        self.loadingIndexesCount = 15;
        
        self.loadingDataHeadersIndex = 1;
        self.loadingDataPointsIndex = 5;
        self.loadingStepGoalIndex = 7;
        self.loadingDistanceGoalIndex = 8;
        self.loadingCalorieGoalIndex = 9;
        self.loadingSleepSettingsIndex = 0;
        self.loadingNotificationIndex = 10;
        self.loadingCalibrationDataIndex = 11;
        self.loadingWorkoutDatabaseIndex = 12;
        self.loadingWorkoutStopDatabaseIndex = 13;
        self.loadingSleepDatabaseIndex = 13;//0;
        self.loadingUserProfileIndex = 14;
        
        self.salutronR420ModelSync.delegate = self;
        self.salutronR420ModelSync.salutronSDK.delegate = self.salutronR420ModelSync;
        [self.salutronR420ModelSync syncData];
    } else {
        self.loadingIndexesCount = 22;
        
        self.loadingDataHeadersIndex = 1;
        self.loadingDataPointsIndex = 5;
        self.loadingWorkoutDatabaseIndex = 7;
        self.loadingWorkoutStopDatabaseIndex = 8;
        self.loadingSleepDatabaseIndex = 9;
        self.loadingLightDatapointsIndex = 5;
        self.loadingStepGoalIndex = 15;
        self.loadingDistanceGoalIndex = 16;
        self.loadingCalorieGoalIndex = 17;
        self.loadingNotificationIndex = 18;
        self.loadingSleepSettingsIndex = 19;
        self.loadingCalibrationDataIndex = 20;
        self.loadingUserProfileIndex = 21;
        
        self.salutronRModelSync.delegate = self;
        self.salutronRModelSync.syncType = SyncTypeInitial;
        self.salutronRModelSync.salutronSDK.delegate = self.salutronRModelSync;
        [self.salutronRModelSync didConnectAndSetupDeviceWithStatus:NO_ERROR];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    DDLogInfo(@"");
    [self disconnect];
}

- (void)rightButtonCicked:(id)sender{
    //[self performSegueWithIdentifier:@"SyncDataToAddDetails" sender:self];
}


- (void)disconnect{
    WatchModel model = WatchModel_Move_C300;
    if ([self.deviceModelString isEqualToString:WatchModel_C300_DeviceId]) {
        model = WatchModel_Move_C300;
        //[self.salutronCModelSync connectToDeviceWithIndex:self.deviceIndex withStatus:self.status];
    }
    else if ([self.deviceModelString isEqualToString:WatchModel_C410_DeviceId]) {
        model = WatchModel_Zone_C410;
        //[self.salutronCModelSync connectToDeviceWithIndex:self.deviceIndex withStatus:self.status];
    }
    else if ([self.deviceModelString isEqualToString:WatchModel_R420_DeviceId]) {
        model = WatchModel_R420;
        //[self.salutronCModelSync connectToDeviceWithIndex:self.deviceIndex withStatus:self.status];
    }
    else{// if ([self.deviceModelString isEqualToString:WatchModel_R450_DeviceId]){
        model = WatchModel_R450;
    }
    
    if (model == WatchModel_Move_C300 ||
        model == WatchModel_Zone_C410 ||
        model == WatchModel_R420) {
        self.salutronCModelSync.delegate = nil;
        [self.salutronCModelSync.salutronSDK disconnectDevice];
        [self.salutronCModelSync.salutronSDK commDone];
        [self.salutronCModelSync deleteDevice];
        [self.salutronSync deleteDevice];
    }
    else{
        self.salutronRModelSync.delegate = nil;
        [self.salutronRModelSync.salutronSDK disconnectDevice];
        //[self.salutronRModelSync.salutronSDK commDone];
        [self.salutronRModelSync deleteDevice];
        [self.salutronSync deleteDevice];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    SFALoadingViewController *rootController = (SFALoadingViewController *)((SFASalutronFitnessAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    rootController.isSwitchWatch = YES;
    [rootController returnToRoot];
    
}


- (void)showErrorMessage{
    SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
    vc.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc setErrorTitle:WATCH_SYNC_FAILED
            errorMessage1:MAKE_SURE_BLE_ENABLED
            errorMessage2:CHECK_BATTERY_LEVEL
            errorMessage3:KEEP_PHONE_AND_WATCH_RANGE
         andErrorMessage4:@""
        andButtonPosition:1
             ButtonTitle1:LS_CANCEL
          andButtonTitle2:LS_TRY_AGAIN_CAPS];
    });
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)erroMessageCenterButtonClicked{
    
}

- (void)erroMessageLeftButtonClicked{
    [self performSelector:@selector(disconnect) withObject:nil afterDelay:0.5];
}

- (void)erroMessageRightButtonClicked{
    NSArray *navControllers = [self.navigationController viewControllers];
    for (id vc in navControllers) {
        if ([vc isKindOfClass:[SFAFindingWatchViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

- (void)didChecksumError
{
    
}

- (void)didDeviceDisconnected:(BOOL)isSyncFinished{
    if (!isSyncFinished) {
        
        WatchModel model = WatchModel_Move_C300;
        if ([self.deviceModelString isEqualToString:WatchModel_C300_DeviceId]) {
            model = WatchModel_Move_C300;
            //[self.salutronCModelSync connectToDeviceWithIndex:self.deviceIndex withStatus:self.status];
        }
        else if ([self.deviceModelString isEqualToString:WatchModel_C410_DeviceId]) {
            model = WatchModel_Zone_C410;
            //[self.salutronCModelSync connectToDeviceWithIndex:self.deviceIndex withStatus:self.status];
        }
        else if ([self.deviceModelString isEqualToString:WatchModel_R420_DeviceId]) {
            model = WatchModel_R420;
            //[self.salutronCModelSync connectToDeviceWithIndex:self.deviceIndex withStatus:self.status];
        }
        else{// if ([self.deviceModelString isEqualToString:WatchModel_R450_DeviceId]){
            model = WatchModel_R450;
        }
        
        if (model == WatchModel_Move_C300 ||
            model == WatchModel_Zone_C410 ||
            model == WatchModel_R420) {
            self.salutronCModelSync.delegate = nil;
            [self.salutronCModelSync.salutronSDK disconnectDevice];
            [self.salutronCModelSync.salutronSDK commDone];
            [self.salutronCModelSync deleteDevice];
            [self.salutronSync deleteDevice];
        }
        else{
            self.salutronRModelSync.delegate = nil;
            //[self.salutronRModelSync.salutronSDK disconnectDevice];
            //[self.salutronRModelSync.salutronSDK commDone];
            [self.salutronRModelSync deleteDevice];
            [self.salutronSync deleteDevice];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        

        
        SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
        vc.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc setErrorTitle:WATCH_SYNC_FAILED
                errorMessage1:MAKE_SURE_BLE_ENABLED
                errorMessage2:CHECK_BATTERY_LEVEL
                errorMessage3:KEEP_PHONE_AND_WATCH_RANGE
             andErrorMessage4:@""
            andButtonPosition:1
                 ButtonTitle1:LS_CANCEL
              andButtonTitle2:LS_TRY_AGAIN_CAPS];
        });
        [self presentViewController:vc animated:YES completion:nil];

    }
    else{
        [self performSegueWithIdentifier:@"SyncDataToAddDetails" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"SyncDataToAddDetails"]) {
        SFAAddDetailsViewController *addDetailsVC = segue.destinationViewController;
        addDetailsVC.salutronCModelSync = self.salutronCModelSync;
        addDetailsVC.salutronRModelSync = self.salutronRModelSync;
    }
}


#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
}

#pragma mark - SFASalutronSyncDelegate
- (void)didRaiseError{
    [self showErrorMessage];
}

- (void)didSyncOnAlerts{
    DDLogInfo(@"");
    self.subLabel.text                  = SYNCING_SETTINGS;
}

- (void)didSyncOnDataHeaders{
    DDLogInfo(@"");
    //self.subLabel.text                  = @"Fitness data";
    //1
    [self incrementProgressBarWith:((float)self.loadingDataHeadersIndex/self.loadingIndexesCount)*PROGRESS_BAR_WIDTH];
}

- (void)didSyncOnDataPoints{
    DDLogInfo(@"");
    self.subLabel.text                  = SYNCING_FITNESS_DATA;
}

- (void)didSyncOnDataPoints:(NSInteger)percent{
    //2
    DDLogInfo(@"%i", percent);
    float percentage = (float)percent/100;
    float datapointIncrement = 1 + percentage*(self.loadingDataPointsIndex*1.0);
    float dataPointProgress = datapointIncrement/(float)self.loadingIndexesCount;
    [self incrementProgressBarWith:dataPointProgress*PROGRESS_BAR_WIDTH];
    self.subLabel.text                  = SYNCING_FITNESS_DATA;
}

- (void)didSyncOnStepGoal{
    DDLogInfo(@"");
    //3
    [self incrementProgressBarWith:((float)self.loadingStepGoalIndex/self.loadingIndexesCount)*PROGRESS_BAR_WIDTH];
    self.subLabel.text                  = SYNCING_GOALS;
}

- (void)didSyncOnDistanceGoal{
    DDLogInfo(@"");
    //4
    [self incrementProgressBarWith:((float)self.loadingDistanceGoalIndex/self.loadingIndexesCount)*PROGRESS_BAR_WIDTH];
    self.subLabel.text                  = SYNCING_GOALS;
    
}

- (void)didSyncOnCalorieGoal{
    DDLogInfo(@"");
    //5
    self.subLabel.text                  = SYNCING_GOALS;
    [self incrementProgressBarWith:((float)self.loadingCalorieGoalIndex/self.loadingIndexesCount)*PROGRESS_BAR_WIDTH];
}


- (void)didSyncOnSleepSettings{
    DDLogInfo(@"");
    //
    [self incrementProgressBarWith:((float)self.loadingSleepSettingsIndex/self.loadingIndexesCount)*PROGRESS_BAR_WIDTH];
    self.subLabel.text                  = SYNCING_SETTINGS;
    
}

- (void)didSyncOnNotification{
    DDLogInfo(@"");
    //6
    [self incrementProgressBarWith:((float)self.loadingNotificationIndex/self.loadingIndexesCount)*PROGRESS_BAR_WIDTH];
    self.subLabel.text                  = SYNCING_SETTINGS;
}

- (void)didSyncOnCalibrationData{
    DDLogInfo(@"");
    //7
    self.subLabel.text                  = SYNCING_SETTINGS;
    [self incrementProgressBarWith:((float)self.loadingCalibrationDataIndex/self.loadingIndexesCount)*PROGRESS_BAR_WIDTH];
}

- (void)didSyncOnWorkoutDatabase{
    DDLogInfo(@"");
    //8
    [self incrementProgressBarWith:((float)self.loadingWorkoutDatabaseIndex/self.loadingIndexesCount)*PROGRESS_BAR_WIDTH];
    self.subLabel.text                  = SYNCING_WORKOUT;
}

- (void)didSyncOnWorkoutStopDatabase{
    DDLogInfo(@"");
    //9
    [self incrementProgressBarWith:((float)self.loadingWorkoutStopDatabaseIndex/self.loadingIndexesCount)*PROGRESS_BAR_WIDTH];
    self.subLabel.text                  = SYNCING_WORKOUT;
}


- (void)didSyncOnSleepDatabase{
    DDLogInfo(@"");
    //
    [self incrementProgressBarWith:((float)self.loadingSleepDatabaseIndex/self.loadingIndexesCount)*PROGRESS_BAR_WIDTH];
    self.subLabel.text                  = SYNCING_SLEEP;
}

- (void)didSyncOnUserProfile{
    DDLogInfo(@"");
    //10
    self.salutronCModelSync.initialSync = YES;
    [self incrementProgressBarWith:((float)self.loadingUserProfileIndex/self.loadingIndexesCount)*PROGRESS_BAR_WIDTH];
    self.subLabel.text                  = SYNCING_SETTINGS;
}

- (void)didSyncOnLightDataPoints{
    DDLogInfo(@"");
    //[self incrementProgressBarWith:((float)self.loadingLightDatapointsIndex/self.loadingIndexesCount)*PROGRESS_BAR_WIDTH];
    //self.subLabel.text                  = @"Light data";
}

- (void)didSyncOnLightDataPoints:(NSInteger)percent{
    DDLogInfo(@"%i", percent);
    self.subLabel.text                  = SYNCING_LIGHT;

    float percentage = (float)percent/100;
    float datapointIncrement = 9 + percentage*(self.loadingLightDatapointsIndex*1.0);
    float dataPointProgress = datapointIncrement/(float)self.loadingIndexesCount;
    [self incrementProgressBarWith:dataPointProgress*PROGRESS_BAR_WIDTH];
}

- (void)didSyncOnTimeAndDate{
    DDLogInfo(@"");
    
}

- (void)didUpdateFinish{
    DDLogInfo(@"");
}

- (void)didSaveSettings{
    DDLogInfo(@"");
    [self incrementProgressBarWith:PROGRESS_BAR_WIDTH];
}

- (void)didSyncFinished:(DeviceEntity *)deviceEntity profileUpdated:(BOOL)profileUpdated{
    DDLogInfo(@"");
    
    self.salutronR420ModelSync.delegate = nil;
    self.salutronR420ModelSync.salutronSDK.delegate = nil;
    
    [self incrementProgressBarWith:PROGRESS_BAR_WIDTH];
    [self performSelector:@selector(showSyncSuccess) withObject:nil afterDelay:1.0];
    
}

- (void)showSyncSuccess{
    self.mainLabel.text                 = SYNCING_SUCCESSFUL;
    self.subLabel.text                  = @"";
    
    [self.imageView stopAnimating];
    self.imageView.animationImages      = nil;
    self.imageView.image                = [UIImage imageNamed:@"ll_preloader_sync_success"];
    self.progressBarGray.hidden         = YES;
    self.progressBar.hidden             = YES;
    [self performSelector:@selector(goToAddDetails) withObject:nil afterDelay:3.0];
}

- (void)goToAddDetails{
    [self performSegueWithIdentifier:@"SyncDataToAddDetails" sender:self];
}

- (void)incrementProgressBarWith:(int)increment{
    int max = PROGRESS_BAR_WIDTH;
    int currentProgress = increment;//self.progressBarConstraint.constant;
    //currentProgress +=increment;
    if (currentProgress>=max) {
        currentProgress = max;
        [UIView animateWithDuration:1.0
                         animations:^{
                             self.progressBarConstraint.constant = currentProgress;
                         }
                         completion:nil];
    }
    else{
        [UIView animateWithDuration:1.0
                         animations:^{
                             self.progressBarConstraint.constant = currentProgress;
                         }
                         completion:nil];
    }
}

- (void)didSyncStarted{
    
}

- (void)didChangeSettings{
    
}
@end
