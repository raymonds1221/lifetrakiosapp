//
//  SFANotificationsViewController.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/23/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFANotificationsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end