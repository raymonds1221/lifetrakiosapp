//
//  SFANotesViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/2/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFANotesViewController.h"

@interface SFANotesViewController ()

@end

@implementation SFANotesViewController

#pragma mark - UIViewController Methods

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

#pragma mark - IBAction Methods

- (IBAction)doneButtonPressed:(id)sender
{
    NSString *note = self.textView.text;
    
    if ([self.delegate conformsToProtocol:@protocol(SFANotesViewControllerDelegate)] &&
        [self.delegate respondsToSelector:@selector(notesViewController:didAddNote:)])
    {
        [self.delegate notesViewController:self didAddNote:note];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
