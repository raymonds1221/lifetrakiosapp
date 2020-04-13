//
//  SFASmartCalibrationViewController.m
//  SalutronFitnessApp
//
//  Created by Dana Elisa Nicolas on 1/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASmartCalibrationViewController.h"

#import "SFASmartCalibrationTableViewCell.h"
#import "SFASmartCalibrationCellHeader.h"
#import "SFAUserDefaultsManager.h"

#import "CalibrationData+CalibrationDataCategory.h"
#import "CalibrationDataEntity+Data.h"
#import "SFASettingsViewController.h"

#import "DeviceEntity+Data.h"
#import "JDACoreData.h"
#import "CalibrationData+Data.h"


static CGFloat  const CELL_HEIGHT = 88.0f;
static CGFloat  const CELL_HEIGHT_IPAD = 66.0f;
static CGFloat  const CELL_SLIDER_HEIGHT = 134.0f;


@interface SFASmartCalibrationViewController () <UITableViewDataSource, UITableViewDelegate, SFASmartCalibrationTableViewCellDelegate>
{
    UISlider    *_distanceCalSlider;
    UILabel     *_distanceCalLabel;
    UISlider    *_caloriesCalSlider;
    UILabel     *_caloriesCalLabel;
    UISwitch    *_autoElSwitch;
}

@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) CalibrationData *calibrationData;
@property (strong, nonatomic) SFASettingsViewController *syncSetupViewController;
@property (strong, nonatomic) NSArray *stepsDescription;
@property (strong, nonatomic) SFAUserDefaultsManager *userDefaultsManager;
@property (assign, nonatomic) WatchModel watchModel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SFASmartCalibrationViewController

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
    self.watchModel = self.userDefaultsManager.watchModel;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    /*
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.calibrationData];
    
    [self.userDefaults setObject:data forKey:CALIBRATION_DATA];
    [self.userDefaults synchronize];
    */
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
    self.calibrationData = [CalibrationData calibrationDataWithCalibrationDataEntity:deviceEntity.calibrationData];
    
//    self.calibrationData = [NcSKeyedUnarchiver unarchiveObjectWithData:[self.userDefaults objectForKey:CALIBRATION_DATA]];
    
    [self.tableView reloadData];
    
    UINavigationController *navigationController = (UINavigationController *)self.parentViewController;
    self.syncSetupViewController = (SFASettingsViewController *)navigationController.viewControllers[0];
}

#pragma mark - Lazy Load

- (NSUserDefaults *) userDefaults {
    if(!_userDefaults)
        _userDefaults = [NSUserDefaults standardUserDefaults];
    return _userDefaults;
}

- (CalibrationData *)calibrationData
{
    if (!_calibrationData)
        _calibrationData = [[CalibrationData alloc] init];
    return _calibrationData;
}

- (SFAUserDefaultsManager *)userDefaultsManager
{
    if    (!_userDefaultsManager)
        _userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    return _userDefaultsManager;
}

#pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.watchModel == WatchModel_R450 || self.watchModel == WatchModel_R500) ? 3 : 2;
}
/*
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return LS_STEPS_TITLE;
            break;
        case 1:
            return @"Distance";
            break;
        case 2:
            if    (self.watchModel == WatchModel_R450 || self.watchModel == WatchModel_R500)
                return @"Calories";
            else
                return NSLocalizedString(@"Auto EL", nil);
            break;
        default:
            return NSLocalizedString(@"Auto EL", nil);
            break;
    }
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return  CELL_HEIGHT_IPAD+10;
    }
    return CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return  CELL_HEIGHT_IPAD;
        }
        return CELL_HEIGHT;
    }
    return CELL_SLIDER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        NSMutableAttributedString * attributedString= [[NSMutableAttributedString alloc] initWithString:SMART_CALIB_STEP_DESCRIPTION];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12.0f] range:[attributedString.string rangeOfString:SMART_CALIB_STEP_BRIEF]];
        
        SFASmartCalibrationCellHeader *header = [tableView dequeueReusableCellWithIdentifier:@"SmartCalibrationCellHeader"];
        [header.titleLabel setText:SMART_CALIB_STEP_TITLE];
        [header.descriptionLabel setAttributedText:attributedString];
        return header;
    }
    if (section == 1) {
        NSMutableAttributedString * attributedString= [[NSMutableAttributedString alloc] initWithString:SMART_CALIB_DISTANCE_DESCRIPTION];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12.0f] range:[attributedString.string rangeOfString:SMART_CALIB_DISTANCE_BRIEF]];
        
        SFASmartCalibrationCellHeader *header = [tableView dequeueReusableCellWithIdentifier:@"SmartCalibrationCellHeader"];
        [header.titleLabel setText:SMART_CALIB_DISTANCE_TITLE];
        [header.descriptionLabel setAttributedText:attributedString];
        return header;
    }
    if (section == 2) {
        NSMutableAttributedString * attributedString= [[NSMutableAttributedString alloc] initWithString:SMART_CALIB_CALORIES_DESCRIPTION];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12.0f] range:[attributedString.string rangeOfString:SMART_CALIB_CALORIES_BRIEF]];
        
        SFASmartCalibrationCellHeader *header = [tableView dequeueReusableCellWithIdentifier:@"SmartCalibrationCellHeader"];
        [header.titleLabel setText:SMART_CALIB_CALORIES_TITLE];
        [header.descriptionLabel setAttributedText:attributedString];
        return header;
    }
    
    return [UIView new];
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
        default:
            return 1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFASmartCalibrationTableViewCell *smartCalCell;
    
    switch (indexPath.section) {
        case 0: {
            StepsCalibration stepsCalibration = self.calibrationData.calib_step;
            
            smartCalCell = [tableView dequeueReusableCellWithIdentifier:@"StepsCalibrationCell"];
            //[smartCalCell.stepsOption addTarget:self action:@selector(stepsCalibrationSet:) forControlEvents:UIControlEventTouchUpInside];
            smartCalCell.accessoryType = UITableViewCellAccessoryNone;
            
            if (indexPath.row == 0) {
                smartCalCell.titleLabel.text = LS_DEFAULT_TITLE;
                smartCalCell.descriptionLabel.text = self.stepsDescription[indexPath.row];
                //[smartCalCell.stepsOption setTitle:@"Default" forState:UIControlStateNormal];
                if (stepsCalibration == StepsCalibrationDefault){
                    smartCalCell.checkButton.selected = YES;
                }
                else{
                    smartCalCell.checkButton.selected = NO;
                }
            }
            else if (indexPath.row == 1){
                smartCalCell.titleLabel.text = SMART_CALIB_OPTION_A;
                smartCalCell.descriptionLabel.text = self.stepsDescription[indexPath.row];
                //[smartCalCell.stepsOption setTitle:@"Option A" forState:UIControlStateNormal];
                if (stepsCalibration == StepsCalibrationOptionA){
                    smartCalCell.checkButton.selected = YES;
                }
                else{
                    smartCalCell.checkButton.selected = NO;
                }
            }
            else {
                smartCalCell.titleLabel.text = SMART_CALIB_OPTION_B;
                smartCalCell.descriptionLabel.text = self.stepsDescription[indexPath.row];
                //[smartCalCell.stepsOption setTitle:@"Option B" forState:UIControlStateNormal];
                if (stepsCalibration == StepsCalibrationOptionB){
                    smartCalCell.checkButton.selected = YES;
                }
                else{
                    smartCalCell.checkButton.selected = NO;
                }
            }
            smartCalCell.delegate = self;
        }
            break;
        case 1:
            smartCalCell = [tableView dequeueReusableCellWithIdentifier:@"DistanceCalibrationCell"];
            [smartCalCell.distanceSlider setTintColor:[UIColor blueColor]];
            smartCalCell.distanceSlider.minimumValue = -25.0f;
            smartCalCell.distanceSlider.maximumValue = 25.0f;
            [smartCalCell.distanceSlider addTarget:self action:@selector(distanceSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            
            _distanceCalSlider = smartCalCell.distanceSlider;
            _distanceCalLabel = smartCalCell.distanceCalLabel;
            
            smartCalCell.shorterStridesLabel.text = SMART_CALIB_SHORTER_STRIDES;
            smartCalCell.longerStridesLabel.text = SMART_CALIB_LONGER_STRIDES;
            
            if (self.calibrationData.calib_walk) {
                
                smartCalCell.distanceCalLabel.text = [NSString stringWithFormat:@"%d%%", self.calibrationData.calib_walk];
                smartCalCell.distanceSlider.value = self.calibrationData.calib_walk;
                [smartCalCell.distanceSlider setNeedsDisplay];
            }
            else {
                smartCalCell.distanceCalLabel.text = [NSString stringWithFormat:@"%d%%", 0];
                smartCalCell.distanceSlider.value = 0;
                [smartCalCell.distanceSlider setNeedsDisplay];
            }
            
            break;
        case 2:
            if    (self.watchModel == WatchModel_R450 || self.watchModel == WatchModel_R500) {
                smartCalCell = [tableView dequeueReusableCellWithIdentifier:@"DistanceCalibrationCell"];
                [smartCalCell.distanceSlider setTintColor:[UIColor blueColor]];
                smartCalCell.distanceSlider.minimumValue = -25.0f;
                smartCalCell.distanceSlider.maximumValue = 25.0f;
                [smartCalCell.distanceSlider addTarget:self action:@selector(caloriesSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
                
                _caloriesCalSlider = smartCalCell.distanceSlider;
                _caloriesCalLabel = smartCalCell.distanceCalLabel;
                
                smartCalCell.shorterStridesLabel.text = SMART_CALIB_LESS_CALORIES;
                smartCalCell.longerStridesLabel.text = SMART_CALIB_MORE_CALORIES;
                
                if (self.calibrationData.calib_calo) {
                    smartCalCell.distanceCalLabel.text = [NSString stringWithFormat:@"%d%%", self.calibrationData.calib_calo];
                    smartCalCell.distanceSlider.value = self.calibrationData.calib_calo;
                    [smartCalCell.distanceSlider setNeedsDisplay];
                }
                else {
                    smartCalCell.distanceCalLabel.text = [NSString stringWithFormat:@"%d%%", 0];
                    smartCalCell.distanceSlider.value = 0;
                    [smartCalCell.distanceSlider setNeedsDisplay];
                }
            }
            break;
        default:
            smartCalCell = [tableView dequeueReusableCellWithIdentifier:@"AutoELCalibrationCell"];
            smartCalCell.autoElSwitch.on = self.calibrationData.autoEL;
            
            _autoElSwitch = smartCalCell.autoElSwitch;
            
            [smartCalCell.autoElSwitch addTarget:self action:@selector(autoElSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            break;
    }
    
    smartCalCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return smartCalCell;
}

/*- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    //avoid inserting cells after last section
    return [UITableViewCell new];
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        StepsCalibration stepsCalibration;
        
        if (indexPath.row == 0) {
            stepsCalibration = StepsCalibrationDefault;
        } else if (indexPath.row == 1) {
            stepsCalibration = StepsCalibrationOptionA;
        } else if (indexPath.row == 2) {
            stepsCalibration = StepsCalibrationOptionB;
        } else {
            stepsCalibration = StepsCalibrationOff;
        }
        
        self.calibrationData.calib_step = stepsCalibration;
        DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
        [CalibrationDataEntity calibrationDataWithCalibrationData:self.calibrationData forDeviceEntity:deviceEntity];
        [SFAUserDefaultsManager sharedManager].calibrationData = self.calibrationData;
        
//        [self.userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.calibrationData] forKey:CALIBRATION_DATA];
//        [self.userDefaults synchronize];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

/*
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UIFont *font = [UIFont systemFontOfSize:12];
        CGRect rect = [self.stepsDescription[indexPath.row] boundingRectWithSize:CGSizeMake(260, 200)
                                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                      attributes:@{ NSFontAttributeName : font}
                                                                         context:nil];
        return 40 + rect.size.height;
    } else if (indexPath.section == 1) {
        return 115;
    } else if (indexPath.section == 2) {
        return (self.watchModel == WatchModel_R450 || self.watchModel == WatchModel_R500) ? 115 : 80;
    } else {
        return 80;
    }
    
    return 0;
}
 */

/*- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2)
        return 0;
    return 60;
}*/

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerView;
//    
//    return headerView;
//}

#pragma mark - Private Methods

- (void)stepsCalibrationSet:(id)sender
{
    UIButton *button = (UIButton *)sender;
    StepsCalibration stepsCalibration;
    
    if ([button.titleLabel.text isEqualToString:LS_DEFAULT_TITLE]) {
        stepsCalibration = StepsCalibrationDefault;
    }
    else if ([button.titleLabel.text isEqualToString:SMART_CALIB_OPTION_A]) {
        stepsCalibration = StepsCalibrationOptionA;
    }
    else if ([button.titleLabel.text isEqualToString:SMART_CALIB_OPTION_B]) {
        stepsCalibration = StepsCalibrationOptionB;
    }
    else {
        stepsCalibration = StepsCalibrationOff;
    }
    
    self.calibrationData.calib_step = stepsCalibration;
    
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
    [CalibrationDataEntity calibrationDataWithCalibrationData:self.calibrationData forDeviceEntity:deviceEntity];
    
//    [self.userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.calibrationData] forKey:CALIBRATION_DATA];
//    [self.userDefaults synchronize];
    [SFAUserDefaultsManager sharedManager].calibrationData = self.calibrationData;
    
    [self.tableView reloadData];
}

- (void)distanceSliderValueChanged:(UISlider *)sender
{
    if (sender == _distanceCalSlider) {
//        int sliderValue = sender.value;
//        int stepSize = 5;
//        _distanceCalSlider.value = sliderValue - sliderValue % stepSize;
        _distanceCalSlider.value = sender.value;
        
        [_distanceCalSlider setNeedsDisplay];
        _distanceCalLabel.text = [NSString stringWithFormat:@"%d%%", [[NSNumber numberWithFloat:_distanceCalSlider.value] intValue]];
        [_distanceCalLabel setNeedsDisplay];
        
        self.calibrationData.calib_walk = _distanceCalSlider.value;
        [self showCancelAndSave];
        [self.tableView reloadData];
    }
}

- (void)caloriesSliderValueChanged:(UISlider *)sender
{
    if    (sender == _caloriesCalSlider) {
        _caloriesCalSlider.value = sender.value;
        
        [_caloriesCalSlider setNeedsDisplay];
        _caloriesCalLabel.text = [NSString stringWithFormat:@"%d%%", [[NSNumber numberWithFloat:_caloriesCalSlider.value] intValue]];
        [_caloriesCalLabel setNeedsDisplay];
        
        self.calibrationData.calib_calo =  _caloriesCalSlider.value;
        
        [self showCancelAndSave];
        [self.tableView reloadData];

    }
}

- (void)autoElSwitchChanged:(UISwitch *)sender
{
    UISwitch *autoElSwitch = sender;
    
    self.calibrationData.autoEL = autoElSwitch.on;
    
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
    [CalibrationDataEntity calibrationDataWithCalibrationData:self.calibrationData forDeviceEntity:deviceEntity];
    
//    [self.userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.calibrationData] forKey:CALIBRATION_DATA];
//    [self.userDefaults synchronize];
    
    [SFAUserDefaultsManager sharedManager].calibrationData = self.calibrationData;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Getters

- (NSArray *)stepsDescription
{
    if (!_stepsDescription) {
        _stepsDescription = @[SMART_CALIB_DEFAULT,
                              SMART_CALIB_A,
                              SMART_CALIB_B];
    }
    
    return _stepsDescription;
}

#pragma mark - SFASmartCalibrationTableViewCellDelegate

- (void)cellButtonClicked:(UIButton *)sender andCellTitle:(NSString *)cellTitle{
    StepsCalibration stepsCalibration;
    
    if ([cellTitle isEqualToString:LS_DEFAULT_TITLE]) {
        stepsCalibration = StepsCalibrationDefault;
    }
    else if ([cellTitle isEqualToString:SMART_CALIB_OPTION_A]) {
        stepsCalibration = StepsCalibrationOptionA;
    }
    else if ([cellTitle isEqualToString:SMART_CALIB_OPTION_B]) {
        stepsCalibration = StepsCalibrationOptionB;
    }
    else {
        stepsCalibration = StepsCalibrationOff;
    }
    
    self.calibrationData.calib_step = stepsCalibration;
    
    [self showCancelAndSave];
    [self.tableView reloadData];
}

- (void)saveChanges{
     DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
     [CalibrationDataEntity calibrationDataWithCalibrationData:self.calibrationData forDeviceEntity:deviceEntity];
     
     //    [self.userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self.calibrationData] forKey:CALIBRATION_DATA];
     //    [self.userDefaults synchronize];
     [SFAUserDefaultsManager sharedManager].calibrationData = self.calibrationData;
    [self hideCancelAndSave];
    [self.tableView reloadData];
}


- (void)showCancelAndSave{
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChanges)];//[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    //self.saveButton.hidden = NO;
    UIBarButtonItem *newBackButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveChanges)];//[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.rightBarButtonItem = newBackButton2;
    
}

- (void)hideCancelAndSave{
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    //[newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    /*UIBarButtonItem *newBackButton2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SyncNavigation"] style:UIBarButtonItemStyleBordered target:self action:@selector(syncButtonPressed:)];
     [newBackButton2 setImageInsets:UIEdgeInsetsMake(0, -15, 0, 15)];
     */
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)cancelChanges{
    DeviceEntity *deviceEntity = [DeviceEntity deviceEntityForMacAddress:[[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]];
    self.calibrationData = [CalibrationData calibrationDataWithCalibrationDataEntity:deviceEntity.calibrationData];
    [self hideCancelAndSave];
    [self.tableView reloadData];
}

- (void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
