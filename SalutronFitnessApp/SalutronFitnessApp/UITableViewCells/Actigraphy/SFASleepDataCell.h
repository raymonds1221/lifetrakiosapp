//
//  SFASleepDataCell.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 1/13/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SleepDatabaseEntity;

@interface SFASleepDataCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sleepDuration;
@property (weak, nonatomic) IBOutlet UILabel *sleepTime;
@property (weak, nonatomic) IBOutlet UILabel *sleepCount;
@property (weak, nonatomic) IBOutlet UILabel *sleepDate;

- (void)setContentsWithSleepDatabaseEntity:(SleepDatabaseEntity *)sleepDatabaseEntity;

@end
