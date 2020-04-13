//
//  GoalsEntity+Data.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "GoalsEntity.h"

@interface GoalsEntity (Data)

+ (NSArray *)goalsEntitiesDictionaryForDeviceEntity:(DeviceEntity *)device;
+ (NSArray *)goalsEntitiesWithArray:(NSArray *)array forDeviceEnitity:(DeviceEntity *)device;

- (NSDictionary *)dictionary;

@end
