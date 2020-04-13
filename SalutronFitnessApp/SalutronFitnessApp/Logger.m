//
//  Logger.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 5/28/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "Logger.h"

@implementation Logger

void QLog (NSString *format, ...)
{
	va_list argList;
	va_start (argList, format);
	NSString *message = [[NSString alloc] initWithFormat: format
                                               arguments: argList];
	printf ("%s\t\n", [message UTF8String]);
	va_end  (argList);
}

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

@end
