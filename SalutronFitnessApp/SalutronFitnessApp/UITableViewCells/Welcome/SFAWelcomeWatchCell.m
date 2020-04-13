
//
//  SFAWelcomeWatchCell.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/17/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Comparison.h"
#import "UIImage+WatchImage.h"
#import "TimeDate+Data.h"

#import "SFAWelcomeWatchCell.h"

#import "DeviceEntity.h"

@interface SFAWelcomeWatchCell ()

@property (strong, nonatomic) UIImage *backgroundImage;

@end

@implementation SFAWelcomeWatchCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundImage = self.watchBackgroundImage.image;
}

#pragma mark - Private Methods

- (NSString *)watchModelStringWithWatchModel:(WatchModel)model
{
    if (model == WatchModel_Move_C300 || model == WatchModel_Move_C300_Android)
    {
        return @"C300";
    }
    else if (model == WatchModel_Zone_C410)
    {
        return @"C410";
    }
    else if (model == WatchModel_R420)
    {
        return @"R420";
    }
    else if (model == WatchModel_R450)
    {
        return @"R450";
    }
    else if (model == WatchModel_R500)
    {
        return @"R500";
    }
    
    return nil;
}

- (UIImage *)watchImageWithWatchModel:(WatchModel)model
{
    
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

/*
 * Deprecated - December 11, 2014
- (NSString *)lastSyncDateWithDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    
    if (date.isToday)
    {
        dateFormatter.dateFormat = @"hh:mm a";
        return [NSString stringWithFormat:@"%@ %@", LS_SYNC_TODAY, [dateFormatter stringFromDate:date]];
    }
    else if (date.isYesterday)
    {
        dateFormatter.dateFormat = @"hh:mm a";
        return [NSString stringWithFormat:@"%@ %@", LS_SYNC_YESTERDAY, [dateFormatter stringFromDate:date]];
    }
    else {
        dateFormatter.dateFormat = @"MMMM dd yyyy, hh:mm a";
        return [NSString stringWithFormat:@"%@ %@", LS_SYNCED_AT, [dateFormatter stringFromDate:date]];
    }
    
    return nil;
}
*/

- (NSString *)lastSyncDateWithDate:(NSDate *)date withMACAddress:(NSString *)macAddress
{
    TimeDate *timeDate              = [TimeDate getDataWithMACAddress:macAddress];
    NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    
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

#define Public Methods

- (void)setContentsWithDevice:(DeviceEntity *)device
{
    UIImage *image = [UIImage watchImageForMacAddress:device.macAddress];
    
    if (image) {
        self.watchBackgroundImage.image = image;
        image = nil;
    } else {
        image = [self watchImageWithWatchModel:device.modelNumber.integerValue];
    }
    ////BROWNBAG ITEM - Debugging UIViews
    self.watchImage.image   = image;
    self.watchModel.text    = device.name;
    if (device.lastDateSynced)
        self.watchLastSync.text = [self lastSyncDateWithDate:device.lastDateSynced withMACAddress:device.macAddress];
    else
        self.watchLastSync.text = MESSAGE_NOT_YET_SYNCED;
}

@end
