//
//  SFASessionExpiredErrorAlertView.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 8/11/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFASessionExpiredErrorAlertViewDelegate;

@interface SFASessionExpiredErrorAlertView : UIAlertView

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate;

@end

@protocol SFASessionExpiredErrorAlertViewDelegate <NSObject>

@optional
- (void)sessionExpiredAlertViewCancelButtonClicked:(SFASessionExpiredErrorAlertView *)errorAlertView;
- (void)sessionExpiredAlertViewContinueButtonClicked:(SFASessionExpiredErrorAlertView *)errorAlertView;

@end