//
//  SFAMenuViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/14/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lastSync;
@property (weak, nonatomic) IBOutlet UILabel *buildVersion;

@end
