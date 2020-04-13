//
//  TimeDate+Data.m
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/19/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Format.h"

#import "TimeDateEntity+Data.h"

#import "TimeDate+Data.h"

#import "DeviceEntity+Data.h"


@implementation TimeDate (Data)

#pragma mark - Public class save methods
+ (void)saveWithTimeDate:(TimeDate *)timeDate
{
    //save time date
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    [TimeDateEntity timeDateWithTimeDate:timeDate forDeviceEntity:deviceEntity];
    
    [SFAUserDefaultsManager sharedManager].timeDate = timeDate;
    DDLogInfo(@"----------> TIMEDATE : %@", timeDate);
}

#pragma mark - Public class select methods
+ (TimeDate *)getData
{
    //set data if nil
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    
    if (deviceEntity.timeDate == nil)
    {
        TimeDate *timeDate = [[TimeDate alloc] initWithDate:[NSDate date]];
        [SFAUserDefaultsManager sharedManager].timeDate = timeDate;
        
        [TimeDateEntity timeDateWithTimeDate:timeDate forDeviceEntity:deviceEntity];
        
        return [TimeDate timeDateWithTimeDateEntity:deviceEntity.timeDate];
    } else {
        //TimeDate *_timeDate2 = [[TimeDate alloc] initWithDate:[NSDate date]];
        //_timeDate2.hourFormat = _timeDate.hourFormat;
        //_timeDate2.dateFormat = _timeDate.dateFormat;
        //[self saveWithTimeDate:_timeDate2];
        //return _timeDate2;
        
        return [TimeDate timeDateWithTimeDateEntity:deviceEntity.timeDate];
    }
    
    return nil;
}

+ (TimeDate *)getDataWithMACAddress:(NSString *)macAdress
{
    //set data if nil
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:macAdress];
    
    if (deviceEntity.timeDate == nil)
    {
        TimeDate *timeDate = [[TimeDate alloc] initWithDate:[NSDate date]];
        [SFAUserDefaultsManager sharedManager].timeDate = timeDate;
        
        [TimeDateEntity timeDateWithTimeDate:timeDate forDeviceEntity:deviceEntity];
        
        return [TimeDate timeDateWithTimeDateEntity:deviceEntity.timeDate];
    } else {
        //TimeDate *_timeDate2 = [[TimeDate alloc] initWithDate:[NSDate date]];
        //_timeDate2.hourFormat = _timeDate.hourFormat;
        //_timeDate2.dateFormat = _timeDate.dateFormat;
        //[self saveWithTimeDate:_timeDate2];
        //return _timeDate2;
        
        return [TimeDate timeDateWithTimeDateEntity:deviceEntity.timeDate];
    }
    
    return nil;
}

+ (TimeDate *)getUpdatedData
{
    // Get time and date values from the device
    //NSCalendar *calendar = [NSCalendar currentCalendar];
    /*NSDateComponents *dateComponents = [calendar components:NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit |
                                                            NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit
                                                   fromDate:[NSDate date]];*/
    
    // Create SH_Date object
    /*SH_Date *date = [[SH_Date alloc] init];
    date.month = dateComponents.month;
    date.day = dateComponents.day;
    date.year = dateComponents.year - 1900;*/
    
    // Create SH_Time object
    /*SH_Time *time = [[SH_Time alloc] init];
    time.hour = dateComponents.hour;
    time.minute = dateComponents.minute;
    time.second = dateComponents.second;*/
    
    // Update date and time
    TimeDate *timeDate = [self getData];
    /*timeDate.date = date;
    timeDate.time = time;*/
    
    TimeDate *valueOfTimeDate   = [[TimeDate alloc] initWithDate:[NSDate date]];
    valueOfTimeDate.hourFormat  = timeDate.hourFormat;
    valueOfTimeDate.dateFormat  = timeDate.dateFormat;
    valueOfTimeDate.watchFace   = timeDate.watchFace;
    
    // Save time date
    //[self saveWithTimeDate:timeDate];
    [self saveWithTimeDate:valueOfTimeDate];
    DDLogInfo(@"----------> TIMEDATE : %@", valueOfTimeDate);
    return valueOfTimeDate;
}

- (BOOL)isEqualToTimeDate:(TimeDate *)timeDate
{
    if(/*self.time == timeDate.time && */self.date.month == timeDate.date.month && self.date.day == timeDate.date.day && self.date.year == timeDate.date.year && self.hourFormat == timeDate.hourFormat && self.dateFormat == timeDate.dateFormat /*&& self.watchFace == timeDate.watchFace*/) {
        return YES;
    }
    return NO;
}

#pragma mark - Private Methods

- (NSString *)hourFormatString
{
    if (self.hourFormat == _12_HOUR) {
        return @"12";
    } else if (self.hourFormat == _24_HOUR) {
        return @"24";
    }
    
    return @"12";
}

- (NSString *)dateFormatString
{
    if (self.dateFormat == _MMDD) {
        return @"MMDD";
    } else if (self.dateFormat == _DDMM) {
        return @"DDMM";
    }
    
    return @"MMDD";
}

- (NSString *)watchFaceString
{
    if (self.watchFace == _SIMPLE) {
        return @"simple";
    } else if (self.watchFace == _FULL) {
        return @"full";
    }
    
    return @"simple";
}

#pragma mark - Public Methods

+ (TimeDate *)timeDate
{
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
    TimeDate *timeDate = [TimeDate timeDateWithTimeDateEntity:deviceEntity.timeDate];
    
    if (!deviceEntity.timeDate) {
        timeDate = [TimeDate new];
    }
    
//    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
//    NSData *data                    = [userDefaults objectForKey:TIME_DATE];
//    TimeDate *timeDate              = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    
//    if (!timeDate) {
//        timeDate = [TimeDate new];
//    }
    
    return timeDate;
}

+ (TimeDate *)timeDateWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        NSString *hourFormat    = [dictionary objectForKey:API_DEVICE_SETTINGS_HOUR_FORMAT];
        NSString *dateFormat    = [dictionary objectForKey:API_DEVICE_SETTINGS_DATE_FORMAT];
        NSString *watchFace     = [dictionary objectForKey:API_DEVICE_SETTINGS_WATCH_FACE];
        
        TimeDate *timeDate      = [[TimeDate alloc] init];
        timeDate.hourFormat     = [hourFormat isEqualToString:@"12"] ? _12_HOUR : _24_HOUR;
        timeDate.dateFormat     = [dateFormat isEqualToString:@"MMDD"] ? _MMDD : _DDMM;
        timeDate.watchFace      = [watchFace isEqualToString:@"simple"] ? _SIMPLE : _FULL;
        
        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:timeDate];
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:data forKey:TIME_DATE];
        
        DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
        [TimeDateEntity timeDateWithTimeDate:timeDate forDeviceEntity:deviceEntity];
        
        return timeDate;
    }
    
    return nil;
}

+ (TimeDate *)timeDateWithTimeDateEntity:(TimeDateEntity *)entity
{
    TimeDate *timeDate      = [TimeDate new];
    timeDate.date           = [SH_Date new];
    timeDate.date.month     = entity.date.dateComponents.month;
    timeDate.date.day       = entity.date.dateComponents.day;
    timeDate.date.year      = entity.date.dateComponents.year - DATE_YEAR_ADDER;
    timeDate.time           = [SH_Time new];
    timeDate.time.hour      = entity.date.dateComponents.hour;
    timeDate.time.minute    = entity.date.dateComponents.minute;
    timeDate.time.second    = entity.date.dateComponents.second;
    timeDate.hourFormat     = entity.hourFormat.integerValue;
    timeDate.dateFormat     = entity.dateFormat.integerValue;
    timeDate.watchFace      = entity.watchFace.integerValue;
    
    [SFAUserDefaultsManager sharedManager].timeDate = timeDate;
    return timeDate;
}

- (NSDictionary *)dictionary
{
    NSDictionary *dictionary = @{API_DEVICE_SETTINGS_HOUR_FORMAT    : self.hourFormatString,
                                 API_DEVICE_SETTINGS_DATE_FORMAT    : self.dateFormatString,
                                 API_DEVICE_SETTINGS_WATCH_FACE     : self.watchFaceString};
    
    return dictionary;
}

@end
