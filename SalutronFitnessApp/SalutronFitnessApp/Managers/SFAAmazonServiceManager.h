//
//  SFAAmazonServiceManager.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 10/6/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceEntity.h"

@protocol SFAAmazonServiceManagerDelegate <NSObject>

- (void)amazonServiceUploadFinishedWithParameters:(NSDictionary *)parameters;

- (void)amazonServiceUploadFailedWithError:(NSError *)error;



- (void)amazonServiceDownloadFinishedWithParameters:(NSDictionary *)parameters;

- (void)amazonServiceDownloadFailedWithError:(NSError *)error;

- (void)amazonServiceProgress:(int)progress;

@end

@interface SFAAmazonServiceManager : NSObject

@property id<SFAAmazonServiceManagerDelegate> delegate;

+ (SFAAmazonServiceManager *)sharedManager;

- (void)uploadDataToS3:(NSString *)stringData;
- (void)uploadArrayOfDataToS3:(NSArray *)dataArray;
- (void)downloadDataFromS3withBucketName:(NSString *)bucketName andFilesNames:(NSArray *)fileNames andFolderName:(NSString *)folderName andDeviceEntity:(DeviceEntity *)deviceEntity;
- (void)cancelOperation;

@end
