//
//  SFALightDataManager.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 9/20/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFALightDataManager : NSObject

+ (int)getTotalExposureTime:(NSArray *)arrayOfEntities;
+ (int)getExposureTimeDuration:(NSArray *)arrayOfEntities;

/*
 * SFALightColorBlue <   250 = Artificial Light, >=  250 = Ambient
 * SFALightColorAll  <   500 = Artificial Light, >=  500 = Ambient
 */
+ (BOOL)isAmbientLight:(float)light lightColor:(SFALightColor)lightColor;

@end
