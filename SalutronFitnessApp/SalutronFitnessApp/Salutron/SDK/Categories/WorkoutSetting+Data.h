//
//  WorkoutSetting+Data.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/10/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import "WorkoutSetting.h"

@interface WorkoutSetting (Data)

+ (WorkoutSetting *)workoutSettingWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionary;

@end
