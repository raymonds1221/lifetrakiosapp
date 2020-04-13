//
//  SFAProfileCell.h
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/10/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SalutronUserProfile.h"
#import "SFAYourProfileViewController.h"

@protocol SFAProfileCellDelegate;

@interface SFAProfileCell : UITableViewCell

@property (strong ,nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) SalutronUserProfile *salutronUserProfile;
@property (weak, nonatomic) IBOutlet UIView *cellSeparator;
@property (strong, nonatomic) id<SFAProfileCellDelegate> delegate;

- (void)setContentsWithProfileType:(ProfileType)profileType;

@end


@protocol SFAProfileCellDelegate <NSObject>

- (void)profileDataChangedWithSalutronUserProfile:(SalutronUserProfile *)salutronUserProfile;

@end
