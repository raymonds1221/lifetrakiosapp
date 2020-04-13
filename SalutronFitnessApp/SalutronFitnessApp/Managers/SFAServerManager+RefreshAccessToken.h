//
//  SFAServerManager+RefreshAccessToken.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 7/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAServerManager.h"

@interface SFAServerManager (RefreshAccessToken)

- (NSOperation *)getRequestWithRefreshAccessTokenToURL:(NSString *)url
                                            parameters:(NSDictionary *)parameters
                                               success:(void (^)(NSDictionary *response))success
                                               failure:(void (^)(NSError *error))failure;

- (NSOperation *)postRequestWithRefreshAccessTokenToURL:(NSString *)url
                                             parameters:(NSDictionary *)parameters
                                                success:(void (^)(NSDictionary *response))success
                                                failure:(void (^)(NSError *error))failure;


- (NSOperation *)postRequestWithRefreshAccessTokenToURL:(NSString *)url
                                             parameters:(NSDictionary *)parameters
                                                   data:(NSData *)data
                                               dataName:(NSString *)dataName
                                               fileName:(NSString *)fileName
                                               mimeType:(NSString *)mimeType
                                                success:(void (^)(NSDictionary *response))success
                                                failure:(void (^)(NSError *error))failure;

@end
