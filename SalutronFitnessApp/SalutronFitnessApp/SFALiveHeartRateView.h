//
//  SFALiveHeartRateView.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/26/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFAGraphView.h"

@interface SFALiveHeartRateView : UIView

- (void)initializeObjects;
- (void)startHeartRateLiveStream;
- (void)endHeartRateLiveStream;

@end
