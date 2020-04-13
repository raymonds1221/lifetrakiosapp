//
//  SFAProfileServerSyncCell.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/16/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Comparison.h"

#import "TimeDate+Data.h"
#import "DeviceEntity+Data.h"

#import "SFAProfileServerSyncCell.h"

@implementation SFAProfileServerSyncCell

#pragma mark - Private Methods

- (NSString *)lastSyncDateWithMacAddress:(NSString *)macAddress
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:macAddress]) {
        NSData *data                    = [userDefaults objectForKey:macAddress];
        
        if (data)
        {
            TimeDate *timeDate              = [TimeDate getData];
            NSDateFormatter *dateFormatter  = [NSDateFormatter new];
            NSDate *date                    = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            if (date.isToday)
            {
                dateFormatter.dateFormat    = timeDate.hourFormat == _12_HOUR ? @"hh:mm a" : @"HH:mm";
                
                NSString *finalTime = [NSString stringWithFormat:@"%@ %@", LS_SYNC_TODAY, [dateFormatter stringFromDate:date]];
                
                if (LANGUAGE_IS_FRENCH && timeDate.hourFormat == _24_HOUR) {
                    finalTime = [finalTime stringByReplacingOccurrencesOfString:@":" withString:@"h"];
                }
                
                finalTime = [[finalTime stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
                
                return finalTime;
            }
            else if (date.isYesterday)
            {
                dateFormatter.dateFormat    = timeDate.hourFormat == _12_HOUR ? @"hh:mm a" : @"HH:mm";
                
                NSString *finalTime = [NSString stringWithFormat:@"%@ %@", LS_SYNC_YESTERDAY, [dateFormatter stringFromDate:date]];
                
                if (LANGUAGE_IS_FRENCH && timeDate.hourFormat == _24_HOUR) {
                    finalTime = [finalTime stringByReplacingOccurrencesOfString:@":" withString:@"h"];
                }
                
                finalTime = [[finalTime stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
                
                return finalTime;
            }
            else {
                if (timeDate.hourFormat == _12_HOUR && timeDate.dateFormat == 0)
                {
                    dateFormatter.dateFormat = @"dd MMM yyyy, hh:mm a";
                }
                else if (timeDate.hourFormat == _12_HOUR && timeDate.dateFormat == 1)
                {
                    dateFormatter.dateFormat = @"MMM dd yyyy, hh:mm a";
                }
                else if (timeDate.hourFormat == _24_HOUR && timeDate.dateFormat == 0)
                {
                    dateFormatter.dateFormat = @"dd MMM yyyy, HH:mm";
                }
                else
                {
                    dateFormatter.dateFormat = @"MMM dd yyyy, HH:mm";
                }
                
                NSString *finalString = [NSString stringWithFormat:@"%@ %@", LS_SYNCED_AT,[dateFormatter stringFromDate:date]];
                if (LANGUAGE_IS_FRENCH && timeDate.hourFormat == _24_HOUR) {
                    finalString = [finalString stringByReplacingOccurrencesOfString:@":" withString:@"h"];
                }
                
                finalString = [[finalString stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
                
                return finalString;
            }
        }
        else
        {
            return MESSAGE_NOT_YET_SYNCED;
        }
    }
    else{
        return MESSAGE_NOT_YET_SYNCED;
    }
    return MESSAGE_NOT_YET_SYNCED;
}

- (NSString *)lastSyncDateWithDeviceEntity:(DeviceEntity *)device
{
    TimeDate *timeDate              = [TimeDate getData];
    NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    NSDate *date                    = device.lastDateSynced;
    
    if (date.isToday)
    {
        dateFormatter.dateFormat    = timeDate.hourFormat == _12_HOUR ? @"hh:mm a" : @"HH:mm";
        
        NSString *finalTime = [NSString stringWithFormat:@"%@ %@", LS_SYNC_TODAY, [dateFormatter stringFromDate:date]];
        
        if (LANGUAGE_IS_FRENCH && timeDate.hourFormat == _24_HOUR) {
            finalTime = [finalTime stringByReplacingOccurrencesOfString:@":" withString:@"h"];
        }
        
        finalTime = [[finalTime stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
        
        
        return finalTime;
    }
    else if (date.isYesterday)
    {
        dateFormatter.dateFormat    = timeDate.hourFormat == _12_HOUR ? @"hh:mm a" : @"HH:mm";
        
        NSString *finalTime = [NSString stringWithFormat:@"%@ %@", LS_SYNC_YESTERDAY, [dateFormatter stringFromDate:date]];
        
        if (LANGUAGE_IS_FRENCH && timeDate.hourFormat == _24_HOUR) {
            finalTime = [finalTime stringByReplacingOccurrencesOfString:@":" withString:@"h"];
        }
        
        finalTime = [[finalTime stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
        
        
        return finalTime;
    }
    else {
        if (timeDate.hourFormat == _12_HOUR && timeDate.dateFormat == 0)
        {
            dateFormatter.dateFormat = @"dd MMM yyyy, hh:mm a";
        }
        else if (timeDate.hourFormat == _12_HOUR && timeDate.dateFormat == 1)
        {
            dateFormatter.dateFormat = @"MMM dd yyyy, hh:mm a";
        }
        else if (timeDate.hourFormat == _24_HOUR && timeDate.dateFormat == 0)
        {
            dateFormatter.dateFormat = @"dd MMM yyyy, HH:mm";
        }
        else
        {
            dateFormatter.dateFormat = @"MMM dd yyyy, HH:mm";
        }
        
        NSString *finalString = [NSString stringWithFormat:@"%@ %@", LS_SYNCED_AT,[dateFormatter stringFromDate:date]];
        if (LANGUAGE_IS_FRENCH && timeDate.hourFormat == _24_HOUR) {
            finalString = [finalString stringByReplacingOccurrencesOfString:@":" withString:@"h"];
        }
        
        finalString = [[finalString stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM] stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
        
        return finalString;
    }
    
    return nil;
}


#pragma mark - Public Methods

- (void)setContentsWithMacAddress:(NSString *)macAddress
{
    self.serverLastSync.text = [self lastSyncDateWithMacAddress:macAddress];
}

- (void)setContentsWithDeviceEntity:(DeviceEntity *)device
{
    self.serverLastSync.text = [self lastSyncDateWithDeviceEntity:device];
}

@end
