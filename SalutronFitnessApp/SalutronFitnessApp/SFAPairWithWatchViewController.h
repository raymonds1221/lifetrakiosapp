//
//  SFAPairWithWatchViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/3/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFAViewController.h"

@interface SFAPairWithWatchViewController : SFAViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (strong, nonatomic) NSArray *devices;

- (IBAction)leftButtonClicked:(id)sender;
- (IBAction)rightButtonCicked:(id)sender;
@end
