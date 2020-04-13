//
//  SFASettingsIndentedCellWithButton.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 5/4/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFASettingsIndentedCellWithButton.h"


#define HOUR_FORMAT_12                       0
#define HOUR_FORMAT_24                       1

@implementation SFASettingsIndentedCellWithButton

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonClicked:(id)sender {
    [self.delegate indentedCellButtonClicked:sender withLabelTitle:self.lableTitle.text withCellTag:self.tag];
}

- (IBAction)onOffButtonClicked:(id)sender {
    [self.delegate indentedCellOnOffButtonClicked:sender withLabelTitle:self.lableTitle.text withCellTag:self.tag];
}

- (void)setAutoSyncTimeWithTimeData:(TimeDate *)timeDate
                     autoSyncOption:(SyncSetupOption)syncSetupOption
                       autoSyncTime:(NSNumber *)autoSyncTime
                     andAutoSyncDay:(NSString *)autoSyncDay
{
        switch (syncSetupOption) {
            case SyncSetupOptionOnce: {
                
                //TimeDate *timeDate = [TimeDate getData];
                autoSyncDay = nil;
                NSString *defaultTimeString = timeDate.hourFormat == _12_HOUR ? [NSString stringWithFormat:@"9:00 %@", LS_AM] : [NSString stringWithFormat:@"09%@00", LANGUAGE_IS_FRENCH ? @"h" : @":"];
                NSString *title = [self convertTimestampToString:autoSyncTime withTimeDate:timeDate andAutoSyncDay:autoSyncDay];
                if (title) {
                    [self.cellButton setTitle:title forState:UIControlStateNormal];
                }
                else{
                    [self.cellButton setTitle:defaultTimeString  forState:UIControlStateNormal];
                }
                
                break;
            }
            case SyncSetupOptionOnceAWeek:{
                NSString *defaultTimeString = timeDate.hourFormat == _12_HOUR ? [NSString stringWithFormat:@"%@, 9:00 %@", autoSyncDay, LS_AM] : [NSString stringWithFormat:@"09%@00", LANGUAGE_IS_FRENCH ? @"h" : @":"];
                
                NSString *title = [self convertTimestampToString:autoSyncTime withTimeDate:timeDate andAutoSyncDay:autoSyncDay];
                [self.cellButton setTitle: title ? title : defaultTimeString  forState:UIControlStateNormal];
                break;
            }
            default:
                break;
        }
}


- (NSString *)convertTimestampToString:(NSNumber *)timestamp withTimeDate:(TimeDate *)timeDate andAutoSyncDay:(NSString *)autoSyncDay
{
    NSTimeInterval interval = [timestamp doubleValue];
    NSDate *date = [NSDate date];
    date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //TimeDate *timeDate = [TimeDate getData];
    
    if (timeDate.hourFormat == HOUR_FORMAT_12) {
        [dateFormatter setDateFormat:@"hh:mm a"];
    } else {
        [dateFormatter setDateFormat:@"HH:mm"];
    }
    
    if (!timestamp) {
        return nil;
    }
    else if ([dateFormatter stringFromDate:date]) {
        
        NSString *finalDateString = [dateFormatter stringFromDate:date];
        
        if (timeDate.hourFormat == HOUR_FORMAT_24 && LANGUAGE_IS_FRENCH) {
            finalDateString = [finalDateString stringByReplacingOccurrencesOfString:@":" withString:@"h"];
        }
        
        NSString *timeString;
        if(timeDate.hourFormat == _12_HOUR){
            NSString *time = [[finalDateString componentsSeparatedByString:@" "] objectAtIndex:0];
            [dateFormatter setDateFormat:@"HH:mm"];
            NSString *time24hrs = [dateFormatter stringFromDate:date];
            NSString *hour = [[time24hrs componentsSeparatedByString:@":"] objectAtIndex:0];
            if(hour.intValue > 11){
                timeString = [NSString stringWithFormat:@"%@ %@", time, LS_PM];
            }
            else{
                timeString = [NSString stringWithFormat:@"%@ %@", time, LS_AM];
            }
            finalDateString = timeString;
        }

        
        if (timeDate.hourFormat == _24_HOUR && LANGUAGE_IS_FRENCH) {
            finalDateString = [finalDateString stringByReplacingOccurrencesOfString:@":" withString:@"h"];
        }
        
        finalDateString = [[finalDateString stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
        
        if (autoSyncDay) {
            finalDateString = [NSString stringWithFormat:@"%@, %@", autoSyncDay, finalDateString];
        }
        return finalDateString;
    }
    return nil;
}

@end
