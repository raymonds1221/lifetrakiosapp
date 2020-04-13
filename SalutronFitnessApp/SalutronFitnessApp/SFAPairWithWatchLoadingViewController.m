//
//  SFAPairWithWatchLoadingViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/3/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAPairWithWatchLoadingViewController.h"
#import "SFASalutronLibrary.h"
#import "SFASalutronCModelSync.h"
#import "SFASalutronSync.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFAErrorMessageViewController.h"
#import "SFAPairWithWatchViewController.h"
#import "SFASalutronCModelSync.h"
#import "SFASalutronRModelSync.h"
#import "SFAFindingWatchViewController.h"
#import "SFASyncDataLoadingViewController.h"
#import "SFAServerAccountManager.h"
#import "SFALoadingViewController.h"

@interface SFAPairWithWatchLoadingViewController () <SFASalutronSyncDelegate, SFAErrorMessageViewControllerDelegate, SalutronSDKDelegate>


@property (strong, nonatomic) SFASalutronLibrary        *salutronLibrary;
@property (strong, nonatomic) SFASalutronCModelSync     *salutronCModelSync;
@property (strong, nonatomic) SFASalutronRModelSync     *salutronRModelSync;
@property (strong, nonatomic) SFASalutronSync           *salutronSync;
@property (strong, nonatomic) SFAUserDefaultsManager    *userDefaultsManager;
@property (strong, nonatomic) NSManagedObjectContext    *managedObjectContext;
@property (strong, nonatomic) CBCentralManager          *centralManager;
@property (nonatomic) BOOL pairingTimedOut;

@end

/*
 Step 2.b: Pair/connect watch and app.
 */

@implementation SFAPairWithWatchLoadingViewController

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
        _salutronCModelSync.delegate = self;
    }
    return _salutronCModelSync;
}

- (SFASalutronLibrary *) salutronLibrary
{
    if (!_salutronLibrary)
        _salutronLibrary = [[SFASalutronLibrary alloc] initWithManagedObjectContext:self.managedObjectContext];
    return _salutronLibrary;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = PAIR_WATCH_TITLE;
    self.mainLabel.text = PAIRING_WATCH;
    self.subLabel.text = PLEASE_WAIT;
    self.pairingTimedOut = NO;
    self.userDefaultsManager.autoSyncTimeEnabled = YES;
    
    if([SFAWatch isDeviceId:self.deviceModelString SameWithWatchModel:WatchModel_R450])
        self.watchModel = WatchModel_R450;
    else if([SFAWatch isDeviceId:self.deviceModelString SameWithWatchModel:WatchModel_Zone_C410])
        self.watchModel = WatchModel_Zone_C410;
    else if([SFAWatch isDeviceId:self.deviceModelString SameWithWatchModel:WatchModel_R420])
        self.watchModel = WatchModel_R420;
    else if([SFAWatch isDeviceId:self.deviceModelString SameWithWatchModel:WatchModel_Move_C300])
        self.watchModel = WatchModel_Move_C300;
    
    
    //[self performSelector:@selector(connectToCModel) withObject:nil afterDelay:0.0];
    
    /*if ([self.deviceModelString isEqualToString:WatchModel_C300_DeviceId] ||
        [self.deviceModelString isEqualToString:WatchModel_C410_DeviceId] ||
        [self.deviceModelString isEqualToString:WatchModel_R420_DeviceId]) {
        [self performSelector:@selector(connectToCModel) withObject:nil afterDelay:0.0];
        //[self connectToCModel];
        //[self.salutronCModelSync connectToDeviceWithIndex:self.deviceIndex withStatus:self.status];
    }
    else {//if ([self.deviceModelString isEqualToString:WatchModel_R450_DeviceId]){
        [self performSelector:@selector(connectToRModel) withObject:nil afterDelay:0.0];
        //[self connectToRModel];
    }*/
    //else{
        
    //}
    
    self.salutronCModelSync.delegate = self;
    [self performSelector:@selector(connectToCModel) withObject:nil afterDelay:0.0];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //self.salutronSDK.delegate = nil;
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
    [self disconnect];
}

- (void)rightButtonCicked:(id)sender{
    //[self performSegueWithIdentifier:@"PairWithWatchToSyncData" sender:self];
}

- (void)didSyncOnDataHeaders{
    [self performSegueWithIdentifier:@"PairWithWatchToSyncData" sender:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[SFASyncDataLoadingViewController class]]) {
        SFASyncDataLoadingViewController *vc    = segue.destinationViewController;
        vc.deviceIndex                          = self.deviceIndex;
        vc.deviceModelString                    = self.deviceModelString;
        vc.status                               = self.status;
        vc.watchModel                           = self.watchModel;
    }
}


- (void)showErrorMessage{
    SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
    vc.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc setErrorTitle:PAIRING_FAILED
            errorMessage1:MAKE_SURE_BLE_ENABLED
            errorMessage2:CHECK_BATTERY_LEVEL
            errorMessage3:KEEP_PHONE_AND_WATCH_RANGE
         andErrorMessage4:IF_STILL_CANNOT_BE_DETECTED
        andButtonPosition:1
             ButtonTitle1:LS_CANCEL
          andButtonTitle2:FIND_WATCH];
    });
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)erroMessageCenterButtonClicked{
    [self performSelector:@selector(disconnect) withObject:nil afterDelay:0.5];
    //[self dismissView];
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


- (void)dismissView{
    //NSString *macAddress = nil;
    // Status status = [self.salutronSyncC300.salutronSDK getMacAddress:&macAddress];
    [self.salutronSync.salutronSDK commDone];
    //Status status2 =
    [self.salutronCModelSync.salutronSDK disconnectDevice];
    [self.salutronCModelSync deleteDevice];
    [self.salutronSync deleteDevice];
    
    [self.salutronSync.salutronSDK disconnectDevice];
    
    self.salutronSync.delegate = nil;
    self.salutronSync.salutronSDK.delegate = nil;
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (void)connectToCModel{
    Status s = [self.salutronCModelSync connectDeviceAt:self.deviceIndex];
    if (s != NO_ERROR) {
        [self showErrorMessage];
    }
    else{
        self.pairingTimedOut = YES;
        [self performSelector:@selector(didPairingTimedOut) withObject:nil afterDelay:15.0];
    }
}

- (void)connectToRModel{
    //DeviceDetail *deviceDetail;
    //Status status = [self.salutronCModelSync.salutronSDK getDeviceDetail:self.deviceIndex with:&deviceDetail];//getConnectedDeviceDetail];
    //DDLogInfo(@"deviceDetail = %@  status = %@", deviceDetail, Status_toString[status]);
    Status s = [self.salutronCModelSync connectDeviceAt:self.deviceIndex];//retrieveConnectedDevices];
    if (s != NO_ERROR) {
        [self showErrorMessage];
    }
    else {
        self.pairingTimedOut = YES;
        [self performSelector:@selector(didPairingTimedOut) withObject:nil afterDelay:30.0];
    }
}

- (void)didPairingTimedOut{
    if (self.pairingTimedOut) {
        if (self.watchModel != WatchModel_R450) {
            [self.salutronCModelSync disconnectWatch];
        }
        [self showErrorMessage];
    }
}

- (void)didDeviceRetrieved:(NSInteger)numDevice withStatus:(Status)status{
    if (numDevice == 1) {
        Status s = [self.salutronCModelSync connectDeviceAt:0];
        if (s != NO_ERROR) {
            [self showErrorMessage];
        }
        else{
            
        }
    }
}


- (void)didDeviceDisconnected:(BOOL)isSyncFinished{
    DDLogInfo(@"");
    //if (status!= NO_ERROR) {
    //Possible causes: Phone is connected/paired to another device
        [self showErrorMessage];
    //}
}

- (void)didChecksumError{
    [self showErrorMessage];
}

- (void)didDeviceConnectedWithStatus:(Status)status{
    
    self.pairingTimedOut = NO;
    if (status == NO_ERROR) {
        
        SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
        NSArray *devices = [manager.user.device allObjects];
        NSString *macAddress;
        [self.salutronCModelSync.salutronSDK getMacAddress:&macAddress];
        BOOL alreadyAdded = NO;
        for (DeviceEntity *deviceEntity in devices) {
            DDLogInfo(@"deviceEntity.macAddress ?= macAddress\n %@ ?= %@", deviceEntity.macAddress, macAddress);
            NSString *savedMacAdress = deviceEntity.macAddress;
            if ([savedMacAdress rangeOfString:@":"].location != NSNotFound) {
                savedMacAdress = [self convertAndroidToiOSMacAddress:savedMacAdress];
            }
            if ([savedMacAdress isEqualToString:macAddress]) {
                alreadyAdded = YES;
                break;
            }
        }
        
        if (!alreadyAdded) {
            [self performSegueWithIdentifier:@"PairWithWatchToSyncData" sender:self];
            //[self performSegueWithIdentifier:@"PairinWithWatch1ToPairWithWatch2" sender:self];
        }
        else{
            SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
            vc.delegate = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [vc setErrorTitle:WATCH_ALREADY_ADDED
                    errorMessage1:WATCH_ALREADY_ADDED_DESC
                    errorMessage2:@""
                    errorMessage3:@""
                 andErrorMessage4:@""
                andButtonPosition:0
                     ButtonTitle1:BUTTON_TITLE_OK
                  andButtonTitle2:@""];
            });
            [self presentViewController:vc animated:YES completion:nil];
        }

        
        //[self performSegueWithIdentifier:@"PairWithWatchToSyncData" sender:self];
    }
}

- (void)disconnect{
    self.salutronCModelSync.delegate = nil;
    [self.salutronCModelSync.salutronSDK disconnectDevice];
    [self.salutronCModelSync.salutronSDK commDone];
    [self.salutronCModelSync deleteDevice];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    SFALoadingViewController *rootController=(SFALoadingViewController *)((SFASalutronFitnessAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    rootController.isSwitchWatch = YES;
    [rootController returnToRoot];
    
}

- (NSString *)convertAndroidToiOSMacAddress:(NSString *)macAddress
{
    NSArray *macAddressParts = [macAddress componentsSeparatedByString:@":"];
    NSInteger middle = [macAddressParts count] / 2;
    NSMutableString *convertedMacAddress = [NSMutableString new];
    
    for (NSInteger i = [macAddressParts count] - 1; i>=0; i--) {
        [convertedMacAddress appendString:[macAddressParts objectAtIndex:i]];
        
        if (middle == i) {
            [convertedMacAddress appendString:@"0000"];
        }
    }
    return [convertedMacAddress lowercaseString];
}

- (void)didSyncStarted{
    
}

- (void)didSyncFinished:(DeviceEntity *)deviceEntity profileUpdated:(BOOL)profileUpdated{
    
}

- (void)didChangeSettings{
    
}

- (void)didSaveSettings{
    
}

- (void)didDiscoverDevice:(int)numDevice withStatus:(Status)status{
    
}

- (void)didConnectAndSetupDeviceWithStatus:(Status)status{
    DDLogInfo(@"didConnectAndSetupDeviceWithStatus");
}

- (void)didDisconnectDevice:(Status)status{
    
}

- (void)didRetrieveConnectedDevice:(int)numDevice withStatus:(Status)status{
    
}

- (void)didGetBattLevel:(NSString *)battLevelString withStatus:(Status)status{
    
}

@end
