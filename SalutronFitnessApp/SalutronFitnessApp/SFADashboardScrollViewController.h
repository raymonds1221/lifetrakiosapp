//
//  SFADashboardScrollViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/28/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFASalutronCModelSync.h"

typedef enum
{
    SFAOptionTypeReSync,
    SFAOptionTypeDelete
}SFAOptionType;

@interface SFADashboardScrollViewController : UIViewController  <UIScrollViewDelegate, UIActionSheetDelegate, SFASalutronSyncDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet UIView         *leftDashboardView;
@property (weak, nonatomic) IBOutlet UIView         *centerDashboardView;
@property (weak, nonatomic) IBOutlet UIView         *rightDashboardView;

- (IBAction)menuButtonPressed:(UIBarButtonItem *)sender;

@end
