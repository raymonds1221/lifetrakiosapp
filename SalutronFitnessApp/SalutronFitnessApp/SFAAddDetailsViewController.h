//
//  SFAAddDetailsViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/3/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFASalutronCModelSync.h"
#import "SFASalutronRModelSync.h"
#import "SFAInputViewController.h"

@interface SFAAddDetailsViewController : SFAInputViewController <UITextFieldDelegate>
@property (strong, nonatomic) SFASalutronCModelSync     *salutronCModelSync;
@property (strong, nonatomic) SFASalutronRModelSync     *salutronRModelSync;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

- (IBAction)leftButtonClicked:(id)sender;
- (IBAction)rightButtonCicked:(id)sender;

@end
