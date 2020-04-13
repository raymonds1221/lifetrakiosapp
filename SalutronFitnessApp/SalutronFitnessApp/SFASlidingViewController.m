//
//  SFASlidingViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/14/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFASlidingViewController.h"

#import "SFAActigraphyScrollViewController.h"
#import "SFADashboardScrollViewController.h"
#import "SFAMainViewController.h"
#import "UIViewController+Helper.h"

@interface SFASlidingViewController ()

@property (strong, nonatomic) UIViewController *menu;
@property (strong, nonatomic) UIViewController *dashboard;
@property (strong, nonatomic) UIViewController *goalsSetup;
@property (strong, nonatomic) UIViewController *actigraphy;
@property (strong, nonatomic) UIViewController *syncSetup;
@property (strong, nonatomic) UIViewController *pulsewaveAnaylysis;
@property (strong, nonatomic) UIViewController *settings;
@property (strong, nonatomic) UIViewController *myAccount;
@property (strong, nonatomic) UIViewController *partners;

- (void)setViewControllers;

@end

@implementation SFASlidingViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setViewControllers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    /*if(self.isIOS8AndAbove) // added support for iOS 8
        self.topViewController.view.frame = [[UIScreen mainScreen] bounds];*/
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return _shouldRotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return (_shouldRotate) ? UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Getters

- (UIViewController *)menu
{
    if (!_menu)
    {
        _menu = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAMenuViewController"];
    }
    return _menu;
}

- (UIViewController *)dashboard
{
    if (!_dashboard)
    {
        _dashboard = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAMainViewController"];
    }
    return _dashboard;
}

- (UIViewController *)goalsSetup
{
    if (!_goalsSetup)
    {
        _goalsSetup = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAGoalsNavigation"];
    }
    return _goalsSetup;
}

- (UIViewController *)actigraphy
{
    if (!_actigraphy)
    {
        _actigraphy = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAActrigraphyNavigation"];
    }
    return _actigraphy;
}

- (UIViewController *)syncSetup
{
    if(!_syncSetup) {
        _syncSetup = [self.storyboard instantiateViewControllerWithIdentifier:@"SFASyncSetupNavigation"];
    }
    return _syncSetup;
}

- (UIViewController *)pulsewaveAnaylysis
{
    if(!_pulsewaveAnaylysis) {
        _pulsewaveAnaylysis = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAPulsewaveNavigation"];
    }
    return _pulsewaveAnaylysis;
}

- (UIViewController *)settings
{
    if(!_settings) {
        _settings = [self.storyboard instantiateViewControllerWithIdentifier:@"SFASettingsNavigation"];
    }
    return _settings;
}

- (UIViewController *)myAccount
{
    if(!_myAccount) {
        _myAccount = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAEditProfileNavigation"];//@"SFAMyAccountNavigation"];
    }
    return _myAccount;
}

- (UIViewController *)partners
{
    if (!_partners){
        _partners = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAPartnersNavigation"];
    }
    return _partners;
}

#pragma mark - Setters

- (void)setShouldRotate:(BOOL)shouldRotate
{
    _shouldRotate = shouldRotate;
    [self shouldAutorotate];
    [self supportedInterfaceOrientations];
}

#pragma mark - Private Methods

- (void)setViewControllers
{
    self.underLeftViewController                            = self.menu;
    self.underRightViewController                           = nil;
    self.underLeftWidthLayout                               = ECFullWidth;
    self.anchorRightRevealAmount                            = 240.0f;
    self.topViewController                                  = self.dashboard;
    self.shouldAddPanGestureRecognizerToTopViewSnapshot     = YES;
}

#pragma mark - Public Methods

- (void)showDashboard
{
    self.shouldRotate   = NO;
    self.isActigraphy   = NO;
    [self.dashboard.childViewControllers[0] popToRootViewControllerAnimated:YES];
    self.topViewController = self.dashboard;
}

- (void)showGoalsSetup
{
    self.shouldRotate = NO;
    self.topViewController = self.goalsSetup;
}

- (void)showActigraphy
{
    self.shouldRotate = YES;
    self.isActigraphy = YES;
    self.topViewController = self.actigraphy;
}

- (void)showSyncSetup
{
    self.shouldRotate = NO;
    self.topViewController = self.syncSetup;
}

- (void)showPulsewave
{
    self.shouldRotate = NO;
    self.topViewController = self.pulsewaveAnaylysis;
}

- (void)showSettings
{
    self.shouldRotate = NO;
    self.topViewController = self.settings;
}

- (void)showMyAccount
{
    self.shouldRotate = NO;
    self.topViewController = self.myAccount;
}

- (void)showPartners
{
    self.shouldRotate = NO;
    self.topViewController = self.partners;
}

@end
