//
//  UIViewController+Helper.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 10/9/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (Helper)

- (BOOL) isIOS8AndAbove;
- (BOOL) isIOS9AndAbove;
- (BOOL) isLowBattery;
- (BOOL) isLowStorage;
//- (uint64_t) getFreeDiskspace;
//- (long long) getFreeDiskspace;
@end