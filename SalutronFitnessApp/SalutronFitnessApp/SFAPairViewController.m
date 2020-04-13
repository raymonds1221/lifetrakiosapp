//
//  SFAPairViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/15/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAPairViewController.h"
#import "SFADashboardScrollViewController.h"
#import "SFAGoalsSetupViewController.h"
#import "SFASettingsViewController.h"
#import "SFANotificationsViewController.h"
#import "SFAMyAccountViewController.h"
#import "Flurry.h"

#define IPHONE_4_RECTANGLE_WATCH    @"PairingRectangleWatchiPhone4Frame"
#define IPHONE_4_ROUND_WATCH        @"PairingRoundWatchiPhone4Frame"
#define IPHONE_4_ROUND_WATCH_BLUE   @"PairingRoundWatchBlueiPhone4Frame"
#define IPHONE_5_RECTANGLE_WATCH    @"PairingRectangleWatchiPhone5Frame"
#define IPHONE_5_ROUND_WATCH        @"PairingRoundWatchiPhone5Frame"
#define IPHONE_5_ROUND_WATCH_BLUE   @"PairingRoundWatchBlueiPhone5Frame"

@interface SFAPairViewController ()

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *pressAndHoldLabel;
@property (weak, nonatomic) IBOutlet UILabel *helpTipsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageBottomConstraints;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *titleBarItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *watchNameTopConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *watchNameHeightConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelCButtonHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueCButtonHeight;


@end

@implementation SFAPairViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Flurry logEvent:PAIRING_PAGE];
    //if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        self.continueCButtonHeight.constant = 55;
        self.cancelCButtonHeight.constant = 55;
        self.cancelButtonHeight.constant = 55;
    //}
    [self initializeObjects];
    
}
/*
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.imageView.animationImages = nil;
    [self.imageView stopAnimating];    //here animation stops
    [self.imageView removeFromSuperview];    // here view removes from view hierarchy
    self.imageView = nil;
    [self.view.layer removeAllAnimations];
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) shouldAutorotate {
    return NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Cancel Sync"]) {
       // [self.imageView stopAnimating];
      //  self.imageView.animationImages = nil;
    }
}

#pragma mark - IBAction Methods

- (IBAction)continueButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.imageView stopAnimating];
        
        self.imageView.animationImages = nil;
        
        if ([self.delegate conformsToProtocol:@protocol(SFAPairViewControllerDelegate)] &&
            [self.delegate respondsToSelector:@selector(didPressContinueInPairViewController:)]){
            [self.delegate didPressContinueInPairViewController:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
        }
    }];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    if ([self.delegate isKindOfClass:[SFADashboardScrollViewController class]] ||
        [self.delegate isKindOfClass:[SFAGoalsSetupViewController class]] ||
        [self.delegate isKindOfClass:[SFASettingsViewController class]] ||
        [self.delegate isKindOfClass:[SFANotificationsViewController class]] ||
        [self.delegate isKindOfClass:[SFAMyAccountViewController class]]) {
       // [self dismissViewControllerAnimated:YES completion:^{
           // [self.imageView stopAnimating];
            
            //self.imageView.animationImages = nil;
            
            if ([self.delegate conformsToProtocol:@protocol(SFAPairViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(didPressCancelInPairViewController:)]){
                [self.delegate didPressCancelInPairViewController:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
            }
            
       // }];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:^{
            [self.imageView stopAnimating];
            
            self.imageView.animationImages = nil;
            
            if ([self.delegate conformsToProtocol:@protocol(SFAPairViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(didPressCancelInPairViewController:)]){
                [self.delegate didPressCancelInPairViewController:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
            }
            
        }];
    }
}

#pragma mark - Private Methods

- (void)initializeObjects
{
    if (self.watchModel == WatchModel_Move_C300_Android) {
        self.watchModel = WatchModel_Move_C300;
    }
    switch (self.watchModel) {
        case WatchModel_Move_C300:
            self.labelWatchName.text = [NSString stringWithFormat:@"%@ %@", LS_SYNCING, WATCHNAME_MOVE_C300];
            break;
        case WatchModel_Zone_C410:
            self.labelWatchName.text = [NSString stringWithFormat:@"%@ %@", LS_SYNCING, WATCHNAME_ZONE_C410];
            break;
        case WatchModel_R420:
            self.labelWatchName.text = [NSString stringWithFormat:@"%@ %@", LS_SYNCING, WATCHNAME_R420];
            break;
        case WatchModel_R450:
            self.labelWatchName.text = [NSString stringWithFormat:@"%@ %@", LS_PAIRING, WATCHNAME_BRITE_R450];
            break;
        case WatchModel_R500:
            self.labelWatchName.text = [NSString stringWithFormat:@"%@ %@", LS_PAIRING, WATCHNAME_R500];
            break;
        default:
            break;
    }
    
    self.imageView.animationImages      = self.images;
    self.imageView.animationDuration    = 3.0f;
    [self.imageView startAnimating];
    
    self.cancelButton.hidden = !self.showCancelSyncButton;
    
    [self.pressAndHoldLabel sizeToFit];
    if (self.isPaired) {
        [self displayWatchIsPairedWindow];
    }
}

- (BOOL)isiPhone5
{
    CGRect screenRect       = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight    = screenRect.size.height;
    return screenHeight >= 568;
}

- (BOOL)isiPad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (NSString *)imageName
{
    if (self.watchModel == WatchModel_Move_C300 ||
        self.watchModel == WatchModel_Move_C300_Android ||
        self.watchModel == WatchModel_Zone_C410)
    {
        if (self.isiPhone5 || self.isiPad)
        {
            return IPHONE_5_RECTANGLE_WATCH;
        }
        else
        {
            return IPHONE_4_RECTANGLE_WATCH;
        }
    }
    else if (self.watchModel == WatchModel_R450 ||
             self.watchModel == WatchModel_R500 ||
             self.watchModel == WatchModel_R420)
    {
        if (self.isiPhone5 ||  self.isiPad)
        {
            if (self.isPaired) {
                return IPHONE_5_ROUND_WATCH_BLUE;
            } else {
                return IPHONE_5_ROUND_WATCH;
            }
        }
        else
        {
            if (self.isPaired) {
                return IPHONE_4_ROUND_WATCH_BLUE;
            } else {
                return IPHONE_4_ROUND_WATCH;
            }
        }
    }
    
    return nil;
}

- (NSArray *)images
{
    NSMutableArray *images = [NSMutableArray new];
    
    for (int a = 0; a < 30; a++)
    {
        NSString *assetName = [NSString stringWithFormat:@"%@%i", self.imageName, a];
        UIImage *image      = [UIImage imageNamed:assetName];
        if (image) {
            [images addObject:image];
        }
    }
    
    return images.copy;
}

- (void)displayWatchIsPairedWindow
{
    self.labelWatchName.hidden = YES;
    //self.pressAndHoldLabel.hidden = YES;
    self.watchNameTopConstraints.constant = 0;
    //self.watchNameHeightConstraints.constant = 0;
    self.pressAndHoldLabel.text = WATCH_DATA_NOT_SYNCING;
    self.helpTipsLabel.text = PAIRED_MESSAGE;
    
    if ([self isiPad]) {
        //[self.pressAndHoldLabel setFont:[self.pressAndHoldLabel.font fontWithSize:15]];
        [self.helpTipsLabel setFont:[self.helpTipsLabel.font fontWithSize:12]];
    } else {
        //[self.pressAndHoldLabel setFont:[self.pressAndHoldLabel.font fontWithSize:10]];
        [self.helpTipsLabel setFont:[self.helpTipsLabel.font fontWithSize:12]];
    }
    
    [self.helpTipsLabel setTextAlignment:NSTextAlignmentLeft];
    self.helpTipsLabel.adjustsFontSizeToFitWidth = YES;
    [self.helpTipsLabel setNumberOfLines:0];
    [self.helpTipsLabel setMinimumScaleFactor:0.5];
    [self.helpTipsLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.navigationBar setBarTintColor:SYNC_BLUE_COLOR];
    self.titleBarItem.title = @"Sync";
}

@end
