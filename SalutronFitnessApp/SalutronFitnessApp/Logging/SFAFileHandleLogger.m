//
//  SFAFileHandleLogger.m
//  SalutronFitnessApp
//
//  Created by Darwin Bautista on 6/28/15.
//  Copyright (c) 2015 Salutron. All rights reserved.
//

#import "SFAFileHandleLogger.h"

@interface SFAFileHandleLogger ()

@property (nonatomic, weak) NSFileHandle *fileHandle;

@end


@implementation SFAFileHandleLogger

- (instancetype)initWithFileHandle:(NSFileHandle *)fileHandle
{
    self = [super init];
    if (self) {
        _fileHandle = fileHandle;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFileHandle:[NSFileHandle fileHandleWithStandardError]];
}

- (void)logMessage:(DDLogMessage *)logMessage
{
    // Ignore captured logs
    if (logMessage->_context == SFALogContextCaptured) {
        return;
    }
    NSString *message = [_logFormatter formatLogMessage:logMessage];
    [_fileHandle writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
