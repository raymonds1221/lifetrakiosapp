//
//  SFADashboardViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/26/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "ECSlidingViewController.h"
#import "NSDate+Comparison.h"

#import "SFADashboardViewController.h"

#import "Constants.h"

#import "SFASalutronFitnessAppDelegate.h"

#import "DateEntity.h"
#import "WorkoutInfoEntity+Data.h"
#import "WorkoutHeaderEntity.h"
#import "WorkoutHeartRateDataEntity.h"
#import "StatisticalDataHeaderEntity.h"
#import "StatisticalDataPointEntity+Data.h"
#import "SleepDatabaseEntity+Data.h"
#import "GoalsEntity.h"
#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "LightDataPointEntity+GraphData.h"
#import "LightDataPointEntity+Data.h"

#import "SFADashboardCell.h"
#import "SFADashboardBPMCell.h"
#import "SFADashboardSleepCell.h"
#import "SFADashboardDistanceCell.h"

#import "JDACoreData.h"

#import "SFADashboardCellPositionHelper.h"
#import "SFAGoalsData.h"
#import "SalutronUserProfile+Data.h"
#import "StatisticalDataPointEntity+Data.h"
#import "DayLightAlertEntity+Data.h"

#import "SFALightDataManager.h"

#define CALENDAR_VIEW_HEADER_HEIGHT 49.0f
#define SLEEP_MAX_HOUR                      15 //3pm is the max time for turn over

@interface SFADashboardViewController () <NSFetchedResultsControllerDelegate>
{
    SalutronUserProfile *_userProfile;
}

@property (readwrite, nonatomic) BOOL                           isCalendarViewHidden;
@property (strong, nonatomic) NSManagedObjectContext            *managedObjectContext;
@property (strong, nonatomic) SFADashboardCellPositionHelper    *dashboardPosition;
@property (readwrite, nonatomic) WatchModel                     watchModel;

// Goals
@property (readwrite, nonatomic) int    minBPM;
@property (readwrite, nonatomic) int    maxBPM;
@property (readwrite, nonatomic) int    stepsGoal;
@property (readwrite, nonatomic) double distanceGoal;
@property (readwrite, nonatomic) int    caloriesGoal;
@property (readwrite, nonatomic) int    sleepMinutesGoal;
@property (readwrite, nonatomic) int    workoutsGoal;

// Values
@property (readwrite, nonatomic) int    averageBPM;
@property (readwrite, nonatomic) int    steps;
@property (readwrite, nonatomic) double distance;
@property (readwrite, nonatomic) int    calories;
@property (readwrite, nonatomic) int    sleepMinutes;
@property (readwrite, nonatomic) int    workouts;
@property (readwrite, nonatomic) int    activeTimeMinutes;
@property (readwrite, nonatomic) int    totalExposureTime;
@property (readwrite, nonatomic) int    exposureTimeDuration;
@property (readwrite, nonatomic) NSArray *workoutInfoArray;

- (void)initializeObjects;

@end

@implementation SFADashboardViewController
@synthesize statisticalDataHeader;

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initializeObjects];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _userProfile = [SalutronUserProfile getData];
    
    //[self initializeObjects];
    //[self.tableView reloadData];
    
    //Allow drag and drop
    [self.tableView setAllowsSelectionDuringEditing:YES];
    [self.tableView setEditing:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) shouldAutorotate
{
    return NO;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        /*if (_watchModel == WatchModel_Core_C200 ||
            _watchModel == WatchModel_Move_C300)
            return 5;*/
        return 8;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    /*if (section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardHeaderCell"];
        return cell;
    }*/
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == _dashboardPosition.bpmRow)
        {
            if (self.averageBPM == 0)
            {
                if (self.date.isToday)
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardCheckBPMCell"];
                    return cell;
                }
                else
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardNoBPMCell"];
                    return cell;
                }
            }
            else
            {
                SFADashboardBPMCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardBPMCell"];
                [cell setContentsWithIntValue:self.averageBPM minValue:self.minBPM maxValue:self.maxBPM];
                return cell;
            }
        }
        else if (indexPath.row == _dashboardPosition.stepsRow)
        {
            SFADashboardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardStepsCell"];
            [cell setContentsWithIntValue:self.steps goal:self.stepsGoal];
            return cell;
        }
        else if (indexPath.row == _dashboardPosition.distanceRow)
        {
            SFADashboardDistanceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardDistanceCell"];
            [cell setContentsWithDoubleValue:self.distance goal:self.distanceGoal];
            return cell;
        }
        else if (indexPath.row == _dashboardPosition.caloriesRow)
        { 
            SFADashboardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardCaloriesCell"];
            [cell setContentsWithIntValue:self.calories goal:self.caloriesGoal];
            return cell;
        } else if (indexPath.row == _dashboardPosition.actigraphyRow) {
            if (self.date.isTomorrow) {
                SFADashboardSleepCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardNoActiveTimeCell"];
                return cell;
            } else {
                SFADashboardSleepCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardActiveTimeCell"];
                [cell setContentsWithHours:self.activeTimeMinutes / 60 minutes:self.activeTimeMinutes % 60];
                return cell;
            }
        }
        else if (indexPath.row == _dashboardPosition.sleepRow)
        {
            if (self.sleepMinutes == 0)
            {
                if (self.date.isToday)
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardCheckSleepCell"];
                    return cell;
                }
                else
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardNoSleepCell"];
                    return cell;
                }
            }
            else
            {
                SFADashboardSleepCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardSleepCell"];
                [cell setContentsWithIntValue:self.sleepMinutes goal:self.sleepMinutesGoal];
                return cell;
            }
        }
        else if (indexPath.row == _dashboardPosition.workoutRow)
        {
            if (self.workouts == 0)
            {
                if (self.date.isToday)
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardCheckWorkoutCell"];
                    return cell;
                }
                else
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardNoWorkoutCell"];
                    return cell;
                }
            }
            else
            {
                SFADashboardCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardWorkoutsCell"];
                NSString *workouts      = [NSString stringWithFormat:@"%i", self.workouts];
                cell.value.text         = workouts;
                return cell;
            }
        }
        else if (indexPath.row == _dashboardPosition.lightPlotRow){
            SFADashboardSleepCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFADashboardLightCell"];
            cell.type = @"SFADashboardLightCell";
            //self.totalExposureTime = 29;
            [cell setContentsWithIntValue:self.totalExposureTime goal:self.exposureTimeDuration];
            return cell;
        }
    }
    
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    /*if (section == 0)
    {
        return 40.0f;
    }*/
    
    return 0; 
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        //temporary commenting for testing only
        if (indexPath.row == _dashboardPosition.workoutRow &&
                 (_watchModel == WatchModel_Move_C300 || _watchModel == WatchModel_Move_C300_Android))
        {
            //remove workout cell if watch does not support it
            return 0;
        }
        if (indexPath.row == _dashboardPosition.sleepRow &&
                 (_watchModel == WatchModel_Move_C300 || _watchModel == WatchModel_Move_C300_Android))
        {
            //remove sleep cell if watch does not support it
            return 0;
        }
        if (indexPath.row == _dashboardPosition.actigraphyRow &&
            (_watchModel == WatchModel_Move_C300 || _watchModel == WatchModel_Move_C300_Android))
        {
            //remove actigraphy cell if watch does not support it
            return 0;
        }
        if (indexPath.row == _dashboardPosition.lightPlotRow &&
            (_watchModel == WatchModel_Zone_C410 ||
             _watchModel == WatchModel_R420 ||
             _watchModel == WatchModel_Move_C300 ||
             _watchModel == WatchModel_Move_C300_Android))
        {
            //remove lightPlot cell if watch does not support it
            return 0;
        }
        
        return 104.0f;
    }
    
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == _dashboardPosition.bpmRow && self.averageBPM == 0)
        {
            return ;
        }
        else if (indexPath.row == _dashboardPosition.workoutRow && self.workouts == 0)
        {
            return ;
        }
        //else if(indexPath.row == _dashboardPosition.sleepRow && self.sleepMinutes == 0)
        //{
        //    return;
        //}
        else if ([self.delegate respondsToSelector:@selector(dashboardViewController:didSelectDashboardItem:)])
        {
            [self.delegate dashboardViewController:self didSelectDashboardItem:indexPath.row];
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    //change cell position
    [_dashboardPosition setFromRow:fromIndexPath.row toRow:toIndexPath.row];
    //[tableView reloadData];
    
    if ([self.delegate conformsToProtocol:@protocol(SFADashboardDelegate)] &&
        [self.delegate respondsToSelector:@selector(didUpdateDashboardPositionInDashboardViewController:)]) {
        [self.delegate didUpdateDashboardPositionInDashboardViewController:self];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}


#pragma mark - Getters

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext)
    {
        //SFASalutronFitnessAppDelegate *appDelegate  = [UIApplication sharedApplication].delegate;
        _managedObjectContext                       = [JDACoreData sharedManager].context;//appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

#pragma mark - Private Methods

- (void)initializeObjects
{
    // Data
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    
    // Goals
    self.minBPM                 = 40;
    self.maxBPM                 = 240;
    self.stepsGoal          = [userDefaults integerForKey:STEP_GOAL];
    self.distanceGoal       = [userDefaults doubleForKey:DISTANCE_GOAL];
    self.caloriesGoal       = [userDefaults integerForKey:CALORIE_GOAL];
    self.sleepMinutesGoal   = [userDefaults integerForKey:SLEEP_GOAL];
    
    self.workoutsGoal       = 10;
    
    //initalize dashboard helper
    _dashboardPosition  = [[SFADashboardCellPositionHelper alloc] init];
    
    //Get watch model connected
    NSUserDefaults *_userDefaults   = [NSUserDefaults standardUserDefaults];
    _watchModel                     = [[_userDefaults objectForKey:CONNECTED_WATCH_MODEL] integerValue];
}

- (void)getDataForDate:(NSDate *)date
{
    // Date
    NSArray *data                   = [StatisticalDataHeaderEntity statisticalDataHeaderEntitiesForDate:date];
    
    if (data)
    {
        if (data.count > 0)
        {
            StatisticalDataHeaderEntity *dataHeader     = [data objectAtIndex:0];
            
            //self.totalExposureTime = [SFALightDataManager getTotalExposureTime:[LightDataPointEntity lightDataPointsForDate:date]];
            self.totalExposureTime = dataHeader.totalExposureTime.integerValue;
            self.exposureTimeDuration = [SFALightDataManager getExposureTimeDuration:[LightDataPointEntity lightDataPointsForDate:date]];
            
            
            statisticalDataHeader                       = dataHeader;
            self.averageBPM                             = [StatisticalDataPointEntity getAverageBPMForDate:date];
            //self.steps                                  = dataHeader.totalSteps.intValue;
            //self.calories                               = dataHeader.totalCalorie.intValue;
            //self.sleepMinutes                           = [self getTotalSleepForDate:date];
            
            
#warning uncomment for r420 testing only
            if (self.watchModel == WatchModel_R420) {
                NSArray *previousDayWorkouts = [WorkoutHeaderEntity getWorkoutInfoWithDate:[date dateByAddingTimeInterval:-DAY_SECONDS]];
                
                BOOL hasSpillOverWorkout = NO;
                for (WorkoutHeaderEntity *workout in previousDayWorkouts){
                    if ([workout hasSpillOverWorkoutMinutes]){
                        hasSpillOverWorkout = YES;
                        break;
                    }
                }
                self.workouts                               = hasSpillOverWorkout ? self.workoutInfoArray.count + 1 : self.workoutInfoArray.count;
                
                //check for continuous heart rate
#warning no case for hr with normal and continuous data
                if (self.workouts > 0) {
                    
                    NSArray *dataPoints = [[StatisticalDataPointEntity dataPointsForDate:date] copy];
                    NSArray *continuousHR = [WorkoutHeaderEntity getWorkoutHeartRateWithMinMaxDataWithDate:date];
                    
                    //group hr per 10 mins
                    int totalHR = 0;
                    int totalCount = 0;
                    NSInteger datapointIndex = [[[continuousHR firstObject] objectForKey:@"index"] integerValue]/600;
                    NSMutableArray *hrArray = [[NSMutableArray alloc] init];
                    for (NSDictionary *hrEntity in continuousHR) {
                        
                        NSInteger hrValue = [hrEntity[@"hrData"] integerValue];
                        NSInteger minhrValue = hrValue;//[hrEntity[@"min"] integerValue];
                        NSInteger maxhrValue = hrValue;//[hrEntity[@"max"] integerValue];
                        NSInteger index = [hrEntity[@"index"] integerValue];
                        
                        if (hrValue > 0) {
                            if (datapointIndex == index/600) {
                                totalHR += hrValue;
                                totalCount++;
                                if ([hrEntity isEqual:[continuousHR lastObject]]) {
                                    //save avg hr
                                    NSInteger averageHR = totalHR/totalCount;
                                    [hrArray addObject:@(averageHR)];
                                }
                            }
                            else{
                                //save avg hr
                                NSInteger averageHR = totalHR/totalCount;
                                [hrArray addObject:@(averageHR)];
                                //next index
                                datapointIndex = index/600;
                                
                                totalCount = 0;
                                totalHR = 0;
                                totalHR += hrValue;
                                totalCount++;
                                
                                if ([hrEntity isEqual:[continuousHR lastObject]]) {
                                    //save avg hr
                                    NSInteger averageHR = totalHR/totalCount;
                                    [hrArray addObject:@(averageHR)];
                                }
                            }
                        }
                        else{
                            if ([hrEntity isEqual:[continuousHR lastObject]]) {
                                //save avg hr
                                NSInteger averageHR = totalHR/totalCount;
                                if (averageHR > 0) {
                                    [hrArray addObject:@(averageHR)];
                                }
                            }
                        }
                    }
                    
                    
                    for (StatisticalDataPointEntity *dataPoint in dataPoints)
                    {
                        if (dataPoint.averageHR.integerValue > 0) {
                            [hrArray addObject:@(dataPoint.averageHR.intValue)];
                        }
                    }
                    
                    NSInteger averageBPM = 0;
                    NSInteger totalBPMCount = 0;
                    NSInteger totalBPM = 0;
                    for (NSNumber *hrDataDict in hrArray) {
                        NSInteger hrDataDictAve = [hrDataDict integerValue];
                        if (hrDataDictAve > 0) {
                            totalBPM += hrDataDictAve;
                            totalBPMCount++;
                        }
                    }
                    averageBPM = totalBPM/totalBPMCount;
                    
                    self.averageBPM = averageBPM;

                   // self.minBPM = minhr;
                   // self.maxBPM = maxhr;
                }
            }
            else{
                NSArray *previousDayWorkouts = [WorkoutInfoEntity getWorkoutInfoWithDate:[date dateByAddingTimeInterval:-DAY_SECONDS]];
                
                BOOL hasSpillOverWorkout = NO;
                for (WorkoutInfoEntity *workout in previousDayWorkouts){
                    if ([workout hasSpillOverWorkoutMinutes]){
                        hasSpillOverWorkout = YES;
                        break;
                    }
                }
                self.workouts                               = hasSpillOverWorkout ? self.workoutInfoArray.count + 1 : self.workoutInfoArray.count;
            }
            
            
            //self.distance                               = dataHeader.totalDistance.floatValue;
            
            /*if (_userProfile.unit == IMPERIAL) {
                self.distance                           = (dataHeader.totalDistance.floatValue) * 0.621371;
            }
            else {
                self.distance                           = dataHeader.totalDistance.floatValue;
            }*/
            
            data = [[StatisticalDataPointEntity dataPointsForDate:date] copy];
            NSInteger activeTimeMinutes     = 0;
            NSInteger totalSleepDuration    = 0;
            
            if (data > 0) {
                NSDate *yesterday               = [date dateByAddingTimeInterval:-DAY_SECONDS];
                NSArray *yesterdaySleeps        = [SleepDatabaseEntity sleepDatabaseForDate:yesterday];
                NSArray *sleeps                 = [SleepDatabaseEntity sleepDatabaseForDate:date];
                
                NSMutableArray *sleepIndexes        = [NSMutableArray new];
                
                for (SleepDatabaseEntity *sleep in yesterdaySleeps)
                {
                    NSInteger startIndex    = (sleep.sleepStartHour.integerValue * 6) + (sleep.sleepStartMin.integerValue / 10);
                    NSInteger endIndex      = sleep.adjustedSleepEndMinutes/10;
                    
                    if (startIndex >= endIndex)
                    {
                        for (NSInteger a = 0; a <= endIndex; a++)
                        {
                            NSNumber *number = [NSNumber numberWithInt:a];
                            [sleepIndexes addObject:number];
                        }
                    }
                    
                    NSInteger sleepStartMinutes = (sleep.sleepStartHour.integerValue * 60) + sleep.sleepStartMin.integerValue;
                    NSInteger sleepEndMinutes   = sleep.adjustedSleepEndMinutes;
                    
                    if (sleepStartMinutes >= sleepEndMinutes) {
                        totalSleepDuration += sleep.sleepDuration.integerValue;
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
                    
                    NSInteger sleepStartMinutes = (sleep.sleepStartHour.integerValue * 60) + sleep.sleepStartMin.integerValue;
                    NSInteger sleepEndMinutes   = sleep.adjustedSleepEndMinutes;
                    
                    if (sleepStartMinutes < sleepEndMinutes) {
                        totalSleepDuration += sleep.sleepDuration.integerValue;
                    }
                }

                
                CGFloat totalCalories    = 0.0f;
                CGFloat totalDistance    = 0.0f;
                CGFloat totalSteps       = 0.0f;
                
                for (StatisticalDataPointEntity *dataPoint in data) {
                    NSInteger value = dataPoint.sleepPoint02.integerValue + dataPoint.sleepPoint24.integerValue + dataPoint.sleepPoint46.integerValue;
                    value           += dataPoint.sleepPoint68.integerValue + dataPoint.sleepPoint810.integerValue;
                    NSInteger index = [data indexOfObject:dataPoint];
                    
                    if (![sleepIndexes containsObject:@(index)] &&
                         value >= 40 * 5) {
                        activeTimeMinutes += 10;
                    }
                    totalSteps      += dataPoint.steps.floatValue;
                    totalCalories   += dataPoint.calorie.floatValue;
                    totalDistance   += dataPoint.distance.floatValue;
                }
                self.steps = totalSteps;
                self.calories = totalCalories;
                self.distance = totalDistance;
            }
            
            self.activeTimeMinutes  = activeTimeMinutes;
            self.sleepMinutes       = [self getTotalSleepForDate:date];
            
            return;
        }
    }
    
    // Values
    self.averageBPM         = 0;
    self.steps              = 0;
    self.distance           = 0.0f;
    self.calories           = 0;
    self.sleepMinutes       = 0;
    self.workouts           = 0;
    self.activeTimeMinutes  = 0;
    self.totalExposureTime   = 0;
}

#pragma mark - Get total Sleep

- (NSInteger)getTotalSleepForDate:(NSDate *)date{
    
    NSDate *yesterday               = [date dateByAddingTimeInterval:-DAY_SECONDS];
    NSArray *yesterdaySleeps        = [SleepDatabaseEntity sleepDatabaseForDate:yesterday];
    NSArray *sleeps                 = [SleepDatabaseEntity sleepDatabaseForDate:date];
    NSMutableArray *sleepLogs       = [NSMutableArray new];
    NSMutableArray *sleepLogsGraph  = [[NSMutableArray alloc] init];
    NSInteger totalSleepDuration    = 0;
    
    //check and stop processing if there are no statistical data headers for that date
    NSArray *data                   = [StatisticalDataHeaderEntity statisticalDataHeaderEntitiesForDate:date];
    NSArray *yesterdayData          = [StatisticalDataHeaderEntity statisticalDataHeaderEntitiesForDate:yesterday];
    
    if (yesterdayData && yesterdayData.count > 0){
        for (SleepDatabaseEntity *sleep in yesterdaySleeps)
        {
            NSInteger sleepStartMinutes = (sleep.sleepStartHour.integerValue * 60) + sleep.sleepStartMin.integerValue;
            NSInteger sleepEndMinutes   =  sleep.adjustedSleepEndMinutes;
            //NSInteger sleepEndMinutes   = (sleep.sleepEndHour.integerValue * 60) + sleep.sleepEndMin.integerValue;
            
            if ((sleepStartMinutes >= sleepEndMinutes) ||
                (sleep.sleepStartHour.integerValue >= SLEEP_MAX_HOUR || sleep.sleepEndHour.integerValue >= SLEEP_MAX_HOUR)){
                totalSleepDuration += sleep.sleepDuration.integerValue;
                [sleepLogs addObject:sleep];
                [sleepLogsGraph addObject:sleep];
                continue;
            }
        }
    }
    
    if (data && data.count > 0){
        for (SleepDatabaseEntity *sleep in sleeps)
        {
            NSInteger sleepStartMinutes = (sleep.sleepStartHour.integerValue * 60) + sleep.sleepStartMin.integerValue;
            NSInteger sleepEndMinutes   =  sleep.adjustedSleepEndMinutes;
            //NSInteger sleepEndMinutes   = (sleep.sleepEndHour.integerValue * 60) + sleep.sleepEndMin.integerValue;
            
            if ((sleepStartMinutes < sleepEndMinutes) &&
                (sleep.sleepStartHour.integerValue < SLEEP_MAX_HOUR && sleep.sleepEndHour.integerValue < SLEEP_MAX_HOUR)) {
                totalSleepDuration += sleep.sleepDuration.integerValue;
                [sleepLogsGraph addObject:sleep];
                [sleepLogs addObject:sleep];
            }
        }
    }
    /*
    StatisticalDataHeaderEntity *dataHeader = [data firstObject];
    if (dataHeader){
        totalSleepDuration = [[dataHeader totalSleep] integerValue];
    }
    */
    return totalSleepDuration;
}

- (void)setGoalsWithDate:(NSDate *)date
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *macAddress        = [userDefaults stringForKey:MAC_ADDRESS];
    GoalsEntity *goalsEntity    = [SFAGoalsData goalsFromNearestDate:date
                                                          macAddress:macAddress
                                                       managedObject:self.managedObjectContext];
    if (goalsEntity == nil) {
        // Goals
        self.stepsGoal          = [userDefaults integerForKey:STEP_GOAL];
        self.distanceGoal       = [userDefaults doubleForKey:DISTANCE_GOAL];
        self.caloriesGoal       = [userDefaults integerForKey:CALORIE_GOAL];
        self.sleepMinutesGoal   = [userDefaults integerForKey:SLEEP_GOAL];
    } else {
        self.stepsGoal              = goalsEntity.steps.integerValue;
        self.distanceGoal           = goalsEntity.distance.floatValue;
        self.caloriesGoal           = goalsEntity.calories.integerValue;
        self.sleepMinutesGoal       = goalsEntity.sleep.integerValue;
    }
}

#pragma mark - Public Methods

- (void)setContentsWithDate:(NSDate *)date
{
    self.date           = date;
    if (self.watchModel == WatchModel_R420) {
        _workoutInfoArray   = [WorkoutHeaderEntity getWorkoutInfoWithDate:date];
    }
    else{
        _workoutInfoArray   = [WorkoutInfoEntity getWorkoutInfoWithDate:date];
    }


    [self setGoalsWithDate:date];
    [self getDataForDate:date];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
}

@end
