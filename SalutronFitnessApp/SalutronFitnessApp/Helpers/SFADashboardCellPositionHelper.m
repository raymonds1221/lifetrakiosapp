//
//  SFADashboardCellPositionHelper.m
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 1/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFADashboardCellPositionHelper.h"

#define CALORIES_ROW    @"calories_row"
#define BPM_ROW         @"bpm_row"
#define STEPS_ROW       @"steps_row"
#define DISTANCE_ROW    @"distance_row"
#define ACTIGRAPHY_ROW  @"actigraphy_row"
#define SLEEP_ROW       @"sleep_row"
#define WORKOUT_ROW     @"workout_row"
#define LIGHTPLOT_ROW   @"lightplot_row"

#define TEMPORARY_ROW 10

@interface SFADashboardCellPositionHelper ()

@property (strong, nonatomic) NSUserDefaults *userDefaults;
- (void)_initializeObjects;

@end

@implementation SFADashboardCellPositionHelper

#pragma mark - Constructors
- (id)init
{
    self = [super init];
    if (self) {
        [self _initializeObjects];
    }
    return self;
}

#pragma mark - Getters
- (NSInteger)caloriesRow
{
    return [[_userDefaults objectForKey:CALORIES_ROW] integerValue];
}

- (NSInteger)bpmRow
{
    return [[_userDefaults objectForKey:BPM_ROW] integerValue];
}

- (NSInteger)stepsRow
{
    return [[_userDefaults objectForKey:STEPS_ROW] integerValue];
}

- (NSInteger)distanceRow
{
    return [[_userDefaults objectForKey:DISTANCE_ROW] integerValue];
}

- (NSInteger)actigraphyRow
{
    return [[_userDefaults objectForKey:ACTIGRAPHY_ROW] integerValue];
}

- (NSInteger)sleepRow
{
    return [[_userDefaults objectForKey:SLEEP_ROW] integerValue];
}

- (NSInteger)workoutRow
{
    return [[_userDefaults objectForKey:WORKOUT_ROW] integerValue];
}

- (NSInteger)lightPlotRow
{
    return [[_userDefaults objectForKey:LIGHTPLOT_ROW] integerValue];
}

#pragma mark - Setters
- (void)setCaloriesRow:(NSInteger)caloriesRow
{
    [_userDefaults setObject:[NSNumber numberWithInt:caloriesRow] forKey:CALORIES_ROW];
    [_userDefaults synchronize];
}

- (void)setBpmRow:(NSInteger)bpmRow
{
    [_userDefaults setObject:[NSNumber numberWithInt:bpmRow] forKey:BPM_ROW];
    [_userDefaults synchronize];
}

- (void)setStepsRow:(NSInteger)stepsRow
{
    [_userDefaults setObject:[NSNumber numberWithInt:stepsRow] forKey:STEPS_ROW];
    [_userDefaults synchronize];
}

- (void)setDistanceRow:(NSInteger)distanceRow
{
    [_userDefaults setObject:[NSNumber numberWithInt:distanceRow] forKey:DISTANCE_ROW];
    [_userDefaults synchronize];
}

- (void)setActigraphyRow:(NSInteger)actigraphyRow
{
    [_userDefaults setObject:[NSNumber numberWithInt:actigraphyRow] forKey:ACTIGRAPHY_ROW];
    [_userDefaults synchronize];
}

- (void)setSleepRow:(NSInteger)sleepRow
{
    [_userDefaults setObject:[NSNumber numberWithInt:sleepRow] forKey:SLEEP_ROW];
    [_userDefaults synchronize];
}

- (void)setWorkoutRow:(NSInteger)workoutRow
{
    [_userDefaults setObject:[NSNumber numberWithInt:workoutRow] forKey:WORKOUT_ROW];
    [_userDefaults synchronize];
}

- (void)setLightPlotRow:(NSInteger)lightPlotRow
{
    [_userDefaults setObject:[NSNumber numberWithInt:lightPlotRow] forKey:LIGHTPLOT_ROW];
    [_userDefaults synchronize];
}

#pragma mark - Public Methods

- (void)setFromRow:(NSInteger)fromRow toRow:(NSInteger)toRow
{
    [self updateFromRow:fromRow toRow:TEMPORARY_ROW];
    
    if (fromRow < toRow) {
        for (NSInteger a = fromRow + 1; a <= toRow; a ++) {
            [self updateFromRow:a toRow:a - 1];
        }
    } else {
        for (NSInteger a = fromRow - 1; a >= toRow; a --) {
            [self updateFromRow:a toRow:a + 1];
        }
    }
    
    [self updateFromRow:TEMPORARY_ROW toRow:toRow];
   
    /*NSString *_rowName = @"";
    
    //from row
    if (self.bpmRow == fromRow)
    {
        self.bpmRow = toRow;
        _rowName = BPM_ROW;
    }
    else if (self.stepsRow == fromRow)
    {
        self.stepsRow = toRow;
        _rowName = STEPS_ROW;
    }
    else if (self.distanceRow == fromRow)
    {
        self.distanceRow = toRow;
        _rowName = DISTANCE_ROW;
    }
    else if (self.caloriesRow == fromRow)
    {
        self.caloriesRow = toRow;
        _rowName = CALORIES_ROW;
    }
    else if (self.sleepRow == fromRow)
    {
        self.sleepRow = toRow;
        _rowName = SLEEP_ROW;
    }
    else if (self.workoutRow == fromRow)
    {
        self.workoutRow = toRow;
        _rowName = WORKOUT_ROW;
    }
    
    //to row
    if (self.bpmRow == toRow && ![_rowName isEqualToString:BPM_ROW])
    {
        self.bpmRow = fromRow;
    }
    else if (self.stepsRow == toRow && ![_rowName isEqualToString:STEPS_ROW])
    {
        self.stepsRow = fromRow;
    }
    else if (self.distanceRow == toRow && ![_rowName isEqualToString:DISTANCE_ROW])
    {
        self.distanceRow = fromRow;
    }
    else if (self.caloriesRow == toRow && ![_rowName isEqualToString:CALORIES_ROW])
    {
        self.caloriesRow = fromRow;
    }
    else if (self.sleepRow == toRow && ![_rowName isEqualToString:SLEEP_ROW])
    {
        self.sleepRow = fromRow;
    }
    else if (self.workoutRow == toRow && ![_rowName isEqualToString:WORKOUT_ROW])
    {
        self.workoutRow = fromRow;
    }*/
    
}

#pragma mark - Private Methods

- (void)_initializeObjects
{
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Set default dashboard row values
    if ([_userDefaults objectForKey:BPM_ROW] == nil ||
        [_userDefaults objectForKey:STEPS_ROW] == nil ||
        [_userDefaults objectForKey:DISTANCE_ROW] == nil ||
        [_userDefaults objectForKey:CALORIES_ROW] == nil ||
        [_userDefaults objectForKey:ACTIGRAPHY_ROW] == nil ||
        [_userDefaults objectForKey:SLEEP_ROW] == nil ||
        [_userDefaults objectForKey:WORKOUT_ROW] == nil ||
        [_userDefaults objectForKey:LIGHTPLOT_ROW] == nil ||
        self.bpmRow == self.stepsRow ||
        self.bpmRow == self.distanceRow ||
        self.bpmRow == self.caloriesRow ||
        self.bpmRow == self.sleepRow ||
        self.bpmRow == self.workoutRow)
    {
        self.bpmRow         = 0;
        self.stepsRow       = 1;
        self.distanceRow    = 2;
        self.caloriesRow    = 3;
        self.actigraphyRow  = 4;
        self.sleepRow       = 5;
        self.workoutRow     = 6;
        self.lightPlotRow   = 7;
    }
}

- (void)updateFromRow:(NSInteger)fromRow toRow:(NSInteger)toRow
{
    if (fromRow == self.bpmRow) {
        self.bpmRow = toRow;
    } else if (fromRow == self.stepsRow) {
        self.stepsRow = toRow;
    } else if (fromRow == self.distanceRow) {
        self.distanceRow = toRow;
    } else if (fromRow == self.caloriesRow) {
        self.caloriesRow = toRow;
    } else if (fromRow == self.actigraphyRow) {
        self.actigraphyRow = toRow;
    } else if (fromRow == self.sleepRow) {
        self.sleepRow = toRow;
    } else if (fromRow == self.workoutRow) {
        self.workoutRow = toRow;
    }else if (fromRow == self.lightPlotRow) {
        self.lightPlotRow = toRow;
    }
}


@end
