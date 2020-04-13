//
//  SFAHealthKitManager.h
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 1/23/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import "StatisticalDataHeaderEntity.h"

@protocol SFAHealthKitManagerDelegate;

@interface SFAHealthKitManager : NSObject

@property (strong, nonatomic) HKHealthStore *store;
@property (strong, nonatomic) id<SFAHealthKitManagerDelegate> delegate;
@property (strong, nonatomic) NSArray *statisticalDataHeaderEntities;
@property (strong, nonatomic) DeviceEntity *deviceEntity;
@property (strong, nonatomic) NSMutableArray *unfilteredData;
@property (strong, nonatomic) NSMutableArray *filteredData;
@property (strong, nonatomic) NSMutableArray *duplicateData;
@property (strong, nonatomic) NSMutableArray *duplicateWorkouts;
@property (strong, nonatomic) NSMutableArray *workouts;
@property (strong, nonatomic) NSMutableArray *duplicateSleepData;
@property (strong, nonatomic) NSMutableArray *sleepData;
@property (strong, nonatomic) NSMutableArray *sleepDataSamples;
@property (nonatomic) BOOL isHealthKitSyncOngoing;


+ (instancetype)sharedManager;

- (BOOL)isHealthKitAvailable;
- (void)requestAuthorizationWithSuccess:(void (^)(BOOL success))success
                                failure:(void (^)(NSError *error))failure;

- (NSDate *)getDateOfBirth;
- (int)getBiologicalSex;
//in meters
- (void)getHeightWithSuccess:(void (^)(double height))success
                     failure:(void (^)(NSError *error))failure;
//in grams
- (void)getWeightWithSuccess:(void (^)(double weight))success
                     failure:(void (^)(NSError *error))failure;
//in meters
- (void)saveHeight:(double)height;
//in pounds
- (void)saveWeight:(double)weight;

//- (BOOL)isHealthKitEnabled;

//save quantity type objects
/*
- (void)saveQuantityTypeIdentifier:(NSString *)identifier
                         withValue:(double)value
                          withUnit:(HKUnit *)unit
                     withStartDate:(NSDate *)startDate
                        andEndDate:(NSDate *)endDate;
*/
- (void)saveQuantityTypeIdentifier:(NSString *)identifier
                         withValue:(double)value
                          withUnit:(HKUnit *)unit
                     withStartDate:(NSDate *)startDate
                        andEndDate:(NSDate *)endDate
                       withSuccess:(void (^)(BOOL success))success;
- (void)saveAllDataToHealthStoreFromDataHeaders:(NSArray *)dataHeaderEntities;
//- (void)saveDataHeadersEntityToHealthStore:(NSArray *)statisticalDataHeaderEntities withPosition:(int)position andHealthData:(NSMutableArray *)healthData;
- (void)saveDataHeadersEntitiesToHealthStore;
- (void)addSleepAndWorkoutToHealthStoreWithWorkoutEntitities:(NSArray *)workouts andSleepLogs:(NSArray *)sleepLogs;
- (void)addSleepLogsToHealthStoreWithArray:(NSArray *)sleepLogs;

//- (void)saveDataToHealthStoreFromStatisticalDataHeaderEntity:(StatisticalDataHeaderEntity *)statisticalDataHeaderEntity;

//- (void)saveDataPerHourToHealthStoreFromStatisticalDataHeaderEntity:(StatisticalDataHeaderEntity *)statisticalDataHeaderEntity;
//- (void)updateObjectsForDate:(NSDate *)date withIdentifier:(NSString *)identifier withHealthData:(NSMutableArray *)healthData;
//- (void)addWorkoutsToHealthStoreWithWorkoutInfoEntities:(NSArray *)workouts;
/*
- (void)saveAllDataToHealthStoreFromDeviceEntity:(DeviceEntity *)deviceEntity;
- (void)saveAllDataToHealthStoreFromDeviceEntity:(DeviceEntity *)deviceEntity withDataHeaders:(NSArray *)dataHeaderEntities;
*/
@end

@protocol SFAHealthKitManagerDelegate <NSObject>

@optional
- (void)failedSavingQuantityType:(NSString *)identifier;
- (void)syncingToHealthKitFinished;


@end
