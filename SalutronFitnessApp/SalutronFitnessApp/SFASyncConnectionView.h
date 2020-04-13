//
//  SFASyncConnectionView.h
//  SalutronFitnessApp
//
//  Created by Dana Elisa Nicolas on 12/9/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFASyncConnectionViewDelegate <NSObject>

- (void)cancelButtonDidClicked:(id)sender;
- (void)tryAgainButtonDidClicked:(id)sender;

@end

@interface SFASyncConnectionView : UIView

@property (assign, nonatomic) id<SFASyncConnectionViewDelegate> delegate;

- (void)cancelButtonClicked:(id)sender;
- (void)tryAgainButtonClicked:(id)sender;
- (void)beginAnimating;
- (void)stopAnimating;
- (void)showFail;
- (void)setLabelValue:(NSString *)value;

@end
