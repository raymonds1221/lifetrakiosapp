//
//  SFASettingsIndentedCellWithButton.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 5/4/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFASettingsIndentedCellWithButtonDelegate <NSObject>

- (void)indentedCellButtonClicked:(UIButton *)sender withLabelTitle:(NSString *)title withCellTag:(int)cellTag;
- (void)indentedCellOnOffButtonClicked:(UIButton *)sender withLabelTitle:(NSString *)title withCellTag:(int)cellTag;

@end

@interface SFASettingsIndentedCellWithButton : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *cellButton;
@property (weak, nonatomic) IBOutlet UILabel *lableTitle;
@property (weak, nonatomic) IBOutlet UIButton *onOffButton;
@property (strong, nonatomic) id<SFASettingsIndentedCellWithButtonDelegate> delegate;

- (IBAction)buttonClicked:(id)sender;
- (IBAction)onOffButtonClicked:(id)sender;
- (void)setAutoSyncTimeWithTimeData:(TimeDate *)timeDate
                     autoSyncOption:(SyncSetupOption)syncSetupOption
                       autoSyncTime:(NSNumber *)autoSyncTime
                     andAutoSyncDay:(NSString *)autoSyncDay;
@end
