//
//  SFAPartnersViewController.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 6/19/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAPartnersViewController.h"
#import "ECSlidingViewController.h"
#import "Flurry.h"

@interface SFAPartnersViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SFAPartnersViewController

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

    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [Flurry logEvent:PARTNERS_PAGE];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)menuButtonPressed:(UIBarButtonItem *)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SFAUserDefaultsManager *defaultsManager = [SFAUserDefaultsManager sharedManager];
#if WALGREENS
    return  defaultsManager.watchModel == WatchModel_R450 ? 1 : 2;
#else
    return  defaultsManager.watchModel == WatchModel_R450 ? 0 : 1;
#endif
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFAUserDefaultsManager *defaultsManager = [SFAUserDefaultsManager sharedManager];
    
    if (defaultsManager.watchModel == WatchModel_R450) {
        #if WALGREENS
            return [tableView dequeueReusableCellWithIdentifier:@"RewardsCell"];
        #endif
    }
    else {
        if (indexPath.row == 0) {
            return [tableView dequeueReusableCellWithIdentifier:@"CompatibleAppsCell"];
        }
        #if WALGREENS
        else if (indexPath.row == 1){
            return [tableView dequeueReusableCellWithIdentifier:@"RewardsCell"];
        }
        #endif
    }
    
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
