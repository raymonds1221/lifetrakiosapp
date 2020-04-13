//
//  SFASyncSetup.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/25/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Format.h"

#import "SFASettingsViewController.h"
#import "SFASettingsViewController+View.h"

#import "SFAConnectionViewController.h"
#import "ECSlidingViewController.h"
#import "SFAPairViewController.h"
#import "SFAFunFactsLifeTrakViewController.h"
#import "UIViewController+Helper.h"

#import "ErrorCodeToStringConverter.h"
#import "SFAAutoSyncCell.h"
#import "SFASalutronCModelSync.h"
#import "SFASalutronFitnessAppDelegate.h"

#import "TimeDate+Data.h"
#import "UIImage+WatchImage.h"
#import "SalutronUserProfile+Data.h"
#import "WorkoutSetting+Coding.h"

#import "DeviceEntity+Data.h"
#import "TimeDate+Data.h"
#import "Notification+Data.h"
#import "SleepSetting+Data.h"
#import "CalibrationData+Data.h"

#import "TimeDateEntity+Data.h"
#import "NotificationEntity+Data.h"
#import "SleepSettingEntity+Data.h"
#import "CalibrationDataEntity+Data.h"
#import "UserProfileEntity+Data.h"
#import "WorkoutSettingEntity+CoreDataProperties.h"
#import "SFAAmazonServiceManager.h"

#import "JDACoreData.h"

#import "SVProgressHUD.h"
#import "SFASettingsViewController+TableData.h"
#import "SFAWatchManager.h"
#import "SFAHealthKitManager.h"
#import "SFASyncProgressView.h"
#import "SFASalutronSync.h"
#import "SFAServerSyncManager.h"
#import "SFAServerManager.h"
#import "SFAServerAccountManager.h"

#import "SFAWelcomeViewNavigationController.h"
#import "SFALoadingViewController.h"

#import "SFARewardsWebViewController.h"
#import "SFAWalgreensManager.h"
#import "WorkoutInfoEntity+Data.h"
#import "SleepDatabaseEntity+Data.h"

#import "SFAUserDefaultsManager.h"
#import "SFASalutronUpdateManager.h"

#import "InactiveAlertEntity+Data.h"
#import "DayLightAlertEntity+Data.h"
#import "NightLightAlertEntity+Data.h"
#import "StatisticalDataHeaderEntity+Data.h"
#import "Flurry.h"

#define BACKGROUND_COLOR    [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]

#define WELCOME_VIEW_CONTROLLER_IDENTIFIER  @"SFAWelcomeViewController"
#define INTRO_VIEW_CONTROLLER_IDENTIFIER    @"IntroViewControllerIdentifier"
#define PAIR_SEGUE_IDENTIFIER               @"WatchSettingsToPair"
#define SMART_CALIBRATION_SEGUE             @"SFASmartCalibrationViewController"
#define ALARM_SETTINGS_SEGUE                @"SFAAlarmSettingsViewController"
#define NOTIFICATIONS_SEGUE                 @"SFANotificationsViewController"


#define HOUR_FORMAT_12                       0
#define HOUR_FORMAT_24                       1

/* SFAImagePickerController */

@interface SFAImagePickerController : UIImagePickerController

@end

@implementation SFAImagePickerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)   // iOS7+ only
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}
@end

/* SFASettingsViewController */

@interface SFASettingsViewController () <UIAlertViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SFASalutronSyncDelegate, SFAPairViewControllerDelegate, CBCentralManagerDelegate, UITextFieldDelegate, SFASalutronSyncDelegate, SFASyncProgressViewDelegate, SFAHealthKitManagerDelegate, SFAAmazonServiceManagerDelegate>
{
    //NSString *_deviceName;
    NSString *_deviceModelNumberString;
    NSNumber *_deviceModelNumber;
    BOOL      _profileUpdated;
    BOOL      _deviceFound;
    
    TimeDate *_timeDate;
}

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPickerView *dayPicker;
@property (strong, nonatomic) UIButton *timeButton;

@property (strong, nonatomic) SFASalutronCModelSync *salutronSyncC300;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readwrite, nonatomic) WatchModel watchModel;

@property (assign, nonatomic)       BOOL                        bluetoothOn;
@property (strong, nonatomic)       CBCentralManager            *centralManager;

@property (readwrite, nonatomic) BOOL isDisconnected;

@property (readwrite, nonatomic) BOOL                           isStillSyncing;
@property (readwrite, nonatomic) BOOL                           didCancel;
@property (readwrite, nonatomic) BOOL                           cancelSyncToCloudOperation;

@property (strong, nonatomic) SFASalutronUpdateManager *updateManager;
@property (strong, nonatomic) NSArray *settingsArray;

@property (strong, nonatomic) NSOperation               *syncToCloudOperation;


@property (strong, nonatomic) SFASalutronSync                   *salutronSync;
@property (weak, nonatomic) SFAPairViewController               *pairViewController;
@property (strong, nonatomic) UIPickerView                      *pickerView;
@property (strong, nonatomic) UIView                            *genericPickerView;

@property (assign, nonatomic, getter=isResetWorkout) BOOL        resetWorkout;

@property (strong, nonatomic) DeviceEntity *device;

@end

@implementation SFASettingsViewController


- (SFASalutronSync *)salutronSync
{
    if (!_salutronSync) {
        _salutronSync = [[SFASalutronSync alloc] init];
    }
    
    return _salutronSync;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _watchModel = self.userDefaultsManager.watchModel;
    
    self.timeButton.titleLabel.minimumScaleFactor = 0.3f;
    
    [self hideCancelAndSave];
    [self getCurrentSettings];
    self.saveButton = self.navigationItem.rightBarButtonItem;
    [self addGenericPickerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    /*JDACoreData *manager = [JDACoreData sharedManager];
    NSArray *devices = [manager fetchEntityWithEntityName:@"DeviceEntity"];

    if ([devices count] > 0) {
        for (int i = 0; i < [devices count]; i++) {
            DeviceEntity *deviceEntity = (DeviceEntity *)[devices objectAtIndex:i];
            if ([deviceEntity.modelNumber isEqualToNumber:[[NSUserDefaults standardUserDefaults] objectForKey:CONNECTED_WATCH_MODEL]]) {
                _deviceName = deviceEntity.name;
                _deviceModelNumberString = deviceEntity.modelNumberString;
                _deviceModelNumber = deviceEntity.modelNumber;
            }

        }
//        DeviceEntity *deviceEntity = (DeviceEntity *)[devices lastObject];
//        _deviceName = deviceEntity.name;
//        _deviceModelNumberString = deviceEntity.modelNumberString;
//        _deviceModelNumber = deviceEntity.modelNumber;
    }*/
    
    [Flurry logEvent:SETTINGS_PAGE];
    NSString *macAddress            = self.userDefaultsManager.macAddress;
    self.deviceEntity               = [DeviceEntity deviceEntityForMacAddress:macAddress];

    if (self.deviceEntity) {
        //_deviceName                 = self.deviceEntity.name;
        _deviceModelNumberString    = self.deviceEntity.modelNumberString;
        _deviceModelNumber          = self.deviceEntity.modelNumber;
    } else {
        //_deviceName                 = @"";
        _deviceModelNumberString    = @"";
        _deviceModelNumber          = [[NSNumber alloc] init];
    }
    
    CalibrationData *calibrationData = [CalibrationData calibrationDataWithCalibrationDataEntity:self.deviceEntity.calibrationData];
    DDLogError(@"calibration data: %@", calibrationData);
    self.userDefaultsManager.calibrationData = calibrationData;
    self.userDefaultsManager.salutronUserProfile = [SalutronUserProfile getData];
//    CalibrationData *calibrationData = [NSKeyedUnarchiver unarchiveObjectWithData:[self.userDefaults objectForKey:CALIBRATION_DATA]];
//    DDLogError(@"calibration data: %@", calibrationData);

//    _timeDate = [TimeDate getUpdatedData];
    //[super viewWillAppear:animated];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    [self getCurrentSettings];
    [self.tableView reloadData];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelChanges];
}

/*
- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {
    if ([fromViewController isKindOfClass:[SFAPairViewController class]]) {
        SFAPairViewController *pairViewController = (SFAPairViewController *)fromViewController;
        
        if (pairViewController.startedFromConnectionView) {
            [pairViewController dismissViewControllerAnimated:NO completion:nil];
            return NO;
        } else {
            return YES;
        }
    }
    return YES;
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Lazy loading of properties

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

- (SFASalutronUpdateManager *)updateManager
{
    if (!_updateManager) {
        _updateManager   = [SFASalutronUpdateManager sharedInstance];
    }
    return _updateManager;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PAIR_SEGUE_IDENTIFIER]) {
        self.pairViewController                          = (SFAPairViewController *)segue.destinationViewController;
        self.pairViewController.delegate                 = self;
        self.pairViewController.watchModel               = self.userDefaultsManager.watchModel;
        self.pairViewController.showCancelSyncButton     = YES;
        
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            self.pairViewController.paired               = YES;
        } else {
            self.pairViewController.paired               = NO;
        }
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
    if ([identifier isEqualToString:PAIR_SEGUE_IDENTIFIER]) {
        if(!self.userDefaultsManager.isBlueToothOn) {
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
        
        if(self.userDefaultsManager.watchModel != WatchModel_R450){
            [self startSyncCModel];
            return self.bluetoothOn;
        }
        else{
            [self startSyncRModel];
            return NO;
        }
    }
    else if ([identifier isEqualToString:@"Cancel Sync"]) {
        return NO;
    }

    return YES;
}

#pragma mark - IBActions

- (IBAction)menuButtonPressed:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
    //[self updateSettingsInUserDefaults];
    //[self saveToCoreData];
}

#pragma mark - Private Methods

- (void) pairUnpairPressed {
    if([self.userDefaults boolForKey:HAS_PAIRED]) {
        /*[self.userDefaults setBool:NO forKey:HAS_PAIRED];
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroViewControllerIdentifier"];
        [self presentViewController:viewController animated:YES completion:nil];*/
        
        NSString *model         = [SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel];
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:UNPAIR_ALERT_TITLE
                                                                                     message:UNPAIR_ALERT_MESSAGE(model)
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_CANCEL
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
            UIAlertAction *continueAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_CONTINUE
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSString *identifier                = [DeviceEntity hasDeviceEntity] ? WELCOME_VIEW_CONTROLLER_IDENTIFIER : INTRO_VIEW_CONTROLLER_IDENTIFIER;
                                           UIViewController *viewController    = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
                                           
                                           [self.userDefaults setBool:NO forKey:HAS_PAIRED];
                                           [self presentViewController:viewController animated:YES completion:nil];
                                       }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:continueAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
        UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:UNPAIR_ALERT_TITLE
                                                             message:UNPAIR_ALERT_MESSAGE(model)
                                                            delegate:self
                                                   cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                   otherButtonTitles:BUTTON_TITLE_CONTINUE, nil];
        alertView.tag           = 1;
        
        [alertView show];
        }
        
    } else {
        UINavigationController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAConnectionNavigationIdentifier"];
        if([viewController.topViewController respondsToSelector:@selector(previousController)]) {
            SFAConnectionViewController *connectionViewController = (SFAConnectionViewController *) viewController.topViewController;
            connectionViewController.previousController = SyncSetupViewController;
        }
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)valueChanged:(id)sender
{
//    UISwitch *autoSyncSwitch = (UISwitch *) sender;
//    self.userDefaultsManager.autoSyncToWatchEnabled = [autoSyncSwitch isOn];
    
    if([sender isKindOfClass:[UISwitch class]]) {
        if (self.autoSyncSwitch == sender) {
            //add table cells
            UISwitch *autoSyncAlertSwitch = (UISwitch *) sender;
            
            if([autoSyncAlertSwitch isOn]) {
                self.userDefaultsManager.autoSyncToWatchEnabled = YES;
                [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
            }
            else {
                self.userDefaultsManager.autoSyncToWatchEnabled = NO;
                [[SFAWatchManager sharedManager] disableAutoSync];
            }
            [self.tableView reloadData];
        }
        else if (self.autoSyncAlertSwitch == sender) {
            UISwitch *autoSyncAlertSwitch = (UISwitch *) sender;
            
            if([autoSyncAlertSwitch isOn]) {
                self.userDefaultsManager.autoSyncToWatchEnabled = YES;
                [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
            } else {
                self.userDefaultsManager.autoSyncToWatchEnabled = NO;
                [[SFAWatchManager sharedManager] disableAutoSync];
            }
            [self.userDefaults synchronize];
            
        } else if (self.autoSyncTimeSwitch == sender) {
            self.userDefaultsManager.autoSyncTimeEnabled = [self.autoSyncTimeSwitch isOn];
        }
        
    } else if([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
        
        SyncSetupOption syncSetupOption;
        
        switch (segmentedControl.selectedSegmentIndex) {
            case 1:
                syncSetupOption = SyncSetupOptionOnce;
                break;
            case 2:
                syncSetupOption = SyncSetupOptionOnceAWeek;
                break;
            /*
            case 2:
                syncSetupOption = SyncSetupOptionTwice;
                break;
            case 3:
                syncSetupOption = SyncSetupOptionFourTimes;
                break;
             */
            default:
                syncSetupOption = SyncSetupOptionOnce;
                break;
        }
        
        [self.userDefaults setInteger:syncSetupOption forKey:AUTO_SYNC_OPTION];
        [self.userDefaults synchronize];
    }
}

- (void)dateFormatClick:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select Date Format",nil)
                                                             delegate:self
                                                    cancelButtonTitle:BUTTON_TITLE_CANCEL
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:DATE_FORMAT_DDMMYY, DATE_FORMAT_MMDDYY, DATE_FORMAT_MMMDD, DATE_FORMAT_DDMMM, nil];
    actionSheet.tag            = 2;
    [actionSheet showInView:self.view];
}

- (void)setSyncSetupOption:(int)row
{
    SyncSetupOption syncSetupOption;
    
    switch (row) {
        case 1:
            syncSetupOption = SyncSetupOptionOnce;
            break;
        case 2:
            syncSetupOption = SyncSetupOptionOnceAWeek;
            break;
        /*
        case 2:
            syncSetupOption = SyncSetupOptionTwice;
            break;
        case 3:
            syncSetupOption = SyncSetupOptionFourTimes;
            break;
         */
        default:
            syncSetupOption = SyncSetupOptionOff;
            break;
    }
   
    [self.userDefaults setInteger:syncSetupOption forKey:AUTO_SYNC_OPTION];
    [self.userDefaults synchronize];
    
    [self.tableView reloadData];
}

- (void)setAutoSyncFrequency:(id)sender
{
    UIButton *freqButton = (UIButton *)sender;
    SyncSetupOption syncSetupOption;
    
    if ([freqButton.titleLabel.text isEqualToString:OPTION_ONCE_LABEL]) {
        syncSetupOption = SyncSetupOptionOnce;
    }
    else if([freqButton.titleLabel.text isEqualToString:OPTION_ONCE_A_WEEK_LABEL]) {
        syncSetupOption = SyncSetupOptionOnceAWeek;
    }
   /* else if([freqButton.titleLabel.text isEqualToString:OPTION_TWICE_LABEL]) {
        syncSetupOption = SyncSetupOptionTwice;
    }
    else if([freqButton.titleLabel.text isEqualToString:OPTION_FOUR_TIMES_LABEL]) {
        syncSetupOption = SyncSetupOptionFourTimes;
    }*/
    else {
        syncSetupOption = SyncSetupOptionOff;
    }
    
    [self.userDefaults setInteger:syncSetupOption forKey:AUTO_SYNC_OPTION];
    [self.userDefaults synchronize];
    
    [self.tableView reloadData];
}

- (void)manualSyncPressed
{
    /*NSUInteger model = [self.userDefaults integerForKey:CONNECTED_WATCH_MODEL];
    [self.salutronSyncC300 startSyncWithWatchModel:model];
    [self showProgress];*/
    
    NSString *model                 = [SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel];
    BOOL isAutoSync                 = [SFAWatch isAutoSyncForWatchModel:self.userDefaultsManager.watchModel];
    if (self.isIOS8AndAbove) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:UPDATE_ALERT_TITLE
                                                                                 message:UPDATE_ALERT_MESSAGE(model, isAutoSync)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_CANCEL
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
        UIAlertAction *continueAction = [UIAlertAction
                                         actionWithTitle:BUTTON_TITLE_CONTINUE
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action)
                                         {
                                              [self showProgressForSearch];
                                         }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:continueAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
    UIAlertView *alertView          = [[UIAlertView alloc] initWithTitle:UPDATE_ALERT_TITLE
                                                                 message:UPDATE_ALERT_MESSAGE(model, isAutoSync)
                                                                delegate:self
                                                       cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                       otherButtonTitles:BUTTON_TITLE_CONTINUE, nil];
    alertView.tag                   = 0;
    
    [alertView show];
    }
}

- (void)showProgress {
    UIView *modal = [[UIView alloc] init];
    modal.alpha = 0.5f;
    modal.tag = 101;
    modal.backgroundColor = [UIColor blackColor];
    modal.frame = self.view.bounds;
    
    
    CGPoint containerPoint = CGPointMake((modal.frame.size.width / 2) - 100,
                                         (modal.frame.size.height / 2) - 50);
    
    UIView *container = [[UIView alloc] init];
    container.tag = 102;
    container.backgroundColor = [UIColor whiteColor];
    container.frame = CGRectMake(containerPoint.x, containerPoint.y, 200, 100);
    
    UILabel *label = [[UILabel alloc] init];
    label.tag = 103;
    label.text = LS_SEARCHING;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
    label.frame = CGRectMake((container.frame.size.width / 2) - 75, 10, 150, 20);
    label.textAlignment = NSTextAlignmentCenter;
    [container addSubview:label];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake((container.frame.size.width / 2) - 25, 20, 50, 50);
    indicator.hidesWhenStopped = YES;
    [indicator startAnimating];
    [container addSubview:indicator];
    
    container.layer.cornerRadius = 10.0f;
    container.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    container.layer.shadowRadius = 5.0f;
    container.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    container.layer.shadowOpacity = 1.0f;
    
    [self.view addSubview:modal];
    [self.view addSubview:container];
    
    [self.view bringSubviewToFront:modal];
    [self.view bringSubviewToFront:container];
}

- (void)_finishUpdate {
    if(_profileUpdated) {
        [SVProgressHUD popActivity];
        [self performSegueWithIdentifier:@"YourProfileSegue" sender:self];
    } else {
        [UIView animateWithDuration:0.5f animations:^{
            [self.view viewWithTag:101].layer.opacity = 0.0f;
            //[SVProgressHUD showSuccessWithStatus:SYNC_SUCCESS];
            [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
                
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
        } completion:^(BOOL finished) {
            [[self.view viewWithTag:101] removeFromSuperview];
            [[self.view viewWithTag:102] removeFromSuperview];
        }];
    }
}

- (void)showProgressForSearch
{
    self.isDisconnected = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];

    //NSString *modelString = @"";
    
    if (self.userDefaultsManager.watchModel == WatchModel_Move_C300_Android) {
        self.userDefaultsManager.watchModel = WatchModel_Move_C300;
    }
    /*
    switch (self.userDefaultsManager.watchModel) {
        case WatchModel_Move_C300:
            modelString = @"Move C300";
            break;
        case WatchModel_Zone_C410:
            modelString = @"Zone C410";
            break;
        case WatchModel_R420:
            modelString = @"R420";
            break;
        case WatchModel_R450:
            modelString = @"R450";
            break;
        case WatchModel_R500:
            modelString = @"R500";
            break;
        default:
            modelString = @"Move C300";
            break;
    }
     */

    //if (self.userDefaultsManager.watchModel != WatchModel_R450) {
     //   [SVProgressHUD showWithStatus:SYNC_SEARCH(modelString) maskType:SVProgressHUDMaskTypeClear];
    //}
    
    if (self.pairViewController && self.pairViewController.isViewLoaded) {
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    [SFASyncProgressView progressView].delegate = self;
    [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:YES showButton:YES];
    
    self.updateManager.delegate         = self;
    
    if (self.isResetWorkout) {
        self.resetWorkout = NO;
        [self.updateManager startResetWorkoutDatabase:self.userDefaultsManager.watchModel workoutSetting:self.workoutSetting];
    } else {
        [self.updateManager startUpdateSettingsWithWatchModel:self.userDefaultsManager.watchModel
                                          salutronUserProfile:self.userDefaultsManager.salutronUserProfile
                                                     timeDate:self.userDefaultsManager.timeDate/*[TimeDate getUpdatedData]*/
                                                sleepSettings:[SleepSetting sleepSetting]
                                                       wakeUp:self.userDefaultsManager.wakeUp//[[Wakeup alloc] initWithEntity:self.wakeupEntity]
                                              calibrationData:self.userDefaultsManager.calibrationData
                                                 notification:self.userDefaultsManager.notification
                                                inactiveAlert:[self.userDefaultsManager.inactiveAlert copy]
                                                dayLightAlert:[self.userDefaultsManager.dayLightAlert copy]
                                              nightLightAlert:[self.userDefaultsManager.nightLightAlert copy]
                                           notificationStatus:self.userDefaultsManager.notificationStatus
                                                       timing:self.userDefaultsManager.timing
                                               workoutSetting:self.workoutSetting];
    }
}

#pragma mark - Private Properties;

- (NSUserDefaults *) userDefaults
{
    if(!_userDefaults)
        _userDefaults = [NSUserDefaults standardUserDefaults];
    return _userDefaults;
}

- (NSManagedObjectContext *)managedObjectContext {
    if(!_managedObjectContext) {
        SFASalutronFitnessAppDelegate *appDelegate = (SFASalutronFitnessAppDelegate *)[UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (SFASalutronCModelSync *)salutronSyncC300 {
    if(!_salutronSyncC300) {
        _salutronSyncC300 = [[SFASalutronCModelSync alloc] initWithManagedObjectContext:self.managedObjectContext];
        _salutronSyncC300.delegate = self;
    }
    return _salutronSyncC300;
}


#pragma mark - SFASalutronSyncDelegate

- (void)didDeviceConnected
{
    
}

- (void)didPairWatch{
    self.isDisconnected = YES;
    /*[self cancelSyncing:nil];
    //[self startSyncConnectedRModel];*/
    
    //[self cancelSyncing:nil];
    //[self startSyncConnectedRModel];
    
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    [SFASyncProgressView hide];
    
    [SFASyncProgressView progressView].delegate = self;
    [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    _deviceFound = YES;
}

- (void)didSyncStarted
{
    if (self.userDefaultsManager.watchModel != WatchModel_R450) {
        //self.salutronSyncC300 = nil;
        self.salutronSyncC300.delegate = nil;
        [self showProgressForSearch];
        //[self updateWatchGoals];
    }
    
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    [SFASyncProgressView hide];
    
    [SFASyncProgressView progressView].delegate = self;
    [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    _deviceFound = YES;
}

- (void)didUpdateFinish
{
    [SFASyncProgressView hide];
    //[SVProgressHUD showSuccessWithStatus:SYNC_SUCCESS];
    [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
        
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    [self saveToCoreData];
    [self updateSettingsInUserDefaults];
    [self getCurrentSettings];
    
    [self.tableView reloadData];
}

- (void)didSyncFinished:(DeviceEntity *)deviceEntity
         profileUpdated:(BOOL)profileUpdated
{
    //[SVProgressHUD showSuccessWithStatus:SYNC_SUCCESS];
    [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
        
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    [self saveToCoreData];
    [self updateSettingsInUserDefaults];
    [self getCurrentSettings];
}

- (void)didDiscoverTimeout
{
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    //if (!self.isDisconnected) {
        self.isDisconnected = YES;
        [self.salutronSync stopSync];
        [SFASyncProgressView hide];
        
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    if ([self respondsToSelector:@selector(showTryAgainViewWithTarget:cancelSelector:tryAgainSelector:)] && !self.didCancel) {
        [self showTryAgainViewWithTarget:self
                          cancelSelector:@selector(cancelOnTimeoutClick)
                        tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
    }
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    //}
    //[SVProgressHUD showErrorWithStatus:SYNC_NOT_FOUND_MESSAGE];
}

- (void)didRaiseError{
    [self didDeviceDisconnected:NO];
}

- (void)didDeviceDisconnected:(BOOL)isSyncFinished
{
    if (!self.isDisconnected || !isSyncFinished) {
        self.isDisconnected = YES;
        //[SVProgressHUD showErrorWithStatus:DEVICE_DISCONNECTED];
        /*
        [SVProgressHUD dismiss];
        [SFASyncProgressView showWithMessage:DEVICE_DISCONNECTED animate:NO showOKButton:YES onButtonClick:^{
            [SFASyncProgressView hide];
        }];
        */
        
        [self.salutronSync stopSync];
        [SFASyncProgressView hide];
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
        if ([self respondsToSelector:@selector(showTryAgainViewWithTarget:cancelSelector:tryAgainSelector:)] && !self.didCancel) {
        [self showTryAgainViewWithTarget:self
                          cancelSelector:@selector(cancelOnTimeoutClick)
                        tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
         }
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    }
    
}

- (void)didChangeSettings
{
    [self.salutronSyncC300 useAppSettings];
}

- (void)didSaveSettings
{
    
}

- (void)didRetrieveDeviceFromSearching
{
    //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:NO showButton:YES];
    if (self.pairViewController && self.pairViewController.isViewLoaded) {
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES onButtonClick:^{
        [self.salutronSync stopSync];
    }];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0)
    {
        if (buttonIndex == 1)
        {
            [self showProgressForSearch];
        }
    }
    else if (alertView.tag == 1)
    {
        if (buttonIndex == 1)
        {
            /*
            NSString *identifier                = [DeviceEntity hasDeviceEntity] ? WELCOME_VIEW_CONTROLLER_IDENTIFIER : INTRO_VIEW_CONTROLLER_IDENTIFIER;
            UIViewController *viewController    = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            
            [self.userDefaults setBool:NO forKey:HAS_PAIRED];
            [self presentViewController:viewController animated:YES completion:nil];
             */
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:NO forKey:HAS_PAIRED];
            /*
                SFAWelcomeViewNavigationController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAWelcomeViewNavigationController"];
                //            SFAWelcomeViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAWelcomeViewController"];
                //[self performSegueWithIdentifier:@"MyAccountToWelcomeUnwind" sender:self];
                [self presentViewController:viewController animated:YES completion:nil];
            */
            SFALoadingViewController *rootController=(SFALoadingViewController *)((SFASalutronFitnessAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
            rootController.isSwitchWatch = YES;
            [rootController returnToRoot];
        }
    }
    else if (alertView.tag == 2)
    {
        if (buttonIndex == 1) {
            [self updateSettingsInUserDefaults];
            [self saveToCoreData];
            [self.slidingViewController anchorTopViewTo:ECRight];
        }
        else if (buttonIndex == 0){
            [self showProgressForSearch];
        }
    }
    else if (alertView.tag == 200) {
        if (buttonIndex == 1) {
            /*if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"HealthKitEnabled"] isEqualToNumber:@(1)]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:HEALTHAPP_CONNECT_MESSAGE
                                                               delegate:nil
                                                      cancelButtonTitle:BUTTON_TITLE_OK
                                                      otherButtonTitles:nil];
                alert.tag =  201;
                alert.delegate = self;
                [alert show];
            }
            else{*/
                [self saveDataToHealthStore];
            //}
        }
        else{
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"HealthKitEnabled"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else if (alertView.tag == 201) {
        if (buttonIndex == 1) {
        }
    }
}

#pragma mark - UIAlertSheet Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 2) {
        TimeDate *timeDate = [TimeDate getData];
        
        switch (buttonIndex) {
            case 0:
                timeDate.dateFormat = 0;
                [self.dateFormatButton setTitle:DATE_FORMAT_DDMMYY forState:UIControlStateNormal];
                break;
            case 1:
                timeDate.dateFormat = 1;
                [self.dateFormatButton setTitle:DATE_FORMAT_MMDDYY forState:UIControlStateNormal];
                break;
            case 2:
                timeDate.dateFormat = 3;
                [self.dateFormatButton setTitle:DATE_FORMAT_MMMDD forState:UIControlStateNormal];
                break;
            case 3:
                timeDate.dateFormat = 2;
                [self.dateFormatButton setTitle:DATE_FORMAT_DDMMM forState:UIControlStateNormal];
                break;

            default:
                break;
        }
        
        self.userDefaultsManager.timeDate = timeDate;
        [TimeDate saveWithTimeDate:timeDate];
    } else {
        if (buttonIndex == 0 ||
            buttonIndex == 1) {
            SFAImagePickerController *picker = [SFAImagePickerController new];
            picker.delegate = self;
            
            if (buttonIndex == 0) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            } else if (buttonIndex == 1) {
                picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
}

#pragma mark - UINavigationControllerDelegate Methods

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - UIImagePickerController Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [UIImage saveImage:image withMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
    [picker dismissViewControllerAnimated:YES completion:nil];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}
/*
#pragma mark - Private Methods

- (void)showPickerWithDate:(NSDate *)date
{
    self.datePickerContainerView.hidden = NO;
    for (id object in [self.datePickerContainerView subviews]) {
        if (self.timeButton.tag == 1) {
            if ([object isKindOfClass:[UIPickerView class]]) {
                UIPickerView *dayPicker = (UIPickerView *)object;
                self.dayPicker = dayPicker;
                self.dayPicker.delegate = self;
                self.dayPicker.dataSource = self;
                self.dayPicker.backgroundColor = [UIColor whiteColor];
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSInteger selectedIndex = 1;
                if ([userDefaults objectForKey:AUTO_SYNC_TIME_WEEKLY]) {
                      selectedIndex = [@[LS_MONDAY, LS_TUESDAY, LS_WEDNESDAY, LS_THURSDAY, LS_FRIDAY, LS_SATURDAY, LS_SUNDAY] indexOfObject:[userDefaults objectForKey:AUTO_SYNC_TIME_WEEKLY]];
                }
                [self.dayPicker selectRow:selectedIndex inComponent:0 animated:NO];
                [self.datePickerContainerView bringSubviewToFront:self.dayPicker];
            }
        }
        else{
        if ([object isKindOfClass:[UIDatePicker class]]) {
            UIDatePicker *datePicker = (UIDatePicker *)object;
            self.datePicker = datePicker;
            self.datePicker.backgroundColor = [UIColor whiteColor];
            [datePicker setDate:date];
            [self.datePickerContainerView bringSubviewToFront:self.datePicker];
            
            
            SyncSetupOption syncSetupOption = [[self.userDefaults objectForKey:AUTO_SYNC_OPTION] intValue];
            if (syncSetupOption == SyncSetupOptionOnce){
                [self.userDefaults removeObjectForKey:AUTO_SYNC_TIME_WEEKLY];
            }
        }
        }
    }
    [self.view bringSubviewToFront:self.datePickerContainerView];
}

- (IBAction)hidePicker:(id)sender
{
    NSDate *time                        = [self.datePicker date];
    NSDateComponents *timeComponents    = time.dateComponents;
    NSDate *date                        = [NSDate date];
    NSDateComponents *components        = date.dateComponents;
    components.hour                     = timeComponents.hour;
    components.minute                   = timeComponents.minute;
    components.second                   = timeComponents.second;
    NSCalendar *calendar                = [NSCalendar currentCalendar];
    date                                = [calendar dateFromComponents:components];
    
    
    TimeDate *timeDate = [TimeDate getData];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    if (timeDate.hourFormat == _12_HOUR) {
        [dateFormat setDateFormat:@"hh:mm a"];
    } else {
        [dateFormat setDateFormat:@"HH:mm"];
    }
    
    dateFormat.timeZone = [NSTimeZone localTimeZone];
    NSString *stringFromDate = [dateFormat stringFromDate:date];
    
    if (LANGUAGE_IS_FRENCH && timeDate.hourFormat == _24_HOUR) {
        stringFromDate = [stringFromDate stringByReplacingOccurrencesOfString:@":" withString:@"h"];
    }
    
    stringFromDate = [[stringFromDate stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];

    NSNumber *timestamp = [NSNumber numberWithDouble:[date timeIntervalSince1970]];
    
    if ([self isTimeValidWithStringFromDate:date]) {
        
        
        switch (self.timeButton.tag) {
            case 0:
                [self.userDefaults setObject:timestamp forKey:AUTO_SYNC_TIME_STAMP_1];
                [self.timeButton setTitle:stringFromDate forState:UIControlStateNormal];
                self.timeButton.titleLabel.minimumScaleFactor = 0.3f;
                break;
            case 1:
                [self setWeeklySchedule];
                break;
            default:
                break;
        }
        
        [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
    }
    else {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS_SYNC_INVALID_TIME
                                                                                     message:LS_SYNC_SCHEDULE_WARNING
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
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:LS_SYNC_INVALID_TIME message:LS_SYNC_SCHEDULE_WARNING delegate:nil cancelButtonTitle:nil otherButtonTitles:BUTTON_TITLE_OK, nil];
        [errorAlertView show];
        }
    }
    
    self.datePickerContainerView.hidden = YES;
}

 */
 
- (void)saveAutoSyncReminder{
    
    NSDate *time                        = [NSDate dateWithTimeIntervalSinceNow:[self.autoSyncTime intValue]];//self.autoSyncTime//[self.datePicker date];
    NSDateComponents *timeComponents    = time.dateComponents;
    NSDate *date                        = [NSDate date];
    NSDateComponents *components        = date.dateComponents;
    components.hour                     = timeComponents.hour;
    components.minute                   = timeComponents.minute;
    components.second                   = timeComponents.second;
    NSCalendar *calendar                = [NSCalendar currentCalendar];
    date                                = [calendar dateFromComponents:components];
    
    
    TimeDate *timeDate = [TimeDate getData];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    if (timeDate.hourFormat == _12_HOUR) {
        [dateFormat setDateFormat:@"hh:mm a"];
    } else {
        [dateFormat setDateFormat:@"HH:mm"];
    }
    
    dateFormat.timeZone = [NSTimeZone localTimeZone];
    NSString *stringFromDate = [dateFormat stringFromDate:date];
    
    if (LANGUAGE_IS_FRENCH && timeDate.hourFormat == _24_HOUR) {
        stringFromDate = [stringFromDate stringByReplacingOccurrencesOfString:@":" withString:@"h"];
    }
    
    stringFromDate = [[stringFromDate stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
    
    NSNumber *timestamp = [NSNumber numberWithDouble:[date timeIntervalSince1970]];
    
    if ([self isTimeValidWithStringFromDate:date]) {
        
        
        switch (self.timeButton.tag) {
            case 0:
                [self.userDefaults setObject:timestamp forKey:AUTO_SYNC_TIME_STAMP_1];
                [self.timeButton setTitle:stringFromDate forState:UIControlStateNormal];
                self.timeButton.titleLabel.minimumScaleFactor = 0.3f;
                break;
            case 1:
                [self setWeeklySchedule];
                break;
            default:
                break;
        }
        
        [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
    }
    else {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS_SYNC_INVALID_TIME
                                                                                     message:LS_SYNC_SCHEDULE_WARNING
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
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:LS_SYNC_INVALID_TIME message:LS_SYNC_SCHEDULE_WARNING delegate:nil cancelButtonTitle:nil otherButtonTitles:BUTTON_TITLE_OK, nil];
            [errorAlertView show];
        }
    }
    
    self.datePickerContainerView.hidden = YES;

}

- (void)setWeeklySchedule{
    [self.userDefaults setObject:self.autoSyncDay forKey:AUTO_SYNC_TIME_WEEKLY];
}

- (BOOL)isTimeValidWithStringFromDate:(NSDate *)date
{
    SyncSetupOption syncSetUpOption = [[self.userDefaults objectForKey:AUTO_SYNC_OPTION] integerValue];
    NSMutableArray *timestampArray = [[NSMutableArray alloc] init];
    
    switch (syncSetUpOption) {
        case SyncSetupOptionOff:
        case SyncSetupOptionOnce:
        case SyncSetupOptionOnceAWeek:
            return YES;
            break;
        /*
         case SyncSetupOptionTwice:
            [self.userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_1] ? [timestampArray addObject:[self.userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_1]] : [timestampArray addObject:@0];
            [self.userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_2] ? [timestampArray addObject:[self.userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_2]] : [timestampArray addObject:@0];
            break;
        
        case SyncSetupOptionFourTimes:
            [self.userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_1] ? [timestampArray addObject:[self.userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_1]] : [timestampArray addObject:@0];
            [self.userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_2] ? [timestampArray addObject:[self.userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_2]] : [timestampArray addObject:@0];
            [self.userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_3] ? [timestampArray addObject:[self.userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_3]] : [timestampArray addObject:@0];
            [self.userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_4] ? [timestampArray addObject:[self.userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_4]] : [timestampArray addObject:@0];
            break;
        */
        default:
            break;
    }
    
    NSNumber *newTimestamp = [NSNumber numberWithDouble:[date timeIntervalSince1970]];
    
    for (int i = 0; i < timestampArray.count; i++) {
        if (i != self.timeButton.tag) {
            NSNumber *timestamp = timestampArray[i];
            
            if ([newTimestamp isEqualToNumber:timestamp]) {
                return NO;
            }
        }
    }
    
    return YES;
}

/*
- (IBAction)timeButtonClicked:(UIButton *)sender
{
    self.timeButton = sender;
    / *
    if (self.timeButton.tag == 1) {
        self.dayPicker = [[UIPickerView alloc] initWithFrame:self.datePicker.frame];
        self.dayPicker.delegate = self;
        self.dayPicker.dataSource = self;
        self.dayPicker.showsSelectionIndicator = YES;
        self.dayPicker.backgroundColor = [UIColor whiteColor];
        [self.datePickerContainerView addSubview:self.dayPicker];
        [self.datePickerContainerView setHidden:NO];
        
        [self.view bringSubviewToFront:self.datePickerContainerView];
        
        UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
        [toolBar setBarStyle:UIBarStyleDefault];
        UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:BUTTON_TITLE_DONE
                                                                          style:UIBarButtonItemStyleBordered target:self action:@selector(hidePickerView)];
        toolBar.items = [[NSArray alloc] initWithObjects:barButtonDone,nil];
        barButtonDone.tintColor=[UIColor lightGrayColor];
        [self.dayPicker addSubview:toolBar];
        
        
        
    }
    else{
        * /
    
        / * December 11, 2014 - Fix for hour format for different languages. * /
        TimeDate *timeDate = [TimeDate getData];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
        if (timeDate.hourFormat == _12_HOUR) {
            [dateFormat setDateFormat:@"hh:mm a"];
        } else {
            [dateFormat setDateFormat:@"HH:mm"];
        }
    
        NSString *titleString = sender.titleLabel.text;
        if (LANGUAGE_IS_FRENCH) {
            titleString = [titleString stringByReplacingOccurrencesOfString:@"h" withString:@":"];
        }
    
        titleString = [[titleString stringByReplacingOccurrencesOfString:LS_AM withString:@"AM"] stringByReplacingOccurrencesOfString:LS_PM withString:@"PM"];
    
        NSDate *date = [dateFormat dateFromString:titleString];
        
        NSDateComponents *components    = date.dateComponents;
        components.month                = [NSDate date].dateComponents.month;
        components.day                  = [NSDate date].dateComponents.day;
        components.year                 = [NSDate date].dateComponents.year;
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        date                            = [calendar dateFromComponents:components];
        
        [self showPickerWithDate:date];
    //}
   
}
 */

#pragma mark - Sync Functions
- (IBAction)syncButtonPressed:(id)sender
{
    DDLogInfo(@"syncButtonPressed");
    /*if(!_bluetoothOn) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:TURN_ON_BLUETOOTH
                                                       delegate:nil
                                              cancelButtonTitle:BUTTON_TITLE_OK
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [self manualSyncPressed];*/
    
    if (self.userDefaultsManager.isBlueToothOn) {
        if (self.userDefaultsManager.watchModel != WatchModel_R450) {
            
            [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
            [self startSyncCModel];
        }
        else{
            [self startSyncRModel];
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



- (void)startSyncRModel
{
    DDLogInfo(@"");
    self.salutronSync                               = [[SFASalutronSync alloc] init];
    self.salutronSync.delegate                      = self;
    self.salutronSync.selectedWatchModel            = WatchModel_R450;
    self.salutronSync.connectDevice                 = YES;
    self.didCancel                                  = NO;
    [self.salutronSync searchConnectedDevice];
    //[self startSyncConnectedRModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startSyncCModel
{
    DDLogInfo(@"");
    self.salutronSyncC300.delegate = self;
    self.salutronSync.delegate = self;
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress];
    
    self.salutronSyncC300.updateTimeAndDate = self.userDefaultsManager.autoSyncTimeEnabled;
    [self.salutronSyncC300 startSyncWithDeviceEntity:deviceEntity watchModel:self.userDefaultsManager.watchModel];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didSearchConnectedWatch:(BOOL)found
{
    DDLogInfo(@"");
    
    if (!self.didCancel) {
        if (found) {
            //[self.pairViewController dismissViewControllerAnimated:YES completion:nil];
            //[self startSyncConnectedRModel];
            //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:YES showButton:YES];
            
            if (self.pairViewController && self.pairViewController.isViewLoaded) {
                [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
            }
            
            [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES onButtonClick:^{
                [self.salutronSync stopSync];
            }];
        } else {
            [SFASyncProgressView hide];
            if(!self.pairViewController){
                [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
            }
            [self.salutronSync startSync];
        }
    }
}

- (void)didDeviceConnectedFromSearching
{
    [SFASyncProgressView hide];
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    [self startSyncConnectedRModel];
}

- (void)startSyncConnectedRModel{
    DDLogInfo(@"");
    self.salutronSync                              = [[SFASalutronSync alloc] init];
    self.salutronSync.delegate                     = self;
    self.salutronSync.selectedWatchModel           = WatchModel_R450;
    
    if (self.pairViewController && self.pairViewController.isViewLoaded)
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    
    [SFASyncProgressView progressView].delegate = self;
    [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES onButtonClick:^{
        [self.salutronSync stopSync];
    }];
    //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:YES showButton:YES];
    
    //[self.salutronSync startSync];
    //[self updateWatchGoals];
    [self showProgressForSearch];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)cancelOnTimeoutClick
{
    [self hideTryAgainView];
    [self hideTryAgainView];
}

- (void)tryAgainOnTimeoutClick
{
    if (self.userDefaultsManager.isBlueToothOn) {
        
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            [self startSyncRModel];
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
    [self hideTryAgainView];
}

#pragma mark - Cancel sync

- (IBAction)cancelSyncing:(UIStoryboardSegue *)segue
{
    DDLogInfo(@"");
    
    [self.updateManager cancelSyncing];
    if ([segue.sourceViewController isKindOfClass:[SFAPairViewController class]]) {
        self.didCancel = YES;
        self.isStillSyncing = YES;
        
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
    
}

- (void)changeWatchImage
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:LS_IMAGE_SOURCE
                                                                 delegate:self
                                                        cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:LS_CAMERA, LS_IMAGE_LIBRARY, nil];
        [actionSheet showInView:self.view];
    } else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self.navigationController pushViewController:picker animated:YES];
    }
}

- (void)saveToCoreData
{
    TimeDate *timeDate                  = [TimeDate timeDate];
    Notification *notification          = [Notification notification];
    SleepSetting *sleepSetting          = [SleepSetting sleepSetting];
    CalibrationData *calibrationData    = [CalibrationData calibrationData];
    
    InactiveAlert *inactiveAlert        = [SFAUserDefaultsManager sharedManager].inactiveAlert;
    DayLightAlert *dayLightAlert        = [SFAUserDefaultsManager sharedManager].dayLightAlert;
    NightLightAlert *nightLightAlert    = [SFAUserDefaultsManager sharedManager].nightLightAlert;
    WorkoutSetting *workoutSetting      = [SFAUserDefaultsManager sharedManager].workoutSetting;
    
    [TimeDateEntity timeDateWithTimeDate:timeDate forDeviceEntity:self.deviceEntity];
    [NotificationEntity notificationWithNotification:notification notificationStatus:self.userDefaultsManager.notificationStatus forDeviceEntity:self.deviceEntity];
    [SleepSettingEntity sleepSettingWithSleepSetting:sleepSetting forDeviceEntity:self.deviceEntity];
    [CalibrationDataEntity calibrationDataWithCalibrationData:calibrationData forDeviceEntity:self.deviceEntity];
    
    [InactiveAlertEntity inactiveAlertWithInactiveAlert:inactiveAlert forDeviceEntity:self.deviceEntity];
    [DayLightAlertEntity dayLightAlertWithDayLightAlert:dayLightAlert forDeviceEntity:self.deviceEntity];
    [NightLightAlertEntity nightLightAlertWithNightLightAlert:nightLightAlert forDeviceEntity:self.deviceEntity];
    [WorkoutSettingEntity updateWorkoutSetting:workoutSetting forDeviceEntity:self.deviceEntity];
}

- (void)updateSettingsInUserDefaults
{
    TimeDate *timeDate                  = [TimeDate timeDate];
    Notification *notification          = [Notification notification];
    SleepSetting *sleepSetting          = [SleepSetting sleepSetting];
    CalibrationData *calibrationData    = [CalibrationData calibrationData];
    
    self.userDefaultsManager.timeDate           = timeDate;
    self.userDefaultsManager.notification       = notification;
    self.userDefaultsManager.sleepSetting       = sleepSetting;
    self.userDefaultsManager.calibrationData    = calibrationData;
    
    
}

#pragma mark - UITableViewDataSource Methods

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor  = BACKGROUND_COLOR;
    
    UIButton *switchWatchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    switchWatchButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        switchWatchButton.frame = CGRectMake(630, 10, 150, 40);
        if (LANGUAGE_IS_FRENCH) {
            switchWatchButton.frame = CGRectMake(600, 10, 160, 40);
        }
    }
    else{
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        switchWatchButton.frame = CGRectMake(screenWidth-130, 10, 120, 40);
        if (LANGUAGE_IS_FRENCH) {
            switchWatchButton.frame = CGRectMake(screenWidth-110, 10, 100, 40);
        }
    }
    switchWatchButton.titleLabel.textAlignment = NSTextAlignmentRight;
    //switchWatchButton.titleLabel.textColor = [UIColor blackColor];//LIFETRAK_COLOR;
    [switchWatchButton setTitleColor:LIFETRAK_COLOR forState:UIControlStateNormal];
    switchWatchButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    switchWatchButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    switchWatchButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    switchWatchButton.titleLabel.minimumScaleFactor = 0.5;
    
    if (section == 1) {
        [switchWatchButton setTitle:SETTING_SWITCH_WATCH forState:UIControlStateNormal];
        [switchWatchButton addTarget:self action:@selector(switchWatch) forControlEvents:UIControlEventTouchUpInside];
        
        BOOL hasButton = NO;
        for (id obj in header.subviews) {
            if ([obj isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)obj;
                if ([button.titleLabel.text isEqualToString:SETTING_SWITCH_WATCH]) {
                    hasButton = YES;
                    [obj setHidden:NO];
                }
                else{
                    hasButton = NO;
                    [obj setHidden:YES];
                }
            }
        }
        if (!hasButton) {
            [header addSubview:switchWatchButton];
        }
        switchWatchButton.hidden = NO;
    }
    else if (section == 3) {
        [switchWatchButton setTitle:SETTING_RESET_WORKOUT forState:UIControlStateNormal];
        [switchWatchButton addTarget:self action:@selector(resetWorkout) forControlEvents:UIControlEventTouchUpInside];
        BOOL hasButton = NO;
        for (id obj in header.subviews) {
            if ([obj isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)obj;
                if ([button.titleLabel.text isEqualToString:SETTING_RESET_WORKOUT]) {
                    hasButton = YES;
                    [obj setHidden:NO];
                }
                else{
                    hasButton = NO;
                    [obj setHidden:YES];
                }
            }
        }
        if (!hasButton) {
            [header addSubview:switchWatchButton];
        }
        switchWatchButton.hidden = NO;
    }
    else{
        for (id obj in header.subviews) {
            if ([obj isKindOfClass:[UIButton class]]) {
                [obj setHidden:YES];
            }
        }
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    footer.contentView.backgroundColor  = BACKGROUND_COLOR;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    /*
    if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
        return (self.watchModel == WatchModel_Core_C200 || self.watchModel == WatchModel_Move_C300 || self.watchModel == WatchModel_Move_C300_Android) ? 6 : 7;
    }
    else{
        return (self.watchModel == WatchModel_Core_C200 || self.watchModel == WatchModel_Move_C300 || self.watchModel == WatchModel_Move_C300_Android) ? 5 : 6;
    }
     */
    if (self.watchModel == WatchModel_R420) {
        return 4;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRowsInSection:section watchModel:self.watchModel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [self heightForFooterInSection:section watchModel:self.watchModel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self heightForHeaderInSection:section watchModel:self.watchModel];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self titleForHeaderInSection:section watchModel:self.watchModel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForRowAtIndexPath:indexPath watchModel:self.watchModel];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellForRowAtIndexPath:indexPath watchModel:self.watchModel];
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (self.watchModel == WatchModel_R450) {
                if (indexPath.row == 4) {
                    [self performSegueWithIdentifier:SMART_CALIBRATION_SEGUE sender:self];
                }
            }
            /*else if (self.watchModel == WatchModel_Zone_C410){
                if (indexPath.row == 1) {
                    [self performSegueWithIdentifier:SMART_CALIBRATION_SEGUE sender:self];
                }
             }*/
            break;
        case 1:
            if (self.watchModel == WatchModel_R450) {
                if (indexPath.row == 8) {
                    //Watch Alarms
                    [self performSegueWithIdentifier:ALARM_SETTINGS_SEGUE sender:self];
                }
                if (indexPath.row == 9) {
                    //Notifications
                    [self performSegueWithIdentifier:NOTIFICATIONS_SEGUE sender:self];
                }
                if (indexPath.row == 10) {
                    [self performSegueWithIdentifier:SMART_CALIBRATION_SEGUE sender:self];
                }
                if (indexPath.row == 11) {
                    //sync to watch
                    [self saveSettings];
                    
                    [self syncButtonPressed:self];
                }
            }
            else if (self.watchModel == WatchModel_Zone_C410){
                if (indexPath.row == 7) {
                    [self performSegueWithIdentifier:SMART_CALIBRATION_SEGUE sender:self];
                }
                if (indexPath.row == 8) {
                    //sync to watch
                    [self saveSettings];
                    [self syncButtonPressed:self];
                }
            }
            else if(self.watchModel == WatchModel_R420){
                if (indexPath.row == 7) {
                    [self performSegueWithIdentifier:SMART_CALIBRATION_SEGUE sender:self];
                }
                if (indexPath.row == 8) {
                    //sync to watch
                    [self saveSettings];
                    [self syncButtonPressed:self];
                }
            }
            else if (self.watchModel == WatchModel_Move_C300 || self.watchModel == WatchModel_Move_C300_Android){
                if (indexPath.row == 6) {
                    //sync to watch
                    [self saveSettings];
                    [self syncButtonPressed:self];
                }
            }
            break;
        case 2:
            if (indexPath.row == 1) {
                //synctocloud
                if (self.enableSyncToCloud) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
                    //[self syncButtonPressed:tableView];
                    [self restoreButtonPressed:tableView];
                }
            }
            break;
        /*
        case 0:
            if ((self.userDefaultsManager.watchModel != WatchModel_R500 && indexPath.row == 2) && !self.userDefaultsManager.autoSyncToWatchEnabled)
            {
                WatchModel watchModel   = self.userDefaultsManager.watchModel;
                NSString *model         = [SFAWatch watchModelStringForWatchModel:watchModel];
                if (self.isIOS8AndAbove) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:UNPAIR_ALERT_TITLE
                                                                                             message:UNPAIR_ALERT_MESSAGE(model)
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction = [UIAlertAction
                                                   actionWithTitle:BUTTON_TITLE_CANCEL
                                                   style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                                                   {
                                                       
                                                   }];
                    UIAlertAction *continueAction = [UIAlertAction
                                                     actionWithTitle:BUTTON_TITLE_CONTINUE
                                                     style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
                                                     {
                                                         NSString *identifier                = [DeviceEntity hasDeviceEntity] ? WELCOME_VIEW_CONTROLLER_IDENTIFIER : INTRO_VIEW_CONTROLLER_IDENTIFIER;
                                                         UIViewController *viewController    = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
                                                         
                                                         [self.userDefaults setBool:NO forKey:HAS_PAIRED];
                                                         [self presentViewController:viewController animated:YES completion:nil];;
                                                     }];
                    
                    [alertController addAction:cancelAction];
                    [alertController addAction:continueAction];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                else{
                UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:UNPAIR_ALERT_TITLE
                                                                     message:UNPAIR_ALERT_MESSAGE(model)
                                                                    delegate:self
                                                           cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                           otherButtonTitles:BUTTON_TITLE_CONTINUE, nil];
                alertView.tag           = 1;
                
                [alertView show];
                }
            }
            else if ([[self.userDefaults objectForKey:AUTO_SYNC_ALERT] boolValue] && indexPath.row > 0 && indexPath.row < 4) {
                [self setSyncSetupOption:indexPath.row];
                [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
            }
//
//                SyncSetupOption syncSetupOption = [[self.userDefaults objectForKey:AUTO_SYNC_OPTION] intValue];
//                
//                if (indexPath.row == 1) {
//                    if (syncSetupOption == SyncSetupOptionOnce) {
//                        
//                    }
//                }
//                else if (indexPath.row == 2) {
//                    if (syncSetupOption == SyncSetupOptionTwice) {
//                        
//                    }
//                    
//                }
//                else if (indexPath.row == 3) {
//                    if (syncSetupOption == SyncSetupOptionFourTimes) {
//                        
//                    }
//                }
//                else {
//                    
//                }
//            }

            break;
        case 5:
            if ((self.watchModel == WatchModel_Core_C200 || self.watchModel == WatchModel_Move_C300 || self.watchModel == WatchModel_Move_C300_Android) && [[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"HealthKitEnabled"] isEqualToNumber:@(1)]) {
                    if (self.isIOS8AndAbove) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                                 message:HEALTHAPP_CONNECT_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
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
                                                                        message:HEALTHAPP_CONNECT_MESSAGE
                                                                       delegate:nil
                                                              cancelButtonTitle:BUTTON_TITLE_OK
                                                              otherButtonTitles:nil];
                        alert.tag =  201;
                        alert.delegate = self;
                        [alert show];

                    }
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
                                                             [self saveDataToHealthStore];
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
            return;
        case 6:
            if ([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"HealthKitEnabled"] isEqualToNumber:@(1)]) {
                    if (self.isIOS8AndAbove) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                                 message:HEALTHAPP_CONNECT_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
                        
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
                                                                        message:HEALTHAPP_CONNECT_MESSAGE
                                                                       delegate:nil
                                                              cancelButtonTitle:BUTTON_TITLE_OK
                                                              otherButtonTitles:nil];
                        alert.tag =  201;
                        alert.delegate = self;
                        [alert show];
                    }
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
                                                       [self saveDataToHealthStore];
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
            break;
       */
         default:
            break;
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
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

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIView *superview = textField.superview;
    
    while (superview != nil) {
        if ([superview isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *)superview;
            [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell]
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
            
            break;
        }
        else {
            superview = superview.superview;
        }
    }
}

#pragma mark - SFAPairViewControllerDelegate Methods

- (void)didPressContinueInPairViewController:(SFAPairViewController *)viewController
{
    [self showProgressForSearch];
}

- (void)didPressCancelInPairViewController:(SFAPairViewController *)viewController
{
    self.updateManager.delegate = nil;
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
}
/*
#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    DDLogError(@"row = %i", row);
    NSString *pickedDay = [@[LS_MONDAY, LS_TUESDAY, LS_WEDNESDAY, LS_THURSDAY, LS_FRIDAY, LS_SATURDAY, LS_SUNDAY] objectAtIndex:row];
    [self.timeButton setTitle:pickedDay forState:UIControlStateNormal];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 7;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
   return [@[LS_MONDAY, LS_TUESDAY, LS_WEDNESDAY, LS_THURSDAY, LS_FRIDAY, LS_SATURDAY, LS_SUNDAY] objectAtIndex:row];
}

- (void)hidePickerView{
    [self.dayPicker resignFirstResponder];
}
 */

- (void)back:(UIBarButtonItem *)sender{
    /*
    if ([self settingsChanged]) {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kSettingsSync
                                                                                     message:NOTIFICATION_ALERT_NOT_SAVED
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *yesAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_YES_ALL_CAPS
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self showProgressForSearch];
                                       }];
            
            UIAlertAction *noAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_NO_ALL_CAPS
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self updateSettingsInUserDefaults];
                                           [self saveToCoreData];
                                           [self.slidingViewController anchorTopViewTo:ECRight];
                                       }];
            
            [alertController addAction:yesAction];
            [alertController addAction:noAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kSettingsSync message:NOTIFICATION_ALERT_NOT_SAVED delegate:self cancelButtonTitle:BUTTON_TITLE_YES_ALL_CAPS otherButtonTitles:BUTTON_TITLE_NO_ALL_CAPS, nil];
            alertView.tag = 2;
            [alertView show];
        }
    }
    else{
        [self.slidingViewController anchorTopViewTo:ECRight];
        [self updateSettingsInUserDefaults];
        [self saveToCoreData];
    }
     */
}

- (BOOL)settingsChanged{
    
    TimeDate *oldTimeDate = self.settingsArray[1];
    SalutronUserProfile *oldUserProfile = self.settingsArray[2];
    //SleepSetting *oldSleepSettings = self.settingsArray[3];
    if(self.watchModel == WatchModel_Move_C300 || self.watchModel == WatchModel_Move_C300_Android){
        if (self.settingsArray[0] != [NSNumber numberWithBool:self.userDefaultsManager.autoSyncTimeEnabled]) {
            return YES;
        }
        else if (oldTimeDate.hourFormat != [TimeDate getData].hourFormat){
            return YES;
        }
        else if (oldTimeDate.dateFormat != [TimeDate getData].dateFormat){
            return YES;
        }
        else if (oldTimeDate.watchFace != [TimeDate getData].watchFace){
            return YES;
        }
        else if (oldUserProfile.unit != [SalutronUserProfile getData].unit){
            return YES;
        }
    }
    else if(self.watchModel == WatchModel_Zone_C410 || self.watchModel == WatchModel_R420){
        if (self.settingsArray[0] != [NSNumber numberWithBool:self.userDefaultsManager.autoSyncTimeEnabled]) {
            return YES;
        }
        else if (oldTimeDate.hourFormat != [TimeDate getData].hourFormat){
            return YES;
        }
        else if (oldTimeDate.dateFormat != [TimeDate getData].dateFormat){
            return YES;
        }
        else if (oldTimeDate.watchFace != [TimeDate getData].watchFace){
            return YES;
        }
        else if (oldUserProfile.unit != [SalutronUserProfile getData].unit){
            return YES;
        }
        else if ([self calibrationDataChanged]){
            return YES;
        }
    }
    else{
        //if (self.settingsArray[0] != [NSNumber numberWithBool:self.userDefaultsManager.autoSyncTimeEnabled]) {
        //    return YES;
        //}
        //else
        if (oldTimeDate.hourFormat != [TimeDate getData].hourFormat){
            return YES;
        }
        else if (oldTimeDate.dateFormat != [TimeDate getData].dateFormat){
            return YES;
        }
        else if (oldTimeDate.watchFace != [TimeDate getData].watchFace){
            return YES;
        }
        else if (oldUserProfile.unit != [SalutronUserProfile getData].unit){
            return YES;
        }
        //else if (oldSleepSettings.sleep_mode != [SleepSetting sleepSetting].sleep_mode){
        //    return YES;
        //}
        //else if (self.settingsArray[4] != [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:PROMPT_CHANGE_SETTINGS]]){
        //    return YES;
        //}
        else if ([self nightLightAlertChanged]){
            return YES;
        }
        else if ([self dayLightAlertChanged]){
            return YES;
        }
        else if ([self inactiveAlertChanged]){
            return YES;
        }
        else if ([self wakeUpAlertChanged]){
            return YES;
        }
        else if ([self calibrationDataChanged]){
            return YES;
        }
        /*
         else if ([self notificationChanged]){
         return YES;
         }
         */
        else if (self.settingsArray.count > 11){
            if(self.settingsArray[11] != [NSNumber numberWithBool:self.userDefaultsManager.notificationStatus])
                return YES;
        }
    }
    return NO;
}

- (void)getCurrentSettings{
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
    NSNumber *currentAutoSync = [NSNumber numberWithBool:self.userDefaultsManager.autoSyncTimeEnabled];
    TimeDate *currentTimeDate = [TimeDate getData];
    SalutronUserProfile *currentProfile = [SalutronUserProfile getData];
    SleepSetting *currentSleepSetting = [SleepSetting sleepSetting];
    NSNumber *currentPromptChangeSettings = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:PROMPT_CHANGE_SETTINGS]];
    NightLightAlert *currentNightLightAlert = self.userDefaultsManager.nightLightAlert;
    DayLightAlert *currentDayLightAlert = self.userDefaultsManager.dayLightAlert;
    InactiveAlert *currentInactiveAlert = self.userDefaultsManager.inactiveAlert;
    WakeupEntity *currentWakeUp = [WakeupEntity getWakeup];
    CalibrationData *currentCalibrationData = [CalibrationData calibrationDataWithCalibrationDataEntity:deviceEntity.calibrationData];
    
    NSNumber *currentNightLightAlertStatus = [NSNumber numberWithBool:self.userDefaultsManager.nightLightAlert.status];
    NSNumber *currentDayLightAlertStatus = [NSNumber numberWithBool:self.userDefaultsManager.dayLightAlert.status];
    NSNumber *currentInactiveAlertStatus = [NSNumber numberWithBool:self.userDefaultsManager.inactiveAlert.status];
    NSNumber *currentWakeUpStatus = [WakeupEntity getWakeup].wakeupMode;
    
    Notification *currentNotification = self.userDefaultsManager.notification;
    NSNumber *currentNotificationStatus = [NSNumber numberWithBool:self.userDefaultsManager.notificationStatus];
    self.settingsArray = [[NSArray alloc] initWithObjects:
                          currentAutoSync,
                          //[self.userDefaults objectForKey:AUTO_SYNC_OPTION],
                          currentTimeDate,
                          currentProfile,
                          currentSleepSetting,
                          currentPromptChangeSettings,
                          currentNightLightAlert,
                          currentDayLightAlert,
                          currentInactiveAlert,
                          currentWakeUp,
                          currentCalibrationData,
                          currentNotification,
                          currentNotificationStatus,
                          currentNightLightAlertStatus,
                          currentDayLightAlertStatus,
                          currentInactiveAlertStatus,
                          currentWakeUpStatus,
                          nil];
    
    self.promptChangeSettings = self.userDefaultsManager.promptChangeSettings;
    self.deviceEntity = [DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress];
    self.timeDate = self.userDefaultsManager.timeDate;//[TimeDate getData];
    self.timeDate.watchFace = self.userDefaultsManager.watchFace;
    self.syncTime = self.userDefaultsManager.autoSyncTimeEnabled;
    self.userProfile = self.userDefaultsManager.salutronUserProfile;//[SalutronUserProfile getData];
    self.calibrationData = self.userDefaultsManager.calibrationData;//[CalibrationData calibrationDataWithCalibrationDataEntity:deviceEntity.calibrationData];
    self.enableSyncToCloud = self.userDefaultsManager.cloudSyncEnabled;
    self.autoSyncReminder = self.userDefaultsManager.autoSyncToWatchEnabled;
    self.workoutSetting = self.userDefaultsManager.workoutSetting;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.autoSyncTime = [userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_1];
    
    self.autoSyncDay = LS_MON;
    if ([userDefaults objectForKey:AUTO_SYNC_TIME_WEEKLY]) {
        self.autoSyncDay = [userDefaults objectForKey:AUTO_SYNC_TIME_WEEKLY];
        if([[self arrayDaysOfWeekFull] containsObject:self.autoSyncDay]){
            int selectedIndex = [[self arrayDaysOfWeekFull] indexOfObject:self.autoSyncDay];
            self.autoSyncDay = [[self arrayDaysOfWeek] objectAtIndex:selectedIndex];
        }
    }
    self.autoSyncSetupOption = [[userDefaults objectForKey:AUTO_SYNC_OPTION] intValue];
    
    self.hrLoggingRate = @(self.workoutSetting.HRLogRate);
    self.reconnectTimeout = @(self.workoutSetting.reconnectTimeout);
    
    if([self.hrLoggingRate integerValue] <= 0){
        self.hrLoggingRate = @(1);
    }
    
    if([self.reconnectTimeout integerValue] <= 5){
        self.reconnectTimeout = @(5);
    }
    
    self.workoutReconnectTimeout = @(self.workoutSetting.reconnectTimeout);
    
    CGFloat storageLeft = self.workoutSetting.databaseUsageMax - self.workoutSetting.databaseUsage;
    storageLeft -= 46.0f;
    storageLeft = storageLeft * self.hrLoggingRate.floatValue;
    storageLeft /= 1.125f;
    storageLeft /= 3600.0f;
    
    self.workoutStorageLeft = @(storageLeft);
}

- (BOOL)nightLightAlertChanged{
    NightLightAlert *oldNightLightAlert = self.settingsArray[5];
    if (oldNightLightAlert.status != self.userDefaultsManager.nightLightAlert.status) {
        return YES;
    }
    else if (oldNightLightAlert.level != self.userDefaultsManager.nightLightAlert.level) {
        return YES;
    }
    else if (oldNightLightAlert.duration != self.userDefaultsManager.nightLightAlert.duration) {
        return YES;
    }
    else if (oldNightLightAlert.start_hour != self.userDefaultsManager.nightLightAlert.start_hour) {
        return YES;
    }
    else if (oldNightLightAlert.start_min != self.userDefaultsManager.nightLightAlert.start_min) {
        return YES;
    }
    else if (oldNightLightAlert.end_hour != self.userDefaultsManager.nightLightAlert.end_hour) {
        return YES;
    }
    else if (oldNightLightAlert.end_min != self.userDefaultsManager.nightLightAlert.end_min) {
        return YES;
    }
    else if (self.settingsArray.count > 12) {
        if ([self.settingsArray[12] intValue] != self.userDefaultsManager.nightLightAlert.status)
        return YES;
    }
    return NO;
}

- (BOOL)dayLightAlertChanged{
    DayLightAlert *oldDayLightAlert = self.settingsArray[6];
    if (oldDayLightAlert.status != self.userDefaultsManager.dayLightAlert.status) {
        return YES;
    }
    else if (oldDayLightAlert.level != self.userDefaultsManager.dayLightAlert.level) {
        return YES;
    }
    else if (oldDayLightAlert.duration != self.userDefaultsManager.dayLightAlert.duration) {
        return YES;
    }
    else if (oldDayLightAlert.start_hour != self.userDefaultsManager.dayLightAlert.start_hour) {
        return YES;
    }
    else if (oldDayLightAlert.start_min != self.userDefaultsManager.dayLightAlert.start_min) {
        return YES;
    }
    else if (oldDayLightAlert.end_hour != self.userDefaultsManager.dayLightAlert.end_hour) {
        return YES;
    }
    else if (oldDayLightAlert.end_min != self.userDefaultsManager.dayLightAlert.end_min) {
        return YES;
    } else if (oldDayLightAlert.interval != self.userDefaultsManager.dayLightAlert.interval) {
        return YES;
    }
    else if (self.settingsArray.count > 13) {
        if ([self.settingsArray[13] intValue] != self.userDefaultsManager.dayLightAlert.status)
        return YES;
    }
    return NO;
}

- (BOOL)inactiveAlertChanged{
    InactiveAlert *oldInactivetAlert = self.settingsArray[7];
    if (oldInactivetAlert.status != self.userDefaultsManager.nightLightAlert.status) {
        return YES;
    }
    else if (oldInactivetAlert.time_duration != self.userDefaultsManager.inactiveAlert.time_duration) {
        return YES;
    }
    else if (oldInactivetAlert.steps_threshold != self.userDefaultsManager.inactiveAlert.steps_threshold) {
        return YES;
    }
    else if (oldInactivetAlert.start_hour != self.userDefaultsManager.inactiveAlert.start_hour) {
        return YES;
    }
    else if (oldInactivetAlert.start_min != self.userDefaultsManager.inactiveAlert.start_min) {
        return YES;
    }
    else if (oldInactivetAlert.end_hour != self.userDefaultsManager.inactiveAlert.end_hour) {
        return YES;
    }
    else if (oldInactivetAlert.end_min != self.userDefaultsManager.inactiveAlert.end_min) {
        return YES;
    }
    else if (self.settingsArray.count > 14) {
        if([self.settingsArray[14] intValue] != self.userDefaultsManager.inactiveAlert.status)
        return YES;
    }
    return NO;
}

- (BOOL)calibrationDataChanged{
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
    if (self.settingsArray.count > 9) {
        CalibrationData *oldCalibrationData = self.settingsArray[9];
        CalibrationData *newCalibrationData = [CalibrationData calibrationDataWithCalibrationDataEntity:deviceEntity.calibrationData];
        if (oldCalibrationData.calib_step != newCalibrationData.calib_step) {
            return YES;
        }
        else if (oldCalibrationData.calib_step != newCalibrationData.calib_step) {
            return YES;
        }
        else if (oldCalibrationData.calib_run != newCalibrationData.calib_run) {
            return YES;
        }
        else if (oldCalibrationData.calib_walk != newCalibrationData.calib_walk) {
            return YES;
        }
        //else if (oldCalibrationData.autoEL != newCalibrationData.autoEL) {
        //    return YES;
        //}
        else if (oldCalibrationData.calib_calo != newCalibrationData.calib_calo) {
            return YES;
        }
        return NO;
    }
    return NO;
}

- (BOOL)notificationChanged{
    Notification *oldNotification = self.settingsArray[10];
    Notification *newNotification = self.userDefaultsManager.notification;
    
    NSNumber *oldNotificationStatus = self.settingsArray[11];
    if (oldNotification.noti_email != newNotification.noti_email) {
        return YES;
    }
    else if (oldNotification.noti_hightPrio != newNotification.noti_hightPrio) {
        return YES;
    }
    else if (oldNotification.noti_incomingCall != newNotification.noti_incomingCall) {
        return YES;
    }
    else if (oldNotification.noti_missedCall != newNotification.noti_missedCall) {
        return YES;
    }
    else if (oldNotification.noti_news != newNotification.noti_news) {
        return YES;
    }
    else if (oldNotification.noti_schedule != newNotification.noti_schedule) {
        return YES;
    }
    else if (oldNotification.noti_simpleAlert != newNotification.noti_simpleAlert) {
        return YES;
    }
    else if (oldNotification.noti_sms != newNotification.noti_sms) {
        return YES;
    }
    else if (oldNotification.noti_social != newNotification.noti_social) {
        return YES;
    }
    else if (oldNotification.noti_voiceMail != newNotification.noti_voiceMail) {
        return YES;
    }
    else if (oldNotificationStatus != [NSNumber numberWithBool:self.userDefaultsManager.notificationStatus]) {
        return YES;
    }
    return NO;
}

- (BOOL)wakeUpAlertChanged{
    WakeupEntity *oldWakeUp = self.settingsArray[8];
    WakeupEntity *newWakeUp = [WakeupEntity getWakeup];
    
    if (oldWakeUp.wakeupMode.intValue != newWakeUp.wakeupMode.intValue) {
        return YES;
    }
    else if (oldWakeUp.wakeupHour.intValue != newWakeUp.wakeupHour.intValue) {
        return YES;
    }
    else if (oldWakeUp.wakeupMinute.intValue != newWakeUp.wakeupMinute.intValue) {
        return YES;
    }
    else if (oldWakeUp.wakeupWindow.intValue != newWakeUp.wakeupWindow.intValue) {
        return YES;
    }
    else if (oldWakeUp.snoozeMode.intValue != newWakeUp.snoozeMode.intValue) {
        return YES;
    }
    else if (oldWakeUp.snoozeMin.intValue != newWakeUp.snoozeMin.intValue) {
        return YES;
    }
    else if (self.settingsArray.count > 15) {
        if(self.settingsArray[15] != newWakeUp.wakeupMode)
        return YES;
    }
    return NO;
}

- (void)saveDataToHealthStore{
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

#pragma mark - Convert Android to iOS Mac Address

- (NSString *)convertAndroidToiOSMacAddress:(NSString *)macAddress
{
    return nil;
}

- (void)resetWorkout{
    self.resetWorkout = YES;
    [self syncButtonPressed:self];
}

- (void)switchWatch{
    DDLogInfo(@"");
    if (self.isIOS8AndAbove) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:SWITCH_ALERT_TITLE
                                                                                 message:SWITCH_ALERT_MESSAGE
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_CANCEL
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
        UIAlertAction *continueAction = [UIAlertAction
                                         actionWithTitle:BUTTON_TITLE_CONTINUE
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action)
                                         {
                                             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                             [userDefaults setBool:NO forKey:HAS_PAIRED];
                                             /*
                                             SFAWelcomeViewNavigationController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAWelcomeViewNavigationController"];
                                             //            SFAWelcomeViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAWelcomeViewController"];
                                             //[self performSegueWithIdentifier:@"MyAccountToWelcomeUnwind" sender:self];
                                             [self presentViewController:viewController animated:YES completion:nil];
                                             */
                                             SFALoadingViewController *rootController=(SFALoadingViewController *)((SFASalutronFitnessAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
                                             rootController.isSwitchWatch = YES;
                                             [rootController returnToRoot];
                                         }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:continueAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:SWITCH_ALERT_TITLE
                                                             message:SWITCH_ALERT_MESSAGE
                                                            delegate:self
                                                   cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                   otherButtonTitles:BUTTON_TITLE_CONTINUE, nil];
        alertView.tag           = 1;
        
        [alertView show];
    }

}

- (void)addGenericPickerView{
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(hidePickerView)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor blackColor];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.showsSelectionIndicator = YES;
    [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    
    
    self.genericPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (toolBar.frame.size.height + self.pickerView.frame.size.height), self.view.frame.size.width, toolBar.frame.size.height + self.pickerView.frame.size.height)];
    [self.genericPickerView addSubview:self.pickerView];
    [self.genericPickerView addSubview:toolBar];
    self.genericPickerView.hidden = YES;
    
    [self.view addSubview:self.genericPickerView];
}

- (void)hidePickerView{
    self.genericPickerView.hidden = YES;
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}


- (void)showCancelAndSave{
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChanges)];//[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    //self.saveButton.hidden = NO;
    UIBarButtonItem *newBackButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSettings)];//[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.rightBarButtonItem = newBackButton2;

}

- (void)hideCancelAndSave{
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MenuIcon"] style:UIBarButtonItemStyleBordered target:self action:@selector(menuButtonPressed:)];
    //[newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    /*UIBarButtonItem *newBackButton2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SyncNavigation"] style:UIBarButtonItemStyleBordered target:self action:@selector(syncButtonPressed:)];
    [newBackButton2 setImageInsets:UIEdgeInsetsMake(0, -15, 0, 15)];
    */
    self.navigationItem.rightBarButtonItem = nil;
    [self hidePickerView];
}

- (void)saveSettings{
    [self saveSettingsToUserDefaults];
    [self saveSettingsToCoreData];
    [self hidePickerView];
    [self hideCancelAndSave];
}

- (void)saveSettingsToUserDefaults{
    self.userDefaultsManager.promptChangeSettings = self.promptChangeSettings;
    self.userDefaultsManager.timeDate = self.timeDate;
    self.userDefaultsManager.watchFace = self.timeDate.watchFace;
    self.userDefaultsManager.autoSyncTimeEnabled = self.syncTime;
    self.userDefaultsManager.salutronUserProfile = self.userProfile;
    self.userDefaultsManager.calibrationData = self.calibrationData;
    self.userDefaultsManager.cloudSyncEnabled = self.enableSyncToCloud;
    self.userDefaultsManager.autoSyncToWatchEnabled = self.autoSyncReminder;
    self.userDefaultsManager.workoutSetting = self.workoutSetting;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.autoSyncTime forKey:AUTO_SYNC_TIME_STAMP_1];
    [userDefaults setObject:self.autoSyncDay forKey:AUTO_SYNC_TIME_WEEKLY];
    [userDefaults setObject:[NSNumber numberWithInt:self.autoSyncSetupOption] forKey:AUTO_SYNC_OPTION];
    
    if (self.autoSyncReminder) {
        [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
    }
}

- (void)saveSettingsToCoreData{
    
    [TimeDateEntity timeDateWithTimeDate:self.timeDate forDeviceEntity:self.deviceEntity];
    [CalibrationDataEntity calibrationDataWithCalibrationData:self.calibrationData forDeviceEntity:self.deviceEntity];
    [UserProfileEntity userProfileWithSalutronUserProfile:self.userProfile forDeviceEntity:self.deviceEntity];
    [WorkoutSettingEntity updateWorkoutSetting:self.workoutSetting forDeviceEntity:self.deviceEntity];
    
    [[JDACoreData sharedManager] save];
}

- (void)cancelChanges{
    [self getCurrentSettings];
    [self hidePickerView];
    [self hideCancelAndSave];
    [self.tableView reloadData];
}

- (void)showPickerView
{
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, self.genericPickerView.frame.size.height, 0)];
    [self.pickerView reloadAllComponents];
    self.genericPickerView.hidden = NO;
    if ([self.modifyingSettingName isEqualToString:SETTINGS_TIME_FORMAT]) {
        if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
            [self.pickerView selectRow:0 inComponent:0 animated:NO];
        }
        else{
            [self.pickerView selectRow:1 inComponent:0 animated:NO];
        }
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_DATE_FORMAT]){
        switch (self.timeDate.dateFormat) {
            case _DDMM:
                [self.pickerView selectRow:0 inComponent:0 animated:NO];
                break;
            case _MMDD:
                [self.pickerView selectRow:1 inComponent:0 animated:NO];
                break;
            case _MMMDD:
                [self.pickerView selectRow:2 inComponent:0 animated:NO];
                break;
            case _DDMMM:
                [self.pickerView selectRow:3 inComponent:0 animated:NO];
                break;
                
            default:
                break;
        }
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_UNITS]){
        if (self.userProfile.unit == IMPERIAL) {
            [self.pickerView selectRow:0 inComponent:0 animated:NO];
        }
        else{
            [self.pickerView selectRow:1 inComponent:0 animated:NO];
        }
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WATCH_DISPLAY]){
        if (self.timeDate.watchFace == _SIMPLE) {
            [self.pickerView selectRow:1 inComponent:0 animated:NO];
        }
        else{
            [self.pickerView selectRow:0 inComponent:0 animated:NO];
        }
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_DAY]){
        
        //NSDate *time = [NSDate dateWithTimeIntervalSince1970:[self.autoSyncTime intValue]];
        NSString *timeString =  [self convertTimestampToString:self.autoSyncTime withTimeDate:self.timeDate andAutoSyncDay:nil];
        NSString *hour;
        NSString *min;
        NSString *amPm;
        
        if (self.timeDate.hourFormat == _12_HOUR) {
            //[NSDate dateToString:time withFormat:@"hh:mm a"];
            hour = [[timeString componentsSeparatedByString:@":"] objectAtIndex:0];
            min  = [[[[timeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
            amPm = [[[[timeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1];
            amPm =  [amPm uppercaseString];
            if (([amPm isEqualToString:@"AM"] || [amPm isEqualToString:@"PM"]) && LANGUAGE_IS_FRENCH) {
                amPm = [amPm isEqualToString:@"AM"] ? LS_AM : LS_PM;
            }
            [self.pickerView selectRow:[[self arrayOf12Hours] indexOfObject:hour] inComponent:0 animated:NO];
            [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:1 animated:NO];
            [self.pickerView selectRow:[[self arrayOfAmPm] indexOfObject:amPm] inComponent:2 animated:NO];
        } else {
            //[NSDate dateToString:time withFormat:@"HH:mm"];
            if(LANGUAGE_IS_FRENCH){
                hour = [[timeString componentsSeparatedByString:@"h"] objectAtIndex:0];
                min = [[timeString componentsSeparatedByString:@"h"] objectAtIndex:1];
            }
            else{
                hour = [[timeString componentsSeparatedByString:@":"] objectAtIndex:0];
                min = [[timeString componentsSeparatedByString:@":"] objectAtIndex:1];
            }
            [self.pickerView selectRow:[[self arrayOf24Hours] indexOfObject:hour] inComponent:0 animated:NO];
            [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:1 animated:NO];
        }

    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_WEEK]){
        NSInteger selectedIndex = 0;
        if (self.autoSyncDay) {
            if([[self arrayDaysOfWeek] containsObject:self.autoSyncDay]){
                selectedIndex = [[self arrayDaysOfWeek] indexOfObject:self.autoSyncDay];
            }
            else{
                selectedIndex = [[self arrayDaysOfWeekFull] indexOfObject:self.autoSyncDay];
            }
        }
        [self.pickerView selectRow:selectedIndex inComponent:0 animated:NO];
        
        //NSDate *time = [NSDate dateWithTimeIntervalSince1970:[self.autoSyncTime intValue]];
        NSString *timeString = [self convertTimestampToString:self.autoSyncTime withTimeDate:self.timeDate andAutoSyncDay:nil];;
        NSString *hour;
        NSString *min;
        NSString *amPm;
        
        if (self.timeDate.hourFormat == _12_HOUR) {
            //[NSDate dateToString:time withFormat:@"hh:mm a"];
            hour = [[timeString componentsSeparatedByString:@":"] objectAtIndex:0];
            min  = [[[[timeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
            amPm =[[[[timeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1];
            amPm =  [amPm uppercaseString];
            if (([amPm isEqualToString:@"AM"] || [amPm isEqualToString:@"PM"]) && LANGUAGE_IS_FRENCH) {
                amPm = [amPm isEqualToString:@"AM"] ? LS_AM : LS_PM;
            }
            [self.pickerView selectRow:[[self arrayOf12Hours] indexOfObject:hour] inComponent:1 animated:NO];
            [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:2 animated:NO];
            [self.pickerView selectRow:[[self arrayOfAmPm] indexOfObject:amPm] inComponent:3 animated:NO];
        } else {
            //[NSDate dateToString:time withFormat:@"HH:mm"];
            if(LANGUAGE_IS_FRENCH){
                hour = [[timeString componentsSeparatedByString:@"h"] objectAtIndex:0];
                min = [[timeString componentsSeparatedByString:@"h"] objectAtIndex:1];
            }
            else{
                hour = [[timeString componentsSeparatedByString:@":"] objectAtIndex:0];
                min = [[timeString componentsSeparatedByString:@":"] objectAtIndex:1];
            }
            [self.pickerView selectRow:[[self arrayOf24Hours] indexOfObject:hour] inComponent:1 animated:NO];
            [self.pickerView selectRow:[[self arrayOfMinutes] indexOfObject:min] inComponent:2 animated:NO];
        }
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WS_HR_LOGGIN_RATE]){
        //if (self.timeDate.watchFace == _SIMPLE) {
            [self.pickerView selectRow:[[self arrayOfHRLoggingRate] indexOfObject:[self.hrLoggingRate stringValue]] inComponent:0 animated:NO];
        //}
        //else{
        //    [self.pickerView selectRow:0 inComponent:0 animated:NO];
        //}
    }
    else if([self.modifyingSettingName isEqualToString:SETTINGS_WS_RECONNECT_TIMEOUT]) {
        [self.pickerView selectRow:[[self arrayOfReconnectTimeout] indexOfObject:[self.reconnectTimeout stringValue]] inComponent:0 animated:NO];
    }
    

    //End editing causes self.modifyingsettingsname to be changed
    NSString *tempModifyingSettingName = self.modifyingSettingName;
    [self.view endEditing:YES];
    self.modifyingSettingName = tempModifyingSettingName;
}

#pragma mark - UIViewPickerViewDelegate
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([self.modifyingSettingName isEqualToString:SETTINGS_TIME_FORMAT]) {
        return 2;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_DATE_FORMAT]){
        if (self.watchModel == WatchModel_R450) {
            return 4;
        }
        return 2;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_UNITS]){
        return 2;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WATCH_DISPLAY]){
        return 2;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WS_HR_LOGGIN_RATE]){
        return 5;
    }
    else if([self.modifyingSettingName isEqualToString:SETTINGS_WS_RECONNECT_TIMEOUT]) {
        return [self arrayOfReconnectTimeout].count;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_DAY]){
        if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
            if (component == 0) {
                return 12;
            }
            else if (component == 1){
                return 60;
            }
            else if (component == 2){
                return 2;
            }
            return 1;
        }
        else{
            if (component == 0) {
                return 24;
            }
            else if (component == 1){
                return 60;
            }
            return 1;
        }
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_WEEK]){
        if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
            if (component == 0) {
                return 7;
            }
            else if (component == 1){
                return 12;
            }
            else if (component == 2){
                return 60;
            }
            else if (component == 3){
                return 2;
            }
            return 1;
        }
        else{
            if (component == 0) {
                return 7;
            }
            else if (component == 1){
                return 24;
            }
            else if (component == 2){
                return 60;
            }
            return 1;
        }
    }
    return 1;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if ([self.modifyingSettingName isEqualToString:SETTINGS_TIME_FORMAT]) {
        return 1;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_DATE_FORMAT]){
        return 1;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_UNITS]){
        return 1;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WATCH_DISPLAY]){
        return 1;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_DAY]){
        if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
            return 3;
        }
        return 2;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_WEEK]){
        if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
            return 4;
        }
        return 3;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WS_HR_LOGGIN_RATE]){
        return 1;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WS_RECONNECT_TIMEOUT]){
        return 1;
    }
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if ([self.modifyingSettingName isEqualToString:SETTINGS_TIME_FORMAT]) {
        return self.view.frame.size.width;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_DATE_FORMAT]){
        return self.view.frame.size.width;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_UNITS]){
        return self.view.frame.size.width;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WATCH_DISPLAY]){
        return self.view.frame.size.width;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WS_HR_LOGGIN_RATE]){
        return self.view.frame.size.width;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WS_RECONNECT_TIMEOUT]){
        return self.view.frame.size.width;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_DAY]){
        if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
            if (component == 2) {
                return LANGUAGE_IS_FRENCH ? 100 : 50;
            }
        }
        return 50;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_WEEK]){
        if (component == 0) {
            return 100;
        }
        if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
            if (component == 3) {
                return LANGUAGE_IS_FRENCH ? 100 : 50;
            }
        }
        return 50;
    }
    return self.view.frame.size.width;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
        tView.font = [UIFont systemFontOfSize:21.0];
        if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_DAY]) {
            if (self.timeDate.hourFormat == HOUR_FORMAT_12 && LANGUAGE_IS_FRENCH) {
                if (component == 2) {
                    tView.font = [UIFont systemFontOfSize:15.0];
                }
            }
        }
        else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_WEEK]){
            if (self.timeDate.hourFormat == HOUR_FORMAT_12  && LANGUAGE_IS_FRENCH) {
                if (component == 3) {
                    tView.font = [UIFont systemFontOfSize:15.0];
                }
            }
        }
        tView.textAlignment = NSTextAlignmentCenter;
        // Setup label properties - frame, font, colors etc
        tView.text = @"";
    }
    if ([self.modifyingSettingName isEqualToString:SETTINGS_TIME_FORMAT]) {
        
        tView.text = [@[SETTINGS_HOUR_FORMAT_12, SETTINGS_HOUR_FORMAT_24] objectAtIndex:row];
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_DATE_FORMAT]){
        tView.text = [@[DATE_FORMAT_DDMMYY, DATE_FORMAT_MMDDYY, DATE_FORMAT_MMMDD, DATE_FORMAT_DDMMM] objectAtIndex:row];
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_UNITS]){
        tView.text = [@[LS_IMPERIAL, LS_METRIC] objectAtIndex:row];
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WATCH_DISPLAY]){
        tView.text = [@[LS_FULL, LS_SIMPLE] objectAtIndex:row];
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WS_HR_LOGGIN_RATE]){
        tView.text = [[self arrayOfHRLoggingRate] objectAtIndex:row];
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WS_RECONNECT_TIMEOUT]){
        tView.text = [[self arrayOfReconnectTimeout] objectAtIndex:row];
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_DAY]){
        if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
            if (component == 0) {
                tView.text = [[self arrayOf12Hours] objectAtIndex:row];
            }
            else if (component == 1){
                tView.text = [[self arrayOfMinutes] objectAtIndex:row];
            }
            else if (component == 2){
                tView.text = [@[LS_AM, LS_PM] objectAtIndex:row];;
            }
        }
        else{
            if (component == 0) {
                tView.text = [[self arrayOf24Hours] objectAtIndex:row];
            }
            else if (component == 1){
                tView.text = [[self arrayOfMinutes] objectAtIndex:row];
            }
        }
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_WEEK]){
        if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
            if (component == 0) {
                tView.text = [[self arrayDaysOfWeek] objectAtIndex:row];
            }
            else if (component == 1) {
                tView.text = [[self arrayOf12Hours] objectAtIndex:row];
            }
            else if (component == 2){
                tView.text = [[self arrayOfMinutes] objectAtIndex:row];
            }
            else if (component == 3){
                tView.text = [[self arrayOfAmPm] objectAtIndex:row];;
            }
        }
        else{
            if (component == 0) {
                tView.text = [[self arrayDaysOfWeek] objectAtIndex:row];
            }
            else if (component == 1) {
                tView.text = [[self arrayOf24Hours] objectAtIndex:row];
            }
            else if (component == 2){
                tView.text = [[self arrayOfMinutes] objectAtIndex:row];
            }
        }
    }
    return tView;
}


/*
// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([self.modifyingSettingName isEqualToString:SETTINGS_TIME_FORMAT]) {
        
        return [@[SETTINGS_HOUR_FORMAT_12, SETTINGS_HOUR_FORMAT_24] objectAtIndex:row];
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_DATE_FORMAT]){
        return [@[DATE_FORMAT_DDMMYY, DATE_FORMAT_MMDDYY, DATE_FORMAT_MMMDD, DATE_FORMAT_DDMMM] objectAtIndex:row];
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_UNITS]){
        return [@[LS_IMPERIAL, LS_METRIC] objectAtIndex:row];
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WATCH_DISPLAY]){
        return [@[LS_FULL, LS_SIMPLE] objectAtIndex:row];
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_DAY]){
        if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
            if (component == 0) {
                return [[self arrayOf12Hours] objectAtIndex:row];
            }
            else if (component == 1){
                return [[self arrayOfMinutes] objectAtIndex:row];
            }
            else if (component == 2){
                return [@[LS_AM, LS_PM] objectAtIndex:row];;
            }
        }
        else{
            if (component == 0) {
                return [[self arrayOf24Hours] objectAtIndex:row];
            }
            else if (component == 1){
                return [[self arrayOfMinutes] objectAtIndex:row];
            }
        }
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_WEEK]){
        if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
            if (component == 0) {
                return [[self arrayDaysOfWeek] objectAtIndex:row];
            }
            else if (component == 1) {
                return [[self arrayOf12Hours] objectAtIndex:row];
            }
            else if (component == 2){
                return [[self arrayOfMinutes] objectAtIndex:row];
            }
            else if (component == 3){
                return [[self arrayOfAmPm] objectAtIndex:row];;
            }
        }
        else{
            if (component == 0) {
                return [[self arrayDaysOfWeek] objectAtIndex:row];
            }
            else if (component == 1) {
                return [[self arrayOf24Hours] objectAtIndex:row];
            }
            else if (component == 2){
                return [[self arrayOfMinutes] objectAtIndex:row];
            }
        }
    }

    return @"";
}
*/
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //self.pickerView.hidden = YES;
    
    if ([self.modifyingSettingName isEqualToString:SETTINGS_TIME_FORMAT]) {
        //return [@[SETTINGS_HOUR_FORMAT_12, SETTINGS_HOUR_FORMAT_24] objectAtIndex:row];
        if (row == 0) {
            self.timeDate.hourFormat = HOUR_FORMAT_12;
        }
        else{
            self.timeDate.hourFormat = HOUR_FORMAT_24;
        }
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_DATE_FORMAT]){
        //return [@[DATE_FORMAT_DDMMYY, DATE_FORMAT_MMDDYY, DATE_FORMAT_DDMMM, DATE_FORMAT_MMMDD] objectAtIndex:row];
        switch (row) {
            case 0:
                self.timeDate.dateFormat = _DDMM;
                break;
            case 1:
                self.timeDate.dateFormat = _MMDD;
                break;
            case 2:
                self.timeDate.dateFormat = _MMMDD;
                break;
            case 3:
                self.timeDate.dateFormat = _DDMMM;
                break;
            default:
                break;
        }
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_UNITS]){
        //return [@[LS_IMPERIAL, LS_METRIC] objectAtIndex:row];
        if (row == 0) {
            self.userProfile.unit = IMPERIAL;
        }
        else{
            self.userProfile.unit = METRIC;
        }
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WATCH_DISPLAY]){
        //return [@[LS_SIMPLE, LS_FULL] objectAtIndex:row];
        if (row == 0) {
            self.timeDate.watchFace = _FULL;
        }
        else{
            self.timeDate.watchFace = _SIMPLE;
        }
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WS_HR_LOGGIN_RATE]){
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        self.hrLoggingRate = [f numberFromString:[[self arrayOfHRLoggingRate] objectAtIndex:row]];
        self.workoutSetting.HRLogRate = self.hrLoggingRate.integerValue;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_WS_RECONNECT_TIMEOUT]){
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        self.reconnectTimeout = [f numberFromString:[[self arrayOfReconnectTimeout] objectAtIndex:row]];
        self.workoutSetting.reconnectTimeout = self.reconnectTimeout.integerValue;
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_DAY]){
        NSString *hour = @"9";
        NSString *min = @"00";
        NSString *amPm = @"AM";

        //NSDate *time = [NSDate dateWithTimeIntervalSince1970:[self.autoSyncTime intValue]];
        NSString *timeString = [self convertTimestampToString:self.autoSyncTime withTimeDate:self.timeDate andAutoSyncDay:nil];
        if (self.timeDate.hourFormat == _12_HOUR) {
            //[NSDate dateToString:time withFormat:@"hh:mm a"];
            hour = [[timeString componentsSeparatedByString:@":"] objectAtIndex:0];
            min  = [[[[timeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
            amPm = [[[[timeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1];
            amPm =  [amPm uppercaseString];
        } else {
            //[NSDate dateToString:time withFormat:@"HH:mm"];
            if(LANGUAGE_IS_FRENCH){
                hour = [[timeString componentsSeparatedByString:@"h"] objectAtIndex:0];
                min = [[timeString componentsSeparatedByString:@"h"] objectAtIndex:1];
            }
            else{
                hour = [[timeString componentsSeparatedByString:@":"] objectAtIndex:0];
                min = [[timeString componentsSeparatedByString:@":"] objectAtIndex:1];
            }
        }
        
        if (component == 0) {
            if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
                hour = [[self arrayOf12Hours] objectAtIndex:row];
            }
            else{
                hour = [[self arrayOf24Hours] objectAtIndex:row];
            }
        }
        else if (component == 1) {
            min = [[self arrayOfMinutes] objectAtIndex:row];
        }
        else if (component == 2) {
            amPm = [[self arrayOfAmPm] objectAtIndex:row];
        }
        //if (LANGUAGE_IS_FRENCH) {
        //    amPm = [amPm isEqualToString:LS_AM] ? @"AM" : @"PM";
        //}
        self.autoSyncTime = [self timeIntervalFromHour:hour min:min andAmPm:amPm];
    }
    else if ([self.modifyingSettingName isEqualToString:SETTINGS_ONCE_A_WEEK]){
        NSString *hour = @"9";
        NSString *min = @"00";
        NSString *amPm = @"AM";
        
        //NSDate *time = [NSDate dateWithTimeIntervalSince1970:[self.autoSyncTime intValue]];
        NSString *timeString = [self convertTimestampToString:self.autoSyncTime withTimeDate:self.timeDate andAutoSyncDay:nil];
        
        if (self.timeDate.hourFormat == _12_HOUR) {
            //[NSDate dateToString:time withFormat:@"hh:mm a"];
            hour = [[timeString componentsSeparatedByString:@":"] objectAtIndex:0];
            min  = [[[[timeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0];
            amPm = [[[[timeString componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1];
            amPm = [amPm uppercaseString];
        } else {
            //[NSDate dateToString:time withFormat:@"HH:mm"];
            if(LANGUAGE_IS_FRENCH){
                hour = [[timeString componentsSeparatedByString:@"h"] objectAtIndex:0];
                min = [[timeString componentsSeparatedByString:@"h"] objectAtIndex:1];
            }
            else{
                hour = [[timeString componentsSeparatedByString:@":"] objectAtIndex:0];
                min = [[timeString componentsSeparatedByString:@":"] objectAtIndex:1];
            }
        }
        
        if (component == 0) {
            NSString *selectedDay = [[self arrayDaysOfWeek] objectAtIndex:row];
            self.autoSyncDay = selectedDay;
        }
        if (component == 1) {
            if (self.timeDate.hourFormat == HOUR_FORMAT_12) {
                hour = [[self arrayOf12Hours] objectAtIndex:row];
            }
            else{
                hour = [[self arrayOf24Hours] objectAtIndex:row];
            }
        }
        else if (component == 2) {
            min = [[self arrayOfMinutes] objectAtIndex:row];
        }
        else if (component == 3) {
            amPm = [[self arrayOfAmPm] objectAtIndex:row];
        }
        //if (LANGUAGE_IS_FRENCH) {
        //    amPm = [amPm isEqualToString:LS_AM] ? @"AM" : @"PM";
        //}
        self.autoSyncTime = [self timeIntervalFromHour:hour min:min andAmPm:amPm];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //[self hidePickerView];
    //[self.view endEditing:YES];
}


- (NSNumber *)timeIntervalFromHour:(NSString *)hour min:(NSString *)min andAmPm:(NSString *)amPm{
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSString *timeString;
    
    if (self.timeDate.hourFormat == _12_HOUR) {
        if([amPm isEqualToString:LS_AM] && hour.intValue == 12){
            hour = [NSString stringWithFormat:@"00"];
        }
        else if ([amPm isEqualToString:LS_PM] && hour.intValue == 12){
            hour = [NSString stringWithFormat:@"12"];
        }
        else if([amPm isEqualToString:LS_PM]){
            hour = [NSString stringWithFormat:@"%i", (hour.intValue+12)%24];
        }
    }
        //[dateFormatter setDateFormat:@"hh:mm a"];
        //timeString = [NSString stringWithFormat:@"%@:%@ %@", hour, min, amPm];
    //} else {
        [dateFormatter setDateFormat:@"HH:mm"];
        timeString = [NSString stringWithFormat:@"%@:%@", hour, min];
    //}
    date = [dateFormatter dateFromString:timeString];
    return [NSNumber numberWithDouble:[date timeIntervalSince1970]];
}


- (NSArray *)arrayOfMinutes{
    return @[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09",
             @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19",
             @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29",
             @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39",
             @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49",
             @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59"];
}

- (NSArray *)arrayOf12Hours{
    return @[@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12"];
}

- (NSArray *)arrayOf24Hours{
    return @[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10",
             @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20",
             @"21", @"22", @"23"];
}

- (NSArray *)arrayDaysOfWeek{
    return @[LS_SUN, LS_MON, LS_TUE, LS_WED, LS_THU, LS_FRI, LS_SAT];
}

- (NSArray *)arrayDaysOfWeekFull{
    return @[LS_SUNDAY, LS_MONDAY, LS_TUESDAY, LS_WEDNESDAY, LS_THURSDAY, LS_FRIDAY, LS_SATURDAY];
}

- (NSArray *)arrayOfAmPm{
    return @[LS_AM, LS_PM];
}

- (NSArray *)arrayOfHRLoggingRate{
    return @[@"1", @"2", @"3", @"4", @"5"];
}

- (NSArray *)arrayOfReconnectTimeout {
    return @[@"5", @"6", @"7", @"8", @"9", @"10",
             @"11", @"12", @"13", @"14" , @"15",
             @"16", @"17", @"18", @"19", @"20",
             @"21", @"22", @"23", @"24", @"25",
             @"26", @"27", @"28", @"29", @"30"];
}

#pragma mark - Sync to cloud methods

- (IBAction)restoreButtonPressed:(id)sender
{
    DDLogInfo(@"");
    JDACoreData *coreData = [JDACoreData sharedManager];
    NSArray *devices = [coreData fetchEntityWithEntityName:DEVICE_ENTITY predicate:[NSPredicate predicateWithFormat:@"macAddress == %@ AND user.userID == %@", [[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS], [SFAServerAccountManager sharedManager].user.userID] limit:1];
    DeviceEntity *device = [devices firstObject];
    
    if ([devices count] > 0) {
        
        [SFASyncProgressView showWithMessage:LS_SYNC_TO_SERVER animate:YES showButton:YES onButtonClick:^{
            self.cancelSyncToCloudOperation = YES;
            [SFASyncProgressView hide];
            
            [self.syncToCloudOperation cancel];
            self.syncToCloudOperation = nil;
        }];
        
        //[self restoreDataFromServerWithDevice:device];
        //[self updateDataToServerWithDevice:device];
        
        SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
        [serverSyncManager getDeviceDataFromServerWithDevice:device userID:device.user.userID success:^(BOOL shouldRestoreFromServer) {
            
            if (shouldRestoreFromServer) {
                [self restoreDataFromServerWithDevice:device];
            }
            else{
                [self updateDataToServerWithDevice2:device];
//                if (self.watchModel == WatchModel_R420) {
//                    [self updateDataToServerWithDevice2:device];
//                }
//                else{
//                   [self updateDataToServerWithDevice:device];
//                }
            }
            
        } failure:^(NSError *error) {
            if (error.code == 1000) {
                if ([error.localizedDescription isEqualToString:@"Unable to retrieve device with specified mac address."]) {
                    [self updateDataToServerWithDevice2:device];
//                    if (self.watchModel == WatchModel_R420) {
//                        [self updateDataToServerWithDevice2:device];
//                    }
//                    else{
//                        [self updateDataToServerWithDevice:device];
//                    }

                }
                else {
                    [SFASyncProgressView hide];
                    self.syncToCloudOperation       = nil;
                    self.cancelSyncToCloudOperation = NO;
                }
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
    
    /*
     [SVProgressHUD showWithStatus:@"Syncing to cloud" maskType:SVProgressHUDMaskTypeBlack];
     SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
     */
    /*
     [SVProgressHUD showWithStatus:LS_SYNC_RESTORE_FROM_SERVER maskType:SVProgressHUDMaskTypeBlack];
     [serverSyncManager restoreDeviceEntity:self.device startDate:[NSDate UTCDateFromString:[self.device.lastDateSynced getDateString] withFormat:API_DATE_FORMAT] endDate:[NSDate UTCDateFromString:[[NSDate date] getDateString] withFormat:API_DATE_FORMAT] success:^{
     [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
     [SVProgressHUD showSuccessWithStatus:LS_SYNC_RESTORE_SUCCESS];
     } failure:^(NSError *error) {
     [SVProgressHUD dismiss];
     [self alertError:error];
     }];
     */
    /*
     [serverSyncManager restoreDeviceEntity:self.device
     startDateString:[NSDate dateToUTCString:self.device.updatedSynced withFormat:API_DATE_FORMAT]
     endDateString:[NSDate dateToUTCString:[NSDate date] withFormat:API_DATE_FORMAT] success:^{
     
     [self updateDataToServerWithDevice:self.device];
     
     } failure:^(NSError *error) {
     [SVProgressHUD dismiss];
     [self alertError:error];
     }];
     */
}

- (void)restoreDataFromServerWithDevice:(DeviceEntity *)device{
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    //if ([self.deviceEntity.modelNumber isEqualToNumber:@(WatchModel_R420)]) {
        [serverSyncManager restoreDeviceEntityAPIV2:self.deviceEntity success:^(NSDictionary *response) {
            NSString *bucketName = response[@"bucket"];
            NSString *folderName = response[@"uuid"];
            NSArray *filenames = response[@"files"];
            
            SFAAmazonServiceManager *amazonServiceManager = [SFAAmazonServiceManager sharedManager];
            amazonServiceManager.delegate = self;
            if (filenames.count > 0) {
                
                [amazonServiceManager downloadDataFromS3withBucketName:bucketName
                                                         andFilesNames:filenames
                                                         andFolderName:folderName
                                                       andDeviceEntity:self.deviceEntity];
            }
            else{
                DDLogError(@"no files to download from s3. response = %@", response);
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
//    [serverSyncManager restoreDeviceEntity:device
//                           startDateString:[NSDate dateToUTCString:device.lastDateSynced withFormat:API_DATE_FORMAT]
//                             endDateString:[NSDate dateToUTCString:[NSDate date] withFormat:API_DATE_FORMAT] success:^{
//                                 [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
//                                 [self.tableView reloadData];
//                                 
//                                 [SFASyncProgressView hide];
//                                 [SFASyncProgressView showWithMessage:LS_SYNC_SERVER_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
//                                     
//                                 }];
//                                 
//                                 self.syncToCloudOperation       = nil;
//                                 self.cancelSyncToCloudOperation = NO;
//                             } failure:^(NSError *error) {
//                                 if (!self.cancelSyncToCloudOperation){
//                                     [self alertError:error];
//                                 }
//                                 [SFASyncProgressView hide];
//                                 self.syncToCloudOperation       = nil;
//                                 self.cancelSyncToCloudOperation = NO;
//                             }];
//    }
}

- (void)updateDataToServerWithDevice:(DeviceEntity *)device{
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    self.syncToCloudOperation = [serverSyncManager syncDeviceEntity:device startDate:[NSDate UTCDateFromString:[device.lastDateSynced getDateString] withFormat:API_DATE_FORMAT] endDate:[NSDate UTCDateFromString:[[NSDate date] getDateString] withFormat:API_DATE_FORMAT] withSuccess:^(NSString *macAddress) {
        [self storeToServerWithMacAddress:macAddress];
        [StatisticalDataHeaderEntity setAllIsSyncedToServer:YES forDeviceEntity:self.deviceEntity];
        [WorkoutInfoEntity setAllIsSyncedToServer:YES forDeviceEntity:self.deviceEntity];
        [SleepDatabaseEntity setAllIsSyncedToServer:YES forDeviceEntity:self.deviceEntity];
        /*
         [SVProgressHUD showSuccessWithStatus:@"Restore from Server successful."];
         [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
         [SVProgressHUD showSuccessWithStatus:LS_SYNC_RESTORE_SUCCESS];
         
         */
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
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    
    [serverSyncManager storeWithMacAddress:macAddress success:^{
        
        NSDate *date                    = [NSDate date];
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:data forKey:self.deviceEntity.macAddress];
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
        //[SVProgressHUD showSuccessWithStatus:LS_SYNC_SERVER_SUCCESS];
        [self.tableView reloadData];
        
        [SFASyncProgressView hide];
        [SFASyncProgressView showWithMessage:LS_SYNC_SERVER_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
            
        }];
        self.syncToCloudOperation       = nil;
        self.cancelSyncToCloudOperation = NO;
        
        if ([userDefaults boolForKey:WALGREENS_EXPIRED_TOKEN]) {
            if (self.isIOS8AndAbove) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                         message:LS_WALGREENS_CONNECT_MESSAGE
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:BUTTON_TITLE_CANCEL
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   
                                               }];
                UIAlertAction *continueAction = [UIAlertAction
                                                 actionWithTitle:BUTTON_TITLE_CONTINUE
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action)
                                                 {
                                                     [SFASyncProgressView showWithMessage:LS_WALGREENS_RETRIEVE_MESSAGE animate:YES];
                                                     SFARewardsWebViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFARewardsWebViewController"];
                                                     
                                                     [[SFAWalgreensManager sharedManager] getConnectURLWithSuccess:^(NSURL *url, BOOL isConnected, BOOL isSynced) {
                                                         
                                                         [SFASyncProgressView hide];
                                                         viewController.url = url;
                                                         [self.navigationController pushViewController:viewController animated:YES];
                                                         
                                                     } failure:^(NSError *error) {
                                                         [SFASyncProgressView hide];
                                                     }];
                                                     
                                                 }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:continueAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else{
                UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:@""
                                                                     message:LS_WALGREENS_CONNECT_MESSAGE
                                                                    delegate:self
                                                           cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                           otherButtonTitles:BUTTON_TITLE_CONTINUE, nil];
                alertView.tag           = 3;
                
                [alertView show];
            }
        }
        
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

- (void)updateDataToServerWithDevice2:(DeviceEntity *)device{
    
    self.device = device;
    SFAAmazonServiceManager *amazonServiceManager = [SFAAmazonServiceManager sharedManager];
    amazonServiceManager.delegate = self;
    //[amazonServiceManager uploadArrayOfDataToS3:[[SFAServerSyncManager sharedManager] jsonStringWithDeviceEntityForMultipleDays:device]];
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
        NSDate *date                    = [NSDate date];
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:data forKey:self.deviceEntity.macAddress];
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
        //[SVProgressHUD showSuccessWithStatus:LS_SYNC_SERVER_SUCCESS];
        [self.tableView reloadData];
        
        [StatisticalDataHeaderEntity setAllIsSyncedToServer:YES forDeviceEntity:self.deviceEntity];
        [WorkoutInfoEntity setAllIsSyncedToServer:YES forDeviceEntity:self.deviceEntity];
        [SleepDatabaseEntity setAllIsSyncedToServer:YES forDeviceEntity:self.deviceEntity];
        
        [SFASyncProgressView hide];
        [SFASyncProgressView showWithMessage:LS_SYNC_SERVER_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
            
        }];
        self.syncToCloudOperation       = nil;
        self.cancelSyncToCloudOperation = NO;
        
        if ([userDefaults boolForKey:WALGREENS_EXPIRED_TOKEN]) {
            if (self.isIOS8AndAbove) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                         message:LS_WALGREENS_CONNECT_MESSAGE
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:BUTTON_TITLE_CANCEL
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   
                                               }];
                UIAlertAction *continueAction = [UIAlertAction
                                                 actionWithTitle:BUTTON_TITLE_CONTINUE
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *action)
                                                 {
                                                     [SFASyncProgressView showWithMessage:LS_WALGREENS_RETRIEVE_MESSAGE animate:YES];
                                                     SFARewardsWebViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFARewardsWebViewController"];
                                                     
                                                     [[SFAWalgreensManager sharedManager] getConnectURLWithSuccess:^(NSURL *url, BOOL isConnected, BOOL isSynced) {
                                                         
                                                         [SFASyncProgressView hide];
                                                         viewController.url = url;
                                                         [self.navigationController pushViewController:viewController animated:YES];
                                                         
                                                     } failure:^(NSError *error) {
                                                         [SFASyncProgressView hide];
                                                     }];
                                                     
                                                 }];
                
                [alertController addAction:cancelAction];
                [alertController addAction:continueAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else{
                UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:@""
                                                                     message:LS_WALGREENS_CONNECT_MESSAGE
                                                                    delegate:self
                                                           cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                           otherButtonTitles:BUTTON_TITLE_CONTINUE, nil];
                alertView.tag           = 3;
                
                [alertView show];
            }
        }
        
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

- (void)amazonServiceUploadFailedWithError:(NSError *)error{
    DDLogInfo(@"%@", error);
    [SVProgressHUD dismiss];
    if (!self.cancelSyncToCloudOperation){
        [self alertError:error];
    }
    [SFASyncProgressView hide];
    self.syncToCloudOperation       = nil;
    self.cancelSyncToCloudOperation = NO;
}

- (void)amazonServiceDownloadFinishedWithParameters:(NSDictionary *)parameters{
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    [self.tableView reloadData];
    
    [SFASyncProgressView hide];
    [SFASyncProgressView showWithMessage:LS_SYNC_SERVER_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
        
    }];
    
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


- (NSString *)convertTimestampToString:(NSNumber *)timestamp withTimeDate:(TimeDate *)timeDate andAutoSyncDay:(NSString *)autoSyncDay
{
    NSTimeInterval interval = [timestamp doubleValue];
    NSDate *date = [NSDate date];
    date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //TimeDate *timeDate = [TimeDate getData];
    
    if (timeDate.hourFormat == HOUR_FORMAT_12) {
        [dateFormatter setDateFormat:@"hh:mm a"];
    } else {
        [dateFormatter setDateFormat:@"HH:mm"];
    }
    
    if (!timestamp) {
        return nil;
    }
    else if ([dateFormatter stringFromDate:date]) {
        
        NSString *finalDateString = [dateFormatter stringFromDate:date];
        
        if (timeDate.hourFormat == HOUR_FORMAT_24 && LANGUAGE_IS_FRENCH) {
            finalDateString = [finalDateString stringByReplacingOccurrencesOfString:@":" withString:@"h"];
        }
        
        NSString *timeString;
        if(timeDate.hourFormat == _12_HOUR){
            NSString *time = [[finalDateString componentsSeparatedByString:@" "] objectAtIndex:0];
            [dateFormatter setDateFormat:@"HH:mm"];
            NSString *time24hrs = [dateFormatter stringFromDate:date];
            NSString *hour = [[time24hrs componentsSeparatedByString:@":"] objectAtIndex:0];
            if(hour.intValue > 11){
                timeString = [NSString stringWithFormat:@"%@ %@", time, LS_PM];
            }
            else{
                timeString = [NSString stringWithFormat:@"%@ %@", time, LS_AM];
            }
            finalDateString = timeString;
        }
        
        
        if (timeDate.hourFormat == _24_HOUR && LANGUAGE_IS_FRENCH) {
            finalDateString = [finalDateString stringByReplacingOccurrencesOfString:@":" withString:@"h"];
        }
        
        finalDateString = [[finalDateString stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
        
        if (autoSyncDay) {
            finalDateString = [NSString stringWithFormat:@"%@, %@", autoSyncDay, finalDateString];
        }
        return finalDateString;
    }
    return nil;
}

- (void)timeButtonClicked:(UIButton *)sender{
    
}

- (void)hidePicker:(id)sender{
    
}


@end