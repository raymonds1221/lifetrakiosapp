//
//  SFAGoalsSetupViewController.m
//  SalutronFitnessApp
//
//  Created by Dana Elisa Nicolas on 11/14/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAGoalsSetupViewController.h"
#import "SFAGoalsSetupViewController+View.h"
#import "SFAGoalsSetupCell.h"
#import "UIViewController+Helper.h"

#import "JDACoreData.h"

#import "ECSlidingViewController.h"
#import "SFAPairViewController.h"

#import "SFASalutronCModelSync.h"

#import "SVProgressHUD.h"
#import "SFASyncProgressView.h"
#import "SFASettingsPromptView.h"

#import "DeviceEntity.h"
#import "DateEntity.h"
#import "TimeEntity.h"
#import "SalutronUserProfile+SalutronUserProfileCategory.h"
#import "SalutronUserProfile+Data.h"
#import "SleepSetting+SleepSettingCategory.h"
#import "SleepSettingEntity+Data.h"

#import "CalibrationData+CalibrationDataCategory.h"

#import "Calibration_Data.h"
#import "ErrorCodeToStringConverter.h"

#import "SFAGoalsData.h"
#import "GoalsEntity+Data.h"
#import "SFASalutronUpdateManager.h"
#import "SFAServerAccountManager.h"
#import "TimeDate+Data.h"
#import "SFALightDataManager.h"
#import "LightDataPointEntity+Data.h"
#import "DayLightAlertEntity+Data.h"
#import "TimeDate+Data.h"
#import "NSDate+Util.h"
#import "DayLightAlert+Data.h"

#import "AFHTTPRequestOperationManager.h"

#import "SFASalutronSync.h"
#import "Flurry.h"

#define IS_IPHONE ( [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"])
#define IS_HEIGHT_GTE_568 [[UIScreen mainScreen ] bounds].size.height >= 568.0f
#define IS_IPHONE_5 ( IS_IPHONE && IS_HEIGHT_GTE_568 )
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define PAIR_SEGUE_IDENTIFIER @"GoalsToPair"

@interface SFAGoalsSetupViewController () <UIActionSheetDelegate, UIAlertViewDelegate, CBCentralManagerDelegate, SFAPairViewControllerDelegate, SFASettingsPromptViewDelegate, SFASalutronSyncDelegate, SFASyncProgressViewDelegate> {
    UISlider *stepsSlider;
    UISlider *distanceSlider;
    UISlider *caloriesSlider;
    UISlider *sleepSlider;
    
    UITextField *stepsLabel;
    UITextField *distanceLabel;
    UITextField *caloriesLabel;
    UITextField *sleepLabel;
    UIToolbar *numPadToolbar;
    NSArray *pickerViewItems;
//    UIPickerView *_sleepPicker;
    
    int editingTextField;
    int hour;
    int minute;
    int lightHour;
    int lightMinute;
    BOOL clearField;
    
    SalutronUserProfile *userProfile;
}

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) DeviceEntity *deviceEntity;
@property (strong, nonatomic) StatisticalDataHeaderEntity *statisticalDataHeaderEntity;
@property (strong, nonatomic) CalibrationData *calibrationData;

@property (strong, nonatomic) CBCentralManager *centralManager;

@property (strong, nonatomic) SFASalutronCModelSync *salutronSyncC300;
@property (strong, nonatomic) SFASalutronUpdateManager *updateManager;
@property (strong, nonatomic) SFAUserDefaultsManager *userDefaultsManager;
@property (strong, nonatomic) DayLightAlertEntity *daylightAlertEntity;
@property (strong, nonatomic) DayLightAlert *dayLightAlert;

@property (strong, nonatomic) UIPickerView *sleepPicker;

@property (readwrite, nonatomic) WatchModel watchModel;

@property (weak, nonatomic) UITextField *activeTextField;

@property (readwrite, nonatomic) BOOL bluetoothOn;
@property (readwrite, nonatomic) BOOL                           isStillSyncing;
@property (readwrite, nonatomic) BOOL                           didCancel;
@property (readwrite, nonatomic) BOOL                           cancelSyncToCloudOperation;

@property (readwrite, nonatomic) BOOL isSyncing;
@property (readwrite, nonatomic) BOOL isDisconnected;

@property (strong, nonatomic) UISlider *briteLightSlider;
@property (strong, nonatomic) UITextField *briteLightLabel;


@property (strong, nonatomic) SFASalutronSync                   *salutronSync;
@property (weak, nonatomic) SFAPairViewController               *pairViewController;

@end

@implementation SFAGoalsSetupViewController

//static const unsigned int discoverTimeout = 3;

@synthesize tableView       = _tableView;

- (SFASalutronSync *)salutronSync
{
    if (!_salutronSync) {
        _salutronSync = [[SFASalutronSync alloc] init];
    }
    
    return _salutronSync;
}


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
	// Do any additional setup after loading the view.
    
    self.centralManager             = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.salutronSyncC300 = [[SFASalutronCModelSync alloc] initWithManagedObjectContext:[JDACoreData sharedManager].context];
    self.salutronSyncC300.delegate = self;
    
    numPadToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
    //numPadToolbar.barStyle = UIBarStyleBlackOpaque;
    numPadToolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithTitle:BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)], nil];
    self.scrollView.contentSize = CGSizeMake(self.tableView.bounds.size.width, 700);

    [self.view addSubview:self.tableView];
    
    pickerViewItems = [NSArray arrayWithObjects:@[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14"], @[@"00", @"10", @"20", @"30", @"40", @"50"], nil];
    
    [self getDeviceEntity];
    
    self.dayLightAlert = [[SFAUserDefaultsManager sharedManager] dayLightAlert];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTableView:)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(doneWithNumberPad) name:UIKeyboardWillHideNotification object:nil];

    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Flurry logEvent:GOALS_PAGE];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(sleepKeyboardUp:) name:UIKeyboardDidShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(sleepKeyboardDown:) name:UIKeyboardDidHideNotification object:nil];
    
    self.dayLightAlert = [[SFAUserDefaultsManager sharedManager] dayLightAlert];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.watchModel  = self.userDefaultsManager.watchModel;
    userProfile = [SalutronUserProfile getData];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    //[self updateUserDefaultsGoalsData];
    //[self saveGoalsToCoreData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy loading of property

- (SFASalutronUpdateManager *)updateManager
{
    if (!_updateManager) {
        _updateManager = [SFASalutronUpdateManager sharedInstance];
    }
    return _updateManager;
}

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if (!_userDefaultsManager) {
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    }
    return _userDefaultsManager;
}

#pragma mark - Device entity

- (void)getDeviceEntity
{
    // Get Device Entity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:DEVICE_ENTITY];
    NSString *macAddress = self.userDefaultsManager.macAddress;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"macAddress == %@ AND user.userID == %@", macAddress, [SFAServerAccountManager sharedManager].user.userID];
    fetchRequest.predicate = predicate;
    fetchRequest.fetchLimit = 1;
    NSArray *results = [[JDACoreData sharedManager].context executeFetchRequest:fetchRequest error:nil];
    
    if(results.count == 1) {
        self.deviceEntity = (DeviceEntity *)[results firstObject];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PAIR_SEGUE_IDENTIFIER]) {
        self.pairViewController                          = (SFAPairViewController *)segue.destinationViewController;
        self.pairViewController.delegate                 = self;
        self.pairViewController.watchModel               = self.userDefaultsManager.watchModel;
        //if (self.pairViewController.watchModel == WatchModel_R450) {
            self.pairViewController.showCancelSyncButton = YES;
        //}
        
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            self.pairViewController.paired               = YES;
        } else {
            self.pairViewController.paired               = NO;
        }
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:PAIR_SEGUE_IDENTIFIER]) {
        if(!_bluetoothOn) {
            if (self.isIOS8AndAbove) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                         message:TURN_ON_BLUETOOTH
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:BUTTON_TITLE_OK
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               
                                           }];
                
                [alertController addAction:okAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:TURN_ON_BLUETOOTH
                                                               delegate:nil
                                                      cancelButtonTitle:BUTTON_TITLE_OK
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        
        return self.bluetoothOn;
    }
    
    return YES;
}

#pragma mark - TableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( self.watchModel == WatchModel_Move_C300_Android) {
        self.watchModel = WatchModel_Move_C300;
    }
    switch (self.watchModel) {
        case WatchModel_Move_C300:
            return 3;
        case WatchModel_Zone_C410:
            return 4;
        case WatchModel_R420:
            return 4;
        case WatchModel_R450: {
            DayLightAlertEntity *dayLightAlertEntity = [DayLightAlertEntity getDayLightAlert];
            
            if (dayLightAlertEntity.status.integerValue == 1)
                return 5;
            else
                return 4;
        }
        default:
            break;
    }
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SFAGoalsSetupCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[SFAGoalsSetupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell.slider setMaximumTrackTintColor:[UIColor lightGrayColor]];
    switch (indexPath.row) {
        case 0: {
            cell.goalName.text = LS_STEPS_ALL_CAPS;
            cell.goalMinValue.text = @"100";
            cell.goalMaxValue.text = @"30,000";
            
            cell.slider.minimumValue = 100;
            cell.slider.maximumValue = 30000;
            [cell.slider setMinimumTrackTintColor:GOALS_STEPS_LINE_COLOR];
            stepsSlider = cell.slider;
            [stepsSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            [stepsSlider setThumbImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_1_steps.png"] forState:UIControlStateNormal];
            [stepsSlider setThumbImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_1_steps_SELECTED.png"] forState:UIControlStateHighlighted];
            
            if ([self isIOS8AndAbove]) {
            [stepsSlider setMinimumTrackImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_1_steps_bar1.png"] forState:UIControlStateNormal];
            }
            [stepsSlider setMaximumTrackImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_0_bar.png"] forState:UIControlStateNormal];
            if([self isIOS9AndAbove]){
                [stepsSlider setMaximumTrackTintColor:LIFETRAK_COLOR_INACTIVE];
            }
            stepsLabel = cell.goalCurrentValue;
            stepsLabel.delegate = self;
            stepsLabel.keyboardType = UIKeyboardTypeDecimalPad;
            stepsLabel.inputAccessoryView = numPadToolbar;
            [stepsLabel setClearsOnBeginEditing:YES];
            stepsLabel.placeholder = @"0";
            
            if (self.userDefaultsManager.stepGoal > 0) {
                stepsLabel.text = [NSString stringWithFormat:@"%d", self.userDefaultsManager.stepGoal];
                stepsSlider.value = self.userDefaultsManager.stepGoal;
                [stepsSlider setNeedsDisplay];
            }
            else {
                stepsLabel.text = [NSString stringWithFormat:@"%d", 10000];
                stepsSlider.value = 10000;
                [stepsSlider setNeedsDisplay];
            }
            
            cell.goalUnit.text = @"";
        }
            break;
        case 1: {
            cell.goalName.text = [LS_DISTANCE uppercaseString];
            if (userProfile.unit == IMPERIAL) {
                cell.goalMinValue.text = @"0.62";
                cell.goalMaxValue.text = @"25.00";
                
                cell.slider.minimumValue = 0.62;
                cell.slider.maximumValue = 25.00;
            }
            else {
                cell.goalMinValue.text = @"1.00";
                cell.goalMaxValue.text = @"40.23";
                
                cell.slider.minimumValue = 1.00;
                cell.slider.maximumValue = 40.23;
            }
            
            [cell.slider setMinimumTrackTintColor:GOALS_DISTANCE_LINE_COLOR];
            distanceSlider = cell.slider;
            [distanceSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            [distanceSlider setThumbImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_2_distance.png"] forState:UIControlStateNormal];
            [distanceSlider setThumbImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_2_distance_SELECTED.png"] forState:UIControlStateHighlighted];
            if ([self isIOS8AndAbove]) {
                [distanceSlider setMinimumTrackImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_2_distance_bar1.png"] forState:UIControlStateNormal];
            }
            [distanceSlider setMaximumTrackImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_0_bar.png"] forState:UIControlStateNormal];
            if([self isIOS9AndAbove]){
                [distanceSlider setMaximumTrackTintColor:LIFETRAK_COLOR_INACTIVE];
            }
            
            distanceLabel = cell.goalCurrentValue;
            distanceLabel.delegate = self;
            distanceLabel.keyboardType = UIKeyboardTypeDecimalPad;
            distanceLabel.inputAccessoryView = numPadToolbar;
            [distanceLabel setClearsOnBeginEditing:YES];
            //distanceLabel.placeholder = @"00.00";

            if (self.userDefaultsManager.distanceGoal) {
                if (self.userDefaultsManager.distanceGoal < 0) {
                    DDLogError(@"distanceGoal = %f", self.userDefaultsManager.distanceGoal);
                    self.userDefaultsManager.distanceGoal = 3.2;
                }
                if (userProfile.unit == IMPERIAL) {
                    distanceLabel.text = [NSString stringWithFormat:@"%.2f", (self.userDefaultsManager.distanceGoal * 0.621371)];
                    distanceSlider.value = (self.userDefaultsManager.distanceGoal * 0.621371);
                }
                else {
                    distanceLabel.text = [NSString stringWithFormat:@"%.2f", self.userDefaultsManager.distanceGoal];
                    distanceSlider.value = self.userDefaultsManager.distanceGoal;
                }
                [distanceSlider setNeedsDisplay];
            }
            else {
                if (userProfile.unit == IMPERIAL) {
                    distanceLabel.text = [NSString stringWithFormat:@"%.2f", 0.62];
                    distanceSlider.value = 0.621371;
                }
                else {
                    distanceLabel.text = [NSString stringWithFormat:@"%.2f", 1.0];
                    distanceSlider.value = 1.00;
                }
                [distanceSlider setNeedsDisplay];
            }
            
            if (userProfile.unit == IMPERIAL) {
                cell.goalUnit.text = @"mi";
            }
            else {
                cell.goalUnit.text = @"km";
            }
        }
            break;
        case 2: {
            cell.goalName.text = [LS_CALORIES uppercaseString];
            cell.goalMinValue.text = @"100";
            cell.goalMaxValue.text = @"5,000";
            
            cell.slider.minimumValue = 100;
            cell.slider.maximumValue = 5000;
            [cell.slider setMinimumTrackTintColor:GOALS_CALORIES_LINE_COLOR];
            caloriesSlider = cell.slider;
            [caloriesSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            [caloriesSlider setThumbImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_3_calories.png"] forState:UIControlStateNormal];
            [caloriesSlider setThumbImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_3_calories_SELECTED.png"] forState:UIControlStateHighlighted];
            
            if ([self isIOS8AndAbove]) {
                [caloriesSlider setMinimumTrackImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_3_calories_bar1.png"] forState:UIControlStateNormal];
            }
            [caloriesSlider setMaximumTrackImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_0_bar.png"] forState:UIControlStateNormal];
            if([self isIOS9AndAbove]){
                [caloriesSlider setMaximumTrackTintColor:LIFETRAK_COLOR_INACTIVE];
            }
            
            caloriesLabel = cell.goalCurrentValue;
            caloriesLabel.delegate = self;
            caloriesLabel.keyboardType = UIKeyboardTypeDecimalPad;
            caloriesLabel.inputAccessoryView = numPadToolbar;
            [caloriesLabel setClearsOnBeginEditing:YES];
            caloriesLabel.placeholder = @"0";

            if (self.userDefaultsManager.calorieGoal > 0) {
                caloriesLabel.text = [NSString stringWithFormat:@"%d", self.userDefaultsManager.calorieGoal];
                caloriesSlider.value = self.userDefaultsManager.calorieGoal;
                [caloriesSlider setNeedsDisplay];
            }
            else {
                caloriesLabel.text = [NSString stringWithFormat:@"%d", 3000];
                caloriesSlider.value = 3000;
                [caloriesSlider setNeedsDisplay];
            }
            
            cell.goalUnit.text = @"kcal";
        }
            break;
        case 3: {
            cell.goalName.text = [LS_SLEEP uppercaseString];
            cell.goalMinValue.text = @"1hr00min";
            cell.goalMaxValue.text = @"14hr50min";
            
            cell.slider.minimumValue = 60;
            cell.slider.maximumValue = 890;
            [cell.slider setMinimumTrackTintColor:GOALS_SLEEP_LINE_COLOR];
            sleepSlider = cell.slider;
            [sleepSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            [sleepSlider setThumbImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_4_sleep.png"] forState:UIControlStateNormal];
            [sleepSlider setThumbImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_4_sleep_SELECTED.png"] forState:UIControlStateHighlighted];
            
            if ([self isIOS8AndAbove]) {
                [sleepSlider setMinimumTrackImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_4_sleep_bar1.png"] forState:UIControlStateNormal];
            }
            [sleepSlider setMaximumTrackImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_0_bar.png"] forState:UIControlStateNormal];
            if([self isIOS9AndAbove]){
                [sleepSlider setMaximumTrackTintColor:LIFETRAK_COLOR_INACTIVE];
            }
            
            sleepLabel = cell.goalCurrentValue;
            sleepLabel.delegate = self;
            sleepLabel.keyboardType = UIKeyboardTypeDecimalPad;
            sleepLabel.inputAccessoryView = numPadToolbar;
            //sleepLabel.placeholder = @"00h00m";

            if (self.userDefaultsManager.sleepSetting) {
                //int sleepGoal = self.userDefaultsManager.sleepSetting.sleep_goal_lo + (self.userDefaultsManager.sleepSetting.sleep_goal_hi << 8);
                NSInteger hi = (self.userDefaultsManager.sleepSetting.sleep_goal_hi == self.userDefaultsManager.sleepSetting.sleep_goal_lo) ? 0 : self.userDefaultsManager.sleepSetting.sleep_goal_hi;
                int sleepGoal = self.userDefaultsManager.sleepSetting.sleep_goal_lo + (hi << 8);
                
                hour = sleepGoal / 60;
                minute = sleepGoal % 60;
                
                sleepLabel.text = [NSString stringWithFormat:@"%dh%dm", (int)(sleepGoal/60), (int)sleepGoal%60];
                sleepSlider.value = sleepGoal;
                [sleepSlider setNeedsDisplay];
            }
            else
            {
                int sleep = 480;
                
                hour = sleep / 60;
                minute = sleep % 60;
                
                sleepLabel.text = [NSString stringWithFormat:@"%dh%dm", (int)(sleep/60), (int)sleep%60];
                sleepSlider.value = sleep;
            }
            
            cell.goalUnit.text = @"";
        }
            break;
        case 4: {
            NSString *briteLightCellIdentifier = @"BriteLightCellIdentifier";
            SFAGoalsSetupCell *briteCell = [tableView dequeueReusableCellWithIdentifier:briteLightCellIdentifier];
            
            if (!briteCell) {
                briteCell = [[SFAGoalsSetupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:briteLightCellIdentifier];
                briteCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            [briteCell.slider setMinimumTrackTintColor:GOALS_LIGHT_LINE_COLOR];
            [briteCell.slider setMaximumTrackTintColor:[UIColor lightGrayColor]];
            
            briteCell.goalName.text = LS_BRIGHT_LIGHT_DURATION;
            briteCell.goalMinValue.text = @"1hr00min";
            briteCell.goalMaxValue.text = @"14hr50min";
            
            self.briteLightSlider = briteCell.slider;
            
            /*[self.briteLightSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];*/
            
            [self.briteLightSlider addTarget:self action:@selector(briteLightValueChanged) forControlEvents:UIControlEventValueChanged];
            
            self.briteLightLabel = briteCell.goalCurrentValue;
            
            self.briteLightLabel.delegate = self;
            self.briteLightLabel.keyboardType = UIKeyboardTypeDecimalPad;
            self.briteLightLabel.inputAccessoryView = numPadToolbar;
            
            [self.briteLightSlider setThumbImage:[UIImage imageNamed:@"LightPlotSlider"] forState:UIControlStateNormal];
            [self.briteLightSlider setThumbImage:[UIImage imageNamed:@"LightPlotSliderSelected"] forState:UIControlStateHighlighted];
            if ([self isIOS8AndAbove]) {
                [self.briteLightSlider setMinimumTrackImage:[UIImage imageNamed:@"LightPlotSliderBar1"] forState:UIControlStateNormal];
            }
            [self.briteLightSlider setMaximumTrackImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_goals_0_bar.png"] forState:UIControlStateNormal];
            if([self isIOS9AndAbove]){
                [self.briteLightSlider setMaximumTrackTintColor:LIFETRAK_COLOR_INACTIVE];
            }
            
            //self.daylightAlertEntity = [DayLightAlertEntity getDayLightAlert];
            
            
            NSInteger startHour = self.dayLightAlert.start_hour;
            NSInteger startMin = self.dayLightAlert.start_min;
            NSInteger endHour = self.dayLightAlert.end_hour;
            NSInteger endMin = self.dayLightAlert.end_min;
            
            NSInteger exposureTimeDuration = self.dayLightAlert.duration;
            NSInteger totalTimeDuration = [NSDate durationWithStartHour:startHour startMinute:startMin endHour:endHour endMinute:endMin];
            if (totalTimeDuration > 120 || totalTimeDuration == 0) {
                totalTimeDuration = 120;
            }
            
            if (exposureTimeDuration == 0) {
                exposureTimeDuration = 10;
                
                lightHour = exposureTimeDuration/60;
                lightMinute = exposureTimeDuration%60;
                [self briteLightValueChangedManually];
            }
            
            
            briteCell.goalMaxValue.text = [NSString stringWithFormat:@"%dh%dm", (NSInteger)(totalTimeDuration / 60), (NSInteger)(totalTimeDuration % 60)];
            
            self.briteLightSlider.minimumValue = 10;
            self.briteLightSlider.maximumValue = totalTimeDuration;
            briteCell.goalMinValue.text = @"0h10min";
            //briteCell.goalMaxValue.text = [NSString stringWithFormat:@"%i", totalTimeDuration];
            
            
            lightHour = exposureTimeDuration/60;
            lightMinute = exposureTimeDuration%60;
            
            self.briteLightLabel.text = [NSString stringWithFormat:@"%dh%dm", (int)(exposureTimeDuration/60), (int)exposureTimeDuration%60];
            
            self.briteLightSlider.value = exposureTimeDuration;
            [self.briteLightSlider setNeedsDisplay];
            /*
            switch ([TimeDate getData].hourFormat) {
                case _12_HOUR: {
                    if (startHour > 12) {
                        briteCell.goalMinValue.text = [NSString stringWithFormat:@"%02d:%02d%@", startHour - 12, startMin, LS_PM];
                    } else {
                        briteCell.goalMinValue.text = [NSString stringWithFormat:@"%02d:%02d%@", startHour, startMin, LS_AM];
                    }
                    
                    if(endHour > 12) {
                        briteCell.goalMaxValue.text = [NSString stringWithFormat:@"%02d:%02d%@", endHour - 12, endMin, LS_PM];
                    } else {
                        briteCell.goalMaxValue.text = [NSString stringWithFormat:@"%02d:%02d%@", endHour, endMin, LS_AM];
                    }
                }
                    break;
                case _24_HOUR: {
                    briteCell.goalMinValue.text = [NSString stringWithFormat:@"%02d:%02d", startHour, startMin];
                    briteCell.goalMaxValue.text = [NSString stringWithFormat:@"%02d:%02d", endHour, endMin];
                }
                    break;
                default:
                    break;
            }
             */
            
            return briteCell;
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [stepsLabel becomeFirstResponder];
    }
    else if (indexPath.row == 1) {
        [distanceLabel becomeFirstResponder];
    }
    else if (indexPath.row == 2) {
        [caloriesLabel becomeFirstResponder];
    }
    else if (indexPath.row == 3) {
        [sleepLabel becomeFirstResponder];
    }
    else if (indexPath.row == 4) {
        [self.briteLightSlider becomeFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == stepsLabel) {
   //     stepsLabel.text = @"10000";
      //  [stepsLabel sizeToFit];
    } else if (textField == sleepLabel) {
        //sleepLabel.text = @"10h10m";
        [sleepLabel sizeToFit];
    } else if (textField == self.briteLightLabel) {
        //sleepLabel.text = @"10h10m";
        [self.briteLightLabel sizeToFit];
    } else if (textField == caloriesLabel) {
   //     caloriesLabel.text = @"10000";
        //[caloriesLabel sizeToFit];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [textField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    if (textField == stepsLabel) {
        editingTextField = STEPS_TEXTFIELD;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = nil;
    } else if (textField == distanceLabel){
        editingTextField = DISTANCE_TEXTFIELD;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = nil;
    } else if (textField == caloriesLabel) {
        editingTextField = CALORIES_TEXTFIELD;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = nil;
    } else {
        self.sleepPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 568, 320, 180)];
        self.sleepPicker.delegate = self;
        self.sleepPicker.showsSelectionIndicator = YES;
        
        UILabel *hourLabel;
        UILabel *minsLabel;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(310, 80, 20.0, 20.0f)];
            hourLabel.text = @"h";
            
            minsLabel = [[UILabel alloc] initWithFrame:CGRectMake(510.0, 80, 20.0, 20.0f)];
            minsLabel.text = @"m";
        }
        else{
            hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(137, 80, 20.0, 20.0f)];
            hourLabel.text = @"h";
            
            minsLabel = [[UILabel alloc] initWithFrame:CGRectMake(227.0, 80, 20.0, 20.0f)];
            minsLabel.text = @"m";
        }
        
        [self.sleepPicker addSubview:hourLabel];
        [self.sleepPicker addSubview:minsLabel];
        
        if (textField == sleepLabel) {
            sleepLabel.inputView = self.sleepPicker;
            self.sleepPicker.tag = 0;
            editingTextField = SLEEP_TEXTFIELD;
            
            [self.sleepPicker selectRow:hour-1 inComponent:0 animated:NO];
            [self.sleepPicker selectRow:minute/10 inComponent:1 animated:NO];
        }
        else if(textField == self.briteLightLabel) {
            self.briteLightLabel.inputView = self.sleepPicker;
            self.sleepPicker.tag = 1;
            editingTextField = LIGHT_TEXTFIELD;
            
            [self.sleepPicker selectRow:lightHour inComponent:0 animated:NO];
            [self.sleepPicker selectRow:lightMinute inComponent:1 animated:NO];
        }
        
    }
    clearField              = YES;
    self.activeTextField    = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    clearField              = NO;
    self.activeTextField    = nil;
    //[UIView animateWithDuration:1 animations:^{
     //   self.tableView.contentOffset = CGPointMake(0, 0);
        [self.tableView reloadData];
    //} completion:^(BOOL finished) {
    //}];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    int MAXLENGTH = 0;
    
    if (textField == stepsLabel) {
        if ([textField.text intValue] == 3000 && [string intValue] == 0)
            MAXLENGTH = 5;
        else
            MAXLENGTH = 5;
    }
    else if (textField == distanceLabel) {
        if ([textField.text floatValue] == 10.00 && [string floatValue] == 0.00)
            MAXLENGTH = 5;
        else
            MAXLENGTH = 5;
    }
    else if (textField == caloriesLabel) {
        if ([textField.text intValue] == 5000 && [string intValue] == 0)
            MAXLENGTH = 4;
        else
            MAXLENGTH = 4;
    }
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    /*
    if (newLength > 3) {
        [textField sizeToFit];
    }
    */
    return newLength <= MAXLENGTH || returnKey;
}


- (void)textFieldDidChange:(UITextField *)textField{
    [textField sizeToFit];
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    if (component == 0){
        if (pickerView.tag == 0) {
            hour = [[[pickerViewItems objectAtIndex:component] objectAtIndex:row] intValue];
        }
        else{
            lightHour = [pickerView selectedRowInComponent:0];
        }
    }
    else{
        if (pickerView.tag == 0) {
            minute = [[[pickerViewItems objectAtIndex:1] objectAtIndex:row] intValue];
        }
        else{
            lightMinute = [pickerView selectedRowInComponent:1];
            if (lightHour == 2) {
                if (lightMinute > 0) {
                    [pickerView selectRow:row inComponent:component animated:YES];
                }
            }
        }
        
        
    }
    if (pickerView.tag == 1) {
        NSInteger startHour = self.dayLightAlert.start_hour;
        NSInteger startMin = self.dayLightAlert.start_min;
        NSInteger endHour = self.dayLightAlert.end_hour;
        NSInteger endMin = self.dayLightAlert.end_min;
        
        NSInteger totalTimeDuration = [NSDate durationWithStartHour:startHour startMinute:startMin endHour:endHour endMinute:endMin];
        if (totalTimeDuration > 120 || totalTimeDuration == 0) {
            totalTimeDuration = 120;
        }
        
        if ((lightHour*60) + lightMinute > totalTimeDuration){
            [pickerView selectRow:totalTimeDuration/60 inComponent:0 animated:YES];
            [pickerView selectRow:totalTimeDuration%60 inComponent:1 animated:YES];
            lightHour = totalTimeDuration/60;
            lightMinute = totalTimeDuration%60;
            return;
        }else if ((lightHour*60) + lightMinute < 10){
            [pickerView selectRow:0 inComponent:0 animated:YES];
            [pickerView selectRow:10 inComponent:1 animated:YES];
            lightHour = 0;
            lightMinute = 10;
            return;
        }
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 1) {
        if (component == 0) {
            return 3;
        }
        else{
            return 60;
        }
    }
    return [[pickerViewItems objectAtIndex:component] count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [pickerViewItems count];
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == 1) {
        if (component == 0) {
            return [@[@"0",@"1", @"2"] objectAtIndex:row];
        }
        else{
            return [NSString stringWithFormat:@"%i",row];
        }
    }
    return [[pickerViewItems objectAtIndex:component] objectAtIndex:row];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    DDLogError(@"%s", __PRETTY_FUNCTION__);
    int sectionWidth = pickerView.frame.size.width*0.25;
    return sectionWidth;
}

#pragma mark - Actions

- (void)sliderValueChanged:(UISlider *)sender
{
    if (sender == stepsSlider) {
        
        NSUInteger steps = sender.value;
        int stepSize = 100;
        stepsSlider.value = steps - steps % stepSize;
        [stepsSlider setNeedsDisplay];
        stepsLabel.text = [NSString stringWithFormat:@"%d", [[NSNumber numberWithFloat:stepsSlider.value] intValue]];
        [stepsLabel setNeedsDisplay];
        self.userDefaultsManager.stepGoal = stepsSlider.value;
    }
    else if (sender == distanceSlider) {
        
        distanceSlider.value = sender.value;
        [distanceSlider setNeedsDisplay];
        
        distanceLabel.text = [NSString stringWithFormat:@"%.2f", distanceSlider.value];
        [distanceLabel setNeedsDisplay];
        
        if (userProfile.unit == IMPERIAL) {
            self.userDefaultsManager.distanceGoal = distanceSlider.value * 1.60934;
        }
        else {
            self.userDefaultsManager.distanceGoal = distanceSlider.value;
        }
    }
    else if (sender == caloriesSlider) {
        
        NSUInteger calorie = sender.value;
        int stepSize = 100;

        caloriesSlider.value = calorie - calorie % stepSize;
        [caloriesSlider setNeedsDisplay];
        
        caloriesLabel.text = [NSString stringWithFormat:@"%d", [[NSNumber numberWithFloat:caloriesSlider.value] intValue]];
        [caloriesLabel setNeedsDisplay];
        
        self.userDefaultsManager.calorieGoal = caloriesSlider.value;
    }
    else if (sender == sleepSlider) {
        
        int sliderValue = sender.value;
        int stepSize = 10;
        int sleep = sliderValue - sliderValue % stepSize;
        
        int sleepLo = sleep&0x00ff;
        int sleepHi = (sleep&0xff00)>>8;
        
        sleepSlider.value = sleep;
        sleepLabel.text = [NSString stringWithFormat:@"%dh%dm", (int)(sleep/60), (int)(sleep%60)];

        SleepSetting *sleepSetting = [[SleepSetting alloc] init];
        sleepSetting.sleep_goal_lo = sleepLo;
        sleepSetting.sleep_goal_hi = sleepHi;
        
        if (self.deviceEntity.modelNumber.integerValue == WatchModel_R450) {
            sleepSetting.sleep_mode = 3;//MANUAL;//self.userDefaultsManager.sleepSetting.sleep_mode;
        } else {
            sleepSetting.sleep_mode = self.userDefaultsManager.sleepSetting.sleep_mode;
        }

        [sleepSlider setNeedsDisplay];
        [sleepLabel setNeedsDisplay];
        
        self.userDefaultsManager.sleepSetting = sleepSetting;
        self.deviceEntity.sleepSetting = [SleepSettingEntity sleepSettingWithSleepSetting:sleepSetting forDeviceEntity:self.deviceEntity];//sleepSetting;
        self.userDefaultsManager.sleepGoal = sliderValue;
    }
    else if (sender == self.briteLightSlider) {
        
        //self.briteLightSlider.value = sliderValue;
        
        int sliderValue = sender.value;
        //int stepSize = 10;
        int duration = sliderValue;// - sliderValue % stepSize;
        
        self.briteLightSlider.value = duration;
        self.briteLightLabel.text = [NSString stringWithFormat:@"%dh%dm", (int)(duration/60), (int)(duration%60)];
        
        //[self.briteLightSlider setNeedsDisplay];
        [self.briteLightLabel setNeedsDisplay];
    }
    
    //[self saveGoalsToCoreData];
    [self.tableView reloadData];
}

- (void)briteLightValueChanged
{
    //self.briteLightSlider.value = sliderValue;
    
    int sliderValue = self.briteLightSlider.value;
    int duration = sliderValue;
    /*
    int stepSize = 10;
    int duration = sliderValue - sliderValue % stepSize;
    */
    
    self.briteLightSlider.value = duration;
    self.briteLightLabel.text = [NSString stringWithFormat:@"%dh%dm", (int)(duration/60), (int)(duration%60)];

    lightHour = duration/60;
    lightMinute = duration%60;
    
    self.briteLightLabel.text = [NSString stringWithFormat:@"%dh%dm", lightHour, lightMinute];
    
    self.daylightAlertEntity.duration = @(duration);
    //self.dayLightAlert = [DayLightAlert dayLightAlert];
    self.dayLightAlert.duration = (NSUInteger)duration;
    //self.userDefaultsManager.dayLightAlert = self.dayLightAlert;
    [DayLightAlertEntity dayLightAlertWithDayLightAlert:self.dayLightAlert forDeviceEntity:self.deviceEntity];
    
    [SFAUserDefaultsManager sharedManager].dayLightAlert = self.dayLightAlert;
    
    [self.briteLightLabel setNeedsDisplay];
    
    [self.tableView reloadData];
}

- (void)briteLightValueChangedManually
{
    //NSInteger sliderValue = self.briteLightSlider.value;
    //DDLogError(@"slider value: %d", sliderValue);
    
    self.briteLightLabel.text = [NSString stringWithFormat:@"%dh%dm", lightHour, lightMinute];
    
    self.daylightAlertEntity.duration = @((lightHour*60) + lightMinute);
    //DayLightAlert *dayLightAlert = [DayLightAlert dayLightAlert];
    NSInteger duration = (NSInteger)((lightHour*60) + lightMinute);
    NSNumber *numberDuration = [NSNumber numberWithInteger:duration];
    self.dayLightAlert.duration =  numberDuration.unsignedCharValue;
    //self.userDefaultsManager.dayLightAlert = self.dayLightAlert;
    [DayLightAlertEntity dayLightAlertWithDayLightAlert:self.dayLightAlert forDeviceEntity:self.deviceEntity];
    
    [SFAUserDefaultsManager sharedManager].dayLightAlert = self.dayLightAlert;
}

- (IBAction)menuButtonPressed:(id)sender
{
    [self saveGoalsToCoreData];
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)syncButtonPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:BUTTON_TITLE_CANCEL
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:SYNC_DATE_TITLE, LS_RESET, LS_RESTORE_PREV, nil];
    [actionSheet showInView:self.view];
}

- (void)doneWithNumberPad
{
    if (editingTextField == STEPS_TEXTFIELD) {
        if ([stepsLabel.text intValue] <= stepsSlider.maximumValue
            && [stepsLabel.text intValue] >= stepsSlider.minimumValue)
            stepsSlider.value = [stepsLabel.text intValue];
        else {
            stepsSlider.value = self.userDefaultsManager.stepGoal;
            stepsLabel.text = [NSString stringWithFormat:@"%d", self.userDefaultsManager.stepGoal];
        }
        [stepsLabel setNeedsDisplay];
        [stepsSlider setNeedsDisplay];
    }
    else if (editingTextField == DISTANCE_TEXTFIELD) {
        if ([distanceLabel.text floatValue] <= distanceSlider.maximumValue
            && [distanceLabel.text floatValue] >= distanceSlider.minimumValue) {
            distanceSlider.value = [distanceLabel.text floatValue];
            distanceLabel.text = [NSString stringWithFormat:@"%.2f", distanceSlider.value];
        }
        else {
            if (userProfile.unit == IMPERIAL) {
                distanceLabel.text = [NSString stringWithFormat:@"%.2f", (self.userDefaultsManager.distanceGoal * 0.621371)];
                distanceSlider.value = (self.userDefaultsManager.distanceGoal * 0.621371);
            }
            else {
                distanceLabel.text = [NSString stringWithFormat:@"%.2f", self.userDefaultsManager.distanceGoal];
                distanceSlider.value = self.userDefaultsManager.distanceGoal;
            }
        }
        [distanceLabel setNeedsDisplay];
        [distanceSlider setNeedsDisplay];
    }
    else if (editingTextField == CALORIES_TEXTFIELD) {
        if ([caloriesLabel.text intValue] <= caloriesSlider.maximumValue
            && [caloriesLabel.text intValue] >= caloriesSlider.minimumValue)
            caloriesSlider.value = [caloriesLabel.text intValue];
        else {
            caloriesSlider.value = self.userDefaultsManager.calorieGoal;
            caloriesLabel.text = [NSString stringWithFormat:@"%d", self.userDefaultsManager.calorieGoal];
        }
        [caloriesLabel setNeedsDisplay];
        [caloriesSlider setNeedsDisplay];

    }
    else if (editingTextField == SLEEP_TEXTFIELD) {
        int totalNumberOfMinutes = (hour * 60) + minute;
        sleepLabel.text = [NSString stringWithFormat:@"%dh%dm", hour, minute];
        sleepSlider.value = totalNumberOfMinutes;
        
        [sleepLabel setNeedsDisplay];
        [sleepSlider setNeedsDisplay];
        
        int sleep = (hour * 60) + minute;
        int sleepLo = sleep&0x00ff;
        int sleepHi = (sleep&0xff00)>>8;
        SleepSetting *sleepSetting = [[SleepSetting alloc] init];
        sleepSetting.sleep_goal_lo = sleepLo;
        sleepSetting.sleep_goal_hi = sleepHi;
        
        if (self.deviceEntity.modelNumber.integerValue == WatchModel_R450) {
            sleepSetting.sleep_mode = 3;//MANUAL;//self.userDefaultsManager.sleepSetting.sleep_mode;
        } else {
            sleepSetting.sleep_mode = self.userDefaultsManager.sleepSetting.sleep_mode;
        }
        
        self.userDefaultsManager.sleepSetting = sleepSetting;
        self.deviceEntity.sleepSetting = [SleepSettingEntity sleepSettingWithSleepSetting:sleepSetting forDeviceEntity:self.deviceEntity];
        self.userDefaultsManager.sleepGoal = sleep;
        
        if (self.deviceEntity.modelNumber.integerValue == WatchModel_R450) {
            sleepSetting.sleep_mode = 3;//MANUAL;//self.userDefaultsManager.sleepSetting.sleep_mode;
        } else {
            sleepSetting.sleep_mode = self.userDefaultsManager.sleepSetting.sleep_mode;
        }
    }
    else if (editingTextField == LIGHT_TEXTFIELD) {
        lightHour = [self.sleepPicker selectedRowInComponent:0];
        lightMinute = [self.sleepPicker selectedRowInComponent:1];
        if ((lightHour*60 + lightMinute) > self.briteLightSlider.maximumValue) {
            lightHour = (int)self.briteLightSlider.maximumValue/60;
            lightMinute = (int)self.briteLightSlider.maximumValue%60;
        }
        else if (lightHour == 0 && lightMinute == 0){
            lightMinute = 10;
        }
        
        int totalNumberOfMinutes = (lightHour * 60) + lightMinute;
        self.briteLightLabel.text = [NSString stringWithFormat:@"%dh%dm", lightHour, lightMinute];
        self.briteLightSlider.value = totalNumberOfMinutes;
        
        [self briteLightValueChangedManually];
        
        [self.briteLightLabel setNeedsDisplay];
        [self.briteLightSlider setNeedsDisplay];
    }

    [stepsLabel resignFirstResponder];
    [distanceLabel resignFirstResponder];
    [caloriesLabel resignFirstResponder];
    [sleepLabel resignFirstResponder];
    [self.briteLightLabel resignFirstResponder];
    
    self.userDefaultsManager.stepGoal = stepsSlider.value;
    
    if (userProfile.unit == IMPERIAL) {
        self.userDefaultsManager.distanceGoal = distanceSlider.value * 1.60934;
    }
    else {
        self.userDefaultsManager.distanceGoal = distanceSlider.value;
    }
    self.userDefaultsManager.calorieGoal = caloriesSlider.value;
    
    //[self saveGoalsToCoreData];
    [self.tableView reloadData];
}

- (void)sleepKeyboardUp:(NSNotification *)notification
{
    NSDictionary *userInfo  = [notification userInfo];
    CGRect keyboardFrame    = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIEdgeInsets insets     = UIEdgeInsetsMake(0.0f, 0.0f, keyboardFrame.size.height, 0.0f);
    [self.tableView setContentInset:insets];
}

- (void)sleepKeyboardDown:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25 animations:^{
        UIEdgeInsets insets     = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        [self.tableView setContentInset:insets];
    } completion:^(BOOL finished) {
    }];

}

- (void)didChangeSettings
{
    if (!self.userDefaultsManager.promptChangeSettings) {
        switch (self.userDefaultsManager.syncOption) {
                
            case SyncOptionWatch:
                [self didPressWatchButtonOnSettingsPromptView:nil];
                break;
                
            case SyncOptionApp:
                [self didPressAppButtonOnSettingsPromptView:nil];
                break;
            case SyncOptionNone:
                [self didPressWatchButtonOnSettingsPromptView:nil];
                break;
                
            default:
                [self didPressAppButtonOnSettingsPromptView:nil];
                break;
        }
    }
    else {
        [SFASettingsPromptView settingsPromptView].delegate = self;
        [SFASettingsPromptView show];
    }
}

- (void)didSaveSettings
{
    self.isSyncing = NO;
    //[SVProgressHUD showSuccessWithStatus:SYNC_SUCCESS];
    [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
        
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
}

#pragma mark - SalutronSync Delegate
- (void)didRaiseError{
    [self didDeviceDisconnected:NO];
}

- (void)didDeviceDisconnected:(BOOL)isSyncFinished
{
    [SFASettingsPromptView hide];
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    if (!self.isDisconnected || !isSyncFinished) {
        self.isDisconnected = YES;
        //[SVProgressHUD showErrorWithStatus:DEVICE_DISCONNECTED];
        
        /*
        [SVProgressHUD dismiss];
        [SFASyncProgressView showWithMessage:DEVICE_DISCONNECTED animate:NO showOKButton:YES onButtonClick:^{
            [SFASyncProgressView hide];
        }];
         */
        [self.salutronSync stopSync];
        [SFASyncProgressView hide];
        //[SFASyncProgressView showWithMessage:DEVICE_DISCONNECTED animate:NO showButton:NO dismiss:YES];
        /*
         [SFASyncProgressView showWithMessage:DEVICE_DISCONNECTED animate:NO showOKButton:YES onButtonClick:^{
         [SVProgressHUD dismiss];
         [SFASyncProgressView hide];
         }];
         */
        
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
         if ([self respondsToSelector:@selector(showTryAgainViewWithTarget:cancelSelector:tryAgainSelector:)] && !self.didCancel) {
        [self showTryAgainViewWithTarget:self
                          cancelSelector:@selector(cancelOnTimeoutClick)
                            tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
         }

        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    }
    
    self.isSyncing = NO;
}

- (void)didPairWatch{
    self.isDisconnected = YES;
    [self cancelSyncing:nil];
    //[self startSyncConnectedRModel];
    
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    [SFASyncProgressView hide];
    
    self.isSyncing = YES;
    
    [SFASyncProgressView progressView].delegate = self;
    [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES onButtonClick:^{
        [self.salutronSync stopSync];
    }];
}

- (void)didSyncStarted
{
    if (self.userDefaultsManager.watchModel != WatchModel_R450) {
        //self.salutronSyncC300 = nil;
        self.salutronSyncC300.delegate = nil;
        [self updateWatchGoals];
    }
    
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    [SFASyncProgressView hide];
    
    self.isSyncing = YES;
    
    [SFASyncProgressView progressView].delegate = self;
    [SFASyncProgressView showWithMessage:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES];
    //[SVProgressHUD showWithStatus:SYNC_SHORT_MESSAGE([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) maskType:SVProgressHUDMaskTypeClear];
}

- (void)didSyncFinished:(DeviceEntity *)deviceEntity profileUpdated:(BOOL)profileUpdated
{
    self.isSyncing = NO;
    //[SVProgressHUD showSuccessWithStatus:SYNC_SUCCESS];
    [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
        
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
//    [self syncToServer];
}

- (void)didUpdateFinish
{
    self.isSyncing = NO;
    [SFASyncProgressView hide];
    //[SVProgressHUD showSuccessWithStatus:SYNC_SUCCESS];
    
    if (![self isTryAgainShowing]) {
        [SFASyncProgressView showWithMessage:SYNC_SUCCESS animate:NO showOKButton:YES onButtonClick:^{
            
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    }
}

- (void)didDiscoverTimeout
{
    /*
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    [SFASyncProgressView hide];
    
    self.isSyncing = NO;
    [SVProgressHUD showErrorWithStatus:SYNC_NOT_FOUND_MESSAGE];
    */
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    if (!self.isDisconnected || (self.isDisconnected && self.userDefaultsManager.watchModel != WatchModel_R450)) {
        self.isDisconnected = YES;
        [self.salutronSync stopSync];
        [SFASyncProgressView hide];
        
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
         if ([self respondsToSelector:@selector(showTryAgainViewWithTarget:cancelSelector:tryAgainSelector:)] && !self.didCancel) {
        [self showTryAgainViewWithTarget:self
                          cancelSelector:@selector(cancelOnTimeoutClick)
                        tryAgainSelector:@selector(tryAgainOnTimeoutClick)];
         }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    }
    
    self.isSyncing = NO;
}

- (void)didRetrieveDeviceFromSearching
{
    //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:NO showButton:YES];
    if (self.pairViewController && self.pairViewController.isViewLoaded) {
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    }
    [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES onButtonClick:^{
        [self.salutronSync stopSync];
    }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0: {
            if (self.userDefaultsManager.isBlueToothOn) {
                if(self.userDefaultsManager.watchModel != WatchModel_R450){
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
                            [self startSyncCModel];
                        });
                    }
                    else{
                        [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
                        [self startSyncCModel];
                    }
                   
                }
                else{
                    [self startSyncRModel];
                    //[self updateWatchGoals];
                }
            } else {
                if (self.isIOS8AndAbove) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                             message:TURN_ON_BLUETOOTH
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction
                                               actionWithTitle:BUTTON_TITLE_OK
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   
                                               }];
                    
                    [alertController addAction:okAction];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:TURN_ON_BLUETOOTH
                                                                   delegate:nil
                                                          cancelButtonTitle:BUTTON_TITLE_OK_NORMAL
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        }
            break;
        case 1: {
            stepsLabel.text = @"10000";
            stepsSlider.value = 10000;
            
            if (userProfile.unit == IMPERIAL) {
                distanceLabel.text = @"5.0";
                distanceSlider.value = 5.0;
            }
            else {
                distanceLabel.text = @"8.0";
                distanceSlider.value = 8.04672;
            }
            
            caloriesLabel.text = @"3000";
            caloriesSlider.value = 3000;
            sleepLabel.text = [NSString stringWithFormat:@"%ih%im", 480/60, 480%60];
            sleepSlider.value = 480;
            [self updateUserDefaultsGoalsData];
        }
            break;
        case 2: {
            // Restore To Previous
            
            NSString *macAddress = self.userDefaultsManager.macAddress;
            JDACoreData *manager = [JDACoreData sharedManager];
 
            GoalsEntity *goals = [SFAGoalsData goalsFromNearestDate:[NSDate date] macAddress:macAddress managedObject:manager.context];
            if (goals == nil) {
                stepsLabel.text = @"10000";
                stepsSlider.value = 10000;
                
                if (userProfile.unit == IMPERIAL) {
                    distanceLabel.text = @"5.0";
                    distanceSlider.value = 5.0;
                }
                else {
                    distanceLabel.text = @"8.0";
                    distanceSlider.value = 8.04672;
                }
                
                caloriesLabel.text = @"3000";
                caloriesSlider.value = 3000;
                sleepLabel.text = [NSString stringWithFormat:@"%ih%im", 480/60, 480%60];
                sleepSlider.value = 480;
                [self updateUserDefaultsGoalsData];
            }
            else {
                stepsLabel.text = [NSString stringWithFormat:@"%i",[goals.steps intValue]];
                stepsSlider.value = [goals.steps intValue];
                
                if (userProfile.unit == IMPERIAL) {
                    distanceLabel.text = [NSString stringWithFormat:@"%.2f", [goals.distance floatValue] * 0.621371];
                    distanceSlider.value = [goals.distance floatValue] * 0.621371;
                }
                else {
                    distanceLabel.text = [NSString stringWithFormat:@"%.2f", [goals.distance floatValue]];
                    distanceSlider.value = [goals.distance floatValue];
                }
                
                caloriesLabel.text = [NSString stringWithFormat:@"%i", [goals.calories intValue]];
                caloriesSlider.value = [goals.calories intValue];
                
                sleepLabel.text = [NSString stringWithFormat:@"%ih%im", [goals.sleep intValue]/60, [goals.sleep intValue]%60];
                sleepSlider.value = [goals.sleep intValue];
                
                SleepSetting *sleepSetting = [[SleepSetting alloc] init];
                sleepSetting.sleep_goal_hi = [goals.sleep intValue];
                
//                self.updateManager.delegate = self;
//                [self.updateManager startUpdateGoalsWithWatchModel:self.userDefaultsManager.watchModel
//                                               salutronUserProfile:userProfile
//                                                      sleepSetting:sleepSetting
//                                                      distanceGoal:[goals.distance floatValue]
//                                                       calorieGoal:[goals.calories intValue]
//                                                          stepGoal:[goals.steps intValue]
//                                                         sleepGoal:[goals.sleep intValue]
//                                                          timeDate:self.userDefaultsManager.timeDate];
                [self updateUserDefaultsGoalsData];
            }
        }
            break;
        default:
            break;
    }
    
    
    [self.tableView reloadData];
}

#pragma mark - Update user defaults

- (void)updateUserDefaultsGoalsData
{
    CGFloat distanceGoal = userProfile.unit == IMPERIAL ? distanceSlider.value * 1.60934 : distanceSlider.value;
    int sleep = sleepSlider.value;
    int sleepLo = sleep&0x00ff;
    int sleepHi = (sleep&0xff00)>>8;
    SleepSetting *sleepSetting = [[SleepSetting alloc] init];
    sleepSetting.sleep_goal_lo = sleepLo;
    sleepSetting.sleep_goal_hi = sleepHi;
    
    if (self.deviceEntity.modelNumber.integerValue == WatchModel_R450) {
        sleepSetting.sleep_mode = 3;//MANUAL;//self.userDefaultsManager.sleepSetting.sleep_mode;
    } else {
        sleepSetting.sleep_mode = self.userDefaultsManager.sleepSetting.sleep_mode;
    }
    
    self.userDefaultsManager.distanceGoal   = distanceGoal;
    self.userDefaultsManager.stepGoal       = stepsSlider.value;
    self.userDefaultsManager.calorieGoal    = caloriesSlider.value;
    self.userDefaultsManager.sleepGoal      = sleepSlider.value;
    self.userDefaultsManager.sleepSetting   = sleepSetting;
    self.deviceEntity.sleepSetting = [SleepSettingEntity sleepSettingWithSleepSetting:sleepSetting forDeviceEntity:self.deviceEntity];
}

#pragma mark - Private Methods

- (NSString *)watchModelStringForWatchModel:(WatchModel)watchModel
{
    if (watchModel == WatchModel_Core_C200) {
        return WATCHNAME_CORE_C200;
    }
    else if (watchModel == WatchModel_Move_C300 || watchModel == WatchModel_Move_C300_Android) {
        return WATCHNAME_MOVE_C300;
    }
    else if (watchModel == WatchModel_Zone_C410) {
        return WATCHNAME_ZONE_C410;
    }
    else if (watchModel == WatchModel_R420) {
        return WATCHNAME_R420;
    }
    else if (watchModel == WatchModel_R450) {
        return WATCHNAME_BRITE_R450;
    }
    else if (watchModel == WatchModel_R500) {
        return WATCHNAME_R500;
    }
    else {
        return WATCHNAME_DEFAULT;
    }
    
    return nil;
}

- (BOOL)isAutoSyncForWatchModel:(WatchModel)watchModel
{
    if (watchModel == WatchModel_Core_C200) {
        return NO;
    }
    else if (watchModel == WatchModel_Move_C300 ||
             watchModel == WatchModel_Move_C300_Android) {
        return NO;
    }
    else if (watchModel == WatchModel_Zone_C410 ||
             watchModel == WatchModel_R420) {
        return NO;
    }
    else if (watchModel == WatchModel_R450) {
        return YES;
    }
    else if (watchModel == WatchModel_R500) {
        return YES;
    }
    
    return NO;
}

- (void)didTapTableView:(id)sender
{
    if (self.activeTextField) {
        [self.activeTextField resignFirstResponder];
        [self.tableView reloadData];
    }
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (self.pairViewController && self.pairViewController.isViewLoaded) {
            [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.watchModel]) animate:YES showButton:YES onButtonClick:^{
            [self.salutronSync stopSync];
        }];
        //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:YES showButton:YES];
        self.isDisconnected = NO;
        
        [self updateWatchGoals];
    }
}

#pragma mark - Update watch goals data

- (void)updateWatchGoals
{
    self.updateManager.delegate         = self;
    [self.updateManager startUpdateGoalsWithWatchModel:self.userDefaultsManager.watchModel
                                 salutronUserProfile:userProfile
                                        sleepSetting:[self sleepSettingValue]
                                        distanceGoal:[self distanceGoalValue]
                                         calorieGoal:self.userDefaultsManager.calorieGoal
                                            stepGoal:self.userDefaultsManager.stepGoal
                                           sleepGoal:self.userDefaultsManager.sleepGoal
                                         daylightAlert:self.userDefaultsManager.dayLightAlert
                                              timeDate:nil/*[TimeDate getUpdatedData]*/];
    //[self updateUserDefaultsGoalsData];
    //[self saveGoalsToCoreData];
}

- (void)startSyncRModel
{
    self.salutronSync                              = [[SFASalutronSync alloc] init];
    self.salutronSync.delegate                     = self;
    self.salutronSync.selectedWatchModel           = WatchModel_R450;
    self.salutronSync.connectDevice                = YES;
    self.didCancel                                  = NO;
    [self.salutronSync searchConnectedDevice];
    //[self startSyncConnectedRModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)startSyncCModel
{
    self.salutronSyncC300.delegate = self;
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress];
    
    self.salutronSyncC300.updateTimeAndDate = self.userDefaultsManager.autoSyncTimeEnabled;
    self.salutronSyncC300.watchSettingsSelected = YES;
    [self.salutronSyncC300 startSyncWithDeviceEntity:deviceEntity watchModel:self.userDefaultsManager.watchModel];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didSearchConnectedWatch:(BOOL)found
{
    
    if (!self.didCancel) {
        if (found) {
            //[self.pairViewController dismissViewControllerAnimated:YES completion:nil];
            //[self startSyncConnectedRModel];
            //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:YES showButton:YES];
            if (self.pairViewController && self.pairViewController.isViewLoaded) {
                [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
            }
            [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES onButtonClick:^{
                [self.salutronSync stopSync];
            }];
        } else {
            [SFASyncProgressView hide];
            if (!self.pairViewController) {
                [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
            }
            [self.salutronSync startSync];
        }
    }
}

- (void)didDeviceConnectedFromSearching
{
    [SFASyncProgressView hide];
    [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    [self startSyncConnectedRModel];
}

- (void)startSyncConnectedRModel{
    self.salutronSync                              = [[SFASalutronSync alloc] init];
    self.salutronSync.delegate                     = self;
    self.salutronSync.selectedWatchModel           = WatchModel_R450;
    
    if (self.pairViewController && self.pairViewController.isViewLoaded)
        [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
    
    [SFASyncProgressView progressView].delegate = self;
    [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.userDefaultsManager.watchModel]) animate:YES showButton:YES onButtonClick:^{
        [self.salutronSync stopSync];
    }];
    //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:YES showButton:YES];
    
    //[self.salutronSync startSync];
    [self updateWatchGoals];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_ON_GOING object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"InitialWatchToAppSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)cancelOnTimeoutClick
{
    [self hideTryAgainView];
    [self hideTryAgainView];
}

- (void)tryAgainOnTimeoutClick
{
    if (self.userDefaultsManager.isBlueToothOn) {
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            [self startSyncRModel];
        } else {
            [self performSegueWithIdentifier:PAIR_SEGUE_IDENTIFIER sender:self];
            [self startSyncCModel];
        }
    } else {
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                     message:TURN_ON_BLUETOOTH
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_OK
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:TURN_ON_BLUETOOTH
                                                           delegate:nil
                                                  cancelButtonTitle:BUTTON_TITLE_OK_NORMAL
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    
    [self hideTryAgainView];
}

#pragma mark - Cancel sync

- (IBAction)cancelSyncing:(UIStoryboardSegue *)segue
{
    DDLogInfo(@"");
    
    [self.updateManager cancelSyncing];
    if ([segue.sourceViewController isKindOfClass:[SFAPairViewController class]]) {
        self.didCancel = YES;
        self.isStillSyncing = YES;
        
        [SFASyncProgressView hide];
        
        if (self.userDefaultsManager.watchModel == WatchModel_R450) {
            //[self didDeviceDisconnected:NO];
            self.didCancel = YES;
            //[self cancelSyncing:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
        }
        else {
            [self.salutronSyncC300 disconnectWatch];
        }
    }
    
    if (self.userDefaultsManager.watchModel != WatchModel_R450) {
        [self.salutronSyncC300.salutronSDK commDone];
        [self.salutronSyncC300.salutronSDK disconnectDevice];
        [self.salutronSync.salutronSDK disconnectDevice];
    }
    
    //self.salutronSyncC300.delegate = nil;
    //self.salutronSyncC300.salutronSDK.delegate = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    // [[SFAWatchManager sharedManager] rescheduleAutoSyncNotifications];
    //   if (self.userDefaultsManager.notificationStatus == YES) {
    //       [[SFASalutronUpdateManager sharedInstance] startUpdateNotificationStatusWithWatchModel:self.userDefaultsManager.watchModel notificationStatus:YES];
    //   }
    
    
}



#pragma mark - Computer

- (double)distanceGoalValue
{
//    double distanceValue;
//    
//    if(userProfile.unit == IMPERIAL) {
//        
//        if (distanceSlider.value < 0.621371) {
//            distanceValue = 1.0f;
//        } else {
//            distanceValue = distanceSlider.value * 1.60934;
//        }
//    } else {
//        distanceValue = distanceSlider.value;
//    }
    
    CGFloat distanceValue = userProfile.unit == IMPERIAL ? distanceSlider.value * 1.60934 : distanceSlider.value;
    
    double value = round(distanceValue * 100);
    value = value + 0.1f;
    value = value / 100.0f;
    
    self.userDefaultsManager.distanceGoal = value;
    
    return distanceValue;
}

- (SleepSetting *)sleepSettingValue
{
    SleepSetting *sleepSetting = [[SleepSetting alloc] init];
    
    sleepSetting.sleep_goal_lo = self.userDefaultsManager.sleepGoal&0x00ff;
    sleepSetting.sleep_goal_hi = (self.userDefaultsManager.sleepGoal&0xff00)>>8;
    
    if (self.deviceEntity.modelNumber.integerValue == WatchModel_R450) {
        sleepSetting.sleep_mode = 3;//MANUAL;//AUTO;
    } else {
        sleepSetting.sleep_mode = self.userDefaultsManager.sleepSetting.sleep_mode;
    }
    
    return sleepSetting;
}

#pragma mark - Save to coredata

- (void)saveGoalsToCoreData
{
    // Add goals to core data
    JDACoreData *coreData = [JDACoreData sharedManager];
    [SFAGoalsData addGoalsWithSteps:self.userDefaultsManager.stepGoal
                           distance:self.userDefaultsManager.distanceGoal
                           calories:self.userDefaultsManager.calorieGoal
                              sleep:self.userDefaultsManager.sleepGoal
                             device:self.deviceEntity
                      managedObject:coreData.context];
}

#pragma mark - Sync to server

- (void) syncToServer
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/x-www-form-urlencoded"];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.securityPolicy.allowInvalidCertificates     = YES;
    manager.securityPolicy = securityPolicy;
    
    NSDictionary *goalDictionary;
    
    NSArray *goals = [GoalsEntity goalsEntitiesDictionaryForDeviceEntity:[DeviceEntity deviceEntityForMacAddress:self.userDefaultsManager.macAddress]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *lastSyncDate = self.userDefaultsManager.lastSyncedDate;
    NSDictionary *deviceInfo = [[NSDictionary alloc] initWithObjectsAndKeys:self.userDefaultsManager.macAddress, @"mac_address", self.userDefaultsManager.watchModel, @"model_number", @"MJ", @"device_name", [dateFormatter stringFromDate:lastSyncDate], @"last_date_synced", nil];
    
    for (NSDictionary *goal in goals) {
        NSString *createdDate = [dateFormatter stringFromDate:[goal objectForKey:@"goal_created_date_time"]];
        
        goalDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[goal objectForKey:@"calories"], @"calories", [goal objectForKey:@"steps"], @"steps", [goal objectForKey:@"distance"], @"distance", [goal objectForKey:@"sleep"], @"sleep", createdDate, @"goal_created_date_time", nil];
    }
    
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:deviceInfo, @"device", goalDictionary, @"goal", nil];
    
    NSError *jError = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&jError];
    NSString *jString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:jString, @"data", [[NSUserDefaults standardUserDefaults] objectForKey:API_OAUTH_ACCESS_TOKEN], @"access_token", nil];
    
    AFHTTPRequestOperation *blablaOperation = [manager POST:SYNC_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self storeToServer];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *responseDictionary = [self responseStringToDictionary:[operation responseString]];
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", [ERROR_TITLE uppercaseString], [responseDictionary objectForKey:@"\"status\""]]
                                                                                     message:[responseDictionary objectForKey:@"\"error_description\""]
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_OK_NORMAL
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@", [ERROR_TITLE uppercaseString], [responseDictionary objectForKey:@"\"status\""]] message:[responseDictionary objectForKey:@"\"error_description\""] delegate:self cancelButtonTitle:BUTTON_TITLE_OK_NORMAL otherButtonTitles: nil];
            [alert show];
        }
    }];
    
    [blablaOperation setWillSendRequestForAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
            if (YES){ // TODO replace this with check from array comparing host.
                [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            }
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
        
    }];
}

- (void)storeToServer
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.securityPolicy.allowInvalidCertificates     = YES;
    manager.securityPolicy = securityPolicy;
    
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:self.userDefaultsManager.macAddress, @"mac_address", [[NSUserDefaults standardUserDefaults] objectForKey:API_OAUTH_ACCESS_TOKEN], @"access_token", nil];
    
    [manager POST:STORE_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@!",[LS_SUCCESS uppercaseString]]
                                                                                     message:LS_SUCCESS_SERVER_SYNC
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_OK_NORMAL
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@!",[LS_SUCCESS uppercaseString]] message:LS_SUCCESS_SERVER_SYNC delegate:self cancelButtonTitle:BUTTON_TITLE_OK_NORMAL otherButtonTitles: nil];
            [alert show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *responseDictionary = [self responseStringToDictionary:[operation responseString]];
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ %@", [ERROR_TITLE uppercaseString],  [responseDictionary objectForKey:@"\"status\""]]
                                                                                     message:[responseDictionary objectForKey:@"\"error_description\""]
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:BUTTON_TITLE_OK_NORMAL
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
            
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@", [ERROR_TITLE uppercaseString],  [responseDictionary objectForKey:@"\"status\""]] message:[responseDictionary objectForKey:@"\"error_description\""] delegate:self cancelButtonTitle:BUTTON_TITLE_OK_NORMAL otherButtonTitles: nil];
            [alert show];
        }
    }];
}

- (NSDictionary *)responseStringToDictionary:(NSString *)responseString
{
    NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *stringComponents = [responseString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{}:,"]];
    for (int i = 0; i < [stringComponents count]; i=i+2) {
        if ([[stringComponents objectAtIndex:i] isEqualToString:@""] && i+2< [stringComponents count])
            i++;
        if (i+2 > [stringComponents count])
            break;
        [responseDictionary setObject:[stringComponents objectAtIndex:i+1] forKey:[stringComponents objectAtIndex:i]];
    }
    
    return responseDictionary;
}

#pragma mark - SFAPairViewControllerDelegate Methods

- (void)didPressContinueInPairViewController:(SFAPairViewController *)viewController
{
    // When the app and the watch are connected, there's no need to display "Searching for your R415"
    if (self.userDefaultsManager.watchModel != WatchModel_R450) {
        if (self.pairViewController && self.pairViewController.isViewLoaded) {
            [self.pairViewController dismissViewControllerAnimated:YES completion:nil];
        }
        [SFASyncProgressView showWithMessage:SYNC_SEARCH([SFAWatch watchModelStringForWatchModel:self.watchModel]) animate:YES showButton:YES onButtonClick:^{
            [self.salutronSync stopSync];
        }];
        //[SFASyncProgressView showWithMessage:BLUETOOTH_ACTIVE animate:YES showButton:YES];
    }
    [self updateWatchGoals];
}

- (void)didPressCancelInPairViewController:(SFAPairViewController *)viewController
{
    self.updateManager.delegate = nil;
    self.didCancel = YES;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            _bluetoothOn = NO;
            break;
        case CBCentralManagerStatePoweredOn:
            _bluetoothOn = YES;
            break;
        default:
            break;
    }
    self.userDefaultsManager.bluetoothOn = _bluetoothOn;
}


#pragma mark - SFASyncProgressViewDelegate Methods

- (void)didPressButtonOnProgressView:(SFASyncProgressView *)progressView
{
    DDLogInfo(@"");
    
    self.didCancel = YES;
    [SFASyncProgressView hide];
    [self cancelSyncing:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
}


#pragma mark - SFASettingsPromptViewDelegate Methods

- (void)didPressAppButtonOnSettingsPromptView:(SFASettingsPromptView *)view
{/*
    if (!self.userDefaultsManager.promptChangeSettings) {
        self.userDefaultsManager.syncOption = SyncOptionApp;
    }
    */
    [self.salutronSyncC300 useAppSettings];
}

- (void)didPressWatchButtonOnSettingsPromptView:(SFASettingsPromptView *)view
{/*
    if (!self.userDefaultsManager.promptChangeSettings) {
        self.userDefaultsManager.syncOption = SyncOptionWatch;
    }
    */
    [self.salutronSyncC300 useWatchSettings];
}


@end
