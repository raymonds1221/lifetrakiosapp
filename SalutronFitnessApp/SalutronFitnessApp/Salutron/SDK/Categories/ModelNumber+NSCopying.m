//
//  ModelNumber+NSCopying.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 1/28/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "ModelNumber+NSCopying.h"

@implementation ModelNumber (NSCopying)

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    
    [copy setNumber:self.number];
    [copy setString:self.string];
    
    return copy;
}

@end
