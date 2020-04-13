//
//  main.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/11/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFASalutronFitnessAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        int x;
        
		@try {
			x = UIApplicationMain(argc, argv, nil, NSStringFromClass([SFASalutronFitnessAppDelegate class]));
		}
		@catch (NSException *exception) {
			NSLog(@"%@", exception);
		}
		return x;
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SFASalutronFitnessAppDelegate class]));
    }
}
