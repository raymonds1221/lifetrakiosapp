//
//  SFASyncProgressView.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFASyncProgressViewDelegate;

@interface SFASyncProgressView : UIView

@property (strong, nonatomic) NSString *status;
@property (readwrite, nonatomic) BOOL isAnimating;
@property (readwrite, nonatomic) BOOL showButton;

@property (weak, nonatomic) id <SFASyncProgressViewDelegate> delegate;

+ (SFASyncProgressView *)progressView;

+ (void)show;
+ (void)showWithMessage:(NSString *)message;
+ (void)showWithMessage:(NSString *)message animate:(BOOL)animate;
+ (void)showWithMessage:(NSString *)message animate:(BOOL)animate showButton:(BOOL)showButton;
+ (void)showWithMessage:(NSString *)message animate:(BOOL)animate showButton:(BOOL)showButton dismiss:(BOOL)dismiss;

+ (void)showWithMessage:(NSString *)message animate:(BOOL)animate showButton:(BOOL)showButton onButtonClick:(void (^)(void))onClick;

+ (void)showWithMessage:(NSString *)message animate:(BOOL)animate showOKButton:(BOOL)showButton onButtonClick:(void (^)(void))onClick;


+ (void)hide;

@end

@protocol SFASyncProgressViewDelegate <NSObject>

- (void)didPressButtonOnProgressView:(SFASyncProgressView *)progressView;

@end