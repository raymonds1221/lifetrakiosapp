//
//  SFALightDataManager.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 9/20/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFALightDataManager.h"
#import "DayLightAlertEntity+Data.h"
#import "LightDataPointEntity+GraphData.h"
#import "StatisticalDataPointEntity.h"
#import "NightLightAlertEntity+Data.h"
#import "DayLightAlertEntity+Data.h"

@implementation SFALightDataManager

+ (int)getTotalExposureTime:(NSArray *)arrayOfEntities
{
    DayLightAlertEntity *dayLightAlertEntity = [DayLightAlertEntity getDayLightAlert];
    
    int startIndex          = ([dayLightAlertEntity.startHour intValue] * 6) + [dayLightAlertEntity.startMin intValue];
    int endIndex            = ([dayLightAlertEntity.endHour intValue] * 6) + [dayLightAlertEntity.endMin intValue];
    int totalExposureTime   = 0;
    
    for (LightDataPointEntity *entity in arrayOfEntities) {
        if ([entity.dataPoint.wristDetection boolValue] == YES && [entity.dataPointID intValue] >= startIndex && [entity.dataPointID intValue] <= endIndex && [SFALightDataManager isAmbientLight:[entity blueLux] lightColor:SFALightColorAll]) {
            totalExposureTime += 10;
        }
    }
    return totalExposureTime;
}

+ (int)getExposureTimeDuration:(NSArray *)arrayOfEntities
{
    DayLightAlertEntity *dayLightAlertEntity = [DayLightAlertEntity getDayLightAlert];
    
    //int startIndex          = ([dayLightAlertEntity.startHour intValue] * 6) + [dayLightAlertEntity.startMin intValue];
    //int endIndex            = ([dayLightAlertEntity.endHour intValue] * 6) + [dayLightAlertEntity.endMin intValue];
    int totalExposureTime     = [dayLightAlertEntity.duration intValue];//(endIndex - startIndex);
    return totalExposureTime;
}

// Natural Light
+ (BOOL)isAmbientLight:(float)light lightColor:(SFALightColor)lightColor
{
    int minValueForAmbientLight = 0;
    
    switch (lightColor) {
        case SFALightColorAll:
            minValueForAmbientLight = [NightLightAlertEntity getNightLightAlertThreshold];
            break;
        case SFALightColorRed:
        case SFALightColorGreen:
        case SFALightColorBlue:
        default:
            minValueForAmbientLight = [DayLightAlertEntity getDayLightAlertThreshold];
            break;
    }
    
    if (light > minValueForAmbientLight) {
        return YES;
    }
    return NO;
}

@end
