//
//  SFAMyAccountViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/25/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "ECSlidingViewController.h"
#import "UIViewController+Helper.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"

#import "DeviceEntity+Data.h"
#import "TimeDate+Data.h"
#import "SalutronUserProfile+Data.h"
#import "CalibrationData+Data.h"
#import "Wakeup+Data.h"
#import "SalutronUserProfile+Data.h"
#import "UserProfileEntity+Data.h"

#import "SFAServerSyncManager.h"
#import "SFAServerAccountManager.h"
#import "SFAWalgreensManager.h"
#import "SFAWatchSettingsWatchCell.h"
#import "SFAWatchSettingsWatchNameCell.h"

#import "SFAProfileCell.h"
#import "SFAProfileGenderCell.h"
#import "SFAButtonCell.h"
#import "SFAProfileServerSyncCell.h"
#import "SFAProfileEnableServerSyncTableViewCell.h"

#import "SFASalutronCModelSync.h"
#import "SFASalutronSync.h"
#import "JDACoreData.h"

#import "SFASyncProgressView.h"
#import "SFASettingsPromptView.h"

#import "SFAIntroViewController.h"
#import "SFAWelcomeViewController.h"
#import "SFAWelcomeViewNavigationController.h"
#import "SFARewardsWebViewController.h"
#import "SFAPairViewController.h"
#import "SFAMyAccountViewController.h"

#import "UIActionSheet+MKBlockAdditions.h"
#import "UIView+CircularMask.h"
#import "NSDate+Format.h"
#import "NSDate+Formatter.h"
#import "StatisticalDataHeaderEntity+Data.h"
#import "WorkoutInfoEntity+Data.h"
#import "SleepDatabaseEntity+Data.h"

#import "SFAHealthKitManager.h"
#import "SFAAmazonServiceManager.h"

#import "SFAMyAccountViewController+View.h"

#import "Flurry.h"

#define PROFILE_CELL            @"SFAProfileCell"
#define GENDER_CELL             @"SFAProfileGenderCell"
#define PREFERENCE_CELL         @"SFAPreferenceCell"
#define WATCH_CELL              @"SFAWatchSettingsWatchCell"
#define WATCH_NAME_CELL         @"SFAWatchSettingsWatchNameCell"
#define SERVER_SYNC_CELL        @"SFAProfileServerSyncCell"
#define WATCH_SYNC_CELL         @"SFAProfileWatchSyncCell"
#define DISCONNECT_WATCH_CELL   @"SFAWatchSettingsDisconnectWatchCell"
#define LOGOUT_CELL             @"SFALogoutCell"
#define ENABLE_CLOUD_CELL       @"SFAProfileEnableServerSyncTableViewCell"
#define ABOUT_ME_CELL_FOOTER    @"AboutMeFooter"

#define WELCOME_SEGUE_IDENTIFIER    @"MyAccountToWelcome"
#define PAIR_SEGUE_IDENTIFIER       @"MyAccountToPair"

@interface SFAMyAccountViewController () <UITableViewDataSource, UITableViewDelegate, SFASalutronSyncDelegate, SFAPairViewControllerDelegate, SFASettingsPromptViewDelegate, CBCentralManagerDelegate, UITextFieldDelegate, SFAProfileGenderCellDelegate, SFASalutronSyncDelegate, SFASyncProgressViewDelegate, SFAAmazonServiceManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (weak, nonatomic) IBOutlet UIImageView    *userImage;
@property (weak, nonatomic) IBOutlet UILabel        *userName;
@property (weak, nonatomic) IBOutlet UILabel        *userEmail;

@property (strong, nonatomic) DeviceEntity              *device;
@property (strong, nonatomic) SFASalutronCModelSync       *salutronSyncC300;
@property (strong, nonatomic) SFASalutronSync           *salutronSync;
@property (strong, nonatomic) SFAPairViewController     *pairViewController;
@property (strong, nonatomic) SFAUserDefaultsManager    *userDefaultsManager;
@property (strong, nonatomic) NSOperation               *syncToCloudOperation;
@property (strong, nonatomic) CBCentralManager          *centralManager;

@property (readwrite, nonatomic) BOOL   cancelSyncToCloudOperation;
@property (readwrite, nonatomic) BOOL   isSyncing;
@property (readwrite, nonatomic) BOOL   didCancel;
@property (readwrite, nonatomic) BOOL   bluetoothOn;
@property (readwrite, nonatomic) BOOL   isDisconnected;

@property (readwrite, nonatomic) BOOL                           isStillSyncing;



@property (nonatomic, getter = isEnableSyncToCloud) BOOL enableSyncToCloud;

@end

@implementation SFAMyAccountViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.inputContainer = self.tableView;
    [self setCloudSyncSwitchValue];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Flurry logEvent:MYACCOUNTS_PAGE];
    [self updateProfile];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[self updateCoreData];
    [self saveHeightAndWeightToHealthStore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Cloud sync value

- (void)setCloudSyncSwitchValue
{
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress];
    self.userDefaultsManager.cloudSyncEnabled = [deviceEntity.cloudSyncEnabled boolValue];
    self.enableSyncToCloud = self.userDefaultsManager.cloudSyncEnabled;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PAIR_SEGUE_IDENTIFIER]) {
        self.didCancel                                  = NO;
        self.pairViewController                         = (SFAPairViewController *)segue.destinationViewController;
        self.pairViewController.watchModel              = self.userDefaultsManager.watchModel;
        self.pairViewController.delegate                = self;
        self.pairViewController.showCancelSyncButton    = YES;
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
                return NO;
            }
        }
        
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
            [self startSyncRModel];
            return NO;
        }else{
            [self startSyncCModel];
            return YES;
        }
    }
    else if ([identifier isEqualToString:@"Cancel Sync"]) {
        return NO;
    }
    return YES;
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

#pragma mark- Sync

- (void)startSyncCModel
{
    self.salutronSyncC300.delegate = self;
    self.salutronSyncC300.updateTimeAndDate = self.userDefaultsManager.autoSyncTimeEnabled;
    [self.salutronSyncC300 startSyncWithDeviceEntity:self.device watchModel:self.userDefaultsManager.watchModel];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)startSyncRModel
{
    //self.salutronSync                              = [[SFASalutronSync alloc] init];
    self.salutronSync.delegate                     = self;
    self.salutronSync.selectedWatchModel           = WatchModel_R450;
    [self.salutronSync searchConnectedDevice];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startSyncRModelConnected
{
    //self.salutronSync                              = [[SFASalutronSync alloc] init];
    self.salutronSync.delegate                     = self;
    self.salutronSync.selectedWatchModel           = WatchModel_R450;
    self.salutronSync.syncType                     = SyncTypeAll;
    
    [SFASyncProgressView progressView].delegate = self;
    [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.salutronSync startSync];
}

- (void)didSearchConnectedWatch:(BOOL)found
{
    if (found) {
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
        [self startSyncRModelConnected];
    } else {
        [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
        //[self.salutronSync startSync];
    }
}

#pragma mark - Getters

- (DeviceEntity *)device
{
    if (!_device) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *macAddress = [userDefaults objectForKey:MAC_ADDRESS];
        _device = [DeviceEntity deviceEntityForMacAddress:macAddress];
    }
    
    return _device;
}

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

- (SFASalutronCModelSync *)salutronSyncC300
{
    if(!_salutronSyncC300) {
        JDACoreData *coreData = [JDACoreData sharedManager];
        _salutronSyncC300 = [[SFASalutronCModelSync alloc] initWithManagedObjectContext:coreData.context];
        _salutronSyncC300.delegate = self;
    }
    return _salutronSyncC300;
}

- (SFASalutronSync *)salutronSync
{
    if (!_salutronSync) {
        _salutronSync = [[SFASalutronSync alloc] init];
    }
    return _salutronSync;
}

#pragma mark - Setters

- (void)setEnableSyncToCloud:(BOOL)enableSyncToCloud
{
    _enableSyncToCloud = enableSyncToCloud;
    [SFAUserDefaultsManager sharedManager].cloudSyncEnabled = _enableSyncToCloud;
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            SFAWelcomeViewNavigationController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAWelcomeViewNavigationController"];
//            SFAWelcomeViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAWelcomeViewController"];
            [userDefaults setBool:NO forKey:HAS_PAIRED];
            //[self performSegueWithIdentifier:@"MyAccountToWelcomeUnwind" sender:self];
            [self presentViewController:viewController animated:YES completion:nil];
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
            SFAIntroViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAIntroViewController"];
            [manager logOut];
            [self presentViewController:viewController animated:YES completion:nil];
        }
    } else if (alertView.tag == 3) {
        if (buttonIndex == 1) {
            [SFASyncProgressView showWithMessage:LS_WALGREENS_RETRIEVE_MESSAGE animate:YES];
            SFARewardsWebViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFARewardsWebViewController"];
            
            [[SFAWalgreensManager sharedManager] getConnectURLWithSuccess:^(NSURL *url, BOOL isConnected, BOOL isSynced) {
                
                [SFASyncProgressView hide];
                viewController.url = url;
                [self.navigationController pushViewController:viewController animated:YES];
                
            } failure:^(NSError *error) {
                [SFASyncProgressView hide];
            }];
        }
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 4;
    } else if (section == 2){
        return self.isEnableSyncToCloud ? 2 : 1;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return LS_ABOUT_ME;
    } else if (section == 1) {
        return LS_MY_LIFETRAK;
    } else if (section == 2){
        return LS_CLOUD_SYNC;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 60.0f;
    } else if (section == 1) {
        return 10.0f;
    } else if (section == 2){
        return 80.0f;
    }
    
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ABOUT_ME_CELL_FOOTER];
        cell.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0];
        return cell;
    } else if (section == 1) {
        
    } else if (section == 2){
        SFAButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:LOGOUT_CELL];
        [cell.button addTarget:self action:@selector(logoutButtonPressed) forControlEvents:UIControlEventTouchDown];
        cell.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0];
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 44.0f;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return 95.0f;
        }
        return 44.0f;
    } else if (indexPath.section == 2){
        return 44.0f;
    }
    
    return 0.0f;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.view endEditing:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row < 3) {
            SFAProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:PROFILE_CELL];
            [cell setContentsWithProfileType:indexPath.row];
            return cell;
        } else if (indexPath.row == 3) {
            SFAProfileGenderCell *cell = [tableView dequeueReusableCellWithIdentifier:GENDER_CELL];
            cell.delegate = self;
            [cell setGenderContent];
            return cell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            SFAWatchSettingsWatchCell *cell = [tableView dequeueReusableCellWithIdentifier:WATCH_CELL];
            //[cell.watchImage addTarget:self action:@selector(changeWatchImage) forControlEvents:UIControlEventTouchDown];
            [cell setContentsWithWatchModel:self.device.modelNumber.integerValue];
            return cell;
        } else if (indexPath.row == 1) {
            SFAWatchSettingsWatchNameCell *cell = [tableView dequeueReusableCellWithIdentifier:WATCH_NAME_CELL];
            cell.watchName.text                 = self.device.name;
            return cell;
        } else if (indexPath.row == 2) {
            SFAProfileServerSyncCell *cell = [tableView dequeueReusableCellWithIdentifier:WATCH_SYNC_CELL];
            [cell setContentsWithDeviceEntity:self.device];
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        } else if (indexPath.row == 3) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DISCONNECT_WATCH_CELL];
            return cell;
        }
    } else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            SFAProfileEnableServerSyncTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ENABLE_CLOUD_CELL];
            return cell;
        }else if (self.isEnableSyncToCloud && indexPath.row == 1) {
            SFAProfileServerSyncCell *cell = [tableView dequeueReusableCellWithIdentifier:SERVER_SYNC_CELL];
            if (self.device.macAddress) {
                [cell setContentsWithMacAddress:self.device.macAddress];
            }
            return cell;
        }
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    if (indexPath.section == 0) {
        if (indexPath.row < 3) {
            SFAProfileCell *cell = (SFAProfileCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell.textField becomeFirstResponder];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            SFAWatchSettingsWatchNameCell *cell = (SFAWatchSettingsWatchNameCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell.watchName becomeFirstResponder];
        }
        else if (indexPath.row == 2) {
            //[self syncToWatch];
        }
        else if (indexPath.row == 3) {
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
                                               SFAWelcomeViewNavigationController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAWelcomeViewNavigationController"];
                                               //            SFAWelcomeViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAWelcomeViewController"];
                                               [userDefaults setBool:NO forKey:HAS_PAIRED];
                                               //[self performSegueWithIdentifier:@"MyAccountToWelcomeUnwind" sender:self];
                                               [self presentViewController:viewController animated:YES completion:nil];

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
    } else if (indexPath.section == 2){
        if (self.isEnableSyncToCloud && indexPath.row == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
            //[self syncButtonPressed:tableView];
            [self restoreButtonPressed:tableView];
        }
    }
}

#pragma mark - IBAction Methods

- (IBAction)menuButtonPressed:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)syncButtonPressed:(id)sender
{
        [SFASyncProgressView showWithMessage:LS_SYNC_TO_SERVER animate:YES showButton:YES onButtonClick:^{
        self.cancelSyncToCloudOperation = YES;
        [SFASyncProgressView hide];
        [self.syncToCloudOperation cancel];
        self.syncToCloudOperation = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    }];

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
        
        self.syncToCloudOperation = [serverSyncManager syncDeviceEntity:self.device withSuccess:^(NSString *macAddress) {
            [self storeToServerWithMacAddress:macAddress];
            [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
        } failure:^(NSError *error) {
            
            if (!self.cancelSyncToCloudOperation){
                [self alertError:error];
            }
            [SFASyncProgressView hide];
            self.syncToCloudOperation       = nil;
            self.cancelSyncToCloudOperation = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
        }];
        
    });
}


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
                [self updateDataToServerWithDevice:device];
            }
            
        } failure:^(NSError *error) {
            if (error.code == 1000) {
                if ([error.localizedDescription isEqualToString:@"Unable to retrieve device with specified mac address."]) {
                    [self updateDataToServerWithDevice:device];
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
    //if ([device.modelNumber isEqualToNumber:@(WatchModel_R420)]) {
        [serverSyncManager restoreDeviceEntityAPIV2:device
                                    startDateString:[NSDate dateToUTCString:device.lastDateSynced withFormat:API_DATE_FORMAT]
                                      endDateString:[NSDate dateToUTCString:[NSDate date] withFormat:API_DATE_FORMAT] success:^(NSDictionary *response) {
                                          NSString *bucketName = response[@"bucket"];
                                          NSString *folderName = response[@"uuid"];
                                          NSArray *filenames = response[@"files"];
                                          
                                          SFAAmazonServiceManager *amazonServiceManager = [SFAAmazonServiceManager sharedManager];
                                          amazonServiceManager.delegate = self;
                                          [amazonServiceManager downloadDataFromS3withBucketName:bucketName
                                                                                   andFilesNames:filenames
                                                                                   andFolderName:folderName
                                                                                 andDeviceEntity:device];
                                          
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
		[StatisticalDataHeaderEntity setAllIsSyncedToServer:YES forDeviceEntity:self.device];
		[WorkoutInfoEntity setAllIsSyncedToServer:YES forDeviceEntity:self.device];
		[SleepDatabaseEntity setAllIsSyncedToServer:YES forDeviceEntity:self.device];
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


- (IBAction)enableSyncToCloud:(id)sender
{
    self.enableSyncToCloud = !self.isEnableSyncToCloud;
    self.device.cloudSyncEnabled = [NSNumber numberWithBool:self.enableSyncToCloud];
    
    NSError *error = nil;
    
    JDACoreData *coreData = [JDACoreData sharedManager];
    [coreData.context save:&error];
    
    [self setCloudSyncSwitchValue];
    
    [self.tableView reloadData];
}
#pragma mark - Private Methods

- (void)storeToServerWithMacAddress:(NSString *)macAddress
{
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    
    [serverSyncManager storeWithMacAddress:macAddress success:^{
 
        NSDate *date                    = [NSDate date];
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:data forKey:self.device.macAddress];
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

- (void)updateProfile
{
    SFAServerAccountManager *manager    = [SFAServerAccountManager sharedManager];
    self.userName.text                  = [NSString stringWithFormat:@"%@ %@", manager.user.firstName, manager.user.lastName];
    self.userEmail.text                 = manager.user.emailAddress;
    NSURL *url                          = [NSURL URLWithString:manager.user.imageURL];
    UIImage *placeholderImage           = [UIImage imageNamed:@"ProfileDefaultPicture"];
    self.userImage.image                = nil;
//    [self.userImage setImageWithURL:url placeholderImage:placeholderImage options:SDWebImageRefreshCached];
    [self.userImage setImageWithURL:url placeholderImage:placeholderImage options:(SDWebImageRefreshCached |  SDWebImageAllowInvalidSSLCertificates)];
    [self.userImage addCircularMaskToBounds:self.userImage.frame];
    [self.userImage setNeedsDisplay];
}

- (void)logoutButtonPressed
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
                                       SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
                                       SFAIntroViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAIntroViewController"];
                                       [manager logOut];
                                       [self presentViewController:viewController animated:YES completion:nil];
                                   }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:kSettingsSignOut
                                                             message:MESSAGE_SIGN_OUT
                                                            delegate:self
                                                   cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                   otherButtonTitles:BUTTON_TITLE_OK, nil];
        alertView.tag           = 2;
        
        [alertView show];
    }
}

//- (void)syncToWatch
//{
//    [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
//}

- (void)updateCoreData
{
    SalutronUserProfile *userProfile = [SalutronUserProfile userProfile];
    [UserProfileEntity userProfileWithSalutronUserProfile:userProfile forDeviceEntity:self.device];
}

- (void)saveHeightAndWeightToHealthStore{
    DDLogInfo(@"");
    if([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
        //[[SFAHealthKitManager sharedManager] requestAuthorizationWithSuccess:^(BOOL success) {
         //   if (success) {
                SalutronUserProfile *userProfile = [SalutronUserProfile userProfile];
                [[SFAHealthKitManager sharedManager] saveHeight:(double)(userProfile.height/100.0)];
                [[SFAHealthKitManager sharedManager] saveWeight:round(userProfile.weight / 2.20462)];
        //    }
       // } failure:^(NSError *error) {
            
       // }];
    }
}

#pragma mark - Salutron sync delegate

- (void)didDiscoverTimeout
{
    /*
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    if (!self.didCancel) {
        [SFASyncProgressView showWithMessage:SYNC_NOT_FOUND_MESSAGE animate:NO showButton:NO dismiss:YES];
    }
    */
    /*
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    if (!self.isDisconnected) {
        self.isDisconnected = YES;
        [self.salutronSync stopSync];
        [SFASyncProgressView hide];
        
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
        [self showTryAgainViewWithTarget:self
                          cancelSelector:@selector(cancelOnTimeoutClick)
                        tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    }
    
    self.isSyncing = NO;
    //[SVProgressHUD showErrorWithStatus:SYNC_NOT_FOUND_MESSAGE];
     */DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (!self.didCancel) {
        [SFASyncProgressView hide];
        /*[SFASyncProgressView showWithMessage:SYNC_TIMEOUT animate:NO showOKButton:YES onButtonClick:^{
         [SFASyncProgressView hide];
         }];*/
        if ([self respondsToSelector:@selector(showTryAgainViewWithTarget:cancelSelector:tryAgainSelector:)]) {
        [self showTryAgainViewWithTarget:self
                                          cancelSelector:@selector(cancelOnTimeoutClick)
                                        tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
        }
        
    }
    else {
        
    }

}

- (void)didDiscoverTimeoutWithDiscoveredDevices:(NSArray *)discoveredDevices {
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    [self didDiscoverTimeout];
}

- (void)didDeviceConnected
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (self.isStillSyncing) {
        
        [SFASyncProgressView progressView].delegate = self;
        [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    }
}

- (void)didPairWatch
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (self.isStillSyncing) {
        [SFASyncProgressView progressView].delegate = self;
        [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
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
    [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
}

- (void)didSyncFinished:(DeviceEntity *)deviceEntity
{
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    
    self.userDefaultsManager.lastSyncedDate     = [NSDate date];
    self.userDefaultsManager.deviceUUID         = deviceEntity.uuid;
    self.userDefaultsManager.macAddress         = deviceEntity.macAddress;
    self.userDefaultsManager.cloudSyncEnabled   = [deviceEntity.cloudSyncEnabled boolValue];
    
    if (!self.userDefaultsManager.promptChangeSettings) {
        self.isSyncing = NO;
        [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
            
        }];
        //[SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showButton:NO dismiss:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
        
        if (self.userDefaultsManager.watchModel != WatchModel_R450) {
            [self.salutronSyncC300.salutronSDK commDone];
        }
        else {
            //self.salutronSync.delegate = nil;
        }
    }
    
    [self.tableView reloadData];
}

- (void)didUpdateFinish
{
    self.userDefaultsManager.lastSyncedDate     = [NSDate date];
    
    self.isSyncing = NO;
    //[SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showButton:NO dismiss:YES];
    [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
        
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    
    if (self.userDefaultsManager.watchModel != WatchModel_R450) {
        [self.salutronSyncC300.salutronSDK commDone];
    }
    else {
        //self.salutronSync.delegate = nil;
    }
    
    [self.tableView reloadData];
}

- (void)didSyncFinished:(DeviceEntity *)deviceEntity profileUpdated:(BOOL)profileUpdated
{
    [self didSyncFinished:deviceEntity];
    [self.pairViewController dismissViewControllerAnimated:YES completion:^{}];
    
    self.userDefaultsManager.lastSyncedDate     = [NSDate date];
    self.userDefaultsManager.deviceUUID         = deviceEntity.uuid;
    self.userDefaultsManager.macAddress         = deviceEntity.macAddress;
    self.userDefaultsManager.cloudSyncEnabled   = [deviceEntity.cloudSyncEnabled boolValue];
    
    self.isSyncing = NO;
    //[SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showButton:NO dismiss:YES];
    [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
        
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    
    if (self.userDefaultsManager.watchModel != WatchModel_R450) {
        [self.salutronSyncC300.salutronSDK commDone];
    }
    else {
        //self.salutronSync.delegate = nil;
    }

    [self.tableView reloadData];
}

- (void)didDisconnectDevice
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (self.userDefaultsManager.watchModel == WatchModel_R450) {
        [SFASyncProgressView hide];
        [SFASyncProgressView showWithMessage:SYNC_NOT_FOUND_MESSAGE animate:NO showButton:NO dismiss:YES];
    }
}

- (void)didDeviceDisconnected:(BOOL)isSyncFinished
{
    
    [self.pairViewController dismissViewControllerAnimated:YES completion:NULL];
    [SFASettingsPromptView hide];
    
    if (isSyncFinished && !self.didCancel) {
        
        [SFASyncProgressView progressView].delegate = self;
        //[SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showButton:NO dismiss:YES];
        [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
            
        }];
        
        [self.salutronSync stopSync];
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
         if ([self respondsToSelector:@selector(showTryAgainViewWithTarget:cancelSelector:tryAgainSelector:)]) {
        [self showTryAgainViewWithTarget:self
                                          cancelSelector:@selector(cancelOnTimeoutClick)
                                        tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
         }
    }
    
    self.isStillSyncing     = NO;
    self.didCancel          = NO;
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
    self.isSyncing = NO;
    [self.tableView reloadData];
    //[SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showButton:NO dismiss:YES];
    [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
        
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
}

#pragma mark - SFASettingsPromptViewDelegate Methods

- (void)didPressAppButtonOnSettingsPromptView:(SFASettingsPromptView *)view
{/*
    if (!self.userDefaultsManager.promptChangeSettings) {
        self.userDefaultsManager.syncOption = SyncOptionApp;
    }
    */
    [SFASyncProgressView showWithMessage:SYNC_SEARCH([self watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    
    if (self.userDefaultsManager.watchModel == WatchModel_R450) {
        [self.salutronSync useAppSettingsWithDelegate:self];
    }
    else {
        [self.salutronSyncC300 useAppSettings];
    }
}

- (void)didPressWatchButtonOnSettingsPromptView:(SFASettingsPromptView *)view
{/*
    if (!self.userDefaultsManager.promptChangeSettings) {
        self.userDefaultsManager.syncOption = SyncOptionWatch;
    }
    */
    [SFASyncProgressView showWithMessage:SYNC_SEARCH([self watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    
    if (self.userDefaultsManager.watchModel == WatchModel_R450) {
        [self.salutronSync useWatchSettingsWithDelegate:self];
    }
    else {
        [self.salutronSyncC300 useWatchSettings];
    }
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

#pragma mark - SFAPairViewController Methods

- (void)didPressContinueInPairViewController:(SFAPairViewController *)viewController
{
    
}

- (void)didPressCancelInPairViewController:(SFAPairViewController *)viewController
{
    [self.salutronSyncC300.salutronSDK commDone];
    [self.salutronSyncC300.salutronSDK disconnectDevice];
    //self.salutronSyncC300.salutronSDK.delegate = nil;
    
    [self.salutronSync.salutronSDK disconnectDevice];
    //self.salutronSync.salutronSDK.delegate = nil;

    //self.salutronSyncC300.delegate = nil;
    //self.salutronSync.delegate = nil;
}

#pragma mark - SFAProfileGenderCellDelegate

- (void)genderValueChanged{
    [self.view endEditing:YES];
}


- (void)cancelOnTimeoutClick
{
    [self hideTryAgainView];
    [self hideTryAgainView];
}

- (void)tryAgainOnTimeoutClick
{
    if (self.userDefaultsManager.watchModel == WatchModel_R450) {
        [self startSyncRModel];
    } else {
        [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
        [self startSyncCModel];
    }
    
    [self hideTryAgainView];
}

#pragma mark - Cancel sync

- (IBAction)cancelSyncing:(UIStoryboardSegue *)segue
{
    DDLogInfo(@"");
    
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
    [[SFAAmazonServiceManager sharedManager] cancelOperation];
    
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


- (void)genderValueChangedWithSalutronUserProfile:(SalutronUserProfile *)salutronUserProfile{
    
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


@end
