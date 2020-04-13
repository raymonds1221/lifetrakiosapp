//
//  StatisticalDataPointEntity.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 9/13/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LightDataPointEntity, StatisticalDataHeaderEntity;

@interface StatisticalDataPointEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * averageHR;
@property (nonatomic, retain) NSNumber * axisDirection;
@property (nonatomic, retain) NSNumber * axisMagnitude;
@property (nonatomic, retain) NSNumber * bleStatus;
@property (nonatomic, retain) NSNumber * calorie;
@property (nonatomic, retain) NSNumber * dataPointID;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * dominantAxis;
@property (nonatomic, retain) NSNumber * lux;
@property (nonatomic, retain) NSNumber * sleepPoint02;
@property (nonatomic, retain) NSNumber * sleepPoint24;
@property (nonatomic, retain) NSNumber * sleepPoint46;
@property (nonatomic, retain) NSNumber * sleepPoint68;
@property (nonatomic, retain) NSNumber * sleepPoint810;
@property (nonatomic, retain) NSNumber * steps;
@property (nonatomic, retain) NSNumber * wristDetection;
@property (nonatomic, retain) StatisticalDataHeaderEntity *header;
@property (nonatomic, retain) LightDataPointEntity *lightDataPoint;

@end
