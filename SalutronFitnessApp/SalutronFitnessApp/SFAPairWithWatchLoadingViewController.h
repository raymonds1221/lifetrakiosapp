//
//  SFAPairWithWatchLoadingViewController.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/3/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAPairWithWatchLoadingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;

@property (nonatomic) int deviceIndex;
@property (nonatomic) NSString *deviceModelString;
@property (nonatomic) WatchModel watchModel;
@property (nonatomic) Status status;

- (IBAction)leftButtonClicked:(id)sender;
- (IBAction)rightButtonCicked:(id)sender;
@end
