//
//  SFANotificationsViewController+View.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 10/11/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFANotificationsViewController+View.h"
#import "Constants.h"

static NSString * const ESTABLISHING_VIEW_CONTENT   = @"establishingViewContent";
static NSString * const ESTABLISHING_VIEW_OVERLAY   = @"establishingViewOverlay";
static NSString * const TRY_AGAIN_VIEW_CONTENT      = @"tryAgainViewContent";
static NSString * const TRY_AGAIN_VIEW_OVERLAY      = @"tryAgainViewOverlay";
static NSString * const CHECKSUM_VIEW_CONTENT       = @"tryAgainViewContent";
static NSString * const CHECKSUM_VIEW_OVERLAY       = @"tryAgainViewOverlay";

@implementation SFANotificationsViewController (Utilities)

/***********************************************************************************/
/*****                              TRY AGAIN VIEW                             *****/
/***********************************************************************************/

- (void)showTryAgainViewWithTarget:(id)target cancelSelector:(SEL)cancelSelector tryAgainSelector:(SEL)tryAgainSelector
{
    DDLogInfo(@"");
    
    [self hideChecksumErrorView];
    [self hideTryAgainView];
    
    UIView *viewOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    viewOverlay.backgroundColor = [UIColor blackColor];
    viewOverlay.layer.opacity = 0.5;
    
    float contentWidth = self.view.bounds.size.width-60;
    float contentHeight = 242.0f;
    
    //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    //    contentHeight += 20.0f;
    //}
    
    //if ([SFAUserDefaultsManager sharedManager].watchModel == WatchModel_R450) {
    contentHeight += 8.0f;
    //}
    
    CGRect contentFrame = CGRectMake((viewOverlay.bounds.size.width / 2) - (contentWidth /  2),
                                     (viewOverlay.bounds.size.height / 2) - (contentHeight / 2),
                                     contentWidth, contentHeight);
    
    UIView *viewContent = [[UIView alloc] init];
    viewContent.frame = contentFrame;
    viewContent.backgroundColor = [UIColor whiteColor];
    viewContent.layer.cornerRadius = 10;
    viewContent.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewContent.layer.shadowRadius = 5.0f;
    viewContent.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    viewContent.layer.shadowOpacity = 1.0f;
    
    UILabel *label = [[UILabel alloc] init];
    label.tag = 7;
    label.text = SETUP_ALERT_TITLE;
    label.font = [label.font fontWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    //    [label sizeToFit];
    CGRect labelFrame = CGRectMake(0, 0, 150, 50);
    label.frame = labelFrame;
    label.center = CGPointMake(viewContent.frame.size.width/2, 50);
    
    UILabel *reminderLabel = [[UILabel alloc] init];
    
    reminderLabel.text = SETUP_ALERT_MESSAGE;
    
    if ([SFAUserDefaultsManager sharedManager].watchModel == WatchModel_R450) {
        reminderLabel.text = [reminderLabel.text stringByAppendingString:LS_BLUETOOTH_SETTINGS_MESSAGE];
    }
    
    reminderLabel.textAlignment = NSTextAlignmentCenter;
    //reminderLabel.backgroundColor = [UIColor lightGrayColor];
    reminderLabel.font = [reminderLabel.font fontWithSize:12];
    reminderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    reminderLabel.adjustsFontSizeToFitWidth = YES;
    reminderLabel.numberOfLines = 0;
    reminderLabel.minimumScaleFactor = 0.5;
    
    /*
     if ([SFAUserDefaultsManager sharedManager].watchModel != WatchModel_R450) {
     reminderLabel.font = [reminderLabel.font fontWithSize:10];
     }
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
     reminderLabel.font = [reminderLabel.font fontWithSize:12];
     }
     if ([SFAUserDefaultsManager sharedManager].watchModel == WatchModel_R450) {
     reminderLabel.numberOfLines = 7;
     }
     */
    
    UIImageView *syncImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_connect_4failed.png"]];
    syncImage.frame = CGRectMake((viewContent.bounds.size.width / 2) - (syncImage.bounds.size.width / 2), label.frame.origin.y + label.frame.size.height + 10, syncImage.bounds.size.width, syncImage.bounds.size.height);
    
    /*
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
     if ([SFAUserDefaultsManager sharedManager].watchModel == WatchModel_R450) {
     reminderLabel.frame = CGRectMake(0, 0, viewContent.bounds.size.width-60, 96);
     }
     else {
     reminderLabel.frame = CGRectMake(0, 0, viewContent.bounds.size.width-60, 80);
     }
     }
     else{*/
    //if ([SFAUserDefaultsManager sharedManager].watchModel == WatchModel_R450) {
    reminderLabel.frame = CGRectMake(0, 0, viewContent.bounds.size.width-60, 85);
    reminderLabel.center = CGPointMake(viewContent.bounds.size.width/2, syncImage.frame.origin.y + syncImage.frame.size.height + 42);
    //}
    //else {
    //    reminderLabel.frame = CGRectMake(0, 0, viewContent.bounds.size.width-60, 65);
    //    reminderLabel.center = CGPointMake(viewContent.bounds.size.width/2, syncImage.frame.origin.y + syncImage.frame.size.height + 35);
    //}
    // }
    
    
    UIView *border1 = [[UIView alloc] initWithFrame:CGRectMake(0, reminderLabel.frame.origin.y+reminderLabel.frame.size.height, viewContent.frame.size.width, 1)];
    border1.backgroundColor = [UIColor lightGrayColor];
    
    UIView *border2 = [[UIView alloc] initWithFrame:CGRectMake(viewContent.frame.size.width/2, reminderLabel.frame.origin.y+reminderLabel.frame.size.height+1, 1, 40)];
    border2.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    //cancel.backgroundColor = [UIColor yellowColor];
    //if ([SFAUserDefaultsManager sharedManager].watchModel == WatchModel_R450) {
    cancel.frame = CGRectMake(10, reminderLabel.frame.origin.y+reminderLabel.frame.size.height, (viewContent.frame.size.width/2)-10, 35);
    //}
    //else{
    //    cancel.frame = CGRectMake(10, reminderLabel.frame.origin.y+reminderLabel.frame.size.height+5, (viewContent.frame.size.width/2)-10, 50);
    //}
    [cancel.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [cancel setTitleColor:[UIColor colorWithRed:34.0/255.0 green:97.0/255.0 blue:221.0/255.0 alpha:1] forState:UIControlStateNormal];
    [cancel setTitle:BUTTON_TITLE_CANCEL forState:UIControlStateNormal];
    [cancel addTarget:target action:cancelSelector forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *tryAgain = [UIButton buttonWithType:UIButtonTypeSystem];
    tryAgain.frame = CGRectMake(cancel.frame.origin.x+cancel.frame.size.width+5, cancel.frame.origin.y, cancel.frame.size.width, cancel.frame.size.height);
    [tryAgain.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    [tryAgain setTitleColor:[UIColor colorWithRed:34.0/255.0 green:97.0/255.0 blue:221.0/255.0 alpha:1] forState:UIControlStateNormal];
    [tryAgain setTitle:LS_TRY_AGAIN forState:UIControlStateNormal];
    [tryAgain addTarget:target action:tryAgainSelector forControlEvents:UIControlEventTouchUpInside];
    
    viewContent.layer.opacity = 1.0;
    [viewContent addSubview:label];
    [viewContent addSubview:syncImage];
    [viewContent addSubview:reminderLabel];
    [viewContent addSubview:border1];
    [viewContent addSubview:border2];
    [viewContent addSubview:cancel];
    [viewContent addSubview:tryAgain];
    
    viewOverlay.accessibilityValue = TRY_AGAIN_VIEW_OVERLAY;
    viewContent.accessibilityValue = TRY_AGAIN_VIEW_CONTENT;
    
    [self.view addSubview:viewOverlay];
    [self.view bringSubviewToFront:viewOverlay];
    [self.view insertSubview:viewContent aboveSubview:viewOverlay];
}


- (void)hideTryAgainView
{
    for (UIView *subview in self.view.subviews) {
        if ([subview.accessibilityValue isEqualToString:TRY_AGAIN_VIEW_CONTENT] || [subview.accessibilityValue isEqualToString:TRY_AGAIN_VIEW_OVERLAY]) {
            [subview removeFromSuperview];
        }
    }
}

/***********************************************************************************/
/*****                              CHECKSUM VIEW                              *****/
/***********************************************************************************/

- (void)showChecksumFailViewWithTarget:(id)target cancelSelector:(SEL)cancelSelector tryAgainSelector:(SEL)tryAgainSelector
{
    DDLogInfo(@"");
    
    [self hideChecksumErrorView];
    [self hideTryAgainView];
    
    UIView *viewOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    viewOverlay.tag = 5;
    viewOverlay.backgroundColor = [UIColor blackColor];
    viewOverlay.layer.opacity = 0.5;
    
    float contentWidth = self.view.bounds.size.width-60;
    float contentHeight = 260.0f;
    CGRect contentFrame = CGRectMake((viewOverlay.bounds.size.width / 2) - (contentWidth /  2),
                                     (viewOverlay.bounds.size.height / 2) - (contentHeight / 2),
                                     contentWidth, contentHeight);
    
    UIView *viewContent = [[UIView alloc] init];
    viewContent.frame = contentFrame;
    viewContent.backgroundColor = [UIColor whiteColor];
    viewContent.layer.cornerRadius = 10;
    viewContent.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewContent.layer.shadowRadius = 5.0f;
    viewContent.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    viewContent.layer.shadowOpacity = 1.0f;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = SETUP_ALERT_SYNC_TITLE2;
    label.font = [label.font fontWithSize:11];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 5;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.frame =  CGRectMake(0, 0, 150, 50);
    label.center = CGPointMake(viewContent.frame.size.width/2, 50);
    
    UILabel *reminderLabel = [[UILabel alloc] init];
    reminderLabel.text = SETUP_ALERT_SYNC_FAILED_MESSAGE2;
    reminderLabel.font = [reminderLabel.font fontWithSize:12];
    reminderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    reminderLabel.numberOfLines = 2;
    reminderLabel.textAlignment = NSTextAlignmentCenter;
    
    UIImageView *syncImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_connect_4failed.png"]];
    syncImage.frame = CGRectMake((viewContent.bounds.size.width / 2) - (syncImage.bounds.size.width / 2), label.frame.origin.y + label.frame.size.height + 10, syncImage.bounds.size.width, syncImage.bounds.size.height);
    
    reminderLabel.frame = CGRectMake(0, 0, viewContent.bounds.size.width-60, 40);
    reminderLabel.center = CGPointMake(viewContent.bounds.size.width/2, syncImage.frame.origin.y + syncImage.frame.size.height + 36);
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_0_xcancel.png"] forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(viewContent.frame.size.width-40, 10, 30, 30);
    [closeButton addTarget:target action:cancelSelector forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *tryAgain = [UIButton buttonWithType:UIButtonTypeCustom];
    [tryAgain setTitle:LS_TRY_AGAIN forState:UIControlStateNormal];
    [tryAgain setBackgroundImage:[UIImage imageNamed:@"LogInButtonInactive"] forState:UIControlStateNormal];
    tryAgain.frame = CGRectMake(15, reminderLabel.frame.origin.y + reminderLabel.frame.size.height + 10, viewContent.frame.size.width-30, 40);
    [tryAgain addTarget:target action:tryAgainSelector forControlEvents:UIControlEventTouchUpInside];
    
    viewContent.layer.opacity = 1.0;
    [viewContent addSubview:label];
    [viewContent addSubview:syncImage];
    [viewContent addSubview:reminderLabel];
    [viewContent addSubview:closeButton];
    [viewContent addSubview:tryAgain];
    [viewContent bringSubviewToFront:closeButton];
    
    viewOverlay.accessibilityValue = CHECKSUM_VIEW_OVERLAY;
    viewContent.accessibilityValue = CHECKSUM_VIEW_OVERLAY;
    
    [self.view addSubview:viewOverlay];
    [self.view bringSubviewToFront:viewOverlay];
    [self.view insertSubview:viewContent aboveSubview:viewOverlay];
}

- (void)hideChecksumErrorView
{
    for (UIView *subview in self.view.subviews) {
        if ([subview.accessibilityValue isEqualToString:CHECKSUM_VIEW_OVERLAY] || [subview.accessibilityValue isEqualToString:CHECKSUM_VIEW_OVERLAY]) {
            [subview removeFromSuperview];
        }
    }
}

/***********************************************************************************/
/*****                       ESTABLISHING CONNECTION VIEW                      *****/
/***********************************************************************************/

- (void)showEstablishingConnectionview
{
    DDLogInfo(@"");
    
    [self hideEstablishingConnectionView];
    
    UIView *viewOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    UIView *viewContent = [[UIView alloc] init];
    
    CGFloat contentWidth = self.view.bounds.size.width - 60;
    CGFloat contentHeight = 150.0f;
    
    CGRect frame = CGRectMake((self.view.bounds.size.width / 2) - (contentWidth / 2),
                              (self.view.bounds.size.height / 2) - (contentHeight / 2),
                              contentWidth, contentHeight);
    viewOverlay.backgroundColor = [UIColor blackColor];
    viewOverlay.layer.opacity = 0.5f;
    
    viewContent.frame = frame;
    viewContent.backgroundColor = [UIColor whiteColor];
    viewContent.layer.cornerRadius = 10.0f;
    viewContent.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    viewContent.layer.shadowRadius = 5.0f;
    viewContent.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    viewContent.layer.shadowOpacity = 1.0f;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((viewContent.bounds.size.width / 2) - (143.0f / 2.0f), 40, 143, 40)];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.animationImages = [self establishingConnectionImageArray];
    imageView.animationDuration = 1.5f;
    
    [imageView startAnimating];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((viewContent.bounds.size.width / 2) - 100, imageView.bounds.origin.y + imageView.bounds.size.height + 30, 200, 60)];
    label.text = LS_CONNECTION_ESTABLISH;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
    
    [viewContent addSubview:imageView];
    [viewContent addSubview:label];
    
    viewOverlay.accessibilityValue = ESTABLISHING_VIEW_OVERLAY;
    viewContent.accessibilityValue = ESTABLISHING_VIEW_CONTENT;
    
    [self.view addSubview:viewOverlay];
    [self.view addSubview:viewContent];
}

- (void)hideEstablishingConnectionView
{
    for (UIView *subview in self.view.subviews) {
        if ([subview.accessibilityValue isEqualToString:ESTABLISHING_VIEW_CONTENT] || [subview.accessibilityValue isEqualToString:ESTABLISHING_VIEW_OVERLAY]) {
            [subview removeFromSuperview];
        }
    }
}

- (NSArray *)establishingConnectionImageArray
{
    return [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"ll_preloader_default.png"],
            [UIImage imageNamed:@"ll_preloader_radar_01.png"],
            [UIImage imageNamed:@"ll_preloader_radar_02.png"],
            [UIImage imageNamed:@"ll_preloader_radar_03.png"],
            [UIImage imageNamed:@"ll_preloader_radar_04.png"],
            [UIImage imageNamed:@"ll_preloader_radar_05.png"],
            [UIImage imageNamed:@"ll_preloader_radar_06.png"],
            [UIImage imageNamed:@"ll_preloader_radar_07.png"],
            [UIImage imageNamed:@"ll_preloader_radar_08.png"],
            [UIImage imageNamed:@"ll_preloader_radar_09.png"],
            [UIImage imageNamed:@"ll_preloader_radar_10.png"],
            [UIImage imageNamed:@"ll_preloader_radar_11.png"], nil];
}

@end

