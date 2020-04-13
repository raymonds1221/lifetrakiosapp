//
//  SFAWatchSettingsWatchCell.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/16/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Comparison.h"
#import "TimeDate+Data.h"
#import "UIImage+WatchImage.h"
#import "DeviceEntity.h"
#import "DeviceEntity+Data.h"

#import "SFAWatchSettingsWatchCell.h"

@implementation SFAWatchSettingsWatchCell

#pragma mark - Private Methods

- (NSString *)watchModelStringWithWatchModel:(WatchModel)model
{
   if (model == WatchModel_Move_C300 || model == WatchModel_Move_C300_Android)
    {
        return WATCHNAME_MOVE_C300;
    }
    else if (model == WatchModel_Zone_C410)
    {
        return WATCHNAME_ZONE_C410;
    }
    else if (model == WatchModel_R420)
    {
        return WATCHNAME_R420;
    }
    else if (model == WatchModel_R450)
    {
        return WATCHNAME_BRITE_R450;
    }
    else if (model == WatchModel_R500)
    {
        return WATCHNAME_R500;
    }
    
    return nil;
}

- (UIImage *)watchImageWithWatchModel:(WatchModel)model
{
    UIImage *image = [UIImage watchImageForMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
    
    if (image) {
        return image;
    }
    
    if (model == WatchModel_Move_C300 || model == WatchModel_Move_C300_Android)
    {
        return [UIImage imageNamed:WATCHIMAGE_C300];
    }
    else if (model == WatchModel_Zone_C410)
    {
        return [UIImage imageNamed:WATCHIMAGE_C410];
    }
    else if (model == WatchModel_R420)
    {
        return [UIImage imageNamed:WATCHIMAGE_R420];
    }
    else if (model == WatchModel_R450)
    {
        return [UIImage imageNamed:WATCHIMAGE_R450];
    }
    else if (model == WatchModel_R500)
    {
        return [UIImage imageNamed:WATCHIMAGE_R500];
    }
    
    return nil;
}

- (NSString *)lastSyncDate
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSData *data                    = [userDefaults objectForKey:LAST_SYNC_DATE];
    
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
        self.watchLastSync.text = @"";
    }

    return nil;
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

- (void)setContentsWithWatchModel:(WatchModel)model
{
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
    self.watchModel.text    = [self watchModelStringWithWatchModel:model];
    self.watchLastSync.text = [self lastSyncDateWithDeviceEntity:deviceEntity];//self.lastSyncDate;
    //[self.watchImage.imageView setContentMode:UIViewContentModeScaleAspectFill];
    //self.watchImage.image = [self watchImageWithWatchModel:model];
    
}

@end
