//
//  SFASalutronR420ModelSync.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/3/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFASalutronSync.h"

@protocol SFASalutronSyncDelegate;

@interface SFASalutronR420ModelSync : SFASalutronSync <SalutronSDKDelegate>

- (void)searchDevice;
- (void)syncData;

- (void)useAppSettingsWithDelegate:(id)delegate;
- (void)useWatchSettingsWithDelegate:(id)delegate;

@end