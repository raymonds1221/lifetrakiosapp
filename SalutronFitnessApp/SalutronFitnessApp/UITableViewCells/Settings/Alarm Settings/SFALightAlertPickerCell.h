//
//  SFALightAlertPickerCell.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 9/1/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFAStringLightAlertPickerCellDelegate;

typedef enum : NSUInteger {
    SFALightPickerCellTypeTime,
    SFALightPickerCellTypeString,
    SFALightPickerCellTypeDuration
} SFALightPickerCellType;

static NSString *const pickerCellIdentifier = @"lightAlertPickerCell";

@interface SFALightAlertPickerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *pickerText;

@property (strong, nonatomic) NSString *pickerString;

//this property should be set last, used for initialization
@property (assign, nonatomic)SFALightPickerCellType cellType;

//if light picker cell is type time
@property (assign, nonatomic) NSInteger hour;
@property (assign, nonatomic) NSInteger minute;

//if light picker cell is type string
@property (strong, nonatomic) NSArray *stringValuesArray;
@property (strong, nonatomic) NSString *stringValue;

//if light picker cell is type duration
@property (assign, nonatomic) NSInteger maxMinutesDuration;
@property (assign, nonatomic) NSInteger minMinutesDuration;
@property (assign, nonatomic) NSInteger durationValue;

@property (weak, nonatomic) id<SFAStringLightAlertPickerCellDelegate> stringDelegate;

@end

@protocol SFAStringLightAlertPickerCellDelegate <NSObject>
- (void)lightAlertPickerCell:(SFALightAlertPickerCell *)cell stringValueChangedTo:(NSString *)valueChanged;

@end