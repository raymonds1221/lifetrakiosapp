//
//  SFAWatchDetailsTableViewCell.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/4/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAWatchDetailsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *watchImage;
@property (weak, nonatomic) IBOutlet UILabel *watchModel;
@property (weak, nonatomic) IBOutlet UIImageView *featureImage1;
@property (weak, nonatomic) IBOutlet UILabel *featureLabel1;
@property (weak, nonatomic) IBOutlet UIImageView *featureImage2;
@property (weak, nonatomic) IBOutlet UILabel *featureLabel2;
@property (weak, nonatomic) IBOutlet UIImageView *featureImage3;
@property (weak, nonatomic) IBOutlet UILabel *featureLabel3;
@property (weak, nonatomic) IBOutlet UIImageView *featureImage4;
@property (weak, nonatomic) IBOutlet UILabel *featureLabel4;
@property (weak, nonatomic) IBOutlet UIImageView *featureImage5;
@property (weak, nonatomic) IBOutlet UILabel *featureLabel5;
@property (weak, nonatomic) IBOutlet UIImageView *featureImage6;
@property (weak, nonatomic) IBOutlet UILabel *featureLabel6;
@property (weak, nonatomic) IBOutlet UIImageView *featureImage7;
@property (weak, nonatomic) IBOutlet UILabel *featureLabel7;

@property (strong, nonatomic) NSObject *deviceID;

- (void)configureCellWithDeviceID:(NSObject *)deviceID;

@end
