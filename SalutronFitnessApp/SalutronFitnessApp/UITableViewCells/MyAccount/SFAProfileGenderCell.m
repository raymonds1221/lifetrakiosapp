//
//  SFAProfileGenderCell.m
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/10/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAProfileGenderCell.h"

#import "SalutronUserProfile+Data.h"
#import "SalutronUserProfile.h"
#import "DeviceEntity+Data.h"
#import "UserProfileEntity+Data.h"

@interface SFAProfileGenderCell ()

- (IBAction)buttonMaleTouchedUp:(id)sender;
- (IBAction)buttonFemaleTouchedUp:(id)sender;

@end

@implementation SFAProfileGenderCell

#pragma mark - Public instance methods
- (void)setGenderContent
{
    //SalutronUserProfile *_userProfile   = [SalutronUserProfile getData];
    Gender _gender                      = self.salutronUserProfile.gender;
    switch (_gender) {
        case MALE:
            //[self buttonMaleTouchedUp:self];
            self.buttonMale.selected            = YES;
            self.buttonFemale.selected          = NO;
            break;
        case FEMALE:
            self.buttonMale.selected            = NO;
            self.buttonFemale.selected          = YES;
            //[self buttonFemaleTouchedUp:self];
            break;
        default:
            break;
    }
}

#pragma mark - IBActions
- (IBAction)buttonMaleTouchedUp:(id)sender
{
    self.buttonMale.selected            = YES;
    self.buttonFemale.selected          = NO;
    //SalutronUserProfile *_userProfile   = [SalutronUserProfile getData];
    self.salutronUserProfile.gender                 = MALE;
    //[SalutronUserProfile saveWithSalutronUserProfile:_userProfile];
    //DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    //[UserProfileEntity userProfileWithSalutronUserProfile:self.salutronUserProfile forDeviceEntity:deviceEntity];
    [self.delegate genderValueChangedWithSalutronUserProfile:self.salutronUserProfile];
}

- (IBAction)buttonFemaleTouchedUp:(id)sender
{
    self.buttonMale.selected            = NO;
    self.buttonFemale.selected          = YES;
    //SalutronUserProfile *_userProfile   = [SalutronUserProfile getData];
    self.salutronUserProfile.gender                 = FEMALE;
    //[SalutronUserProfile saveWithSalutronUserProfile:self.salutronUserProfile];
    //DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
    //[UserProfileEntity userProfileWithSalutronUserProfile:self.salutronUserProfile forDeviceEntity:deviceEntity];
    [self.delegate genderValueChangedWithSalutronUserProfile:self.salutronUserProfile];}

@end
