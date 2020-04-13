//
//  SFACompatibleAppsCell.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 1/30/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ARGUS,
    MAP_MY_FITNESS
} SFACompatibleApp;

@interface SFACompatibleAppsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView    *compatibleAppsImage;
@property (weak, nonatomic) IBOutlet UILabel        *compatibleAppsLabel;

@property (assign, nonatomic) SFACompatibleApp      compatibleApp;

@end
