//
//  SFASalutronHelper.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/26/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronWrapper.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "StatisticalDataHeader.h"
#import "StatisticalDataPoint.h"
#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "StatisticalDataPointEntity+StatisticalDataPointEntityCategory.h"

#define DISCOVER_TIMEOUT 3

@interface SFASalutronWrapper ()

@property (strong, nonatomic) SalutronSDK *salutronSDK;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign, nonatomic) WatchModel watchModel;

@end

@implementation SFASalutronWrapper

+ (SFASalutronWrapper *) sharedInstance {
    static SFASalutronWrapper *salutronWrapper;
    
    if(!salutronWrapper)
        salutronWrapper = [[SFASalutronWrapper alloc] init];
    
    return salutronWrapper;
}


#pragma mark - Private Methods & Properties

- (SalutronSDK *) salutronSDK {
    if(!_salutronSDK) {
        _salutronSDK = [SalutronSDK sharedInstance];
        _salutronSDK.delegate = self;
        [_salutronSDK disconnectDevice];
    }
    return _salutronSDK;
}


- (NSManagedObjectContext *) managedObjectContext {
    if(!_managedObjectContext) {
        SFASalutronFitnessAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (BOOL) isStatisticalDataHeaderExists:(StatisticalDataHeader *)dataHeader
                                entity:(StatisticalDataHeaderEntity *__autoreleasing *)entity {
    NSString *query = @"date.day == $day && date.month == $month && date.year == $year";
    
    SH_Date *date = dataHeader.date;
    
    NSNumber *day = [NSNumber numberWithInt:date.day];
    NSNumber *month = [NSNumber numberWithInt:date.month];
    NSNumber *year = [NSNumber numberWithInt:date.year];
    NSDictionary *vars = [[NSDictionary alloc]
                          initWithObjectsAndKeys:day, @"day", month, @"month", year,@"year", nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
    predicate = [predicate predicateWithSubstitutionVariables:vars];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:STATISTICAL_DATA_HEADER_ENTITY];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error && [results count] > 0) {
        StatisticalDataHeaderEntity *dataHeaderEntity = [results lastObject];
        *entity = dataHeaderEntity;
        return YES;
    }
    
    return NO;
}

- (BOOL) isStatisticalDataPointExists:(StatisticalDataPoint *)dataPoint
                               entity:(StatisticalDataPointEntity *__autoreleasing *)entity {
    NSString *query = @"averageHR == $averageHR && axisDirection == $axisDirection && "
    @"axisMagnitude == $axisMagnitude && calorie == $calorie && "
    @"distance == $distance && dominantAxis == $dominantAxis && "
    @"lux == $lux && sleepPoint02 == $sleepPoint02 && "
    @"sleepPoint24 == $sleepPoint24 && sleepPoint46 == $sleepPoint46 && "
    @"sleepPoint68 == $sleepPoint68 && sleepPoint810 == $sleepPoint810 && steps == $steps";
    
    NSNumber *averageHR = [NSNumber numberWithInt:dataPoint.averageHR];
    NSNumber *axisDirection = [NSNumber numberWithInt:dataPoint.axis_direction];
    NSNumber *axisMagnitude = [NSNumber numberWithInt:dataPoint.axis_magnitude];
    NSNumber *calorie = [NSNumber numberWithInt:dataPoint.calorie];
    NSNumber *distance = [NSNumber numberWithInt:dataPoint.distance];
    NSNumber *dominantAxis = [NSNumber numberWithInt:dataPoint.dominant_axis];
    NSNumber *lux = [NSNumber numberWithInt:dataPoint.Lux];
    NSNumber *sleepPoint02 = [NSNumber numberWithInt:dataPoint.sleeppoint_0_2];
    NSNumber *sleepPoint24 = [NSNumber numberWithInt:dataPoint.sleeppoint_2_4];
    NSNumber *sleepPoint46 = [NSNumber numberWithInt:dataPoint.sleeppoint_4_6];
    NSNumber *sleepPoint68 = [NSNumber numberWithInt:dataPoint.sleeppoint_6_8];
    NSNumber *sleepPoint810 = [NSNumber numberWithInt:dataPoint.sleeppoint_8_10];
    NSNumber *steps = [NSNumber numberWithInt:dataPoint.steps];
    
    NSDictionary *vars = [[NSDictionary alloc] initWithObjectsAndKeys:averageHR, @"averageHR", axisDirection, @"axisDirection", axisMagnitude, @"axisMagnitude", calorie, @"calorie", distance, @"distance", dominantAxis, @"dominantAxis", lux, @"lux", sleepPoint02, @"sleepPoint02", sleepPoint24, @"sleepPoint24", sleepPoint46, @"sleepPoint46", sleepPoint68, @"sleepPoint68", sleepPoint810, @"sleepPoint810", steps, @"steps", nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
    predicate = [predicate predicateWithSubstitutionVariables:vars];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:STATISTICAL_DATA_POINT_ENTITY];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(!error && [results count] > 0) {
        StatisticalDataPointEntity *dataPointEntity = [results lastObject];
        *entity = dataPointEntity;
        return YES;
    }
    return NO;
}

#pragma mark - Public Methods

- (void) searchAndConnectDeviceWithWatchModel:(WatchModel)watchModel {
    [_salutronSDK clearDiscoveredDevice];
    [_salutronSDK discoverDevice:DISCOVER_TIMEOUT];
    self.watchModel = watchModel;
}

- (void) startSync {
    [_salutronSDK getStatisticalDataHeaders];
}

#pragma mark - SalutronSDKDelegate

- (void) didDiscoverDevice:(int)numDevice withStatus:(Status)status {
    [_salutronSDK connectDevice:0];
}

- (void) didConnectAndSetupDeviceWithStatus:(Status)status{
    int modelNumber = [self.salutronSDK getModelNumber];
    NSString *modelNumberString = [self.salutronSDK getModelNumberString];
    
    NSLog(@"model number: %i, model name: %@", modelNumber, modelNumberString);
    [self.delegate didSearchedAndConnectDevice];
}

- (void) didDisconnectDevice:(Status)status {
    [self.delegate didDisconnectDevice];
}

- (void) didGetStatisticalDataHeaders:(NSArray *)statisticalDataHeaders
                           withStatus:(Status)status {
}

@end
