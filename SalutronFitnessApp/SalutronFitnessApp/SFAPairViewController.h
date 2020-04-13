//
//  SFAPairViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/15/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFAPairViewControllerDelegate;

@interface SFAPairViewController : UIViewController

@property (nonatomic) BOOL showCancelSyncButton;
@property (assign, nonatomic, getter=isPaired) BOOL paired;

@property (readwrite, nonatomic) WatchModel                     watchModel;
@property (weak, nonatomic) id <SFAPairViewControllerDelegate>  delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labelWatchName;
@property (assign, nonatomic) BOOL startedFromConnectionView;

- (IBAction)continueButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end

@protocol SFAPairViewControllerDelegate <NSObject>

- (void)didPressContinueInPairViewController:(SFAPairViewController *)viewController;
- (void)didPressCancelInPairViewController:(SFAPairViewController *)viewController;

@end