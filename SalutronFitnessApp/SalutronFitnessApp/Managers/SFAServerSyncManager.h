//
//  SFAServerSyncManager.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/7/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DeviceEntity;

@interface SFAServerSyncManager : NSObject

// Singleton Instance

+ (SFAServerSyncManager *)sharedManager;

// Instance Methods

- (NSOperation *)syncDeviceEntity:(DeviceEntity *)deviceEntity
             withSuccess:(void (^)(NSString *macAddress))success
                 failure:(void (^)(NSError *error))failure;

- (NSOperation *)syncDeviceEntityWithParameters:(NSDictionary *)parameters
                                    withSuccess:(void (^)(NSString *macAddress))success
                                        failure:(void (^)(NSError *error))failure;

- (NSOperation *)syncDeviceEntityWithParametersAPIV2:(NSDictionary *)parameters
                                         withSuccess:(void (^)(NSString *macAddress))success
                                             failure:(void (^)(NSError *error))failure;

- (NSOperation *)syncDeviceEntity:(DeviceEntity *)deviceEntity
						startDate:(NSDate *)startDate
						  endDate:(NSDate *)endDate
					  withSuccess:(void (^)(NSString *macAddress))success
						  failure:(void (^)(NSError *error))failure;

- (NSOperation *)storeWithMacAddress:(NSString *)macAddress
                    success:(void (^)())success
                    failure:(void (^)(NSError *error))failure;

- (void)deleteWithMacAddress:(NSString *)macAddress
                     success:(void (^)())success
                     failure:(void (^)(NSError *error))failure;

- (void)getDevicesWithSuccess:(void (^)(NSArray *deviceEntities))success
                      failure:(void (^)(NSError *error))failure;

- (void)restoreDeviceEntity:(DeviceEntity *)deviceEntity
				  startDate:(NSDate *)startDate
					endDate:(NSDate *)endDate
					success:(void (^)())success
					failure:(void (^)(NSError *))failure;

/*
- (NSOperation *)syncDeviceEntity:(DeviceEntity *)deviceEntity
						startDate:(NSDate *)startDate
						  endDate:(NSDate *)endDate
					  withSuccess:(void (^)(NSString *macAddress))success
						  failure:(void (^)(NSError *error))failure;
*/

- (void)restoreDeviceEntity:(DeviceEntity *)deviceEntity
                    success:(void (^)())success
                    failure:(void (^)(NSError *error))failure;


- (void)restoreDeviceEntityAPIV2:(DeviceEntity *)deviceEntity
                         success:(void (^)(NSDictionary *response))success
                         failure:(void (^)(NSError *error))failure;


- (void)restoreDeviceEntity:(DeviceEntity *)deviceEntity
            startDateString:(NSString *)startDate
              endDateString:(NSString *)endDate
                    success:(void (^)())success
                    failure:(void (^)(NSError *))failure;

- (void)restoreDeviceEntityAPIV2:(DeviceEntity *)deviceEntity
                 startDateString:(NSString *)startDate
                   endDateString:(NSString *)endDate
                         success:(void (^)(NSDictionary *response))success
                         failure:(void (^)(NSError *error))failure;

- (void)getDeviceDataFromServerWithDevice:(DeviceEntity *)deviceEntity
                                   userID:(NSString *)startDate
                                  success:(void (^)(BOOL shouldRestoreFromServer))success
                                  failure:(void (^)(NSError *error))failure;
- (NSString *)jsonStringWithDeviceEntity:(DeviceEntity *)device;

- (NSArray *)jsonStringWithDeviceEntityForMultipleDays:(DeviceEntity *)device;

- (void)convertResult:(NSDictionary *)result forDeviceEntity:(DeviceEntity *)deviceEntity;
- (void)convertResultPerDay:(NSDictionary *)result forDeviceEntity:(DeviceEntity *)deviceEntity isLastDay:(BOOL)isLastDay;

- (void)cancelOperation;

@end
