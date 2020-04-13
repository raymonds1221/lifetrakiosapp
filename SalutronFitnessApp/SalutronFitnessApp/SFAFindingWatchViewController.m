//
//  SFAFindingWatchViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/2/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAFindingWatchViewController.h"
#import "SFALoadingViewController.h"
#import "SFASalutronFitnessAppDelegate.h"

@interface SFAFindingWatchViewController ()

@property (nonatomic) BOOL stepCancelled;

@end

/*
 Step #1.a: Finding watch page shows instruction on how to turn on bluetooth on watch. This will display for 5 seconds then move to step #1.b.
 */

@implementation SFAFindingWatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initializeObjects];
}

- (void)initializeObjects{
    self.navigationController.navigationBarHidden = NO;
    self.mainLabel.text     = TURN_ON_BLE;
    self.subLabel.text      = PRESS_AND_HOLD_INSTRUCTION;
    self.stepCancelled = NO;
    self.title = FIND_WATCH_TITLE;
    [self performSelector:@selector(goToNextStep) withObject:nil afterDelay:5.0];
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

- (IBAction)leftButtonClicked:(id)sender {
    //[self dismissViewControllerAnimated:NO completion:nil];// popToRootViewControllerAnimated:YES];
    [self disconnect];
}

- (IBAction)rightButtonCicked:(id)sender {
}


- (void)goToNextStep{
    if (!self.stepCancelled) {
        [self performSegueWithIdentifier:@"FindingWatch1ToFindingWatch2" sender:self];
    }
}

- (void)disconnect{
    self.stepCancelled = YES;
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    SFALoadingViewController *rootController=(SFALoadingViewController *)((SFASalutronFitnessAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    rootController.isSwitchWatch = YES;
    [rootController returnToRoot];
}

@end
