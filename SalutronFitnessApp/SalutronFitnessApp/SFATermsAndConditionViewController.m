//
//  SFATermsAndConditionViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 10/2/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFATermsAndConditionViewController.h"

@interface SFATermsAndConditionViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *grayActivityIndicator;

@end

@implementation SFATermsAndConditionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
	// Do any additional setup after loading the view.
    self.webView.delegate = self;
    self.title = LS_TERMS_AND_CONDITIONS_SMALL;
    
    //Remove this when there is a link for TaC in lifetrak website
    [self.grayActivityIndicator stopAnimating];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationItem.hidesBackButton = NO;
    //Uncomment this when there is a link for TaC in lifetrak website
    /*
    NSString *urlAddress = @"http://lifetrakusa.com/support/frequently-asked-questions/";//@"http://lifetrakusa.com/faq/";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
     */
    
    //Remove this when there is a link for TaC in lifetrak website
    
    NSString *filePathName = @"terms";
    if (LANGUAGE_IS_FRENCH) {
        filePathName = @"terms_french";
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                                          pathForResource:filePathName ofType:@"html"]isDirectory:NO]]];
}


//Uncomment this when there is a link for TaC in lifetrak website
/*
#pragma mark - UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.grayActivityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.grayActivityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:BUTTON_TITLE_OK, nil];
    [alertView show];
}
*/

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
