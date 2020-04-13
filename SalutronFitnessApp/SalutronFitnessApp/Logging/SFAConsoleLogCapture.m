//
//  SFAConsoleLogCapture.m
//  SalutronFitnessApp
//
//  Created by Darwin Bautista on 6/28/15.
//  Copyright (c) 2015 Salutron. All rights reserved.
//

#import "SFAConsoleLogCapture.h"

#import <unistd.h>

@interface SFAConsoleLogCapture ()

// Redeclare as readwrite
@property (nonatomic, strong, readwrite) NSFileHandle *originalFileHandle;

@property (nonatomic) dispatch_queue_t ddLoggingQueue;
@property (nonatomic) int capturedFileDescriptor;
@property (nonatomic, strong) NSPipe *pipe;

- (void)_initPipe;
- (void)_redirectInputToPipe;

@end

@implementation SFAConsoleLogCapture

- (instancetype)initWithFileDescriptor:(int)fileDescriptor
{
    self = [super init];
    if (self) {
        _capturedFileDescriptor = fileDescriptor;
        // Use this to synchronize with CocoaLumberjack
        _ddLoggingQueue = [DDLog loggingQueue];
        [self _redirectInputToPipe];
    }
    return self;
}

- (void)dealloc
{
    if (_originalFileHandle != nil) {
        // Redirect input from captured file descriptor back to original file handle
        dup2(_originalFileHandle.fileDescriptor, _capturedFileDescriptor);
        _originalFileHandle = nil;
        _pipe.fileHandleForReading.readabilityHandler = nil;
        _pipe = nil;
    }
}

- (void)_redirectInputToPipe
{
    // Backup captured file descriptor
    int originalFd = dup(_capturedFileDescriptor);
    if (originalFd == -1) {
        return;
    }
    _originalFileHandle = [[NSFileHandle alloc] initWithFileDescriptor:originalFd closeOnDealloc:YES];

    [self _initPipe];

    // Redirect input from captured file descriptor to the write-end of the pipe
    if (dup2(_pipe.fileHandleForWriting.fileDescriptor, _capturedFileDescriptor) == -1) {
        // Unable to redirect input, so no need for the backup fd
        _originalFileHandle = nil;
    }
}

- (void)_initPipe
{
    __weak typeof(self) weakSelf = self;
    _pipe = [NSPipe pipe];
    // Set readabilityHandler block which is called whenever data can be read from the pipe
    _pipe.fileHandleForReading.readabilityHandler = ^(NSFileHandle *fileHandle) {

        NSData *data = fileHandle.availableData;

        // Forward captured logs to their original destination (console)
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(strongSelf->_ddLoggingQueue, ^{
            [strongSelf->_originalFileHandle writeData:data];
        });

        // Forward captured logs to CocoaLumberjack.
        // These are already formatted so use SFALogContextCaptured.
        NSString *logs = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        DDLogMessage *logMessage = [[DDLogMessage alloc] initWithMessage:logs
                                                                   level:DDLogLevelVerbose
                                                                    flag:DDLogFlagDebug
                                                                 context:SFALogContextCaptured
                                                                    file:@"SFAConsoleLogCapture"
                                                                function:nil
                                                                    line:0
                                                                     tag:nil
                                                                 options:(DDLogMessageOptions)0
                                                               timestamp:nil];
        [DDLog log:YES message:logMessage];
    };
}

@end
