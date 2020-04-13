//
//  SFAHealthKitManager.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 1/23/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAHealthKitManager.h"
#import "NSDate+Format.h"

#import "StatisticalDataHeaderEntity.h"
#import "StatisticalDataPointEntity.h"
#import "StatisticalDataPointEntity+Data.h"
#import "DateEntity.h"
#import "HKUnit+Custom.h"
#import "WorkoutInfoEntity.h"
#import "WorkoutInfoEntity+Data.h"
#import "WorkoutStopDatabaseEntity.h"
#import "SleepDatabaseEntity.h"
#import "SleepDatabaseEntity+Data.h"
#import "DeviceEntity.h"
#import "StatisticalDataHeaderEntity+Data.h"
#import "WorkoutHeaderEntity.h"

@implementation SFAHealthKitManager

+ (SFAHealthKitManager *)sharedManager
{
    static SFAHealthKitManager *instance = nil;
    
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

- (HKHealthStore *)store{
    if (!_store) {
        _store = [[HKHealthStore alloc] init];
        self.isHealthKitSyncOngoing = NO;
    }
    return _store;
}

- (BOOL)isHealthKitAvailable{
    return (NSClassFromString(@"HKHealthStore") && [HKHealthStore isHealthDataAvailable]);
}
/*
- (BOOL)isHealthKitEnabled{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"HealthKitEnabled"]) {
        NSNumber *enabled = [[NSUserDefaults standardUserDefaults] objectForKey:@"HealthKitEnabled"];
        return enabled.boolValue;
    }
    return YES;
}
*/

//Ask authorization from Health App to access and and share data
- (void)requestAuthorizationWithSuccess:(void (^)(BOOL success))success
                                failure:(void (^)(NSError *error))failure{
    // Share body mass, height and body mass index
    NSSet *shareObjectTypes;
    
    /*
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    WatchModel watchModel           = [[userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
    if (watchModel == WatchModel_Move_C300 || watchModel == WatchModel_Move_C300_Android)
    {
        shareObjectTypes  = [NSSet setWithObjects:
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned],
                             nil];
    }
    else
    {*/
        shareObjectTypes  = [NSSet setWithObjects:
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned],
                             [HKObjectType workoutType],
                             [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis],
                             nil];
    //}
    
    // Read date of birth, biological sex and step count
    //Will be implemented in next release
   /*
    NSSet *readObjectTypes  = [NSSet setWithObjects:
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                               nil];
    */
    // Request access
    [self.store requestAuthorizationToShareTypes:shareObjectTypes
                                        readTypes:nil//readObjectTypes
                                       completion:^(BOOL successful, NSError *error) {
                                           
                                           if(successful == YES)
                                           {
                                               success(successful);
                                               [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"HealthKitEnabled"];
                                               [[NSUserDefaults standardUserDefaults] synchronize];
                                           }
                                           else
                                           {
                                               [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"HealthKitEnabled"];
                                               [[NSUserDefaults standardUserDefaults] synchronize];
                                               failure(error);
                                               // Determine if it was an error or if the
                                               // user just canceld the authorization request
                                           }
                                           
                                       }];
}

//Get basic data for user profile
- (int)getBiologicalSex{
    NSError *error;
    HKBiologicalSexObject *bioSex = [self.store biologicalSexWithError:&error];
    return bioSex.biologicalSex;
}

- (NSDate *)getDateOfBirth{
    NSError *error;
    NSDate *dateOfBirth = [self.store dateOfBirthWithError:&error];
    //1992-11-15 16:00:00 +0000
    dateOfBirth = [NSDate dateFromString:[NSString stringWithFormat:@"%@", dateOfBirth] withFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    return dateOfBirth;
}

- (void)getHeightWithSuccess:(void (^)(double height))success
                       failure:(void (^)(NSError *error))failure{

    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:heightType predicate:nil limit:1 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            //error fetching or no data stored yet
            failure(error);
        }
        
        if (results) {
            // If quantity isn't in the database, return nil in the completion block.
            HKQuantitySample *quantitySample = results.firstObject;
            HKQuantity *quantity = quantitySample.quantity;
            HKUnit *heightUnit = [HKUnit meterUnit];
            double usersHeight = [quantity doubleValueForUnit:heightUnit];
            success(usersHeight);
        }
    }];
    
    [self.store executeQuery:query];
}

- (void)getWeightWithSuccess:(void (^)(double weight))success
                     failure:(void (^)(NSError *error))failure{
    
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:weightType predicate:nil limit:1 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            //error fetching or no data stored yet
            failure(error);
        }
        
        if (results) {
            // If quantity isn't in the database, return nil in the completion block.
            HKQuantitySample *quantitySample = results.firstObject;
            HKQuantity *quantity = quantitySample.quantity;
            HKUnit *weightUnit = [HKUnit gramUnit];
            double usersWeight = [quantity doubleValueForUnit:weightUnit];
            success(usersWeight);
        }
    }];
    
    [self.store executeQuery:query];
}

//Save basic data from LifeTrak user profile
- (void)saveHeight:(double) height{
    // Save the user's height into HealthKit.
    HKUnit *meterUnit = [HKUnit meterUnit];
    HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:meterUnit doubleValue:height];
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    NSDate *now = [NSDate date];
    
    HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType:heightType quantity:heightQuantity startDate:now endDate:now];
    
    [self getHeightWithSuccess:^(double oldHeight) {
        if (oldHeight != height) {
            [self.store saveObject:heightSample withCompletion:^(BOOL success1, NSError *error) {
                if (!success1) {
                    DDLogInfo(@"An error occured saving the height sample %@. In your app, try to handle this gracefully. The error was: %@.", heightSample, error);
                    //abort();
                }
            }];

        }
    } failure:^(NSError *error) {
        [self.store saveObject:heightSample withCompletion:^(BOOL success1, NSError *error) {
            if (!success1) {
                DDLogInfo(@"An error occured saving the height sample %@. In your app, try to handle this gracefully. The error was: %@.", heightSample, error);
                //abort();
            }
        }];
    }];
    
   
}

- (void)saveWeight:(double)weight{
    HKUnit *gramUnit = [HKUnit gramUnit];
    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:gramUnit doubleValue:weight*1000];
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    NSDate *now = [NSDate date];
    
    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:now endDate:now];
    
    [self getWeightWithSuccess:^(double oldWeight) {
        if (oldWeight != weight*1000) {
            [self.store saveObject:weightSample withCompletion:^(BOOL success1, NSError *error) {
                if (!success1) {
                    DDLogInfo(@"An error occured saving the weight sample %@. In your app, try to handle this gracefully. The error was: %@.", weightSample, error);
                    //abort();
                }
            }];
            
        }
    } failure:^(NSError *error) {
        [self.store saveObject:weightSample withCompletion:^(BOOL success1, NSError *error) {
            if (!success1) {
                DDLogInfo(@"An error occured saving the weight sample %@. In your app, try to handle this gracefully. The error was: %@.", weightSample, error);
                //abort();
            }
        }];
    }];
}

//Generic Function for saving a Quantity Sample
- (void)saveQuantityTypeIdentifier:(NSString *)identifier
                         withValue:(double)value
                          withUnit:(HKUnit *)unit
                     withStartDate:(NSDate *)startDate
                        andEndDate:(NSDate *)endDate
                       withSuccess:(void (^)(BOOL success))success{
    HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:value];
    
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:identifier];
    
    HKQuantitySample *quantitySample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:startDate endDate:endDate];
    
    [self.store saveObject:quantitySample withCompletion:^(BOOL success1, NSError *error) {
        if (!success1) {
            success(success1);
            DDLogInfo(@"An error occured saving the sample %@. In your app, try to handle this gracefully. The error was: %@.", quantitySample, error);
            //abort();
        }
        success(success1);
    }];
    
}


/* * * * * * * * * * * * * * * * * * * * * * * * * */
//      STEPS, CALORIES, DISTANCE, HEART RATE       /
/* * * * * * * * * * * * * * * * * * * * * * * * * */

//Generic Function for creating a Quantity Sample
- (HKQuantitySample *)createQuantitySampleOfTypeIdentifier:(NSString *)identifier
                                                 withValue:(double)value
                                                  withUnit:(HKUnit *)unit
                                             withStartDate:(NSDate *)startDate
                                                andEndDate:(NSDate *)endDate
                                             andWatchName:(NSString *)watchName{
    HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:value];
    
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:identifier];
    
    HKQuantitySample *quantitySample;
    if (watchName) {
        quantitySample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:startDate endDate:endDate metadata:@{@"Watch Name" : watchName}];
    }
    else{
        quantitySample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:startDate endDate:endDate];
    }
    return quantitySample;
}


/* * * * * * * * * * */
//     ALL DATA       /
/* * * * * * * * * * */
//Used for sign in
//For sign up and dashboard
- (void)saveAllDataToHealthStoreFromDataHeaders:(NSArray *)statisticalDataHeaderEntities{
    DDLogInfo(@"");
   // NSMutableArray *healthData = [[NSMutableArray alloc] init];
    self.statisticalDataHeaderEntities = statisticalDataHeaderEntities;
    if (statisticalDataHeaderEntities.count > 0) {
        self.isHealthKitSyncOngoing = YES;
        [[SFAHealthKitManager sharedManager] saveDataHeadersEntitiesToHealthStore];
    }
   // [[SFAHealthKitManager sharedManager] saveDataHeadersEntitiesToHealthStore];
    //:dataHeaderEntities/* withPosition:0 andHealthData:healthData*/];
}

- (void)saveDataHeadersEntitiesToHealthStore{//:(NSArray *)statisticalDataHeaderEntities/* withPosition:(int)position andHealthData:(NSMutableArray *)healthData*/{
    
    //DDLogInfo(@"");
    static int position;
    static NSMutableArray *healthData;
    if (position == 0) {
        healthData = [[NSMutableArray alloc] init];
    }
    StatisticalDataHeaderEntity *statisticalDataHeaderEntity = [self.statisticalDataHeaderEntities objectAtIndex:position];
    NSMutableArray *dataPoints = [[StatisticalDataPointEntity dataPointsForDate:statisticalDataHeaderEntity.dateInNSDate] mutableCopy];
    //[statisticalDataHeaderEntity.dataPoint allObjects];
    NSArray *activeTimeIndexes = [self getActiveTimeIndexesForDateHeader:statisticalDataHeaderEntity];
    int index = 0;
    int currentIndex = index/6;
    int caloriesForHour = 0;
    int restingCaloriesForHour = 0;
    int distanceForHour = 0;
    int heartRateForHour = 0;
    int stepsForHour = 0;
    int newIndex = index/6;
    
    
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    WatchModel watchModel           = [[userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
    if (watchModel == WatchModel_R420) {
        NSArray *continuousHR = [WorkoutHeaderEntity getWorkoutHeartRateWithMinMaxDataWithDate:statisticalDataHeaderEntity.dateInNSDate];
        
        //group hr per 10 mins
        int totalHR = 0;
        int totalCount = 0;
        NSInteger datapointIndex = [[[continuousHR firstObject] objectForKey:@"index"] integerValue]/600;
        for (NSDictionary *hrEntity in continuousHR) {
            
            NSInteger hrValue = [hrEntity[@"hrData"] integerValue];
            NSInteger index = [hrEntity[@"index"] integerValue];
            
            if (hrValue > 0) {
                if (datapointIndex == index/600) {
                    totalHR += hrValue;
                    totalCount++;
                    if ([hrEntity isEqual:[continuousHR lastObject]]) {
                        //save avg hr
                        NSInteger averageHR = totalHR/totalCount;
                        if (datapointIndex >= dataPoints.count) {
                            datapointIndex = dataPoints.count - 1;
                        }
                        StatisticalDataPointEntity *dataPointEntity = dataPoints[datapointIndex];
                        dataPointEntity.averageHR = @(averageHR);
                        [dataPoints replaceObjectAtIndex:datapointIndex withObject:dataPointEntity];
                    }
                }
                else{
                    //save avg hr
                    NSInteger averageHR = totalHR/totalCount;
                    if (datapointIndex >= dataPoints.count) {
                        datapointIndex = dataPoints.count - 1;
                    }
                    StatisticalDataPointEntity *dataPointEntity = dataPoints[datapointIndex];
                    dataPointEntity.averageHR = @(averageHR);
                    [dataPoints replaceObjectAtIndex:datapointIndex withObject:dataPointEntity];
                    
                    //next index
                    datapointIndex = index/600;
                    totalCount = 0;
                    totalHR = 0;
                    totalHR += hrValue;
                    totalCount++;
                    
                    if ([hrEntity isEqual:[continuousHR lastObject]]) {
                        //save avg hr
                        NSInteger averageHR = totalHR/totalCount;
                        if (datapointIndex >= dataPoints.count) {
                            datapointIndex = dataPoints.count - 1;
                        }
                        StatisticalDataPointEntity *dataPointEntity = dataPoints[datapointIndex];
                        dataPointEntity.averageHR = @(averageHR);
                        [dataPoints replaceObjectAtIndex:datapointIndex withObject:dataPointEntity];
                    }
                }
            }
            else{
                if ([hrEntity isEqual:[continuousHR lastObject]]) {
                    //save avg hr
                    NSInteger averageHR = totalHR/totalCount;
                    if (averageHR > 0) {
                        if (datapointIndex >= dataPoints.count) {
                            datapointIndex = dataPoints.count - 1;
                        }
                        StatisticalDataPointEntity *dataPointEntity = dataPoints[datapointIndex];
                        dataPointEntity.averageHR = @(averageHR);
                        [dataPoints replaceObjectAtIndex:datapointIndex withObject:dataPointEntity];
                    }
                }
            }
        }
        }
    
    
    
    
    
    for (StatisticalDataPointEntity *dataPoint in dataPoints) {
        //if ([dataPoint isEqual:[dataPoints lastObject]] && dataPoints.count % 6 != 0){
        //    newIndex++;
        //}
        if (/*(newIndex == 0 && index == 5) || */newIndex > currentIndex || (newIndex == currentIndex && [dataPoint isEqual:[dataPoints lastObject]])/* || ([dataPoint isEqual:[dataPoints lastObject]] && newIndex < 24)*/) {
 //           if (([dataPoint isEqual:[dataPoints lastObject]] && newIndex == 23)) {
 //               newIndex++;
 //           }
            
            //  else if ([dataPoint isEqual:[dataPoints lastObject]] && dataPoints.count % 6 != 0){
            //      newIndex++;
            //  }
            // else{
            if (newIndex == currentIndex && [dataPoint isEqual:[dataPoints lastObject]]) {
                stepsForHour += dataPoint.steps.integerValue;
                distanceForHour += dataPoint.distance.doubleValue*1000;
                if(dataPoint.averageHR.intValue > 0){
                    if (heartRateForHour > 0) {
                        heartRateForHour = heartRateForHour + dataPoint.averageHR.intValue;
                        heartRateForHour = heartRateForHour/2;
                    }
                    else{
                        heartRateForHour = dataPoint.averageHR.intValue;
                    }
                }
                if([activeTimeIndexes containsObject:@(index)]){
                    caloriesForHour += dataPoint.calorie.intValue;
                }
                else{
                    restingCaloriesForHour += dataPoint.calorie.intValue;
                }
            }
            
            NSCalendar *calendar                    = [NSCalendar currentCalendar];
            NSDateComponents *components            = [NSDateComponents new];
            components.month                        = statisticalDataHeaderEntity.date.month.integerValue;
            components.day                          = statisticalDataHeaderEntity.date.day.integerValue;
            components.year                         = statisticalDataHeaderEntity.date.year.integerValue + 1900;
            components.hour                         = currentIndex;
            components.minute                       = 0;
            NSDate *startDate                       = [calendar dateFromComponents:components];
            
            NSDateComponents *components2            = [NSDateComponents new];
            components2.month                        = statisticalDataHeaderEntity.date.month.integerValue;
            components2.day                          = statisticalDataHeaderEntity.date.day.integerValue;
            components2.year                         = statisticalDataHeaderEntity.date.year.integerValue + 1900;
            components2.hour                         = currentIndex+1;
            components2.minute                       = 0;
            NSDate *endDate                          = [calendar dateFromComponents:components2];
            
            if(stepsForHour > 0){
            HKQuantitySample *stepsQuantitySample = [self createQuantitySampleOfTypeIdentifier:HKQuantityTypeIdentifierStepCount withValue:stepsForHour withUnit:[HKUnit countUnit] withStartDate:startDate andEndDate:endDate andWatchName:statisticalDataHeaderEntity.device.name];
            [healthData addObject:stepsQuantitySample];
            }
            
            if(distanceForHour > 0){
            HKQuantitySample *distanceQuantitySample = [self createQuantitySampleOfTypeIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning withValue:distanceForHour withUnit:[HKUnit meterUnit] withStartDate:startDate andEndDate:endDate andWatchName:statisticalDataHeaderEntity.device.name];
            [healthData addObject:distanceQuantitySample];
            }
            
            if(caloriesForHour > 0){
                HKQuantitySample *caloriesQuantitySample = [self createQuantitySampleOfTypeIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned withValue:caloriesForHour withUnit:[HKUnit kilocalorieUnit] withStartDate:startDate andEndDate:endDate andWatchName:statisticalDataHeaderEntity.device.name];
                [healthData addObject:caloriesQuantitySample];
            }
            
            if(restingCaloriesForHour > 0){
                HKQuantitySample *restingCaloriesQuantitySample = [self createQuantitySampleOfTypeIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned withValue:restingCaloriesForHour withUnit:[HKUnit kilocalorieUnit] withStartDate:startDate andEndDate:endDate andWatchName:statisticalDataHeaderEntity.device.name];
                [healthData addObject:restingCaloriesQuantitySample];
            }
            
            if (heartRateForHour > 0) {
                HKQuantitySample *heartRateQuantitySample = [self createQuantitySampleOfTypeIdentifier:HKQuantityTypeIdentifierHeartRate withValue:heartRateForHour withUnit:[HKUnit heartBeatsPerMinuteUnit] withStartDate:startDate andEndDate:endDate andWatchName:statisticalDataHeaderEntity.device.name];
                [healthData addObject:heartRateQuantitySample];
            }
            
            //  }
            currentIndex = newIndex;
            caloriesForHour = 0;
            restingCaloriesForHour = 0;
            distanceForHour = 0;
            heartRateForHour = 0;
            stepsForHour = 0;
        }
        
        stepsForHour += dataPoint.steps.integerValue;
        distanceForHour += dataPoint.distance.doubleValue*1000;
        if(dataPoint.averageHR.intValue > 0){
            if (heartRateForHour > 0) {
                heartRateForHour = heartRateForHour + dataPoint.averageHR.intValue;
                heartRateForHour = heartRateForHour/2;
            }
            else{
                heartRateForHour = dataPoint.averageHR.intValue;
            }
        }
        if([activeTimeIndexes containsObject:@(index)]){
            caloriesForHour += dataPoint.calorie.intValue;
        }
        else{
            restingCaloriesForHour += dataPoint.calorie.intValue;
        }
        
        index++;
        newIndex = index/6;
    }
    
    //Update/Save sample quantity
    if (position == self.statisticalDataHeaderEntities.count - 1) {
        if (healthData.count > 0) {
            //NSMutableArray *duplicateHealthData = [[NSMutableArray alloc] init];
            position = 0;
            self.deviceEntity = statisticalDataHeaderEntity.device;
            self.unfilteredData = healthData;
            [self updateDataByFilteringDuplicate];//GettingDuplicateDataInArray:healthData /*atIndex:0 andAddToDuplicatesArray:duplicateHealthData andUseFilteredData:healthData]; withDeviceEntity:statisticalDataHeaderEntity.device*/];
        }
        else{
            DDLogInfo(@"Saving data to health store successful");
            position = 0;
            NSArray *sleepLogs = [SleepDatabaseEntity sleepDatabaseForDeviceEntity:self.deviceEntity];
            NSArray *workouts = [[NSArray alloc] init];
            NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
            WatchModel watchModel           = [[userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
            if (watchModel == WatchModel_R420) {
                workouts = [self.deviceEntity.workoutHeader allObjects];
                NSMutableArray *tempWorkouts = [workouts mutableCopy];
                for (WorkoutHeaderEntity *workoutHeader in workouts) {
                    NSDate *startTime = [self getStartTimeOfWorkoutHeader:workoutHeader];
                    NSDate *endTime = [self getEndTimeOfWorkoutHeader:workoutHeader];
                    if ([startTime compare:endTime] == NSOrderedDescending) {
                        [tempWorkouts removeObject:workoutHeader];
                    }
                }
                workouts = [tempWorkouts copy];
            }
            else{
                workouts = [self.deviceEntity.workout allObjects];
                NSMutableArray *tempWorkouts = [workouts mutableCopy];
                for (WorkoutInfoEntity *workoutInfo in workouts) {
                    NSDate *startTime = [self getStartTimeOfWorkout:workoutInfo];
                    NSDate *endTime = [self getEndTimeOfWorkout:workoutInfo];
                    if ([startTime compare:endTime] == NSOrderedDescending) {
                        [tempWorkouts removeObject:workoutInfo];
                    }
                }
                workouts = [tempWorkouts copy];
            }
            
            [[SFAHealthKitManager sharedManager] addSleepAndWorkoutToHealthStoreWithWorkoutEntitities:workouts andSleepLogs:sleepLogs];
        }
    }
    else{
        position++;
        [[SFAHealthKitManager sharedManager] saveDataHeadersEntitiesToHealthStore];//:statisticalDataHeaderEntities /*withPosition:position+1 andHealthData:healthData*/];
    }
}


- (void)updateDataByFilteringDuplicate{//GettingDuplicateDataInArray:(NSMutableArray *)healthData{
                             //atIndex:(int)index
             //andAddToDuplicatesArray:(NSMutableArray *)duplicatesArray
                             //andUseFilteredData:(NSMutableArray *)filteredData{
                               //withDeviceEntity:(DeviceEntity *)deviceEntity{
    //DDLogInfo(@"");
    static int index;
    static NSMutableArray *duplicatesArray;
    static NSMutableArray *filteredData;
    if (index == 0) {
       duplicatesArray = [[NSMutableArray alloc] init];
        filteredData = [self.unfilteredData mutableCopy];
        self.filteredData = [self.unfilteredData mutableCopy];
    }
    //DDLogInfo(@"healthData.count = %i", self.unfilteredData.count);
    //DDLogInfo(@"index = %i", index);
    HKQuantitySample *quantitySample = [self.unfilteredData objectAtIndex:index];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@", HKPredicateKeyPathStartDate, quantitySample.startDate, HKPredicateKeyPathEndDate, quantitySample.endDate];
    HKSampleQuery *query2 = [[HKSampleQuery alloc] initWithSampleType:quantitySample.quantityType predicate:predicate2 limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery *query2, NSArray *results2, NSError *error) {
        if (results2.count > 0) {
            for (HKQuantitySample *result in results2) {
                if ([result.quantity compare:quantitySample.quantity] == NSOrderedSame && [result.metadata[@"Watch Name"] isEqualToString:self.deviceEntity.name]) {
                    [filteredData removeObject:quantitySample];
                }
                else{
                    if ([result.metadata[@"Watch Name"] isEqualToString:self.deviceEntity.name]) {
                        [duplicatesArray addObject:result];//[results2 firstObject]];
                    }
                }
            }
            if (index >= self.unfilteredData.count - 1) {
                if (duplicatesArray.count > 0) {
                    index = 0;
                    self.duplicateData = duplicatesArray;
                    self.filteredData = filteredData;
                    [self deleteDuplicateDataInHealthStore];//:duplicatesArray /*atPosition:0*/ andAddNewData:filteredData ];//withDeviceEntity:self.deviceEntity];
                }
                else{
                    index = 0;
                    self.filteredData = filteredData;
                    [self addHealthDataWithHealthData:self.filteredData]; //andDeviceEntity:self.deviceEntity];
                }
            }
            else{
                index++;
                [self updateDataByFilteringDuplicate];//updateDataByGettingDuplicateDataInArray:self.unfilteredData /*atIndex:index+1 andAddToDuplicatesArray:duplicatesArray */andUseFilteredData:filteredData];// withDeviceEntity:deviceEntity];
            }
        }
        else{
            if (index >= self.unfilteredData.count - 1) {
                if (duplicatesArray.count == 0) {
                    index = 0;
                    self.filteredData = filteredData;
                    [self addHealthDataWithHealthData:self.filteredData];// andDeviceEntity:self.deviceEntity];
                }
                else{
                    index = 0;
                    self.duplicateData = duplicatesArray;
                    self.filteredData = filteredData;
                    [self deleteDuplicateDataInHealthStore];//:duplicatesArray atPosition:0 andAddNewData:filteredData withDeviceEntity:self.deviceEntity];
                }
            }
            else{
                index++;
                [self updateDataByFilteringDuplicate];//updateDataByGettingDuplicateDataInArray:healthData /*atIndex:index+1 andAddToDuplicatesArray:duplicatesArray */andUseFilteredData:filteredData]; //withDeviceEntity:self.deviceEntity];
            }
        }
    }];
    [self.store executeQuery:query2];
}


- (void)deleteDuplicateDataInHealthStore{//:(NSArray *)duplicateData
                              //atPosition:(int)position
                           //andAddNewData:(NSArray *)healthData{
                        //withDeviceEntity:(DeviceEntity *)deviceEntity{
    //DDLogInfo(@"");
    static int position;
   // if (position == 0) {
        
   // }
    //DDLogInfo(@"duplicateData.count = %i", self.duplicateData.count);
    //DDLogInfo(@"position = %i", position);
    [self.store deleteObject:self.duplicateData[position] withCompletion:^(BOOL success, NSError *error) {
        if (position+1 == self.duplicateData.count) {
            position = 0;
            [self addHealthDataWithHealthData:self.filteredData];// andDeviceEntity:self.deviceEntity];
        }
        else{
            position++;
            [self deleteDuplicateDataInHealthStore];//:self.duplicateData atPosition:position+1 andAddNewData:self.filteredData withDeviceEntity:self.deviceEntity];
        }
    }];
}

- (void)addHealthDataWithHealthData:(NSArray *)healthData{// andDeviceEntity:(DeviceEntity *)deviceEntity{
    NSMutableArray *healthDataSteps = [[NSMutableArray alloc] init];
    NSMutableArray *healthDataCalories = [[NSMutableArray alloc] init];
    NSMutableArray *healthDataRestingCalories = [[NSMutableArray alloc] init];
    NSMutableArray *healthDataDistance = [[NSMutableArray alloc] init];
    NSMutableArray *healthDataHeartRate = [[NSMutableArray alloc] init];
    for (HKQuantitySample *healthObject in healthData) {
        if (healthObject.sampleType == [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]) {
            [healthDataSteps addObject:healthObject];
        }
        else if (healthObject.sampleType == [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned]) {
            [healthDataCalories addObject:healthObject];
        }
        else if (healthObject.sampleType == [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned]) {
            [healthDataRestingCalories addObject:healthObject];
        }
        else if (healthObject.sampleType == [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning]) {
            [healthDataDistance addObject:healthObject];
        }
        else if (healthObject.sampleType == [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]) {
            [healthDataHeartRate addObject:healthObject];
        }
    }
    [self.store saveObjects:healthDataSteps withCompletion:^(BOOL success, NSError *error) {
        [self.store saveObjects:healthDataCalories withCompletion:^(BOOL success, NSError *error) {
            [self.store saveObjects:healthDataRestingCalories withCompletion:^(BOOL success, NSError *error) {
                [self.store saveObjects:healthDataDistance withCompletion:^(BOOL success, NSError *error) {
                    [self.store saveObjects:healthDataHeartRate withCompletion:^(BOOL success, NSError *error) {
                        DDLogInfo(@"Saving data to health store successful");
                        NSArray *sleepLogs = [SleepDatabaseEntity sleepDatabaseForDeviceEntity:self.deviceEntity];
                        NSArray *workouts = [[NSArray alloc] init];
                        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
                        WatchModel watchModel           = [[userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
                        
                        if (watchModel == WatchModel_R420) {
                            workouts = [self.deviceEntity.workoutHeader allObjects];
                            NSMutableArray *tempWorkouts = [workouts mutableCopy];
                            for (WorkoutHeaderEntity *workoutInfo in workouts) {
                                NSDate *startTime = [self getStartTimeOfWorkoutHeader:workoutInfo];
                                NSDate *endTime = [self getEndTimeOfWorkoutHeader:workoutInfo];
                                if ([startTime compare:endTime] == NSOrderedDescending) {
                                    [tempWorkouts removeObject:workoutInfo];
                                }
                            }
                            workouts = [tempWorkouts copy];
                        }
                        else{
                            workouts = [self.deviceEntity.workout allObjects];
                            NSMutableArray *tempWorkouts = [workouts mutableCopy];
                            for (WorkoutInfoEntity *workoutInfo in workouts) {
                                NSDate *startTime = [self getStartTimeOfWorkout:workoutInfo];
                                NSDate *endTime = [self getEndTimeOfWorkout:workoutInfo];
                                if ([startTime compare:endTime] == NSOrderedDescending) {
                                    [tempWorkouts removeObject:workoutInfo];
                                }
                            }
                            workouts = [tempWorkouts copy];
                        }
                        [[SFAHealthKitManager sharedManager] addSleepAndWorkoutToHealthStoreWithWorkoutEntitities:workouts andSleepLogs:sleepLogs];
                    }];
                }];
            }];
        }];
    }];
}


/* * * * * * * * * * * * * * * * * */
//      SLEEP AND WORKOUT           /
/* * * * * * * * * * * * * * * * * */

- (void)addSleepAndWorkoutToHealthStoreWithWorkoutEntitities:(NSArray *)workouts andSleepLogs:(NSArray *)sleepLogs{
    //DDLogInfo(@"");
    NSMutableArray *workoutToBeStored = [[NSMutableArray alloc] init];
    NSMutableArray *duplicateWorkout = [[NSMutableArray alloc] init];
    //NSMutableArray *workoutsCopy = [workouts mutableCopy];
    NSArray *workoutsCopy = [workouts copy];
    if (workouts.count > 0) {
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        WatchModel watchModel           = [[userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
        if (watchModel == WatchModel_R420) {
            for(WorkoutHeaderEntity *workoutEntity in workouts){
                HKQuantity *distance = [HKQuantity quantityWithUnit:[HKUnit meterUnit]
                                                        doubleValue:workoutEntity.distance.doubleValue*1000];
                
                HKQuantity *energyBurned = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit]
                                                            doubleValue:workoutEntity.calories.integerValue];
                
                NSDictionary *metadata = @{HKMetadataKeyDeviceManufacturerName: @"LifeTrak", @"Watch Name" : self.deviceEntity.name};
                
                
                NSDate *startTime = [self getStartTimeOfWorkoutHeader:workoutEntity];
                NSDate *endTime = [self getEndTimeOfWorkoutHeader:workoutEntity];
                
                
                NSArray *workoutEvents = [self getWorkoutStopsOfWorkoutHeader:workoutEntity];
                //#warning change type
                //Running is the closest workout for LifeTrak workouts
                //if ([startTime compare:endTime] == NSOrderedAscending){
                HKWorkout *workout = [HKWorkout workoutWithActivityType:HKWorkoutActivityTypeRunning
                                                              startDate:startTime
                                                                endDate:endTime
                                                          workoutEvents:workoutEvents
                                                      totalEnergyBurned:energyBurned
                                                          totalDistance:distance
                                                               metadata:metadata];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@", HKPredicateKeyPathStartDate, workout.startDate, HKPredicateKeyPathEndDate, workout.endDate];//[HKQuery predicateForObjectsFromWorkout:workout];
                HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:[HKWorkoutType workoutType] predicate:predicate limit:1 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                    if (results.count == 0) {
                        [workoutToBeStored addObject:workout];
                        WorkoutHeaderEntity *lastWorkoutEntity = workoutsCopy[workoutsCopy.count-1];
                        if (workoutEntity.stampYear.integerValue == lastWorkoutEntity.stampYear.integerValue &&
                            workoutEntity.stampMonth.integerValue == lastWorkoutEntity.stampMonth.integerValue &&
                            workoutEntity.stampDay.integerValue == lastWorkoutEntity.stampDay.integerValue &&
                            workoutEntity.stampHour.integerValue == lastWorkoutEntity.stampHour.integerValue &&
                            workoutEntity.stampMinute.integerValue == lastWorkoutEntity.stampMinute.integerValue &&
                            workoutEntity.stampSecond.integerValue == lastWorkoutEntity.stampSecond.integerValue) {
                            if (duplicateWorkout.count > 0) {
                                self.duplicateWorkouts = duplicateWorkout;
                                self.workouts = workoutToBeStored;
                                self.sleepData = [sleepLogs mutableCopy];
                                [self deleteDuplicateWorkoutInHealthStore];//:duplicateWorkout atPosition:0 andAddNewWorkouts:workoutToBeStored andNewSleepLogs:sleepLogs];
                            }
                            else{
                                [self.store saveObjects:workoutToBeStored withCompletion:^(BOOL success, NSError *error) {
                                    // Perform proper error handling here...
                                    DDLogInfo(@"*** An error occurred while saving this "
                                              @"workout: %@ ***", error.localizedDescription);
                                    DDLogInfo(@"Workouts saved");
                                    [[SFAHealthKitManager sharedManager] addSleepLogsToHealthStoreWithArray:sleepLogs];
                                }];
                            }
                        }
                        
                    }
                    else{
                        [duplicateWorkout addObject:workout];
                        WorkoutHeaderEntity *lastWorkoutEntity = workoutsCopy[workoutsCopy.count-1];
                        if (workoutEntity.stampYear.integerValue == lastWorkoutEntity.stampYear.integerValue &&
                            workoutEntity.stampMonth.integerValue == lastWorkoutEntity.stampMonth.integerValue &&
                            workoutEntity.stampDay.integerValue == lastWorkoutEntity.stampDay.integerValue &&
                            workoutEntity.stampHour.integerValue == lastWorkoutEntity.stampHour.integerValue &&
                            workoutEntity.stampMinute.integerValue == lastWorkoutEntity.stampMinute.integerValue &&
                            workoutEntity.stampSecond.integerValue == lastWorkoutEntity.stampSecond.integerValue) {
                            if (duplicateWorkout.count > 0) {
                                self.workouts = workoutToBeStored;
                                self.duplicateWorkouts = duplicateWorkout;
                                self.sleepData = [sleepLogs mutableCopy];
                                [self deleteDuplicateWorkoutInHealthStore];//:duplicateWorkout atPosition:0 andAddNewSleep:sleepLogs];
                            }
                        }
                    }
                }];
                
                [self.store executeQuery:query];
            }
            //}
        }
        else{
            for(WorkoutInfoEntity *workoutEntity in workouts){
                HKQuantity *distance = [HKQuantity quantityWithUnit:[HKUnit meterUnit]
                                                        doubleValue:workoutEntity.distance.doubleValue*1000];
                
                HKQuantity *energyBurned = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit]
                                                            doubleValue:workoutEntity.calories.integerValue];
                
                NSDictionary *metadata = @{HKMetadataKeyDeviceManufacturerName: @"LifeTrak", @"Watch Name" : self.deviceEntity.name};
                
                
                NSDate *startTime = [self getStartTimeOfWorkout:workoutEntity];
                NSDate *endTime = [self getEndTimeOfWorkout:workoutEntity];
                
                
                NSArray *workoutEvents = [self getWorkoutStopsOfWorkout:workoutEntity];
                //#warning change type
                //Running is the closest workout for LifeTrak workouts
                //if ([startTime compare:endTime] == NSOrderedAscending){
                HKWorkout *workout = [HKWorkout workoutWithActivityType:HKWorkoutActivityTypeRunning
                                                              startDate:startTime
                                                                endDate:endTime
                                                          workoutEvents:workoutEvents
                                                      totalEnergyBurned:energyBurned
                                                          totalDistance:distance
                                                               metadata:metadata];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@", HKPredicateKeyPathStartDate, workout.startDate, HKPredicateKeyPathEndDate, workout.endDate];//[HKQuery predicateForObjectsFromWorkout:workout];
                HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:[HKWorkoutType workoutType] predicate:predicate limit:1 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                    if (results.count == 0) {
                        [workoutToBeStored addObject:workout];
                        WorkoutInfoEntity *lastWorkoutEntity = workoutsCopy[workoutsCopy.count-1];
                        if (workoutEntity.stampYear.integerValue == lastWorkoutEntity.stampYear.integerValue &&
                            workoutEntity.stampMonth.integerValue == lastWorkoutEntity.stampMonth.integerValue &&
                            workoutEntity.stampDay.integerValue == lastWorkoutEntity.stampDay.integerValue &&
                            workoutEntity.stampHour.integerValue == lastWorkoutEntity.stampHour.integerValue &&
                            workoutEntity.stampMinute.integerValue == lastWorkoutEntity.stampMinute.integerValue &&
                            workoutEntity.stampSecond.integerValue == lastWorkoutEntity.stampSecond.integerValue) {
                            if (duplicateWorkout.count > 0) {
                                self.duplicateWorkouts = duplicateWorkout;
                                self.workouts = workoutToBeStored;
                                self.sleepData = [sleepLogs mutableCopy];
                                [self deleteDuplicateWorkoutInHealthStore];//:duplicateWorkout atPosition:0 andAddNewWorkouts:workoutToBeStored andNewSleepLogs:sleepLogs];
                            }
                            else{
                                [self.store saveObjects:workoutToBeStored withCompletion:^(BOOL success, NSError *error) {
                                    // Perform proper error handling here...
                                    DDLogInfo(@"*** An error occurred while saving this "
                                              @"workout: %@ ***", error.localizedDescription);
                                    DDLogInfo(@"Workouts saved");
                                    [[SFAHealthKitManager sharedManager] addSleepLogsToHealthStoreWithArray:sleepLogs];
                                }];
                            }
                        }
                        
                    }
                    else{
                        [duplicateWorkout addObject:workout];
                        WorkoutInfoEntity *lastWorkoutEntity = workoutsCopy[workoutsCopy.count-1];
                        if (workoutEntity.stampYear.integerValue == lastWorkoutEntity.stampYear.integerValue &&
                            workoutEntity.stampMonth.integerValue == lastWorkoutEntity.stampMonth.integerValue &&
                            workoutEntity.stampDay.integerValue == lastWorkoutEntity.stampDay.integerValue &&
                            workoutEntity.stampHour.integerValue == lastWorkoutEntity.stampHour.integerValue &&
                            workoutEntity.stampMinute.integerValue == lastWorkoutEntity.stampMinute.integerValue &&
                            workoutEntity.stampSecond.integerValue == lastWorkoutEntity.stampSecond.integerValue) {
                            if (duplicateWorkout.count > 0) {
                                self.duplicateWorkouts = duplicateWorkout;
                                self.sleepData = [sleepLogs mutableCopy];
                                [self deleteDuplicateWorkoutInHealthStore];//:duplicateWorkout atPosition:0 andAddNewSleep:sleepLogs];
                            }
                        }
                    }
                }];
                
                [self.store executeQuery:query];
            }
            //}
        }
        
    }
    else{
        [[SFAHealthKitManager sharedManager] addSleepLogsToHealthStoreWithArray:sleepLogs];
    }
}

/* * * * * * * * * * * * */
//      WORKOUT           /
/* * * * * * * * * * * * */

- (void)deleteDuplicateWorkoutInHealthStore{//:(NSArray *)duplicateWorkouts atPosition:(int)position andAddNewWorkouts:(NSArray *)workouts andNewSleepLogs:(NSArray *)sleepLogs{
    //DDLogInfo(@"");
    static int position;
    //DDLogInfo(@"duplicateWorkouts.count = %i", self.duplicateWorkouts.count);
    //DDLogInfo(@"position = %i", position);
    [self.store deleteObject:self.duplicateWorkouts[position] withCompletion:^(BOOL success, NSError *error) {
        if (position+1 == self.duplicateWorkouts.count) {
            [self.store saveObjects:self.workouts withCompletion:^(BOOL success, NSError *error) {
                DDLogInfo(@"Workouts saved");
                position = 0;
                [[SFAHealthKitManager sharedManager] addSleepLogsToHealthStoreWithArray:self.sleepData];
            }];
        }
        else{
            position++;
            [self deleteDuplicateWorkoutInHealthStore];//:duplicateWorkouts atPosition:position+1 andAddNewWorkouts:workouts andNewSleepLogs:sleepLogs];
        }
    }];
}


- (NSDate *)getStartTimeOfWorkout:(WorkoutInfoEntity *)workoutEntity{
    //DDLogInfo(@"");
    NSCalendar *calendar                    = [NSCalendar currentCalendar];
    NSDateComponents *components            = [NSDateComponents new];
    components.month                        = workoutEntity.stampMonth.integerValue;
    components.day                          = workoutEntity.stampDay.integerValue;
    components.year                         = workoutEntity.stampYear.integerValue;
    components.hour                         = workoutEntity.stampHour.integerValue;
    components.minute                       = workoutEntity.stampMinute.integerValue;
    components.second                       = workoutEntity.stampSecond.integerValue;
    NSDate *startDate                       = [calendar dateFromComponents:components];
    
    return startDate;
}

- (NSDate *)getStartTimeOfWorkoutHeader:(WorkoutHeaderEntity *)workoutEntity{
    //DDLogInfo(@"");
    NSCalendar *calendar                    = [NSCalendar currentCalendar];
    NSDateComponents *components            = [NSDateComponents new];
    components.month                        = workoutEntity.stampMonth.integerValue;
    components.day                          = workoutEntity.stampDay.integerValue;
    components.year                         = workoutEntity.stampYear.integerValue > 1900 ? workoutEntity.stampYear.integerValue : workoutEntity.stampYear.integerValue + 1900;
    components.hour                         = workoutEntity.stampHour.integerValue;
    components.minute                       = workoutEntity.stampMinute.integerValue;
    components.second                       = workoutEntity.stampSecond.integerValue;
    NSDate *startDate                       = [calendar dateFromComponents:components];
    
    return startDate;
}

- (NSDate *)getEndTimeOfWorkout:(WorkoutInfoEntity *)workoutEntity{
    //DDLogInfo(@"");
    NSArray *workoutStops = [workoutEntity.workoutStopDatabase allObjects];
    NSInteger workoutStopDuration = 0;
    NSInteger workoutDuration = workoutEntity.hour.integerValue * 3600 + workoutEntity.minute.integerValue * 60 + workoutEntity.second.integerValue;
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        
        if (([[self getStartTimeOfWorkoutStop:workoutStop] compare:[self getStartTimeOfWorkout:workoutEntity]] == NSOrderedAscending &&
             [[self getStartTimeOfWorkoutStop:workoutStop] compare:[self getEndTimeOfWorkout:workoutEntity]] == NSOrderedDescending) &&
            ([[self getEndTimeOfWorkoutStop:workoutStop] compare:[self getStartTimeOfWorkout:workoutEntity]] == NSOrderedAscending &&
             [[self getEndTimeOfWorkoutStop:workoutStop] compare:[self getEndTimeOfWorkout:workoutEntity]] == NSOrderedDescending)) {
                NSInteger stopMinutes = workoutStop.stopHour.integerValue * 3600 + workoutStop.stopMinute.integerValue * 60 + workoutStop.stopSecond.integerValue;
                workoutStopDuration += stopMinutes;;
            }
    }
    
    NSInteger startSeconds =(workoutEntity.stampHour.integerValue * 3600 + workoutEntity.stampMinute.integerValue * 60 + workoutEntity.stampSecond.integerValue);
    
    workoutDuration += startSeconds + workoutStopDuration;
    
    NSInteger endMinute = (workoutDuration%3600)/60;
    NSInteger endHour = workoutDuration/3600;
    NSInteger endSecond = workoutDuration%60;
    
    NSCalendar *calendar                    = [NSCalendar currentCalendar];
    NSDateComponents *components            = [NSDateComponents new];
    components.month                        = workoutEntity.stampMonth.integerValue;
    components.day                          = workoutEntity.stampDay.integerValue;
    components.year                         = workoutEntity.stampYear.integerValue;
    components.hour                         = endHour;
    components.minute                       = endMinute;
    components.second                       = endSecond;
    NSDate *endDate                         = [calendar dateFromComponents:components];
    return endDate;
}


- (NSDate *)getEndTimeOfWorkoutHeader:(WorkoutHeaderEntity *)workoutEntity{
    //DDLogInfo(@"");
    NSArray *workoutStops = [workoutEntity.workoutStopDatabase allObjects];
    NSInteger workoutStopDuration = 0;
    NSInteger workoutDuration = workoutEntity.hour.integerValue * 3600 + workoutEntity.minute.integerValue * 60 + workoutEntity.second.integerValue;
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        
        if (([[self getStartTimeOfWorkoutStopHeader:workoutStop] compare:[self getStartTimeOfWorkoutHeader:workoutEntity]] == NSOrderedAscending &&
             [[self getStartTimeOfWorkoutStopHeader:workoutStop] compare:[self getEndTimeOfWorkoutHeader:workoutEntity]] == NSOrderedDescending) &&
            ([[self getEndTimeOfWorkoutStopHeader:workoutStop] compare:[self getStartTimeOfWorkoutHeader:workoutEntity]] == NSOrderedAscending &&
             [[self getEndTimeOfWorkoutStopHeader:workoutStop] compare:[self getEndTimeOfWorkoutHeader:workoutEntity]] == NSOrderedDescending)) {
                NSInteger stopMinutes = workoutStop.stopHour.integerValue * 3600 + workoutStop.stopMinute.integerValue * 60 + workoutStop.stopSecond.integerValue;
                workoutStopDuration += stopMinutes;;
            }
    }
    
    NSInteger startSeconds =(workoutEntity.stampHour.integerValue * 3600 + workoutEntity.stampMinute.integerValue * 60 + workoutEntity.stampSecond.integerValue);
    
    workoutDuration += startSeconds + workoutStopDuration;
    
    NSInteger endMinute = (workoutDuration%3600)/60;
    NSInteger endHour = workoutDuration/3600;
    NSInteger endSecond = workoutDuration%60;
    
    NSCalendar *calendar                    = [NSCalendar currentCalendar];
    NSDateComponents *components            = [NSDateComponents new];
    components.month                        = workoutEntity.stampMonth.integerValue;
    components.day                          = workoutEntity.stampDay.integerValue;
    components.year                         = workoutEntity.stampYear.integerValue > 1900 ? workoutEntity.stampYear.integerValue : workoutEntity.stampYear.integerValue + 1900;
    components.hour                         = endHour;
    components.minute                       = endMinute;
    components.second                       = endSecond;
    NSDate *endDate                         = [calendar dateFromComponents:components];
    return endDate;
}

- (NSDate *)getStartTimeOfWorkoutStop:(WorkoutStopDatabaseEntity *)workoutStopEntity{
    //DDLogInfo(@"");
    NSDate *workoutStart                    = [self getStartTimeOfWorkout:workoutStopEntity.workout];
    NSCalendar *calendar                    = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:workoutStart];
    int workoutStopSeconds = components.hour*3600 + workoutStopEntity.workoutHour.integerValue*3600 + components.minute*60 + workoutStopEntity.workoutMinute.integerValue*60 + components.second + workoutStopEntity.workoutSecond.integerValue;
    components.hour                         = workoutStopSeconds/3600;
    components.minute                       = (workoutStopSeconds%3600)/60;
    components.second                       = workoutStopSeconds%60;
    
    NSDate *startDate                       = [calendar dateFromComponents:components];
    
    return startDate;
}

- (NSDate *)getEndTimeOfWorkoutStop:(WorkoutStopDatabaseEntity *)workoutStopEntity{
    //DDLogInfo(@"");
    NSDate *startDate                       = [self getStartTimeOfWorkoutStop:workoutStopEntity];
    int workoutStopDuration = workoutStopEntity.stopHour.integerValue * 3600 + workoutStopEntity.stopMinute.integerValue * 60 + workoutStopEntity.stopSecond.integerValue;
    
    NSDate *endDate = [startDate dateByAddingTimeInterval:workoutStopDuration];
    
    return endDate;
}

- (NSArray *)getWorkoutStopsOfWorkout:(WorkoutInfoEntity *)workoutEntity{
    //DDLogInfo(@"");
    NSMutableArray *workoutEvents = [[NSMutableArray alloc] init];
    NSArray *workoutStops = [workoutEntity.workoutStopDatabase allObjects];
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        HKWorkoutEvent *pause =
        [HKWorkoutEvent workoutEventWithType:HKWorkoutEventTypePause
                                        date:[self getStartTimeOfWorkoutStop:workoutStop]];
        
        HKWorkoutEvent *resume =
        [HKWorkoutEvent workoutEventWithType:HKWorkoutEventTypeResume
                                        date:[self getEndTimeOfWorkoutStop:workoutStop]];
        
        if (([[self getStartTimeOfWorkoutStop:workoutStop] compare:[self getStartTimeOfWorkout:workoutEntity]] == NSOrderedAscending &&
            [[self getStartTimeOfWorkoutStop:workoutStop] compare:[self getEndTimeOfWorkout:workoutEntity]] == NSOrderedDescending) &&
            ([[self getEndTimeOfWorkoutStop:workoutStop] compare:[self getStartTimeOfWorkout:workoutEntity]] == NSOrderedAscending &&
             [[self getEndTimeOfWorkoutStop:workoutStop] compare:[self getEndTimeOfWorkout:workoutEntity]] == NSOrderedDescending)) {
                [workoutEvents addObject:pause];
                [workoutEvents addObject:resume];
        }
    }
    return [workoutEvents copy];
}


- (NSArray *)getWorkoutStopsOfWorkoutHeader:(WorkoutHeaderEntity *)workoutEntity{
    //DDLogInfo(@"");
    NSMutableArray *workoutEvents = [[NSMutableArray alloc] init];
    NSArray *workoutStops = [workoutEntity.workoutStopDatabase allObjects];
    for (WorkoutStopDatabaseEntity *workoutStop in workoutStops){
        HKWorkoutEvent *pause =
        [HKWorkoutEvent workoutEventWithType:HKWorkoutEventTypePause
                                        date:[self getStartTimeOfWorkoutStopHeader:workoutStop]];
        
        HKWorkoutEvent *resume =
        [HKWorkoutEvent workoutEventWithType:HKWorkoutEventTypeResume
                                        date:[self getEndTimeOfWorkoutStopHeader:workoutStop]];
        
        if (([[self getStartTimeOfWorkoutStopHeader:workoutStop] compare:[self getStartTimeOfWorkoutHeader:workoutEntity]] == NSOrderedAscending &&
             [[self getStartTimeOfWorkoutStopHeader:workoutStop] compare:[self getEndTimeOfWorkoutHeader:workoutEntity]] == NSOrderedDescending) &&
            ([[self getEndTimeOfWorkoutStopHeader:workoutStop] compare:[self getStartTimeOfWorkoutHeader:workoutEntity]] == NSOrderedAscending &&
             [[self getEndTimeOfWorkoutStopHeader:workoutStop] compare:[self getEndTimeOfWorkoutHeader:workoutEntity]] == NSOrderedDescending)) {
                [workoutEvents addObject:pause];
                [workoutEvents addObject:resume];
            }
    }
    return [workoutEvents copy];
}

- (NSDate *)getStartTimeOfWorkoutStopHeader:(WorkoutStopDatabaseEntity *)workoutStopEntity{
    //DDLogInfo(@"");
    NSDate *workoutStart                    = [self getStartTimeOfWorkoutHeader:workoutStopEntity.workoutHeader];
    NSCalendar *calendar                    = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:workoutStart];
    int workoutStopSeconds = components.hour*3600 + workoutStopEntity.workoutHour.integerValue*3600 + components.minute*60 + workoutStopEntity.workoutMinute.integerValue*60 + components.second + workoutStopEntity.workoutSecond.integerValue;
    components.hour                         = workoutStopSeconds/3600;
    components.minute                       = (workoutStopSeconds%3600)/60;
    components.second                       = workoutStopSeconds%60;
    
    NSDate *startDate                       = [calendar dateFromComponents:components];
    
    return startDate;
}

- (NSDate *)getEndTimeOfWorkoutStopHeader:(WorkoutStopDatabaseEntity *)workoutStopEntity{
    //DDLogInfo(@"");
    NSDate *startDate                       = [self getStartTimeOfWorkoutStopHeader:workoutStopEntity];
    int workoutStopDuration = workoutStopEntity.stopHour.integerValue * 3600 + workoutStopEntity.stopMinute.integerValue * 60 + workoutStopEntity.stopSecond.integerValue;
    
    NSDate *endDate = [startDate dateByAddingTimeInterval:workoutStopDuration];
    
    return endDate;
}

/* * * * * * * * * * * * */
//         SLEEP          /
/* * * * * * * * * * * * */
- (void)addSleepLogsToHealthStoreWithArray:(NSArray *)sleepLogs{
    //sleepLogs is array of sleepDataBaseEntities
    //DDLogInfo(@"");
    NSMutableArray *sleepSamples = [[NSMutableArray alloc] init];
    NSMutableArray *duplicateSleepSamples = [[NSMutableArray alloc] init];
    if (sleepLogs.count > 0) {
    
    for (SleepDatabaseEntity *sleep in sleepLogs)
    {
#warning for data from cloud
        int unadjustedSleepEndMinutes = sleep.sleepEndHour.intValue * 60 + sleep.sleepEndMin.intValue;
        NSInteger sleepEndMinutes     =  unadjustedSleepEndMinutes;//sleep.adjustedSleepEndMinutes;
        NSInteger sleepStartMinutes   =  sleep.sleepStartHour.integerValue * 60 + sleep.sleepStartMin.integerValue;
        int endDayConstant = sleep.date.day.integerValue;
        int sleepEndHour = sleepEndMinutes/60;
        int sleepStartAndDuration = sleepStartMinutes + sleep.sleepDuration.integerValue;
        if (1439 < sleepStartAndDuration) {
            endDayConstant++;
        }
        
        NSCalendar *calendar                    = [NSCalendar currentCalendar];
        NSDateComponents *components            = [NSDateComponents new];
        components.month                        = sleep.date.month.integerValue;
        components.day                          = sleep.date.day.integerValue;
        components.year                         = sleep.date.year.integerValue + 1900;
        components.hour                         = sleep.sleepStartHour.integerValue;
        components.minute                       = sleep.sleepStartMin.integerValue;
        NSDate *startDate                       = [calendar dateFromComponents:components];
        

        NSCalendar *calendar2                    = [NSCalendar currentCalendar];
        NSDateComponents *components2            = [NSDateComponents new];
        components2.month                        = sleep.date.month.integerValue;
        components2.day                          = endDayConstant;//sleep.date.day.integerValue;
        components2.year                         = sleep.date.year.integerValue + 1900;
        components2.hour                         = sleepEndHour;
        components2.minute                       = sleepEndMinutes%60;
        NSDate *endDate                          = [calendar2 dateFromComponents:components2];
        
        if ([startDate compare:endDate] == NSOrderedDescending) {
            components2.day                      = endDayConstant+1;
            endDate                              = [calendar2 dateFromComponents:components2];
        }

        
        HKCategoryType *categoryType = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
        HKCategorySample *sleepCatergorySample = [HKCategorySample categorySampleWithType:categoryType value:HKCategoryValueSleepAnalysisAsleep startDate:startDate endDate:endDate metadata:@{@"Watch Name" : self.deviceEntity.name}];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@", HKPredicateKeyPathStartDate, sleepCatergorySample.startDate, HKPredicateKeyPathEndDate, sleepCatergorySample.endDate];
        HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:categoryType predicate:predicate limit:1 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
            if (results.count == 0) {
                
               /* [self.store deleteObject:sleepCatergorySample withCompletion:^(BOOL success, NSError *error) {
                    // Perform proper error handling here...
                    DDLogError(@"*** An error occurred while deleting this "
                          @"sleep: %@ ***", error.localizedDescription);
                }];
            */
#warning handle modified sleep in lifetrak
                [sleepSamples addObject:sleepCatergorySample];
                
                if([sleep isEqual:[sleepLogs lastObject]]){
                    if (duplicateSleepSamples.count > 0) {
                        self.duplicateSleepData = duplicateSleepSamples;
                        self.sleepDataSamples = [sleepSamples mutableCopy];
                        [self deleteDuplicateSleepInArray];//:duplicateSleepSamples atPosition:0 andAddNewSleep:sleepSamples];
                    }
                    else{
                    [self.store saveObjects:sleepSamples withCompletion:^(BOOL success, NSError *error) {
                        [self healthKitSyncingDone];
                        DDLogInfo(@"Saving sleep done");
                    }];
                    }
                }
            }
            else{
                [duplicateSleepSamples addObject:sleepCatergorySample];
                if([sleep isEqual:[sleepLogs lastObject]]){
                    self.duplicateSleepData = duplicateSleepSamples;
                    self.sleepDataSamples = [sleepSamples mutableCopy];
                    [self deleteDuplicateSleepInArray];//:duplicateSleepSamples atPosition:0 andAddNewSleep:sleepSamples];
                }
            }
            
        }];
        
        [self.store executeQuery:query];
    }
    
    }
    else{
        [self healthKitSyncingDone];
        DDLogInfo(@"No sleep to save in health store.");
    }
}

- (void)deleteDuplicateSleepInArray{//:(NSArray *)duplicateSleeps atPosition:(int)position andAddNewSleep:(NSArray *)sleepLogs{
    //DDLogInfo(@"");
    static int position;
    //DDLogInfo(@"duplicateSleeps.count = %i", self.duplicateSleepData.count);
    //DDLogInfo(@"position = %i", position);
    [self.store deleteObject:self.duplicateSleepData[position] withCompletion:^(BOOL success, NSError *error) {
        if (position+1 == self.duplicateSleepData.count) {
            position = 0;
            [self.store saveObjects:self.sleepDataSamples withCompletion:^(BOOL success, NSError *error) {
                [self healthKitSyncingDone];
                DDLogInfo(@"Saving sleep to health store successful");
            }];
        }
        else{
            position++;
            [self deleteDuplicateSleepInArray];//:duplicateSleeps atPosition:position+1 andAddNewSleep:sleepLogs];
        }
    }];
}

//Get active time for active calories burned filtering
- (NSArray *)getActiveTimeIndexesForDateHeader:(StatisticalDataHeaderEntity *)dataHeader{
    //DDLogInfo(@"");
    NSArray *data = [[StatisticalDataPointEntity dataPointsForDate:dataHeader.dateInNSDate] copy];//[dataHeader.dataPoint copy];
    NSMutableArray *activeTimeIndexes = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    WatchModel watchModel           = [[userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
    
    if (data.count > 0 && (watchModel == WatchModel_Move_C300 || watchModel == WatchModel_Move_C300_Android)) {
        for (NSInteger a = 0; a < data.count; a++)
        {
            [activeTimeIndexes addObject:@(a)];
        }
    }
    else if (data.count > 0)
    {
        NSDate *yesterday               = [dataHeader.dateInNSDate dateByAddingTimeInterval:-DAY_SECONDS];
        NSArray *yesterdaySleeps        = [SleepDatabaseEntity sleepDatabaseForDate:yesterday];
        NSArray *sleeps                 = [SleepDatabaseEntity sleepDatabaseForDate:dataHeader.dateInNSDate];
        NSArray *workouts               = nil;
        
        if (watchModel != WatchModel_Core_C200 &&
            watchModel != WatchModel_Move_C300 &&
            watchModel != WatchModel_Move_C300_Android &&
            watchModel != WatchModel_Zone_C410 &&
            watchModel != WatchModel_R420) {
            workouts = [WorkoutInfoEntity getWorkoutInfoWithDate:dataHeader.dateInNSDate];
        }
        
        NSMutableArray *sleepIndexes        = [NSMutableArray new];
        
        for (SleepDatabaseEntity *sleep in yesterdaySleeps)
        {
            NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6) + (sleep.sleepStartMin.integerValue / 10);
            NSInteger endIndex       = sleep.adjustedSleepEndMinutes/10;
            
            if (startIndex >= endIndex)
            {
                
                for (NSInteger a = 0; a <= endIndex; a++)
                {
                    NSNumber *number = [NSNumber numberWithInt:a];
                    [sleepIndexes addObject:number];
                }
            }
            
        }
        
        for (SleepDatabaseEntity *sleep in sleeps)
        {
            NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6) + (sleep.sleepStartMin.integerValue / 10);
            NSInteger endIndex      = (sleep.sleepEndHour.integerValue * 6) + (sleep.sleepEndMin.integerValue / 10);
            endIndex                = endIndex >= DAY_DATA_MAX_COUNT - 1 ? DAY_DATA_MAX_COUNT - 1 : endIndex;
            endIndex                = endIndex <= startIndex ? DAY_DATA_MAX_COUNT - 1 : endIndex;
            
            for (NSInteger a = startIndex; a <= endIndex; a++)
            {
                NSNumber *number = [NSNumber numberWithInt:a];
                [sleepIndexes addObject:number];
            }
        }
        
        for (NSInteger a = 0; a < data.count; a++)
        {
            StatisticalDataPointEntity *dataPoint = [data objectAtIndex:a];
            
            NSNumber *number    = [NSNumber numberWithInt:a];
            CGFloat value       = dataPoint.sleepPoint02.floatValue + dataPoint.sleepPoint24.floatValue + dataPoint.sleepPoint46.floatValue;
            value               += dataPoint.sleepPoint68.floatValue + dataPoint.sleepPoint810.floatValue;
            
            if (![sleepIndexes containsObject:number]){
            
                if (value < (40 * 5)) {
                } else {
                    [activeTimeIndexes addObject:@(a)];
                }
            }
        }
    }
    return activeTimeIndexes;
}

- (void)healthKitSyncingDone{
    DDLogInfo(@"");
    self.isHealthKitSyncOngoing = NO;
    if([self.delegate respondsToSelector:@selector(syncingToHealthKitFinished)]){
        [self.delegate syncingToHealthKitFinished];
    }
}

/*
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 [self getResultSetFromDB:docids];
 });
 */

@end
