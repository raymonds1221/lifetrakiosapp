//
//  SFALightPlotViewController.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 8/22/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFALightPlotViewController.h"

#import "SFAMainViewController.h"
#import "SFASlidingViewController.h"
#import "SFAFunFactsLifeTrakViewController.h"

#import "SFALightPlotGraphViewController.h"
#import "StatisticalDataHeaderEntity+StatisticalDataHeaderEntityCategory.h"
#import "LightDataPointEntity+Data.h"
#import "LightDataPointEntity+GraphData.h"
#import "JDAPickerView.h"
#import "JDAKeyboardAccessory.h"
#import "SFALightDataTableViewController.h"

#import "DayLightAlertEntity+Data.h"
#import "NightLightAlertEntity+Data.h"
#import "SFALightDataManager.h"

#import "UIViewController+Helper.h"

#import "TimeDate+Data.h"

#define LIGHT_PLOT_GRAPH_SEGUE_IDENTIFIER @"lightPlotGraphVC"

@interface SFALightPlotViewController ()<SFALightPlotGraphViewControllerDelegate,JDAPickerViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewLeadingConstraints;


// PORTRAIT
@property (weak, nonatomic) IBOutlet UIView *portraitContainerView;
@property (weak, nonatomic) IBOutlet UILabel *portraitTotalLightExposureMinuteLabel;
@property (weak, nonatomic) IBOutlet UILabel *portraitTotalLightExposureHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *portraitAllLightLabel;
@property (weak, nonatomic) IBOutlet UILabel *portraitBlueLightLabel;
@property (weak, nonatomic) IBOutlet UILabel *portraitWristOffLabel;
@property (weak, nonatomic) IBOutlet UILabel *portraitMorningExpLevel;
@property (weak, nonatomic) IBOutlet UILabel *portraitEveningExpLevel;
@property (weak, nonatomic) IBOutlet UIButton *portraitInfoButton;

@property (weak, nonatomic) IBOutlet UIImageView    *portraitWristOffIcon;
@property (weak, nonatomic) IBOutlet UILabel        *portraitWristOffLabel_new;

// LANDSCAPE
@property (weak, nonatomic) IBOutlet UIView *landscapeContainerView;
@property (weak, nonatomic) IBOutlet UILabel *landscapeTotalLightExposureMinuteLabel;
@property (weak, nonatomic) IBOutlet UILabel *lanscapeTotalLightExposureHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *landscapeAllLightLabel;
@property (weak, nonatomic) IBOutlet UILabel *landscapeBlueLightLabel;
@property (weak, nonatomic) IBOutlet UILabel *landscapeWristOffLabel;
@property (weak, nonatomic) IBOutlet UILabel *landscapeAllLightThresholdLabel;
@property (weak, nonatomic) IBOutlet UILabel *landscapeBlueLightThresholdLabel;
@property (weak, nonatomic) IBOutlet UILabel *landscapeDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *landscapeAllLightLXLabel;
@property (strong, nonatomic) IBOutlet UILabel *landscapeBlueLightLXLabel;
@property (weak, nonatomic) IBOutlet UIButton *landscapeInfoButton;

@property (weak, nonatomic) IBOutlet UILabel *yAxisLabel01;
@property (weak, nonatomic) IBOutlet UILabel *yAxisLabel02;
@property (weak, nonatomic) IBOutlet UILabel *yAxisLabel03;
@property (weak, nonatomic) IBOutlet UILabel *yAxisLabel04;
@property (weak, nonatomic) IBOutlet UILabel *yAxisLabel05;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *containerLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landscapeBottomConstraints;


@property (weak, nonatomic) IBOutlet UIView *graphView;
@property (weak, nonatomic) IBOutlet UIView *graphContainerView;

@property (strong, nonatomic) SFALightPlotGraphViewController *graph;

@property (nonatomic, strong) JDAPickerView *pickerView;

//@property (strong, nonatomic) NSMutableArray *barGraphDataArray;

@property (weak, nonatomic) IBOutlet UIImageView *playHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *playHeadTime;

@property (readwrite, nonatomic) NSInteger  month;
@property (readwrite, nonatomic) NSInteger  year;
@property (readwrite, nonatomic) NSInteger  week;


@property (weak, nonatomic) IBOutlet UIView *viewBottomGrayLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphViewBackgroundHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playheadHeight;

@end

@implementation SFALightPlotViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeObjects];
    
    // Do any additional setup after loading the view.
}

/*
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self updateFramesIfNeeded];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self performSelector:@selector(updateFramesIfNeeded) withObject:nil afterDelay:0.05f];
}

- (void)updateFramesIfNeeded
{
    // adjustments for french UI because the labels will have two lines
    if (LANGUAGE_IS_FRENCH) {
        CGRect frame = self.portraitWristOffLabel_new.frame;
        frame.origin.x = 166;
        self.portraitWristOffLabel_new.frame = frame;
        
        frame = self.portraitWristOffIcon.frame;
        frame.origin.x = 155;
        self.portraitWristOffIcon.frame = frame;
    }
}
 */

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.graphViewTopConstraint.constant = 45;
        self.landscapeContainerView.hidden = YES;
        self.portraitContainerView.hidden = NO;
        
        self.playHeadImage.hidden = YES;
        self.playHeadTime.hidden = YES;
        
        self.containerViewWidthConstraint.constant  = self.view.window.frame.size.width;
        self.pickerView.selectedIndex = SFADateRangeDay;
        self.landscapeBottomConstraints.constant = 30;
    }
    else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.graphViewTopConstraint.constant = -15;
        self.landscapeContainerView.hidden = NO;
        self.portraitContainerView.hidden = YES;
        
        self.playHeadImage.hidden = NO;
        self.playHeadTime.hidden  = NO;
        
        self.containerViewWidthConstraint.constant  = self.view.window.frame.size.height;
        self.landscapeBottomConstraints.constant = -10;
    }
    
    [self.view endEditing:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (fromInterfaceOrientation == UIInterfaceOrientationPortrait) {
        if (self.isIOS8AndAbove) {
            self.containerViewWidthConstraint.constant  = [UIScreen mainScreen].bounds.size.width;
        } else {
            self.containerViewWidthConstraint.constant  = self.view.window.frame.size.height;
        }
    }
    else {
        if (self.isIOS8AndAbove) {
            self.containerViewWidthConstraint.constant  = [UIScreen mainScreen].bounds.size.width;
        } else {
            self.containerViewWidthConstraint.constant  = self.view.window.frame.size.width;
        }
    }
}

- (void)resetTextLabel
{
    self.playHeadTime.text = @"";
    self.portraitAllLightLabel.text             = @"0";
    self.portraitBlueLightLabel.text            = @"0";
    self.portraitWristOffLabel.text             = @"0";
    self.landscapeAllLightLabel.text            = @"0";
    self.landscapeBlueLightLabel.text           = @"0";
    self.landscapeWristOffLabel.text            = @"0";
    self.landscapeAllLightThresholdLabel.text   = [NightLightAlertEntity thresholdToString:[NightLightAlertEntity getNightLightAlertThreshold]];
    self.landscapeBlueLightThresholdLabel.text  = [DayLightAlertEntity thresholdToString:[DayLightAlertEntity getDayLightAlertThreshold]];
    self.portraitMorningExpLevel.text           = [DayLightAlertEntity thresholdToString:[DayLightAlertEntity getDayLightAlertThreshold]];
    self.portraitEveningExpLevel.text           = [NightLightAlertEntity thresholdToString:[NightLightAlertEntity getNightLightAlertThreshold]];

    
    if (self.calendarController.calendarMode == SFACalendarDay) {
        self.landscapeAllLightLabel.hidden = NO;
        self.landscapeBlueLightLabel.hidden = NO;
        self.landscapeAllLightLXLabel.hidden = NO;
        self.landscapeBlueLightLXLabel.hidden = NO;
    }
    else{
        self.landscapeAllLightLabel.hidden = YES;
        self.landscapeBlueLightLabel.hidden = YES;
        self.landscapeAllLightLXLabel.hidden = YES;
        self.landscapeBlueLightLXLabel.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeObjects
{
    
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        self.graphContainerHeight.constant = 265;
        self.graphViewBackgroundHeight.constant = 253;
        self.graphViewHeight.constant = 180;
        self.playheadHeight.constant = 175;
    }
    
    self.pickerView = [[JDAPickerView alloc] initWithArray:@[LS_DAILY, LS_WEEKLY, LS_MONTHLY, LS_YEARLY]
                                                  delegate:self];
    self.pickerView.textField = self.textFieldDateRange;
    self.textFieldDateRange.inputView = self.pickerView;
    JDAKeyboardAccessory *keyboardAccessory = [[JDAKeyboardAccessory alloc] initWithDoneAccessoryWithBarStyle:UIBarStyleDefault];
    keyboardAccessory.currentView = self.textFieldDateRange;
    self.textFieldDateRange.inputAccessoryView = keyboardAccessory;
    
    // Set date range border
    self.dateRangeBackgroundView.layer.borderWidth = 1.0f;
    self.dateRangeBackgroundView.layer.borderColor = DISTANCE_LINE_COLOR.CGColor;
    self.dateRangeBackgroundView.layer.cornerRadius = 10.0f;
    
    
    // initial for Bright light exposure
    self.textFieldDateRange.text = LS_DAILY;
    
    self.landscapeWristOffLabel.hidden = YES;
    self.portraitAllLightLabel.hidden = YES;
    self.portraitBlueLightLabel.hidden = YES;
    self.portraitWristOffLabel.hidden = YES;
    
    //self.landscapeAllLightLabel.hidden = YES;
    //self.landscapeBlueLightLabel.hidden = YES;
    //self.landscapeAllLightLXLabel.hidden = YES;
    //self.landscapeBlueLightLXLabel.hidden = YES;
    
    
//    if (LANGUAGE_IS_FRENCH) {
//        CGRect frame = self.yAxisLabel01.frame;
//        frame.origin.x = 200;
//        self.yAxisLabel01.frame = frame;
//        
//        frame = self.yAxisLabel05.frame;
//        frame.origin.x = 20;
//        self.yAxisLabel05.frame = frame;
//    }
}

- (void)setTotalExposureTime:(NSArray *)arrayOfEntites
{
    int exposureInMinutes = [SFALightDataManager getTotalExposureTime:arrayOfEntites];

    NSString *hour      = [NSString stringWithFormat:@"%d", exposureInMinutes / 60];
    NSString *minute    = [NSString stringWithFormat:@"%d", exposureInMinutes % 60];
    
    if (hour.length == 1) {
        hour = [NSString stringWithFormat:@"0%@", hour];
    }
    if (minute.length == 1) {
        minute = [NSString stringWithFormat:@"0%@", minute];
    }
    
    self.portraitTotalLightExposureHourLabel.text   = hour;
    self.portraitTotalLightExposureMinuteLabel.text = minute;
    self.lanscapeTotalLightExposureHourLabel.text   = hour;
    self.landscapeTotalLightExposureMinuteLabel.text= minute;
}

- (void)setTotalExposureTimeWithValue:(NSInteger)totalExposureTime
{
    NSString *hour      = [NSString stringWithFormat:@"%d", totalExposureTime / 60];
    NSString *minute    = [NSString stringWithFormat:@"%d", totalExposureTime % 60];
    
    if (hour.length == 1) {
        hour = [NSString stringWithFormat:@"0%@", hour];
    }
    if (minute.length == 1) {
        minute = [NSString stringWithFormat:@"0%@", minute];
    }
    
    self.portraitTotalLightExposureHourLabel.text   = hour;
    self.portraitTotalLightExposureMinuteLabel.text = minute;
    self.lanscapeTotalLightExposureHourLabel.text   = hour;
    self.landscapeTotalLightExposureMinuteLabel.text= minute;
}

- (NSInteger)totalExposureTimeFromDate:(NSDate *)date
{
    StatisticalDataHeaderEntity *dataHeader = [StatisticalDataHeaderEntity statisticalDataHeaderEntityForDate:date];
    return dataHeader.totalExposureTime.integerValue;
}

- (void)setContentsWithDate:(NSDate *)date
{
    [self resetTextLabel];
    [self.graph setContentsWithDate:date];
    
    NSArray *lightDataPointEntities = [LightDataPointEntity lightDataPointsForDate:date];
    //[self setTotalExposureTime:lightDataPointEntities];
    
    [self setTotalExposureTimeWithValue:[self totalExposureTimeFromDate:date]];
    
    CGFloat allLightTotal = [LightDataPointEntity totalComputedLightForLightDataPointEntitiesArray:lightDataPointEntities lightColor:SFALightColorAll];
    CGFloat blueLightTotal = [LightDataPointEntity totalComputedLightForLightDataPointEntitiesArray:lightDataPointEntities lightColor:SFALightColorBlue];
    CGFloat wristOffTotal = [LightDataPointEntity totalComputedLightForLightDataPointEntitiesArray:lightDataPointEntities lightColor:SFALightcolorWristOff];
    
    self.portraitAllLightLabel.text     = [NSString stringWithFormat:@"%.2f", allLightTotal];
    self.portraitBlueLightLabel.text    = [NSString stringWithFormat:@"%.2f", blueLightTotal];
    self.portraitWristOffLabel.text     = [NSString stringWithFormat:@"%.2f", wristOffTotal];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd yyyy"];
    
    NSString *selectedDate = [dateFormatter stringFromDate:date];
    self.landscapeDateLabel.text = selectedDate;
    if (!isinf(self.graph.maxYTipValue)) {
        [self setYAxisDailyLabelWithMaxValue:self.graph.maxYTipValueInLux];
    }
    else{
        [self setYAxisLabelHidden];
    }
}

- (void)setYAxisLabelHidden{
    self.yAxisLabel01.hidden = YES;
    self.yAxisLabel02.hidden = YES;
    self.yAxisLabel03.hidden = YES;
    self.yAxisLabel04.hidden = YES;
    self.yAxisLabel05.hidden = YES;
}

- (void)setYAxisDailyLabelWithMaxValue:(CGFloat)maxYTipValue
{
    self.yAxisLabel01.hidden = YES;
    self.yAxisLabel02.hidden = YES;
    self.yAxisLabel03.hidden = YES;
    self.yAxisLabel04.hidden = YES;
    self.yAxisLabel05.hidden = YES;
    
    self.containerLeftConstraint.constant = 10.0f;
    /*
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithInteger:(int)maxYTipValue]];
    self.yAxisLabel01.text = [NSString stringWithFormat:@"%@ LUX", formatted];
    self.yAxisLabel02.text = [NSString stringWithFormat:@"%i LUX", (int)(maxYTipValue/4) *3];
    self.yAxisLabel03.text = [NSString stringWithFormat:@"%i LUX", (int)(maxYTipValue/4) *2];
    self.yAxisLabel04.text = [NSString stringWithFormat:@"%i LUX", (int)(maxYTipValue/4) *1];
    self.yAxisLabel05.text = [NSString stringWithFormat:@"%i LUX", (int)(maxYTipValue/4) *0];
     */
}

- (void)setYAxisTimeLabelWithMaxValue
{
    SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    
    self.yAxisLabel01.hidden = NO;
    self.yAxisLabel02.hidden = YES;
    self.yAxisLabel03.hidden = YES;
    self.yAxisLabel04.hidden = YES;
    self.yAxisLabel05.hidden = NO;
    
    self.containerLeftConstraint.constant = 50.0f;
    
    self.yAxisLabel01.text = /*userDefaultsManager.timeDate.hourFormat == */LANGUAGE_IS_FRENCH ? (userDefaultsManager.timeDate.hourFormat == _12_HOUR ? @"11:59 APRÈS-MIDI" : @"23h59") : (userDefaultsManager.timeDate.hourFormat == _12_HOUR ? @"11:59 PM" : @"23:59");
    self.yAxisLabel05.text = /*userDefaultsManager.timeDate.hourFormat == */LANGUAGE_IS_FRENCH ? (userDefaultsManager.timeDate.hourFormat == _12_HOUR ? @"12:00 MATIN" : @"00h00") : (userDefaultsManager.timeDate.hourFormat == _12_HOUR ? @"12:00 AM" : @"00:00");
}

- (void)setContentsWithWeek:(NSInteger)week ofYear:(NSInteger)year
{
    self.landscapeDateLabel.text = @"";
    self.week = week;
    self.month = (int)week/4;
    self.year = year;
    [self setYAxisTimeLabelWithMaxValue];
    
    [self setTotalExposureTime:[LightDataPointEntity lightDataPointsForWeek:week ofYear:year daysInWeek:NULL]];
    
    [self.graph setContentsWithWeek:week ofYear:year];
    [self resetTextLabel];
}

- (void)setContentsWithMonth:(NSInteger)month ofYear:(NSInteger)year
{
    self.landscapeDateLabel.text = @"";
    self.month = month;
    self.year = year;
    [self setYAxisTimeLabelWithMaxValue];
    
    [self setTotalExposureTime:[LightDataPointEntity lightDataPointsForMonth:month ofYear:year daysInMonth:NULL]];
    
    [self.graph setContentsWithMonth:month ofYear:year];
    [self resetTextLabel];
}

- (void)setContentsWithYear:(NSInteger)year
{
    self.landscapeDateLabel.text = @"";
    self.year = year;
    [self setYAxisTimeLabelWithMaxValue];
    
    [self setTotalExposureTime:[LightDataPointEntity lightDataPointsForYear:year daysInYear:NULL]];
    
    [self.graph setContentsWithYear:year];
    [self resetTextLabel];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:LIGHT_PLOT_GRAPH_SEGUE_IDENTIFIER]) {
        self.graph          = (SFALightPlotGraphViewController *)segue.destinationViewController;
        self.graph.delegate = self;
    }
}

#pragma mark - SFALightPlotGraphViewController delegate

- (void)graphViewController:(SFALightPlotGraphViewController *)graphViewController didChangeDataPoint:(NSInteger)index
{
    if ((self.calendarController.calendarMode == SFACalendarMonth ||
        self.calendarController.calendarMode == SFACalendarYear)
        || self.calendarController.calendarMode == SFACalendarWeek) {
        
        if (self.calendarController.calendarMode == SFACalendarWeek) {
            
            if (index < 1) {
                index = 1;
            }
            /*
            if (index > 6) {
                index = 6;
            }
            */
            NSCalendar *calendar            = [NSCalendar currentCalendar];
            NSDateComponents *components    = [NSDateComponents new];
            components.month                = self.month;
            components.year                 = self.year;
            components.week                 = self.week;
           // components.day                  = index;// + ((self.week % 4) * 7);
            components.weekday              = index;
            NSDate *date                    = [calendar dateFromComponents:components];
            NSDateFormatter *formatter      = [NSDateFormatter new];
            
            TimeDate *timeDate = [TimeDate getData];
            
            if (timeDate.dateFormat == 0) {
                formatter.dateFormat    = @"dd MMMM, YYYY";
            } else {
                formatter.dateFormat    = @"MMMM dd, YYYY";
            }
            
            self.landscapeDateLabel.text = [formatter stringFromDate:date];
            
            //[self setTotalExposureTime:[LightDataPointEntity lightDataPointsForDate:date]];
            [self setTotalExposureTimeWithValue:[self totalExposureTimeFromDate:date]];
            
            self.landscapeAllLightThresholdLabel.text = [NightLightAlertEntity thresholdToString:[NightLightAlertEntity getNightLightAlertThreshold]];
            self.landscapeBlueLightThresholdLabel.text = [DayLightAlertEntity thresholdToString:[DayLightAlertEntity getDayLightAlertThreshold]];
            
        } else if (self.calendarController.calendarMode == SFACalendarMonth) {
            NSCalendar *calendar            = [NSCalendar currentCalendar];
            NSDateComponents *components    = [NSDateComponents new];
            components.month                = self.month;
            components.year                 = self.year;
            components.day                  = index;// + 1;
            NSDate *date                    = [calendar dateFromComponents:components];
            NSDateFormatter *formatter      = [NSDateFormatter new];
            
            TimeDate *timeDate = [TimeDate getData];
            
            if (timeDate.dateFormat == 0) {
                formatter.dateFormat    = @"dd MMMM, yyyy";
            } else {
                formatter.dateFormat    = @"MMMM dd, yyyy";
            }
            
            self.landscapeDateLabel.text = [formatter stringFromDate:date];
            //[self setTotalExposureTime:[LightDataPointEntity lightDataPointsForDate:date]];
            [self setTotalExposureTimeWithValue:[self totalExposureTimeFromDate:date]];
            
        } else if (self.calendarController.calendarMode == SFACalendarYear) {
           // index -= 1;
            NSCalendar *calendar            = [NSCalendar currentCalendar];
            NSDateComponents *components    = [NSDateComponents new];
            components.month                = 1;
            components.day                  = 1;
            components.year                 = self.year;
            NSDate *firstDate               = [calendar dateFromComponents:components];
            NSDate *date                    = [firstDate dateByAddingTimeInterval:DAY_SECONDS * index];
            NSDateFormatter *formatter      = [NSDateFormatter new];
            
            TimeDate *timeDate = [TimeDate getData];
            
            if (timeDate.dateFormat == 0) {
                formatter.dateFormat    = @"dd MMMM, yyyy";
            } else {
                formatter.dateFormat    = @"MMMM dd, yyyy";
            }
            
            self.landscapeDateLabel.text = [formatter stringFromDate:date];
            
            //[self setTotalExposureTime:[LightDataPointEntity lightDataPointsForDate:date]];
            [self setTotalExposureTimeWithValue:[self totalExposureTimeFromDate:date]];
        }
        
    }
    
    self.landscapeAllLightLabel.text    = @"0";
    self.landscapeBlueLightLabel.text   = @"0";
    self.landscapeWristOffLabel.text    = @"0";
    
    
    NSString *time = [self.calendarController timeForIndex:index];
    
    NSDictionary *allLight = (NSDictionary *)graphViewController.computeLightDictionary[@"ALL"];
    NSDictionary *blueLight = (NSDictionary *)graphViewController.computeLightDictionary[@"BLUE"];
    NSDictionary *wristOff = (NSDictionary *)graphViewController.computeLightDictionary[@"WRISTOFF"];
    
    if (self.graph.dateRangeSelected == SFADateRangeDay) {
        self.playHeadTime.text = time;
        self.playHeadTime.hidden = NO;
    }
    else {
        self.playHeadTime.hidden = YES;
    }
    
    switch (graphViewController.dateRangeSelected) {
        case SFADateRangeDay: {
            for (SFABarGraphData *graphdata in [LightDataPointEntity getDailyLightBarGraphDataForDate:self.currentDate lightDataPointsArray:nil]) {
                if (graphdata.x == index) {
                    if (graphdata.barColor == SFALightPlotBarColorAllLight) {
                        self.landscapeAllLightLabel.text    = [NSString stringWithFormat:@"%.2f", graphdata.light];
                    }
                    else if (graphdata.barColor == SFALightPlotBarColorBlueLight) {
                        self.landscapeBlueLightLabel.text   = [NSString stringWithFormat:@"%.2f", graphdata.light];
                    }
                }
            }
            break;
        }
        case SFADateRangeWeek:
        case SFADateRangeMonth:
        case SFADateRangeYear:
        {
            if (self.calendarController.calendarMode != SFACalendarYear) {
                index = index-1;
            }
            
            if (index < 0) {
                index = 0;
            }
            NSNumber *allLightTotal = (NSNumber *)allLight[[NSNumber numberWithInt:index]];
            NSNumber *blueLightTotal = (NSNumber *)blueLight[[NSNumber numberWithInt:index]];
            NSNumber *wristOffTotal = (NSNumber *)wristOff[@(index)];
            self.landscapeAllLightLabel.text    = [NSString stringWithFormat:@"%.2f", [allLightTotal floatValue]];
            self.landscapeBlueLightLabel.text   = [NSString stringWithFormat:@"%.2f", [blueLightTotal floatValue]];
            self.landscapeWristOffLabel.text    = [NSString stringWithFormat:@"%.2f", [wristOffTotal floatValue]];
            break;
        }
        default:
            self.landscapeAllLightLabel.text    = @"0";
            self.landscapeBlueLightLabel.text   = @"0";
            self.landscapeWristOffLabel.text    = @"0";
            break;
    }
}

#pragma mark - Text field delegates

- (void)pickerViewDidSelectIndex:(NSInteger)selectedIndex
{
    SFADateRange dateRange  = SFADateRangeDay;
    
    //Change graph
    if([self.pickerView.selectedValue isEqualToString:DAILY_IDENTIFIER]) {
        dateRange = SFADateRangeDay;
    }
    else if([self.pickerView.selectedValue isEqualToString:WEEKLY_IDENTIFIER]) {
        dateRange = SFADateRangeWeek;
    }
    else if([self.pickerView.selectedValue isEqualToString:MONTHLY_IDENTIFIER]) {
        dateRange = SFADateRangeMonth;
    }
    else if([self.pickerView.selectedValue isEqualToString:YEARLY_IDENTIFIER])
    {
        dateRange = SFADateRangeYear;
    }
    
    if ([self.delegate conformsToProtocol:@protocol(SFALightPlotViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(lightPlotViewController:didChangeDateRange:)]){
        [self.delegate lightPlotViewController:self didChangeDateRange:dateRange];
        
    }
}

// For testing

- (IBAction)showTableDataClicked:(UIButton *)sender
{
    SFALightDataTableViewController *tableViewController = [[SFALightDataTableViewController alloc] initWithNibName:@"SFALightDataTableViewController" bundle:nil];
    [tableViewController reloadDataWithDate:self.currentDate];
    [self.navigationController pushViewController:tableViewController animated:YES];
}
- (IBAction)portraitInfoButtonClicked:(id)sender {
    SFAFunFactsLifeTrakViewController* vc;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        vc = [[SFAFunFactsLifeTrakViewController alloc] initWithNibName:@"SFAFunFactsLifeTrakViewiPad" bundle:nil];
    }
    else{
        vc = [SFAFunFactsLifeTrakViewController new];
    }
    vc.isLightPlot = YES;
    [self presentViewController:vc animated:YES completion:nil];
    
}
- (IBAction)landscapeInfoButtonClicked:(id)sender {
    SFAFunFactsLifeTrakViewController* vc = [SFAFunFactsLifeTrakViewController new];
    vc.isLightPlot = YES;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
