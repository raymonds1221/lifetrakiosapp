//
//  SalutronUserProfile+SalutronUserProfileCategory.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/13/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SalutronUserProfile+SalutronUserProfileCategory.h"

@implementation SalutronUserProfile (SalutronUserProfileCategory)

- (id) initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.birthday = [aDecoder decodeObjectForKey:BIRTHDAY];
        self.gender = [aDecoder decodeIntForKey:GENDER];
        self.unit = [aDecoder decodeIntForKey:UNIT];
        self.sensitivity = [aDecoder decodeIntForKey:SENSITIVITY];
        self.weight = [aDecoder decodeIntForKey:WEIGHT];
        self.height = [aDecoder decodeIntForKey:HEIGHT];
        return self;
    }
    return nil;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.birthday forKey:BIRTHDAY];
    [aCoder encodeInt:self.gender forKey:GENDER];
    [aCoder encodeInt:self.unit forKey:UNIT];
    [aCoder encodeInt:self.sensitivity forKey:SENSITIVITY];
    [aCoder encodeInt:self.weight forKey:WEIGHT];
    [aCoder encodeInt:self.height forKey:HEIGHT];
}

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    
    [copy setBirthday:self.birthday];
    [copy setGender:self.gender];
    [copy setUnit:self.unit];
    [copy setSensitivity:self.sensitivity];
    [copy setWeight:self.weight];
    [copy setHeight:self.height];
    
    return copy;
}

- (BOOL) isEqualToUserProfile:(SalutronUserProfile *)userProfile {
    if(self.birthday.day == userProfile.birthday.day &&
        self.birthday.month == userProfile.birthday.month &&
        self.birthday.year == userProfile.birthday.year &&
        self.gender == userProfile.gender &&
        self.unit == userProfile.unit &&
        self.sensitivity == userProfile.sensitivity &&
        self.weight == userProfile.weight &&
        self.height == userProfile.height)
        return YES;
    return NO;
}

@end
