//
//  SFAProfileServerSyncCell.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/16/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceEntity;

@interface SFAProfileServerSyncCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *serverLastSync;

- (void)setContentsWithMacAddress:(NSString *)macAddress;

- (void)setContentsWithDeviceEntity:(DeviceEntity *)device;

@end
