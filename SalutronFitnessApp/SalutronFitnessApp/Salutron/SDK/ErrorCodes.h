//
//  ErrorCodes.h
//  BLEManager
//
//  Created by Herman on 2/20/13.
//  Copyright (c) 2013 GV Concepts Inc. All rights reserved.
//
//  All information and materials contained herein are owned by GV Concepts, Inc.
//  and is protected by U.S. and international copyright laws.
//  All use, disclosure, dissemination, transfer, publication or reproduction
//  of these materials, in whole or in part, is prohibited, unless authorized
//  in writing by GV Concepts, Inc.
//  If copies of these materials are made with written authorization of
//  GV Concepts, Inc, all copies must contain this notice.
//

typedef enum {
    NO_ERROR,                   // No error.
    
    UPDATE,                     // Update on progress.
    
    ERROR_CHECKSUM,             // Invalid checksum. 
    
    ERROR_DATA,                 // Data received contains error (invalid fields).
    
    ERROR_DISCONNECT,           // Error occurred while disconnecting from a device.
    
    ERROR_DISCOVER,             // Error occurred while discovering service(s)/characteristic(s) on the device.
    
    ERROR_INTERNAL,             // Internal error. BUGS.
        
    ERROR_NOT_CONNECTED,        // Communicating with a device that is not connected.
    
    ERROR_NOT_FOUND,            // Supported service(s)/characteristic(s) not found on the connected device.
    
    ERROR_NOT_INITIALIZED,      // Not initialized, maybe the user did not use the sharedInstance.
    
    ERROR_NOT_SUPPORTED,        // The iOS device is not supported.
    
    ERROR_NOTIFICATION,         // Error occurred while changing the notification state of a characteristic.
    
    ERROR_TIMEOUT,              // Timeout while waiting for response.
    
    ERROR_UPDATE,               // Error occurred while updating a characteristic.
    
    ERROR_WRITE,                // Error occurred while writing to a characteristic.
    
    ERROR_DEVICE_NOT_SUPPORTED, // SDK will return this erro if the command is not supported
    
    WARNING_BUSY,               // SDK is currently busy handing another command.
    
    WARNING_CONNECTED,          // Attempting to remove a connected device from the connected peripherals array.
                                // Attempting to connect to a device that is already connected.
    
    WARNING_NOT_CONNECTED,      // Attempting disconnecting a device that is not connected.
                                // Attempting to communicate with a peripheral that is not connected.
    
    WARNING_NOT_READY,          // The library is not ready.
    
    WARNING_INVALID_ARGUMENT,   // Arguments used in methods are invalid. 
    
    ERROR_UNKNOWN,              // Unknown error.
} Status;