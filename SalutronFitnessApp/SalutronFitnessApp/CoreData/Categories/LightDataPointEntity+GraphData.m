//
//  LightDataPointEntity+GraphData.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 8/27/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "LightDataPointEntity+GraphData.h"
#import "LightDataPointEntity+Data.h"
#import "StatisticalDataHeaderEntity.h"
#import "DateEntity.h"
#import "StatisticalDataPointEntity+Data.h"
#import "DayLightAlertEntity+Data.h"
#import "NightLightAlertEntity+Data.h"
#import "NSDate+Comparison.h"

static CGFloat const maxLightValue = 110000;
static const NSInteger maxAllLightLuxValue = 110000;

@implementation LightDataPointEntity (GraphData)

/**********************************************************************************/

- (CGFloat)allLux
{
    float allLux = ([self.red floatValue] * [self.redLightCoeff floatValue]) + ([self.green floatValue] * [self.greenLightCoeff floatValue]) + ([self.blue floatValue] * [self.blueLightCoeff floatValue]);
    allLux = allLux < 1.0f ? 1.0f : allLux;
   
    if (allLux > maxAllLightLuxValue) {
        allLux = maxAllLightLuxValue;
    }

    if (log10f(allLux) > maxLightValue) {
        return maxLightValue;
    }
    
    return allLux;
//    return log10f(allLux);
}

- (CGFloat)redLux
{
    float redLux = [self.red floatValue] * [self.redLightCoeff floatValue];
    redLux = redLux < 1.0f ? 1.0f : redLux;
    
    if (log10f(redLux) > maxLightValue) {
        return maxLightValue;
    }
    return redLux;
//    return log10f(redLux);
}

- (CGFloat)greenLux
{
    float greenLux = [self.green floatValue] * [self.greenLightCoeff floatValue];
    greenLux = greenLux < 1.0f ? 1.0f : greenLux;
    
    if (log10f(greenLux) > maxLightValue) {
        return maxLightValue;
    }
    return greenLux;
//    return log10f(greenLux);
}

- (CGFloat)blueLux
{
    float blueLux = [self.blue floatValue] * [self.blueLightCoeff floatValue];
    blueLux = blueLux < 1.0f ? 1.0f : blueLux;
    
    if (log10f(blueLux) > maxLightValue) {
        return maxLightValue;
    }
    return blueLux;
//    return log10f(blueLux);
}

/**********************************************************************************/

+ (NSArray *)getDailyLightBarGraphDataForDate:(NSDate *)date lightDataPointsArray:(NSArray *__autoreleasing *)lightDataPointsArray
{
    NSArray *lightDataPointArray = [self lightDataPointsForDate:date];
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    //NSDate *currentDate = [NSDate date];
    //NSCalendar *calendar = [NSCalendar currentCalendar];
    //NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:currentDate];
    //NSInteger hour = [components hour];
    //NSInteger minute = [components minute];
    
    //NSInteger currentTimeInMinutes = ((hour * 60) + minute);
   // NSInteger excludedDataPointIndex = (currentTimeInMinutes/10);
    
    
    for (int index = 0; index < lightDataPointArray.count; index++) {
        LightDataPointEntity *entity = (LightDataPointEntity *)lightDataPointArray[index];
        
        SFABarGraphData *barGraphData = [[SFABarGraphData alloc] init];
        barGraphData.x      = index;
        barGraphData.yBase  = 0.0f;
        barGraphData.yTip   = [entity blueLux];
        barGraphData.yBaseLog = 0.0f;
        barGraphData.yTipLog  = log10f([entity blueLux]);
        
        barGraphData.light = [entity blueLux];
        barGraphData.wristDetection = [entity.dataPoint.wristDetection boolValue];
        //barGraphData.barColor = barGraphData.wristDetection ? SFALightPlotBarColorBlueLight:SFALightPlotBarColorGray;
        barGraphData.barColor = SFALightPlotBarColorBlueLight;
        /*
        if ([date isToday]) {
            if (index != excludedDataPointIndex &&
                currentTimeInMinutes%10 != 0) {
                [data addObject:barGraphData];
            }
        }
        else{
        */    [data addObject:barGraphData];
        //}
        
    }
    
    for (int index = 0; index < lightDataPointArray.count; index++) {
        LightDataPointEntity *entity = (LightDataPointEntity *)lightDataPointArray[index];
        
        SFABarGraphData *barGraphData = [[SFABarGraphData alloc] init];
        barGraphData.x      = index;
        barGraphData.yBase  = [entity blueLux];
        barGraphData.yTip   = barGraphData.yBase + [entity allLux] - [entity blueLux];
        barGraphData.yBaseLog = log10f([entity blueLux]);
        barGraphData.yTipLog  = log10f(barGraphData.yBase + [entity allLux] - [entity blueLux]);
        
        barGraphData.light  = [entity allLux];
        barGraphData.wristDetection = [entity.dataPoint.wristDetection boolValue];
        //barGraphData.barColor = barGraphData.wristDetection ? SFALightPlotBarColorAllLight:SFALightPlotBarColorGray;
        barGraphData.barColor = SFALightPlotBarColorAllLight;
        
        /*
        if ([date isToday]) {
            if (index != excludedDataPointIndex &&
                currentTimeInMinutes%10 != 0) {
                [data addObject:barGraphData];
            }
        }
        else{
         */   [data addObject:barGraphData];
        //}
         
    }
    
    if (lightDataPointsArray != NULL) {
        *lightDataPointsArray = lightDataPointArray;
    }
    
    return data.copy;
}

+ (NSArray *)getWeeklyLightBarGraphDataForWeek:(NSInteger)week ofYear:(NSInteger)year lightColor:(SFALightColor)lightColor 
{
    NSMutableOrderedSet *daysInWeek = [[NSMutableOrderedSet alloc] init];
    NSArray *lightDataPointArray = [self lightDataPointsForWeek:week ofYear:year daysInWeek:&daysInWeek];
    
    NSMutableArray *weeklyDataPointArray = [[NSMutableArray alloc] init];
    
    for (int dayIndex = 0; dayIndex < daysInWeek.count; dayIndex++) {
        NSMutableArray *dataPointsPerDay = [[NSMutableArray alloc] init];
        
        for (LightDataPointEntity *entity in lightDataPointArray) {
            if ([entity.header.date.day isEqualToNumber:daysInWeek[dayIndex]]) {
                [dataPointsPerDay addObject:entity];
                
            }
        }
        NSArray *barGraphDataArray = [self barGraphDataXBarPosition:dayIndex lightColor:lightColor lightDataPointArray:dataPointsPerDay];
        
        [weeklyDataPointArray addObject:@{daysInWeek[dayIndex]: barGraphDataArray}];
    }
    
    return weeklyDataPointArray;
}

+ (NSArray *)getMonthlyLightBarGraphDataForMonth:(NSInteger)month ofYear:(NSInteger)year lightColor:(SFALightColor)lightColor
{
    NSMutableOrderedSet *daysInMonth = [[NSMutableOrderedSet alloc] init];
    NSArray *lightDataPointArray = [self lightDataPointsForMonth:month ofYear:year daysInMonth:&daysInMonth];
    
    NSMutableArray *monthlyDataPointArray = [[NSMutableArray alloc] init];
    
    for (int dayIndex = 0; dayIndex < daysInMonth.count; dayIndex++) {
        NSMutableArray *dataPointsPerDay = [[NSMutableArray alloc] init];
        
        for (LightDataPointEntity *entity in lightDataPointArray) {
            
            if ([entity.header.date.day isEqualToNumber:daysInMonth[dayIndex]]) {
                [dataPointsPerDay addObject:entity];
            }
        }
        NSArray *barGraphDataArray = [self barGraphDataXBarPosition:dayIndex lightColor:lightColor lightDataPointArray:dataPointsPerDay];
        
        [monthlyDataPointArray addObject:@{daysInMonth[dayIndex]: barGraphDataArray}];
    }
    
    return monthlyDataPointArray;
}

+ (NSArray *)getYearlyLightBarGraphDataForYear:(NSInteger)year lightColor:(SFALightColor)lightColor
{
    
    NSMutableOrderedSet *daysInYear = [[NSMutableOrderedSet alloc] init];
    NSArray *lightDataPointArray = [self lightDataPointsForYear:year daysInYear:&daysInYear];
    
    NSMutableArray *yearlyDataPointArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *dataPointsPerDay = [[NSMutableArray alloc] init];
    int dayIndex = 0;
    
    for (LightDataPointEntity *entity in lightDataPointArray) {
            //LOG(@"dayindex:%d", dayIndex);
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSNumber *dayOfYear = [NSNumber numberWithInteger:[gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:entity.header.dateInNSDate]];
        
            //LOG(@"dayOfYear:%i", dayOfYear.intValue);
            if ([dayOfYear isEqualToNumber:daysInYear[dayIndex]]) {
                [dataPointsPerDay addObject:entity];
            }
            else {
                NSArray *barGraphDataArray = [self barGraphDataXBarPosition:dayIndex lightColor:lightColor lightDataPointArray:dataPointsPerDay];
                
                [yearlyDataPointArray addObject:@{daysInYear[dayIndex]: barGraphDataArray}];
                
                dayIndex++;
                [dataPointsPerDay removeAllObjects];
                /*
                if ([dayOfYear isEqualToNumber:daysInYear[dayIndex]]) {
                    [dataPointsPerDay addObject:entity];
                }
                 */
            }
        
        if ([dayOfYear isEqualToNumber:daysInYear[dayIndex]]) {
            NSArray *barGraphDataArray = [self barGraphDataXBarPosition:dayIndex lightColor:lightColor lightDataPointArray:dataPointsPerDay];
            
            [yearlyDataPointArray addObject:@{daysInYear[dayIndex]: barGraphDataArray}];
            
        }
    }
    return yearlyDataPointArray;
}

/**********************************************************************************/

+ (CGFloat)getMaxYTipValueForLightBarGraphDataArray:(NSArray *)barGraphDataArray
{
    __block CGFloat maxYTipValue = 0.0f;
    
    [barGraphDataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SFABarGraphData *barGraphData = (SFABarGraphData *)obj;
        CGFloat x = barGraphData.yTip;
        //if (barGraphData.wristDetection == 1) {
            if (x > maxYTipValue) maxYTipValue = x;
        //}
    }];
    
    return maxYTipValue;
}

/**********************************************************************************/

+ (CGFloat)totalComputedLightForLightDataPointEntitiesArray:(NSArray *)lightDataPointArray lightColor:(SFALightColor)lightColor
{
    NSMutableArray *arrayOfLightDataWithWristDetection = [[NSMutableArray alloc] init];
    
    CGFloat totalAllLight   = 0.0f;
    CGFloat totalBlueLight  = 0.0f;
    CGFloat totalWristOff   = 0.0f;
    
    for (LightDataPointEntity *entity in lightDataPointArray) {
        
        float blueLux = [entity.blue floatValue] * [entity.blueLightCoeff floatValue];
        float allLux = ([entity.red floatValue] * [entity.redLightCoeff floatValue]) + ([entity.green floatValue] * [entity.greenLightCoeff floatValue]) + blueLux;
        
//        allLux = allLux < 1.0f ? 1.0f : allLux;
//        blueLux = blueLux < 1.0f ? 1.0f : blueLux;        
//        allLux = log10f(allLux);
//        blueLux = log10f(blueLux);
        
        [arrayOfLightDataWithWristDetection addObject:entity];
        
        if ([entity.dataPoint.wristDetection boolValue] == YES) {
            totalAllLight += allLux;
            totalBlueLight += blueLux;
        } else {
            totalWristOff += blueLux;
        }
    }
    
    if (lightColor == SFALightColorAll) {
        return totalAllLight;
    }
    else if (lightColor == SFALightColorBlue) {
        return totalBlueLight;
    }
    else if (lightColor == SFALightcolorWristOff) {
        return totalWristOff;
    }
    return 0.0f;
}

/**********************************************************************************/

+ (NSArray *)barGraphDataXBarPosition:(int)xPosition lightColor:(SFALightColor)lightColor lightDataPointArray:(NSArray *)lightDataPointArray
{
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    float nextYBase = 0.0f;
    
    for (int index = 0; index < lightDataPointArray.count; index++) {
        
        LightDataPointEntity *entity = (LightDataPointEntity *)lightDataPointArray[index];
        
        SFABarGraphData *barGraphData = [[SFABarGraphData alloc] init];
        barGraphData.x      = xPosition;
        barGraphData.yBase  = nextYBase;
        barGraphData.wristDetection = [entity.dataPoint.wristDetection boolValue];
        
        if (lightColor == SFALightColorBlue) {
            barGraphData.yTip   = barGraphData.yBase + [entity blueLux];
            barGraphData.light = [entity blueLux];
            barGraphData.barColor = SFALightPlotBarColorBlueLight;
        }
        else {
            barGraphData.yTip   = barGraphData.yBase + [entity allLux];
            barGraphData.light = [entity allLux];
            barGraphData.barColor = SFALightPlotBarColorAllLight;
        }
        
        nextYBase = barGraphData.yTip;
        [data addObject:barGraphData];
    }
    return data.copy;
}

+ (CGFloat)thresholdForValue:(CGFloat)value lightColor:(SFALightColor)lightColor
{
    if (lightColor == SFALightColorAll) {
        
        if (value > 0 && value <= SFAAllLightThreshold_01) {
            return 0.0f;
        }
        else if (value > SFAAllLightThreshold_01 && value <= SFAAllLightThreshold_02) {
            return SFAAllLightThreshold_01;
        }
        else if (value > SFAAllLightThreshold_02 && value <= SFAAllLightThreshold_03) {
            return SFAAllLightThreshold_02;
        }
        else if (value > SFAAllLightThreshold_03 && value <= SFAAllLightThreshold_04) {
            return SFAAllLightThreshold_03;
        }
        else if (value > SFAAllLightThreshold_04 && value <= SFAAllLightThreshold_05) {
            return SFAAllLightThreshold_04;
        }
        else if (value > SFAAllLightThreshold_05) {
            return SFAAllLightThreshold_05;
        }
        else {
            return SFAAllLightThreshold_05;
        }
    }
    else if (lightColor == SFALightColorBlue) {
        if (value > 0 && value <= SFABlueLightThreshold_01) {
            return 0.0f;
        }
        else if (value > SFABlueLightThreshold_01 && value <= SFABlueLightThreshold_02) {
            return SFABlueLightThreshold_01;
        }
        else if (value > SFABlueLightThreshold_02 && value <= SFABlueLightThreshold_03) {
            return SFABlueLightThreshold_02;
        }
        else if (value > SFABlueLightThreshold_03 && value <= SFABlueLightThreshold_04) {
            return SFABlueLightThreshold_03;
        }
        else if (value > SFABlueLightThreshold_04 && value <= SFABlueLightThreshold_05) {
            return SFABlueLightThreshold_04;
        }
        else if (value > SFABlueLightThreshold_05) {
            return SFABlueLightThreshold_05;
        }
        else {
            return SFABlueLightThreshold_05;
        }
    }
    else {
        
    }
    return 0.0f;
}

/**********************************************************************************/

@end

@implementation SFABarGraphData

- (NSString *)description
{
    return [NSString stringWithFormat:@"barColor: %@    x: %f   yBase: %f   yTip: %f light: %f wristDetection: %d", _barColor == SFALightPlotBarColorAllLight ? @"orange" : @"blue" , _x, _yBase, _yTip, _light, _wristDetection];
}

@end
