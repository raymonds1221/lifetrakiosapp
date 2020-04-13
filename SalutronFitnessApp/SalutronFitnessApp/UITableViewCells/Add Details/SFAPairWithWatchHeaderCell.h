//
//  SFAPairWithWatchHeaderCell.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/10/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SFAPairWithWatchHeaderCellDelegate;

@interface SFAPairWithWatchHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *headerButton;
@property (strong, nonatomic) id<SFAPairWithWatchHeaderCellDelegate> delegate;
- (IBAction)headerButtonClicked:(id)sender;

@end

@protocol SFAPairWithWatchHeaderCellDelegate <NSObject>

- (void)headerCellButtonClicked;

@end
