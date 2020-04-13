//
//  SFAServerManager.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/24/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFAServerManager : NSObject

// Singleton Instance

+ (SFAServerManager *)sharedManager;

// Instance Methods

- (NSOperation *)getRequestToURL:(NSString *)url
             parameters:(NSDictionary *)parameters
                success:(void (^)(NSDictionary *response))success
                failure:(void (^)(NSError *error))failure;

- (NSOperation *)postRequestToURL:(NSString *)url
              parameters:(NSDictionary *)parameters
                 success:(void (^)(NSDictionary *response))success
                 failure:(void (^)(NSError *error))failure;


- (NSOperation *)postRequestToURL:(NSString *)url
              parameters:(NSDictionary *)parameters
                    data:(NSData *)data
                dataName:(NSString *)dataName
                fileName:(NSString *)fileName
                mimeType:(NSString *)mimeType
                 success:(void (^)(NSDictionary *response))success
                 failure:(void (^)(NSError *error))failure;
- (void)cancelOperation;
@end