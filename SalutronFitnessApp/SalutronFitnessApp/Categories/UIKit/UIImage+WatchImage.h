//
//  UIImage+WatchImage.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WatchImage)

+ (UIImage *)watchImageForMacAddress:(NSString *)macAddress;
+ (void)saveImage:(UIImage *)image withMacAddress:(NSString *)macAddress;

@end
