//
//  SFAIntroViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/19/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAIntroViewController.h"
#import "SFAIntroItemViewController.h"
#import "SFASlidingViewController.h"
#import "ErrorCodeToStringConverter.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "UIViewController+Helper.h"

#import "DeviceEntity+Data.h"
#import "SFAServerAccountManager.h"
#import "SFAWelcomeViewController.h"

#import "SFAUserDefaultsManager.h"
#import "Flurry.h"

//#define BACKGROUND_COLOR [UIColor colorWithRed:0.914 green:0.914 blue:0.914 alpha:1]
#define BACKGROUND_COLOR [UIColor whiteColor];

#define MAIN_VIEW_SEGUE_IDENTIFIER                  @"MainViewFromIntroSegueIndentifier"
#define DEVICE_SETUP_VIEW_SEGUE_IDENTIFIER          @"DeviceSetupViewFromIntroSegueIndentifier"
#define INTRO_TO_REGISTRATION_SEGUE_IDENTIFIER      @"IntroToRegistrationSegueIdentifier"
#define INTRO_TO_CONNECTION_SEGUE_IDENTIFIER        @"IntroToConnectionViewSegueIdentifier"
#define INTRO_TO_WELCOME_SEQUE_IDENTIFIER           @"IntroToWelcome"
#define WELCOME_VIEW_ID                             @"SFAWelcomeViewNavigationController"

@interface SFAIntroViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (assign, nonatomic) BOOL bluetoothOn;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) SFAServerAccountManager *serverAccountManager;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

- (SFAIntroItemViewController *) viewControllerAtIndex:(int) index;

@end

@implementation SFAIntroViewController

- (SFAServerAccountManager *)serverAccountManager
{
    if (!_serverAccountManager) {
        _serverAccountManager = [SFAServerAccountManager sharedManager];
    }
    return _serverAccountManager;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DDLogInfo(@"");
    if (!self.serverAccountManager.isFacebookLogIn && !self.serverAccountManager.isLoggedIn) {
        
        self.view.backgroundColor = BACKGROUND_COLOR;
        [self.signupButton setTitle:SIGNUP forState:UIControlStateNormal];
        [self.loginButton setTitle:SIGNIN forState:UIControlStateNormal];
        /*
        self.pageViewController = [[UIPageViewController alloc]
                                   initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                   options:nil];
         */
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Signup_Main" bundle:nil];
        self.pageViewController = [storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        self.pageViewController.dataSource = self;
        self.pageViewController.delegate = self;
        //self.pageViewController.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+20, self.view.frame.size.width, self.view.frame.size.height);
        //self.pageViewController.view.frame = self.view.frame;
        //[self.pageViewController.view setFrame:[[self view] bounds]];
        
        
        SFAIntroItemViewController *introItemViewController = [self viewControllerAtIndex:0];/*(SFAIntroItemViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"IntroItemViewController"];
        introItemViewController.view.frame = CGRectMake(0, 90, 320, 512);
        introItemViewController.view.backgroundColor = BACKGROUND_COLOR;
                                                               */
        NSArray * initialControllers = @[introItemViewController];//[[NSArray alloc] initWithObjects:introItemViewController, nil];
        
        [self.pageViewController setViewControllers:initialControllers
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:nil];
        
       // self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        [self addChildViewController:self.pageViewController];
        [self.view addSubview:self.pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
        
        [self.view sendSubviewToBack:self.pageViewController.view];
        
        self.setupDevice = (UIButton *) [self.view viewWithTag:1];
        self.seeYourStats = (UIButton *) [self.view viewWithTag:2];
        
        [self.setupDevice addTarget:self action:@selector(connectYourWatchPressed) forControlEvents:UIControlEventTouchUpInside];
        
        //[self.view bringSubviewToFront:self.setupDevice];
        //[self.view bringSubviewToFront:self.seeYourStats];
        //[self.view bringSubviewToFront:self.pageControl];
        
        self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.698 green:0.698 blue:0.698 alpha:1];
        self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.498 green:0.498 blue:0.498 alpha:1];
        
        self.pageControl.numberOfPages = 5;
        self.pageControl.currentPage = 0;
        self.pageControl.enabled = NO;
        
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        [self initializeObjects];
        self.salutronSDK = [SalutronSDK sharedInstance];
        self.salutronSDK.delegate = nil;
        [self.salutronSDK commDone];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    DDLogInfo(@"");
    [Flurry logEvent:INTRODUCTION_PAGE];
    [super viewDidAppear:animated];
    
    if (self.serverAccountManager.isFacebookLogIn || self.serverAccountManager.isLoggedIn) {
        DDLogError(@"MANAGER LOGIN");
        DDLogInfo(@"MANAGER LOGIN");
        //[self performSegueWithIdentifier:INTRO_TO_WELCOME_SEQUE_IDENTIFIER sender:self];
        NSString *storyBoardName = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"Main" : @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
        UIViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:WELCOME_VIEW_ID];
        [self presentViewController:ivc animated:YES completion:nil];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    /*if([[NSUserDefaults standardUserDefaults] boolForKey:HAS_PAIRED]) {
        [self performSegueWithIdentifier:@"MainViewFromIntroSegueIndentifier" sender:self];
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)unwindFromWelcomeView:(UIStoryboardSegue *)segue
{
    SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
    [manager logOut];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO forKey:PROMPT_CHANGE_SETTINGS];
    [userDefaults synchronize];
    DDLogInfo(@"PROMPT_CHANGE_SETTINGS : %d", [userDefaults boolForKey:PROMPT_CHANGE_SETTINGS]);
    
}

#pragma mark - Private Methods

- (SFAIntroItemViewController *) viewControllerAtIndex:(int)index {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Signup_Main" bundle:nil];
    SFAIntroItemViewController *introItemViewController = (SFAIntroItemViewController *) [storyboard instantiateViewControllerWithIdentifier:@"IntroItemViewController"];
    //introItemViewController.view.frame = self.pageViewController.view.frame;
    introItemViewController.index = index;
    
    introItemViewController.view.backgroundColor = BACKGROUND_COLOR;
    
    NSString *imagePathAppend = @"";
    
    if (LANGUAGE_IS_FRENCH) {
        imagePathAppend = @"_fr";
    }
    
    switch (index) {
        case 0:
            [introItemViewController.splashIntro setImage:[UIImage imageNamed:[NSString stringWithFormat:@"splash_intro_1%@", imagePathAppend]]];
            break;
        case 1:
            [introItemViewController.splashIntro setImage:[UIImage imageNamed:[NSString stringWithFormat:@"splash_intro_2%@", imagePathAppend]]];
            break;
        case 2:
            [introItemViewController.splashIntro setImage:[UIImage imageNamed:[NSString stringWithFormat:@"splash_intro_3%@", imagePathAppend]]];
            break;
        case 3:
            [introItemViewController.splashIntro setImage:[UIImage imageNamed:[NSString stringWithFormat:@"splash_intro_4%@", imagePathAppend]]];
            break;
        case 4:
            [introItemViewController.splashIntro setImage:[UIImage imageNamed:[NSString stringWithFormat:@"splash_intro_5%@", imagePathAppend]]];
            break;
        default:
            break;
    }
    return introItemViewController;
}

- (void)connectYourWatchPressed {
    if(_bluetoothOn) {
        [self performSegueWithIdentifier:DEVICE_SETUP_VIEW_SEGUE_IDENTIFIER sender:self];
    } else {
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
}

- (BOOL)hasDevicesWithNoUser
{
    NSArray *devices = [DeviceEntity deviceEntities];
    DDLogInfo(@"%@ : %@", LS_DEVICES, devices);
    for (DeviceEntity *device in devices) {
        if (device.user == nil) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - CBCentralManagerDelegate

- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
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

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController
       viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [(SFAIntroItemViewController *) viewController index];
    
    if(index == 0)
        return nil;
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController
        viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [(SFAIntroItemViewController *) viewController index];
    
    if(index == 4)
        return nil;
    index++;
    
    return [self viewControllerAtIndex:index];
}


#pragma mark - UIPageViewControllerDelegate

- (void) pageViewController:(UIPageViewController *)pageViewController
         didFinishAnimating:(BOOL)finished
    previousViewControllers:(NSArray *)previousViewControllers
        transitionCompleted:(BOOL)completed {
  
    SFAIntroItemViewController *introItemViewController = (SFAIntroItemViewController *) [pageViewController.viewControllers lastObject];
    int index = introItemViewController.index;
    
    self.pageControl.currentPage = index;
    
//    switch (index) {
//        case 0:
            self.setupDevice.imageView.image = [UIImage imageNamed:@"LT_v1_Sprint01_v1.4_mockups_walkthrough_setupdevicebutton.png"];
            self.seeYourStats.imageView.image = [UIImage imageNamed:@"LT_v1_Sprint01_v1.4_mockups_walkthrough_seeyourstatsbutton.png"];
//            break;
//        case 1:
//            self.setupDevice.imageView.image = [UIImage imageNamed:@"LT_v1_Sprint01_v1.4_mockups_walkthrough_seeyourstatsbutton.png"];
//            self.seeYourStats.imageView.image = [UIImage imageNamed:@"LT_v1_Sprint01_v1.4_mockups_walkthrough_seeyourstatsbutton.png"];
//            break;
//        case 2:
//            self.setupDevice.imageView.image = [UIImage imageNamed:@"LT_v1_Sprint01_v1.4_mockups_walkthrough_seeyourstatsbutton.png"];
//            self.seeYourStats.imageView.image = [UIImage imageNamed:@"LT_v1_Sprint01_v1.4_mockups_walkthrough_seeyourstatsbutton.png"];
//            break;
//        case 3:
//            self.setupDevice.imageView.image = [UIImage imageNamed:@"LT_v1_Sprint01_v1.4_mockups_walkthrough_seeyourstatsbutton.png"];
//            self.seeYourStats.imageView.image = [UIImage imageNamed:@"LT_v1_Sprint01_v1.4_mockups_walkthrough_seeyourstatsbutton.png"];
//            break;
//        default:
//            break;
//    }
}

#pragma mark - IBAction Methods

- (IBAction)showStatisticsButtonPressed:(id)sender
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    BOOL isPaired                   = [userDefaults boolForKey:HAS_PAIRED];
    
    if (isPaired)
    {
        [self performSegueWithIdentifier:MAIN_VIEW_SEGUE_IDENTIFIER sender:sender];
    }
    else
    {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NO_DATA_ALERT_TITLE
                                                                                     message:NO_DATA_ALERT_MESSAGE
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
                                           [self performSegueWithIdentifier:MAIN_VIEW_SEGUE_IDENTIFIER sender:alertController];
                                       }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:continueAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NO_DATA_ALERT_TITLE
                                                                message:NO_DATA_ALERT_MESSAGE
                                                               delegate:self
                                                      cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                      otherButtonTitles:BUTTON_TITLE_CONTINUE, nil];
            
            [alertView show];
        }
    }
    
    // [self performSegueWithIdentifier:MAIN_VIEW_SEGUE_IDENTIFIER sender:sender];
}

- (IBAction)signUpButtonClicked:(id)sender
{
   /*
    [SFAUserDefaultsManager sharedManager].cloudSyncEnabled = YES;
    
    
    if ([self hasDevicesWithNoUser]) { //change to check only devices without user.
        [self performSegueWithIdentifier:INTRO_TO_REGISTRATION_SEGUE_IDENTIFIER sender:sender];
    }
    else {
     
        [self performSegueWithIdentifier:INTRO_TO_CONNECTION_SEGUE_IDENTIFIER sender:sender];
    }
    */
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self performSegueWithIdentifier:MAIN_VIEW_SEGUE_IDENTIFIER sender:alertView];
    }
}

#pragma mark - Private Methods

- (void)initializeObjects
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:DEVICE_UUID];
    [userDefaults setObject:nil forKey:MAC_ADDRESS];
    [userDefaults setObject:@(NO) forKey:HAS_PAIRED];
    [userDefaults setBool:YES forKey:AUTO_SYNC_TIME];
    [userDefaults synchronize];
}

@end
