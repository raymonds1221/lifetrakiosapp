//
//  SFAMenuViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/14/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "ECSlidingViewController.h"
#import "UIViewController+Helper.h"
#import "UIImageView+WebCache.h"

#import "SFAMenuViewController.h"
#import "SFAIntroViewController.h"
#import "SFALoadingViewController.h"
#import "SFASalutronFitnessAppDelegate.h"

#import "SFASlidingViewController.h"

#import "SFAMenuProfileCell.h"

#import "SFAGoalsSetupViewController.h"
#import "SFAMenuCell.h"
#import "SFASyncView.h"

#import "SFAServerAccountManager.h"

#import "TimeDate+Data.h"
#import "UIView+CircularMask.h"

#import "AFHTTPRequestOperationManager.h"

#define MENU_CELL_IDENTIFIER                @"SFAMenuCell"
#define SETTINGS_HEADER_CELL_IDENTIFIER     @"SFASettingsHeaderCell"
#define PROFILE_CELL                        @"SFAMenuProfileCell"

@interface SFAMenuViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *menu;
@property (strong, nonatomic) NSArray *settings;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@end

@implementation SFAMenuViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBuildVersion];
    //[self setInitialSelectedCell];
    
    SFAServerAccountManager *manager    = [SFAServerAccountManager sharedManager];
    
    [manager getProfileWithSuccess:^{
        [self updateProfile];
    } failure:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateProfile];
    [self setLastSync];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
            //SFAIntroViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAIntroViewController"];
            [manager logOut];
            //[self.slidingViewController presentViewController:viewController animated:YES completion:nil];
            /*SFALoadingViewController *nav = (SFALoadingViewController*) self.view.window.rootViewController;
            //[self.navigationController popToViewController:nav animated:NO];
            [nav returnToRoot];
            */
            
            SFALoadingViewController *rootController=(SFALoadingViewController *)((SFASalutronFitnessAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
            [rootController returnToRoot];
        }
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1 ||
        section == 2) {
        return 5.0f;
    }
    
    return 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1 ||
        section == 2)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTINGS_HEADER_CELL_IDENTIFIER];
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.menu.count;
    } else if (section == 2) {
        return self.settings.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 90.0f;
    } else {
        return 44.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SFAMenuProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:PROFILE_CELL];
        self.userImage          = cell.userImage;
        self.userName           = cell.userName;
        UIView *view            = [[UIView alloc] init];
        view.backgroundColor    = SELECTED_CELL_BACKGROUND_COLOR;
        [cell setSelectedBackgroundView:view];
        [self updateProfile];
        
        return cell;
    } else if (indexPath.section == 1) {
        UIImage *menuIcon;
        BOOL withSeparator      = indexPath.row < self.menu.count - 1;
        SFAMenuCell *cell       = [tableView dequeueReusableCellWithIdentifier:MENU_CELL_IDENTIFIER];
        UIView *view            = [[UIView alloc] init];
        view.backgroundColor    = SELECTED_CELL_BACKGROUND_COLOR;
        
        [cell setSelectedBackgroundView:view];
        
        
        if ([_menu[indexPath.row] isEqualToString:kMenuDashboard])
        {
             menuIcon = [UIImage imageNamed:@"MenuDashboard"];
        }
        else if ([_menu[indexPath.row] isEqualToString:kMenuGoals])
        {
            menuIcon = [UIImage imageNamed:@"MenuGoals"];
        }
        else if ([_menu[indexPath.row] isEqualToString:kActigraphy])
        {
            menuIcon = [UIImage imageNamed:@"MenuActigraphy"];
        }
        else if ([_menu[indexPath.row] isEqualToString:kMenuPulsewaveAnalysis])
        {
           menuIcon = [UIImage imageNamed:@"lifetrack_mnav_icon_pulsewave.png"];
        }
        else if ([_menu[indexPath.row] isEqualToString:kSettingsPartners])
        {
            menuIcon = nil;
        }
        else
        {
            menuIcon = nil;
        }
        
        [cell setContentsWithImage:menuIcon label:self.menu[indexPath.row] withSeparator:withSeparator];
        
        return cell;
    }
    else if (indexPath.section == 2)
    {
        UIImage *menuIcon;
        SFAMenuCell *cell       = [tableView dequeueReusableCellWithIdentifier:MENU_CELL_IDENTIFIER];
        UIView *view            = [[UIView alloc] init];
        view.backgroundColor    = SELECTED_CELL_BACKGROUND_COLOR;
        
        [cell setSelectedBackgroundView:view];
        
        if ([_settings[indexPath.row] isEqualToString:kSettingsApplication])
        {
            menuIcon = [UIImage imageNamed:@"MenuHelp"];
        }
        else if ([_settings[indexPath.row] isEqualToString:kSettingsSync])
        {
            menuIcon = [UIImage imageNamed:@"MenuSettings"];
        }
        else if ([_settings[indexPath.row] isEqualToString:kSettingsSignOut])
        {
            menuIcon = [UIImage imageNamed:@"MenuLogout"];
        }
        else if ([_settings[indexPath.row] isEqualToString:kSettingsPartners])
        {
            menuIcon = [UIImage imageNamed:@"MenuPartners"];
        }
        else
        {
            menuIcon = nil;
        }
        
        [cell setContentsWithImage:menuIcon label:self.settings[indexPath.row] withSeparator:YES];
        
        return cell;
    }
    
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate Methods

/*- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell               = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor    = SELECTED_CELL_BACKGROUND_COLOR;
    cell.backgroundColor                = SELECTED_CELL_BACKGROUND_COLOR;
    
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell               = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor    = CELL_BACKGROUND_COLOR;
    cell.backgroundColor                = CELL_BACKGROUND_COLOR;
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFASlidingViewController *viewController = (SFASlidingViewController *)self.slidingViewController;
    
    if (indexPath.section == 0) {
        [viewController showMyAccount];
    } else if (indexPath.section == 1) {
        if ([_menu[indexPath.row] isEqualToString:kMenuDashboard])
        {
            [viewController showDashboard];
        }
        else if ([_menu[indexPath.row] isEqualToString:kMenuGoals])
        {
            [viewController showGoalsSetup];
        }
        else if ([_menu[indexPath.row] isEqualToString:kActigraphy])
        {
            [viewController showActigraphy];
        }
        else if ([_menu[indexPath.row] isEqualToString:kMenuPulsewaveAnalysis])
        {
            [viewController showPulsewave];
        }
        else if ([_menu[indexPath.row] isEqualToString:kMenuAlarms])
        {
            //show alarm
        }
    }
    else if(indexPath.section == 2)
    {
        if ([_settings[indexPath.row] isEqualToString:kSettingsApplication])
        {
            [viewController showSettings];
        }
        else if ([_settings[indexPath.row] isEqualToString:kSettingsSync])
        {
            [viewController showSyncSetup];
        }
        else if ([_settings[indexPath.row] isEqualToString:kSettingsPartners])
        {
            [viewController showPartners];
        }
        else if ([_settings[indexPath.row] isEqualToString:kSettingsSignOut]) {
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
                                               //SFAIntroViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAIntroViewController"];
                                               [manager logOut];
                                               //[self.slidingViewController presentViewController:viewController animated:YES completion:nil];
                                               //SFALoadingViewController *nav = (SFALoadingViewController*) self.view.window.rootViewController;
                                               //[self.navigationController popToViewController:nav animated:NO];
                                               //[nav returnToRoot];
                                               SFALoadingViewController *rootController=(SFALoadingViewController *)((SFASalutronFitnessAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
                                               [rootController returnToRoot];
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
                alertView.tag           = 1;
                
                [alertView show];
            }
            /* Remove local notification */
//            UILocalNotification *localNotification;
//            localNotification = [UILocalNotification new];
//            localNotification.alertBody = SYNC_NOTIFICATION_MESSAGE;
//            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:20];
//            localNotification.timeZone = [NSTimeZone localTimeZone];
//            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
    
    [self.slidingViewController resetTopView];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Getters

- (NSArray *)menu
{
    if (!_menu)
    {
        //Get watch model connected
        //NSUserDefaults *_userDefaults   = [NSUserDefaults standardUserDefaults];
        //WatchModel _watchModel          = [[_userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
       
        //Set menu
        NSArray *_menuArray = @[kMenuDashboard,
                                kMenuGoals,
                                //kActigraphy,
                                kMenuPulsewaveAnalysis,
                                kMenuAlarms];
        _menu               = [NSMutableArray array];
        _menu               = [_menuArray mutableCopy];
        
        
        //Get watch model connected
        NSUserDefaults *_userDefaults   = [NSUserDefaults standardUserDefaults];
        WatchModel _watchModel          = [[_userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
        
        //Remove pulsewave menu if watch does not support it
        if (_watchModel == WatchModel_Core_C200 ||
            _watchModel == WatchModel_Move_C300 ||
            _watchModel == WatchModel_Move_C300_Android ||
            _watchModel == WatchModel_R450 ||
            _watchModel == WatchModel_Zone_C410 ||
            _watchModel == WatchModel_R420)
            [_menu removeObject:kMenuPulsewaveAnalysis];
        
        //remove actigraphy menu if watch does not support it
        if (_watchModel == WatchModel_Core_C200 ||
            _watchModel == WatchModel_Move_C300 ||
            _watchModel == WatchModel_Move_C300_Android)
            [_menu removeObject:kActigraphy];

        //Remove alarm menu (temporary) comment code below if you wish to put alarm menu back
        [_menu removeObject:kMenuAlarms];
    }
    
    return _menu;
}

- (NSArray *)settings
{
    if (!_settings)
    {
        _settings = @[kSettingsSync,
                      kSettingsPartners,
                      kSettingsApplication,
                      kSettingsSignOut];
    }
    
    return _settings;
}

#pragma mark - Private Methods

- (void)updateProfile
{
    SFAServerAccountManager *manager    = [SFAServerAccountManager sharedManager];
    self.userName.text                  = [NSString stringWithFormat:@"%@ %@", manager.user.firstName, manager.user.lastName];
    NSURL *url                          = manager.user.imageURL ? [NSURL URLWithString:manager.user.imageURL] : [NSURL URLWithString:manager.user.imageURL];
    UIImage *placeholderImage           = [UIImage imageNamed:@"ProfileDefaultPicture"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];//[[UIImage alloc] initWithData:data cache:NO];
        self.userImage.image = placeholderImage;
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.userImage.image = img;
            if (!img) {
                self.userImage.image = placeholderImage;
            }
        });
        //    [self.userImage setImageWithURL:url placeholderImage:placeholderImage options:SDWebImageRefreshCached];
        [self.userImage addCircularMaskToBounds:self.userImage.frame];
    });
}

- (void)setLastSync
{
    TimeDate *_timeDate             = [TimeDate getData];
    
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSData *data                    = [userDefaults objectForKey:LAST_SYNC_DATE];
    if (data) {
        NSDate *date                    = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
        if (_timeDate.hourFormat == _12_HOUR && _timeDate.dateFormat == 0) {
            dateFormatter.dateFormat        = @"dd MMM yyyy, hh:mm a";
        }
        else if (_timeDate.hourFormat == _12_HOUR && _timeDate.dateFormat == 1) {
            dateFormatter.dateFormat        = @"MMM dd yyyy, hh:mm a";
        }
        else if (_timeDate.hourFormat == _24_HOUR && _timeDate.dateFormat == 0) {
            dateFormatter.dateFormat        = @"dd MMM yyyy, HH:mm";
        }
        else {
            dateFormatter.dateFormat        = @"MMM dd yyyy, HH:mm";
        }
        
        NSString *dateSynced = [dateFormatter stringFromDate:date];
        
        if (LANGUAGE_IS_FRENCH && _timeDate.hourFormat == _24_HOUR) {
            dateSynced = [dateSynced stringByReplacingOccurrencesOfString:@":" withString:@"h"];
        }
        
        dateSynced = [[dateSynced stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
    
        self.lastSync.text              = dateSynced;
    }
    else {
        self.lastSync.text              = MESSAGE_NOT_YET_SYNCED;
    }
}

- (void)setBuildVersion
{
    NSString *sdkVersion    = [SalutronSDK getVersion];
    NSBundle *bundle        = [NSBundle mainBundle];
    NSString *build         = [bundle objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    NSString *firmwareRevision      = [SFAUserDefaultsManager sharedManager].firmwareRevision;
    NSString *softwareRevision      = [SFAUserDefaultsManager sharedManager].softwareRevision;
    
//    NSMutableString *buildVersionText = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"App Version: %@ | SDK Version: %@", build, sdkVersion]];
    
    NSMutableString *buildVersionText = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ | %@ %@", LS_APP_VERSION, build, LS_SDK_VERSION, sdkVersion]];
    
    if (firmwareRevision)
        [buildVersionText appendString:[NSString stringWithFormat:@" | %@ %@", LS_FW_VERSION, firmwareRevision]];
    if (softwareRevision)
        [buildVersionText appendString:[NSString stringWithFormat:@" | %@ %@", LS_SW_VERSION, softwareRevision]];
    
    if (RELEASE == 1) {
        self.buildVersion.text          = @"";
    } else {
        self.buildVersion.text          = buildVersionText;
    }
}

- (void)setInitialSelectedCell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - IBAction Methods

- (IBAction)viewProfileButtonPressed:(id)sender
{
    SFASlidingViewController *viewController = (SFASlidingViewController *)self.slidingViewController;
    [viewController showMyAccount];
    [self.slidingViewController resetTopView];
}


@end
