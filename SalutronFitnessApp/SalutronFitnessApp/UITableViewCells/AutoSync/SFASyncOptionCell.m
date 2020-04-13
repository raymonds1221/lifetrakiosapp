//
//  SFASyncOptionCell.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 5/23/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASyncOptionCell.h"
#import "TimeDate+Data.h"

@implementation SFASyncOptionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)showTimeButtonForSyncSetupOption:(SyncSetupOption)syncSetupOption
{
    switch (syncSetupOption) {
        
        case SyncSetupOptionFourTimes:
            [self.timeButtonArray[3] setHidden:NO];
            [self.timeButtonArray[2] setHidden:NO];

        /*
        case SyncSetupOptionTwice:
            [self.timeButtonArray[1] setHidden:NO];
        */

        case SyncSetupOptionOnceAWeek:
            [self.timeButtonArray[1] setHidden:NO];
            
        case SyncSetupOptionOnce:
            [self.timeButtonArray[0] setHidden:NO];
            break;
            
        default:
            break;
    }
}

- (NSString *)convertTimestampToString:(NSNumber *)timestamp
{
    NSTimeInterval interval = [timestamp doubleValue];
    NSDate *date = [NSDate date];
    date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    TimeDate *timeDate = [TimeDate getData];
    
    if (timeDate.hourFormat == _12_HOUR) {
        [dateFormatter setDateFormat:@"hh:mm a"];
    } else {
        [dateFormatter setDateFormat:@"HH:mm"];
    }
    
    if (!timestamp) {
        return nil;
    }
    else if ([dateFormatter stringFromDate:date]) {
        
        NSString *finalDateString = [dateFormatter stringFromDate:date];
        
        if (LANGUAGE_IS_FRENCH && timeDate.hourFormat == _24_HOUR) {
            finalDateString = [finalDateString stringByReplacingOccurrencesOfString:@":" withString:@"h"];
        }
        
        finalDateString = [[finalDateString stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
        
        return finalDateString;
    }
    return nil;
}

- (void)setAutoSyncTime
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *autoSyncTimestamp1 = [userDefaults objectForKey:AUTO_SYNC_TIME_STAMP_1];

    NSString *selectedDay = LS_MONDAY;
    if ([userDefaults objectForKey:AUTO_SYNC_TIME_WEEKLY]) {
        selectedDay = [userDefaults objectForKey:AUTO_SYNC_TIME_WEEKLY];
    }
    
    for (UIButton *timeButton in self.timeButtonArray) {
        int timeButtonIndex = (int)[self.timeButtonArray indexOfObject:timeButton];
        timeButton.titleLabel.minimumScaleFactor = 0.3f;
        timeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        switch (timeButtonIndex) {
            case 0: {
                
                TimeDate *timeDate = [TimeDate getData];
                
                NSString *defaultTimeString = timeDate.hourFormat == _12_HOUR ? [NSString stringWithFormat:@"9:00 %@", LS_AM] : [NSString stringWithFormat:@"09%@00", LANGUAGE_IS_FRENCH ? @"h" : @":"];
                
                [timeButton setTitle:[self convertTimestampToString:autoSyncTimestamp1] ? [self convertTimestampToString:autoSyncTimestamp1] : defaultTimeString  forState:UIControlStateNormal];
                break;
            }
            case 1:
                [userDefaults setObject:selectedDay forKey:AUTO_SYNC_TIME_WEEKLY];
                [userDefaults synchronize];
                [timeButton setTitle:selectedDay forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
}

- (void)hideAllTimeButtons:(BOOL)hide
{
    for (UIButton *timeButton in self.timeButtonArray) {
        [timeButton setHidden:hide];
    }
}

/*
 for (UIButton *timeButton in self.timeButtonArray) {
 
 int timeButtonIndex = (int)[self.timeButtonArray indexOfObject:timeButton];
 }
 */
@end
