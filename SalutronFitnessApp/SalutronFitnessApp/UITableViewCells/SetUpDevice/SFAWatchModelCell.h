//
//  SFAWatchModelCell.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/22/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFAWatchModelCellDelegate <NSObject>

@required
- (void) didClickOnConnectWithWatchModel:(WatchModel) watchModel;

@end

@interface SFAWatchModelCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *watchImage;
@property (weak, nonatomic) IBOutlet UILabel *watchModelName;
@property (weak, nonatomic) IBOutlet UIButton *connectToDevice;
@property (assign, nonatomic) WatchModel watchModel;
@property (weak, nonatomic) id<SFAWatchModelCellDelegate> delegate;

- (void) displayInfo;

@end
