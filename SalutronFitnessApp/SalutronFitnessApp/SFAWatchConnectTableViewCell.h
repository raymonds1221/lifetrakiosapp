//
//  SFAWatchConnectTableViewCell.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/4/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFAWatchConnectTableViewCellDelegate <NSObject>

- (void)watchButtonClickedWithWatchName:(NSString *)watchName andCellTag:(int)tag;

@end

@interface SFAWatchConnectTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *watchImage;
@property (weak, nonatomic) IBOutlet UILabel *watchModel;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) id<SFAWatchConnectTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *watchNameLabel;
- (IBAction)watchButtonClicked:(id)sender;

@end
