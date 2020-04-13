//
//  SFAFindingWatch2ViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/3/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAFindingWatch2ViewController.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFAErrorMessageViewController.h"
#import "SFAPairWithWatchViewController.h"
#import "SFAFindingWatchViewController.h"
#import "SFASalutronCModelSync.h"
#import "SFALoadingViewController.h"

#define DISCOVER_TIMEOUT 5

@interface SFAFindingWatch2ViewController () <CBCentralManagerDelegate, SFAErrorMessageViewControllerDelegate, SFASalutronSyncDelegate>

@property (strong, nonatomic) SFAUserDefaultsManager    *userDefaultsManager;
@property (strong, nonatomic) NSManagedObjectContext    *managedObjectContext;
@property (strong, nonatomic) CBCentralManager          *centralManager;
//Since this part only discovers devices, SFASalutronCModelSync can be used for both R and C watch models.
@property (strong, nonatomic) SFASalutronCModelSync     *salutronCModelSync;

@property (strong, nonatomic) NSMutableArray *devices;
@property (nonatomic) BOOL syncingCancelled;

@end

/*
 Step #1.b: Finding watch page do the following steps:
                - Retrieve connected watches on device for 3 seconds.
                - Discover devices in range for 5 seconds
                - Filter non-LifeTrak device by checking their names (We can filter by model number but R450 has no way of getting model number when it is already connected to the device, thus names are being used for filtering.)
 */

@implementation SFAFindingWatch2ViewController


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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initializeViews];
    [self initializeObjects];
}


- (void)viewWillDisappear:(BOOL)animated{
    self.salutronCModelSync.salutronSDK.delegate = nil;
    self.syncingCancelled = YES;
    self.salutronCModelSync.delegate = nil;
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
    //[self performSegueWithIdentifier:@"FindingWatchToPairWithWatch" sender:self];
}

- (void)disconnect{
    self.syncingCancelled = YES;
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

- (void)initializeViews{
    self.title = FIND_WATCH_TITLE;
    self.mainLabel.text = FINDING_WATCH;
    self.subLabel.text = PLEASE_WAIT;
}

- (void)initializeObjects{
    SFASalutronFitnessAppDelegate *appDelegate  = [UIApplication sharedApplication].delegate;
    self.managedObjectContext                   = appDelegate.managedObjectContext;
    
    self.centralManager                         = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.devices                                = [[NSMutableArray alloc] init];
    
    self.progressBarWidth.constant              = 0;
    self.syncingCancelled                       = NO;
    
    [self performSelector:@selector(jumpStart) withObject:nil afterDelay:0.5];
}

- (void)jumpStart{
    NSString *macAddress                = nil;
    [self.salutronCModelSync.salutronSDK getMacAddress:&macAddress];
    [self setProgressBarToFullWithSeconds:DISCOVER_TIMEOUT+2];
    [self performSelector:@selector(getConnectedDevices) withObject:nil afterDelay:0.5];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.syncingCancelled) {
            [self getDevicesInRange];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DISCOVER_TIMEOUT * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!self.syncingCancelled) {
                    NSMutableArray *filteredDevices = [[NSMutableArray alloc] init];
                    for (DeviceDetail *deviceDetail in self.devices) {
                        if ([deviceDetail.peripheral.name rangeOfString:@"Life Trak"].location != NSNotFound ||
                            [deviceDetail.peripheral.name rangeOfString:@"LifeTrak"].location != NSNotFound ||
                            [deviceDetail.peripheral.name rangeOfString:@"Brite"].location != NSNotFound ||
                            [deviceDetail.peripheral.name rangeOfString:@"R450"].location != NSNotFound ||
                            [deviceDetail.peripheral.name rangeOfString:@"R420"].location != NSNotFound ||
                            [deviceDetail.peripheral.name rangeOfString:@"C410"].location != NSNotFound ||
                            [deviceDetail.peripheral.name rangeOfString:@"C300"].location != NSNotFound ||
                            [deviceDetail.peripheral.name rangeOfString:@"C400"].location != NSNotFound) {
                            [filteredDevices addObject:deviceDetail];
                        }
                    }
                    
                    if(filteredDevices.count == 0){
                        self.progressBarWidth.constant = 160.0f;
                        [self performSelector:@selector(showErrorMessage) withObject:nil afterDelay:0.5];
                    }
                    else{
                        [self performSegueWithIdentifier:@"FindingWatchToPairWithWatch" sender:self];
                    }
                }
            });
        }
       
    });
    
    //[self performSelector:@selector(getConnectedDevices) withObject:nil afterDelay:0.5];
}

//Get connected R450 and other non-LifeTrak devices
- (void)getConnectedDevices{
    [self.devices removeAllObjects];
    [self.salutronCModelSync.salutronSDK clearDiscoveredDevice];
    Status s = [self.salutronCModelSync retrieveConnectedDevices];
    if (s != NO_ERROR) {
        DDLogInfo(@"ERROR = %@", Status_toString[s]);
        [self showErrorMessage];
    }
    /*
    else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //[self performSelector:@selector(getDevicesInRange) withObject:nil afterDelay:0.5];
            //[self getDevicesInRange];
            self.progressBarWidth.constant = 160.0f;
            
            NSMutableArray *filteredDevices = [[NSMutableArray alloc] init];
            for (DeviceDetail *deviceDetail in self.devices) {
                if ([deviceDetail.peripheral.name rangeOfString:@"Life Trak"].location != NSNotFound ||
                    [deviceDetail.peripheral.name rangeOfString:@"LifeTrak"].location != NSNotFound ||
                    [deviceDetail.peripheral.name rangeOfString:@"Brite"].location != NSNotFound) {
                    [filteredDevices addObject:deviceDetail];
                }
            }
            
            if(filteredDevices.count > 0){
                [self performSegueWithIdentifier:@"FindingWatchToPairWithWatch" sender:self];
            }
            else{
                self.progressBarWidth.constant = 160.0f;
                [self performSelector:@selector(showErrorMessage) withObject:nil afterDelay:0.5];
            }
        });
    }
     */
}

- (void)didDeviceRetrieved:(NSInteger)numDevice withStatus:(Status)status{
    if (numDevice > 0) {
        //[self.devices removeAllObjects];
        //[self.salutronCModelSync.salutronSDK clearDiscoveredDevice];
        for (int i=0; i<numDevice; i++) {
            DeviceDetail *deviceDetail = nil;
            //Status s =
            [self.salutronCModelSync getDeviceDetailAt:i with:&deviceDetail];
            DDLogInfo(@"deviceDetail = %@", deviceDetail);
            if (![self.devices containsObject:deviceDetail]) {
                [self.devices addObject:deviceDetail];
            }
        }
    }
    else{
    }
}

//Get not connected LifeTrak devices
- (void)getDevicesInRange{
    //[self.devices removeAllObjects];
    Status s = [self.salutronCModelSync discoverDevicesWithTimeout:DISCOVER_TIMEOUT];
    if (s != NO_ERROR) {
        DDLogInfo(@"ERROR = %@", Status_toString[s]);
        [self showErrorMessage];
    }
}

- (void)didDeviceDiscovered:(NSInteger)numDevice withStatus:(Status)status{
    DDLogInfo(@"\n---------------> STATUS: %@ NUM DEVICE : %d\n", Status_toString[status], numDevice);
    if (numDevice > 0 && !self.syncingCancelled) {
        //[self.devices removeeAllObjects];
        for (int i=0; i<numDevice; i++) {
            DeviceDetail *deviceDetail = nil;
            //Status s =
            [self.salutronCModelSync getDeviceDetailAt:i with:&deviceDetail];
            DDLogInfo(@"deviceDetail = %@", deviceDetail);
            if (![self.devices containsObject:deviceDetail]) {
                [self.devices addObject:deviceDetail];
            }
        }
    }
    else{
    }
}

/*
- (void)didDisconnectDevice:(Status)status{
    if(self.devices.count > 0){
        [self performSegueWithIdentifier:@"FindingWatchToPairWithWatch" sender:self];
    }
}
 */

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
}

#pragma mark - SFAErrorMessageViewControllerDelegate
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

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[SFAPairWithWatchViewController class]]) {
        SFAPairWithWatchViewController *pairWatchVC = segue.destinationViewController;
        pairWatchVC.devices = [self.devices copy];
    }
}

- (void)showErrorMessage{
    SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
    vc.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc setErrorTitle:NO_WATCH_DETECTED
            errorMessage1:MAKE_SURE_BLE_ENABLED
            errorMessage2:CHECK_BATTERY_LEVEL
            errorMessage3:KEEP_PHONE_AND_WATCH_RANGE
         andErrorMessage4:IF_STILL_CANNOT_BE_DETECTED
        andButtonPosition:1
             ButtonTitle1:LS_CANCEL
          andButtonTitle2:LS_TRY_AGAIN_CAPS];
    });
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)setProgressBarToFullWithSeconds:(int)seconds{
    self.progressBarWidth.constant = 0;
    int progressWidth = 160;
    int progressIncrement = (int)progressWidth/seconds;
    
    [self incrementProgressBarWith:progressIncrement maxValue:progressWidth];
}

- (void)incrementProgressBarWith:(int)increment maxValue:(int)max{
    int currentProgress = self.progressBarWidth.constant;
    currentProgress +=increment;
    if (currentProgress>=max) {
        currentProgress = max;
        [UIView animateWithDuration:1.0
                         animations:^{
                             self.progressBarWidth.constant = currentProgress;
                         }
                         completion:nil];
    }
    else{
        [UIView animateWithDuration:1.0
                         animations:^{
                             self.progressBarWidth.constant = currentProgress;
                         }
                         completion:nil];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self incrementProgressBarWith:increment maxValue:max];
            //do work
        });
    }
}

- (void)didSyncStarted{
    
}

- (void)didSyncFinished:(DeviceEntity *)deviceEntity profileUpdated:(BOOL)profileUpdated{
    
}

- (void)didChangeSettings{
    
}

- (void)didSaveSettings{
    
}

@end
