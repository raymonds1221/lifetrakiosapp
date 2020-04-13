//
//  SFASleepLogDataViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/13/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SleepDatabaseEntity;

typedef enum {
    SFASleepLogDataModeAdd,
    SFASleepLogDataModeEdit
} SFASleepLogDataMode;

@protocol  SFASleepLogDataViewControllerDelegate;

@interface SFASleepLogDataViewController : UIViewController

@property (readwrite, nonatomic) SFASleepLogDataMode mode;
@property (strong, nonatomic) SleepDatabaseEntity *sleepDatabaseEntity;
@property (weak, nonatomic) id <SFASleepLogDataViewControllerDelegate> delegate;

@end

@protocol SFASleepLogDataViewControllerDelegate <NSObject>

@optional
- (void)sleepLogDataViewController:(SFASleepLogDataViewController *)viewController didAddSleepDatabaseEntity:(SleepDatabaseEntity *)sleepDatabaseEntity;
- (void)sleepLogDataViewController:(SFASleepLogDataViewController *)viewController didUpdateSleepDatabaseEntity:(SleepDatabaseEntity *)sleepDatabaseEntity;

- (void)didDeleteInSleepLogDataViewController:(SFASleepLogDataViewController *)viewController;

@end