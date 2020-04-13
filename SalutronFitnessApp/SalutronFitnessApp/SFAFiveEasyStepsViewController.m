//
//  SFAFiveEasyStepsViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/2/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAFiveEasyStepsViewController.h"

#import "SFAServerAccountManager.h"

@interface SFAFiveEasyStepsViewController () <CBCentralManagerDelegate>

@property (nonatomic) BOOL bluetoothOn;
@property (strong, nonatomic) SFAUserDefaultsManager *userDefaultsManager;
@property (strong, nonatomic) CBCentralManager  *centralManager;

@end

/*
 New sign up flow: 5 Easy Steps
*/

@implementation SFAFiveEasyStepsViewController

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    [self initializeObjects];
}

- (void)initializeObjects{
    SFAServerAccountManager *manager    = [SFAServerAccountManager sharedManager];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    NSString *welcomeUser = WELCOME_USER;
    if (LANGUAGE_IS_FRENCH) {
        self.welcomeTitle.text = [NSString stringWithFormat:@"%@ %@ !", welcomeUser, manager.user.firstName];
    }
    else{
        self.welcomeTitle.text = [NSString stringWithFormat:@"%@ %@!", welcomeUser, manager.user.firstName];
    }
    self.setupLabel.text            = SETUP_5_EASY_STEPS;
    self.step1Label.text            = FIND_WATCH;
    self.step2Label.text            = PAIR_WATCH;
    self.step3Label.text            = SYNC_DATA;
    self.step4Label.text            = ADD_DETAILS;
    self.step5Label.text            = BACKUP_DATA;
    self.pleaseMakeSureLabel.text   = PLEASE_MAKE_SURE;
    NSString *getStarted = GET_STARTED;
    [self.getStartedButton setTitle:getStarted forState:UIControlStateNormal];
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
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    //check for bluetooth
    if (!self.bluetoothOn) {
        [self alertWithTitle:@"" message:PLEASE_ENABLE_BLE];
        return NO;
    }
    else{
        return YES;
    }
}

- (IBAction)getStartedButtonClicked:(id)sender {
    
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

@end
