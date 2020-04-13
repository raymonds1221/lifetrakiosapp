//
//  SFAAppDelegate.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/11/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SalutronSDK.h"

#define DATABASE_NAME @"/salutronfitnessapp.sqlite"

static NSString * const autoSyncNotificationName = @"AutoSyncNotification";

@interface SFASalutronFitnessAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) SalutronSDK *salutronSDK;

- (void)resetCoreData;

@end
