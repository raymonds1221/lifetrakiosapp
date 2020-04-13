//
//  LightDataPointEntity+GraphData.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 8/27/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//



#import "LightDataPointEntity.h"

@interface LightDataPointEntity (GraphData)

/*
 * (SFALightColorRed)    RedLight     = red   + redLightCoefficient
 * (SFALightColorGreen)  GreenLight   = green + greenLightCoefficient
 * (SFALightColorBlue)   BlueLight    = blue  + blueLightCoefficient
 */

- (CGFloat)allLux;

- (CGFloat)redLux;

- (CGFloat)greenLux;

- (CGFloat)blueLux;

// Array of SFABarGraphData
+ (NSArray *)getDailyLightBarGraphDataForDate:(NSDate *)date
                         lightDataPointsArray:(NSArray *__autoreleasing *)lightDataPointsArray;

// Array of dictionaries where key is the header.date.day of the week
// and the object is an array of SFABarGraphData for that day

+ (NSArray *)getWeeklyLightBarGraphDataForWeek:(NSInteger)week
                                             ofYear:(NSInteger)year
                                         lightColor:(SFALightColor)lightColor;

+ (NSArray *)getMonthlyLightBarGraphDataForMonth:(NSInteger)month
                                         ofYear:(NSInteger)year
                                     lightColor:(SFALightColor)lightColor;

+ (NSArray *)getYearlyLightBarGraphDataForYear:(NSInteger)year
                                    lightColor:(SFALightColor)lightColor;


+ (CGFloat)getMaxYTipValueForLightBarGraphDataArray:(NSArray *)barGraphDataArray;
/*
 * Sum of (Blue, Red, Green or All) light values
 */
+ (CGFloat)totalComputedLightForLightDataPointEntitiesArray:(NSArray *)lightDataPointArray
                                                 lightColor:(SFALightColor)lightColor;

@end

@interface SFABarGraphData : NSObject

@property (assign, nonatomic) float x;
@property (assign, nonatomic) float yBase;
@property (assign, nonatomic) float yTip;
@property (assign, nonatomic) float yBaseLog;
@property (assign, nonatomic) float yTipLog;
@property (assign, nonatomic) SFALightPlotBarColor barColor;
@property (assign, nonatomic) float light;
@property (assign, nonatomic) float threshold;
@property (assign, nonatomic) BOOL wristDetection;

@end
