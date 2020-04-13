//
//  SFAFAQViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/24/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAFAQViewController.h"
#import "UIViewController+Helper.h"

@interface SFAFAQViewController () <UIWebViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) BOOL loadingStopped;

@end

@implementation SFAFAQViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = newBackButton;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *urlAddress = @"https://lifetrakusa.com/support/frequently-asked-questions/";//@"http://lifetrakusa.com/faq/";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_4 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B350 Safari/8536.25", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    [self.webView loadRequest:request];
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    self.loadingStopped = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.loadingStopped = YES;
    /*
    if ([self.webView isLoading]) {
        [self.webView stopLoading];
    }
     */
}

#pragma mark - UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (!self.loadingStopped) {
    if (self.isIOS8AndAbove) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                 message:[error localizedDescription]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:BUTTON_TITLE_OK
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:BUTTON_TITLE_OK, nil];
        [alertView show];
    }
    }
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)back:(UIBarButtonItem *)sender{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
    else{
        [self.activityIndicatorView startAnimating];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
