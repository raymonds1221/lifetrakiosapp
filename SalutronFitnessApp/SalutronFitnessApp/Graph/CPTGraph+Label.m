//
//  CPTGraph+Label.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/13/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "NSDate+Formatter.h"

#import "CPTGraph+Label.h"

#import "SFAGraphTools.h"

#import "TimeDate+Data.h"

#import "NSDate+Util.h"

@implementation CPTGraph (Label)

#pragma mark - Public Methods

- (void)hourLabels
{
    NSMutableArray *labels  = [NSMutableArray new];
    CPTXYAxisSet *axisSet   = (CPTXYAxisSet *) self.axisSet;
    TimeDate *_timeDate     = [TimeDate getData];
    
    for (NSInteger hour = 0; hour <= HOURS_IN_DAY_COUNT; hour++)
    {
        CPTAxisLabel *label;
        
        if (_timeDate.hourFormat == 0) {
            if (hour == 0 || hour == HOURS_IN_DAY_COUNT)
            {
                label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"12%@", LS_AM] textStyle:axisSet.xAxis.labelTextStyle];
            }
            else if (hour == 12)
            {
                label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"12%@", LS_PM] textStyle:axisSet.xAxis.labelTextStyle];
            }
            else
            {
                NSString *time  = hour < 12 ? [NSString stringWithFormat:@"%i%@", hour, LS_AM] : [NSString stringWithFormat:@"%i%@", hour - 12, LS_PM];
                label           = [[CPTAxisLabel alloc] initWithText:time textStyle:axisSet.xAxis.labelTextStyle];
            }
        
            CGFloat x           = [SFAGraphTools xWithMaxX:HOURS_IN_DAY_COUNT xValue:hour];
            label.tickLocation  = CPTDecimalFromCGFloat(x);
        
            [labels addObject:label];
        }
        else {
            if (hour == 0 || hour == HOURS_IN_DAY_COUNT)
            {
                label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"0:00%@", LS_AM] textStyle:axisSet.xAxis.labelTextStyle];
            }
            else if (hour == 12)
            {
                label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"12:00%@", LS_PM] textStyle:axisSet.xAxis.labelTextStyle];
            }
            else
            {
                NSString *time  = hour < 12 ? [NSString stringWithFormat:@"%i:00%@", hour, LS_AM] : [NSString stringWithFormat:@"%i:00%@", hour, LS_PM];
                label           = [[CPTAxisLabel alloc] initWithText:time textStyle:axisSet.xAxis.labelTextStyle];
            }
            
            CGFloat x           = [SFAGraphTools xWithMaxX:HOURS_IN_DAY_COUNT xValue:hour];
            label.tickLocation  = CPTDecimalFromCGFloat(x);
            
            [labels addObject:label];
        }
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)dayLabelsWithWeek:(NSInteger)week ofYear:(NSInteger)year
{
    TimeDate *_timeDate             = [TimeDate getData];
    
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.weekOfYear           = week;
    components.yearForWeekOfYear    = year;
    NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    
    if (_timeDate.dateFormat == 0) {
        dateFormatter.dateFormat        = @"dd MMM";
    }
    else {
        dateFormatter.dateFormat        = @"MMM dd";
    }
    NSMutableArray *labels          = [NSMutableArray new];
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *) self.axisSet;
    
    for (NSInteger day = 0; day < DAYS_IN_WEEK_COUNT; day ++)
    {
        components.weekday          = day + 1;
        NSDate *date                = [calendar dateFromComponents:components];
        NSString *dayString         = [dateFormatter stringFromDate:date];
        CPTAxisLabel *label         = [[CPTAxisLabel alloc] initWithText:dayString textStyle:axisSet.xAxis.labelTextStyle];
        CGFloat x                   = [SFAGraphTools xWithMaxX:DAYS_IN_WEEK_COUNT xValue:day];
        label.tickLocation          = CPTDecimalFromCGFloat(x);
        
        [labels addObject:label];
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)dayLabelsWithMonth:(NSInteger)month ofYear:(NSInteger)year
{
    NSDateComponents *components    = [NSDateComponents new];
    components.month                = month;
    components.year                 = year;
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDate *date                    = [calendar dateFromComponents:components];
    NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSMutableArray *labels          = [NSMutableArray new];
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *) self.axisSet;
    
    for (NSInteger day = 0; day < range.length; day++)
    {
        NSString *dayString = [NSString stringWithFormat:@"%i", day + 1];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:dayString textStyle:axisSet.xAxis.labelTextStyle];
        CGFloat x           = [SFAGraphTools xWithMaxX:range.length xValue:day];
        label.tickLocation  = CPTDecimalFromCGFloat(x);
        
        [labels addObject:label];
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)monthLabels
{
    NSMutableArray *labels  = [NSMutableArray new];
    CPTXYAxisSet *axisSet   = (CPTXYAxisSet *) self.axisSet;
    NSArray *months         = [NSDateFormatter new].shortMonthSymbols;
    
    for (NSString *month in months)
    {
        NSInteger index         = [months indexOfObject:month];
        CPTAxisLabel *label     = [[CPTAxisLabel alloc] initWithText:month textStyle:axisSet.xAxis.labelTextStyle];
        CGFloat x               = [SFAGraphTools xWithMaxX:MONTHS_IN_YEAR_COUNT xValue:index];
        label.tickLocation      = CPTDecimalFromCGFloat(x);
        
        [labels addObject:label];
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

// New Label Methods

- (void)hourPortraitLabelsWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    NSMutableArray *labels      = [NSMutableArray new];
    CPTXYAxisSet *axisSet       = (CPTXYAxisSet *) self.axisSet;
    NSInteger _startHour        = 2;
    NSInteger _endHour          = HOURS_IN_DAY_COUNT - 3;
    TimeDate *_timeDate         = [TimeDate getData];
    NSString *_hourlabel        = LANGUAGE_IS_FRENCH ? (_timeDate.hourFormat == _12_HOUR ? @"12:00 MATIN" : @"00h00") : (_timeDate.hourFormat == _12_HOUR ? @"12:00 AM" : @"00:00");
    NSString *_lastHourLabel    = LANGUAGE_IS_FRENCH ? (_timeDate.hourFormat == _12_HOUR ? @"11:59 APRÈS-MIDI" : @"23h59") : (_timeDate.hourFormat == _12_HOUR ? @"11:59 PM" : @"23:59");
    CPTAxisLabel *label;
    
    label = [[CPTAxisLabel alloc] initWithText:_hourlabel textStyle:axisSet.xAxis.labelTextStyle];
    CGFloat x           = _startHour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
    
    if (LANGUAGE_IS_FRENCH && _timeDate.hourFormat == _12_HOUR) {
        x += 160;
    }
    
    label.tickLocation  = CPTDecimalFromCGFloat(x);
    label.offset        = 7.0f;

    [labels addObject:label];
    
    label = [[CPTAxisLabel alloc] initWithText:_lastHourLabel textStyle:axisSet.xAxis.labelTextStyle];
    x     = _endHour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
    
    if (LANGUAGE_IS_FRENCH && _timeDate.hourFormat == _12_HOUR) {
        x -= 360.0f;
    }
    
    label.tickLocation  = CPTDecimalFromCGFloat(x);
    label.offset        = 7.0f;
    
    [labels addObject:label];
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)hourLabelsWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace graphWidth:(CGFloat)graphWidth
{
    NSMutableArray *labels  = [NSMutableArray new];
    CPTXYAxisSet *axisSet   = (CPTXYAxisSet *) self.axisSet;
    TimeDate *timeDate     = [TimeDate getData];
    BOOL hourFormatMilitary = timeDate.hourFormat;
    
    for (int i = 0; i < HOURS_IN_DAY_COUNT; i++) {
        
        CGFloat value = ((graphWidth / (HOURS_IN_DAY_COUNT+1)) * i);
        CPTAxisLabel *label;
        
        if (i == 0 || i == 24) {
            label = [[CPTAxisLabel alloc] initWithText:hourFormatMilitary ? @"0:00" : @"12AM"
                                             textStyle:axisSet.xAxis.labelTextStyle];
        }
        else if (i < 12) {
            label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:hourFormatMilitary ? @"%i:00" : @"%iAM", i]
                                             textStyle:axisSet.xAxis.labelTextStyle];
        }
        else if (i == 12) {
            // [NSString stringWithFormat:@"12%@00", LANGUAGE_IS_FRENCH ? @"h" : @":"] : [NSString stringWithFormat:@"12%@", LS_PM]
            label = [[CPTAxisLabel alloc] initWithText:hourFormatMilitary ? @"12:00" : @"12PM"
                                             textStyle:axisSet.xAxis.labelTextStyle];
        }
        else if (i > 12 && i < 24) {
            label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:hourFormatMilitary ? @"%i:00" : @"%iPM", hourFormatMilitary ? i : i-12]
                                             textStyle:axisSet.xAxis.labelTextStyle];
        }
        
        label.tickLocation  = CPTDecimalFromCGFloat(value * barSpace);
        label.offset        = 7.0f;
        
        [labels addObject:label];
    }
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)hourLabelsWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    NSMutableArray *labels  = [NSMutableArray new];
    CPTXYAxisSet *axisSet   = (CPTXYAxisSet *) self.axisSet;
    TimeDate *_timeDate     = [TimeDate getData];
    
    for (NSInteger hour = 0; hour < HOURS_IN_DAY_COUNT; hour++)
    {
        CPTAxisLabel *label;
        
        if (_timeDate.hourFormat == 0) {
            if (hour == 0 || hour == HOURS_IN_DAY_COUNT)
            {
                label = [[CPTAxisLabel alloc] initWithText:@"12AM" textStyle:axisSet.xAxis.labelTextStyle];
            }
            else if (hour == 12)
            {
                label = [[CPTAxisLabel alloc] initWithText:@"12PM" textStyle:axisSet.xAxis.labelTextStyle];
            }
            else
            {
                NSString *time  = hour < 12 ? [NSString stringWithFormat:@"%iAM", hour] : [NSString stringWithFormat:@"%iPM", hour - 12];
                label           = [[CPTAxisLabel alloc] initWithText:time textStyle:axisSet.xAxis.labelTextStyle];
            }
        
            CGFloat x           = hour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
            label.tickLocation  = CPTDecimalFromCGFloat(x);
            label.offset        = 7.0f;
        
            [labels addObject:label];
        }
        else {
            if (hour == 0 || hour == HOURS_IN_DAY_COUNT)
            {
                label = [[CPTAxisLabel alloc] initWithText:@"0:00" textStyle:axisSet.xAxis.labelTextStyle];
            }
            else if (hour == 12)
            {
                label = [[CPTAxisLabel alloc] initWithText:@"12:00" textStyle:axisSet.xAxis.labelTextStyle];
            }
            else
            {
                NSString *time  = hour < 12 ? [NSString stringWithFormat:@"%i:00", hour] : [NSString stringWithFormat:@"%i:00", hour];
                label           = [[CPTAxisLabel alloc] initWithText:time textStyle:axisSet.xAxis.labelTextStyle];
            }
            
            CGFloat x           = hour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
            label.tickLocation  = CPTDecimalFromCGFloat(x);
            label.offset        = 7.0f;
            
            [labels addObject:label];
        }
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}


- (void)hourPortraitLabelsForActigraphyWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    NSMutableArray *labels      = [NSMutableArray new];
    CPTXYAxisSet *axisSet       = (CPTXYAxisSet *) self.axisSet;
    NSInteger _startHour        = 2;
    NSInteger _endHour          = HOURS_IN_DAY_COUNT - 2;
    TimeDate *_timeDate         = [TimeDate getData];
    NSString *_hourlabel        = LANGUAGE_IS_FRENCH ? (_timeDate.hourFormat == _12_HOUR ? @"12:00 MATIN" : @"00h00") : (_timeDate.hourFormat == _12_HOUR ? @"12:00 AM" : @"00:00");
    NSString *_lastHourLabel    = LANGUAGE_IS_FRENCH ? (_timeDate.hourFormat == _12_HOUR ? @"11:59 APRÈS-MIDI" : @"23h59") : (_timeDate.hourFormat == _12_HOUR ? @"11:59 PM" : @"23:59");
    
    CPTAxisLabel *label;
    
    CPTMutableTextStyle *textStyle = [axisSet.xAxis.labelTextStyle mutableCopy];
    
    label = [[CPTAxisLabel alloc] initWithText:_hourlabel textStyle:textStyle.copy];
    CGFloat x           = _startHour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
    label.tickLocation  = CPTDecimalFromCGFloat(x);
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        label.offset = 215;
    }
    else{
        label.offset        = 90.0f;
    }
    
    [labels addObject:label];
    
    label = [[CPTAxisLabel alloc] initWithText:_lastHourLabel textStyle:textStyle.copy];
    //x     = _endHour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
    x     = _endHour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
    //x     *= 0.937;
    label.tickLocation  = CPTDecimalFromCGFloat(x);
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        label.offset = 215;
    }
    else{
        label.offset        = 90.0f;
    }
    
    [labels addObject:label];
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)hourPortraitLabelsForLightPlotWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    NSMutableArray *labels      = [NSMutableArray new];
    CPTXYAxisSet *axisSet       = (CPTXYAxisSet *) self.axisSet;
    NSInteger _startHour        = 2;
    NSInteger _endHour          = HOURS_IN_DAY_COUNT-3;
    TimeDate *_timeDate         = [TimeDate getData];
    NSString *_hourlabel        = LANGUAGE_IS_FRENCH ? (_timeDate.hourFormat == _12_HOUR ? @"12:00 MATIN" : @"00h00") : (_timeDate.hourFormat == _12_HOUR ? @"12:00 AM" : @"00:00");
    NSString *_lastHourLabel    = LANGUAGE_IS_FRENCH ? (_timeDate.hourFormat == _12_HOUR ? @"11:59 APRÈS-MIDI" : @"23h59") : (_timeDate.hourFormat == _12_HOUR ? @"11:59 PM" : @"23:59");
    
    CPTAxisLabel *label;
    
    CPTMutableTextStyle *textStyle = [axisSet.xAxis.labelTextStyle mutableCopy];
    
    label = [[CPTAxisLabel alloc] initWithText:_hourlabel textStyle:textStyle.copy];
    CGFloat x           = _startHour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
    
    if (LANGUAGE_IS_FRENCH && _timeDate.hourFormat == _12_HOUR) {
        x += 15.0f;
    }
    
    label.tickLocation  = CPTDecimalFromCGFloat(x);
    label.offset        = 3.0f;
    
    [labels addObject:label];
    
    label = [[CPTAxisLabel alloc] initWithText:_lastHourLabel textStyle:textStyle.copy];
    //x     = _endHour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
    x     = _endHour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
    //x     *= 0.937;
    
    if (LANGUAGE_IS_FRENCH && _timeDate.hourFormat == _12_HOUR) {
        x -= 60.0f;
    }
    
    label.tickLocation  = CPTDecimalFromCGFloat(x);
    label.offset        = 3.0f;
    
    [labels addObject:label];
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)hourLabelsForActigraphyWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    [self hourLabelsWithBarWidth:barWidth barSpace:barSpace];
    
    CPTXYAxisSet *axisSet   = (CPTXYAxisSet *) self.axisSet;
    NSMutableArray *labels  = [[axisSet.xAxis.axisLabels allObjects] mutableCopy];
    
    for (CPTAxisLabel *label in labels) {
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
            label.offset = 215;
        }
        else{
            label.offset = 90.0f;
        }
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)hourLabelsForLightPlotWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    [self hourLabelsWithBarWidth:barWidth barSpace:barSpace];
    
    CPTXYAxisSet *axisSet   = (CPTXYAxisSet *) self.axisSet;
    NSMutableArray *labels  = [[axisSet.xAxis.axisLabels allObjects] mutableCopy];
    
    for (CPTAxisLabel *label in labels) {
        label.offset = 3.0f;
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}


- (void)hourLabelsWithBarWidth:(CGFloat)barWidth
                      barSpace:(CGFloat)barSpace
                    startPoint:(NSInteger)startPoint
                      endPoint:(NSInteger)endPoint
{
    NSMutableArray *labels  = [NSMutableArray new];
    CPTXYAxisSet *axisSet   = (CPTXYAxisSet *) self.axisSet;
    
    for (NSInteger a = startPoint; a <= endPoint; a++)
    {
        if (a % 6 == 0)
        {
            CPTAxisLabel *label;
            NSInteger hour = a / 6;
            
            if (hour == 0 || hour == HOURS_IN_DAY_COUNT)
            {
                label = [[CPTAxisLabel alloc] initWithText:@"12AM" textStyle:axisSet.xAxis.labelTextStyle];
            }
            else if (hour == 12)
            {
                label = [[CPTAxisLabel alloc] initWithText:@"12PM" textStyle:axisSet.xAxis.labelTextStyle];
            }
            else
            {
                NSString *time  = hour < 12 ? [NSString stringWithFormat:@"%iAM", hour] : [NSString stringWithFormat:@"%iPM", hour - 12];
                label           = [[CPTAxisLabel alloc] initWithText:time textStyle:axisSet.xAxis.labelTextStyle];
            }
            
            CGFloat x           = (a - startPoint) * (barWidth + barSpace) + ((barWidth + barSpace) / 2);
            label.tickLocation  = CPTDecimalFromCGFloat(x);
            label.offset        = 7.0f;
            
            [labels addObject:label];
        }
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)dayPortraitLabelsWithWeek:(NSInteger)week ofYear:(NSInteger)year barWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    TimeDate *_timeDate             = [TimeDate getData];
    
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.weekOfYear           = week;
    components.yearForWeekOfYear    = year;
    NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    
    if (_timeDate.dateFormat == _DDMM) {
        dateFormatter.dateFormat        = @"dd MMM";
    }
    else {
        dateFormatter.dateFormat        = @"MMM dd";
    }
    
    NSMutableArray *labels          = [NSMutableArray new];
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *) self.axisSet;
    
    NSInteger firstDay  = 1;
    NSInteger lastDay   = DAYS_IN_WEEK_COUNT - 1;
    
    components.weekday      = 1;
    NSDate *date            = [calendar dateFromComponents:components];
    NSString *dayString     = [dateFormatter stringFromDate:date];
    CPTAxisLabel *label     = [[CPTAxisLabel alloc] initWithText:dayString textStyle:axisSet.xAxis.labelTextStyle];
    CGFloat x               = (firstDay * (barWidth + barSpace) * 12) + ((barWidth + barSpace) / 2) - 180;
    label.tickLocation      = CPTDecimalFromCGFloat(x);
    label.offset            = 7.0f;
    [labels addObject:label];
    
    components.weekday  = 7;
    date                = [calendar dateFromComponents:components];
    dayString           = [dateFormatter stringFromDate:date];
    label               = [[CPTAxisLabel alloc] initWithText:dayString textStyle:axisSet.xAxis.labelTextStyle];
    x                   = (lastDay * (barWidth + barSpace) * 12) + ((barWidth + barSpace) / 2) + 180;
    label.tickLocation  = CPTDecimalFromCGFloat(x);
    label.offset        = 7.0f;
    [labels addObject:label];
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}
   
- (void)dayLabelsWithWeek:(NSInteger)week ofYear:(NSInteger)year barWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    TimeDate *_timeDate             = [TimeDate getData];
    
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.weekOfYear           = week;
    components.yearForWeekOfYear    = year;
    NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    
    if (_timeDate.dateFormat == _DDMM) {
        dateFormatter.dateFormat        = @"dd MMM";
    }
    else {
        dateFormatter.dateFormat        = @"MMM dd";
    }
    
    NSMutableArray *labels          = [NSMutableArray new];
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *) self.axisSet;
    
    for (NSInteger day = 0; day < DAYS_IN_WEEK_COUNT; day++)
    {
        components.weekday          = day + 1;
        NSDate *date                = [calendar dateFromComponents:components];
        NSString *dayString         = [dateFormatter stringFromDate:date];
        CPTAxisLabel *label         = [[CPTAxisLabel alloc] initWithText:dayString textStyle:axisSet.xAxis.labelTextStyle];
        CGFloat x                   = (day * (barWidth + barSpace) * 12) + ((barWidth + barSpace) / 2);
        label.tickLocation          = CPTDecimalFromCGFloat(x);
        label.offset                = 7.0f;
        
        [labels addObject:label];
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}


- (void)dayLabelsForActigraphyWithWeek:(NSInteger)week ofYear:(NSInteger)year barWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    TimeDate *_timeDate             = [TimeDate getData];
    
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.weekOfYear           = week;
    components.yearForWeekOfYear    = year;
    NSDateFormatter *dateFormatter  = [NSDateFormatter new];
    
    if (_timeDate.dateFormat == _DDMM) {
        dateFormatter.dateFormat        = @"dd";
    }
    else {
        dateFormatter.dateFormat        = @"dd";
    }
    
    NSMutableArray *labels          = [NSMutableArray new];
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *) self.axisSet;
    
    for (NSInteger day = 0; day < DAYS_IN_WEEK_COUNT; day++)
    {
        components.weekday          = day + 1;
        NSDate *date                = [calendar dateFromComponents:components];
        NSString *dayString         = [dateFormatter stringFromDate:date];
        CPTAxisLabel *label         = [[CPTAxisLabel alloc] initWithText:dayString textStyle:axisSet.xAxis.labelTextStyle];
        CGFloat x                   = (day * (barWidth + barSpace)) + ((barWidth + barSpace) / 2);
        label.tickLocation          = CPTDecimalFromCGFloat(x);
        //label.offset                = 90.0f;
        label.offset                = 7.0f;
        
        [labels addObject:label];
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)dayLabelsForActigraphyWithYear:(NSInteger)year BarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    NSDateComponents *components    = [NSDateComponents new];
    NSInteger _days                 = 0;
    for (NSInteger i = 1; i < 13; i++)
    {
        components.month                = i;
        components.year                 = year;
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        NSDate *date                    = [calendar dateFromComponents:components];
        NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
        _days += range.length;
    }
    
    NSMutableArray *labels          = [NSMutableArray new];
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *) self.axisSet;
    
    for (NSInteger day = 0; day < YEAR_ACT_DATA_MAX_COUNT; day+=4)
    {
        NSString *dayString = [NSString stringWithFormat:@"%i", day + 1];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:dayString textStyle:axisSet.xAxis.labelTextStyle];
        CGFloat x           = (day * (barWidth + barSpace)) + ((barWidth + barSpace) / 2);
        label.tickLocation  = CPTDecimalFromCGFloat(x);
        //label.offset        = 90.0f;
        label.offset        = 7.0f;
        
        [labels addObject:label];
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)dayPortraitLabelsWithMonth:(NSInteger)month ofYear:(NSInteger)year barWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    NSDateComponents *components    = [NSDateComponents new];
    components.month                = month;
    components.year                 = year;
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDate *date                    = [calendar dateFromComponents:components];
    NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSMutableArray *labels          = [NSMutableArray new];
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *) self.axisSet;
    
    for (NSInteger day = 0; day < range.length; day+=3)
    {
        NSString *dayString = [NSString stringWithFormat:@"%i", day + 1];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:dayString textStyle:axisSet.xAxis.labelTextStyle];
        CGFloat x           = (day * (barWidth + barSpace)) + ((barWidth + barSpace) / 2);
        label.tickLocation  = CPTDecimalFromCGFloat(x);
        label.offset        = 7.0f;
        
        [labels addObject:label];
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)dayLabelsWithMonth:(NSInteger)month ofYear:(NSInteger)year barWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    NSDateComponents *components    = [NSDateComponents new];
    components.month                = month;
    components.year                 = year;
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDate *date                    = [calendar dateFromComponents:components];
    NSRange range                   = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSMutableArray *labels          = [NSMutableArray new];
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *) self.axisSet;
    
    for (NSInteger day = 0; day < range.length; day++)
    {
        NSString *dayString = [NSString stringWithFormat:@"%i", day + 1];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:dayString textStyle:axisSet.xAxis.labelTextStyle];
        CGFloat x           = (day * (barWidth + barSpace)) + ((barWidth + barSpace) / 2);
        label.tickLocation  = CPTDecimalFromCGFloat(x);
        label.offset        = 7.0f;
        
        [labels addObject:label];
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}


- (void)dayLabelsWithYear:(NSInteger)year barWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    NSUInteger days = [NSDate numberOfDaysForCurrentYear];
    
    NSMutableArray *labels          = [NSMutableArray new];
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *) self.axisSet;
    
    for (NSInteger day = 0; day < days; day++)
    {
        NSString *dayString = [NSString stringWithFormat:@"%i", day + 1];
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:dayString textStyle:axisSet.xAxis.labelTextStyle];
        CGFloat x           = (day * (barWidth + barSpace)) + ((barWidth + barSpace) / 2);
        label.tickLocation  = CPTDecimalFromCGFloat(x);
        label.offset        = 7.0f;
        
        if (day % 7 == 0) {
            [labels addObject:label];
        }
        
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}


- (void)monthLabelsWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    NSMutableArray *labels  = [NSMutableArray new];
    CPTXYAxisSet *axisSet   = (CPTXYAxisSet *) self.axisSet;
    NSArray *months         = [NSDateFormatter new].shortMonthSymbols;
    
    for (NSString *month in months)
    {
        NSInteger index         = [months indexOfObject:month];
        CPTAxisLabel *label     = [[CPTAxisLabel alloc] initWithText:month textStyle:axisSet.xAxis.labelTextStyle];
        CGFloat x               = (index * (barWidth + barSpace)) + ((barWidth + barSpace) / 2);
        label.tickLocation      = CPTDecimalFromCGFloat(x);
        label.offset            = 7.0f;
        
        [labels addObject:label];
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)sleepLogsHourPortraitLabelsWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    NSMutableArray *labels      = [NSMutableArray new];
    CPTXYAxisSet *axisSet       = (CPTXYAxisSet *) self.axisSet;
    NSInteger _startHour        = 1;//1;
    NSInteger _endHour          = HOURS_IN_DAY_COUNT - 1;//1;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _startHour              = 1;
        _endHour                = HOURS_IN_DAY_COUNT - 1;
    }
    
    if (LANGUAGE_IS_FRENCH) {
        _startHour              = 3;
        _endHour                = HOURS_IN_DAY_COUNT - 3;
    }
    //3PM - 3PM,
    NSInteger _midHour          = 9;//(1 + HOURS_IN_DAY_COUNT)/2;
    TimeDate *_timeDate         = [TimeDate getData];
    NSString *_hourlabel        = (_timeDate.hourFormat == _12_HOUR) ? @"3 PM" : @"15:00";
    NSString *_lastHourLabel    = (_timeDate.hourFormat == _12_HOUR) ? @"3 PM" : @"15:00";
    NSString *_midHourLabel     = (_timeDate.hourFormat == _12_HOUR) ? @"12 AM" : @"00:00";
    
    _hourlabel = [_hourlabel stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
    _lastHourLabel = [_lastHourLabel stringByReplacingOccurrencesOfString:@"PM" withString:LS_PM];
    _midHourLabel = [_midHourLabel stringByReplacingOccurrencesOfString:@"AM" withString:LS_AM];
    
    CPTAxisLabel *label;
    
    label = [[CPTAxisLabel alloc] initWithText:_hourlabel textStyle:axisSet.xAxis.labelTextStyle];
    CGFloat x           = _startHour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
    label.tickLocation  = CPTDecimalFromCGFloat(x);
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        label.offset = 223.0f;
    }
    else{
        label.offset = 83.0f;
    }
    
    [labels addObject:label];
    
    label = [[CPTAxisLabel alloc] initWithText:_midHourLabel textStyle:axisSet.xAxis.labelTextStyle];
    x     = _midHour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
    label.tickLocation  = CPTDecimalFromCGFloat(x);
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        label.offset = 223.0f;
    }
    else{
        label.offset = 83.0f;
    }
    
    //temporarily removed middle label
   // [labels addObject:label];
    
    label = [[CPTAxisLabel alloc] initWithText:_lastHourLabel textStyle:axisSet.xAxis.labelTextStyle];
    x     = _endHour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
    label.tickLocation  = CPTDecimalFromCGFloat(x);
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        label.offset = 223.0f;
    }
    else{
        label.offset = 83.0f;
    }
    
    [labels addObject:label];
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)sleepLogsHourLabelsWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    NSMutableArray *labels  = [NSMutableArray new];
    CPTXYAxisSet *axisSet   = (CPTXYAxisSet *) self.axisSet;
    TimeDate *_timeDate     = [TimeDate getData];
    
    for (NSInteger hour = 0; hour < HOURS_IN_DAY_COUNT; hour++)
    {
        CPTAxisLabel *label;
        
        NSInteger newHour   = hour + 15;
        newHour             = newHour >= 24 ? newHour - 24 : newHour;
        
        if (_timeDate.hourFormat == 0) {
            if (newHour == 0 || newHour == HOURS_IN_DAY_COUNT)
            {
                label = [[CPTAxisLabel alloc] initWithText:@"12AM" textStyle:axisSet.xAxis.labelTextStyle];
            }
            else if (newHour == 12)
            {
                label = [[CPTAxisLabel alloc] initWithText:@"12PM" textStyle:axisSet.xAxis.labelTextStyle];
            }
            else
            {
                NSString *time  = newHour < 12 ? [NSString stringWithFormat:@"%iAM", newHour] : [NSString stringWithFormat:@"%iPM", newHour - 12];
                label           = [[CPTAxisLabel alloc] initWithText:time textStyle:axisSet.xAxis.labelTextStyle];
            }
            
            CGFloat x           = hour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
            label.tickLocation  = CPTDecimalFromCGFloat(x);
            if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
                label.offset = 223.0f;
            }
            else{
                label.offset = 83.0f;
            }
            
            [labels addObject:label];
        }
        else {
            if (newHour == 0 || newHour == HOURS_IN_DAY_COUNT)
            {
                label = [[CPTAxisLabel alloc] initWithText:@"0:00" textStyle:axisSet.xAxis.labelTextStyle];
            }
            else if (newHour == 12)
            {
                label = [[CPTAxisLabel alloc] initWithText:@"12:00" textStyle:axisSet.xAxis.labelTextStyle];
            }
            else
            {
                NSString *time  = newHour < 12 ? [NSString stringWithFormat:@"%i:00", newHour] : [NSString stringWithFormat:@"%i:00", newHour];
                label           = [[CPTAxisLabel alloc] initWithText:time textStyle:axisSet.xAxis.labelTextStyle];
            }
            
            CGFloat x           = hour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
            label.tickLocation  = CPTDecimalFromCGFloat(x);
            if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
                label.offset = 223.0f;
            }
            else{
                label.offset = 83.0f;
            }
            
            [labels addObject:label];
        }
    }
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)workoutPortraitLabelsWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace labelArray:(NSArray *)labelArray numberOfDataPoints:(NSInteger) dataPointsCount
{
    NSMutableArray *labels      = [NSMutableArray new];
    CPTXYAxisSet *axisSet       = (CPTXYAxisSet *) self.axisSet;
    CPTAxisLabel *label;
    
    if (labelArray.count == 0){
        axisSet.xAxis.axisLabels = [[NSSet alloc] init];
        return;
    }
    
    for (NSDictionary *labelDictionary in labelArray){
        label = [[CPTAxisLabel alloc] initWithText:labelDictionary[@"string"] textStyle:axisSet.xAxis.labelTextStyle];
//        CGFloat x           = [(NSNumber *)labelDictionary[@"x"] integerValue] * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2);
        label.tickLocation  = CPTDecimalFromCGFloat([(NSNumber *)labelDictionary[@"x"] floatValue]);
        label.offset        = 5.0f;
        
        [labels addObject:label];
    }
    
    //adjust first and last labels tick locaation
    CPTAxisLabel *firstLabel = [labels firstObject];
    firstLabel.tickLocation = CPTDecimalFromCGFloat(([(NSNumber *)([labelArray firstObject][@"x"]) floatValue]) + barSpace/2);
    
    CPTAxisLabel *lastLabel = [labels lastObject];
    lastLabel.tickLocation = CPTDecimalFromCGFloat(([(NSNumber *)([labelArray lastObject][@"x"]) floatValue]) - barSpace/2);
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)HRworkoutPortraitLabelsWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace labelArray:(NSArray *)labelArray numberOfDataPoints:(NSInteger) dataPointsCount
{
    NSMutableArray *labels  = [NSMutableArray new];
    CPTXYAxisSet *axisSet   = (CPTXYAxisSet *) self.axisSet;
    
    for (NSInteger index = 0; index < labelArray.count; index++)
    {
        CPTAxisLabel *label;
        
        NSDictionary *labelDict = labelArray[index];
        label = [[CPTAxisLabel alloc] initWithText:labelDict[@"string"] textStyle:axisSet.yAxis.labelTextStyle];
        CGFloat x           = index*0.75;//[labelDict[@"y"] floatValue];
        label.tickLocation  = CPTDecimalFromCGFloat(x);
        label.offset        = 0.0f;
        
        [labels addObject:label];
    }
    axisSet.yAxis.axisLabels = [NSSet setWithArray:labels.copy];
}

- (void)lightPlotHourPortraitLabelsWithBarWidth:(CGFloat)barWidth barSpace:(CGFloat)barSpace
{
    NSMutableArray *labels      = [NSMutableArray new];
    CPTXYAxisSet *axisSet       = (CPTXYAxisSet *) self.axisSet;
    NSInteger _startHour        = 1;
    NSInteger _endHour          = HOURS_IN_DAY_COUNT - 1;
    TimeDate *_timeDate         = [TimeDate getData];
    NSString *_hourlabel        = LANGUAGE_IS_FRENCH ? (_timeDate.hourFormat == _12_HOUR ? @"12:00 MATIN" : @"00h00") : (_timeDate.hourFormat == _12_HOUR ? @"12:00 AM" : @"00:00");
    NSString *_lastHourLabel    = LANGUAGE_IS_FRENCH ? (_timeDate.hourFormat == _12_HOUR ? @"11:59 APRÈS-MIDI" : @"23h59") : (_timeDate.hourFormat == _12_HOUR ? @"11:59 PM" : @"23:59");
    
    CPTAxisLabel *label;
    
    label = [[CPTAxisLabel alloc] initWithText:_hourlabel textStyle:axisSet.xAxis.labelTextStyle];
    CGFloat x           = _startHour * (barWidth + barSpace) * 6 + ((barWidth + barSpace) / 2) + 20.0f;
    
//    if (LANGUAGE_IS_FRENCH && _timeDate.hourFormat == _12_HOUR) {
//        x = 80.0f;
//    }
    
    label.tickLocation  = CPTDecimalFromCGFloat(x);
    label.offset        = 3.0f;
    
    
    [labels addObject:label];
    
    label = [[CPTAxisLabel alloc] initWithText:_lastHourLabel textStyle:axisSet.xAxis.labelTextStyle];
    x     = _endHour * (barWidth + barSpace) * 5.8;
    
//    if (LANGUAGE_IS_FRENCH && _timeDate.hourFormat == _12_HOUR) {
//        x = 220.0f;
//    }
    
    label.tickLocation  = CPTDecimalFromCGFloat(x);
    label.offset        = 3.0f;
    
    [labels addObject:label];
    
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels.copy];
}


@end
