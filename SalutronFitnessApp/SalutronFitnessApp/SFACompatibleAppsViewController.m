//
//  SFACompatibleAppsViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 1/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "DeviceEntity+Data.h"

#import "SFACompatibleAppsViewController.h"
#import "SFACompatibleAppsCell.h"

#define COMPATIBLEAPP_CELL_IDENTIFIER @"SFACompatibleAppCellIdentifier"

@interface SFACompatibleAppsViewController ()

@end

@implementation SFACompatibleAppsViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
    DeviceEntity *device            = [DeviceEntity deviceEntityForMacAddress:macAddress];
    
    if (device.modelNumber.integerValue == WatchModel_Move_C300 || device.modelNumber.integerValue == WatchModel_Move_C300_Android) {
        return 2;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFACompatibleAppsCell *compatibleAppsCell = [tableView dequeueReusableCellWithIdentifier:COMPATIBLEAPP_CELL_IDENTIFIER];
    
    switch (indexPath.row) {
        case 0: {
            compatibleAppsCell.compatibleApp = ARGUS;
            compatibleAppsCell.compatibleAppsImage.image = [UIImage imageNamed:@"comapps_icon_argus"];
            compatibleAppsCell.compatibleAppsLabel.text = @"Argus";
            break;
        }
        case 1: {
            compatibleAppsCell.compatibleApp = MAP_MY_FITNESS;
            compatibleAppsCell.compatibleAppsImage.image = [UIImage imageNamed:@"comapps_icon_mapmyfit"];
            compatibleAppsCell.compatibleAppsLabel.text = @"MapMyFitness";
            break;
        }
        default:
            break;
    }
    
    return compatibleAppsCell;
}

@end
