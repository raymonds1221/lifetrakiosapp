//
//  StatisticalDataHeaderEntity.m
//  SalutronFitnessApp
//
//  Created by Patricia Marie Cesar on 11/28/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "StatisticalDataHeaderEntity.h"
#import "DateEntity.h"
#import "DeviceEntity.h"
#import "LightDataPointEntity.h"
#import "StatisticalDataPointEntity.h"
#import "TimeEntity.h"


@implementation StatisticalDataHeaderEntity

@dynamic allocationBlockIndex;
@dynamic dateInNSDate;
@dynamic maxHR;
@dynamic minHR;
@dynamic totalCalorie;
@dynamic totalDistance;
@dynamic totalExposureTime;
@dynamic totalSleep;
@dynamic totalSteps;
@dynamic isSyncedToServer;
@dynamic dataPoint;
@dynamic date;
@dynamic device;
@dynamic lightDataPoint;
@dynamic time;

@end
