//
//  SFALogger.m
//  SalutronFitnessApp
//
//  Created by Darwin Bautista on 6/26/15.
//  Copyright (c) 2015 Salutron. All rights reserved.
//

#import "SFALoggingFramework.h"
#import "SFALogFormatter.h"
#import "SFAConsoleLogCapture.h"
#import "SFAFileHandleLogger.h"

NSString * const Status_toString[] = {
    [NO_ERROR] = @"NO_ERROR",
    [UPDATE] = @"UPDATE",
    [ERROR_CHECKSUM] = @"ERROR_CHECKSUM",
    [ERROR_DATA] = @"ERROR_DATA",
    [ERROR_DISCONNECT] = @"ERROR_DISCONNECT",
    [ERROR_DISCOVER] = @"ERROR_DISCOVER",
    [ERROR_INTERNAL] = @"ERROR_INTERNAL",
    [ERROR_NOT_CONNECTED] = @"ERROR_NOT_CONNECTED",
    [ERROR_NOT_FOUND] = @"ERROR_NOT_FOUND",
    [ERROR_NOT_INITIALIZED] = @"ERROR_NOT_INITIALIZED",
    [ERROR_NOT_SUPPORTED] = @"ERROR_NOT_SUPPORTED",
    [ERROR_NOTIFICATION] = @"ERROR_NOTIFICATION",
    [ERROR_TIMEOUT] = @"ERROR_TIMEOUT",
    [ERROR_UPDATE] = @"ERROR_UPDATE",
    [ERROR_WRITE] = @"ERROR_WRITE",
    [ERROR_DEVICE_NOT_SUPPORTED] = @"ERROR_DEVICE_NOT_SUPPORTED",
    [WARNING_BUSY] = @"WARNING_BUSY",
    [WARNING_CONNECTED] = @"WARNING_CONNECTED",
    [WARNING_NOT_CONNECTED] = @"WARNING_NOT_CONNECTED",
    [WARNING_NOT_READY] = @"WARNING_NOT_READY",
    [WARNING_INVALID_ARGUMENT] = @"WARNING_INVALID_ARGUMENT",
    [ERROR_UNKNOWN] = @"ERROR_UNKNOWN",
};


@interface SFALoggingFramework ()

@property (nonatomic, strong) DDLogFileManagerDefault *logFileManager;

@property (nonatomic, strong) SFAConsoleLogCapture *stdoutCapture;
@property (nonatomic, strong) SFAConsoleLogCapture *stderrCapture;

- (void)_addLoggers;

@end


@implementation SFALoggingFramework

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static SFALoggingFramework *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _addLoggers];
    }
    return self;
}

- (void)_addLoggers
{
    SFALogFormatter *logFormatter = [[SFALogFormatter alloc] init];

    //--- File logging ---
    _logFileManager = [[DDLogFileManagerDefault alloc] init];

    //_logFileManager.maximumNumberOfLogFiles = 7;

    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:_logFileManager];
    fileLogger.logFormatter = logFormatter;
    // Set max log file size to 10 MiB
    fileLogger.maximumFileSize = 10 * 1024 * 1024;
    // Disable time-based log rolling // = 0;
    fileLogger.rollingFrequency = (3600.0 * 24.0) * 7;
    [fileLogger logFileManager].maximumNumberOfLogFiles = 0;
    // Make sure that each "session" would have a different log file
    //fileLogger.doNotReuseLogFiles = YES;

    [DDLog addLogger:fileLogger];

    //--- Console logging ---
    _stdoutCapture = [[SFAConsoleLogCapture alloc] initWithFileDescriptor:STDOUT_FILENO];
    _stderrCapture = [[SFAConsoleLogCapture alloc] initWithFileDescriptor:STDERR_FILENO];

    SFAFileHandleLogger *consoleLogger = [[SFAFileHandleLogger alloc] initWithFileHandle:_stderrCapture.originalFileHandle];
    consoleLogger.logFormatter = logFormatter;
    [DDLog addLogger:consoleLogger];
}

#pragma mark - Properties

- (NSArray *)logFilePaths
{
    return [self.logFileManager sortedLogFilePaths];
}

@end
