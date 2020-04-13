//
//  SFAPreferenceCell.h
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/19/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    SFAPreferenceTypeDate       = 0,
    SFAPreferenceTypeTime       = 1,
    SFAPreferenceTypeUnit       = 2,
    SFAPreferenceFaceWatch      = 3,
    SFAPreferenceSleepMode      = 4
    
}SFAPreferenceType;

@protocol SFAPreferenceCellDelegate;

@interface SFAPreferenceCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel  *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel  *labelFirst;
@property (strong, nonatomic) IBOutlet UILabel  *labelSecond;
@property (strong, nonatomic) IBOutlet UIButton *buttonFirst;
@property (strong, nonatomic) IBOutlet UIButton *buttonSecond;
@property (weak, nonatomic) IBOutlet UIButton *dateFormatButton;
@property (readwrite, nonatomic) SFAPreferenceType preferenceType;

@property (nonatomic, weak) id <SFAPreferenceCellDelegate> delegate;

- (void)setContentWithPreferenceType:(SFAPreferenceType)preferenceType;

@end

@protocol SFAPreferenceCellDelegate <NSObject>

- (void)preferenceCell:(SFAPreferenceCell *)cell didChangeHourFormat:(HourFormat)hourFormat;
- (void)preferenceCell:(SFAPreferenceCell *)cell didChangeUnit:(Unit)unit;
- (void)preferenceCell:(SFAPreferenceCell *)cell didChangeDateFormat:(DateFormat)dateFormat;

@end
