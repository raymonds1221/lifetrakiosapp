//
//  TimeEntity.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/21/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StatisticalDataHeaderEntity;

@interface TimeEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * endHour;
@property (nonatomic, retain) NSNumber * endMinute;
@property (nonatomic, retain) NSNumber * endSecond;
@property (nonatomic, retain) NSNumber * startHour;
@property (nonatomic, retain) NSNumber * startMinute;
@property (nonatomic, retain) NSNumber * startSecond;
@property (nonatomic, retain) StatisticalDataHeaderEntity *header;

@end
