//
//  CalibrationData+CalibrationDataCategory.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/18/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "CalibrationData+CalibrationDataCategory.h"
#import "SFASalutronFitnessAppDelegate.h"

@implementation CalibrationData (CalibrationDataCategory)

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init]) {
        self.type = [aDecoder       decodeIntForKey:TYPE];
        self.calib_step = [aDecoder decodeIntForKey:CALIB_STEP];
        self.calib_walk = [aDecoder decodeIntForKey:CALIB_WALK];
        self.calib_run = [aDecoder  decodeIntForKey:CALIB_RUN];
        self.calib_calo = [aDecoder decodeIntForKey:CALIB_CALO];
        self.autoEL = [aDecoder     decodeIntForKey:AUTO_EL];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self.type         forKey:TYPE];
    [aCoder encodeInt:self.calib_step   forKey:CALIB_STEP];
    [aCoder encodeInt:self.calib_walk   forKey:CALIB_WALK];
    [aCoder encodeInt:self.calib_run    forKey:CALIB_RUN];
    [aCoder encodeInt:self.calib_calo   forKey:CALIB_CALO];
    [aCoder encodeInt:self.autoEL       forKey:AUTO_EL];
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    [copy setType:self.type];
    [copy setCalib_step:self.calib_step];
    [copy setCalib_walk:self.calib_walk];
    [copy setCalib_run:self.calib_run];
    [copy setCalib_calo:self.calib_calo];
    [copy setAutoEL:self.autoEL];
    
    return copy;
}

@end
