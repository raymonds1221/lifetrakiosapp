//
//  SFASalutronSyncCModel.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 1/27/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFASalutronSyncDelegate.h"

@interface SFASalutronSyncCModel : NSObject

+ (SFASalutronSyncCModel *)salutronSyncC300;
- (void)startSyncWithWatchModel:(WatchModel)watchModel;

@property (weak, nonatomic) id<SFASalutronSyncDelegate> delegate;

@end
