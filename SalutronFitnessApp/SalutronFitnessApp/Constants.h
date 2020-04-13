//
//  Constants.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/12/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#ifndef SalutronFitnessApp_Constants_h
#define SalutronFitnessApp_Constants_h

#define TEST_LIGHT 2// Change threshold for testing only, set to 0 when releasing new build (lower values)

#define RELEASE 0   // 0 - Testing with SDK Logs
                    // 1 - Testing without SDK logs / For Internal Release
                    // 2 - For Appstore Releases

#define WALGREENS 1

#if RELEASE == 0

    #define HIDE_SDK_LOGS 0
    #define API_URL_PROD 0

#elif RELEASE == 1

    #define HIDE_SDK_LOGS 1
    #define API_URL_PROD 0

#else

    #define HIDE_SDK_LOGS 1
    #define API_URL_PROD 1

#endif

#define R450_SUPPORTED      1
#define R500_SUPPORTED      0


#if API_URL_PROD == 1
    #define API_LIFETRAK_URL                        /*@"my.lifetrakusa.com"*/@"api.lifetrakusa.com"

#else
    #define API_LIFETRAK_URL                        @"staging.lifetrakusa.com"
#endif

//#define FLURRY_API_KEY @"PTJ348WBWQYMN7YYP6WX"
#define FLURRY_API_KEY  @"74Z25K7FNXKSKZKPPTHZ"

#define APPTENTIVE_API_KEY  @"6776f0fcdc14f2b28beb311d98f09037c55993 511d73ca38e67908aae81ea0e3"

#define CRASHLYTICS_API_KEY @"1698dff5a7428ef48093f6f3b3778c7db6331c19"


#define CLIENT_ID @"WzXdfbBrMtC10MAVouC3rqy8cA0NNPSycAvpBElF"
#define CLIENT_SECRET @"PRqOLPMb60MCxLeRuJRlROpwKGGdYQGoKzNWUIsD"

#define LOGIN_URL [NSString stringWithFormat:@"https://%@/api/v1/user/login", API_LIFETRAK_URL]
#define REGISTER_URL [NSString stringWithFormat:@"https://%@/api/v1/user/register", API_LIFETRAK_URL]
#define SYNC_URL [NSString stringWithFormat:@"https://%@/api/v1/user/sync/send", API_LIFETRAK_URL]
#define STORE_URL [NSString stringWithFormat:@"https://%@/api/v1/user/sync/store", API_LIFETRAK_URL]

#define SYNC_URL_V2 [NSString stringWithFormat:@"https://%@/api/v1/user/sync/send", API_LIFETRAK_URL]
#define STORE_URL_V2 [NSString stringWithFormat:@"https://%@/api/v1/user/sync/store", API_LIFETRAK_URL]

//#define LOGIN_URL @"https://ec2-54-187-59-106.us-west-2.compute.amazonaws.com/api/v1/user/login" /*@"http://172.16.3.70/user/login"*/
//#define REGISTER_URL @"https://ec2-54-187-59-106.us-west-2.compute.amazonaws.com/api/v1/user/register" /*@"http://172.16.3.70/user/register"*/
//#define SYNC_URL @"https://ec2-54-187-59-106.us-west-2.compute.amazonaws.com/api/v1/sync/send"
//#define STORE_URL @"https://ec2-54-187-59-106.us-west-2.compute.amazonaws.com/api/v1/sync/store"

#define ACCESS_TOKEN @"accessToken"
#define REFRESH_TOKEN @"refreshToken"
#define EMAIL @"email"
#define PASSWORD @"password"
#define REGISTER @"didRegister"
#define EXPIRY_DATE @"expires"

#define S3_BUCKET_NAME_STORE   @"lifetrak-bulk-data2"
#define S3_BUCKET_NAME_RESTORE @"lifetrak-restore-data"

#define DEVICE_NAME         @"device_name"
#define DEVICE_UUID         @"device_id"
#define MAC_ADDRESS         @"mac_address"
#define USER_PROFILE        @"user_profile"
#define TIME_DATE           @"time_date"
#define HAS_PAIRED          @"has_paired"
#define AUTO_SYNC_OPTION    @"auto_sync_option"
#define AUTO_SYNC_ALERT     @"auto_sync_alert"
#define AUTO_SYNC_TIME      @"auto_sync_time"
#define BLUETOOTH_ON        @"bluetooth_on"
#define CURRENT_SYNC_DATE   @"current_sync_date"
#define LAST_SYNC_DATE      @"last_sync_date"
#define LAST_LOGIN_DATE     @"last_login_date"
#define LAST_MAC_ADDRESS    @"last_mac_address"
#define NOTIFICATION        @"notification"
#define NOTIFICATION_STATUS @"notif_status"
#define SELECTED_DATE       @"selectedDate"
#define FIRMWARE_REVISION   @"firmwareRevision"
#define SOFTWARE_REVISION   @"softwareRevision"
#define ENABLE_CLOUD_SYNC   @"enableSyncToCloud"
#define SIGNUP_MACADDRESS   @"signUpMacAddress"
#define WATCH_FACE          @"watch_face"
#define WORKOUT_SETTING     @"workout_setting"

#define STEPS_CALIBRATION @"steps_calibration"
#define DISTANCE_CALIBRATION @"distance_calibration"

#define USER_ENTITY                     @"UserEntity"
#define DEVICE_ENTITY                   @"DeviceEntity"
#define STATISTICAL_DATA_HEADER_ENTITY  @"StatisticalDataHeaderEntity"
#define STATISTICAL_DATA_POINT_ENTITY   @"StatisticalDataPointEntity"
#define LIGHT_DATA_POINT_ENTITY         @"LightDataPointEntity"
#define TIME_ENTITY                     @"TimeEntity"
#define TIMING_ENTITY                   @"TimingEntity"
#define DATE_ENTITY                     @"DateEntity"
#define WORKOUT_INFO_ENTITY             @"WorkoutInfoEntity"
#define WORKOUT_HEADER_ENTITY           @"WorkoutHeaderEntity"
#define SLEEP_DATABASE_ENTITY           @"SleepDatabaseEntity"
#define GOALS_ENTITY                    @"GoalsEntity"
#define NOTE_ENTITY                     @"NoteEntity"
#define WAKEUP_ENTITY                   @"WakeupEntity"
#define WORKOUT_STOP_DATABASE_ENTITY    @"WorkoutStopDatabaseEntity"
#define USER_PROFILE_ENTITY             @"UserProfileEntity"
#define TIME_DATE_ENTITY                @"TimeDateEntity"
#define NOTIFICATION_ENTITY             @"NotificationEntity"
#define SLEEP_SETTING_ENTITY            @"SleepSettingEntity"
#define CALIBRATION_DATA_ENTITY         @"CalibrationDataEntity"
#define INACTIVE_ALERT_ENTITY           @"InactiveAlertEntity"
#define DAY_LIGHT_ALERT_ENTITY          @"DayLightAlertEntity"
#define NIGHT_LIGHT_ALERT_ENTITY        @"NightLightAlertEntity"
#define WORKOUT_HEADER_ENTITY           @"WorkoutHeaderEntity"
#define WORKOUT_RECORD_ENTITY           @"WorkoutRecordEntity"
#define WORKOUT_SETTING_ENTITY          @"WorkoutSettingEntity"
#define WORKOUT_HEART_RATE_DATA_ENTITY  @"WorkoutHeartRateDataEntity"

#define STEP_GOAL                       @"step_goal"
#define DISTANCE_GOAL                   @"distance_goal"
#define CALORIE_GOAL                    @"calorie_goal"
#define SLEEP_GOAL                      @"sleep_goal"
#define SLEEP_SETTING                   @"sleep_setting"
#define CALIBRATION_DATA                @"calibration_data"
#define WORKOUT_DATABASE                @"workout_database"
#define CONNECTED_WATCH_MODEL           @"connected_watch_model"
#define WAKEUP_KEY                      @"wakeup_key"
#define SYNC_OPTION                     @"sync_option"
#define INACTIVE_ALERT                  @"inactive_alert"
#define DAY_LIGHT_ALERT                 @"day_light_alert"
#define NIGHT_LIGHT_ALERT               @"night_light_alert"

#define PROMPT_CHANGE_SETTINGS          @"prompt_change_settings"
#define UPDATE_SETTINGS                 @"update_settings"
#define DATE_YEAR_ADDER 1900
#define DAY_SECONDS 60 * 60 * 24

#define PERIODIC_INTERVAL               @"periodic_interval"
#define SCAN_TIME                       @"scan_time"
#define LIMIT_TIME                      @"limit_time"
#define TIMING                          @"timing"
#define SMART_FOR_SLEEP                 @"smart_for_sleep"
#define SMART_FOR_WRIST                 @"smart_for_wrist"

#define NOTIFY_SIMPLE_ALERT 0
#define NOTIFY_EMAIL 1
#define NOTIFY_NEWS 2
#define NOTIFY_IN_CALL 3
#define NOTIFY_MISS_CALL 4
#define NOTIFY_SMS_MMS 5
#define NOTIFY_VOICE_MAIL 6
#define NOTIFY_SCHEDULE 7
#define NOTIFY_HIGH_PRIO 8
#define NOTIFY_SOCIAL 9

#define PROFILE_MAX_WEIGHT      440
#define PROFILE_MIN_WEIGHT      44
#define PROFILE_MAX_KG_WEIGHT   [[NSString stringWithFormat:@"%.0f", ceilf(PROFILE_MAX_WEIGHT / 2.2)] integerValue]
#define PROFILE_MIN_KG_WEIGHT   [[NSString stringWithFormat:@"%.0f", ceilf(PROFILE_MIN_WEIGHT / 2.2)] integerValue]

#define PROFILE_MAX_HEIGHT 220
#define PROFILE_MIN_HEIGHT 100

#define GRAPH_PORTRAIT_HORIZONTAL_MARGIN 0.0f

#define TEXTCOLOR   [UIColor colorWithRed:64.0/255.0 green:59.0/255.0 blue:54.0/255.0 alpha:1]

#define WEB_VIEW_USER_AGENT     @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36"

#define WALGREENS_SOURCE_APPLICATION            @"com.lifetrak.walgreens"
#define WALGREENS_CONNECT_SUCCESS               @"success"
#define WALGREENS_CONNECT_FAILED                @"failed"
#define NOTIFICATION_WALGREENS_CONNECT_SUCCESS  @"walgreensConnectSuccess"
#define NOTIFICATION_WALGREENS_CONNECT_FAILED   @"walgreensConnectFailed"

//static NSString * const AutoRotateNotificationName = @"AutoRotateNotificationName";


typedef NS_ENUM (NSInteger, SFALightColor) {
    SFALightColorAll = 0,
    SFALightColorBlue,
    SFALightColorRed,
    SFALightColorGreen,
    SFALightcolorWristOff
};

typedef NS_ENUM (NSInteger, SFALightPlotBarColor) {
    SFALightPlotBarColorAllLight,
    SFALightPlotBarColorBlueLight,
    SFALightPlotBarColorRedLight,
    SFALightPlotBarColorGreenLight,
    SFALightPlotBarColorGray
};

typedef NS_ENUM (NSInteger, SFAAllLightDailyThreshold) {
    SFAAllLightDailyThresholdLow = 350,
    SFAAllLightDailyThresholdMed = 1000,
    SFAAllLightDailyThresholdHigh = 2000
};

typedef NS_ENUM (NSInteger, SFABlueLightDailyThreshold) {
    SFABlueLightDailyThresholdLow = 30,
    SFABlueLightDailyThresholdMed = 100,
    SFABlueLightDailyThresholdHigh = 200
};

#if TEST_LIGHT == 1

typedef NS_ENUM (NSInteger, SFAAllLightThreshold) {
    SFAAllLightThreshold_01 = 20,
    SFAAllLightThreshold_02 = 100,
    SFAAllLightThreshold_03 = 200,
    SFAAllLightThreshold_04 = 300,
    SFAAllLightThreshold_05 = 400
};

typedef NS_ENUM (NSInteger, SFABlueLightThreshold) {
    SFABlueLightThreshold_01 = 10,
    SFABlueLightThreshold_02 = 20,
    SFABlueLightThreshold_03 = 30,
    SFABlueLightThreshold_04 = 40,
    SFABlueLightThreshold_05 = 50
};

#else 

typedef NS_ENUM (NSInteger, SFAAllLightThreshold) {
    SFAAllLightThreshold_01 = 10,
    SFAAllLightThreshold_02 = 4000,
    SFAAllLightThreshold_03 = 6000,
    SFAAllLightThreshold_04 = 8000,
    SFAAllLightThreshold_05 = 10000
};

typedef NS_ENUM (NSInteger, SFABlueLightThreshold) {
    SFABlueLightThreshold_01 = 3,
    SFABlueLightThreshold_02 = 800,
    SFABlueLightThreshold_03 = 1200,
    SFABlueLightThreshold_04 = 1600,
    SFABlueLightThreshold_05 = 2000
};

#endif

typedef NS_ENUM (NSInteger, SERVER_ERROR) {
    BadRequest = 400,
    Unauthorized = 401,
    NotFound = 404,
    InternalServerError = 500
};

typedef NS_ENUM (NSInteger, SyncSetupOption) {
    SyncSetupOptionOff,
    SyncSetupOptionOnce,
    SyncSetupOptionTwice,
    SyncSetupOptionFourTimes,
    SyncSetupOptionOnceAWeek
};

typedef NS_ENUM (NSInteger, SFAGraphType) {
    SFAGraphTypeCalories,
    SFAGraphTypeHeartRate,
    SFAGraphTypeSteps,
    SFAGraphTypeDistance
};

typedef NS_ENUM (NSInteger, StepsCalibration) {
    StepsCalibrationDefault = 0,
    StepsCalibrationOptionA = 1,
    StepsCalibrationOptionB = 2,
    StepsCalibrationOff
};

typedef NS_ENUM (NSInteger, SFADateRange) {
    SFADateRangeDay,
    SFADateRangeWeek,
    SFADateRangeMonth,
    SFADateRangeYear
};

typedef NS_ENUM (NSInteger, BarPlotType) {
    CALORIE_PLOT = 0,
    HEARTRATE_PLOT = 1,
    STEPS_PLOT = 2,
    DISTANCE_PLOT = 3
};

// Colors
#define CALORIES_LINE_COLOR                 [UIColor colorWithRed:226/255.0f green:136/255.0f blue:35/255.0f alpha:1.0f]
#define HEART_RATE_LINE_COLOR               [UIColor colorWithRed:190/255.0f green:73/255.0f blue:67/255.0f alpha:1.0f]
#define STEPS_LINE_COLOR                    [UIColor colorWithRed:31/255.0f green:178/255.0f blue:103/255.0f alpha:1.0f]
#define DISTANCE_LINE_COLOR                 [UIColor colorWithRed:38/255.0f green:130/255.0f blue:200/255.0f alpha:1.0f]
#define SLEEP_LINE_COLOR                    [UIColor colorWithRed:38/255.0f green:130/255.0f blue:200/255.0f alpha:1.0f]
#define LIGHT_SLEEP_LINE_COLOR              [UIColor colorWithRed:217/255.0f green:189/255.0f blue:55/255.0f alpha:1]
#define MEDIUM_SLEEP_LINE_COLOR             [UIColor colorWithRed:31/255.0f green:178/255.0f blue:103/255.0f alpha:1.0f]
#define DEEP_SLEEP_LINE_COLOR               [UIColor colorWithRed:38/255.0f green:130/255.0f blue:200/255.0f alpha:1.0f]
#define WORKOUT_LINE_COLOR                  [UIColor colorWithRed:190/255.0f green:73/255.0f blue:67/255.0f alpha:1.0f]
#define ACTIVE_LINE_COLOR                   [UIColor colorWithRed:168/255.0f green:101/255.0f blue:26/255.0f alpha:1.0f]
#define SEDENTARY_LINE_COLOR                [UIColor colorWithRed:226/255.0f green:136/255.0f blue:35/255.0f alpha:1.0f]

#define GOALS_STEPS_LINE_COLOR              [UIColor colorWithRed:255/255.0f green:193/255.0f blue:55/255.0f alpha:1.0f]
#define GOALS_DISTANCE_LINE_COLOR           [UIColor colorWithRed:0/255.0f green:209/255.0f blue:98/255.0f alpha:1.0f]
#define GOALS_CALORIES_LINE_COLOR           [UIColor colorWithRed:255/255.0f green:64/255.0f blue:44/255.0f alpha:1.0f]
#define GOALS_SLEEP_LINE_COLOR              [UIColor colorWithRed:23/255.0f green:134/255.0f blue:189/255.0f alpha:1.0f]
#define GOALS_LIGHT_LINE_COLOR              [UIColor colorWithRed:0/255.0f green:179/255.0f blue:204/255.0f alpha:1.0f]



#define ALL_LIGHT_LINE_COLOR                [UIColor colorWithRed:249/255.0f green:145/255.0f blue:37/255.0f alpha:1.0f]
#define ALL_LIGHT_ARTIFICIAL_LINE_COLOR     [UIColor colorWithRed:253/255.0f green:195/255.0f blue:128/255.0f alpha:1.0f]

#define ALL_LIGHT_LINE_COLOR_01             [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f]
#define ALL_LIGHT_LINE_COLOR_02             [UIColor colorWithRed:118.0f/255.0f green:64.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
#define ALL_LIGHT_LINE_COLOR_03             [UIColor colorWithRed:177.0f/255.0f green:96.0f/255.0f blue:0.0f/255.0f alpha:1.0f]
#define ALL_LIGHT_LINE_COLOR_04             [UIColor colorWithRed:227.0f/255.0f green:148.0f/255.0f blue:31.0f/255.0f alpha:1.0f]
#define ALL_LIGHT_LINE_COLOR_05             [UIColor colorWithRed:242.0f/255.0f green:178.0f/255.0f blue:93.0f/255.0f alpha:1.0f]
#define ALL_LIGHT_LINE_COLOR_06             [UIColor colorWithRed:247.0f/255.0f green:204.0f/255.0f blue:149.0f/255.0f alpha:1.0f]

#define BLUE_LIGHT_LINE_COLOR               [UIColor colorWithRed:51/255.0f green:118/255.0f blue:191/255.0f alpha:1.0f]
#define BLUE_LIGHT_ARTIFICIAL_LINE_COLOR    [UIColor colorWithRed:112/255.0f green:189/255.0f blue:255/255.0f alpha:1.0f]

#define BLUE_LIGHT_LINE_COLOR_01            [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f]
#define BLUE_LIGHT_LINE_COLOR_02            [UIColor colorWithRed:12.0f/255.0f green:54.0f/255.0f blue:102.0f/255.0f alpha:1.0f]
#define BLUE_LIGHT_LINE_COLOR_03            [UIColor colorWithRed:19.0f/255.0f green:80.0f/255.0f blue:153.0f/255.0f alpha:1.0f]
#define BLUE_LIGHT_LINE_COLOR_04            [UIColor colorWithRed:66.0f/255.0f green:131.0f/255.0f blue:204.0f/255.0f alpha:1.0f]
#define BLUE_LIGHT_LINE_COLOR_05            [UIColor colorWithRed:114.0f/255.0f green:167.0f/255.0f blue:225.0f/255.0f alpha:1.0f]
#define BLUE_LIGHT_LINE_COLOR_06            [UIColor colorWithRed:160.0f/255.0f green:196.0f/255.0f blue:235.0f/255.0f alpha:1.0f]

/*
#define PERCENT_0_COLOR         [UIColor colorWithRed:217/255.0f green:189/255.0f blue:55/255.0f alpha:1]
#define PERCENT_25_COLOR        [UIColor colorWithRed:229/255.0f green:210/255.0f blue:80/255.0f alpha:1]
#define PERCENT_50_COLOR        [UIColor colorWithRed:144/255.0f green:204/255.0f blue:41/255.0f alpha:1]
#define PERCENT_75_COLOR        [UIColor colorWithRed:104/255.0f green:196/255.0f blue:89/255.0f alpha:1]
#define PERCENT_100_COLOR       [UIColor colorWithRed:31/255.0f green:178/255.0f blue:103/255.0f alpha:1]
*/

#define PERCENT_0_COLOR         [UIColor lightGrayColor]
#define PERCENT_25_COLOR        [UIColor colorWithRed:217/255.0f green:189/255.0f blue:55/255.0f alpha:1]
#define PERCENT_50_COLOR        [UIColor colorWithRed:229/255.0f green:210/255.0f blue:80/255.0f alpha:1]
#define PERCENT_75_COLOR        [UIColor colorWithRed:144/255.0f green:204/255.0f blue:41/255.0f alpha:1]
#define PERCENT_100_COLOR       [UIColor colorWithRed:31/255.0f green:178/255.0f blue:103/255.0f alpha:1]
#define PERCENT_COMPLETE_COLOR  [UIColor colorWithRed:42/255.0f green:167/255.0f blue:84/255.0f alpha:1]


#define LIFETRAK_COLOR          [UIColor colorWithRed:31/255.0f green:178/255.0f blue:103/255.0f alpha:1]
#define LIFETRAK_COLOR_INACTIVE [UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1]


// View Controller Color Macros

#define CELL_BACKGROUND_COLOR           [UIColor colorWithRed:41/255.0f green:42/255.0f blue:45/255.0f alpha:1]
#define SELECTED_CELL_BACKGROUND_COLOR  [UIColor colorWithRed:35/255.0f green:36/255.0f blue:39/255.0f alpha:1]

#define HOURS_IN_DAY_COUNT      24
#define DAYS_IN_WEEK_COUNT      7
#define MONTHS_IN_YEAR_COUNT    12

#define BPM_MAX_Y_VALUE         240
#define DAY_DATA_MAX_COUNT      144
#define WEEK_DATA_MAX_COUNT     84
#define YEAR_ACT_DATA_MAX_COUNT 365
#define YEAR_DATA_MAX_COUNT     12

#define DAY_DATA_BAR_WIDTH      16.0f
#define WEEK_DATA_BAR_WIDTH     16.0f
#define MONTH_DATA_BAR_WIDTH    32.0f
#define YEAR_DATA_BAR_WIDTH     32.0f

#define DAY_DATA_BAR_SPACE      8.0f
#define WEEK_DATA_BAR_SPACE     8.0f
#define MONTH_DATA_BAR_SPACE    8.0f
#define YEAR_DATA_BAR_SPACE     8.0f

#define WEEKLY_IDENTIFIER       NSLocalizedString(@"WEEKLY", nil)
#define DAILY_IDENTIFIER        NSLocalizedString(@"DAILY", nil)
#define MONTHLY_IDENTIFIER      NSLocalizedString(@"MONTHLY", nil)
#define YEARLY_IDENTIFIER       NSLocalizedString(@"YEARLY", nil)
#define DATE_RANGE_PICKER @[DAILY_IDENTIFIER, WEEKLY_IDENTIFIER, MONTHLY_IDENTIFIER, YEARLY_IDENTIFIER]

#define SYNC_BLUE_COLOR [UIColor colorWithRed:85/255.0f green:164/255.0f blue:182/255.0f alpha:1]


//Watch Names
#define WATCHNAME_MOVE_C300     @"LifeTrak Move C300 / C320"
#define WATCHNAME_ZONE_C410     @"LifeTrak Zone C410 / C410W"
#define WATCHNAME_MOVE          @"LifeTrak Move\nC300 / C320"
#define WATCHNAME_ZONE          @"LifeTrak Zone\nC410 / C410W"
#define WATCHNAME_R420          @"LifeTrak Zone R420"
#define WATCHNAME_BRITE_R450    @"LifeTrak Brite R450"

#define WATCHNAME_CORE_C200     @"LifeTrak Core C200"
#define WATCHNAME_R500          @"LifeTrak R500"
#define WATCHNAME_DEFAULT       @"LifeTrak Watch"

#define WATCHIMAGE_C410         @"C410"//@"C410W"
#define WATCHIMAGE_C300         @"C320"//@"C300"
#define WATCHIMAGE_R450         @"R450"
#define WATCHIMAGE_R420         @"R420"
#define WATCHIMAGE_C300_C320    @"C300 C320"
#define WATCHIMAGE_C410_C410W   @"C410 C410W"
#define WATCHIMAGE_R500         @"ll_watch_r500_black.png"
/**
 *  Alert View Messages
 */

// Welcome

#define WELCOME_DELETE_TITLE                NSLocalizedString(@"Delete Watch", nil)
#define WELCOME_DELETE_MESSAGE(watch_name)  [NSString stringWithFormat:@"%@ %@?", NSLocalizedString(@"Are you sure you want to delete",nil) ,watch_name]

// Intro

#define NO_DATA_ALERT_TITLE     NSLocalizedString(@"Oops!", nil)
#define NO_DATA_ALERT_MESSAGE   NSLocalizedString(@"This app needs to be paired with a compatible LifeTrak Fitness Watch in order to view your fitness results. Please set up your device in the next screen.", nil)

// Connection

#define DEVICE_SYNC_ALERT_TITLE            NSLocalizedString(@"Set up Device", nil)
#define DEVICE_SYNC_ALERT_MESSAGE(model)   [NSString stringWithFormat:NSLocalizedString(@"We will now pair this app with your %@ watch. Check that you have selected the correct LifeTrak watch model to pair with. Then press the watch lower button until you see the pairing icon on your watch display.", nil), model]

// Pulsewave

#define PULSEWAVE_SYNC_ALERT_TITLE            NSLocalizedString(@"Pulsewave", nil)
#define PULSEWAVE_SYNC_ALERT_MESSAGE   NSLocalizedString(@"We will now enable pulsewave with your R500 watch. Press your R500 watch lower button until you see the pairing icon on your watch display.", nil)

#define RETRY_SYNC_ALERT_TITLE              NSLocalizedString(@"Retry", nil)
#define RETRY_SYNC_ALERT_MESSAGE(model)     [NSString stringWithFormat:@NSLocalizedString(@"We will now pair this app with your %@ watch. Check that you have selected the correct LifeTrak watch model to pair with. Then press the watch lower button until you see the pairing icon on your watch display.", nil), model]

// Dashboard

#define UPDATE_ALERT_TITLE                          NSLocalizedString(@"Update", nil)
#define UPDATE_ALERT_MESSAGE(model, isAutoSync)     isAutoSync ? [NSString stringWithFormat:NSLocalizedString(@"We will now update the data from your LifeTrak %@.", nil), model] :[NSString stringWithFormat:NSLocalizedString(@"We will now update the data from your LifeTrak %@. Please press the lower button until you see the pairing icon on your watch display.", nil), model]

// Sync Setup

#define UNPAIR_ALERT_TITLE          NSLocalizedString(@"Disconnect", nil)
#define UNPAIR_ALERT_MESSAGE(model) [NSString stringWithFormat:@"%@ %@? %@", NSLocalizedString(@"Are you sure you want to disconnect this app from your LifeTrak", nil), model, NSLocalizedString(@"This will allow you to connect the app to another LifeTrak watch.", nil)]

// Sync Setup

#define SWITCH_ALERT_TITLE          NSLocalizedString(@"Disconnect", nil)
#define SWITCH_ALERT_MESSAGE        NSLocalizedString(@"Are you sure you want to switch to a new watch?", nil)


// Settings

#define PROFILE_UPDATE_ALERT_TITLE                      @"Settings"
#define PROFILE_UPDATE_ALERT_MESSAGE(model, isAutoSync) isAutoSync ? [NSString stringWithFormat:NSLocalizedString(@"We will now update your personal settings on your LifeTrak %@.", nil), model] :[NSString stringWithFormat:NSLocalizedString(@"We will now update your personal settings on your LifeTrak %@. Please press the lower button until you see the pairing icon on your watch display.", nil), model]

// Goals

#define GOAL_UPDATE_ALERT_TITLE                         @"Goals"
#define GOAL_UPDATE_ALERT_MESSAGE(model, isAutoSync)    isAutoSync ? [NSString stringWithFormat:NSLocalizedString(@"We will now update your goal settings on your LifeTrak %@.", nil), model] :[NSString stringWithFormat:NSLocalizedString(@"We will now update your goal settings on your LifeTrak %@. Please press the lower button until you see the pairing icon on your watch display.", nil), model]


#define SYNC_MESSAGE(message)                           [NSString stringWithFormat:NSLocalizedString(@"Syncing data with your LifeTrak watch. Status: %@", nil), message]
//#define SYNC_MESSAGE(message)                           NSLocalizedString([NSString stringWithFormat:@"Syncing data with your LifeTrak watch. Status: %@", message],@"a message when syncing to a watch with a status message")

#define SYNC_SHORT_MESSAGE(model)                       [NSString stringWithFormat:NSLocalizedString(@"Syncing data with your %@",@"a message when syncing to a watch"), model]
#define SYNC_NOT_FOUND_MESSAGE                          NSLocalizedString(@"We cannot find any LifeTrak watch",@"a message when the app can not find any device")
#define SYNC_TIMEOUT                                    NSLocalizedString(@"Syncing timed out",@"a message when the sync timed out")
#define SYNC_SUCCESS                                    NSLocalizedString(@"Sync successful!",@"a message when the sync was successful")
#define DEVICE_DISCONNECTED                             NSLocalizedString(@"Device Disconnected.",@"a message when the device is disconnected")
#define PAIR_R415                                       @"Pairing R450"

// Sync search
#define SYNC_SEARCH(model)                              [NSString stringWithFormat:NSLocalizedString(@"Searching for your %@",@"a message when searching for the model"), model]
#define BLUETOOTH_ACTIVE                                NSLocalizedString(@"Make sure Bluetooth is active on your LifeTrak device.",@"a message when searching for the model")

// Sync date
#define SYNC_DATE_TITLE                                 NSLocalizedString(@"Sync",@"an alert title")
#define SYNC_DATE_MESSAGE                               NSLocalizedString(@"Your date and time in watch not match with the current date and time. Do you want to update your watch date and time?",@"a message when there is a missmatch with times")

// Sync failed

#define SYNC_FAILED(model)                              [NSString stringWithFormat:NSLocalizedString(@"We cannot connect your LifeTrak %@ to the app. Please try to forget the bluetooth device in settings",@"a message when the sync failed"), model]

// Turn on bluetooth
#define TURN_ON_BLUETOOTH                               NSLocalizedString(@"This app works only when the Bluetooth is on. Please activate the Bluetooth in Settings.", nil)

// Walgreens
#define WALGREENS_EXPIRED_TOKEN                         @"walgreens_expired_token"

// Notification alert

#define NOTIFICATION_ALERT_TITLE                        NSLocalizedString(@"Notification", nil)
#define NOTIFICATION_ALERT_MESSAGE                      NSLocalizedString(@"You must turn on your watch bluetooth before you can continue", nil)
#define NOTIFICATION_ALERT_NOT_SAVED                    NSLocalizedString(@"Sync changes to watch?", nil)

//Set up Alert

#define SETUP_ALERT_TITLE                   NSLocalizedString(@"We can't find your LifeTrak device.", nil)
#define SETUP_ALERT_MESSAGE                 NSLocalizedString(@"1. Ensure your phone/tablet’s Bluetooth is on.\n2. Check that Bluetooth is active on your watch. If not, press and hold lower right button to activate.", nil)//NSLocalizedString(@"1. Make sure Bluetooth is turned on, on your smartphone or tablet.\n2. Check that Bluetooth is active on your LifeTrak device.  If it is not, press and hold the lower right button to turn it on (R450) or activate pairing/syncing (C300, C410).", nil)
#define SETUP_ALERT_SYNC_FAILED_MESSAGE    NSLocalizedString(@"1. Make sure Bluetooth is turned on, on your smartphone or tablet.\n2.  Make sure your device is nearby.\n3. Hold the bottom right button down to turn on Bluetooth (R450) or to begin syncing (C300, C320, C410, C410w, R420).", nil)

#define SETUP_ALERT_SYNC_TITLE2            NSLocalizedString(@"Sorry we can't complete your sync", nil)
#define SETUP_ALERT_SYNC_FAILED_MESSAGE2   NSLocalizedString(@"1. There was a problem communicating with your watch.\n\n2. Your battery level is low, try to replace the battery.", nil)


/**
 *  API Constants
 */

// Values

#define API_CLIENT_ID                           @"WzXdfbBrMtC10MAVouC3rqy8cA0NNPSycAvpBElF"
#define API_CLIENT_SECRET                       @"PRqOLPMb60MCxLeRuJRlROpwKGGdYQGoKzNWUIsD"
#define API_USER_ROLE                           @"mobile"
#define API_URL                                 @"api_url"
#define API_PARAMETERS                          @"api_parameters"
#define API_RESULT                              @"result"
#define API_DATE_TIME_FORMAT                    @"yyyy-MM-dd HH:mm:ss"
#define API_DATE_FORMAT                         @"yyyy-MM-dd"
#define API_TIME_FORMAT                         @"HH:mm:ss"
#define API_FACEBOOK_APP_ID                     @"275031536009220"
#define API_FACEBOOK_CLIENT_SECRET              @"faedf3e385ed9624bdd5de0ff6e62851"
#define API_REFRESH_TOKEN_GRANT_TYPE            @"refresh_token"

// URL
#if API_URL_PROD == 1
//#define API_BASE_URL                            @"https://my.lifetrakusa.com"
#define API_BASE_URL                            @"https://api.lifetrakusa.com"
#else 
#define API_BASE_URL                            @"http://staging.lifetrakusa.com"
#endif

//#define API_BASE_URL                            @"https://ec2-54-187-59-106.us-west-2.compute.amazonaws.com"
#define API_LOGIN_URL                           API_BASE_URL "/api/v1/user/login"
#define API_FACEBOOK_LOGIN_URL                  API_BASE_URL "/api/v1/user/facebook"
#define API_PROFILE_URL                         API_BASE_URL "/api/v1/user"
#define API_UPDATE_PROFILE_URL                  API_BASE_URL "/api/v1/user/update"
#define API_FORGOT_PASSWORD_URL                 API_BASE_URL "/api/v1/password/send"
#define API_REGISTER_URL                        API_BASE_URL "/api/v1/user/register"
#define API_SYNC_URL                            API_BASE_URL "/api/v1/sync/send"
#define API_STORE_URL                           API_BASE_URL "/api/v1/sync/store"


#define API_SYNC_URL_V2                            API_BASE_URL "/api/v2/sync/bulk"
#define API_STORE_URL_V2                           API_BASE_URL "/api/v2/sync/store"
#define API_RESTORE_URL_V2                         API_BASE_URL "/api/v2/restore"


#define API_DEVICES_URL                         API_BASE_URL "/api/v1/restore/devices"
#define API_RESTORE_URL                         API_BASE_URL "/api/v1/restore"
#define API_RESTORE_URL_V2                      API_BASE_URL "/api/v2/restore"
#define API_DELETE_DEVICE                       API_BASE_URL "/api/v1/device/delete"
#define API_WALGREENS_LOGIN_URL                 API_BASE_URL "/api/v1/walgreens/connect"
#define API_WALGREENS_DISCONNECT                API_BASE_URL "/api/v1/walgreens/disconnect"
#define API_REFRESH_ACCESS_TOKEN_URL            API_BASE_URL "/api/v1/oauth/refreshtoken"
#define API_DEVICE_DATA_URL                     API_BASE_URL "/api/v1/device" //user_uuid/mac_address
#define API_PLATFORM                            @"ios"

// OAuth
#define API_OAUTH_CLIENT_ID                     @"client_id"
#define API_OAUTH_CLIENT_SECRET                 @"client_secret"
#define API_OAUTH_EMAIL_ADDRESS                 @"email"
#define API_OAUTH_PASSWORD                      @"password"
#define API_OAUTH_ACCESS_TOKEN                  @"access_token"
#define API_OAUTH_REFRESH_TOKEN                 @"refresh_token"
#define API_OAUTH_EXPIRATION                    @"expires"

// Access Token
#define API_ACCESSTOKEN_GRANT                   @"grant_type"


//Refresh token invalid error String
#define API_ERROR_REFRESH_TOKEN_INVALID         @"The refresh token is invalid."
#define REFRESH_TOKEN_INVALID_NOTIFICATION      @"RefreshTokenInvalid"

// User
#define API_USER_FIRST_NAME                     @"first_name"
#define API_USER_LAST_NAME                      @"last_name"
#define API_USER_IMAGE_URL                      @"image"
#define API_USER_ACTIVATED                      @"activated"
#define API_USER_ID                             @"id"

// Error
#define API_ERROR_CODE                          @"error"
#define API_ERROR_MESSAGE                       @"error_description"
#define API_ERROR_UNKNOWN                       @"There is a problem while syncing your data to cloud. You may go to Feedback page to contact administrator."

// Log in
#define API_LOGIN_EMAIL_ADDRESS                 @"email"
#define API_LOGIN_PASSWORD                      @"password"

// Facebook Log in
#define API_FACEBOOK_LOGIN_FACEBOOK_TOKEN       @"facebook_token"
#define API_FACEBOOK_LOGIN_CLIENT_ID            @"client_id"
#define API_FACEBOOK_LOGIN_CLIENT_SECRET        @"client_secret"
#define API_IS_FACEBOOK_LOGIN                   @"is_facebook_login"

// Forgot Password
#define API_FORGOT_PASSWORD_EMAIL_ADDRESS       @"email"

// Register
#define API_REGISTER_EMAIL_ADDRESS              @"email"
#define API_REGISTER_PASSWORD                   @"password"
#define API_REGISTER_FIRST_NAME                 @"first_name"
#define API_REGISTER_LAST_NAME                  @"last_name"
#define API_REGISTER_ROLE                       @"role"
#define API_REGISTER_USER_IMAGE                 @"image"

// Profile
#define API_PROFILE_OLD_PASSWORD                @"old_password"

// Sync
#define API_SYNC_MAC_ADDRESS                    @"mac_address"
#define API_SYNC_RESULT                         @"result"
#define API_SYNC_DATA                           @"data"
#define API_SYNC_START_DATE						@"start_date"
#define API_SYNC_END_DATE						@"end_date"
#define API_SYNC_DEVICE                         @"device"
#define API_SYNC_WORKOUT                        @"workout"
#define API_SYNC_SLEEP                          @"sleep"
#define API_SYNC_DATA_HEADER                    @"data_header"
#define API_SYNC_DEVICE_SETTINGS                @"device_settings"
#define API_SYNC_USER_PROFILE                   @"user_profile"
#define API_SYNC_GOAL                           @"goal"
#define API_SYNC_SLEEP_SETTINGS                 @"sleep_settings"
#define API_SYNC_WAKEUP_INFO                    @"wakeup_info"
#define API_SYNC_UPDATED_AT                     @"updated_at"
#define API_SYNC_LAST_DATE_SYNCED               @"last_date_synced"
#define API_SYNC_LIGHT_DATA_POINT               @"light_datapoint"
#define API_SYNC_INACTIVE_ALERT                 @"inactive_alert_settings"
#define API_SYNC_LIGHT_SETTINGS                 @"light_settings"
#define API_SYNC_WORKOUT_HEADER                 @"workout_header"

// Device
#define API_DEVICE_UUID                         @"device_id"
#define API_DEVICE_MAC_ADDRESS                  @"mac_address"
#define API_DEVICE_MODEL_NUMBER                 @"model_number"
#define API_DEVICE_NAME                         @"device_name"
#define API_DEVICE_LAST_DATE_SYNCED             @"last_date_synced"
#define API_DEVICE_UPDATED_AT                   @"updated_at"

// Workout
#define API_WORKOUT_ID                          @"workout_id"
#define API_WORKOUT_DURATION                    @"workout_duration"
#define API_WORKOUT_START_DATE                  @"start_date_time"
#define API_WORKOUT_STEPS                       @"steps"
#define API_WORKOUT_CALORIES                    @"calories"
#define API_WORKOUT_DISTANCE                    @"distance"
#define API_WORKOUT_DISTANCE_UNIT               @"distance_unit_flag"
#define API_WORKOUT_PLATFORM                    @"platform"
#define API_WORKOUT_WORKOUT_STOP                @"workout_stop"

// Workout Stop
#define API_WORKOUT_STOP_WORKOUT_TIME           @"workout_time"
#define API_WORKOUT_STOP_STOP_TIME              @"stop_time"
#define API_WORKOUT_STOP_INDEX                  @"index"

// Workout Header
#define API_WORKOUT_HEADER_AUTO_SPLIT_THRESHOLD @"auto_split_threshold"
#define API_WORKOUT_HEADER_AUTO_SPLIT_TYPE      @"auto_split_type"
#define API_WORKOUT_HEADER_AVERAGE_BPM          @"average_bpm"
#define API_WORKOUT_HEADER_HOUR                 @"hour"
#define API_WORKOUT_HEADER_HUNDREDTHS           @"hundredths"
#define API_WORKOUT_HEADER_LOG_RATE_HR          @"log_rate_hr"
#define API_WORKOUT_HEADER_MAXIMUM_BPM          @"maximum_bpm"
#define API_WORKOUT_HEADER_MINIMUM_BPM          @"minimum_bpm"
#define API_WORKOUT_HEADER_MINUTE               @"minute"
#define API_WORKOUT_HEADER_RECORD_COUNT_HR      @"record_count_hr"
#define API_WORKOUT_HEADER_RECORD_COUNT_SPLITS  @"record_count_splits"
#define API_WORKOUT_HEADER_RECORD_COUNT_STOPS   @"record_count_stops"
#define API_WORKOUT_HEADER_RECORD_COUNT_TOTAL   @"record_count_total"
#define API_WORKOUT_HEADER_SECOND               @"second"
#define API_WORKOUT_HEADER_STAMP_DAY            @"stamp_day"
#define API_WORKOUT_HEADER_STAMP_HOUR           @"stamp_hour"
#define API_WORKOUT_HEADER_STAMP_MINUTE         @"stamp_minute"
#define API_WORKOUT_HEADER_STAMP_MONTH          @"stamp_month"
#define API_WORKOUT_HEADER_STAMP_SECOND         @"stamp_second"
#define API_WORKOUT_HEADER_STAMP_YEAR           @"stamp_year"
#define API_WORKOUT_HEADER_START_DATE_TIME      @"start_date_time"
#define API_WORKOUT_HEADER_STATUS_FLAG          @"status_flag"
#define API_WORKOUT_HEADER_USER_MAX_HR          @"user_max_hr"
#define API_WORKOUT_HEADER_ZONE0_LOWER_HR       @"zone0_lower_hr"
#define API_WORKOUT_HEADER_ZONE0_UPPER_HR       @"zone0_upper_hr"
#define API_WORKOUT_HEADER_ZONE1_LOWER_HR       @"zone1_lower_hr"
#define API_WORKOUT_HEADER_ZONE2_LOWER_HR       @"zone2_lower_hr"
#define API_WORKOUT_HEADER_ZONE3_LOWER_HR       @"zone3_lower_hr"
#define API_WORKOUT_HEADER_ZONE4_LOWER_HR       @"zone4_lower_hr"
#define API_WORKOUT_HEADER_ZONE5_LOWER_HR       @"zone5_lower_hr"
#define API_WORKOUT_HEADER_ZONE5_UPPER_HR       @"zone5_upper_hr"
#define API_WORKOUT_HEADER_ZONE_TRAIN_TYPE      @"zone_train_type"
#define API_WORKOUT_HEADER_STEPS                @"steps"
#define API_WORKOUT_HEADER_CALORIES             @"calories"
#define API_WORKOUT_HEADER_DISTANCE             @"distance"
#define API_WORKOUT_HEADER_WORKOUT_STOP         @"workout_stop"
#define API_WORKOUT_HEADER_WORKOUT_HR_DATA      @"workout_hr_data"

// Workout Heart Rate Data
#define API_WORKOUT_HEART_RATE_HR_DATA          @"hr_data"
#define API_WORKOUT_HEART_RATE_INDEX            @"index"

// Workout Settings
#define API_WORKOUT_SETTING_HR_LOG_RATE         @"hr_log_rate"
#define API_WORKOUT_SETTING_DATABASE_USAGE      @"database_usage"
#define API_WORKOUT_SETTING_DATABASE_USAGE_MAX  @"database_usage_max"
#define API_WORKOUT_SETTING_RECONNECT_TIMEOUT   @"reconnect_timeout"

// Sleep
#define API_SLEEP_START_TIME                    @"sleep_start_time"
#define API_SLEEP_END_TIME                      @"sleep_end_time"
#define API_SLEEP_OFFSET                        @"sleep_offset"
#define API_SLEEP_DEEP_SLEEP_COUNT              @"deep_sleep_count"
#define API_SLEEP_LIGHT_SLEEP_COUNT             @"light_sleep_count"
#define API_SLEEP_LAPSES                        @"lapses"
#define API_SLEEP_DURATION                      @"sleep_duration"
#define API_SLEEP_CREATED_DATE                  @"sleep_created_date"
#define API_SLEEP_EXTRA_INFO                    @"extra_info"
#define API_SLEEP_PLATFORM                      @"platform"

// Data Header
#define API_DATA_HEADER_MAX_HR                  @"max_HR"
#define API_DATA_HEADER_MIN_HR                  @"min_HR"
#define API_DATA_HEADER_ALLOCATION_BLOCK_INDEX  @"allocation_block_index"
#define API_DATA_HEADER_TOTAL_SLEEP             @"total_sleep"
#define API_DATA_HEADER_TOTAL_STEPS             @"total_steps"
#define API_DATA_HEADER_TOTAL_CALORIES          @"total_calories"
#define API_DATA_HEADER_TOTAL_DISTANCE          @"total_distance"
#define API_DATA_HEADER_TOTAL_EXPOSURE_TIME     @"total_exposure_time"
#define API_DATA_HEADER_CREATED_DATE            @"header_created_date"
#define API_DATA_HEADER_START_TIME              @"start_time"
#define API_DATA_HEADER_END_TIME                @"end_time"
#define API_DATA_HEADER_PLATFORM                @"platform"
#define API_DATA_HEADER_DATA_POINT              @"data_point"
#define API_DATA_HEADER_LIGHT_DATA_POINT        @"light_datapoint"

// Data Point
#define API_DATA_POINT_ID                       @"datapoint_id"
#define API_DATA_POINT_AVERAGE_HR               @"average_HR"
#define API_DATA_POINT_AXIS_DIRECTION           @"axis_direction"
#define API_DATA_POINT_AXIS_MAGNITUDE           @"axis_magnitude"
#define API_DATA_POINT_DOMINANT_AXIS            @"dominant_axis"
#define API_DATA_POINT_SLEEP_POINT_02           @"sleep_point_02"
#define API_DATA_POINT_SLEEP_POINT_24           @"sleep_point_24"
#define API_DATA_POINT_SLEEP_POINT_46           @"sleep_point_46"
#define API_DATA_POINT_SLEEP_POINT_68           @"sleep_point_68"
#define API_DATA_POINT_SLEEP_POINT_810          @"sleep_point_810"
#define API_DATA_POINT_STEPS                    @"steps"
#define API_DATA_POINT_CALORIES                 @"calorie"
#define API_DATA_POINT_DISTANCE                 @"distance"
#define API_DATA_POINT_LUX                      @"lux"
#define API_DATA_POINT_WRIST_DETECTION          @"wrist_detection"
#define API_DATA_POINT_BLE_STATUS               @"ble_status"

// Light Data Point
#define API_LIGHT_DATA_POINT_ID                 @"light_datapoint_id"
#define API_LIGHT_DATA_POINT_RED                @"red"
#define API_LIGHT_DATA_POINT_GREEN              @"blue"
#define API_LIGHT_DATA_POINT_BLUE               @"green"
#define API_LIGHT_DATA_POINT_INTEGRATION_TIME   @"integration_time"
#define API_LIGHT_DATA_POINT_SENSOR_GAIN        @"sensor_gain"
#define API_LIGHT_DATA_POINT_RED_LIGHT_COEFF    @"red_light_coeff"
#define API_LIGHT_DATA_POINT_GREEN_LIGHT_COEFF  @"green_light_coeff"
#define API_LIGHT_DATA_POINT_BLUE_LIGHT_COEFF   @"blue_light_coeff"

// Device Settings
#define API_DEVICE_SETTINGS_TYPE                @"type"
#define API_DEVICE_SETTINGS_CALIB_STEP          @"calib_step"
#define API_DEVICE_SETTINGS_CALIB_WALK          @"calib_walk"
#define API_DEVICE_SETTINGS_CALIB_RUN           @"calib_run"
#define API_DEVICE_SETTINGS_CALIB_CALORIES      @"calib_calories"
#define API_DEVICE_SETTINGS_AUTO_EL             @"auto_EL"
#define API_DEVICE_SETTINGS_NOTI_SIMPLE_ALERT   @"noti_simple_alert"
#define API_DEVICE_SETTINGS_NOTI_EMAIL          @"noti_email"
#define API_DEVICE_SETTINGS_NOTI_NEWS           @"noti_news"
#define API_DEVICE_SETTINGS_NOTI_INCOMING_CALL  @"noti_incoming_call"
#define API_DEVICE_SETTINGS_NOTI_MISSED_CALL    @"noti_missed_call"
#define API_DEVICE_SETTINGS_NOTI_SMS            @"noti_sms"
#define API_DEVICE_SETTINGS_NOTI_VOICE_MAIL     @"noti_voice_mail"
#define API_DEVICE_SETTINGS_NOTI_SCHEDULES      @"noti_schedules"
#define API_DEVICE_SETTINGS_NOTI_HIGH_PRIO      @"noti_high_prio"
#define API_DEVICE_SETTINGS_NOTI_SOCIAL         @"noti_social"
#define API_DEVICE_SETTINGS_NOTI_STATUS         @"notif_status"
#define API_DEVICE_SETTINGS_HOUR_FORMAT         @"hour_format"
#define API_DEVICE_SETTINGS_DATE_FORMAT         @"date_format"
#define API_DEVICE_SETTINGS_WATCH_FACE          @"watch_face"


// User Profile
#define API_USER_PROFILE_BIRTHDAY               @"birthday"
#define API_USER_PROFILE_GENDER                 @"gender"
#define API_USER_PROFILE_UNIT                   @"unit"
#define API_USER_PROFILE_SENSITIVITY            @"sensitivity"
#define API_USER_PROFILE_HEIGHT                 @"height"
#define API_USER_PROFILE_WEIGHT                 @"weight"

// Goal
#define API_GOAL_CALORIES                       @"calories"
#define API_GOAL_STEPS                          @"steps"
#define API_GOAL_DISTANCE                       @"distance"
#define API_GOAL_SLEEP                          @"sleep"
#define API_GOAL_CREATED_DATE                   @"goal_created_date_time"

// Sleep Settings
#define API_SLEEP_SETTINGS_SLEEP_GOAL_LO        @"sleep_goal_lo"
#define API_SLEEP_SETTINGS_SLEEP_GOAL_HI        @"sleep_goal_hi"
#define API_SLEEP_SETTINGS_SLEEP_MODE           @"sleep_mode"

// Wakeup Info
#define API_WAKEUP_INFO_SNOOZE_MIN              @"snooze_min"
#define API_WAKEUP_INFO_SNOOZE_MODE             @"snooze_mode"
#define API_WAKEUP_INFO_WAKEUP_TIME             @"wakeup_time"
#define API_WAKEUP_INFO_WAKEUP_MODE             @"wakeup_mode"
#define API_WAKEUP_INFO_WAKEUP_WINDOW           @"wakeup_window"
#define API_WAKEUP_INFO_WAKEUP_TYPE             @"wakeup_type"

// Walgreens
#define API_WALGREENS_CHANNEL                   @"channel"
#define API_WALGREENS_EXPIRED_TOKEN             @"Successfully stored to server but unable to sync to walgreens."

//Server
#define SERVER_ERROR_MESSAGE                    NSLocalizedString(@"Problem occured while communicating with server. Please try again.", nil)
#define SERVER_ERROR_COCOA                      @"(Cocoa error 3840.)"//@"The operation couldn't be completed. (Cocoa error 3840.)"
#define DEFAULT_SERVER_ERROR                    @"The operation couldn't be completed."//@"The operation couldn't be completed. (Cocoa error 3840.)"
#define NO_INTERNET_ERROR                       @"(NSURLErrorDomain error -1009.)"//@"The operation couldn't be completed. (NSURLErrorDomain error -1009.)"
#define NO_INTERNET_ERROR_MESSAGE               NSLocalizedString(@"The Internet connection appears to be offline.", nil)
#define SERVER_ERROR_MESSAGE_COCOA              NSLocalizedString(@"Poor network connection, please try again later.", nil)
#define SERVER_ERROR_2                          NSLocalizedString(@"A server with the specified hostname could not be found.", nil)
#define SERVER_ERROR_PARSE                      @"cannot parse response"
#define FB_USER_CANCELLED_ERROR                 @"UserLoginCancelled"//@"The operation couldn't be completed. (NSURLErrorDomain error -1009.)"


//Day / Night Light Alert Settings
#define API_LIGHT_ALERT_SETTINGS             @"settings"
#define API_LIGHT_ALERT_DURATION             @"duration"
#define API_LIGHT_ALERT_END_HOUR             @"end_hour"
#define API_LIGHT_ALERT_END_MIN              @"end_min"
#define API_LIGHT_ALERT_LEVEL                @"level"
#define API_LIGHT_ALERT_LEVEL_HIGH           @"level_high"
#define API_LIGHT_ALERT_LEVEL_LOW            @"level_low"
#define API_LIGHT_ALERT_LEVEL_MID            @"level_mid"
#define API_LIGHT_ALERT_START_HOUR           @"start_hour"
#define API_LIGHT_ALERT_START_MIN            @"start_min"
#define API_LIGHT_ALERT_START_STATUS         @"status"
#define API_LIGHT_ALERT_INTERVAL             @"alert_interval"
#define API_LIGHT_ALERT_START_TYPE           @"type"

//Inactive Alert Settings
#define API_INACTIVE_ALERT_END_HOUR         @"end_hour"
#define API_INACTIVE_ALERT_END_MIN          @"end_min"
#define API_INACTIVE_ALERT_START_HOUR       @"start_hour"
#define API_INACTIVE_ALERT_START_MIN        @"start_min"
#define API_INACTIVE_ALERT_STEPS_THRESHOLD  @"steps_threshold"
#define API_INACTIVE_ALERT_TIME_DURATION    @"time_duration"
#define API_INACTIVE_ALERT_TYPE             @"type"
#define API_INACTIVE_ALERT_STATUS           @"status"

//Timing
#define API_TIMING_SMART_FOR_SLEEP          @"smart_for_sleep"
#define API_TIMING_SMART_FOR_WRIST          @"smart_for_wrist"
/**
 *  Status
 */

// Language detection

#define LANGUAGE_IS_FRENCH                  [[[NSLocale preferredLanguages] objectAtIndex:0] rangeOfString:@"fr" options:NSCaseInsensitiveSearch].location != NSNotFound//[[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"fr"] || [[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"fr-CA"]

// Log in
#define STATUS_LOG_IN                           NSLocalizedString(@"Signing in",@"status message when signing in")

// Facebook Log in
#define STATUS_FACEBOOK_LOG_IN                  NSLocalizedString(@"Signing in",@"status message when signing in")

// Register
#define STATUS_REGISTER                         NSLocalizedString(@"Registering",@"status message when regestering")
#define STATUS_REGISTER_SUCCESS                 NSLocalizedString(@"Registration Successful.",@"status message when the registration is successful")

// Profile
#define STATUS_PROFILE_UPDATE                   NSLocalizedString(@"Updating Profile",@"status message when the user is updating his/her profile")
#define STATUS_PROFILE_UPDATE_SUCCESS           NSLocalizedString(@"Update Successful.",@"status message when in a successful update")

/**
 *  Error
 */

// Values
#define ERROR_TITLE                             NSLocalizedString(@"Error",@"Alert title for errors")

// Error Codes
#define ERROR_CODE_API                          1000
#define ERROR_CODE_ACCESSTOKEN_INVALID          1001

// Validation Error
#define ERROR_LOG_IN_MISSING_FIELDS             NSLocalizedString(@"Please fill out all fields.",@"an error message for log in missing fields")
#define ERROR_REGISTER_MISSING_FIELDS           NSLocalizedString(@"Please fill out all fields.",@"an error message for registration missing fields")
#define ERROR_REGISTER_UNMATCHED_PASSWORD       NSLocalizedString(@"Passwords do not match.",@"an error message for unmatched passwords")
#define ERROR_REGISTER_PASSWORD_CHARACTERS      NSLocalizedString(@"Password must be more than 6 characters",@"an error message for less than 6 characters for passwords")
#define ERROR_PROFILE_MISSING_PASSWORD          NSLocalizedString(@"Please complete the change password form.",@"an error message for any unfilled forms/fields")
#define ERROR_PASSWORD_LESS_THAN_MIN            NSLocalizedString(@"Your password should be not less than 6 characters.",@"an error message for less than 6 characters for passwords")
#define ERROR_RESET_PASSWORD_MISSING_FIELDS     NSLocalizedString(@"Please fill out the email address field.", nil)
#define ERROR_REGISTER_NAME_SINGLE_LETTER       NSLocalizedString(@"Incorrect input for first name and/or last name.", nil)
#define ERROR_REGISTER_EMAIL                    NSLocalizedString(@"Incorrect input for email.", nil)
#define ERROR_REGISTER_TAC_UNCHECKED            NSLocalizedString(@"You must accept LifeTrak's Terms and Conditions.", nil)

/**
 *  Local Notification
 */

// Keys
#define AUTO_SYNC_TIME_STAMP_1      @"auto_sync_date_1"
#define AUTO_SYNC_TIME_STAMP_2      @"auto_sync_date_2"
#define AUTO_SYNC_TIME_STAMP_3      @"auto_sync_date_3"
#define AUTO_SYNC_TIME_STAMP_4      @"auto_sync_date_4"
#define AUTO_SYNC_TIME_WEEKLY       @"weekly"
#define SYNC_NOTIFICATION_MESSAGE   @"You have a scheduled sync. Tap phone notification to start."


/**
 *  Sync Notification Names
 */
#define SYNCING_FINISHED @"SyncingFinished"
#define SYNCING_ON_GOING @"SyncingOnGoing"

/*
 *  November 24, 2014
 *  From the View Controllers
 */

#define DATE_FORMAT_DDMMYY          NSLocalizedString(@"DD/MM/YY", @"date format")
#define DATE_FORMAT_MMDDYY          NSLocalizedString(@"MM/DD/YY", @"date format")
#define DATE_FORMAT_DDMMM           NSLocalizedString(@"DD/MMM", @"date format")
#define DATE_FORMAT_MMMDD           NSLocalizedString(@"MMM/DD", @"date format")

#define kMenuDashboard              NSLocalizedString(@"Dashboard", nil)
#define kMenuPulsewaveAnalysis      NSLocalizedString(@"Pulsewave Analysis", nil)
#define kMenuGoals                  NSLocalizedString(@"Goals", nil)
#define kActigraphy                 NSLocalizedString(@"Actigraphy", nil)
#define kMenuAlarms                 NSLocalizedString(@"Alarms", nil)

#define kSettingsSync               NSLocalizedString(@"Settings", nil)
#define kSettingsPartners           NSLocalizedString(@"Partners", nil)
#define kSettingsApplication        NSLocalizedString(@"Help", nil)
#define kSettingsSignOut            NSLocalizedString(@"Sign out", nil)

#define BUTTON_TITLE_CANCEL         NSLocalizedString(@"Cancel", nil)
#define BUTTON_TITLE_OK             NSLocalizedString(@"OK", nil)
#define BUTTON_TITLE_OK_NORMAL      NSLocalizedString(@"Ok", nil)
#define BUTTON_TITLE_YES_ALL_CAPS   NSLocalizedString(@"YES", nil)
#define BUTTON_TITLE_YES            NSLocalizedString(@"Yes", nil)
#define BUTTON_TITLE_NO_ALL_CAPS    NSLocalizedString(@"NO", nil)
#define BUTTON_TITLE_NO             NSLocalizedString(@"No", nil)
#define BUTTON_TITLE_DONE           NSLocalizedString(@"Done", nil)
#define BUTTON_TITLE_RETRY          NSLocalizedString(@"Retry", nil)
#define BUTTON_TITLE_CONNECT        NSLocalizedString(@"Connect", nil)
#define BUTTON_TITLE_DISCONNECT     NSLocalizedString(@"Disconnect", nil)
#define BUTTON_TITLE_SUPPORT        NSLocalizedString(@"Support", nil)
#define BUTTON_TITLE_ADD            NSLocalizedString(@"Add", nil)
#define BUTTON_TITLE_EDIT           NSLocalizedString(@"Edit", nil)
#define BUTTON_TITLE_CONTINUE       NSLocalizedString(@"Continue", nil)
#define BUTTON_TITLE_SKIP           NSLocalizedString(@"Skip", nil)
#define BUTTON_TITLE_DELETE         NSLocalizedString(@"Delete", nil)
#define BUTTON_TITLE_ENABLE         NSLocalizedString(@"Enable", nil)
#define BUTTON_TITLE_DEVICE         NSLocalizedString(@"Device", nil)
#define BUTTON_TITLE_DISABLE        NSLocalizedString(@"Disable",nil)

#define MESSAGE_NOT_YET_SYNCED      NSLocalizedString(@"Not yet synced.", nil)
#define MESSAGE_SIGN_OUT            NSLocalizedString(@"Are you sure you want to sign out?", @"a message when signing out")

#define LS_APP_VERSION              NSLocalizedString(@"App Version :", nil)
#define LS_SDK_VERSION              NSLocalizedString(@"SDK Version :", nil)
#define LS_FW_VERSION               NSLocalizedString(@"Firmware Version :", nil)
#define LS_SW_VERSION               NSLocalizedString(@"Software Version :", nil)

#define LS_STEPS_ALL_CAPS           NSLocalizedString(@"STEPS", nil)
#define LS_STEPS_TITLE              NSLocalizedString(@"Steps", nil)
#define LS_STEPS_ALL_LOWERCASE      NSLocalizedstring(@"steps", nil)

#define LS_DEFAULT_ALL_CAPS         NSLocalizedString(@"DEFAULT", nil)
#define LS_DEFAULT_TITLE            NSLocalizedString(@"Default", nil)
#define LS_DEFAULT_ALL_LOWERCASE    NSLocalizedstring(@"default", nil)

#define LS_STATUS_ALL_CAPS          NSLocalizedString(@"STATUS", nil)
#define LS_STATUS_TITLE             NSLocalizedString(@"Status", nil)
#define LS_STATUS_ALL_LOWERCASE     NSLocalizedString(@"status", nil)

#define LS_MONDAY                   NSLocalizedString(@"Monday", nil)
#define LS_TUESDAY                  NSLocalizedString(@"Tuesday", nil)
#define LS_WEDNESDAY                NSLocalizedString(@"Wednesday", nil)
#define LS_THURSDAY                 NSLocalizedString(@"Thursday", nil)
#define LS_FRIDAY                   NSLocalizedString(@"Friday", nil)
#define LS_SATURDAY                 NSLocalizedString(@"Saturday", nil)
#define LS_SUNDAY                   NSLocalizedString(@"Sunday", nil)


#define LS_MON                      NSLocalizedString(@"Mon", nil)
#define LS_TUE                      NSLocalizedString(@"Tue", nil)
#define LS_WED                      NSLocalizedString(@"Wed", nil)
#define LS_THU                      NSLocalizedString(@"Thu", nil)
#define LS_FRI                      NSLocalizedString(@"Fri", nil)
#define LS_SAT                      NSLocalizedString(@"Sat", nil)
#define LS_SUN                      NSLocalizedString(@"Sun", nil)

#define LS_LOW                      NSLocalizedString(@"Low", nil)
#define LS_MEDIUM                   NSLocalizedString(@"Medium", nil)
#define LS_HIGH                     NSLocalizedString(@"High", nil)

#define LS_LOW_CAPS                 NSLocalizedString(@"LOW", nil)
#define LS_MEDIUM_CAPS              NSLocalizedString(@"MEDIUM", nil)
#define LS_HIGH_CAPS                NSLocalizedString(@"HIGH", nil)

#define LS_MALE_CAPS                NSLocalizedString(@"MALE", nil)
#define LS_FEMALE_CAPS              NSLocalizedString(@"FEMALE", nil)

#define LS_MALE                     NSLocalizedString(@"male", nil)
#define LS_FEMALE                   NSLocalizedString(@"female", nil)

#define LS_MALE_CAP_FIRST           NSLocalizedString(@"Male", nil)
#define LS_FEMALE_CAP_FIRST         NSLocalizedString(@"Female", nil)

#define LS_METRIC_CAPS              NSLocalizedString(@"METRIC", @"a unit of measurement")
#define LS_IMPERIAL_CAPS            NSLocalizedString(@"IMPERIAL", @"a unit of measurement")

#define LS_METRIC                   NSLocalizedString(@"Metric", @"a unit of measurement")
#define LS_IMPERIAL                 NSLocalizedString(@"Imperial", @"a unit of measurement")

#define LS_SIMPLE                   NSLocalizedString(@"Simple", @"watch face")
#define LS_FULL                     NSLocalizedString(@"Full", @"watch face")

#define LS_DAY                      NSLocalizedString(@"Day", nil)
#define LS_WEEK                     NSLocalizedString(@"Week", nil)
#define LS_MONTH                    NSLocalizedString(@"Month", nil)
#define LS_YEAR                     NSLocalizedString(@"Year", nil)

#define LS_LIVE                     NSLocalizedString(@"Live", nil)

#define LS_DAILY                    NSLocalizedString(@"DAILY", nil)
#define LS_WEEKLY                   NSLocalizedString(@"WEEKLY", nil)
#define LS_MONTHLY                  NSLocalizedString(@"MONTHLY", nil)
#define LS_YEARLY                   NSLocalizedString(@"YEARLY", nil)

#define LS_WEIGHT                   NSLocalizedString(@"Weight", nil)

#define LS_SEARCHING                NSLocalizedString(@"Searching", nil)
#define LS_GOAL_ALL_CAPS            NSLocalizedString(@"GOAL", nil)

#define LS_HEART_RATE_ALL_CAPS      NSLocalizedString(@"HEART RATE", nil)
#define LS_HEART_RATE               NSLocalizedString(@"Heart Rate", nil)

#define LS_SLEPT                    NSLocalizedString(@"SLEPT", nil)
#define LS_DEEP_SLEEP               NSLocalizedString(@"DEEP SLEEP", nil)

#define LS_TIMES                    NSLocalizedString(@"times", nil)
#define LS_TIME                     NSLocalizedString(@"time", nil)

#define LS_WORKOUT_TIME                   NSLocalizedString(@"WORKOUT TIME", nil)
#define LS_WORKOUT_TIME_VARIABLE          NSLocalizedString(@"WORKOUT %i TIME", nil)
#define LS_TOTAL_WORKOUT_TIME_VARIABLE    NSLocalizedString(@"TOTAL WORKOUT TIME", nil)
#define LS_WORKOUT_VARIABLE               NSLocalizedString(@"Workout %i", nil)

/*
 * mixed strings
 */

#define LS_WALGREENS_ALERT_ERROR    NSLocalizedString(@"Connect to Walgreens Error", nil)
#define LS_WALGREENS_TITLE          NSLocalizedString(@"Walgreens Balance® Rewards", nil)
#define LS_WALGREENS_MESSAGE        NSLocalizedString(@"Get points for the healthy activities you do every day.", nil)
#define LS_WALGREENS_CONNECT        NSLocalizedString(@"Connecting to Walgreens...", nil)

#define LS_ACCEPT_TERMS             NSLocalizedString(@"I agree to LifeTrak's TERMS & CONDITIONS", nil)
#define LS_TERMS_AND_CONDITIONS     NSLocalizedString(@"TERMS & CONDITIONS", nil)
//Terms and Conditions
#define LS_TERMS_AND_CONDITIONS_SMALL     NSLocalizedString(@"Terms and Conditions", nil)

#define LS_HELP_SUBJECT             NSLocalizedString(@"LifeTrak iOS App Help", nil)

#define LS_EMAIL_NOT_SET            NSLocalizedString(@"This device has no mail account connected. Please set up your mail first.", nil)

#define LS_SUCCESS_SERVER_SYNC      NSLocalizedString(@"Successfully synced data with server", nil)

#define LS_SUCCESS                  NSLocalizedString(@"Success", nil)

#define LS_DISTANCE                 NSLocalizedString(@"Distance", nil)
#define LS_CALORIES                 NSLocalizedString(@"Calories", nil)
#define LS_SLEEP                    NSLocalizedString(@"Sleep", nil)
#define LS_BRIGHT_LIGHT_DURATION    NSLocalizedString(@"BRIGHT LIGHT DURATION", nil)

#define LS_AUTO_SYNC_WATCH          NSLocalizedString(@"Auto sync to watch", nil)
#define LS_SYNC_TO_SERVER           NSLocalizedString(@"Syncing to Server", nil)
#define LS_SYNC_SERVER_SUCCESS      NSLocalizedString(@"Sync to Server successful.", nil)
#define LS_SYNC_RESTORE_FROM_SERVER NSLocalizedString(@"Restoring from Server", nil)
#define LS_SYNC_RESTORE_SUCCESS     NSLocalizedString(@"Restore from Server successful.", nil)
#define LS_SYNC_SERVER              NSLocalizedString(@"Server Sync", nil)
#define LS_SYNC_FAILED              NSLocalizedString(@"Sync failed", nil)
#define LS_SYNC_YESTERDAY           NSLocalizedString(@"Synced Yesterday at", nil)
#define LS_SYNC_TODAY               NSLocalizedString(@"Synced Today at", nil)
#define LS_SYNC_CLOUD               NSLocalizedString(@"Syncing to cloud", nil)

#define LS_RESET                    NSLocalizedString(@"Reset", nil)
#define LS_RESTORE_PREV             NSLocalizedString(@"Restore to Previous", nil)

#define LS_SLEEP_LOGS               NSLocalizedString(@"Sleep Logs", nil)

#define LS_INVALID_BIRTHDAY         NSLocalizedString(@"Invalid birthday", nil)
#define LS_INVALID_BIRTHDAY_MESSAGE NSLocalizedString(@"Please choose date not later than today.", nil)

#define LS_ABOUT_ME                 NSLocalizedString(@"ABOUT ME", nil)
#define LS_MY_LIFETRAK              NSLocalizedString(@"MY LIFETRAK", nil)
#define LS_CLOUD_SYNC               NSLocalizedString(@"CLOUD SYNC", nil)

#define LS_WALGREENS_RETRIEVE_MESSAGE   NSLocalizedString(@"Retrieving Walgreens Information", nil)
#define LS_WALGREENS_CONNECT_MESSAGE    NSLocalizedString(@"Please reconnect your Walgreens account to continue.", nil)
#define LS_WALGREENS_SYNC_MESSAGE       NSLocalizedString(@"Walgreens requires you to update your data to cloud. Do you want to sync now?", nil)
#define LS_WALGREENS_DISCONNECT         NSLocalizedString(@"Disconnecting from Walgreens...", nil)
#define LS_WALGREENS_DISCONNECT_FAIL    NSLocalizedString(@"Unable to disconnect from Walgreens", nil)

#define LS_SYNCING                  NSLocalizedString(@"Syncing", nil)
#define LS_SYNCED_AT                NSLocalizedString(@"Synced at", nil)

#define LS_HEIGHT                   NSLocalizedString(@"Height", nil)
#define LS_BIRTHDAY                 NSLocalizedString(@"Birthday", nil)

#define LS_WEIGHT_WITH_UNIT_IMP     NSLocalizedString(@"Weight (lbs)", nil)
#define LS_HEIGHT_WITH_UNIT_IMP     NSLocalizedString(@"Height (ft)", nil)
#define LS_WEIGHT_WITH_UNIT_MET     NSLocalizedString(@"Weight (kg)", nil)
#define LS_HEIGHT_WITH_UNIT_MET     NSLocalizedString(@"Height (cm)", nil)
#define LS_BIRTHDAY_WITH_UNIT_DMY   NSLocalizedString(@"Birthday (DD/MM/YYYY)", nil)
#define LS_BIRTHDAY_WITH_UNIT_MDY   NSLocalizedString(@"Birthday (MM/DD/YYYY)", nil)
#define LS_BIRTHDAY_WITH_UNIT_DM    NSLocalizedString(@"Birthday (DDD/MM)", nil)
#define LS_BIRTHDAY_WITH_UNIT_MD    NSLocalizedString(@"Birthday (MMM/DD)", nil)

#define LS_UPLOAD_PHOTO             NSLocalizedString(@"Upload Photo", nil)
#define LS_ACCOUNT_DETAILS          NSLocalizedString(@"ACCOUNT DETAILS", nil)
#define LS_CHANGE_PASSWORD          [NSString stringWithFormat:@" %@", NSLocalizedString(@"CHANGE PASSWORD", nil)]
#define LS_SIGN_IN_EMAIL            NSLocalizedString(@"LOG IN WITH EMAIL", nil)
#define LS_FORGOT_PASSWORD          NSLocalizedString(@"FORGOT PASSWORD", nil)
#define LS_SIGN_IN_MESSAGE          NSLocalizedString(@"Signing In", nil)
#define LS_SIGN_UP_EMAIL            NSLocalizedString(@"SIGN UP WITH EMAIL", nil)
#define LS_SIGN_UP_ADD_PROFILE_PIC  NSLocalizedString(@"ADD PROFILE PICTURE", nil)

#define LS_FETCHING_USER_PROFILE    NSLocalizedString(@"Fetching User Profile", nil)
#define LS_FETCHING_DEVICES         NSLocalizedString(@"Fetching Devices", nil)

#define LS_VALIDATE_EMAIL_MESSAGE   NSLocalizedString(@"Don't forget to validate your email!", nil)
#define LS_REMIND_LATER             NSLocalizedString(@"Remind me later", nil)

#define LS_SIGN_IN_FACEBOOK         NSLocalizedString(@"Signing In with Facebook", nil)
#define LS_TRY_AGAIN                NSLocalizedString(@"Try again", nil)

#define LS_CONNECTION_ESTABLISH     NSLocalizedString(@"Establishing connection", nil)

#define LS_DEVICES                  NSLocalizedString(@"Devices", nil)
#define LS_PAIRING                  NSLocalizedString(@"Pairing", nil)
#define LS_SYNCING                  NSLocalizedString(@"Syncing", nil)

#define LS_BLUETOOTH_SETTINGS_MESSAGE NSLocalizedString(@"\n3. Go to your iOS Settings->Bluetooth. Select your LifeTrak device and then select “Forget this Device“.", nil)//NSLocalizedString(@"\n3.You may also try to forget the bluetooth device in iOS system settings.", nil)

#define LS_IMAGE_SOURCE             NSLocalizedString(@"Image Source", nil)
#define LS_CAMERA                   NSLocalizedString(@"Camera", nil)
#define LS_IMAGE_LIBRARY            NSLocalizedString(@"Image Library", nil)

#define LS_RESET_PASSWORD           NSLocalizedString(@"Reset Password", nil)
#define LS_RESET_PASSWORD_CAPS      NSLocalizedString(@"RESET PASSWORD", nil)
#define LS_RESET_PASSWORD_MESSAGE   NSLocalizedString(@"An email containing the instruction to reset your password has been sent to your email.", nil)

#define LS_REQUEST_TIMEOUT          NSLocalizedString(@"The request timed out.", nil)

#define LS_SESSION_EXPIRED_MESSAGE  NSLocalizedString(@"Your LifeTrak session has expired. Please sign in again to continue.", nil)
#define LS_SESSION_EXPIRED          NSLocalizedString(@"Session Expired", nil)
#define LS_CLOUD_SYNC_ERROR         NSLocalizedString(@"Cloud Sync Error", nil)

#define LS_END_TIME_WARNING         NSLocalizedString(@"End time should not be earlier than the Start time.", nil)
#define LS_START_TIME_WARNING       NSLocalizedString(@"Start time and End time should not be similar.", nil)
#define LS_INTERVAL_TIME_WARNING    NSLocalizedString(@"Start and End times must be 30 minutes apart.", nil)

#define LS_EXPOSURE_DURATION_WARNING    NSLocalizedString(@"Exposure duration should not be greater than the time on start time and end time.", nil)
#define LS_OVERLAP_WARNING          NSLocalizedString(@"Day light and night light start and end time should not overlap.", nil)

#define LS_NO_INTERNET              NSLocalizedString(@"No Internet", nil)
#define LS_DELETE_WATCH_WARNING     NSLocalizedString(@"Please connect to the internet to delete watch.", nil)

#define LS_INVALID_EMAIL_MESSAGE    NSLocalizedString(@"Please enter a valid email address.", nil)
#define LS_SLEEP_LOG_WARNING        NSLocalizedString(@"A sleep log exists between the start and end time.", nil)
#define LS_INVALID_END_TIME         NSLocalizedString(@"The end time is not valid.", nil)
#define LS_INVALID_SLEEP_TIME_MAX   NSLocalizedString(@"Sleep must not exceed 14h50min.", nil)
#define LS_INVALID_SLEEP_TIME_MIN   NSLocalizedString(@"Sleep must not be less than 1min.", nil)
#define LS_DELETE_RECORD_WARNING    NSLocalizedString(@"Are you sure you want to delete this record?", nil)

#define LS_R500_DISCONNECTED        NSLocalizedString(@"R500 watch is disconnected", nil)
#define LS_R500_NOT_FOUND           NSLocalizedString(@"We can't find your R500 watch", nil)

#define LS_SENDING_DATA             NSLocalizedString(@"Sending Data", nil)

#define LS_PAIRING_DEVICE           NSLocalizedString(@"Pairing device", nil)

#define LS_UPDATING_NOTIFICATION    NSLocalizedString(@"Updating notification...", nil)
#define LS_UPDATING_DONE            NSLocalizedString(@"Notification updated!", nil)

#define LS_SIGN_UP_VIA_FACEBOOK     NSLocalizedString(@"Signing up with Facebook", nil)

#define LS_SYNC_INVALID_TIME        NSLocalizedString(@"Invalid sync time", nil)
#define LS_SYNC_SCHEDULE_WARNING    NSLocalizedString(@"Sync schedule cannot be set to same time", nil)

#define LS_WORKOUT                  NSLocalizedString(@"Workout", nil)

#define LS_AVG_BPM                  NSLocalizedString(@"AVG BPM",nil)

#define LS_AM                       NSLocalizedString(@"AM", nil)
#define LS_PM                       NSLocalizedString(@"PM", nil)


/*
 * VC Defaults
 */

#define SECTION_UNIT_PREFERENCES    [NSString stringWithFormat:@"  %@", NSLocalizedString(@"PREFERENCES", nil)]
#define SECTION_PROMPTS [NSString stringWithFormat:@"  %@", NSLocalizedString(@"PROMPTS", nil)]

#define SECTION_APP_SETTINGS                [NSString stringWithFormat:@"     %@", NSLocalizedString(@"APP SETTINGS", nil)]
#define SECTION_WATCH_SETTINGS              [NSString stringWithFormat:@"     %@", NSLocalizedString(@"WATCH SETTINGS", nil)]
#define SECTION_CLOUD_SETTINGS              [NSString stringWithFormat:@"     %@", NSLocalizedString(@"CLOUD SETTINGS", nil)]
#define SECTION_WORKOUT_SETTINGS              [NSString stringWithFormat:@"     %@", NSLocalizedString(@"WORKOUT SETTINGS", nil)]
#define SETTING_SWITCH_WATCH                [NSString stringWithFormat:@"%@", NSLocalizedString(@"SWITCH WATCH", nil)]
#define SETTING_RESET_WORKOUT                [NSString stringWithFormat:@"%@", NSLocalizedString(@"RESET WORKOUT", nil)]

#define SETTINGS_PROMPT_TITLE               [NSString stringWithFormat:@"%@", NSLocalizedString(@"Updated settings prompt", nil)]
#define SETTINGS_PROMPT_DESC                [NSString stringWithFormat:@"%@", NSLocalizedString(@"Get notification when watch and app settings don't match", nil)]
#define SETTINGS_SMART_CALIBRATION_TITLE    [NSString stringWithFormat:@"%@", NSLocalizedString(@"Smart calibration", nil)]
#define SETTINGS_SMART_CALIBRATION_DESC     [NSString stringWithFormat:@"%@", NSLocalizedString(@"Customize watch sensitivity for calories and distance", nil)]
#define SETTINGS_DEVICE_NAME                [NSString stringWithFormat:@"%@", NSLocalizedString(@"Device name", nil)]
#define SETTINGS_TIME_FORMAT                [NSString stringWithFormat:@"%@", NSLocalizedString(@"Time format", nil)]
#define SETTINGS_SYNC_TIME_TO_PHONE         [NSString stringWithFormat:@"%@", NSLocalizedString(@"Sync watch to phone time", nil)]
#define SETTINGS_DATE_FORMAT                [NSString stringWithFormat:@"%@", NSLocalizedString(@"Date format", nil)]
#define SETTINGS_UNITS                      [NSString stringWithFormat:@"%@", NSLocalizedString(@"Units", nil)]
#define SETTINGS_WATCH_DISPLAY              [NSString stringWithFormat:@"%@", NSLocalizedString(@"Watch display", nil)]
#define SETTINGS_AUTO_BACKLIGHT             [NSString stringWithFormat:@"%@", NSLocalizedString(@"Auto backlight", nil)]
#define SETTINGS_WATCH_ALARMS               [NSString stringWithFormat:@"%@", NSLocalizedString(@"Watch alarms", nil)]
#define SETTINGS_NOTIFICATION_TITLE         [NSString stringWithFormat:@"%@", NSLocalizedString(@"Notification display", nil)]
#define SETTINGS_NOTIFICATION_DESC          [NSString stringWithFormat:@"%@", NSLocalizedString(@"Choose which phone notifications to display on watch", nil)]

#define SETTINGS_ENABLE_SYNC_TO_CLOUD              [NSString stringWithFormat:@"%@", NSLocalizedString(@"Enable cloud sync", nil)]
#define SETTINGS_SYNC_TO_CLOUD              [NSString stringWithFormat:@"%@", NSLocalizedString(@"Sync to cloud", nil)]

#define SETTINGS_WS_HR_LOGGIN_RATE            [NSString stringWithFormat:@"%@", NSLocalizedString(@"HR logging rate", nil)]
#define SETTINGS_WS_STORAGE_LEFT              [NSString stringWithFormat:@"%@", NSLocalizedString(@"Workout storage left", nil)]
#define SETTINGS_WS_RECONNECT_TIMEOUT         [NSString stringWithFormat:@"%@", NSLocalizedString(@"Reconnect timeout", nil)]


#define SETTINGS_SYNC_TO_WATCH              [NSString stringWithFormat:@"%@", NSLocalizedString(@"Sync settings to watch", nil)]
#define SETTINGS_SYNC_REMINDER              [NSString stringWithFormat:@"%@", NSLocalizedString(@"Sync reminder", nil)]
#define SETTINGS_ONCE_A_DAY                 [NSString stringWithFormat:@"%@", NSLocalizedString(@"Once a day", nil)]
#define SETTINGS_ONCE_A_WEEK                [NSString stringWithFormat:@"%@", NSLocalizedString(@"Once a week", nil)]

#define SETTINGS_HOUR_FORMAT_12             [NSString stringWithFormat:@"%@", NSLocalizedString(@"12 hour", nil)]
#define SETTINGS_HOUR_FORMAT_24             [NSString stringWithFormat:@"%@", NSLocalizedString(@"24 hour", nil)]

#define SMART_CALIB_STEP_TITLE              NSLocalizedString(@"STEP CALIBRATION", nil)
#define SMART_CALIB_STEP_DESCRIPTION        NSLocalizedString(@"If your step count seems inaccurate, adjust your watch's motion sensitivity", nil)
#define SMART_CALIB_STEP_BRIEF              NSLocalizedString(@"motion sensitivity", nil)
#define SMART_CALIB_DISTANCE_TITLE          NSLocalizedString(@"DISTANCE CALIBRATION", nil)
#define SMART_CALIB_DISTANCE_DESCRIPTION    NSLocalizedString(@"If your distance seems inaccurate, adjust the watch's stride measurement", nil)
#define SMART_CALIB_DISTANCE_BRIEF          NSLocalizedString(@"stride measurement", nil)
#define SMART_CALIB_CALORIES_TITLE          NSLocalizedString(@"CALORIE CALIBRATION", nil)
#define SMART_CALIB_CALORIES_DESCRIPTION    NSLocalizedString(@"If your calories seem inaccurate, adjust the watch's calorie rate calculation", nil)
#define SMART_CALIB_CALORIES_BRIEF          NSLocalizedString(@"calorie rate calculation", nil)

#define SMART_CALIB_LONGER_STRIDES          NSLocalizedString(@"Longer strides", nil)
#define SMART_CALIB_SHORTER_STRIDES         NSLocalizedString(@"Shorter strides", nil)
#define SMART_CALIB_LESS_CALORIES           NSLocalizedString(@"Less calories", nil)
#define SMART_CALIB_MORE_CALORIES           NSLocalizedString(@"More calories", nil)

#define SMART_CALIB_DEFAULT                       NSLocalizedString(@"Recommend for walking and running.", nil)
#define SMART_CALIB_A                       NSLocalizedString(@"Recommend for low intensity walking or mild jogging.", nil)
#define SMART_CALIB_B                       NSLocalizedString(@"Alternate sensing orientation if the above two options do not provide accurate enough step values.", nil)
#define SMART_CALIB_OPTION_DEFAULT                       NSLocalizedString(@"Default", nil)
#define SMART_CALIB_OPTION_A                       NSLocalizedString(@"Option A", nil)
#define SMART_CALIB_OPTION_B                       NSLocalizedString(@"Option B", nil)




#define MY_ACCOUNT_ACCOUNT          NSLocalizedString(@"Account", nil)

#define LS_LOGGED_IN_AS             NSLocalizedString(@"Logged in as", nil)
#define LS_FIRST_NAME               NSLocalizedString(@"First name", nil)
#define LS_LAST_NAME                NSLocalizedString(@"Last name", nil)
#define LS_EMAIL                    NSLocalizedString(@"Email", nil)
#define LS_PASSWORD                 NSLocalizedString(@"Password", nil)
#define LS_GENDER                   NSLocalizedString(@"Gender", nil)
#define LS_OLD_PASSWORD             NSLocalizedString(@"Old password", nil)
#define LS_NEW_PASSWORD             NSLocalizedString(@"New password", nil)
#define LS_CONFIRM_PASSWORD         NSLocalizedString(@"Confirm password", nil)
#define LS_CHANGE_PROFILE_PICTURE   NSLocalizedString(@"CHANGE PROFILE PICTURE", nil)//CHANGE PROFILE PICTURE


#define SECTION_SYNC_FREQUENCY      [NSString stringWithFormat:@"  %@", NSLocalizedString(@"Sync Frequency", nil)]
#define SECTION_BLANK               @""
#define OPTION_ONCE_LABEL           NSLocalizedString(@"Once a day", nil)
#define OPTION_ONCE_A_WEEK_LABEL    NSLocalizedString(@"Once a week", nil)
#define OPTION_TWICE_LABEL          NSLocalizedString(@"Twice a day", nil)
#define OPTION_FOUR_TIMES_LABEL     NSLocalizedString(@"Four times a day", nil)

#define NOTIFICATION_SECTION_TITLE  NSLocalizedString(@"Choose what notifications to be displayed", nil)
#define SMART_FOR_SLEEP_ALWAYS      NSLocalizedString(@"Always",nil)
#define SMART_FOR_SLEEP_WHEN_AWAKE  NSLocalizedString(@"Only when awake", nil)
#define SMART_FOR_SLEEP_NEVER       NSLocalizedString(@"Never", nil)


#define WATCH_ALARMS_TITLE                  NSLocalizedString(@"Watch alarms", nil)

#define WATCH_ALARMS_WAKE_UP               NSLocalizedString(@"Intelligent wake up alarm", nil)
#define WATCH_ALARMS_WAKE_UP_DESC          NSLocalizedString(@"Gradually wakes you up with a series of alarms", nil)
#define WATCH_ALARMS_DAYLIGHT              NSLocalizedString(@"LightTrak daylight alert", nil)
#define WATCH_ALARMS_DAYLIGHT_DESC         NSLocalizedString(@"Reminds you to get healthy amount of morning light exposure", nil)
#define WATCH_ALARMS_NIGHTLIGHT            NSLocalizedString(@"LightTrak night light alert", nil)
#define WATCH_ALARMS_NIGHTLIGHT_DESC       NSLocalizedString(@"Reminds you to get healthy amount of evening light exposure", nil)
#define WATCH_ALARMS_INACTIVITY            NSLocalizedString(@"Inactivity alert", nil)
#define WATCH_ALARMS_INACTIVITY_DESC       NSLocalizedString(@"Regularly reminds you to get active", nil)

#define LS_WAKEUP_TIME              NSLocalizedString(@"Wake up time", nil)
#define LS_WAKEUP_TIME_STARTS       NSLocalizedString(@"Intelligent wake up starts", nil)
#define LS_EXPOSURE_LEVEL           NSLocalizedString(@"Exposure level", nil)
#define LS_LIGHT_EXPOSURE_GOAL      NSLocalizedString(@"Light exposure goal", nil)
#define LS_ALERT_WINDOW             NSLocalizedString(@"Alert window", nil)
#define LS_ALERT_INTERVAL           NSLocalizedString(@"Alert interval", nil)
#define LS_STEPS_THRESHOLD          NSLocalizedString(@"Steps threshold", nil)
#define LS_TO                       NSLocalizedString(@"to", nil)

#define LS_EARLIER                  NSLocalizedString(@"earlier", nil)
#define LS_EXPOSURE_DURATION        NSLocalizedString(@"Exposure Duration", nil)
#define LS_START_TIME               NSLocalizedString(@"Start Time", nil)
#define LS_END_TIME                 NSLocalizedString(@"End Time", nil)
#define LS_ALERT_FREQUENCY          NSLocalizedString(@"Alert Frequency", nil)
#define LS_TIME_DURATION            NSLocalizedString(@"Time Duration", nil)
#define LS_STEPS                    NSLocalizedString(@"steps", nil)
#define LS_STEP                     NSLocalizedString(@"step", nil)

#define LS_HR                       NSLocalizedString(@"hr", nil)
#define LS_MIN                      NSLocalizedString(@"min", nil)
#define LS_HRS                       NSLocalizedString(@"hrs", nil)
#define LS_MINS                      NSLocalizedString(@"mins", nil)



#define FUN_FACTS                    NSLocalizedString(@"Fun Facts", nil)

#define FUN_FACT_1_TITLE            NSLocalizedString(@"Did you know?", nil)
#define FUN_FACT_1_CONTENT          NSLocalizedString(@"There are special photoreceptors in the human eye that help regulate the sleep hormone melatonin based on the amount of light it receives. It’s especially sensitive to blue light frequencies.", nil)
#define FUN_FACT_1_BUTTON1_TITLE    NSLocalizedString(@"What is blue light?", nil)
#define FUN_FACT_1_BUTTON2_TITLE    NSLocalizedString(@"Tell me about light and sleep", nil)
#define FUN_FACT_1_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_1_ICON             NSLocalizedString(@"didyouknow", nil)

#define FUN_FACT_2_TITLE            NSLocalizedString(@"What is blue light?", nil)
#define FUN_FACT_2_CONTENT          NSLocalizedString(@"Light from the sun contains all wavelengths of visible light, which we see as white light. Blue light is a component of the light we see all around us. Blue light has the most effect in regulating sleep wake cycles.", nil)
#define FUN_FACT_2_BUTTON1_TITLE    NSLocalizedString(@"Tell me about light and sleep", nil)
#define FUN_FACT_2_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_2_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_2_ICON             NSLocalizedString(@"bluelight_UV", nil)

#define FUN_FACT_3_TITLE            NSLocalizedString(@"Light alerts", nil)
#define FUN_FACT_3_CONTENT          NSLocalizedString(@"All human beings have an biological oscillator with a 24 hour period called the circadian rhythm. Getting enough light in the morning can synchronize your sleep clock, and getting too much light in the evening can disrupt your sleep clock.", nil)
#define FUN_FACT_3_BUTTON1_TITLE    NSLocalizedString(@"Tell me about morning light", nil)
#define FUN_FACT_3_BUTTON2_TITLE    NSLocalizedString(@"Tell me about evening light", nil)
#define FUN_FACT_3_BUTTON3_TITLE    NSLocalizedString(@"Tell me about UV light", nil)
#define FUN_FACT_3_ICON             NSLocalizedString(@"morninglight", nil)

#define FUN_FACT_4_TITLE            NSLocalizedString(@"Morning light", nil)
#define FUN_FACT_4_CONTENT          NSLocalizedString(@"Get enough blue rich light in the morning, and your body will synchronize your circadian rhythm.  As we age we need more light to synchronize our circadian rhythm, so we recommend you set your light exposure based on your age.", nil)
#define FUN_FACT_4_BUTTON1_TITLE    NSLocalizedString(@"How much light do I need?", nil)
#define FUN_FACT_4_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_4_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_4_ICON             NSLocalizedString(@"morninglight", nil)

#define FUN_FACT_5_TITLE            NSLocalizedString(@"Morning light needs", nil)
#define FUN_FACT_5_CONTENT          NSLocalizedString(@"You can use the Brite R450 to help you ensure you get enough morning light. Select your light threshold and exposure time based on your age.", nil)
#define FUN_FACT_5_BUTTON1_TITLE    NSLocalizedString(@"Tell me about the Morning Light Alert", nil)
#define FUN_FACT_5_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_5_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_5_ICON             NSLocalizedString(@"morninglightneeds", nil)

#define FUN_FACT_6_TITLE            NSLocalizedString(@"Morning light alert", nil)
#define FUN_FACT_6_CONTENT          NSLocalizedString(@"Default morning alert times are 7AM to 12PM, but these can be changed using your smartphone app. If you haven’t received 30 minutes of light with an intensity greater than your morning threshold, the Brite R450 will alert you that you should actively seek out more light.", nil)
#define FUN_FACT_6_BUTTON1_TITLE    NSLocalizedString(@"Tell me about evening light", nil)
#define FUN_FACT_6_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_6_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_6_ICON             NSLocalizedString(@"morninglightalarm", nil)

#define FUN_FACT_7_TITLE            NSLocalizedString(@"Evening Light", nil)
#define FUN_FACT_7_CONTENT          NSLocalizedString(@"If you get too much light in the evening, your body may delay or reduce its melatonin production, which can affect when you get tired, and affect sleep quality. As you age, you need more light to synchronize your circadian rhythm, so we recommend you set your light exposure based on your age.", nil)
#define FUN_FACT_7_BUTTON1_TITLE    NSLocalizedString(@"How much light is too much?", nil)
#define FUN_FACT_7_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_7_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_7_ICON             NSLocalizedString(@"eveninglight", nil)

#define FUN_FACT_8_TITLE            NSLocalizedString(@"Evening Light Needs", nil)
#define FUN_FACT_8_CONTENT          NSLocalizedString(@"The Brite R450 will alert you if you need are getting more evening light than your goal. Select your light threshold and exposure time based on your age.", nil)
#define FUN_FACT_8_BUTTON1_TITLE    NSLocalizedString(@"Tell me about the Evening Light Alert", nil)
#define FUN_FACT_8_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_8_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_8_ICON             NSLocalizedString(@"eveninglightneeds", nil)

#define FUN_FACT_9_TITLE            NSLocalizedString(@"Evening Light Alert", nil)
#define FUN_FACT_9_CONTENT          NSLocalizedString(@"Default evening alert times are 10PM to 11PM, but these can be changed using your smartphone app. It’s important to reduce the amount of light you’re exposed to at least 1 hour before your bedtime. If you’ve received 30 minutes of light with intensity greater than your evening threshold, the Brite R450 will alert you that you should actively try to get less light.", nil)
#define FUN_FACT_9_BUTTON1_TITLE    NSLocalizedString(@"Tell me about UV Light", nil)
#define FUN_FACT_9_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_9_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_9_ICON             NSLocalizedString(@"eveninglightalarm", nil)

#define FUN_FACT_10_TITLE            NSLocalizedString(@"UV Light", nil)
#define FUN_FACT_10_CONTENT          NSLocalizedString(@"Ultraviolet light cannot be seen by the human eye, and has no effect on the human sleep cycle. The Brite R450 does not measure UV light.   You can use sunblock and wear protective clothing while still getting the morning light you need to synchronize your circadian rhythm. IMPORTANT: Always use best practices when exposing yourself to natural light – wear sunscreen and follow doctor’s recommendations for skin care, and never look directly at a light source.", nil)
#define FUN_FACT_10_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_10_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_10_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_10_ICON             NSLocalizedString(@"bluelight_UV", nil)

#define FUN_FACT_11_TITLE            NSLocalizedString(@"Light Fact #1", nil)
#define FUN_FACT_11_CONTENT          NSLocalizedString(@"Blue light can improve performance. In 2013, researchers at Mid Sweden University concluded that blue light was more effective than caffeine at improving performance on a Psychomotor Vigilance Test.", nil)
#define FUN_FACT_11_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_11_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_11_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_11_ICON             NSLocalizedString(@"morninglight", nil)

#define FUN_FACT_12_TITLE            NSLocalizedString(@"Light Fact #2", nil)
#define FUN_FACT_12_CONTENT          NSLocalizedString(@"Bright Light can be an effective treatment for depression. Getting enough bright light can be an effective treatment for both Seasonal and Non-Seasonal Depression", nil)
#define FUN_FACT_12_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_12_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_12_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_12_ICON             NSLocalizedString(@"morninglight", nil)

#define FUN_FACT_13_TITLE            NSLocalizedString(@"Light Fact #3", nil)
#define FUN_FACT_13_CONTENT          NSLocalizedString(@"Light Treatment is generally safe.\nAccording to a 2009 Journal of Sleep Medicine Article, Bright light could pose dangers to patients with known retinal pathology, and in those using photosensitizing medications, but is otherwise is low risk.", nil)
#define FUN_FACT_13_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_13_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_13_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_13_ICON             NSLocalizedString(@"morninglight", nil)

#define FUN_FACT_14_TITLE            NSLocalizedString(@"Light Fact #4", nil)
#define FUN_FACT_14_CONTENT          NSLocalizedString(@"Bright light exposure can improve vitality.\nA 1999 study showed that daily bright light exposure improves vitality. Over 12 weeks, healthy people were exposed to bright light for one hour a day, 5 days a week. Regular controlled surveys revealed improvements in Vitality, General Mental health, emotional problems and physical problems.", nil)
#define FUN_FACT_14_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_14_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_14_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_14_ICON             NSLocalizedString(@"morninglight", nil)

#define FUN_FACT_15_TITLE            NSLocalizedString(@"Sleep Fact #1", nil)
#define FUN_FACT_15_CONTENT          NSLocalizedString(@"Get 7-8 hours of sleep daily.\nThe National Heart, Lung and Blood Institute recommends 7-8 hours of sleep per day for adults, and 9-10 hours of sleep per day for teenagers.", nil)
#define FUN_FACT_15_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_15_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_15_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_15_ICON             NSLocalizedString(@"sleepfacts", nil)

#define FUN_FACT_16_TITLE            NSLocalizedString(@"Sleep Fact #2", nil)
#define FUN_FACT_16_CONTENT          NSLocalizedString(@"Long term Sleep Deprivation is unhealthy.\nLong term sleep deprivation increases risk of heart disease, diabetes, obesity, stroke, and even some cancers.", nil)
#define FUN_FACT_16_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_16_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_16_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_16_ICON             NSLocalizedString(@"sleepfacts", nil)

#define FUN_FACT_17_TITLE            NSLocalizedString(@"Sleep Fact #3", nil)
#define FUN_FACT_17_CONTENT          NSLocalizedString(@"Short term Sleep Deprivation is unhealthy.\nShort term sleep deprivation increases the risk of accidents, increases the risk of catching a cold, increases appetite and overeating, and even results in loss of brain tissue.", nil)
#define FUN_FACT_17_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_17_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_17_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_17_ICON             NSLocalizedString(@"sleepfacts", nil)

#define FUN_FACT_18_TITLE            NSLocalizedString(@"Sleep Fact #4", nil)
#define FUN_FACT_18_CONTENT          NSLocalizedString(@"Sleep deprivation affects your reaction time.\nOver 16 hours of being awake results in reaction time and performance similar to people who have a BAC between 0.05 and 0.1%", nil)
#define FUN_FACT_18_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_18_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_18_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_18_ICON             NSLocalizedString(@"sleepfacts", nil)

#define FUN_FACT_19_TITLE            NSLocalizedString(@"Sleep Fact #5", nil)
#define FUN_FACT_19_CONTENT          NSLocalizedString(@"Sleep loss builds up.\nStudies have shown that sleep deprivation of a few hours every night can build up over several days, resulting in neurobehavioral deficits equivalent to those found after 1-3 days of total sleep loss.", nil)
#define FUN_FACT_19_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_19_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_19_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_19_ICON             NSLocalizedString(@"sleepfacts", nil)

#define FUN_FACT_20_TITLE            NSLocalizedString(@"Sleep Fact #6", nil)
#define FUN_FACT_20_CONTENT          NSLocalizedString(@"Define Insomnia.\nThe term insomnia is derived from the Latin word insomnis, which translates to “sleepless”.", nil)
#define FUN_FACT_20_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_20_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_20_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_20_ICON             NSLocalizedString(@"sleepfacts", nil)

#define FUN_FACT_21_TITLE            NSLocalizedString(@"Sleep Fact #7", nil)
#define FUN_FACT_21_CONTENT          NSLocalizedString(@"Insomnia is not fun.\nInsomnia is associated with increased feelings of hostility and fatigue, and decreased feelings of joviality and attentiveness within individuals.", nil)
#define FUN_FACT_21_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_21_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_21_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_21_ICON             NSLocalizedString(@"sleepfacts", nil)

#define FUN_FACT_22_TITLE            NSLocalizedString(@"Sleep Fact #8", nil)
#define FUN_FACT_22_CONTENT          NSLocalizedString(@"Got Testosterone?\nHealthy young men saw their testosterone levels lower after sleeping less than 5 hours a night for a week.", nil)
#define FUN_FACT_22_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_22_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_22_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_22_ICON             NSLocalizedString(@"sleepfacts", nil)

#define FUN_FACT_23_TITLE            NSLocalizedString(@"Sleep Fact #9", nil)
#define FUN_FACT_23_CONTENT          NSLocalizedString(@"Compose your own sleep patterns.\nListening to relaxing classical music for 45 minutes before bed can improve your sleep quality.", nil)
#define FUN_FACT_23_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_23_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_23_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_23_ICON             NSLocalizedString(@"sleepfacts", nil)

#define FUN_FACT_24_TITLE            NSLocalizedString(@"Actigraphy Fact #1", nil)
#define FUN_FACT_24_CONTENT          NSLocalizedString(@"“All truly great thoughts are conceived by walking” – Nietzsche\nJust 4 minutes of walking has been shown to increase creativity.", nil)
#define FUN_FACT_24_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_24_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_24_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_24_ICON             NSLocalizedString(@"actigraphyfacts", nil)

#define FUN_FACT_25_TITLE            NSLocalizedString(@"Heart Health Fact #1", nil)
#define FUN_FACT_25_CONTENT          NSLocalizedString(@"Heart Disease is prevalent.\nHeart disease is your greatest health threat, and is a greater danger than breast cancer in women and prostate cancer in men.", nil)
#define FUN_FACT_25_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_25_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_25_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_25_ICON             NSLocalizedString(@"hearthealthfact", nil)

#define FUN_FACT_26_TITLE            NSLocalizedString(@"Heart Health Fact #2", nil)
#define FUN_FACT_26_CONTENT          NSLocalizedString(@"Treat your heart right.\nYou can improve your heart health through diet, exercise and managing stress.", nil)
#define FUN_FACT_26_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_26_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_26_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_26_ICON             NSLocalizedString(@"hearthealthfact", nil)

#define FUN_FACT_27_TITLE            NSLocalizedString(@"Heart Health Fact #3", nil)
#define FUN_FACT_27_CONTENT          NSLocalizedString(@"Sounds stressful.\nYou’re more likely to have a heart attack on Monday morning than at any other time of the week.", nil)
#define FUN_FACT_27_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_27_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_27_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_27_ICON             NSLocalizedString(@"hearthealthfact", nil)

#define FUN_FACT_28_TITLE            NSLocalizedString(@"Heart Health Fact #4", nil)
#define FUN_FACT_28_CONTENT          NSLocalizedString(@"Stay active for better heart health.\nPeople who are sedentary at work have a higher risk of heart problems than those in more active jobs.", nil)
#define FUN_FACT_28_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_28_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_28_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_28_ICON             NSLocalizedString(@"hearthealthfact", nil)

#define FUN_FACT_29_TITLE            NSLocalizedString(@"Heart Health Fact #5", nil)
#define FUN_FACT_29_CONTENT          NSLocalizedString(@"Heart Disease can manifest physically.\nOnly 30 percent of Americans correctly identified unusual fatigue, sleep disturbances and jaw pain as all being signs of heart disease -- just a few of the symptoms that can manifest.", nil)
#define FUN_FACT_29_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_29_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_29_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_29_ICON             NSLocalizedString(@"hearthealthfact", nil)

#define FUN_FACT_30_TITLE            NSLocalizedString(@"Heart Health Fact #6", nil)
#define FUN_FACT_30_CONTENT          NSLocalizedString(@"Healthy habits can go a long way.\nThere are five things everyone should learn when it comes to their heart health. These can make an enormous difference and greatly decrease your risk: eat right, exercise regularly, know your cholesterol, blood pressure, and body mass index numbers, do not use tobacco, and know your family history.", nil)
#define FUN_FACT_30_BUTTON1_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_30_BUTTON2_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_30_BUTTON3_TITLE    NSLocalizedString(@"", nil)
#define FUN_FACT_30_ICON             NSLocalizedString(@"hearthealthfact", nil)

#define WatchModel_Move_C300_Android 400

//FLURRY EVENTS
#define DEVICE_SEARCH @"Device_Search"
#define DEVICE_RETRIEVE @"Device_Retrieve"
#define DEVICE_INITIALIZE_CONNECT @"Device_Initialize_Connect"
#define DEVICE_CONNECTED @"Device_Connected"
#define DEVICE_START_SYNC @"Device_Start_Sync"
#define DEVICE_GET_DATA_HEADER @"Get_Data_Header"
#define DEVICE_GET_DATA_POINTS @"Get_Data_Points"
#define DEVICE_GET_LIGHT_DATA_POINTS @"Get_Light_Data_Points"
#define DEVICE_GET_WORKOUT @"Get_Workout"
#define DEVICE_GET_WORKOUT_STOP @"Get_Workout_Stop"
#define DEVICE_GET_SLEEP_DATABASE @"Get_Sleep_Database"
#define DEVICE_GET_SLEEP_SETTING @"Get_Sleep_Setting"
#define DEVICE_GET_STEP_GOAL @"Get_Step_Goal"
#define DEVICE_GET_DISTANCE_GOAL @"Get_Distance_Goal"
#define DEVICE_GET_CALORIES_GOAL @"Get_Calorie_Goal"
#define DEVICE_GET_CALIBRATION_DATA @"Get_Calibration_Data"
#define DEVICE_GET_WAKEUP_SETTING @"Get_Wakeup_Setting"
#define DEVICE_GET_NOTIFICATION @"Get_Notification"
#define DEVICE_GET_ACTIVITY_ALERT @"Get_Activity_Alert"
#define DEVICE_GET_DAYLIGHT_SETTING @"Get_Daylight_Setting"
#define DEVICE_GET_NIGHTLIGHT_SETTING @"Get_Nightlight_Setting"
#define DEVICE_GET_USER_PROFILE @"Get_User_Profile"
#define DEVICE_GET_TIME @"Get_Time"


#define INTRODUCTION_PAGE @"Introduction_Page"
#define DEVICE_LISTING_PAGE @"Device_Listing_Page"
#define SETUP_DEVICE_PAGE @"Setup_Device_Page"
#define PAIRING_PAGE @"Pairing_Page"
#define SYNCING_PAGE @"Syncing_Page"
#define REGISTRATION_PAGE @"Registration_Page"
#define SIGNIN_PAGE @"Signin_Page"
#define DASHBOARD_PAGE @"Dashboard_Page"
#define MYACCOUNTS_PAGE @"MyAccounts_Page"
#define GOALS_PAGE @"Goals_Page"
#define SETTINGS_PAGE @"Settings_Page"
#define PARTNERS_PAGE @"Partners_Page"
#define WALLGREENS_PAGE @"Walgreens_Page"
#define HELP_PAGE @"Help_Page"
#define SIGNOUT_PAGE @"Signout_Page"

#define HEALTHAPP_ACCESS_MESSAGE        NSLocalizedString(@"LifeTrak app will ask you to share data to the Health app. This will allow you to use your LifeTrak fitness tracker with all your other favorite health and fitness apps that can connect to Health App.", nil)
    //@"LifeTrak app will ask you to share data to the Health app. This will allow you to use your LifeTrak fitness tracker with all your other favorite health and fitness apps that can connect to Health App."
    //@"LifeTrak app will ask you to save data to Health App."
#define HEALTHAPP_CONNECT_MESSAGE       NSLocalizedString(@"To change which data you want to be shared by LifeTrak and Health App, you may open Health App on your device, go to the Sources tab and select LifeTrak.", nil)
//@"To change which data you want to be shared by LifeTrak and Health App, you may open Health App on your device, go to the Sources tab and select LifeTrak."//@"LifeTrak app will ask you to save data to Health App."

//PAIRED_MESSAGE                  NSLocalizedString(@"HELPFUL TIPS:\n- Make sure that Bluetooth is active on your phone/tablet.\n- Make sure your phone/tablet has more than 20% battery life, as a low battery on your device may cause syncing issues.", nil)

#define TERMS_AND_COND_FB_ERROR    NSLocalizedString(@"You must agree to LifeTrak’s TERMS & CONDITIONS before proceeding with Facebook sign up", nil)
#define TERMS_AND_COND_FB_ERROR1    NSLocalizedString(@"You must agree to LifeTrak’s", nil)
#define TERMS_AND_COND_FB_ERROR2    NSLocalizedString(@"TERMS & CONDITIONS", nil)
#define TERMS_AND_COND_FB_ERROR3    NSLocalizedString(@"before proceeding with Facebook sign up", nil)
#define TERMS_AND_COND_ERROR    NSLocalizedString(@"You must agree to LifeTrak’s TERMS & CONDITIONS before proceeding", nil)
#define TERMS_AND_COND_ERROR1    NSLocalizedString(@"You must agree to LifeTrak’s", nil)
#define TERMS_AND_COND_ERROR2    NSLocalizedString(@"TERMS & CONDITIONS", nil)
#define TERMS_AND_COND_ERROR3    NSLocalizedString(@"before proceeding", nil)
#define CHANGE_PROFILE_PIC      NSLocalizedString(@"CHANGE PROFILE PICTURE", nil)
#define LS_AGREE                NSLocalizedString(@"AGREE", nil)
#define REGISTERING_ACCOUNT     NSLocalizedString(@"Registering account", nil)
#define PLEASE_WAIT             NSLocalizedString(@"Please wait", nil)
#define WELCOME_USER            NSLocalizedString(@"Welcome,", nil)
#define SETUP_5_EASY_STEPS      NSLocalizedString(@"Set up your LifeTrak app\nin 5 easy steps", nil)
#define FIND_WATCH              NSLocalizedString(@"FIND WATCH", nil)
#define PAIR_WATCH              NSLocalizedString(@"PAIR WITH WATCH", nil)
#define SYNC_DATA               NSLocalizedString(@"SYNC DATA", nil)
#define ADD_DETAILS             NSLocalizedString(@"ADD DETAILS", nil)
#define BACKUP_DATA             NSLocalizedString(@"BACKUP DATA", nil)


#define FIND_WATCH_TITLE              NSLocalizedString(@"Find watch", nil)
#define PAIR_WATCH_TITLE              NSLocalizedString(@"Pair with watch", nil)
#define SYNC_DATA_TITLE               NSLocalizedString(@"Sync data", nil)
#define ADD_DETAILS_TITLE             NSLocalizedString(@"Add details", nil)
#define BACKUP_DATA_TITLE             NSLocalizedString(@"Backup data", nil)

#define PLEASE_MAKE_SURE        NSLocalizedString(@"Please make sure your phone’s wifi and bluetooth are enabled", nil)
#define PLEASE_ENABLE_BLE       NSLocalizedString(@"Please enable bluetooth to continue with setup process", nil)
#define LS_DENY                 NSLocalizedString(@"DENY", nil)
#define LS_ALLOW                NSLocalizedString(@"ALLOW", nil)
#define TURN_ON_BLE             NSLocalizedString(@"Turn on watch bluetooth", nil)
#define PRESS_AND_HOLD_INSTRUCTION    NSLocalizedString(@"Press and hold the lower right button on your watch and release when the bluetooth symbol flashes on the watch face", nil)
#define FINDING_WATCH           NSLocalizedString(@"Finding watch", nil)
#define NO_WATCH_DETECTED       NSLocalizedString(@"No watch detected", nil)
#define MAKE_SURE_BLE_ENABLED   NSLocalizedString(@"Make sure watch bluetooth is enabled. If there is no bluetooth icon on the display, press the lower right button to enable bluetooth and try again.", nil)
#define CHECK_BATTERY_LEVEL     NSLocalizedString(@"Check watch battery level.", nil)
#define KEEP_PHONE_AND_WATCH_RANGE     NSLocalizedString(@"Keep watch and phone within bluetooth range.", nil)
#define IF_STILL_CANNOT_BE_DETECTED    NSLocalizedString(@"If watch still cannot be detected, hold down the lower right button until the message ‘pairing info removed’ appears on the display and try again.", nil)

#define SYNCING_DETAILS_FAILED        NSLocalizedString(@"An error occured while syncing. Unable to save modified details to watch.", nil)
#define SYNCING_DETAILS_SUGGESTION    NSLocalizedString(@"You can modify your details on app settings.", nil)

#define LS_CANCEL               NSLocalizedString(@"CANCEL", nil)
#define LS_TRY_AGAIN_CAPS       NSLocalizedString(@"TRY AGAIN", nil)
#define DETECTED_WATCH          NSLocalizedString(@"DETECTED WATCH", nil)
#define DETECTED_WATCHES        NSLocalizedString(@"DETECTED WATCHES", nil)
#define CONNECT_WATCH           NSLocalizedString(@"Connect watch", nil)
#define CONNECT_WATCH_CAPS      NSLocalizedString(@"CONNECT WATCH", nil)
#define OTHER_PRODUCTS          NSLocalizedString(@"OTHER PRODUCTS FROM LIFETRAK", nil)
#define OTHER_PRODUCT           NSLocalizedString(@"OTHER PRODUCT FROM LIFETRAK", nil)

#define SIGNUP_FB               NSLocalizedString(@"   SIGN UP WITH FACEBOOK", nil)
#define SIGNIN_FB               NSLocalizedString(@"   LOG IN WITH FACEBOOK", nil)

#define SIGNUP                  NSLocalizedString(@"SIGN UP", nil)
#define SIGNIN                  NSLocalizedString(@"LOG IN", nil)


#define SIGNUP_SMALL            NSLocalizedString(@"Sign up", nil)
#define SIGNIN_SMALL            NSLocalizedString(@"Log in", nil)

#define CREATE_ACCOUNT          NSLocalizedString(@"CREATE ACCOUNT", nil)


#define FEATURE_ECG_HR          NSLocalizedString(@"ECG Heart Rate", nil)
#define FEATURE_APP_CONNECTED   NSLocalizedString(@"App Connected", nil)
#define FEATURE_SLEEPTRAK       NSLocalizedString(@"SleepTrak", nil)
#define FEATURE_PRECISE_TRACKING NSLocalizedString(@"Precise Tracking", nil)
#define FEATURE_ALWAYS_ON       NSLocalizedString(@"Always on", nil)
#define FEATURE_BATTERY_WATER   NSLocalizedString(@"Long Battery Life and Waterproof", nil)
#define FEATURE_COMFITBANDS     NSLocalizedString(@"Customizable ComfortFit Bands", nil)

#define PAIRING_WATCH           NSLocalizedString(@"Pairing watch", nil)
#define PAIRING_FAILED          NSLocalizedString(@"Pairing failed", nil)
#define SYNCING_WATCH_DATA      NSLocalizedString(@"Syncing watch data", nil)
#define WATCH_SYNC_FAILED       NSLocalizedString(@"Watch sync failed", nil)
#define SYNCING_SUCCESSFUL      NSLocalizedString(@"Sync successful", nil)

#define ENTER_PERSONAL_DETAILS  NSLocalizedString(@"ENTER PERSONAL DETAILS", nil)
#define PERSONAL_DETAILS_DESC   NSLocalizedString(@"This information will be used to calculate your fitness results. All fields are required.", nil)
#define LS_CONTINUE             NSLocalizedString(@"Continue", nil)
#define LS_CONTINUE_CAPS        NSLocalizedString(@"CONTINUE", nil)
#define ERROR_SYNCING_TO_CLOUD  NSLocalizedString(@"Syncing to cloud", nil)
#define ERROR_BACKUP_FAILED     NSLocalizedString(@"Backup failed", nil)
#define ERROR_CHECK_YOUR_INTERNET  NSLocalizedString(@"Check your internet connection", nil)


#define ERROR_FB_TITLE              NSLocalizedString(@"Facebook Error", nil)
#define ERROR_FB_SIGNUP_CANCELLED   NSLocalizedString(@"Facebook connect was cancelled.", nil)
#define ERROR_FB_LOGIN_CANCELLED    NSLocalizedString(@"Facebook connect was cancelled.", nil)
#define ERROR_FB_MESSAGE            NSLocalizedString(@"An error occured while connecting to Facebook.", nil)

#define RECOMMENDED_GOALS       NSLocalizedString(@"RECOMMENDED GOALS", nil)
#define TODAYS_DATA             NSLocalizedString(@"TODAY'S DATA", nil)
#define SEE_FULL_GRAPH          NSLocalizedString(@"SEE FULL GRAPH", nil)

#define GET_STARTED             NSLocalizedString(@"GET STARTED", nil)

#define CONNECTED               NSLocalizedString(@"CONNECTED", nil)

#define SYNCING_SETTINGS        NSLocalizedString(@"Settings", nil)
#define SYNCING_FITNESS_DATA    NSLocalizedString(@"Fitness data", nil)
#define SYNCING_GOALS           NSLocalizedString(@"Goals", nil)
#define SYNCING_WORKOUT         NSLocalizedString(@"Workout", nil)
#define SYNCING_SLEEP           NSLocalizedString(@"Sleep", nil)
#define SYNCING_LIGHT           NSLocalizedString(@"Light", nil)

#define CLOUD_SYNC              NSLocalizedString(@"Cloud Sync", nil)
#define CLOUD_SYNC_SUBLABEL     NSLocalizedString(@"backing up data to cloud", nil)

#define WATCH_ALREADY_ADDED         NSLocalizedString(@"Watch already added", nil)
#define WATCH_ALREADY_ADDED_DESC    NSLocalizedString(@"The watch you are trying to add is already on your account.", nil)



#define FORGOT_YOUR_PASSWORD    NSLocalizedString(@"FORGOT YOUR PASSWORD?", nil)
#define REMEMBER_ME             NSLocalizedString(@"Remember me", nil)

#define PAIRED_MESSAGE                  NSLocalizedString(@"Tips – check that…\n- Bluetooth on phone/tablet is on.\n- Phone/tablet battery life > 20%\n- Bluetooth active on watch. Press and hold bottom right button to activate.", nil)//NSLocalizedString(@"HELPFUL TIPS:\n- Make sure that Bluetooth is active on your phone/tablet.\n- Make sure your phone/tablet has more than 20% battery life, as a low battery on your device may cause syncing issues.", nil)

#define WATCH_DATA_NOT_SYNCING          NSLocalizedString(@"Unsuccessful data sync between watch & app.", nil)//NSLocalizedString(@"We’re sorry. Your watch data is not syncing to your app.\n\nIs your Bluetooth active?\nPlease make sure that the Bluetooth is active on your watch. Press & hold the bottom, right button to activate.", nil)

#define USER_GUIDES_LINK             @"https://lifetrakusa.com/support/user-guides/"
                                  //@"http://lifetrakusa.com/user-guides/"
#define VIDEO_TUTORIALS_LINK        @"http://lifetrakusa.com/support/video-tutorials/"
#define ANSWERS_FROM_COMMUNITY_LINK @"https://lifetrak.zendesk.com/hc/en-us"

#endif
