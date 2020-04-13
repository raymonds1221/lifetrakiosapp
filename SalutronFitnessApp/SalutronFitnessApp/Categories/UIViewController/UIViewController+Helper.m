//
//  UIViewController+Helper.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 10/9/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "UIViewController+Helper.h"
#import <HealthKit/HealthKit.h>

@implementation UIViewController (Helper)

- (BOOL)isIOS8AndAbove
{
    NSArray *versionComponents = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    return [versionComponents[0] integerValue] >= 8;
}

- (BOOL)isIOS9AndAbove
{
    NSArray *versionComponents = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    return [versionComponents[0] integerValue] >= 9;
}

- (BOOL)isLowBattery
{
   // [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    double batLeft = (float)[myDevice batteryLevel] * 100;
    DDLogError(@"%.f",batLeft);
    
    
    NSString * levelLabel = [NSString stringWithFormat:@"%.f%%", batLeft];
    DDLogInfo(@"battery - %@", levelLabel);
    if (batLeft <= 20.0) {
        return YES;
    }
    return NO;
}

- (BOOL)isLowStorage{
    long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil]
                            objectForKey:NSFileSystemFreeSize] longLongValue];

    NSString *free1 = [NSByteCountFormatter stringFromByteCount:freeSpace countStyle:NSByteCountFormatterCountStyleFile];
    
    DDLogInfo(@"Free1 = %@", free1);
    
    //more accurate
    NSString *free2 = [NSByteCountFormatter stringFromByteCount:freeSpace countStyle:NSByteCountFormatterCountStyleBinary];
    
    DDLogInfo(@"Free2 = %@", free2);
    //Return yes is free space is below 1GB 
    if ([free2 doubleValue] < 1.0) {
        return YES;
    }
    return NO;
}

/*
- (long long)getFreeDiskspace {
    long long freeSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemFreeSizeInBytes = [dictionary objectForKey: NSFileSystemFreeSize];
        freeSpace = [fileSystemFreeSizeInBytes longLongValue];
    } else {
        //Handle error
    }
    DDLogInfo(@"free space = %ll", freeSpace);
    return freeSpace;
}
-(uint64_t)getFreeDiskspace {
 
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        DDLogInfo(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        DDLogInfo(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
 
} */



@end
