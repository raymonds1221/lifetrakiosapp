//
//  SFAPulsewaveAnalysisViewController.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/20/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFAGraphView.h"

@interface SFAPulsewaveAnalysisViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelBPM;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnEnableDisable;
@property (weak, nonatomic) IBOutlet SFAGraphView *graphView;

- (IBAction) menuButtonPressed;
- (IBAction) enableDisablePulsewave;

@end
