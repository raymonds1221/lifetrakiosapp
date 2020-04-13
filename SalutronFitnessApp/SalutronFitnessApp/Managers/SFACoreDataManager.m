//
//  SFACoreDataManager.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/7/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFACoreDataManager.h"

@implementation SFACoreDataManager

#pragma mark - Singleton Instance

+ (SFACoreDataManager *)sharedManager
{
    static SFACoreDataManager *instance = nil;
    
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

@end
