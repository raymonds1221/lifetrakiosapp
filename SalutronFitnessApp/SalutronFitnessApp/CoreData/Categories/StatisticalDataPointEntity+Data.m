//
//  StatisticalDataPointEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronFitnessAppDelegate.h"

#import "StatisticalDataPointEntity+Data.h"

#import "StatisticalDataHeaderEntity.h"

#import "SFAServerAccountManager.h"

#import "JDACoreData.h"

@implementation StatisticalDataPointEntity (Data)

#pragma mark - Private Methods

+ (NSManagedObjectContext *)managedObjectContext
{
    SFASalutronFitnessAppDelegate *appDelegate  = [UIApplication sharedApplication].delegate;
    
    return  appDelegate.managedObjectContext;
}

#pragma mark - Public Methods

+ (NSArray *)dataPointsForDate:(NSDate *)date
{
    // Date
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSString *predicateFormat       = [NSString stringWithFormat:@"(header.date.month == %i) AND (header.date.day == %i) AND (header.date.year == %i) AND (header.device.macAddress == '%@') AND (header.device.user.userID == '%@')",
                                       components.month, components.day, components.year - 1900, macAddress, [SFAServerAccountManager sharedManager].user.userID];
    NSArray *data                   = [[JDACoreData sharedManager] fetchEntityWithEntityName:STATISTICAL_DATA_POINT_ENTITY
                                                                             predicate:[NSPredicate predicateWithFormat:predicateFormat]
                                                                           sortWithKey:@"dataPointID"
                                                                              ascending:YES
                                                                              sortType:SORT_TYPE_NUMBER];
    return data;
}

+ (NSArray *)dataPointsForWeek:(NSInteger)week ofYear:(NSInteger)year
{
    // Date
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.weekOfYear           = week;
    components.yearForWeekOfYear    = year;
    
    // Mac Address
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
    
    // Data
    NSMutableArray *data = [NSMutableArray new];
    
    for (NSInteger a = 1; a <= 7; a++)
    {
        components.weekday                  = a;
        NSDate *date                        = [calendar dateFromComponents:components];
        NSDateComponents *dateComponents    = [calendar components:NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit fromDate:date];
        NSString *predicateFormat           = [NSString stringWithFormat:@"(header.date.month == %i AND header.date.day == %i AND header.date.year == %i) AND (header.device.macAddress == '%@') AND (header.device.user.userID == %@)", dateComponents.month, dateComponents.day, dateComponents.year - 1900, macAddress, [SFAServerAccountManager sharedManager].user.userID];
        NSArray *array                      = [[JDACoreData sharedManager] fetchEntityWithEntityName:STATISTICAL_DATA_POINT_ENTITY
                                                                                           predicate:[NSPredicate predicateWithFormat:predicateFormat]
                                                                                         sortWithKey:@"dataPointID"
                                                                                               limit:144
                                                                                           ascending:YES
                                                                                            sortType:SORT_TYPE_NUMBER];
        
        [data addObjectsFromArray:array];
    }
    
    return data.copy;
}

+ (NSArray *)dataPointsForMonth:(NSInteger)month ofYear:(NSInteger)year
{
    // Core Data
    NSUserDefaults *userDefaults        = [NSUserDefaults standardUserDefaults];
    NSString *macAddress                = [userDefaults objectForKey:MAC_ADDRESS];
    NSString *predicateFormat           = [NSString stringWithFormat:@"(header.date.month == %i AND header.date.year == %i) AND (header.device.macAddress == '%@') AND (header.device.user.userID == '%@')", month, year - 1900, macAddress, [SFAServerAccountManager sharedManager].user.userID];
    NSArray *data                       = [[JDACoreData sharedManager] fetchEntityWithEntityName:STATISTICAL_DATA_POINT_ENTITY
                                                                                       predicate:[NSPredicate predicateWithFormat:predicateFormat]
                                                                                     sortWithKey:@"header.date.day, dataPointID"
                                                                                       ascending:YES
                                                                                        sortType:SORT_TYPE_NUMBER];

    return data;
}

+ (NSArray *)dataPointsForYear:(NSInteger)year
{
    // Core Data
    NSUserDefaults *userDefaults        = [NSUserDefaults standardUserDefaults];
    NSString *macAddress                = [userDefaults objectForKey:MAC_ADDRESS];
    NSString *predicateFormat           = [NSString stringWithFormat:@"(header.date.year == %i) AND (header.device.macAddress == '%@') AND (header.device.user.userID == '%@')", year - 1900, macAddress, [SFAServerAccountManager sharedManager].user.userID];
    NSArray *data                       = [[JDACoreData sharedManager] fetchEntityWithEntityName:STATISTICAL_DATA_POINT_ENTITY
                                                                                       predicate:[NSPredicate predicateWithFormat:predicateFormat]
                                                                                     sortWithKey:@"header.date.month, header.date.day, dataPointID"
                                                                                       ascending:YES
                                                                                        sortType:SORT_TYPE_NUMBER];
    
    return data;
}

+ (StatisticalDataPointEntity *)dataPointForDictionary:(NSDictionary *)dictionary forDataHeader:(StatisticalDataHeaderEntity *)dataHeader
{
    NSNumber *dataPointID       = @([[dictionary objectForKey:API_DATA_POINT_ID] floatValue]);
    NSNumber *averageHR         = @([[dictionary objectForKey:API_DATA_POINT_AVERAGE_HR] floatValue]);
    NSNumber *axisDirection     = @([[dictionary objectForKey:API_DATA_POINT_AXIS_DIRECTION] floatValue]);
    NSNumber *dominantAxis      = @([[dictionary objectForKey:API_DATA_POINT_DOMINANT_AXIS] floatValue]);
    NSNumber *sleepPoint02      = @([[dictionary objectForKey:API_DATA_POINT_SLEEP_POINT_02] floatValue]);
    NSNumber *sleepPoint24      = @([[dictionary objectForKey:API_DATA_POINT_SLEEP_POINT_24] floatValue]);
    NSNumber *sleepPoint46      = @([[dictionary objectForKey:API_DATA_POINT_SLEEP_POINT_46] floatValue]);
    NSNumber *sleepPoint68      = @([[dictionary objectForKey:API_DATA_POINT_SLEEP_POINT_68] floatValue]);
    NSNumber *sleepPoint810     = @([[dictionary objectForKey:API_DATA_POINT_SLEEP_POINT_810] floatValue]);
    NSNumber *steps             = @([[dictionary objectForKey:API_DATA_POINT_STEPS] floatValue]);
    NSNumber *calories          = @([[dictionary objectForKey:API_DATA_POINT_CALORIES] floatValue]);
    NSNumber *distance          = @([[dictionary objectForKey:API_DATA_POINT_DISTANCE] floatValue]);
    NSNumber *lux               = @([[dictionary objectForKey:API_DATA_POINT_LUX] floatValue]);
    NSNumber *wristDetection    = @([[dictionary objectForKey:API_DATA_POINT_WRIST_DETECTION] boolValue]);
    NSNumber *bleStatus         = @([[dictionary objectForKey:API_DATA_POINT_BLE_STATUS] boolValue]);
    
    JDACoreData *coreData                   = [JDACoreData sharedManager];
    StatisticalDataPointEntity *dataPoint   = [coreData insertNewObjectWithEntityName:STATISTICAL_DATA_POINT_ENTITY];
    dataPoint.averageHR                     = averageHR;
    dataPoint.axisDirection                 = axisDirection;
    dataPoint.calorie                       = calories;
    dataPoint.dataPointID                   = dataPointID;
    dataPoint.distance                      = distance;
    dataPoint.dominantAxis                  = dominantAxis;
    dataPoint.lux                           = lux;
    dataPoint.sleepPoint02                  = sleepPoint02;
    dataPoint.sleepPoint24                  = sleepPoint24;
    dataPoint.sleepPoint46                  = sleepPoint46;
    dataPoint.sleepPoint68                  = sleepPoint68;
    dataPoint.sleepPoint810                 = sleepPoint810;
    dataPoint.steps                         = steps;
    dataPoint.header                        = dataHeader;
    dataPoint.wristDetection                = wristDetection;
    dataPoint.bleStatus                     = bleStatus;
    
    [dataHeader addDataPointObject:dataPoint];
    
    return dataPoint;
}

+ (NSArray *)dataPointsWithArray:(NSArray *)array forDataHeader:(StatisticalDataHeaderEntity *)dataHeader
{
    NSMutableArray *dataPoints = [NSMutableArray new];
    
    for (NSDictionary *dictionary in array) {
        StatisticalDataPointEntity *dataPoint = [self dataPointForDictionary:dictionary forDataHeader:dataHeader];
        [dataPoints addObject:dataPoint];
    }
    
    return dataPoints.copy;
}

- (NSDictionary *)dictionary
{
    NSDictionary *dictionary    = @{API_DATA_POINT_ID               : self.dataPointID,
                                    API_DATA_POINT_AVERAGE_HR       : self.averageHR,
                                    API_DATA_POINT_AXIS_DIRECTION   : self.axisDirection,
                                    API_DATA_POINT_AXIS_MAGNITUDE   : self.axisMagnitude,
                                    API_DATA_POINT_DOMINANT_AXIS    : self.dominantAxis,
                                    API_DATA_POINT_SLEEP_POINT_02   : self.sleepPoint02,
                                    API_DATA_POINT_SLEEP_POINT_24   : self.sleepPoint24,
                                    API_DATA_POINT_SLEEP_POINT_46   : self.sleepPoint46,
                                    API_DATA_POINT_SLEEP_POINT_68   : self.sleepPoint68,
                                    API_DATA_POINT_SLEEP_POINT_810  : self.sleepPoint810,
                                    API_DATA_POINT_STEPS            : self.steps,
                                    API_DATA_POINT_CALORIES         : self.calorie,
                                    API_DATA_POINT_DISTANCE         : self.distance,
                                    API_DATA_POINT_LUX              : self.lux ? self.lux : @0,
                                    API_DATA_POINT_WRIST_DETECTION  : self.wristDetection ? self.wristDetection : @0,
                                    API_DATA_POINT_BLE_STATUS       : self.bleStatus ? self.bleStatus : @0};
    
    return dictionary;
}

#pragma mark - Public class average bpm
+ (NSInteger)getAverageBPMForDate:(NSDate *)date
{
    NSArray *data = [[self dataPointsForDate:date] copy];
    return [self getAverageBPMWithData:data];
}

+ (NSInteger)getAverageBPMForWeek:(NSInteger)week ofYear:(NSInteger)year
{
    NSArray *data = [self dataPointsForWeek:week ofYear:year];
    return [self getAverageBPMWithData:data];
}

+ (NSInteger)getAverageBPMForMonth:(NSInteger)month ofYear:(NSInteger)year
{
    NSArray *data = [self dataPointsForMonth:month ofYear:year];
    return [self getAverageBPMWithData:data];
}

+ (NSInteger)getAverageBPMForYear:(NSInteger)year
{
    NSArray *data = [self dataPointsForYear:year];
    return [self getAverageBPMWithData:data];
}

#pragma mark - Private class average bpm
+ (NSInteger)getAverageBPMWithData:(NSArray *)data
{
    if (data)
    {
        if (data.count > 0)
        {
            NSInteger totalBPM = 0;
            NSInteger BPMCount = 0;
            
            for (StatisticalDataPointEntity *dataPoint in data)
            {
                int heartRate = dataPoint.averageHR.integerValue;
                
                if (heartRate > 0 )
                {
                    totalBPM += heartRate;
                    BPMCount ++;
                }
            }


            NSInteger averageBPM = 0;

            // Prevent division by zero --JB
            if (BPMCount != 0)
                averageBPM = totalBPM / BPMCount;
            
            return averageBPM;
        }
    }
    
    return 0;
}

@end
