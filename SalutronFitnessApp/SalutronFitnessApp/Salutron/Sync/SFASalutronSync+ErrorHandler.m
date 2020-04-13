//
//  SFASalutronSync+ErrorHandler.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 7/17/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFASalutronSync+ErrorHandler.h"

@implementation SFASalutronSync (ErrorHandler)

#pragma mark - Error handler

- (void)handleError:(Status)status
{
    DDLogInfo(@"-----> %@", [ErrorCodeToStringConverter convertToString:status]);
    
    if ([self.delegate conformsToProtocol:@protocol(SFASalutronSyncDelegate)]) {
        
        switch (status) {
            case NO_ERROR:
                return;
                break;
                
            case ERROR_CHECKSUM:
                if ([self.delegate respondsToSelector:@selector(didChecksumError)]) {
                    [self.salutronSDK disconnectDevice];
                    [self.delegate didChecksumError];
                    [self.delegate didDeviceDisconnected:self.syncingFinished];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
                }
                break;
                
            case ERROR_TIMEOUT:
                [self.salutronSDK disconnectDevice];
                
                if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                    [self.delegate didDeviceDisconnected:self.syncingFinished];
                }
                if ([self.delegate respondsToSelector:@selector(didDiscoverTimeout)]) {
                    [self.delegate didDiscoverTimeout];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
                break;
                
            case ERROR_DATA:
            case ERROR_DISCOVER:
            case ERROR_DISCONNECT:
            default:
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
                //[self.salutronSDK disconnectDevice];
                
                if ([self.delegate respondsToSelector:@selector(didDeviceDisconnected:)]) {
                    [self.delegate didDeviceDisconnected:self.syncingFinished];
                }
                if ([self.delegate respondsToSelector:@selector(didRaiseError)]) {
                    [self.delegate didRaiseError];
                }
                break;
        }
    }
}

@end
