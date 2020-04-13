//
//  UIImage+WatchImage.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "UIImage+WatchImage.h"

@implementation UIImage (WatchImage)

+ (UIImage *)watchImageForMacAddress:(NSString *)macAddress
{
    NSString *path              = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imageFile         = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", macAddress]];
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    BOOL fileExists             = [fileManager fileExistsAtPath:imageFile];
    
    if (fileExists) {
        return [UIImage imageWithContentsOfFile:imageFile];
    }
    
    return nil;
}

+ (void)saveImage:(UIImage *)image withMacAddress:(NSString *)macAddress
{
    [self deleteImageWithMacAddress:macAddress];
    
    NSData *imageData   = UIImageJPEGRepresentation(image, 1.0);
    NSString *path      = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path                = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", macAddress]];
    
    BOOL success = [imageData writeToFile:path atomically:YES];
    
    if (success) {
        
    }
}

+ (void)deleteImageWithMacAddress:(NSString *)macAddress
{
    NSString *path              = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imageFile         = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", macAddress]];
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    BOOL fileExists             = [fileManager fileExistsAtPath:imageFile];
    
    if (fileExists) {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:imageFile error:&error];
        
        if (success) {
            DDLogError(@"Image Delete Error: %@", [error localizedDescription]);
        }
    }
}

@end
