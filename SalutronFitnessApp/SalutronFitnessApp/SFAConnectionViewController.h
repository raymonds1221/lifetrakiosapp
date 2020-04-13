//
//  SFAViewController.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/11/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorCodeToStringConverter.h"
#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "StatisticalDataPointEntity+StatisticalDataPointEntityCategory.h"
#import "SFASyncConnectionView.h"

typedef enum {
    IntroViewController,
    SyncSetupViewController
} ViewController;

@interface SFAConnectionViewController : UIViewController<SalutronSDKDelegate, UITableViewDataSource, UITableViewDelegate, SFASyncConnectionViewDelegate>

@property (weak, nonatomic) SalutronSDK *salutronSDK;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (assign, nonatomic) ViewController previousController;

@property (strong, nonatomic) SFASyncConnectionView     *syncView;

- (void) discoverDevice;
- (void) navigateToMainViewController;
- (IBAction) backPressed:(id)sender;
- (void)showTryAgainFailView;
- (void)showChecksumFailView;

@end

