//
//  SFAConnectionNavigationViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 2/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAConnectionNavigationViewController.h"

@interface SFAConnectionNavigationViewController ()

@end

@implementation SFAConnectionNavigationViewController

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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
