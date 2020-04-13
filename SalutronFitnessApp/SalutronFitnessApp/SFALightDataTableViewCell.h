//
//  SFALightDataTableViewCell.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 9/1/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFALightDataTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *wristDetection;
@property (weak, nonatomic) IBOutlet UILabel *threshold;

@property (weak, nonatomic) IBOutlet UILabel *redLabel;
@property (weak, nonatomic) IBOutlet UILabel *greenLabel;
@property (weak, nonatomic) IBOutlet UILabel *blueLabel;

@property (weak, nonatomic) IBOutlet UILabel *redCoeffLabel;
@property (weak, nonatomic) IBOutlet UILabel *greenCoeffLabel;
@property (weak, nonatomic) IBOutlet UILabel *blueCoeffLabel;

@property (weak, nonatomic) IBOutlet UILabel *redLuxLabel;
@property (weak, nonatomic) IBOutlet UILabel *greenLuxLabel;
@property (weak, nonatomic) IBOutlet UILabel *blueLuxLabel;
@property (weak, nonatomic) IBOutlet UILabel *allLuxLabel;

@property (weak, nonatomic) IBOutlet UIView *redView;
@property (weak, nonatomic) IBOutlet UIView *greenView;
@property (weak, nonatomic) IBOutlet UIView *blueView;
@property (weak, nonatomic) IBOutlet UIView *allView;

@end
