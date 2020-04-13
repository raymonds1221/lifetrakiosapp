//
//  SFAMainViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/11/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "ECSlidingViewController.h"

#import "DayFlow.h"
#import "SFACalendarView.h"

#import "SFAMainViewController.h"

#import "SFAServerAccountManager.h"

#import "Constants.h"

#import "SFASalutronFitnessAppDelegate.h"

#import "DateEntity.h"
#import "StatisticalDataHeaderEntity.h"

#import "SFADashboardScrollViewController.h"
#import "NSDate+Comparison.h"
#import "TimeDate+Data.h"



#define CALENDAR_VIEW_HEADER_HEIGHT         49.0f
#define CALENDAR_VIEW_ANIMATION_DURATION    0.3f
#define CALENDAR_VIEW_TOP_SPACE             0.0f

@interface SFAMainViewController () <NSFetchedResultsControllerDelegate, SFACalendarViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dashboardNavigationVerticalSpace;

@property (strong, nonatomic) UIView                    *disableLeftSlidingView;
@property (weak, nonatomic) UINavigationController      *dashboardNavigation;
@property (strong, nonatomic) NSManagedObjectContext    *managedObjectContext;
@property (readwrite, nonatomic) CGRect                 oldDateFrame;
@property (readwrite, nonatomic) CGFloat                oldVerticalSpaceHeight;
@property (readwrite, nonatomic) BOOL                   isCalendarViewHidden;
@property (nonatomic) CGRect oldCalendarFrame;
//@property (strong, nonatomic) SFACalendarView           *datePicker;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBottomSpace;

- (void)initializeObjects;
- (void)showCalendarView;
- (void)hideCalendarView;

@end

@implementation SFAMainViewController

@synthesize selectedDate = _selectedDate;

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initializeObjects];
    self.oldCalendarFrame = self.calendarView.frame;
    if (([UIApplication sharedApplication].statusBarFrame).size.height == 40) {
        self.containerBottomSpace.constant = 69;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.datePicker.superview != self.calendarView) {
        self.datePicker.delegate = self;
        [self.calendarView addSubview:self.datePicker];
        self.datePicker.bounds = self.calendarView.bounds;
        self.datePicker.datesWithData = [self getDatesWithData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        self.datePicker.frame                       = _oldDateFrame;
        _dashboardNavigationVerticalSpace.constant  = _oldVerticalSpaceHeight;
    }
    else
    {
        //remove calendar if landscape
        _dashboardNavigationVerticalSpace.constant  = 0;
        if ([self.datePicker isKindOfClass:[UIDatePicker class]]) {
            self.datePicker.frame                       = CGRectMake(0, 0, 0, 0);
        }
    }
    
    //DDLogInfo(@"frame: %@", NSStringFromCGRect(self.view.frame));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (fromInterfaceOrientation == UIInterfaceOrientationPortrait)
        [self _disableLeftSlidingView];
    else
        [self.disableLeftSlidingView removeFromSuperview];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:@"DashboardNavigation"])
//    {
        self.dashboardNavigation = (UINavigationController *) segue.destinationViewController;
//    }
}

#pragma mark - SFACalendarView Methods

- (void)calendarDidTapHeader:(SFACalendarView *)calendar
{
    if (self.isCalendarViewHidden)
    {
        [self showCalendarView];
    }
    else
    {
        [self hideCalendarView];
    }
}

- (void)calendar:(SFACalendarView *)calendar didSelectDate:(NSDate *)date
{
    [self hideCalendarView];

    [SFAUserDefaultsManager sharedManager].selectedDateFromCalendar = date;
    
    if (calendar.calendarMode == SFACalendarDay)
    {
        self.selectedDate = date;
        [self hideCalendarView];
        return ;
    }
    else if (calendar.calendarMode == SFACalendarWeek)
    {
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        NSDateComponents *components    = [calendar components:NSWeekOfYearCalendarUnit | NSYearCalendarUnit fromDate:date];
        
        [self setSelectedWeek:components.weekOfYear ofYear:components.year];
    }
    else if (calendar.calendarMode == SFACalendarMonth)
    {
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        NSDateComponents *components    = [calendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
        
        [self setSelectedMonth:components.month ofYear:components.year];
    }
    else if (calendar.calendarMode == SFACalendarYear)
    {
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        NSDateComponents *components    = [calendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
        self.selectedYear               = components.year;
    }
                                        
    _selectedDate = date;
    [self hideCalendarView];
}

#pragma mark - Setters

- (void)setCalendarMode:(SFACalendarMode)calendarMode
{
    if (self.datePicker.calendarMode != calendarMode)
    {
        self.datePicker.calendarMode = calendarMode;
        
        _selectedWeek   = [self weekForDate:self.datePicker.selectedDate];
        _selectedMonth  = [self monthForDate:self.datePicker.selectedDate];
        _selectedYear   = [self yearForDate:self.datePicker.selectedDate];
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    if (_selectedDate != selectedDate)
    {
        _selectedDate                   = selectedDate;
        self.datePicker.selectedDate    = selectedDate;
        
        for (UIViewController <SFACalendarControllerDelegate> *viewController in self.dashboardNavigation.viewControllers)
        {
            if ([viewController conformsToProtocol:@protocol(SFACalendarControllerDelegate)] &&
                [viewController respondsToSelector:@selector(calendarController:didSelectDate:)])
            {
                [viewController calendarController:self didSelectDate:selectedDate];
            }
        }
    }
}

- (void)setSelectedYear:(NSInteger)selectedYear
{
    if (_selectedYear != selectedYear)
    {
        _selectedYear                   = selectedYear;
        self.datePicker.selectedDate    = [self dateForYear:selectedYear];
        
        for (UIViewController <SFACalendarControllerDelegate> *viewController in self.dashboardNavigation.viewControllers)
        {
            if ([viewController conformsToProtocol:@protocol(SFACalendarControllerDelegate)]&&
                [viewController respondsToSelector:@selector(calendarController:didSelectYear:)])
            {
                [viewController calendarController:self didSelectYear:selectedYear];
            }
        }
    }
}

#pragma mark - Getters

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext)
    {
        SFASalutronFitnessAppDelegate *appDelegate  = [UIApplication sharedApplication].delegate;
        _managedObjectContext                       = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (NSDate *)selectedDate
{
    if (!_selectedDate)
    {
        _selectedDate = [NSDate date];
    }
    
    return _selectedDate;
}

- (SFACalendarMode)calendarMode
{
    return self.datePicker.calendarMode;
}

#pragma mark - IBAction Methods

- (IBAction)overlayViewDidTap:(UITapGestureRecognizer *)sender
{
    [self hideCalendarView];
}

- (IBAction)calendarViewDidPan:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self.view];
    float minY          = self.view.frame.size.height - sender.view.frame.size.height;
    float maxY          = self.view.frame.size.height - CALENDAR_VIEW_HEADER_HEIGHT;
    float newY          = sender.view.frame.origin.y + translation.y;
    
    if (newY >= minY &&
        newY <= maxY)
    {
        sender.view.center      = CGPointMake(sender.view.center.x, sender.view.center.y + translation.y);
        self.overlayView.alpha  = ((maxY - newY) / (maxY - minY)) * 0.5f;
        [sender setTranslation:CGPointMake(0, 0) inView:self.view];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [sender velocityInView:self.view];
        
        if (velocity.y > 0)
        {
            [self hideCalendarView];
        }
        else
        {
            [self showCalendarView];
        }
    }
}

- (IBAction)calendarViewDidTap:(UITapGestureRecognizer *)sender
{
//    if (self.isCalendarViewHidden)
//    {
//        [self showCalendarView];
//    }
//    else
//    {
//        [self hideCalendarView];
//    }
}

- (IBAction)calendarViewDidSwipeToUp:(id)sender
{
//    if (!self.isCalendarViewHidden) {
//        [self.calendarView moveWeekToPreviousWeek];
//
//    }
}

- (IBAction)calendarViewDidSwipeToDown:(id)sender
{
//    if (!self.isCalendarViewHidden) {
//        [self.calendarView moveWeekToNextWeek];
//    }
}

#pragma mark - Private Methods

- (void)initializeObjects
{
    // Initial Date
    _selectedDate   = [NSDate date];
    _selectedWeek   = [self weekForDate:self.selectedDate];
    _selectedMonth  = [self monthForDate:self.selectedDate];
    _selectedYear   = [self yearForDate:self.selectedDate];
    
//    self.dashboardNavigation.navigationBar.barTintColor = [UIColor colorWithRed:26.0/255.0 green:163.0/255.0 blue:73.0/255.0 alpha:1.0];
    self.dashboardNavigation.navigationBar.translucent = NO;
//    [self.dashboardNavigation.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    
    if ([SFACalendarView activeCalendarView]) {
        self.datePicker = [SFACalendarView activeCalendarView];
    } else {
        // Initialize calendar
        NSArray *viewHeirarchy = [[NSBundle mainBundle] loadNibNamed:@"SFACalendarView" owner:nil options:nil];
        
        for (UIView *v in viewHeirarchy) {
            if ([v isKindOfClass:[SFACalendarView class]]) {
                self.datePicker = (SFACalendarView *)v;
               // self.datePicker.bounds = self.calendarView.bounds;
                
                break;
            }
        }
    }
    
    
    self.datePicker.delegate = self;
    
    [self.calendarView addSubview:self.datePicker];
    
    //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        self.datePicker.frame = CGRectMake(0, 0, screenWidth, self.calendarView.frame.size.height);
        
    //}
    //else{
    //    self.datePicker.bounds = self.calendarView.bounds;
    //}
    
    
    //self.datePicker.bounds = CGRectMake(self.calendarView.bounds.origin.x, self.calendarView.bounds.origin.y, self.calendarView.bounds.size.width, self.calendarView.bounds.size.height);
    
    // Calendar
    self.isCalendarViewHidden       = YES;
    self.datePicker.datesWithData   = [self getDatesWithData];
    
    //store old frame;
    _oldDateFrame           = self.datePicker.frame;
    _oldVerticalSpaceHeight = _dashboardNavigationVerticalSpace.constant;
}

- (void)showCalendarView
{
    if (self.datePicker.datesWithData.count == 0) {
        [self reloadDatesWithData];
    }
    [self.datePicker refreshCalendar];
    
    self.isCalendarViewHidden               = NO;
    
    CGFloat calendarHeight = (([UIApplication sharedApplication].statusBarFrame).size.height == 40) ?  self.calendarView.frame.size.height + 20 : self.calendarView.frame.size.height ;
    CGRect frame                            = self.calendarView.frame;
    frame.origin.y                          = self.view.frame.size.height - calendarHeight;
    self.overlayView.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:CALENDAR_VIEW_ANIMATION_DURATION animations:^{
        self.overlayView.alpha  = 0.5f;
        self.calendarView.frame = frame;
    }];
}

- (void)hideCalendarView
{
    self.isCalendarViewHidden               = YES;
    CGFloat calendarHeight = (([UIApplication sharedApplication].statusBarFrame).size.height == 40) ?  CALENDAR_VIEW_HEADER_HEIGHT + 20 : CALENDAR_VIEW_HEADER_HEIGHT ;
    CGRect frame                            = self.calendarView.frame;
    frame.origin.y                          = self.view.frame.size.height - calendarHeight;
    self.overlayView.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:CALENDAR_VIEW_ANIMATION_DURATION animations:^{
        self.overlayView.alpha = 0.0f;
        self.calendarView.frame = frame;
    }];
}

- (void)_disableLeftSlidingView
{
    //Create subview on the left side of the view
    CGRect leftSlidingViewFrame                 = CGRectMake(0,
                                                             self.view.window.frame.size.height - 10.0f,
                                                             self.view.window.frame.size.width,
                                                             10.0f);
    _disableLeftSlidingView                     = [[UIView alloc] initWithFrame:leftSlidingViewFrame];
    _disableLeftSlidingView.backgroundColor     = [UIColor clearColor];
    [self.view.window addSubview:_disableLeftSlidingView];
}


- (NSArray *)getDatesWithData
{
    // Core Data
    NSSortDescriptor *yearDesccriptor   = [NSSortDescriptor sortDescriptorWithKey:@"date.year" ascending:NO];
    NSSortDescriptor *monthDescriptor   = [NSSortDescriptor sortDescriptorWithKey:@"date.month" ascending:NO];
    NSSortDescriptor *dayDescriptor     = [NSSortDescriptor sortDescriptorWithKey:@"date.day" ascending:NO];
    NSString *macAddress                = [SFAUserDefaultsManager sharedManager].macAddress;
    NSPredicate *predicate              = [NSPredicate predicateWithFormat:@"device.macAddress == %@ AND device.user.userID == %@", macAddress, [SFAServerAccountManager sharedManager].user.userID];
    NSFetchRequest *fetchRequest        = [NSFetchRequest fetchRequestWithEntityName:STATISTICAL_DATA_HEADER_ENTITY];
    fetchRequest.sortDescriptors        = @[yearDesccriptor, monthDescriptor, dayDescriptor];
    fetchRequest.predicate              = predicate;
    NSError *error                      = nil;
    NSArray *data                       = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (data)
    {
        NSMutableArray *dateArray = [NSMutableArray new];
        
        for (StatisticalDataHeaderEntity *dataHeader in data)
        {
            NSInteger month                 = dataHeader.date.month.integerValue;
            NSInteger day                   = dataHeader.date.day.integerValue;
            NSInteger year                  = dataHeader.date.year.integerValue + 1900;
            NSString *dateString            = [NSString stringWithFormat:@"%i-%i-%i", month, day, year];
            NSDateFormatter *dateFormatter  = [NSDateFormatter new];
            dateFormatter.dateFormat        = @"MM-dd-yyyy";
            NSDate *date                    = [dateFormatter dateFromString:dateString];
            if (date == nil) continue;
            [dateArray addObject:date];
        }
        
        data = [dateArray copy];
    }
    else
    {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return data;
}

- (NSDate *)dateForWeek:(NSInteger)week forYear:(NSInteger)year
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.weekday              = 7;
    components.weekOfYear           = week;
    components.yearForWeekOfYear    = year;
    NSDate *date                    = [calendar dateFromComponents:components];
    
    return date;
}

- (NSDate *)dateForMonth:(SPCalendarMonth)month forYear:(NSInteger)year
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.day                  = 1;
    components.month                = month;
    components.year                 = year;
    NSDate *date                    = [calendar dateFromComponents:components];
    
    return date;
}


- (NSDate *)dateForYear:(NSInteger)year
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [NSDateComponents new];
    components.year                 = year;
    NSDate *date                    = [calendar dateFromComponents:components];
    
    return date;
}

- (NSRange)rangeOfWeekForYear:(NSInteger)year
{
    NSCalendar *calendar    = [NSCalendar currentCalendar];
    NSDate *date            = [self dateForYear:year];
    NSRange range           = [calendar rangeOfUnit:NSWeekOfYearCalendarUnit inUnit:NSYearCalendarUnit forDate:date];
    
    return range;
}

- (NSInteger)weekForDate:(NSDate *)date
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [calendar components:NSWeekOfYearCalendarUnit fromDate:date];
    
    return components.weekOfYear;
}

- (SPCalendarMonth)monthForDate:(NSDate *)date
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [calendar components:NSMonthCalendarUnit fromDate:date];
    
    return components.month;
}

- (NSInteger)yearForDate:(NSDate *)date
{
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDateComponents *components    = [calendar components:NSYearCalendarUnit fromDate:date];
    
    return components.year;
}

#pragma mark - Public Methods

/* Calendar Methods */

- (void)showCalendar
{
    [UIView animateWithDuration:CALENDAR_VIEW_ANIMATION_DURATION animations:^{
        self.containerBottomSpace.constant = CALENDAR_VIEW_HEADER_HEIGHT;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)hideCalendar
{
    [UIView animateWithDuration:CALENDAR_VIEW_ANIMATION_DURATION animations:^{
        self.containerBottomSpace.constant = 0;
        [self.view layoutIfNeeded];
    } completion:nil];
}


/* Date Methods */

- (NSDate *)nextDate
{
    return [self.selectedDate dateByAddingTimeInterval:DAY_SECONDS];
}

- (NSDate *)previousDate
{
    return [self.selectedDate dateByAddingTimeInterval:-DAY_SECONDS];
}

- (NSInteger)nextWeek
{
    NSRange range = [self rangeOfWeekForYear:self.selectedYear];
    return self.selectedWeek + 1 > range.length ? 1 : self.selectedWeek + 1;
}

- (NSInteger)previousWeek
{
    if (self.selectedWeek > 1)
    {
        return self.selectedWeek - 1;
    }
    
    NSRange range = [self rangeOfWeekForYear:self.selectedYear - 1];
    
    return range.length - 1;
}

- (SPCalendarMonth)nextMonth
{
    return self.selectedMonth + 1 > SPCalendarMonthDecember ? SPCalendarMonthJanuary : self.selectedMonth + 1;
}

- (SPCalendarMonth)previousMonth
{
    return self.selectedMonth - 1 < SPCalendarMonthJanuary ? SPCalendarMonthDecember : self.selectedMonth - 1;
}

- (NSInteger)yearForNextWeek
{
    return self.nextWeek == 1 ? self.selectedYear + 1 : self.selectedYear;
}

- (NSInteger)yearForPreviousWeek
{
    return self.selectedWeek == 1 ? self.selectedYear - 1 : self.selectedYear;
}

- (NSInteger)yearForNextMonth
{
    return self.nextMonth == SPCalendarMonthJanuary ? self.selectedYear + 1 : self.selectedYear ;
}

- (NSInteger)yearForPreviousMonth
{
    return  self.previousMonth == SPCalendarMonthDecember ? self.selectedYear - 1 : self.selectedYear;
}

- (NSInteger)nextYear
{
    return self.selectedYear + 1;
}

- (NSInteger)previousYear
{
    return self.selectedYear - 1;
}

- (void)setSelectedWeek:(NSInteger)selectedWeek ofYear:(NSInteger)year
{
    _selectedWeek                   = selectedWeek;
    _selectedYear                   = year;
    self.datePicker.selectedDate    = [self dateForWeek:selectedWeek forYear:year];
    
    for (UIViewController <SFACalendarControllerDelegate> *viewController in self.dashboardNavigation.viewControllers)
    {
        if ([viewController conformsToProtocol:@protocol(SFACalendarControllerDelegate)] &&
            [viewController respondsToSelector:@selector(calendarController:didSelectWeek:ofYear:)])
        {
            [viewController calendarController:self didSelectWeek:selectedWeek ofYear:year];
        }
    }
}

- (void)setSelectedMonth:(SPCalendarMonth)selectedMonth ofYear:(NSInteger)year
{
    _selectedMonth                  = selectedMonth;
    _selectedYear                   = year;
    self.datePicker.selectedDate    = [self dateForMonth:selectedMonth forYear:year];
    
    for (UIViewController <SFACalendarControllerDelegate> *viewController in self.dashboardNavigation.viewControllers)
    {
        if ([viewController conformsToProtocol:@protocol(SFACalendarControllerDelegate)] &&
            [viewController respondsToSelector:@selector(calendarController:didSelectMonth:ofYear:)])
        {
            [viewController calendarController:self didSelectMonth:selectedMonth ofYear:year];
        }
    }
}

- (void)reloadDatesWithData
{
    self.datePicker.datesWithData = [self getDatesWithData];
}

// Index Methods

- (NSString *)timeForIndex:(NSInteger)index
{
    NSInteger hour      = index / 6;
    NSInteger minute    = index - (hour * 6);
    hour                = (hour == 24) ? 0 : hour;
    
    TimeDate *_timeDate = [TimeDate getData];
    
    NSString *_time     = [NSString stringWithFormat:@"%i:%i0", hour, minute];
    NSDate *_dateTime   = [_time getDateFromStringWithFormat:@"HH:mm"];
    
    if (_timeDate.hourFormat == 0)
    {
        return [_dateTime getDateStringWithFormat:@"hh:mma"];
    }
    else
    {
        return [_dateTime getDateStringWithFormat:@"HH:mm"];
    }
    
    return nil;
}

- (NSString *)timeOfWeekStringForIndex:(NSInteger)index
{
    index                   -= (index / 12) * 12;
    NSInteger hour          = index * 2;
    hour                    = (hour == 24) ? 0 : hour;
    
    TimeDate *_timeDate     = [TimeDate getData];
    
    NSString *_time     = [NSString stringWithFormat:@"%i:00", hour];
    NSDate *_dateTime   = [_time getDateFromStringWithFormat:@"HH:mm"];
    
    
    if (_timeDate.hourFormat == 0)
    {
        return [_dateTime getDateStringWithFormat:@"hh:mma"];
    }
    else
    {
        return [_dateTime getDateStringWithFormat:@"HH:mm"];
    }
    
    return nil;
}

- (NSString *)dayOfMonthStringForIndex:(NSInteger)index month:(NSInteger)month year:(NSInteger)year
{
    TimeDate *_timeDate             = [TimeDate getData];
    NSDateComponents *components    = [NSDateComponents new];
    components.month                = month;
    components.day                  = index + 1;
    components.year                 = year;
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSDate *date                    = [calendar dateFromComponents:components];
    NSDateFormatter *formatter      = [NSDateFormatter new];
    if (_timeDate.dateFormat == 0) {
        formatter.dateFormat            =  @"dd MMM";
    }
    else {
        formatter.dateFormat            =  @"MMM dd";
    }
    
    return [formatter stringFromDate:date];
}

- (NSString *)monthForIndex:(NSInteger)index
{
    NSArray *months = [NSDateFormatter new].shortMonthSymbols;
    if (index < [months count])
        return months[index];
    else
        return months[11];
}

- (NSString *)currentTimeForIndex:(NSInteger)index month:(NSInteger)month year:(NSInteger)year
{
    if (self.calendarMode == SFACalendarDay)
    {
        return [self timeForIndex:index];
    }
    else if (self.calendarMode == SFADateRangeWeek)
    {
        return [self timeOfWeekStringForIndex:index];
    }
    else if (self.calendarMode == SFADateRangeMonth)
    {
        return [self dayOfMonthStringForIndex:index month:month year:year];
    }
    else if (self.calendarMode == SFACalendarYear)
    {
        return [self monthForIndex:index];
    }
    
    return nil;
}

@end

@implementation UIViewController(CalendarControllerExtension)

- (SFAMainViewController *)calendarController
{
    UIViewController *viewController = self.parentViewController ? self.parentViewController : self.presentingViewController;
    
    while (! (viewController == nil || [viewController isKindOfClass:[SFAMainViewController class]]))
    {
        viewController = viewController.parentViewController ? : viewController.presentingViewController;
    }
    
    return (SFAMainViewController *)viewController;
}

@end

@implementation UIPageViewController(CalendarControllerExtension)

- (SFAMainViewController *)calendarController
{
    UIViewController *viewController = self.parentViewController ? self.parentViewController : self.presentingViewController;
    
    while (! (viewController == nil || [viewController isKindOfClass:[SFAMainViewController class]]))
    {
        viewController = viewController.parentViewController ? : viewController.presentingViewController;
    }
    
    return (SFAMainViewController *)viewController;
}

@end
