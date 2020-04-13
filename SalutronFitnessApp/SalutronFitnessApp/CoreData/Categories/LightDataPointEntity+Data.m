//
//  LightDataPointEntity+Data.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 8/20/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "LightDataPointEntity+Data.h"
#import "StatisticalDataHeaderEntity+Data.h"
#import "StatisticalDataPointEntity+Data.h"
#import "SFAServerAccountManager.h"
#import "JDACoreData.h"
#import "DateEntity.h"
#import "StatisticalDataPoint.h"

@implementation LightDataPointEntity (Data)

float redCoefficient(int gain)
{
    switch (gain) {
        case 0:
            return 0.16625f;
            break;
        case 1:
            return 0.665f;
            break;
        case 2:
            return 2.66f;
            break;
        case 3:
            return 42.56f;
            break;
        default:
            break;
    }
    return 0.0f;
}

float greenCoefficient(int gain)
{
    switch (gain) {
        case 0:
            return 0.262233f;
            break;
        case 1:
            return 1.048933f;
            break;
        case 2:
            return 4.19573f;
            break;
        case 3:
            return 67.13168f;
            break;
        default:
            break;
    }
    return 0.0f;
}

float blueCoefficient(int gain)
{
    switch (gain) {
        case 0:
            return 0.262225f;
            break;
        case 1:
            return 1.048898f;
            break;
        case 2:
            return 4.195593f;
            break;
        case 3:
            return 67.12949f;
            break;
        default:
            break;
    }
    return 0.0f;
}

float clearCoefficient(int gain)
{
    switch (gain) {
        case 0:
            return 0.361903f;
            break;
        case 1:
            return 1.44761f;
            break;
        case 2:
            return 5.79044f;
            break;
        case 4:
            return 92.64693f;
            break;
        default:
            break;
    }
    return 0.0f;
}

/**********************************************************************************/

+ (id)insertLightDataPoint:(LightDataPoint *)dataPoint
statisticalDataPointEntity:(StatisticalDataPointEntity *)statisticalDataPoint
                     index:(NSInteger)index
    inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

{
    LightDataPointEntity *dataPointEntity = [NSEntityDescription insertNewObjectForEntityForName:LIGHT_DATA_POINT_ENTITY inManagedObjectContext:managedObjectContext];
    dataPointEntity.dataPointID = [NSNumber numberWithInteger:index];
    return [self updateLightDataPointEntityWithDataPoint:dataPoint statisticalDataPointEntity:statisticalDataPoint dataPointEntity:dataPointEntity];
}

/**********************************************************************************/

+ (id)updateLightDataPointEntityWithDataPoint:(LightDataPoint *)dataPoint
                   statisticalDataPointEntity:(StatisticalDataPointEntity *)statisticalDataPoint dataPointEntity:(LightDataPointEntity *)dataPointEntity
{
    dataPointEntity.red = [NSNumber numberWithInt:dataPoint.red];
    dataPointEntity.green = [NSNumber numberWithInt:dataPoint.green];
    dataPointEntity.blue = [NSNumber numberWithInt:dataPoint.blue];
    dataPointEntity.sensorGain = [NSNumber numberWithChar:dataPoint.sensor_gain];
    dataPointEntity.integrationTime = [NSNumber numberWithChar:dataPoint.intergration_time];
    
    if ([statisticalDataPoint.wristDetection boolValue] == YES) {
        dataPointEntity.redLightCoeff = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", redCoefficient([dataPointEntity.sensorGain intValue])]];
        dataPointEntity.greenLightCoeff = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", greenCoefficient([dataPointEntity.sensorGain intValue])]];
        dataPointEntity.blueLightCoeff = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", blueCoefficient([dataPointEntity.sensorGain intValue])]];
    }
    else {
        dataPointEntity.redLightCoeff = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", clearCoefficient([dataPointEntity.sensorGain intValue])]];
        dataPointEntity.greenLightCoeff = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", clearCoefficient([dataPointEntity.sensorGain intValue])]];
        dataPointEntity.blueLightCoeff = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", clearCoefficient([dataPointEntity.sensorGain intValue])]];
    }
    
    dataPointEntity.dataPoint = statisticalDataPoint;
    
    return dataPointEntity;
}


/**********************************************************************************/

+ (NSArray *)lightDataPointsForDate:(NSDate *)date
{
    NSString *macAddress            = [[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS];
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSString *predicateFormat       = [NSString stringWithFormat:@"(header.date.month == %i) AND (header.date.day == %i) AND (header.date.year == %i) AND (header.device.macAddress == '%@') AND (header.device.user.userID == '%@')", components.month, components.day, components.year - 1900, macAddress, [SFAServerAccountManager sharedManager].user.userID];
    
    NSArray *data                   = [[JDACoreData sharedManager] fetchEntityWithEntityName:LIGHT_DATA_POINT_ENTITY
                                                                                   predicate:[NSPredicate predicateWithFormat:predicateFormat]
                                                                                 sortWithKey:@"dataPointID"
                                                                                   ascending:YES
                                                                                    sortType:SORT_TYPE_NUMBER];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return data;
}

/**********************************************************************************/

+ (NSArray *)lightDataPointsForWeek:(NSInteger)week ofYear:(NSInteger)year daysInWeek:(NSMutableOrderedSet *__autoreleasing *)daysInWeek
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
    NSMutableOrderedSet *days = [[NSMutableOrderedSet alloc] init];
    
    for (NSInteger a = 1; a <= 7; a++)
    {
        components.weekday                  = a;
        NSDate *date                        = [calendar dateFromComponents:components];
        NSDateComponents *dateComponents    = [calendar components:NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit fromDate:date];
        NSString *predicateFormat           = [NSString stringWithFormat:@"(header.date.month == %i AND header.date.day == %i AND header.date.year == %i) AND (header.device.macAddress == '%@')  AND (header.device.user.userID == '%@')", dateComponents.month, dateComponents.day, dateComponents.year - 1900, macAddress, [SFAServerAccountManager sharedManager].user.userID];
        NSArray *array                      = [[JDACoreData sharedManager] fetchEntityWithEntityName:LIGHT_DATA_POINT_ENTITY
                                                                                           predicate:[NSPredicate predicateWithFormat:predicateFormat]
                                                                                         sortWithKey:@"dataPointID"
                                                                                           ascending:YES
                                                                                            sortType:SORT_TYPE_NUMBER];
        [data addObjectsFromArray:array];
        [days addObject:[NSNumber numberWithInteger:dateComponents.day]];
    }
    
    if (daysInWeek != NULL) {
        *daysInWeek = days;
    }
    
    
    return data;
}

/**********************************************************************************/

+ (NSArray *)lightDataPointsForMonth:(NSInteger)month ofYear:(NSInteger)year daysInMonth:(NSMutableOrderedSet *__autoreleasing *)daysInMonth
{
    NSMutableOrderedSet *days = [[NSMutableOrderedSet alloc] init];
    // Core Data
    NSUserDefaults *userDefaults        = [NSUserDefaults standardUserDefaults];
    NSString *macAddress                = [userDefaults objectForKey:MAC_ADDRESS];
    NSString *predicateFormat           = [NSString stringWithFormat:@"(header.date.month == %i AND header.date.year == %i) AND (header.device.macAddress == '%@')  AND (header.device.user.userID == '%@')", month, year - 1900, macAddress, [SFAServerAccountManager sharedManager].user.userID];
    NSArray *data                       = [[JDACoreData sharedManager] fetchEntityWithEntityName:LIGHT_DATA_POINT_ENTITY
                                                                                       predicate:[NSPredicate predicateWithFormat:predicateFormat]
                                                                                     sortWithKey:@"header.date.day, dataPointID"
                                                                                       ascending:YES
                                                                                        sortType:SORT_TYPE_NUMBER];
    for (LightDataPointEntity *entity in data) {
        [days addObject:entity.header.date.day];
    }
    
    if (daysInMonth != NULL) {
        *daysInMonth = days;
    }

    return data;
}


/**********************************************************************************/

+ (NSArray *)lightDataPointsForYear:(NSInteger)year daysInYear:(NSMutableOrderedSet *__autoreleasing *)daysInYear
{
    NSMutableOrderedSet *days = [[NSMutableOrderedSet alloc] init];
    // Core Data
    NSUserDefaults *userDefaults        = [NSUserDefaults standardUserDefaults];
    NSString *macAddress                = [userDefaults objectForKey:MAC_ADDRESS];
    NSString *predicateFormat           = [NSString stringWithFormat:@"(header.date.year == %i) AND (header.device.macAddress == '%@') AND (header.device.user.userID == '%@')", year - 1900, macAddress, [SFAServerAccountManager sharedManager].user.userID];
    NSArray *data                       = [[JDACoreData sharedManager] fetchEntityWithEntityName:LIGHT_DATA_POINT_ENTITY
                                                                                       predicate:[NSPredicate predicateWithFormat:predicateFormat]
                                                                                     sortWithKey:@"header.date.month, header.date.day, dataPointID"
                                                                                       ascending:YES
                                                                                        sortType:SORT_TYPE_NUMBER];
    
    for (LightDataPointEntity *entity in data) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSUInteger dayOfYear = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:entity.header.dateInNSDate];
        [days addObject:[NSNumber numberWithInteger:dayOfYear]];
    }
    
    if (daysInYear != NULL) {
        *daysInYear = days;
    }
    
    return data;
}

/**********************************************************************************/

+ (LightDataPointEntity *)lightDataPointForDictionary:(NSDictionary *)dictionary forDataHeader:(StatisticalDataHeaderEntity *)dataHeader
{
    NSNumber *dataPointID       = @([[dictionary objectForKey:API_LIGHT_DATA_POINT_ID] floatValue]);
    NSNumber *red               = @([[dictionary objectForKey:API_LIGHT_DATA_POINT_RED] floatValue]);
    NSNumber *green             = @([[dictionary objectForKey:API_LIGHT_DATA_POINT_GREEN] floatValue]);
    NSNumber *blue              = @([[dictionary objectForKey:API_LIGHT_DATA_POINT_BLUE] floatValue]);
    NSNumber *integrationTime   = @([[dictionary objectForKey:API_LIGHT_DATA_POINT_INTEGRATION_TIME] floatValue]);
    NSNumber *sensorGain        = @([[dictionary objectForKey:API_LIGHT_DATA_POINT_SENSOR_GAIN] floatValue]);
    NSDecimalNumber *redLightCoeff      = [NSDecimalNumber decimalNumberWithDecimal:[[dictionary objectForKey:API_LIGHT_DATA_POINT_RED_LIGHT_COEFF] decimalValue]];
    NSDecimalNumber *greenLightCoeff    = [NSDecimalNumber decimalNumberWithDecimal:[[dictionary objectForKey:API_LIGHT_DATA_POINT_GREEN_LIGHT_COEFF] decimalValue]];
    NSDecimalNumber *blueLightCoeff     = [NSDecimalNumber decimalNumberWithDecimal:[[dictionary objectForKey:API_LIGHT_DATA_POINT_BLUE_LIGHT_COEFF] decimalValue]];
    
    
    JDACoreData *coreData           = [JDACoreData sharedManager];
    LightDataPointEntity *dataPoint = [coreData insertNewObjectWithEntityName:LIGHT_DATA_POINT_ENTITY];
    dataPoint.dataPointID           = dataPointID;
    dataPoint.red               = red;
    dataPoint.green             = green;
    dataPoint.blue              = blue;
    dataPoint.integrationTime   = integrationTime;
    dataPoint.sensorGain        = sensorGain;
    dataPoint.redLightCoeff     = redLightCoeff;
    dataPoint.greenLightCoeff   = greenLightCoeff;
    dataPoint.blueLightCoeff    = blueLightCoeff;
    dataPoint.header            = dataHeader;
    
    if ([dataPoint.dataPoint.wristDetection boolValue] == YES) {
        
    }
    [dataHeader addLightDataPointObject:dataPoint];
    
    return dataPoint;
}

/**********************************************************************************/

+ (NSArray *)dataPointsWithArray:(NSArray *)array dataPoints:(NSArray *)statisticalDataPoints forDataHeader:(StatisticalDataHeaderEntity *)dataHeader
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dataPointID" ascending:YES];
    NSArray *sortedStatisticalDataPointsArray = [statisticalDataPoints sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSSortDescriptor *sortDescriptorLight = [[NSSortDescriptor alloc] initWithKey:@"light_datapoint_id.intValue" ascending:YES];
    NSArray *sortedLightDataPointsArray = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptorLight]];
    
    NSMutableArray *dataPoints = [NSMutableArray new];
    
    for (int i = 0; i < sortedLightDataPointsArray.count; i++) {
        if (i < sortedStatisticalDataPointsArray.count) {
            NSDictionary *dictionary = (NSDictionary *)sortedLightDataPointsArray[i];
            LightDataPointEntity *lightDataPoint = [self lightDataPointForDictionary:dictionary forDataHeader:dataHeader];
            lightDataPoint.dataPoint = sortedStatisticalDataPointsArray[i];
        }
        else{
            break;
        }
    }
    
    return dataPoints.copy;
}

/**********************************************************************************/

- (NSDictionary *)dictionary
{
    NSDictionary *dictionary    = @{API_LIGHT_DATA_POINT_ID                 : self.dataPointID,
                                    API_LIGHT_DATA_POINT_RED                : self.red,
                                    API_LIGHT_DATA_POINT_GREEN              : self.green,
                                    API_LIGHT_DATA_POINT_BLUE               : self.blue,
                                    API_LIGHT_DATA_POINT_INTEGRATION_TIME   : self.integrationTime,
                                    API_LIGHT_DATA_POINT_SENSOR_GAIN        : self.sensorGain,
                                    API_LIGHT_DATA_POINT_RED_LIGHT_COEFF    : self.redLightCoeff,
                                    API_LIGHT_DATA_POINT_GREEN_LIGHT_COEFF  : self.greenLightCoeff,
                                    API_LIGHT_DATA_POINT_BLUE_LIGHT_COEFF   : self.blueLightCoeff};
    
    return dictionary;
}

/**********************************************************************************/

@end
