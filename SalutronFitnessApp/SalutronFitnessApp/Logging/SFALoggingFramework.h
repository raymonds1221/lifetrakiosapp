//
//  SFALogger.h
//  SalutronFitnessApp
//
//  Created by Darwin Bautista on 6/26/15.
//  Copyright (c) 2015 Salutron. All rights reserved.
//

#import <Foundation/Foundation.h>
// Expose DDLog* macros
#import <CocoaLumberjack/CocoaLumberjack.h>

extern NSString * const Status_toString[];

/**
 Log Context constants

 These constants can be used to segregate or classify the log messages.
 For future use, new constants could be added to identify the different
 logical components of the app.

 Currently, it is used for identifying logs which are captured from stdout and stderr.
 */
typedef NS_ENUM(NSInteger, SFALogContext) {
    /**
     The default context of CocoaLumberjack log messages
     */
    SFALogContextDefault = 0,
    /**
     Used by logs captured from stdout and stderr
     */
    SFALogContextCaptured
};


/**
 `SFALoggingFramework` is a singleton which configures the underlying logging framework.
 */
@interface SFALoggingFramework : NSObject

/**
 An array containing the log file paths sorted by date (newest first)
 */
@property (nonatomic, copy, readonly) NSArray *logFilePaths;

/**
 Returns the `SFALoggingFramework` singleton object
 */
+ (instancetype)sharedInstance;

@end
