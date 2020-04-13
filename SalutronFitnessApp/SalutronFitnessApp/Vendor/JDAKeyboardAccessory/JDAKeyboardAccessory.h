//
//  JDAKeyboardAccessory.h
//  WomensCircle
//
//  Created by John Dwaine Alingarog on 11/15/13.
//  Copyright (c) 2013 John Dwaine Alingarog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDAKeyboardAccessory : UIToolbar

@property (strong, nonatomic) id previousView;
@property (strong, nonatomic) id nextView;
@property (strong, nonatomic) id currentView;

- (id)initWithPrevNextDoneAccessoryWithBarStyle:(UIBarStyle)barStyle;
- (id)initWithDoneAccessoryWithBarStyle:(UIBarStyle)barStyle;

@end
