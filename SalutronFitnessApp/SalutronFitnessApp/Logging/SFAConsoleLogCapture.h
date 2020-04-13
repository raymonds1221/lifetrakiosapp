//
//  SFAConsoleLogCapture.h
//  SalutronFitnessApp
//
//  Created by Darwin Bautista on 6/28/15.
//  Copyright (c) 2015 Salutron. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A `SFAConsoleLogCapture` object captures data from the specified file descriptor
 and forwards the data to the underlying logging framework.

 At the same time, the captured data is written to its original destination as well
 (the file originally referred to by the specified file descriptor).

 @warning This works by piping the inputs to the specified file descriptor. In order words, input is redirected to the pipe.
 */
@interface SFAConsoleLogCapture : NSObject

/**
 A file handle which wraps the file originally referred to by the specified file descriptor.
 */
@property (nonatomic, strong, readonly) NSFileHandle *originalFileHandle;


/**
 Initializes an `SFAConsoleLogCapture` object with the specified file descriptor

 @param fileDescriptor The file descriptor to capture data from

 @return The newly-initialized capture object
 */
- (instancetype)initWithFileDescriptor:(int)fileDescriptor NS_DESIGNATED_INITIALIZER;

@end
