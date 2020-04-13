//
//  SFAProfileGenderCell.h
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/10/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFAProfileGenderCellDelegate;

@interface SFAProfileGenderCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIButton *buttonMale;
@property (strong, nonatomic) IBOutlet UIButton *buttonFemale;
@property (weak, nonatomic) IBOutlet UILabel *maleLabel;
@property (weak, nonatomic) IBOutlet UILabel *femaleLabel;
@property id<SFAProfileGenderCellDelegate> delegate;
@property (strong, nonatomic) SalutronUserProfile *salutronUserProfile;

- (void)setGenderContent;

@end

@protocol SFAProfileGenderCellDelegate <NSObject>

- (void)genderValueChangedWithSalutronUserProfile:(SalutronUserProfile *)salutronUserProfile;

@end