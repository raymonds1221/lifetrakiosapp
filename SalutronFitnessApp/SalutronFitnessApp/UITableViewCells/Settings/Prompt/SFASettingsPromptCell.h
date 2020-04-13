//
//  SFASettingsPromptCell.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/1/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFASettingsPromptCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

@property (weak, nonatomic) IBOutlet UILabel  *labelYes;
@property (weak, nonatomic) IBOutlet UILabel  *labelNo;

- (void)setContents;

- (IBAction)yesButtonPressed:(id)sender;
- (IBAction)noButtonPressed:(id)sender;

@end
