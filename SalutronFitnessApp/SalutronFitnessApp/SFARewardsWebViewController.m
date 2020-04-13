//
//  SFARewardsWebViewController.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 6/17/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFARewardsWebViewController.h"
#import "UIViewController+Helper.h"
#import "SVProgressHUD.h"


@interface SFARewardsWebViewController ()<UIWebViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *exitButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation SFARewardsWebViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationSuccess:) name:NOTIFICATION_WALGREENS_CONNECT_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationFailed:) name:NOTIFICATION_WALGREENS_CONNECT_FAILED object:nil];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_4 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B350 Safari/8536.25", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.webView loadRequest:request];
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_WALGREENS_CONNECT_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_WALGREENS_CONNECT_FAILED object:nil];
}

#pragma mark - ibactions
- (IBAction)exitWebView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - uiwebview delegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSString *msg = @"";
    if (webView.request.URL.absoluteString.length == 0
        || [webView.request.URL.absoluteString rangeOfString:@"walgreens"].location != NSNotFound){
        msg = LS_WALGREENS_CONNECT;
    }
    [SVProgressHUD showWithStatus:msg maskType:SVProgressHUDMaskTypeBlack];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD dismiss];
}

#pragma mark - uialertview methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Notification Center methods
- (void)registrationSuccess:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    if (self.isIOS8AndAbove) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Walgreens"
                                                                                 message:[NSString stringWithFormat:@"%@ Walgreens",NSLocalizedString(@"Successfully connected to", nil)]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:BUTTON_TITLE_OK_NORMAL
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self.navigationController popViewControllerAnimated:YES];
                                   }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"Walgreens" message:[NSString stringWithFormat:@"%@ Walgreens",NSLocalizedString(@"Successfully connected to", nil)] delegate:self cancelButtonTitle:BUTTON_TITLE_OK_NORMAL otherButtonTitles:nil] show];
    }
}

- (void)registrationFailed:(NSNotification *)notification
{
    [self.navigationController popViewControllerAnimated:YES];
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
