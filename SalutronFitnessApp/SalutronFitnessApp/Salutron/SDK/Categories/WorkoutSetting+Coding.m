//
//  WorkoutSetting+Coding.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/26/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import "WorkoutSetting+Coding.h"

#define HR_LOG_RATE             @"hr_log_rate"
#define AUTO_SPLIT_TYPE         @"auto_split_type"
#define AUTO_SPLIT_THRESHOLD    @"auto_split_threshold"
#define ZONE_TRAIN_TYPE         @"zone_train_type"
#define ZONE_0_UPPER            @"zone_0_upper"
#define ZONE_0_LOWER            @"zone_0_lower"
#define ZONE_1_LOWER            @"zone_1_lower"
#define ZONE_2_LOWER            @"zone_2_lower"
#define ZONE_3_LOWER            @"zone_3_lower"
#define ZONE_4_LOWER            @"zone_4_lower"
#define ZONE_5_LOWER            @"zone_5_lower"
#define ZONE_5_UPPER            @"zone_5_upper"
#define RESERVED                @"reserved"
#define DATABASE_USAGE          @"database_usage"
#define DATABASE_USAGE_MAX      @"database_usage_max"
#define RECONNECT_TIMEOUT       @"reconnect_timeout"

@implementation WorkoutSetting (Coding)

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.HRLogRate          = [aDecoder decodeInt32ForKey:HR_LOG_RATE];
        self.autoSplitType      = [aDecoder decodeInt32ForKey:AUTO_SPLIT_TYPE];
        self.autoSplitThreshold = [aDecoder decodeInt32ForKey:AUTO_SPLIT_THRESHOLD];
        self.zoneTrainType      = [aDecoder decodeInt32ForKey:ZONE_TRAIN_TYPE];
        self.zone0Upper         = [aDecoder decodeInt32ForKey:ZONE_0_UPPER];
        self.zone0Lower         = [aDecoder decodeInt32ForKey:ZONE_0_LOWER];
        self.zone1Lower         = [aDecoder decodeInt32ForKey:ZONE_1_LOWER];
        self.zone2Lower         = [aDecoder decodeInt32ForKey:ZONE_2_LOWER];
        self.zone3Lower         = [aDecoder decodeInt32ForKey:ZONE_3_LOWER];
        self.zone4Lower         = [aDecoder decodeInt32ForKey:ZONE_4_LOWER];
        self.zone5Lower         = [aDecoder decodeInt32ForKey:ZONE_5_LOWER];
        self.zone5Upper         = [aDecoder decodeInt32ForKey:ZONE_5_UPPER];
        self.reserved           = [aDecoder decodeInt32ForKey:RESERVED];
        self.databaseUsage      = [aDecoder decodeInt32ForKey:DATABASE_USAGE];
        self.databaseUsageMax   = [aDecoder decodeInt32ForKey:DATABASE_USAGE_MAX];
        self.reconnectTimeout   = [aDecoder decodeInt32ForKey:RECONNECT_TIMEOUT];
        
        return self;
    }
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt32:self.HRLogRate          forKey:HR_LOG_RATE];
    [aCoder encodeInt32:self.autoSplitType      forKey:AUTO_SPLIT_TYPE];
    [aCoder encodeInt32:self.autoSplitThreshold forKey:AUTO_SPLIT_THRESHOLD];
    [aCoder encodeInt32:self.zoneTrainType      forKey:ZONE_TRAIN_TYPE];
    [aCoder encodeInt32:self.zone0Upper         forKey:ZONE_0_UPPER];
    [aCoder encodeInt32:self.zone0Lower         forKey:ZONE_0_LOWER];
    [aCoder encodeInt32:self.zone1Lower         forKey:ZONE_1_LOWER];
    [aCoder encodeInt32:self.zone2Lower         forKey:ZONE_2_LOWER];
    [aCoder encodeInt32:self.zone3Lower         forKey:ZONE_3_LOWER];
    [aCoder encodeInt32:self.zone4Lower         forKey:ZONE_4_LOWER];
    [aCoder encodeInt32:self.zone5Lower         forKey:ZONE_5_LOWER];
    [aCoder encodeInt32:self.zone5Upper         forKey:ZONE_5_UPPER];
    [aCoder encodeInt32:self.reserved           forKey:RESERVED];
    [aCoder encodeInt32:self.databaseUsage      forKey:DATABASE_USAGE];
    [aCoder encodeInt32:self.databaseUsageMax   forKey:DATABASE_USAGE_MAX];
    [aCoder encodeInt32:self.reconnectTimeout   forKey:RECONNECT_TIMEOUT];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    [copy setHRLogRate:self.HRLogRate];
    [copy setAutoSplitType:self.autoSplitType];
    [copy setAutoSplitThreshold:self.autoSplitThreshold];
    [copy setZoneTrainType:self.zoneTrainType];
    [copy setZone0Upper:self.zone0Upper];
    [copy setZone0Lower:self.zone0Lower];
    [copy setZone1Lower:self.zone1Lower];
    [copy setZone2Lower:self.zone2Lower];
    [copy setZone3Lower:self.zone3Lower];
    [copy setZone4Lower:self.zone4Lower];
    [copy setZone5Lower:self.zone5Lower];
    [copy setZone5Upper:self.zone5Upper];
    [copy setReserved:self.reserved];
    [copy setDatabaseUsage:self.databaseUsage];
    [copy setDatabaseUsageMax:self.databaseUsageMax];
    [copy setReconnectTimeout:self.reconnectTimeout];
    
    return copy;
}

@end
