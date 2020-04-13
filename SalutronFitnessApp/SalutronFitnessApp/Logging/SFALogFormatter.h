//
//  SFALogFormatter.h
//  SalutronFitnessApp
//
//  Created by Darwin Bautista on 6/26/15.
//  Copyright (c) 2015 Salutron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

/**
 `SFALogFormatter` implements the `DDLogFormatter` protocol. This formatter does not maintain any internal state and is thread-safe.
 */
@interface SFALogFormatter : NSObject <DDLogFormatter>

@end
