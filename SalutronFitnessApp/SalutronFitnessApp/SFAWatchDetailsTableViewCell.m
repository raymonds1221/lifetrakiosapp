//
//  SFAWatchDetailsTableViewCell.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 6/4/15.
//  Copyright (c) 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAWatchDetailsTableViewCell.h"

@implementation SFAWatchDetailsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithDeviceID:(NSObject *)deviceID{
    self.deviceID = deviceID;
    self.watchModel.text = [self getWatchModelOfDeviceWithID:deviceID];
    self.watchImage.image = [self getWatchImageOfDeviceWithID:deviceID];
    NSArray *features = [self getWatchFeaturesOfDeviceWithID:deviceID];
    NSArray *featuresImages = [self getFeatureImagesOfDeviceWithID:deviceID];
    self.featureImage1 = featuresImages[0];
    self.featureImage2 = featuresImages[1];
    self.featureImage3 = featuresImages[2];
    self.featureImage4 = featuresImages[3];
    self.featureImage5 = featuresImages[4];
    self.featureImage6 = featuresImages[5];
    self.featureImage7 = featuresImages[6];
    
    self.featureLabel1 = features[0];
    self.featureLabel2 = features[1];
    self.featureLabel3 = features[2];
    self.featureLabel4 = features[3];
    self.featureLabel5 = features[4];
    self.featureLabel6 = features[5];
    self.featureLabel7 = features[6];
}

#pragma mark - Device Details

- (UIImage *)getWatchImageOfDeviceWithID:(NSObject *)deviceID{
    NSString *deviceIDString = [NSString stringWithFormat:@"%@", deviceID];
    if ([deviceIDString isEqual:WatchModel_C300_DeviceId]){
        return [UIImage imageNamed:WATCHIMAGE_C300];
    }
    else if ([deviceIDString isEqual:WatchModel_C410_DeviceId]){
        return [UIImage imageNamed:WATCHIMAGE_C410];
    }
    else if ([deviceIDString isEqual:WatchModel_R420_DeviceId]){
        return [UIImage imageNamed:WATCHIMAGE_R420];
    }
    else if ([deviceIDString isEqual:WatchModel_R450_DeviceId]){
        return [UIImage imageNamed:WATCHIMAGE_R450];
    }
    else{
        return [UIImage imageNamed:WATCHIMAGE_R500];
    }
    
}

- (NSString *)getWatchModelOfDeviceWithID:(NSObject *)deviceID{
    NSString *deviceIDString = [NSString stringWithFormat:@"%@", deviceID];
    if ([deviceIDString isEqualToString:WatchModel_C300_DeviceId]) {
        return WATCHNAME_MOVE;
    }
    else if ([deviceIDString isEqualToString:WatchModel_C410_DeviceId]){
        return WATCHNAME_ZONE;
    }
    else if ([deviceIDString isEqualToString:WatchModel_R420_DeviceId]){
        return WATCHNAME_R420;
    }
    else if ([deviceIDString isEqualToString:WatchModel_R450_DeviceId]){
        return WATCHNAME_BRITE_R450;
    }
    else{
        return WATCHNAME_DEFAULT;
    }
}

- (NSArray *)getWatchFeaturesOfDeviceWithID:(NSObject *)deviceID{
    NSArray *watchFeaturesArray = [[NSArray alloc] init];
    NSString *deviceIDString = [NSString stringWithFormat:@"%@", deviceID];
    if ([deviceIDString isEqualToString:WatchModel_C300_DeviceId]) {
        watchFeaturesArray = @[FEATURE_ECG_HR,
                               FEATURE_APP_CONNECTED,
                               FEATURE_PRECISE_TRACKING,
                               FEATURE_ALWAYS_ON,
                               FEATURE_BATTERY_WATER,
                               FEATURE_COMFITBANDS,
                               @""];
    }
    else if ([deviceIDString isEqualToString:WatchModel_C410_DeviceId]){
        watchFeaturesArray = @[FEATURE_ECG_HR,
                               FEATURE_APP_CONNECTED,
                               FEATURE_SLEEPTRAK,
                               FEATURE_PRECISE_TRACKING,
                               FEATURE_ALWAYS_ON,
                               FEATURE_BATTERY_WATER,
                               FEATURE_COMFITBANDS];
    }
    else if ([deviceIDString isEqualToString:WatchModel_R420_DeviceId]){
        watchFeaturesArray = @[FEATURE_ECG_HR,
                               FEATURE_APP_CONNECTED,
                               FEATURE_SLEEPTRAK,
                               FEATURE_PRECISE_TRACKING,
                               FEATURE_ALWAYS_ON,
                               FEATURE_BATTERY_WATER,
                               FEATURE_COMFITBANDS];
    }
    else if ([deviceIDString isEqualToString:WatchModel_R450_DeviceId]){
        watchFeaturesArray = @[FEATURE_ECG_HR,
                               FEATURE_APP_CONNECTED,
                               FEATURE_SLEEPTRAK,
                               FEATURE_PRECISE_TRACKING,
                               FEATURE_ALWAYS_ON,
                               FEATURE_BATTERY_WATER,
                               FEATURE_COMFITBANDS];
    }
    else{
        watchFeaturesArray = @[FEATURE_ECG_HR,
                               FEATURE_APP_CONNECTED,
                               FEATURE_SLEEPTRAK,
                               FEATURE_PRECISE_TRACKING,
                               FEATURE_ALWAYS_ON,
                               FEATURE_BATTERY_WATER,
                               FEATURE_COMFITBANDS];
    }
    return watchFeaturesArray;
}

- (NSArray *)getFeatureImagesOfDeviceWithID:(NSObject *)deviceID{
    NSArray *featureImagesArray = [[NSArray alloc] init];
    NSString *deviceIDString = [NSString stringWithFormat:@"%@", deviceID];
    if ([deviceIDString isEqualToString:WatchModel_C300_DeviceId]) {
        featureImagesArray = @[[UIImage imageNamed:@"DashboardIconBPM.png"],
                               [UIImage imageNamed:@"ll_preloader_default.png"],
                               [UIImage imageNamed:@"DashboardWheelActiveTime.png"],
                               [UIImage imageNamed:@"DashboardWheelCheckWorkout.png"],
                               [UIImage imageNamed:@"DashboardWheelLightFull.png"],
                               [UIImage imageNamed:@"DashboardWheelBPMLight.png"],
                               [UIImage new]];
    }
    else if ([deviceIDString isEqualToString:WatchModel_C410_DeviceId]){
        featureImagesArray = @[[UIImage imageNamed:@"DashboardIconBPM.png"],
                               [UIImage imageNamed:@"ll_preloader_default.png"],
                               [UIImage imageNamed:@"DashboardIconSleep.png"],
                               [UIImage imageNamed:@"DashboardWheelActiveTime.png"],
                               [UIImage imageNamed:@"DashboardWheelCheckWorkout.png"],
                               [UIImage imageNamed:@"DashboardWheelLightFull.png"],
                               [UIImage imageNamed:@"DashboardWheelBPMLight.png"]];
    }
    else if ([deviceIDString isEqualToString:WatchModel_R420_DeviceId]){
        featureImagesArray = @[[UIImage imageNamed:@"DashboardIconBPM.png"],
                               [UIImage imageNamed:@"ll_preloader_default.png"],
                               [UIImage imageNamed:@"DashboardIconSleep.png"],
                               [UIImage imageNamed:@"DashboardWheelActiveTime.png"],
                               [UIImage imageNamed:@"DashboardWheelCheckWorkout.png"],
                               [UIImage imageNamed:@"DashboardWheelLightFull.png"],
                               [UIImage imageNamed:@"DashboardWheelBPMLight.png"]];
    }
    else if ([deviceIDString isEqualToString:WatchModel_R450_DeviceId]){
        featureImagesArray = @[[UIImage imageNamed:@"DashboardIconBPM.png"],
                               [UIImage imageNamed:@"ll_preloader_default.png"],
                               [UIImage imageNamed:@"DashboardIconSleep.png"],
                               [UIImage imageNamed:@"DashboardWheelActiveTime.png"],
                               [UIImage imageNamed:@"DashboardWheelCheckWorkout.png"],
                               [UIImage imageNamed:@"DashboardWheelLightFull.png"],
                               [UIImage imageNamed:@"DashboardWheelBPMLight.png"]];
    }
    else{
        featureImagesArray = @[[UIImage imageNamed:@"DashboardIconBPM.png"],
                               [UIImage imageNamed:@"ll_preloader_default.png"],
                               [UIImage imageNamed:@"DashboardIconSleep.png"],
                               [UIImage imageNamed:@"DashboardWheelActiveTime.png"],
                               [UIImage imageNamed:@"DashboardWheelCheckWorkout.png"],
                               [UIImage imageNamed:@"DashboardWheelLightFull.png"],
                               [UIImage imageNamed:@"DashboardWheelBPMLight.png"]];
    }
    return featureImagesArray;
}



@end
