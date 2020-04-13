//
//  InactiveAlert+Entity.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 3/19/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "InactiveAlert.h"
#import "InactiveAlertEntity+Data.h"

@interface InactiveAlert (Entity)

- (instancetype)initWithEntity:(InactiveAlertEntity *)inactivityAlertEntity;

@end
