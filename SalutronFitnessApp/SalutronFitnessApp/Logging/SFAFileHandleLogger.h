//
//  SFAFileHandleLogger.h
//  SalutronFitnessApp
//
//  Created by Darwin Bautista on 6/28/15.
//  Copyright (c) 2015 Salutron. All rights reserved.
//

#import "DDLog.h"

/**
 `SFAFileHandleLogger` is a CocoaLumberjack logger which write log messages to the specified file handle
 */
@interface SFAFileHandleLogger : DDAbstractLogger

/**
 Initializes a `SFAFileHandleLogger` object with the specified file handle

 @param fileHandle The file handle to write logs to. The logger will only weakly-reference the file handle.

 @return The initialized `SFAFileHandleLogger` object
 */
- (instancetype)initWithFileHandle:(NSFileHandle *)fileHandle NS_DESIGNATED_INITIALIZER;

@end
