//
//  CalibrationData+Data.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "CalibrationDataEntity.h"

#import "CalibrationData+Data.h"
#import "DeviceEntity+Data.h"

@implementation CalibrationData (Data)

#pragma mark - Private Methods

- (NSString *)typeString
{
    if (self.type == 0) {
        return @"step";
    } else if (self.type == 1) {
        return @"walk";
    } else if (self.type == 2) {
        return @"run";
    }
    
    return @"step";
}

#pragma mark - Public Methods

+ (CalibrationData *)calibrationData
{
    DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
    return [CalibrationData calibrationDataWithCalibrationDataEntity:deviceEntity.calibrationData];
    
//    NSUserDefaults *userDefaults        = [NSUserDefaults standardUserDefaults];
//    NSData *data                        = [userDefaults objectForKey:CALIBRATION_DATA];
//    CalibrationData *calibrationData    = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    
//    return calibrationData;
}

+ (CalibrationData *)calibrationDataWithDictionary:(NSDictionary *)dictionary
{
    if ([dictionary isKindOfClass:[NSDictionary class]]) {
        NSString *typeString                = [dictionary objectForKey:API_DEVICE_SETTINGS_TYPE];
        NSString *calibStepString           = [dictionary objectForKey:API_DEVICE_SETTINGS_CALIB_STEP];
        NSString *calibWalkString           = [dictionary objectForKey:API_DEVICE_SETTINGS_CALIB_WALK];
        NSString *calibCalories             = [dictionary objectForKey:API_DEVICE_SETTINGS_CALIB_CALORIES];
        NSString *autoELString              = [dictionary objectForKey:API_DEVICE_SETTINGS_AUTO_EL];
        CalibrationData *calibrationData    = [[CalibrationData alloc] init];
        calibrationData.type                = [typeString characterAtIndex:0];
        calibrationData.calib_step          = (char)calibStepString.integerValue;
        calibrationData.calib_walk          = (char)calibWalkString.integerValue;
        calibrationData.calib_calo          = (char)calibCalories.integerValue;
        calibrationData.autoEL              = [autoELString characterAtIndex:0];
        NSData *data                        = [NSKeyedArchiver archivedDataWithRootObject:calibrationData];
        NSUserDefaults *userDefaults        = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:data forKey:CALIBRATION_DATA];
        
        return calibrationData;
    }
    
    return nil;
}

+ (CalibrationData *)calibrationDataWithCalibrationDataEntity:(CalibrationDataEntity *)entity
{
    CalibrationData *calibrationData    = [CalibrationData new];
    calibrationData.type                = (char)entity.type.integerValue;
    calibrationData.calib_step          = (char)entity.step.integerValue;
    calibrationData.calib_walk          = (signed char)entity.walk.integerValue;
    calibrationData.calib_run           = (signed char)entity.run.integerValue;
    calibrationData.autoEL              = entity.autoEL.boolValue;
    calibrationData.calib_calo          = entity.calories.integerValue;
    
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:calibrationData];
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:data forKey:CALIBRATION_DATA];
    
    return calibrationData;
}

- (NSDictionary *)dictionary
{
    NSDictionary *dictionary = @{API_DEVICE_SETTINGS_TYPE           : self.typeString,
                                 API_DEVICE_SETTINGS_CALIB_STEP     : @(self.calib_step),
                                 API_DEVICE_SETTINGS_CALIB_WALK     : @(self.calib_walk),
                                 API_DEVICE_SETTINGS_CALIB_RUN      : @(self.calib_run),
                                 API_DEVICE_SETTINGS_AUTO_EL        : @(self.autoEL),
                                 API_DEVICE_SETTINGS_CALIB_CALORIES : @(self.calib_calo)
                                 };
    
    return dictionary;
}


@end
