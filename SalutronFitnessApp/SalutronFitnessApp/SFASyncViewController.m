//
//  SFASyncViewController.m
//  SalutronFitnessApp
//
//  Created by Dana Elisa Nicolas on 12/9/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFASyncViewController.h"

@interface SFASyncViewController ()

@end

@implementation SFASyncViewController

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

- (void) setNavigationButtons
{
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSync:)];
    
    [self.navigationController.navigationItem setLeftBarButtonItem:cancel];
}

- (void)cancelSync:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
