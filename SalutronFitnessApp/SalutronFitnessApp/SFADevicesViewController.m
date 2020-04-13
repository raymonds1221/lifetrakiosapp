//
//  SFADevicesViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/9/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAWelcomeWatchCell.h"

#import "SFAServerSyncViewController.h"
#import "SFADevicesViewController.h"
#import "SFAMyAccountViewController.h"

#define WATCH_CELL_STYLE_1              @"SFAWelcomeWatchCell1"
#define WATCH_CELL_STYLE_2              @"SFAWelcomeWatchCell2"
#define SERVER_SYNC_SEGUE_IDENTIFIER    @"DevicesToServerSync"

@interface SFADevicesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SFADevicesViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SERVER_SYNC_SEGUE_IDENTIFIER]) {
        NSIndexPath *indexPath                      = [self.tableView indexPathForSelectedRow];
        SFAServerSyncViewController *viewController  = (SFAServerSyncViewController *)segue.destinationViewController;
        viewController.deviceEntity                 = self.deviceEntities[indexPath.row];
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.deviceEntities.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *cellIdentifier = indexPath.row % 2 == 0 ? WATCH_CELL_STYLE_1 : WATCH_CELL_STYLE_2;
        SFAWelcomeWatchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        [cell setContentsWithDevice:self.deviceEntities[indexPath.row]];
        return cell;
    }
    
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:SERVER_SYNC_SEGUE_IDENTIFIER sender:self];
    }
}

@end
