//
//  SFASyncOptionCell.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 5/23/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFASyncOptionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *optionlabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *timeButtonArray;

- (void)showTimeButtonForSyncSetupOption:(SyncSetupOption)syncSetupOption;
- (void)hideAllTimeButtons:(BOOL)hide;
- (void)setAutoSyncTime;

@end
