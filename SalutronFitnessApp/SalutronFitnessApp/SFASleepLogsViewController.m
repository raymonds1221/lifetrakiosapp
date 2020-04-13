//
//  SFASleepLogsViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/27/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SleepDatabaseEntity+Data.h"
#import "TimeDate+Data.h"
#import "NSDate+Comparison.h"

#import "GoalsEntity.h"
#import "SFAGoalsData.h"
#import "JDACoreData.h"

#import "SFASleepDataCell.h"

#import "SFASleepLogsGraphViewController.h"
#import "SFASleepLogDataViewController.h"
#import "SFAMainViewController.h"
#import "SFASleepLogsViewController.h"

#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "SleepSetting+Data.h"

#define SLEEP_LOGS_HEADER_CELL_IDENTIFIER   @"SleepLogHeaderCell"
#define SLEEP_LOGS_CELL_IDENTIFIER          @"SleepDataCell"

#define SLEEP_LOGS_GRAPH_SEGUE_IDENTIFIER   @"SleepLogsToSleepLogsGraph"
#define EDIT_SLEEP_LOG_SEGUE_IDENTIFIER     @"SleepLogsToEditSleepLog"

#define SLEEP_MAX_HOUR                      15 //3pm is the max time for turn over

@interface SFASleepLogsViewController () <UITableViewDataSource, UITableViewDelegate, SFASleepLogsGraphViewControllerDelegate, SFASleepLogDataViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView        *tableView;
@property (weak, nonatomic) IBOutlet UILabel            *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel            *totalSleepTimeHours;
@property (weak, nonatomic) IBOutlet UILabel            *totalSleepTimeMinutes;
@property (weak, nonatomic) IBOutlet UIImageView        *progressIcon;
@property (weak, nonatomic) IBOutlet UILabel            *progress;
@property (weak, nonatomic) IBOutlet UILabel            *goal;
@property (weak, nonatomic) IBOutlet UIView             *progressBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView             *progressBarBackgroundView;
@property (weak, nonatomic) IBOutlet UIView             *landscapeView;


@property (weak, nonatomic) IBOutlet UILabel            *totalTimeAsleep;
@property (weak, nonatomic) IBOutlet UILabel            *sleepStartTime;
@property (weak, nonatomic) IBOutlet UILabel            *sleepEfficiency;
@property (weak, nonatomic) IBOutlet UILabel            *hoursAwake;
@property (weak, nonatomic) IBOutlet UILabel            *wakeAfterSleepOnset;
@property (weak, nonatomic) IBOutlet UILabel            *numberOfAwakenings;
@property (weak, nonatomic) IBOutlet UILabel            *sleepOnsetLatency;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphBackgroundHeight;
@property (weak, nonatomic) IBOutlet UIView *sleepGraphView;

@property (strong, nonatomic) SFASleepLogsGraphViewController *graph;

@property (strong, nonatomic) NSArray *sleepLogs;

@end

@implementation SFASleepLogsViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        self.containerHeight.constant = 160;
        self.graphBackgroundHeight.constant = 130;
        self.sleepGraphView.frame = CGRectMake(self.sleepGraphView.frame.origin.x, self.sleepGraphView.frame.origin.y, self.sleepGraphView.frame.size.width, 300);
    }
    self.navigationItem.title = LS_SLEEP_LOGS;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd yyyy"];
    
    NSString *selectedDate = [dateFormatter stringFromDate:self.calendarController.selectedDate];
    self.dateLabel.text = selectedDate;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd yyyy"];
    
    NSString *selectedDate = [dateFormatter stringFromDate:self.calendarController.selectedDate];
    self.dateLabel.text = selectedDate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SLEEP_LOGS_GRAPH_SEGUE_IDENTIFIER]) {
        self.graph          = (SFASleepLogsGraphViewController *)segue.destinationViewController;
        self.graph.delegate = self;
    } else if ([segue.identifier isEqualToString:EDIT_SLEEP_LOG_SEGUE_IDENTIFIER]) {
        NSIndexPath *indexPath                          = [self.tableView indexPathForSelectedRow];
        SFASleepLogDataViewController *viewController   = (SFASleepLogDataViewController *)segue.destinationViewController;
        viewController.delegate                         = self;
        viewController.mode                             = SFASleepLogDataModeEdit;
        viewController.sleepDatabaseEntity              = self.sleepLogs[indexPath.row];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.landscapeView.hidden = !UIDeviceOrientationIsLandscape(toInterfaceOrientation);
    if (self.landscapeView.hidden) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    else{
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    NSArray *versionComponents = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([versionComponents[0] integerValue] < 8) {
        [self.tableView reloadData];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.tableView.scrollEnabled = (fromInterfaceOrientation != UIInterfaceOrientationPortrait);
    self.tableView.contentOffset = CGPointZero;
    
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.landscapeView.hidden) {
        return 1;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [tableView dequeueReusableCellWithIdentifier:SLEEP_LOGS_HEADER_CELL_IDENTIFIER];
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.sleepLogs.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SFASleepDataCell *cell = [tableView dequeueReusableCellWithIdentifier:SLEEP_LOGS_CELL_IDENTIFIER];
        SleepDatabaseEntity *sleepDatabaseEntity = self.sleepLogs[indexPath.row];
        [cell setContentsWithSleepDatabaseEntity:sleepDatabaseEntity];
        return cell;
    }
    
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate Methods

#pragma mark - SFASleepLogsGraphViewControllerDelegate Methods

- (void)sleepLogsGraphViewController:(SFASleepLogsGraphViewController *)viewController didSelectSleepLog:(SleepDatabaseEntity *)sleepLog
{
    //NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.sleepLogs indexOfObject:sleepLog] inSection:0];
    //[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    //[self performSegueWithIdentifier:EDIT_SLEEP_LOG_SEGUE_IDENTIFIER sender:self];
}

#pragma mark - SFASleepLogDataViewControllerDelegate Methods

- (void)sleepLogDataViewController:(SFASleepLogDataViewController *)viewController didAddSleepDatabaseEntity:(SleepDatabaseEntity *)sleepDatabaseEntity
{
    [self getSleepLogsForDate:self.calendarController.selectedDate];
}

- (void)sleepLogDataViewController:(SFASleepLogDataViewController *)viewController didUpdateSleepDatabaseEntity:(SleepDatabaseEntity *)sleepDatabaseEntity
{
    [self getSleepLogsForDate:self.calendarController.selectedDate];
}

- (void)didDeleteInSleepLogDataViewController:(SFASleepLogDataViewController *)viewController
{
    [self getSleepLogsForDate:self.calendarController.selectedDate];
}

#pragma mark - Private Methods

- (UIColor *)colorForPercent:(CGFloat)percent
{
    if (percent >= 100.0f)
    {
        return PERCENT_100_COLOR;
    }
    else if (percent >= 75.0f)
    {
        return PERCENT_75_COLOR;
    }
    else if (percent >= 50.0f)
    {
        return PERCENT_50_COLOR;
    }
    else if (percent >= 25.0f)
    {
        return PERCENT_25_COLOR;
    }
    
    return PERCENT_0_COLOR;
}

- (UIImage *)goalImageForPercent:(CGFloat)percent
{
    if (percent >= 100.0f)
    {
        return [UIImage imageNamed:@"FitnessResultsIconGoal100"];
    }
    else if (percent >= 75.0f)
    {
        return [UIImage imageNamed:@"FitnessResultsIconGoal75"];
    }
    else if (percent >= 50.0f)
    {
        return [UIImage imageNamed:@"FitnessResultsIconGoal50"];
    }
    else if (percent >= 25.0f)
    {
        return [UIImage imageNamed:@"FitnessResultsIconGoal25"];
    }
    
    return [UIImage imageNamed:@"FitnessResultsIconGoal0"];
}

- (void)getSleepLogsForDate:(NSDate *)date
{
    
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
    NSInteger totalSleepDurationHours   = totalSleepDuration / 60;
    NSInteger totalSleepDurationMinutes = totalSleepDuration % 60;
    self.totalSleepTimeHours.text       = [NSString stringWithFormat:@"%i", totalSleepDurationHours];
    self.totalSleepTimeMinutes.text     = [NSString stringWithFormat:@"%i", totalSleepDurationMinutes];
    self.sleepLogs                      = [sleepLogs copy];
    
    NSInteger percent           = 0;
    NSInteger sleepGoal         = 0;
    NSComparisonResult result   = [date compareToDate:[NSDate date]];
    
    if (result != NSOrderedAscending) {
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        NSData *data                    = [userDefaults objectForKey:SLEEP_SETTING];
        SleepSetting *sleepSetting      = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSInteger hi                    = (sleepSetting.sleep_goal_hi == sleepSetting.sleep_goal_lo) ? 0 : sleepSetting.sleep_goal_hi;
        sleepGoal                       = sleepSetting.sleep_goal_lo + (/*sleepSetting.sleep_goal_*/hi << 8);
    } else {
        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
        NSString *macAddress            = [userDefaults objectForKey:MAC_ADDRESS];
        GoalsEntity *goalsEntity        = [SFAGoalsData goalsFromNearestDate:date
                                                                  macAddress:macAddress
                                                               managedObject:[JDACoreData sharedManager].context];
        sleepGoal                       = goalsEntity.sleep.floatValue;
    }
    
    if (sleepGoal > 0) {
        percent = ((float) totalSleepDuration / sleepGoal) * 100;
    }

    self.goal.text                                  = [NSString stringWithFormat:@"%@ %iH %iM", LS_GOAL_ALL_CAPS, sleepGoal / 60, sleepGoal % 60];
    self.progress.text                              = [NSString stringWithFormat:@"%i%%", percent];
    self.progress.textColor                         = [self colorForPercent:percent];
    self.progressIcon.image                         = [self goalImageForPercent:percent];
    self.progressBarView.backgroundColor            = [self colorForPercent:percent];
    self.progressBarViewWidthConstraint.constant    = (percent / 100.0f) * self.progressBarBackgroundView.frame.size.width;
    
    [self.graph setContentsWithDate:date sleepLogs:sleepLogsGraph];
    [self.tableView reloadData];
    
    self.tableView.contentOffset = CGPointZero;
    
    NSInteger deepSleepCount = 0;
    NSInteger lightSleepCount = 0;
    NSInteger sleepOffsetCount = 0;
    CGFloat lapses = 0;
    
    for (SleepDatabaseEntity *sleep in sleepLogs) {
        deepSleepCount  += sleep.deepSleepCount.integerValue;
        lightSleepCount += sleep.lightSleepCount.integerValue;
        lapses          += sleep.lapses.integerValue;
        sleepOffsetCount += sleep.sleepOffset.integerValue;
    }
    
    CGFloat sleepEfficiency = (deepSleepCount + lightSleepCount) / (lapses + deepSleepCount + lightSleepCount);
    sleepEfficiency         *= 100;
    sleepEfficiency         = isnan(sleepEfficiency) ? 0 : sleepEfficiency;
    
    SleepDatabaseEntity *databaseEntity = [sleepLogs firstObject];
    TimeDate *timeDate = [TimeDate getData];
    self.totalTimeAsleep.text = [NSString stringWithFormat:@"%iH %iM", totalSleepDurationHours, totalSleepDurationMinutes];
    
    self.sleepStartTime.text = [self formatTimeWithHourFormat:timeDate.hourFormat
                                                         hour:databaseEntity.sleepStartHour.integerValue
                                                       minute:databaseEntity.sleepStartMin.integerValue];
    
    // remove AM or PM
    if (timeDate.hourFormat == _24_HOUR) {
        self.sleepStartTime.text = [self.sleepStartTime.text removeTimeHourFormat];
    }
    
    if ([sleepLogs count] == 0) {
        self.sleepStartTime.text = @"";
    }
    
    self.sleepEfficiency.text = [NSString stringWithFormat:@"%.0f%%", sleepEfficiency];
    
    NSInteger waso = lapses*2;
    NSInteger wasoMinutes =  waso%60;
    NSInteger wasoHours = waso/60;
    
    self.wakeAfterSleepOnset.text = [NSString stringWithFormat:@"%iH %iM", wasoHours, wasoMinutes];
    self.numberOfAwakenings.text = [NSString stringWithFormat:@"%i",(int)lapses];
    
    NSInteger hoursAwake = 1440 - totalSleepDuration;
    NSInteger hoursAwakeMinutes = hoursAwake%60;
    NSInteger hoursAwakeHours = hoursAwake/60;
    
    self.hoursAwake.text =[NSString stringWithFormat:@"%iH %iM", hoursAwakeHours, hoursAwakeMinutes];
    
    SleepSetting *sleepSetting = [SFAUserDefaultsManager sharedManager].sleepSetting;
    if (sleepSetting.sleep_mode == 1){
        self.sleepOnsetLatency.text = [NSString stringWithFormat:@"%i",sleepOffsetCount];
    }else{
        self.sleepOnsetLatency.text = [NSString stringWithFormat:@"0"];
    }
    
}

- (NSString *)formatTimeWithHourFormat:(HourFormat)hourFormat hour:(NSInteger)hour minute:(NSInteger)minute
{
    NSString *timeAMPM = @"";
    
    if (hourFormat == _12_HOUR) {
        timeAMPM = hour < 12 ? LS_AM : LS_PM;
        hour = hour > 12 ? hour - 12 : hour;
        hour = hour == 0 ? 12 : hour;
    }
    
    NSString *minuteString = [NSString stringWithFormat:@"%@%i", minute < 10 ? @"0" : @"", minute];
    NSString *time = [NSString stringWithFormat:@"%i:%@ %@", hour, minuteString, timeAMPM];
    
    return time;
}

#pragma mark - Public Methods

- (void)setContentsWithDate:(NSDate *)date
{
    [self getSleepLogsForDate:date];
}

@end
