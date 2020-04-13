//
//  SFARewardsViewController.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 6/16/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFARewardsViewController.h"
#import "SFARewardsWebViewController.h"
#import "UIViewController+Helper.h"

#import "SFARewardsTableViewCell.h"
#import "SFAWalgreensManager.h"

#import "SVProgressHUD.h"

#import "SFASyncProgressView.h"

#import "SFAServerSyncManager.h"
#import "DeviceEntity+Data.h"

#import "Flurry.h"

#define rewardsToRewardsWebSegueId @"rewardsToRewardsWeb"

@interface SFARewardsViewController ()<SFARewardsCellDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIAlertView *getURLAlertView;
@property (strong, nonatomic) UIAlertView *syncCloudAlertView;

@property (strong, nonatomic) NSURL *connectURL;

@property (nonatomic, getter = isConnected) BOOL connected;
@property (nonatomic, getter = isSynced)    BOOL synced;
@property (nonatomic)                       BOOL cancelSyncToCloudOperation;

@property (strong, nonatomic) NSOperation *syncToCloudOperation;

@property (strong, nonatomic) DeviceEntity *device;

@end

@implementation SFARewardsViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getWalgreensConnectURL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[SFAWalgreensManager sharedManager] cancelCurrentOperation];
}

#pragma mark - properties
- (DeviceEntity *)device
{
    if (!_device) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *macAddress = [userDefaults objectForKey:MAC_ADDRESS];
        _device = [DeviceEntity deviceEntityForMacAddress:macAddress];
    }
    
    return _device;
}

#pragma mark - private methods

- (void)getWalgreensConnectURL
{
    __weak typeof(self) weakSelf = self;
    [[SFAWalgreensManager sharedManager] getConnectURLWithSuccess:^(NSURL *url, BOOL isConnected, BOOL isSynced) {
        weakSelf.connectURL = url;
        weakSelf.connected = isConnected;
        weakSelf.synced = isSynced;
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        //if error returned is due to cancel operation, do nothing
        if (error.code == -999){
            return ;
        }
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LS_WALGREENS_ALERT_ERROR
                                                                                     message:NSLocalizedString(error.localizedDescription, nil)
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *noAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_CANCEL
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self.navigationController popViewControllerAnimated:YES];
                                       }];
            UIAlertAction *yesAction = [UIAlertAction
                                        actionWithTitle:BUTTON_TITLE_RETRY
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action)
                                        {
                                            [self getWalgreensConnectURL];
                                        }];
            
            [alertController addAction:noAction];
            [alertController addAction:yesAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            weakSelf.getURLAlertView = [[UIAlertView alloc] initWithTitle:LS_WALGREENS_ALERT_ERROR
                                                                  message:NSLocalizedString(error.localizedDescription, nil)
                                                                 delegate:weakSelf
                                                        cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                        otherButtonTitles:BUTTON_TITLE_RETRY, nil];
            
            [weakSelf.getURLAlertView show];
        }
    }];
}

- (void)syncToCloud
{
    __weak typeof(self) weakSelf = self;
    [SFASyncProgressView showWithMessage:LS_SYNC_TO_SERVER animate:YES showButton:YES onButtonClick:^{
        weakSelf.cancelSyncToCloudOperation = YES;
        [SFASyncProgressView hide];
        
        [weakSelf.syncToCloudOperation cancel];
        weakSelf.syncToCloudOperation = nil;
    }];
    
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    
    self.syncToCloudOperation = [serverSyncManager syncDeviceEntity:self.device withSuccess:^(NSString *macAddress) {
        [weakSelf storeToServerWithMacAddress:macAddress];
    } failure:^(NSError *error) {
        
        if (!weakSelf.cancelSyncToCloudOperation){
            [weakSelf alertError:error];
        }
        [SFASyncProgressView hide];
        weakSelf.syncToCloudOperation       = nil;
        weakSelf.cancelSyncToCloudOperation = NO;
    }];
}

- (void)storeToServerWithMacAddress:(NSString *)macAddress
{
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    
    __weak typeof(self) weakSelf = self;
    [serverSyncManager storeWithMacAddress:macAddress success:^{
        
        NSDate *date                    = [NSDate date];
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        
        weakSelf.synced                     = YES;
        [userDefaults setObject:data forKey:self.device.macAddress];
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
        //[SVProgressHUD showSuccessWithStatus:LS_SYNC_SERVER_SUCCESS];
        
        [weakSelf.tableView reloadData];
        
        [SFASyncProgressView hide];
        
        [SFASyncProgressView showWithMessage:LS_SYNC_SERVER_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
            
        }];
        weakSelf.syncToCloudOperation       = nil;
        weakSelf.cancelSyncToCloudOperation = NO;
        
        [weakSelf performSegueWithIdentifier:rewardsToRewardsWebSegueId sender:nil];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (!weakSelf.cancelSyncToCloudOperation){
            [weakSelf alertError:error];
        }
        [SFASyncProgressView hide];
        weakSelf.syncToCloudOperation       = nil;
        weakSelf.cancelSyncToCloudOperation = NO;
    }];
}

#pragma mark - UIAlertView Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:self.getURLAlertView] && buttonIndex == 1) {
        [self getWalgreensConnectURL];
    }else if ([alertView isEqual:self.getURLAlertView] && buttonIndex == 0){
        [self.navigationController popViewControllerAnimated:YES];
    }else if ([alertView isEqual:self.syncCloudAlertView] && buttonIndex == 1){
        [self syncToCloud];
    }else if ([alertView isEqual:self.syncCloudAlertView] && buttonIndex == 0){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - tableviewdelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - tableviewdatasource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFARewardsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REWARDS_CELL_IDENTIFIER];
    
    switch (indexPath.row) {
        case 0:{
            cell.delegate = self;
            cell.rewardsTitle.text = LS_WALGREENS_TITLE;
            cell.rewardsDescription.text = LS_WALGREENS_MESSAGE;
            if (self.isConnected){
                [cell.activityIndicator stopAnimating];
                cell.connectButton.enabled = YES;
                [cell showDisconnectButton];
            }else{
                if (self.connectURL){
                    [cell.activityIndicator stopAnimating];
                    [cell showConnectButton];
                    cell.connectButton.enabled = YES;
                }else{
                    cell.connectButton.enabled = NO;
                }
            }
            
        }
        break;
    }
    return cell;
}

#pragma mark - SFARewardsTableViewCell Delegate methods

- (void)connectButtonSelected:(id)sender
{
    if (!self.isSynced){
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Walgreens"
                                                                                     message:LS_WALGREENS_SYNC_MESSAGE
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *noAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_NO
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self.navigationController popViewControllerAnimated:YES];
                                       }];
            UIAlertAction *yesAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_YES
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                        {
                                            [self syncToCloud];
                                       }];
            
            [alertController addAction:noAction];
            [alertController addAction:yesAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            self.syncCloudAlertView = [[UIAlertView alloc] initWithTitle:@"Walgreens" message:LS_WALGREENS_SYNC_MESSAGE delegate:self cancelButtonTitle:BUTTON_TITLE_NO otherButtonTitles:BUTTON_TITLE_YES, nil];
            [self.syncCloudAlertView show];
        }
        return;
    }
    
    if (self.isConnected){
        [SVProgressHUD showWithStatus:LS_WALGREENS_DISCONNECT maskType:SVProgressHUDMaskTypeBlack];
        __weak typeof(self) weakSelf = self;
        [[SFAWalgreensManager sharedManager] disconnectWithSuccess:^{
            [SVProgressHUD dismiss];
            [weakSelf getWalgreensConnectURL];

        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:LS_WALGREENS_DISCONNECT_FAIL];
        }];
        
    }else{
        
        [Flurry logEvent:WALLGREENS_PAGE];
        [self performSegueWithIdentifier:rewardsToRewardsWebSegueId sender:nil];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:rewardsToRewardsWebSegueId]){
        SFARewardsWebViewController *vc = (SFARewardsWebViewController *)segue.destinationViewController;
        vc.url = self.connectURL;
    }
    
}



@end
