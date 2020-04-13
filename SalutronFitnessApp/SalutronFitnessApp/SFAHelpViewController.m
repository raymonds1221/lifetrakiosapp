//
//  SFAHelpViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/16/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <SafariServices/SafariServices.h>

#import <MessageUI/MessageUI.h>
#import "ATConnect.h"

#import "SFAHelpViewController.h"
#import "ECSlidingViewController.h"
#import "SFAYourProfileViewController.h"
#import "SFAPairViewController.h"
#import "UIViewController+Helper.h"
#import "SFAAutoSyncCell.h"
#import "SFAServerAccountManager.h"
#import "SFAFAQViewController.h"
#import "SFAUserGuideViewController.h"

#import "ZipArchive.h"

#import "SVProgressHUD.h"
#import "SalutronUserProfile+Data.h"
#import "TimeDate+Data.h"

#import "Flurry.h"


#define kAccurateInformation    NSLocalizedString(@"Giving accurate information helps us\nhelp YOU better", nil)
#define kLifeTrakSupport        NSLocalizedString(@"Your LifeTrak is also supported by other\napps", nil)

#define kCompatibleApps         NSLocalizedString(@"COMPATIBLE APPS", nil)

#define kHeaderArray            @[@"AUTO SYNC", @"NOTIFICATIONS", kCompatibleApps, @""/*, @"", @""*/]
#define kFooterArray            @[kAccurateInformation, @"", @"", kLifeTrakSupport, @""]
#define kNotificationArray      @[@"Notifications"]
#define kCellArray              @[kAutoSyncArray, kNotificationArray]

#define PAIR_SEGUE_IDENTIFIER   @"ApplicationSettingsToPair"

@interface SFAHelpViewController () <CBCentralManagerDelegate, MFMailComposeViewControllerDelegate, SFAPairViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray    *headerArray;
@property (assign, nonatomic) BOOL              bluetoothOn;
@property (strong, nonatomic) CBCentralManager  *centralManager;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (readwrite, nonatomic) WatchModel     watchModel;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *syncButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)menuButtonPressed:(UIBarButtonItem *)sender;

@end

@implementation SFAHelpViewController

NSString *_profileCell          = @"ProfileCell";
NSString *_profileGenderCell    = @"ProfileGenderCell";
NSString *_preferenceCell       = @"PreferenceCell";
NSString *_compatibleAppsCell   = @"CompatibleAppsCell";
NSString *_helpCell             = @"HelpCell";
NSString *_headerCell           = @"HeaderCell";
NSString *_footerCell           = @"FooterCell";
NSString *_rewardsCell           = @"RewardsCell";

NSString *_notificationCell     = @"NotificationCell";
NSString *_autoSyncStateCell    = @"AutoSyncState";
NSString *_autoSyncAlertCell    = @"AutoSyncAlert";
NSString *_autoSyncOptionCell   = @"AutoSyncOption";

UISwitch *_autoSyncSwitch;
UISwitch *_autoSyncAlertSwitch;

#pragma mark - View controller methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //instantiate objects
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _watchModel         = [[self.userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
    _headerArray        = [NSMutableArray array];
    _headerArray        = [kHeaderArray mutableCopy];
    
    // Hide sync button if model is C300 or C410
    self.navigationItem.rightBarButtonItem = nil;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Flurry logEvent:HELP_PAGE];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PAIR_SEGUE_IDENTIFIER]) {
        NSUserDefaults *userDefaults            = [NSUserDefaults standardUserDefaults];
        SFAPairViewController *viewController   = (SFAPairViewController *)segue.destinationViewController;
        viewController.delegate                 = self;
        viewController.watchModel               = [[userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:PAIR_SEGUE_IDENTIFIER]) {
        if(!_bluetoothOn) {
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
        
        return self.bluetoothOn;
    }
    if(self.isIOS9AndAbove &&
       ([identifier isEqualToString:@"HelpToFAQ"] || [identifier isEqualToString:@"HelpToUserGuides"])){
        return NO;
    }
    return YES;
}

- (NSUserDefaults *)userDefaults
{
    if (!_userDefaults)
        _userDefaults = [NSUserDefaults standardUserDefaults];
    return _userDefaults;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return 5;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return [tableView dequeueReusableCellWithIdentifier:@"FAQCell"];
        } else if (indexPath.row == 1) {
            return [tableView dequeueReusableCellWithIdentifier:@"UserGuideCell"];
        } else if (indexPath.row == 2) {
            return [tableView dequeueReusableCellWithIdentifier:@"HelpCell"];
        } else if (indexPath.row == 3 ) {
            return [tableView dequeueReusableCellWithIdentifier:@"FeedbackCell"];
        } else if (indexPath.row == 4 ) {
            return [tableView dequeueReusableCellWithIdentifier:@"TermsAndCondition"];
        }
    }
    return [UITableViewCell new];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return BUTTON_TITLE_SUPPORT;
    } 
    
    return nil;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DDLogInfo(@"index param: section: %i row: %i",indexPath.section, indexPath.row);
    if (indexPath.section == 0 && indexPath.row == 0) {
        if(self.isIOS9AndAbove){
            NSString *urlAddress = @"https://lifetrakusa.com/support/frequently-asked-questions/";//@"http://lifetrakusa.com/faq/";
            NSURL *url = [NSURL URLWithString:urlAddress];
            SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
            [self presentViewController:safariViewController animated:YES completion:nil];
        }
        else{
            //SFAFAQViewController *faqVC = [[SFAFAQViewController alloc] init];
            //[self presentViewController:faqVC animated:YES completion:nil];
        }
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        if(self.isIOS9AndAbove){
            NSString *urlAddress = USER_GUIDES_LINK;
            NSURL *url = [NSURL URLWithString:urlAddress];
            SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
            [self presentViewController:safariViewController animated:YES completion:nil];
        }
        else{
            //SFAUserGuideViewController *userGuideVC = [[SFAUserGuideViewController alloc] init];
            //[self presentViewController:userGuideVC animated:YES completion:nil];
        }
    }
    if (indexPath.section == 0 &&
        indexPath.row == 3) {
        [ATConnect sharedConnection].initialUserEmailAddress = [SFAServerAccountManager sharedManager].user.emailAddress;
        [[ATConnect sharedConnection] presentMessageCenterFromViewController:self];
        return;
    } else if (indexPath.section == 0 &&
               indexPath.row == 2) {
        if ([MFMailComposeViewController canSendMail]) {
            /*
            // Get Log File
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *fileName = @"LifeTrak.txt";
            NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
            
            NSString *zipFilename =@"LifeTrak.zip";
            NSString *zipFile = [documentsDirectory stringByAppendingPathComponent:zipFilename];
            ZipArchive *zipArchive = [[ZipArchive alloc] init];
            [zipArchive CreateZipFile2:zipFile];
            [zipArchive addFileToZip:logFilePath newname:fileName];
            [zipArchive CloseZipFile2];
            
            */
            // Get Log Files
            NSArray *logFilePaths = [SFALoggingFramework sharedInstance].logFilePaths;

            NSString *zipFilename = @"LifeTrak.zip";
            NSString *dirPath = ((NSString *)logFilePaths.firstObject).stringByDeletingLastPathComponent;
            NSString *zipFile = [dirPath stringByAppendingPathComponent:zipFilename];

            ZipArchive *zipArchive = [[ZipArchive alloc] init];
            [zipArchive CreateZipFile2:zipFile];
            for (NSString *logFilePath in logFilePaths) {
                [zipArchive addFileToZip:logFilePath newname:logFilePath.lastPathComponent];
            }
            [zipArchive CloseZipFile2];
            
            NSData *logData = [NSData dataWithContentsOfFile:zipFile];
            // Zip file no longer needed
            [[NSFileManager defaultManager] removeItemAtPath:zipFile error:nil];
            
            // Show send mail view
            MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
            mail.mailComposeDelegate = self;
            [mail setSubject:LS_HELP_SUBJECT];
            [mail setToRecipients:@[@"appsupport@lifetrakusa.com"]];
            [mail addAttachmentData:logData mimeType:@"application/zip" fileName:zipFilename];
            [mail.navigationBar setTintColor:[UIColor whiteColor]];
            
            [self presentViewController:mail animated:YES completion:nil];
        } else {
            if (self.isIOS8AndAbove) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                         message:LS_EMAIL_NOT_SET
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
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                                    message:LS_EMAIL_NOT_SET
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:BUTTON_TITLE_OK, nil];
                
                [alertView show];
            }
        }
    }
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

- (NSString *)watchModelStringForWatchModel:(WatchModel)watchModel
{
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

- (BOOL)isAutoSyncForWatchModel:(WatchModel)watchModel
{
    if (watchModel == WatchModel_Core_C200)
    {
        return NO;
    }
    else if (watchModel == WatchModel_Move_C300 ||
             watchModel == WatchModel_Move_C300_Android)
    {
        return NO;
    }
    else if (watchModel == WatchModel_Zone_C410 ||
             watchModel == WatchModel_R420)
    {
        return NO;
    }
    else if (watchModel == WatchModel_R450)
    {
        return YES;
    }
    else if (watchModel == WatchModel_R500)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - IBAction methods

- (IBAction)menuButtonPressed:(UIBarButtonItem *)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
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
    [SFAUserDefaultsManager sharedManager].bluetoothOn = _bluetoothOn;
}

#pragma mark - MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SFAPairViewControllerDelegate Methods

- (void)didPressContinueInPairViewController:(SFAPairViewController *)viewController
{
    
}

- (void)didPressCancelInPairViewController:(SFAPairViewController *)viewController
{
    
}


@end
