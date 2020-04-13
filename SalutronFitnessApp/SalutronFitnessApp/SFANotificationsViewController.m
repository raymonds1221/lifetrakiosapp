//
//  SFANotificationsViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/23/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFANotificationsViewController.h"
#import "SFANotificationCell.h"
#import "SFANotificationStatusCell.h"
#import "SFANotificationWatchStatusCell.h"
#import "SFASalutronUpdateManager.h"
#import "Notification+Coding.h"
#import "NotificationEntity+Data.h"
#import "TimingEntity+Data.h"
#import "ErrorCodeToStringConverter.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "SFANotificationsViewController+View.h"

#import "SFASyncProgressView.h"
#import "UIViewController+Helper.h"

#import "SFASalutronSync.h"
#import "SFAPairViewController.h"

#define NOTIFICATION_CELL_IDENTIFIER                @"NotificationCellIdentifier"
#define NOTIFICATION_STATUS_CELL_IDENTIFIER         @"NotificationStatusCellIdentifier"
#define NOTIFICATION_WATCH_STATUS_CELL_IDENTIFIER   @"NotificationWatchStatusCellIdentifier"
#define PAIR_SEGUE_IDENTIFIER                       @"NotificationToPair"
typedef NS_ENUM(NSInteger, NotificationsSection) {
    NotificationsSectionSetStatus = 0,
    NotificationsSectionItems
};

@interface SFANotificationsViewController () <SalutronSDKDelegate, SFANotificationCellDelegate, SFANotificationStatusCellDelegate, SFANotificationWatchStatusCellDelegate, SFASalutronSyncDelegate, SFASalutronUpdateManagerDelegate, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, SFASyncProgressViewDelegate, SFAPairViewControllerDelegate, CBCentralManagerDelegate>

@property (strong, nonatomic) SalutronSDK *salutronSDK;
@property (strong, nonatomic) Notification *notification;
@property (strong, nonatomic) Timing *timing;
@property (weak, nonatomic) UIButton *watchStatusButton;
@property (strong, nonatomic) SFAUserDefaultsManager *userDefaultsManager;
@property (strong, nonatomic) SFASalutronUpdateManager *salutronUpdateManager;
@property (nonatomic) BOOL notificationIsOn;
@property (nonatomic) BOOL isNotificationStatusCurrentlyUpdating;
@property (nonatomic) BOOL forcedSave;

@property (readwrite, nonatomic) BOOL                           isStillSyncing;
@property (readwrite, nonatomic) BOOL                           didCancel;
@property (readwrite, nonatomic) BOOL                           cancelSyncToCloudOperation;
@property (readwrite, nonatomic) BOOL                           isDisconnected;
@property (readwrite, nonatomic) BOOL                           isSyncing;
@property (readwrite, nonatomic) BOOL                           bluetoothOn;

@property (strong, nonatomic) SFASalutronSync                   *salutronSync;
@property (strong, nonatomic) SFAPairViewController             *pairViewController;
@property (strong, nonatomic) UIPickerView                      *pickerView;
@property (strong, nonatomic) UIView                            *genericPickerView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation SFANotificationsViewController

- (SFASalutronSync *)salutronSync
{
    if (!_salutronSync) {
        _salutronSync = [[SFASalutronSync alloc] init];
    }
    
    return _salutronSync;
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

- (void)viewDidLoad
{
    DDLogInfo(@"");
    [super viewDidLoad];
    self.salutronUpdateManager.managerDelegate = self;
    self.forcedSave = NO;
    
    [self hideCancelAndSave];
    
    [self addGenericPickerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"");
    [super viewWillAppear:animated];
    self.notification = self.userDefaultsManager.notification;
    self.timing = self.userDefaultsManager.timing;
    self.notificationIsOn = self.userDefaultsManager.notificationStatus;
    self.salutronUpdateManager.managerDelegate = self;
    self.salutronUpdateManager.delegate = self;
    [self.tableView reloadData];
    //    [self initNotification];
}

- (void)viewWillDisappear:(BOOL)animated{
    DDLogInfo(@"");
    [super viewWillDisappear:animated];
    self.salutronUpdateManager.managerDelegate = nil;
    self.salutronUpdateManager.delegate = nil;
    [self cancelChanges];
}

- (void)didReceiveMemoryWarning
{
    DDLogInfo(@"");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addGenericPickerView{
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(hidePickerView)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor blackColor];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 22.0f, self.view.frame.size.width, 200)];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.showsSelectionIndicator = YES;
    [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    
    
    self.genericPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-200, self.view.frame.size.width, toolBar.frame.size.height + self.pickerView.frame.size.height)];
    [self.genericPickerView addSubview:self.pickerView];
    [self.genericPickerView addSubview:toolBar];
    self.genericPickerView.hidden = YES;
    
    [self.view addSubview:self.genericPickerView];
}

- (void)hidePickerView{
    self.genericPickerView.hidden = YES;
}

- (void)showCancelAndSave{
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChanges)];//[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem=newBackButton;
    self.saveButton.hidden = NO;
}

- (void)hideCancelAndSave{
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem=newBackButton;
    self.saveButton.hidden = YES;
    [self hidePickerView];
}

#pragma mark - Private Methods

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

- (SalutronSDK *)salutronSDK {
    if(!_salutronSDK) {
        _salutronSDK = [SalutronSDK sharedInstance];
        _salutronSDK.delegate = self;
    }
    return _salutronSDK;
}

- (SFASalutronUpdateManager *)salutronUpdateManager
{
    if(!_salutronUpdateManager) {
        _salutronUpdateManager = [SFASalutronUpdateManager sharedInstance];
        _salutronUpdateManager.delegate = self;
    }
    return _salutronUpdateManager;
}

- (void)initNotification
{
    DDLogInfo(@"");
    self.notification = [SFAUserDefaultsManager sharedManager].notification;
    
    //    if(self.notification == nil) {
    //        self.notification = [[Notification alloc] init];
    Status status = [self.salutronSDK retrieveConnectedDevice];
    
    if(status != NO_ERROR) {
        DDLogError(@"retrieveConnectedDevice error: %@", [ErrorCodeToStringConverter convertToString:status]);
    }
    //    }
}

#pragma mark - UITableViewDataSource
/*
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    if (self.isIOS8AndAbove) {
        [header setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]];
    } else {
        [header.contentView setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]];
    }
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    /*
    if (section == NotificationsSectionSetStatus) {
        return 20.0f;
    }
    else if (section == NotificationsSectionItems) {
        return 50.0f;
    }
    return 0.0f;
     */
    if (section == 0) {
        return 22.0f;
    }
    return 0.0f;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == NotificationsSectionItems) {
        return NOTIFICATION_SECTION_TITLE;
    }
    return nil;
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.notificationIsOn) ? 2: 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == NotificationsSectionSetStatus) {
        return 1;
    }
    else if (section == NotificationsSectionItems) {
        return 8;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        SFANotificationWatchStatusCell *notificationWatchStatusCell = [tableView dequeueReusableCellWithIdentifier:NOTIFICATION_WATCH_STATUS_CELL_IDENTIFIER];
        notificationWatchStatusCell.delegate = self;
        
        if (self.notificationIsOn) {
            if (self.timing.smartForSleep == NO) {
                [notificationWatchStatusCell.watchStatusButton setTitle:SMART_FOR_SLEEP_ALWAYS forState:UIControlStateNormal];
            }
            else {
                [notificationWatchStatusCell.watchStatusButton setTitle:SMART_FOR_SLEEP_WHEN_AWAKE forState:UIControlStateNormal];
            }
        }
        else{
            [notificationWatchStatusCell.watchStatusButton setTitle:SMART_FOR_SLEEP_NEVER forState:UIControlStateNormal];
        }
        
        self.watchStatusButton = notificationWatchStatusCell.watchStatusButton;
        notificationWatchStatusCell.watchStatusButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        notificationWatchStatusCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return notificationWatchStatusCell;
    }
    else{
        SFANotificationCell *notificationCell = [tableView dequeueReusableCellWithIdentifier:NOTIFICATION_CELL_IDENTIFIER];
        switch (indexPath.row) {
            case 0:
                notificationCell.notificationLabel.text = NOTIFICATION_MAIL;
                notificationCell.notificationCheckbox.selected = self.notification.noti_email;
                //[notificationCell.notificationSwitch setOn:self.notification.noti_email];
                break;
            case 1:
                notificationCell.notificationLabel.text = NOTIFICATION_NEWS;
                notificationCell.notificationCheckbox.selected = self.notification.noti_news;
                //[notificationCell.notificationSwitch setOn:self.notification.noti_news];
                break;
            case 2:
                notificationCell.notificationLabel.text = NOTIFICATION_INCOMING_CALL;
                notificationCell.notificationCheckbox.selected = self.notification.noti_incomingCall;
                //[notificationCell.notificationSwitch setOn:self.notification.noti_incomingCall];
                break;
            case 3:
                notificationCell.notificationLabel.text = NOTIFICATION_MISSED_CALL;
                notificationCell.notificationCheckbox.selected = self.notification.noti_missedCall;
                // [notificationCell.notificationSwitch setOn:self.notification.noti_missedCall];
                break;
            case 4:
                notificationCell.notificationLabel.text = NOTIFICATION_SMS;
                notificationCell.notificationCheckbox.selected = self.notification.noti_sms;
                //[notificationCell.notificationSwitch setOn:self.notification.noti_sms];
                break;
            case 5:
                notificationCell.notificationLabel.text = NOTIFICATION_VOICE_MAIL;
                notificationCell.notificationCheckbox.selected = self.notification.noti_voiceMail;
                //[notificationCell.notificationSwitch setOn:self.notification.noti_voiceMail];
                break;
            case 6:
                notificationCell.notificationLabel.text = NOTIFICATION_SCHEDULE;
                notificationCell.notificationCheckbox.selected = self.notification.noti_schedule;
                //[notificationCell.notificationSwitch setOn:self.notification.noti_schedule];
                break;
            case 7:
                notificationCell.notificationLabel.text = NOTIFICATION_SOCIAL;
                notificationCell.notificationCheckbox.selected = self.notification.noti_social;
                //[notificationCell.notificationSwitch setOn:self.notification.noti_social];
                break;
            default:
                break;
        }
        notificationCell.delegate = self;
        notificationCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return notificationCell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return [UITableViewCell new];

    /*
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.textAlignment = NSTextAlignmentCenter;
    myLabel.frame = CGRectMake(0, 0, 320, 50);
    myLabel.font = [UIFont boldSystemFontOfSize:12];
    myLabel.textColor = [UIColor grayColor];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
    */
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UITableViewCell new];
}

#pragma mark - SalutronSDKDelegate

- (void)didDiscoverDevice:(int)numDevice withStatus:(Status)status
{
    
}

- (void)didConnectAndSetupDeviceWithStatus:(Status)status
{
    DDLogError(@"connect and setup device");
    [self.salutronSDK getNotification];
}

- (void)didRetrieveConnectedDevice:(int)numDevice withStatus:(Status)status
{
    if(numDevice > 0) {
        [self.salutronSDK connectDevice:0];
    }
}

- (void)didGetNotification:(Notification *)notify withStatus:(Status)status
{
    self.notification = notify;
    self.userDefaultsManager.notification = notify;
    [self.tableView reloadData];
}

- (void)didDisconnectDevice:(Status)status
{
    DDLogError(@"device disconnected :P");
}

- (void)didGetBattLevel:(NSString *)battLevelString withStatus:(Status)status
{
    
}

- (void)didGetModelNumber:(ModelNumber *)modelNumber withStatus:(Status)status
{
    
}

- (void)showDisplayWatchOptions
{
    /*
    [UIActionSheet actionSheetWithTitle:nil message:nil buttons:@[SMART_FOR_SLEEP_ALWAYS, SMART_FOR_SLEEP_WHEN_AWAKE] showInView:self.view onDismiss:^(int buttonIndex) {
        Timing *timing = self.userDefaultsManager.timing;
        
        if (!timing) {
            timing = [[Timing alloc] init];
            timing.smartForSleep = YES;
            timing.smartForWrist = YES;//smartForWrist.boolValue;
        }
        
        switch (buttonIndex) {
            case 0:
                // Always
                [self.watchStatusButton setTitle:SMART_FOR_SLEEP_ALWAYS forState:UIControlStateNormal];
                timing.smartForSleep = NO;
                break;
            case 1:
                // Only when awake
                [self.watchStatusButton setTitle:SMART_FOR_SLEEP_WHEN_AWAKE forState:UIControlStateNormal];
                timing.smartForSleep = YES;
                break;
            default:
                break;
        }
        self.userDefaultsManager.timing = timing;
        self.userDefaultsManager.timing.smartForSleep = timing.smartForSleep;
        [self.tableView reloadData];
    } onCancel:^{
        [self.tableView reloadData];
    }];
     */
    self.genericPickerView.hidden = NO;
    
    if (!self.notificationIsOn) {
        [self.pickerView selectRow:2 inComponent:0 animated:NO];
    }
    else{
        if (self.timing.smartForSleep == NO) {
            [self.pickerView selectRow:0 inComponent:0 animated:NO];
        }
        else{
            [self.pickerView selectRow:1 inComponent:0 animated:NO];
        }
    }
}

#pragma mark - UIViewPickerViewDelegate
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [@[SMART_FOR_SLEEP_ALWAYS, SMART_FOR_SLEEP_WHEN_AWAKE, SMART_FOR_SLEEP_NEVER] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //self.pickerView.hidden = YES;

    if (!self.timing) {
        self.timing = [[Timing alloc] init];
        self.timing.smartForSleep = YES;
        self.timing.smartForWrist = YES;//smartForWrist.boolValue;
    }
    
    if (row == 0) {
        self.notificationIsOn = YES;
        [self.watchStatusButton setTitle:SMART_FOR_SLEEP_ALWAYS forState:UIControlStateNormal];
        self.timing.smartForSleep = NO;
    }
    else if (row == 1) {
        self.notificationIsOn = YES;
        [self.watchStatusButton setTitle:SMART_FOR_SLEEP_WHEN_AWAKE forState:UIControlStateNormal];
        self.timing.smartForSleep = YES;
    }
    else if (row == 2) {
        self.notificationIsOn = NO;
        [self.watchStatusButton setTitle:SMART_FOR_SLEEP_NEVER forState:UIControlStateNormal];
    }
    
    [self.tableView reloadData];
}

#pragma mark - SFANotificationStatusDelegate

- (void)didNotificationStatusValueChanged:(UISwitch *)sender
{
    
    self.notificationIsOn = sender.on;
    /*[self.salutronUpdateManager startUpdateNotificationStatusWithWatchModel:self.userDefaultsManager.watchModel
     notificationStatus:self.userDefaultsManager.notificationStatus];
     self.isNotificationStatusCurrentlyUpdating = YES;
     */
    [self.tableView reloadData];
    
}

#pragma mark - SFANotificationWatchStatusDelegate

- (void)didNotificationWatchStatusClicked:(UIButton *)sender
{
    [self showDisplayWatchOptions];
    [self showCancelAndSave];
}

#pragma mark - SFANotificationCellDelegate

- (void)didNotificationValueChanged:(id)sender notification:(NotificationType)notificationType
{
    [self showCancelAndSave];
    SFANotificationCell *notificationCell = (SFANotificationCell *)sender;
    __weak UIButton *notificationCheckBox = notificationCell.notificationCheckbox;
    
    switch (notificationType) {
        case NotificationTypeIncomingCall:
            self.notification.type = NOTIFY_IN_CALL;
            self.notification.noti_incomingCall = notificationCheckBox.selected ? YES : NO;
            break;
        case NotificationTypeMissedCall:
            self.notification.type = NOTIFY_MISS_CALL;
            self.notification.noti_missedCall = notificationCheckBox.selected ? YES : NO;
            break;
        case NotificationTypeSMS:
            self.notification.type = NOTIFY_SMS_MMS;
            self.notification.noti_sms = notificationCheckBox.selected ? YES : NO;
            break;
        case NotificationTypeMail:
            self.notification.type = NOTIFY_EMAIL;
            self.notification.noti_email = notificationCheckBox.selected ? YES : NO;
            break;
        case NotificationTypeVoiceMail:
            self.notification.type = NOTIFY_VOICE_MAIL;
            self.notification.noti_voiceMail = notificationCheckBox.selected ? YES : NO;
            break;
        case NotificationTypeSchedule:
            self.notification.type = NOTIFY_SCHEDULE;
            self.notification.noti_schedule = notificationCheckBox.selected ? YES : NO;
            break;
        case NotificationTypeNews:
            self.notification.type = NOTIFY_NEWS;
            self.notification.noti_news = notificationCheckBox.selected ? YES : NO;
            break;
        case NotificationTypeSocial:
            self.notification.type = NOTIFY_SOCIAL;
            self.notification.noti_social = notificationCheckBox.selected ? YES : NO;
            break;
        default:
            break;
    }
    
    /*
     [self.salutronUpdateManager startUpdateNotificationWithWatchModel:self.userDefaultsManager.watchModel
     withNotification:self.notification];
     self.isNotificationStatusCurrentlyUpdating = NO;
     
     [self.tableView reloadData];
     */
    //    SFASalutronUpdate *_salutronSDKUpdate = [SFASalutronUpdate manager];
    //    _salutronSDKUpdate.notification = self.notification;
    //    [_salutronSDKUpdate save];
}

#pragma mark - SFASalutronSyncDelegate

- (void)didSyncStarted
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    [SFASyncProgressView hide];
    
    self.isSyncing = YES;
    
    [SFASyncProgressView progressView].delegate = self;
    [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    
}

- (void)didSyncFinished:(DeviceEntity *)deviceEntity profileUpdated:(BOOL)profileUpdated
{
    DDLogInfo(@"");
    
}

- (void)didChangeSettings
{
    DDLogInfo(@"");
    
}

- (void)didSaveSettings
{
    DDLogInfo(@"");
}

- (void)didDiscoverTimeout
{
    DDLogInfo(@"");
    /*
     if(self.userDefaultsManager.notificationStatus) {
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NOTIFICATION_ALERT_TITLE
     message:NOTIFICATION_ALERT_MESSAGE
     delegate:nil
     cancelButtonTitle:BUTTON_TITLE_OK
     otherButtonTitles:nil, nil];
     [alertView show];
     
     //self.userDefaultsManager.notificationStatus = NO;
     [self.tableView reloadData];
     }
     else{
     */
    //[SFASyncProgressView showWithMessage:@"We cannot find your LifeTrak." animate:NO showButton:NO dismiss:YES];
    /*
     [self hideTryAgainView];
     [SFASyncProgressView hide];
     [self showTryAgainViewWithTarget:self
     cancelSelector:@selector(cancelOnTimeoutClick)
     tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
     
     */
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    if (!self.isDisconnected) {
        self.isDisconnected = YES;
        [self.salutronSync stopSync];
        [SFASyncProgressView hide];
        
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
         if ([self respondsToSelector:@selector(showTryAgainViewWithTarget:cancelSelector:tryAgainSelector:)]) {
        [self showTryAgainViewWithTarget:self
                          cancelSelector:@selector(cancelOnTimeoutClick)
                        tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
         }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    }
    
    self.isSyncing = NO;
    //}
    
}

- (void)didUpdateNotificationWithStatus:(Status)status{
    DDLogInfo(@"");
    DDLogInfo(@"status: %@", [ErrorCodeToStringConverter convertToString:status]);
    [self.tableView reloadData];
}

- (void)updateStarted{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    [SFASyncProgressView hide];
    
    self.isSyncing = YES;
    
    [SFASyncProgressView progressView].delegate = self;
    [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    
    //[SFASyncProgressView showWithMessage:LS_UPDATING_NOTIFICATION animate:YES showButton:NO];
}

- (void)updateFinishedWithStatus:(Status)status{
    DDLogInfo(@"");
    //[SFASyncProgressView hide];
    if (status == NO_ERROR) {
        /*
         [SFASyncProgressView showWithMessage:@"Notification synced!" animate:NO showOKButton:YES onButtonClick:^{
         [SFASyncProgressView hide];
         }];
         */
        [SFASyncProgressView showWithMessage:LS_UPDATING_DONE animate:NO showButton:NO dismiss:YES];
        
        self.userDefaultsManager.notificationStatus = self.notificationIsOn;
        [SFAUserDefaultsManager sharedManager].notification = self.notification;
    }
    else{
        [self hideTryAgainView];
        [SFASyncProgressView hide];
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
         if ([self respondsToSelector:@selector(showTryAgainViewWithTarget:cancelSelector:tryAgainSelector:)]) {
        [self showTryAgainViewWithTarget:self
                          cancelSelector:@selector(cancelOnTimeoutClick)
                        tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
         }
        /*
         if (status == ERROR_DISCOVER || status == ERROR_DISCONNECT) {
         //[SFASyncProgressView showWithMessage:@"We cannot find your LifeTrak." animate:NO showButton:NO dismiss:YES];
         
         [self showTryAgainViewWithTarget:self
         cancelSelector:@selector(cancelOnTimeoutClick)
         tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
         }
         else{
         [SFASyncProgressView showWithMessage:@"Error updating." animate:NO showButton:NO dismiss:YES];
         }
         */
        /*
         [SFASyncProgressView showWithMessage:@"Error syncing." animate:NO showOKButton:YES onButtonClick:^{
         [SFASyncProgressView hide];
         }];
         */
        
    }
    self.notification = [SFAUserDefaultsManager sharedManager].notification;
    [self.tableView reloadData];
}

- (void)didUpdateFinish{
    DDLogInfo(@"");
    
    self.isSyncing = NO;
    [SFASyncProgressView hide];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    
    [SFASyncProgressView showWithMessage:LS_UPDATING_DONE animate:NO showButton:NO dismiss:YES];
    
    self.userDefaultsManager.notificationStatus = self.notificationIsOn;
    [SFAUserDefaultsManager sharedManager].notification = self.notification;
    if (self.forcedSave) {
        self.forcedSave = NO;
        [self performSelector:@selector(back:) withObject:self afterDelay:2.1];
    }
}

- (void)cancelOnTimeoutClick
{
    DDLogInfo(@"");
    [self hideTryAgainView];
    [self hideTryAgainView];
}

- (void)tryAgainOnTimeoutClick
{
    DDLogInfo(@"");
    /*
     if (self.userDefaultsManager.watchModel == WatchModel_R450) {
     if (self.isNotificationStatusCurrentlyUpdating == YES) {
     self.notificationIsOn = !self.userDefaultsManager.notificationStatus;
     [self.salutronUpdateManager startUpdateAllNotificationsWithWatchModel:self.userDefaultsManager.watchModel notification:self.notification notificationStatus:self.notificationIsOn];
     self.isNotificationStatusCurrentlyUpdating = NO;
     }
     else{
     self.isNotificationStatusCurrentlyUpdating = YES;
     [self.salutronUpdateManager startUpdateAllNotificationsWithWatchModel:self.userDefaultsManager.watchModel notification:self.notification notificationStatus:self.notificationIsOn];
     self.isNotificationStatusCurrentlyUpdating = NO;
     }
     }
     */
    [self startSyncRModel];
    [self.tableView reloadData];
    [self hideTryAgainView];
}
- (IBAction)saveButtonClicked:(id)sender {
    DDLogInfo(@"");
    /*
     self.isNotificationStatusCurrentlyUpdating = YES;
     [self.salutronUpdateManager startUpdateAllNotificationsWithWatchModel:self.userDefaultsManager.watchModel notification:self.notification notificationStatus:self.notificationIsOn];
     self.isNotificationStatusCurrentlyUpdating = NO;
     [self.tableView reloadData];
     */
    /*
    [self startSyncRModel];
    */
    
    //save to user defaults
    self.userDefaultsManager.notificationStatus = self.notificationIsOn;
    self.userDefaultsManager.notification = self.notification;
    self.userDefaultsManager.timing = self.timing;
    
    //save to core data
    NSString *macAddress            = self.userDefaultsManager.macAddress;
    DeviceEntity *deviceEntity               = [DeviceEntity deviceEntityForMacAddress:macAddress];
    [NotificationEntity notificationWithNotification:self.notification notificationStatus:self.notificationIsOn forDeviceEntity:deviceEntity];
    [TimingEntity timingWithTiming:self.timing forDeviceEntity:deviceEntity];
    
    [self hideCancelAndSave];
}

- (void)updateNotification{
    DDLogInfo(@"");
    self.isNotificationStatusCurrentlyUpdating = YES;
    [self.salutronUpdateManager startUpdateAllNotificationsWithWatchModel:self.userDefaultsManager.watchModel notification:self.notification notificationStatus:self.notificationIsOn];
    self.isNotificationStatusCurrentlyUpdating = NO;
    [self.tableView reloadData];
}

#pragma mark - ibaction
- (void)back:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    /*
    if ((self.notificationIsOn != self.userDefaultsManager.notificationStatus) || [self notificationChanged]){
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NOTIFICATION_ALERT_TITLE
                                                                                     message:NOTIFICATION_ALERT_NOT_SAVED
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *yesAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_YES_ALL_CAPS
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                               self.forcedSave = YES;
                                               [self saveButtonClicked:self];
                                       }];
            UIAlertAction *noAction = [UIAlertAction
                                        actionWithTitle:BUTTON_TITLE_NO
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action)
                                       {
                                           //  self.userDefaultsManager.notificationStatus = self.notificationIsOn;
                                           //  [SFAUserDefaultsManager sharedManager].notification = self.notification;
                                           [self.navigationController popViewControllerAnimated:YES];
                                        }];
            
            [alertController addAction:yesAction];
            [alertController addAction:noAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NOTIFICATION_ALERT_TITLE
                                                                message:NOTIFICATION_ALERT_NOT_SAVED
                                                               delegate:self
                                                      cancelButtonTitle:BUTTON_TITLE_YES_ALL_CAPS
                                                      otherButtonTitles:BUTTON_TITLE_NO_ALL_CAPS, nil];
            [alertView show];
        }
    }
    
    else{
        //  self.userDefaultsManager.notificationStatus = self.notificationIsOn;
        //  [SFAUserDefaultsManager sharedManager].notification = self.notification;
        [self.navigationController popViewControllerAnimated:YES];
    }
    */
}

- (void)cancelChanges{
    self.notification = self.userDefaultsManager.notification;
    self.timing = self.userDefaultsManager.timing;
    self.notificationIsOn = self.userDefaultsManager.notificationStatus;
    [self hideCancelAndSave];
    [self.tableView reloadData];
}

- (BOOL)notificationChanged{
    Notification *oldNotification = [SFAUserDefaultsManager sharedManager].notification;
    if (oldNotification.noti_email != self.notification.noti_email) {
        return YES;
    }
    if (oldNotification.noti_hightPrio != self.notification.noti_hightPrio) {
        return YES;
    }
    if (oldNotification.noti_incomingCall != self.notification.noti_incomingCall) {
        return YES;
    }
    if (oldNotification.noti_missedCall != self.notification.noti_missedCall) {
        return YES;
    }
    if (oldNotification.noti_news != self.notification.noti_news) {
        return YES;
    }
    if (oldNotification.noti_schedule != self.notification.noti_schedule) {
        return YES;
    }
    if (oldNotification.noti_simpleAlert != self.notification.noti_simpleAlert) {
        return YES;
    }
    if (oldNotification.noti_sms != self.notification.noti_sms) {
        return YES;
    }
    if (oldNotification.noti_social != self.notification.noti_social) {
        return YES;
    }
    if (oldNotification.noti_voiceMail != self.notification.noti_voiceMail) {
        return YES;
    }
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    DDLogInfo(@"alertview = %i", buttonIndex);
    if (buttonIndex == 0) {
        self.forcedSave = YES;
        [self saveButtonClicked:self];
    }
    else{
        //  self.userDefaultsManager.notificationStatus = self.notificationIsOn;
        //  [SFAUserDefaultsManager sharedManager].notification = self.notification;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)openPairViewController{
    /*
     self.pairViewController                          = [[SFAPairViewController alloc] init];
     self.pairViewController.delegate                 = self;
     self.pairViewController.watchModel               = self.userDefaultsManager.watchModel;
     //if (self.pairViewController.watchModel == WatchModel_R450) {
     self.pairViewController.showCancelSyncButton = YES;
     [self.navigationController presentViewController:self.pairViewController animated:YES completion:nil];
     //}
     */
    // UIViewController *toViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAPairViewController"];
    // UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"NotificationToPair" source:self destination:toViewController];
    // [self prepareForSegue:segue sender:nil];
    [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
    //[segue perform];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PAIR_SEGUE_IDENTIFIER]) {
        self.pairViewController                          = (SFAPairViewController *)segue.destinationViewController;
        self.pairViewController.delegate                 = self;
        self.pairViewController.watchModel               = self.userDefaultsManager.watchModel;
        //if (self.pairViewController.watchModel == WatchModel_R450) {
        self.pairViewController.showCancelSyncButton = YES;
        //}
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    /*
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
        //[self startSyncRModel];
        return NO;
        
    }
    else if ([identifier isEqualToString:@"Cancel Sync"]) {
        return NO;
    }
    
    return YES;
     */
    return NO;
}



- (void)didDeviceDisconnected:(BOOL)isSyncFinished
{
    DDLogInfo(@"");
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    if (!self.isDisconnected || !isSyncFinished) {
        self.isDisconnected = YES;
        //[SVProgressHUD showErrorWithStatus:DEVICE_DISCONNECTED];
        
        /*
         [SVProgressHUD dismiss];
         [SFASyncProgressView showWithMessage:DEVICE_DISCONNECTED animate:NO showOKButton:YES onButtonClick:^{
         [SFASyncProgressView hide];
         }];
         */
        self.salutronUpdateManager.delegate = nil;
        [self.salutronSync stopSync];
        [SFASyncProgressView hide];
        //[SFASyncProgressView showWithMessage:DEVICE_DISCONNECTED animate:NO showButton:NO dismiss:YES];
        /*
         [SFASyncProgressView showWithMessage:DEVICE_DISCONNECTED animate:NO showOKButton:YES onButtonClick:^{
         [SVProgressHUD dismiss];
         [SFASyncProgressView hide];
         }];
         */
        
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
         if ([self respondsToSelector:@selector(showTryAgainViewWithTarget:cancelSelector:tryAgainSelector:)]) {
        [self showTryAgainViewWithTarget:self
                          cancelSelector:@selector(cancelOnTimeoutClick)
                        tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
         }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    }
    
    self.isSyncing = NO;
}

- (void)didPairWatch{
    DDLogInfo(@"");
    self.isDisconnected = YES;
    [self cancelSyncing:nil];
    [self startSyncConnectedRModel];
}





- (void)startSyncRModel
{
    DDLogInfo(@"");
    self.salutronSync                              = [[SFASalutronSync alloc] init];
    self.salutronSync.delegate                     = self;
    self.salutronSync.selectedWatchModel           = WatchModel_R450;
    [self.salutronSync searchConnectedDevice];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)didSearchConnectedWatch:(BOOL)found
{
    DDLogInfo(@"");
    if (found) {
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
        [self startSyncConnectedRModel];
    } else {
        [self openPairViewController];
        //[self.salutronSync startSync];
    }
}

- (void)startSyncConnectedRModel{
    DDLogInfo(@"");
    self.salutronSync                              = [[SFASalutronSync alloc] init];
    self.salutronSync.delegate                     = self;
    self.salutronSync.selectedWatchModel           = WatchModel_R450;
    self.salutronUpdateManager.delegate            = self;
    
    [SFASyncProgressView progressView].delegate = self;
    [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    
    //[self.salutronSync startSync];
    //[self saveButtonClicked:nil];
    [self updateNotification];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



#pragma mark - Cancel sync

- (IBAction)cancelSyncing:(UIStoryboardSegue *)segue
{
    DDLogInfo(@"");
    
    if ([segue.sourceViewController isKindOfClass:[SFAPairViewController class]]) {
        self.didCancel = YES;
        self.isStillSyncing = YES;
        
        [SFASyncProgressView hide];
        
        //[self didDeviceDisconnected:NO];
        self.didCancel = YES;
        //[self cancelSyncing:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
        
    }
    
    self.salutronSync.delegate = nil;
    self.salutronSDK.delegate = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    // [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
    //   if (self.userDefaultsManager.notificationStatus == YES) {
    //       [[SFASalutronUpdateManager sharedInstance] startUpdateNotificationStatusWithWatchModel:self.userDefaultsManager.watchModel notificationStatus:YES];
    //   }
    
    
}

- (void)didPressCancelInPairViewController:(SFAPairViewController *)viewController
{
    DDLogInfo(@"");
    self.salutronUpdateManager.delegate = nil;
    self.didCancel = YES;
}

- (void)didPressContinueInPairViewController:(SFAPairViewController *)viewController
{
    DDLogInfo(@"");
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


@end
