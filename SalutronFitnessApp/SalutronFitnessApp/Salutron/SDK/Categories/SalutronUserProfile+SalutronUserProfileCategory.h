//
//  SalutronUserProfile+SalutronUserProfileCategory.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 11/13/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SalutronUserProfile.h"

#define BIRTHDAY @"birthday"
#define GENDER @"gender"
#define UNIT @"unit"
#define SENSITIVITY @"sensitivity"
#define WEIGHT @"weight"
#define HEIGHT @"height"

@interface SalutronUserProfile (SalutronUserProfileCategory) <NSCoding, NSCopying>

-(BOOL) isEqualToUserProfile:(SalutronUserProfile *) userProfile;

@end
