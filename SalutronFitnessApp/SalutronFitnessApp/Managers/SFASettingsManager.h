//
//  SFASettingsManager.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFASettingsManager : NSObject

// Singleton Instance

+ (SFASettingsManager *)sharedManager;

// Instance Methods

- (void)settingsWithDictionary:(NSDictionary *)dictionary forDeviceEntity:(DeviceEntity *)device;

- (NSDictionary *)dictionary;

@end
