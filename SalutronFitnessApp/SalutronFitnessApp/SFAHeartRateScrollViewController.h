//
//  SFAHeartRateScrollViewController.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/4/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFAHeartRateViewController.h"

@interface SFAHeartRateScrollViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet UIView         *leftHeartRate;
@property (weak, nonatomic) IBOutlet UIView         *centerHeartRate;
@property (weak, nonatomic) IBOutlet UIView         *rightHeartRate;

@end
