//
//  SFAPairWithWatchViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/3/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAPairWithWatchViewController.h"
#import "SFAPairWithWatchLoadingViewController.h"
#import "SFAWatchConnectTableViewCell.h"
#import "SFAWatchDetailsTableViewCell.h"
#import "SFASalutronLibrary.h"
#import "SFASalutronCModelSync.h"
#import "SFASalutronSync.h"
#import "SFAWatch.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFAErrorMessageViewController.h"
#import "SFAPairWithWatchViewController.h"
#import "SFAPairWithWatchHeaderCell.h"
#import "SFAFindingWatchViewController.h"
#import "SFAServerAccountManager.h"
#import "SFALoadingViewController.h"


#define WATCH_CELL_SINGLE       @"WatchCellSingle"
#define WATCH_CELL_MANY         @"WatchCellMany"
#define WATCH_DETAILS_COMPLETE  @"WatchDetailsCompleteCell"
#define WATCH_DETAILS_OVERVIEW  @"WatchDetailsOverviewCell"

@interface SFAPairWithWatchViewController () <UITableViewDelegate, UITableViewDataSource, SFAWatchConnectTableViewCellDelegate, SFAPairWithWatchHeaderCellDelegate, CBCentralManagerDelegate, SalutronSDKDelegate, SFASalutronSyncDelegate>

@property (strong, nonatomic) SFASalutronLibrary        *salutronLibrary;
@property (strong, nonatomic) SFASalutronCModelSync     *salutronCModelSync;
@property (strong, nonatomic) SFASalutronSync           *salutronSync;
@property (strong, nonatomic) SFAUserDefaultsManager    *userDefaultsManager;
@property (strong, nonatomic) NSManagedObjectContext    *managedObjectContext;
@property (strong, nonatomic) CBCentralManager          *centralManager;
@property (strong, nonatomic) SalutronSDK               *salutronSDK;
@property (strong, nonatomic) NSMutableArray            *otherProducts;
@property (strong, nonatomic) NSMutableArray            *accountConnectedwatchesUUID;
@property (strong, nonatomic) NSMutableArray            *filteredDevices;
@property (nonatomic) WatchModel    selectedWatchModel;
@property (nonatomic) int           deviceIndex;
@property (nonatomic) Status        discoverStatus;
@property (nonatomic) BOOL          bluetoothOn;
@end

/*
 Step #2.a: Show list of LifeTrak devices in range. 
 */
@implementation SFAPairWithWatchViewController
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
        //_salutronSyncC300.delegate = self;
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
    self.title = PAIR_WATCH_TITLE;
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.deviceIndex = 0;
    self.otherProducts = [[NSMutableArray alloc] init];
    [self.otherProducts addObject:WatchModel_C300_DeviceId];
    [self.otherProducts addObject:WatchModel_C410_DeviceId];
    [self.otherProducts addObject:WatchModel_R420_DeviceId];
    [self.otherProducts addObject:WatchModel_R450_DeviceId];
    
    self.filteredDevices = [[NSMutableArray alloc] init];
    
    for (DeviceDetail *deviceDetail in self.devices) {
        if ([self.otherProducts containsObject:[NSString stringWithFormat:@"%@", deviceDetail.deviceID]]) {
            [self.otherProducts removeObject:[NSString stringWithFormat:@"%@", deviceDetail.deviceID]];
        }
    }
    
    for (DeviceDetail *deviceDetail in self.devices) {
        
        if ([deviceDetail.peripheral.name rangeOfString:@"Life Trak"].location != NSNotFound ||
            [deviceDetail.peripheral.name rangeOfString:@"LifeTrak"].location != NSNotFound ||
            [deviceDetail.peripheral.name rangeOfString:@"Brite"].location != NSNotFound ||
            [deviceDetail.peripheral.name rangeOfString:@"R450"].location != NSNotFound ||
            [deviceDetail.peripheral.name rangeOfString:@"R420"].location != NSNotFound ||
            [deviceDetail.peripheral.name rangeOfString:@"C410"].location != NSNotFound ||
            [deviceDetail.peripheral.name rangeOfString:@"C300"].location != NSNotFound ||
            [deviceDetail.peripheral.name rangeOfString:@"C400"].location != NSNotFound) {
            [self.filteredDevices addObject:deviceDetail];
        }
    }
    
    SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
    self.accountConnectedwatchesUUID = [[NSMutableArray alloc] init];
    if (manager.isLoggedIn) {
        NSArray *accountConnectedDevices = [manager.user.device allObjects];
        for (DeviceEntity *deviceEntity in accountConnectedDevices) {
            [self.accountConnectedwatchesUUID addObject:deviceEntity.uuid];
        }
    }
    // Do any additional setup after loading the view.
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
    //[self performSegueWithIdentifier:@"PairinWithWatch1ToPairWithWatch2" sender:self];
}


- (void)disconnect{
    self.salutronCModelSync.delegate = nil;
    [self.salutronCModelSync.salutronSDK disconnectDevice];
    [self.salutronCModelSync.salutronSDK commDone];
    [self.salutronCModelSync deleteDevice];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    SFALoadingViewController *rootController = (SFALoadingViewController *)((SFASalutronFitnessAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    rootController.isSwitchWatch = YES;
    [rootController returnToRoot];
    
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.otherProducts.count == 0) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? self.devices.count : self.otherProducts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if ([self.filteredDevices containsObject:self.devices[indexPath.row]]) {
            return self.filteredDevices.count == 1 ? 277 : 145;
        }
        else{
            return 0;
        }
    }
    else if (indexPath.section == 1){
       // if (indexPath.row == 0) {
       //     return 296;
       // }
        return 104;
    }
    return 0;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return self.devices.count == 1 ? DETECTED_WATCH : DETECTED_WATCHES;
    }
    return self.otherProducts.count == 1 ? OTHER_PRODUCT : OTHER_PRODUCTS;
    //return section == 0 ? DETECTED_WATCH : OTHER_PRODUCTS;
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SFAPairWithWatchHeaderCell *header = [tableView dequeueReusableCellWithIdentifier:@"PairWithWatchHeader"];
    header.delegate = self;
    if (section == 0) {
        header.headerLabel.text = self.devices.count == 1 ? DETECTED_WATCH : DETECTED_WATCHES;
        header.headerButton.hidden = NO;
        header.headerButton.userInteractionEnabled = YES;
        [header.headerButton setTitle:FIND_WATCH forState:UIControlStateNormal];
    }
    else{
        header.headerLabel.text = self.otherProducts.count == 1 ? OTHER_PRODUCT : OTHER_PRODUCTS;
        header.headerButton.hidden = YES;
        header.headerButton.userInteractionEnabled = NO;
        [header.headerButton setTitle:@"" forState:UIControlStateNormal];
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        DeviceDetail *deviceDetail = self.devices[indexPath.row];
        DDLogInfo(@"deviceDetail = %@", deviceDetail);
        UIImage *image          = [self getWatchImageOfDeviceWithID:deviceDetail.deviceID];
        NSString *watchModel    = [self getWatchModelOfDeviceWithID:deviceDetail.deviceID];
        if (!image) {
            image = [self getWatchImageOfDeviceWithName:deviceDetail.peripheral.name];
        }
        if (!watchModel) {
            watchModel = [self getWatchModelOfDeviceWithName:deviceDetail.peripheral.name];
        }
        if ([self.filteredDevices containsObject:self.devices[indexPath.row]]) {
            
        if (self.filteredDevices.count == 1) {
            SFAWatchConnectTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:WATCH_CELL_SINGLE];
            cell.delegate                       = self;
            cell.watchImage.image               = image;
            cell.watchModel.text                = watchModel;
            cell.tag                            = indexPath.row;
            cell.watchNameLabel.text            = deviceDetail.peripheral.name;
            [cell.connectButton setTitle:CONNECT_WATCH_CAPS forState:UIControlStateNormal];
            [cell.connectButton setEnabled:YES];
            [cell.connectButton setUserInteractionEnabled:YES];
            cell.connectButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            cell.connectButton.titleLabel.minimumScaleFactor = 0.5;
            return cell;
        }
        else{
            SFAWatchConnectTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:WATCH_CELL_MANY];
            cell.delegate                       = self;
            cell.watchImage.image               = image;
            cell.watchModel.text                = watchModel;
            cell.tag                            = indexPath.row;
            cell.watchNameLabel.text            = deviceDetail.peripheral.name;
            [cell.connectButton setTitle:CONNECT_WATCH_CAPS forState:UIControlStateNormal];
            cell.connectButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            cell.connectButton.titleLabel.minimumScaleFactor = 0.5;
            return cell;
        }
        }
        else{
            return [UITableViewCell new];
        }
    }
    else if (indexPath.section == 1){
        NSObject *deviceID = self.otherProducts[indexPath.row];
        /*
        if (indexPath.row == 0) {
            SFAWatchDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WATCH_DETAILS_COMPLETE];
            [cell configureCellWithDeviceID:deviceID];
            return cell;
        }
        else {
            */
            SFAWatchDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WATCH_DETAILS_OVERVIEW];
            [cell configureCellWithDeviceID:deviceID];
            return cell;
        //}
    }
    return [UITableViewCell new];
}

#pragma mark - SFAWatchConnetCellDelegate
- (void)watchButtonClickedWithWatchName:(NSString *)watchName andCellTag:(int)tag{
    //connect watchxx
    DDLogInfo(@"Watch: %@", self.devices[tag]);
    self.deviceIndex = tag;

    if (!self.bluetoothOn) {
        [self alertWithTitle:@"" message:PLEASE_ENABLE_BLE];
    }
    else{
        /*
        DeviceDetail *deviceDetail = self.devices[tag];
        self.selectedWatchModel = [self getWatchModelNumberWithDeviceID:deviceDetail.deviceID];
        if (self.selectedWatchModel == WatchModel_Move_C300 || self.selectedWatchModel == WatchModel_Zone_C410) {
            [self startSyncCModel];
        }
        else if (self.selectedWatchModel == WatchModel_R450){
            [self startSyncRModel];
        }
        */
        [self performSegueWithIdentifier:@"PairinWithWatch1ToPairWithWatch2" sender:self];
    }
}

#pragma mark - Device Details

- (UIImage *)getWatchImageOfDeviceWithID:(NSObject *)deviceID{
    NSString *deviceIDString = [NSString stringWithFormat:@"%@", deviceID];
    if ([deviceIDString isEqual:WatchModel_C300_DeviceId]){
        if (self.filteredDevices.count == 1) {
            return [UIImage imageNamed:WATCHIMAGE_C300_C320];
        }
        return [UIImage imageNamed:WATCHIMAGE_C300];
    }
    else if ([deviceIDString isEqual:WatchModel_C410_DeviceId]){
        if (self.filteredDevices.count == 1) {
            return [UIImage imageNamed:WATCHIMAGE_C410_C410W];
        }
        return [UIImage imageNamed:WATCHIMAGE_C410];
    }
    else if ([deviceIDString isEqual:WatchModel_R420_DeviceId]){
        return [UIImage imageNamed:WATCHIMAGE_R420];
    }
    else if ([deviceIDString isEqual:WatchModel_R450_DeviceId]){
        return [UIImage imageNamed:WATCHIMAGE_R450];
    }
    else{
        return nil;
    }

}

- (NSString *)getWatchModelOfDeviceWithID:(NSObject *)deviceID{
    NSString *deviceIDString = [NSString stringWithFormat:@"%@", deviceID];
    if ([deviceIDString isEqualToString:WatchModel_C300_DeviceId]) {
        return WATCHNAME_MOVE_C300;
    }
    else if ([deviceIDString isEqualToString:WatchModel_C410_DeviceId]){
        return WATCHNAME_ZONE_C410;
    }
    else if ([deviceIDString isEqualToString:WatchModel_R420_DeviceId]){
        return WATCHNAME_R420;
    }
    else if ([deviceIDString isEqualToString:WatchModel_R450_DeviceId]){
        return WATCHNAME_BRITE_R450;
    }
    else{
        return nil;
    }
}

- (UIImage *)getWatchImageOfDeviceWithName:(NSString *)deviceName{
    if ([deviceName rangeOfString:@"C300"].location != NSNotFound ||
        [deviceName rangeOfString:@"C400"].location != NSNotFound ||
        [deviceName rangeOfString:@"Move"].location != NSNotFound){
        if (self.filteredDevices.count == 1) {
            return [UIImage imageNamed:WATCHIMAGE_C300_C320];
        }
        return [UIImage imageNamed:WATCHIMAGE_C300];
    }
    else if ([deviceName rangeOfString:@"C410"].location != NSNotFound ||
             [deviceName rangeOfString:@"Zone"].location != NSNotFound){
        if (self.filteredDevices.count == 1) {
            return [UIImage imageNamed:WATCHIMAGE_C410_C410W];
        }
        return [UIImage imageNamed:WATCHIMAGE_C410];
    }
    else if ([deviceName rangeOfString:@"R450"].location != NSNotFound ||
             [deviceName rangeOfString:@"Brite"].location != NSNotFound){
        return [UIImage imageNamed:WATCHIMAGE_R450];
    }
    else{
        return [UIImage imageNamed:WATCHIMAGE_R500];
    }
    
}

- (NSString *)getWatchModelOfDeviceWithName:(NSString *)deviceName{
    if ([deviceName rangeOfString:@"C300"].location != NSNotFound ||
        [deviceName rangeOfString:@"C400"].location != NSNotFound ||
        [deviceName rangeOfString:@"Move"].location != NSNotFound) {
        return WATCHNAME_MOVE_C300;
    }
    else if ([deviceName rangeOfString:@"C410"].location != NSNotFound ||
             [deviceName rangeOfString:@"Zone"].location != NSNotFound){
        return WATCHNAME_ZONE_C410;
    }
    else if ([deviceName rangeOfString:@"R450"].location != NSNotFound ||
             [deviceName rangeOfString:@"Brite"].location != NSNotFound){
        return WATCHNAME_BRITE_R450;
    }
    else{
        return WATCHNAME_DEFAULT;
    }
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[SFAPairWithWatchLoadingViewController class]]) {
        SFAPairWithWatchLoadingViewController *pairLoadingVC = segue.destinationViewController;
        pairLoadingVC.deviceIndex = self.deviceIndex;
        pairLoadingVC.status = self.discoverStatus;
        DeviceDetail *deviceDetail = self.devices[self.deviceIndex];
        pairLoadingVC.deviceModelString = [NSString stringWithFormat:@"%@", deviceDetail.deviceID];
    }
}

#pragma mark - SFAPairWithWatchHeaderCellDelegate
- (void)headerCellButtonClicked{
    //[self.navigationController popViewControllerAnimated:NO];
    NSArray *navControllers = [self.navigationController viewControllers];
    for (id vc in navControllers) {
        if ([vc isKindOfClass:[SFAFindingWatchViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
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

#pragma mark - Start sync

- (void)startSyncCModel
{
    self.salutronCModelSync.updateTimeAndDate = YES;
    self.salutronCModelSync.initialSync = YES;
    [self.salutronCModelSync startSyncWithWatchModel:self.selectedWatchModel withDeviceIndex:self.deviceIndex];
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startSyncRModel
{
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
    
    [self.salutronSync startSync];
}

- (void)didConnectAndSetupDeviceWithStatus:(Status)status{
    [self performSegueWithIdentifier:@"PairinWithWatch1ToPairWithWatch2" sender:self];
}

- (void)didDiscoverDevice:(int)numDevice withStatus:(Status)status{
    
}

- (void)didDisconnectDevice:(Status)status{
    
}

- (void)didRetrieveConnectedDevice:(int)numDevice withStatus:(Status)status{
    
}

- (void)didGetBattLevel:(NSString *)battLevelString withStatus:(Status)status{
    
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
