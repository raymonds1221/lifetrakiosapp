//
//  LightDataPointEntity.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 9/13/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StatisticalDataHeaderEntity, StatisticalDataPointEntity;

@interface LightDataPointEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * blue;
@property (nonatomic, retain) NSDecimalNumber * blueLightCoeff;
@property (nonatomic, retain) NSNumber * dataPointID;
@property (nonatomic, retain) NSNumber * green;
@property (nonatomic, retain) NSDecimalNumber * greenLightCoeff;
@property (nonatomic, retain) NSNumber * integrationTime;
@property (nonatomic, retain) NSNumber * red;
@property (nonatomic, retain) NSDecimalNumber * redLightCoeff;
@property (nonatomic, retain) NSNumber * sensorGain;
@property (nonatomic, retain) StatisticalDataHeaderEntity *header;
@property (nonatomic, retain) StatisticalDataPointEntity *dataPoint;

@end
