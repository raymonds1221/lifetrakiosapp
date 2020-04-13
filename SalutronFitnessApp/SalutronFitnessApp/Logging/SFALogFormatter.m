//
//  SFALogFormatter.m
//  SalutronFitnessApp
//
//  Created by Darwin Bautista on 6/26/15.
//  Copyright (c) 2015 Salutron. All rights reserved.
//

#import "SFALogFormatter.h"

@interface SFALogFormatter ()

@property (nonatomic) NSUInteger calendarUnitFlags;
@property (nonatomic, copy) NSString *processName;
@property (nonatomic, copy) NSString *processID;

@end


@implementation SFALogFormatter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _processName = [NSProcessInfo processInfo].processName;
        _processID = [[NSString alloc] initWithFormat:@"%d", getpid()];
        _calendarUnitFlags = NSCalendarUnitYear   |
                             NSCalendarUnitMonth  |
                             NSCalendarUnitDay    |
                             NSCalendarUnitHour   |
                             NSCalendarUnitMinute |
                             NSCalendarUnitSecond;
    }
    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    // Don't format captured log messages
    if (logMessage->_context == SFALogContextCaptured) {
        return logMessage->_message;
    }

    NSMutableString *message = [[NSMutableString alloc] init];

    // Implementation copied from DDTTYLogger.m:
    // Calculate timestamp.
    // The technique below is faster than using NSDateFormatter.
    if (logMessage->_timestamp) {

        NSDateComponents *components = [[NSCalendar autoupdatingCurrentCalendar] components:_calendarUnitFlags fromDate:logMessage->_timestamp];

        NSTimeInterval epoch = [logMessage->_timestamp timeIntervalSinceReferenceDate];
        int milliseconds = (int)((epoch - floor(epoch)) * 1000);

        [message appendFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld.%03d ", // yyyy-MM-dd HH:mm:ss.SSS
            (long)components.year,
            (long)components.month,
            (long)components.day,
            (long)components.hour,
            (long)components.minute,
            (long)components.second, milliseconds];
    }

    // Get string representation of log flag
    NSString *logFlag = @"";
    switch (logMessage->_flag) {
        case DDLogFlagError:
            logFlag = @"error";
            break;
        case DDLogFlagWarning:
            logFlag = @"warning";
            break;
        case DDLogFlagInfo:
            logFlag = @"info";
            break;
        case DDLogFlagDebug:
            logFlag = @"debug";
            break;
        case DDLogFlagVerbose:
            logFlag = @"verbose";
    }

    [message appendFormat:@"%@[%@:%@] %@ (line %u) %@: ",
        _processName, _processID, logMessage->_threadID,
        logMessage->_function, (unsigned)logMessage->_line, logFlag];

    if (logMessage->_tag) {
        [message appendFormat:@"[%@] ", logMessage->_tag];
    }

    // Add extra newline character to make the logs more readable from the console.
    // Note that this doesn't affect the file logs.
    [message appendFormat:@"%@\n", logMessage->_message];

    return message;
}

@end
