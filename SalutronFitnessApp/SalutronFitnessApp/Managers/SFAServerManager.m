//
//  SFAServerManager.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 4/24/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "AFNetworking.h"

#import "SFAServerManager.h"

@interface SFAServerManager ()

@property (strong, nonatomic) NSOperation *operation;


@end

@implementation SFAServerManager

#pragma mark - Singleton Instance

+ (SFAServerManager *)sharedManager
{
    static SFAServerManager *instance = nil;
    
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

#pragma mark - Setters

#pragma mark - Getters

#pragma mark - Private Methods

#pragma mark - Public Methods

- (NSOperation *)getRequestToURL:(NSString *)url
             parameters:(NSDictionary *)parameters
                success:(void (^)(NSDictionary *response))success
                failure:(void (^)(NSError *error))failure
{
    AFHTTPRequestOperationManager *manager              = [AFHTTPRequestOperationManager manager];
    
    if ([url isEqualToString:API_STORE_URL] ||
        [url isEqualToString:API_SYNC_URL] ||
        [url isEqualToString:API_STORE_URL_V2] ||
        [url isEqualToString:API_RESTORE_URL_V2] ||
        [url isEqualToString:API_SYNC_URL_V2]) {
        manager.requestSerializer.timeoutInterval       = 3600;
    }
    
    manager.responseSerializer.acceptableContentTypes   = [NSSet setWithObjects:@"text/html", @"application/json", nil];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.securityPolicy.allowInvalidCertificates     = YES;
    manager.securityPolicy = securityPolicy;
    
    self.operation = [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary = (NSDictionary *)responseObject;
        if (![self.operation isCancelled]) {
            if (success) {
                success(dictionary);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (![self.operation isCancelled]) {
        if (operation.responseObject) {
            NSDictionary *dictionary    = (NSDictionary *)operation.responseObject;
            NSString *bundleIdentifier  = [NSBundle mainBundle].bundleIdentifier;
            NSString *errorMessage      = dictionary[API_ERROR_MESSAGE] ? dictionary[API_ERROR_MESSAGE] : API_ERROR_UNKNOWN;
            NSDictionary *userInfo      = @{NSLocalizedDescriptionKey : errorMessage};
            NSInteger errorCode         = [dictionary[@"status"] isEqualToNumber:@(401)] ? ERROR_CODE_ACCESSTOKEN_INVALID : ERROR_CODE_API;
            error                       = [NSError errorWithDomain:bundleIdentifier code:errorCode userInfo:userInfo];
        }
        
        if (failure) {
            failure(error);
        }
        }
    }];
    
    return self.operation;
}


- (NSOperation *)postRequestToURL:(NSString *)url
              parameters:(NSDictionary *)parameters
                 success:(void (^)(NSDictionary *response))success
                 failure:(void (^)(NSError *error))failure
{
    AFHTTPRequestOperationManager *manager              = [AFHTTPRequestOperationManager manager];
    if ([url isEqualToString:API_STORE_URL] || [url isEqualToString:API_SYNC_URL] || [url isEqualToString:API_STORE_URL_V2] || [url isEqualToString:API_SYNC_URL_V2]) {
        manager.requestSerializer.timeoutInterval       = 3600;
    }
    manager.responseSerializer.acceptableContentTypes   = [NSSet setWithObjects:@"text/html", @"application/json", nil];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.securityPolicy.allowInvalidCertificates     = YES;
    manager.securityPolicy = securityPolicy;
    
    self.operation = [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary = (NSDictionary *)responseObject;
        if (![self.operation isCancelled]) {
        if (success) {
            success(dictionary);
        }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogInfo(@"failure - %@", error);
        if (![self.operation isCancelled]) {
        if (operation.responseObject) {
            NSDictionary *dictionary    = (NSDictionary *)operation.responseObject;
            NSString *bundleIdentifier  = [NSBundle mainBundle].bundleIdentifier;
            NSString *errorMessage      = dictionary[API_ERROR_MESSAGE] ? dictionary[API_ERROR_MESSAGE] : API_ERROR_UNKNOWN;
            NSDictionary *userInfo      = @{NSLocalizedDescriptionKey : errorMessage};
            NSInteger errorCode         = [dictionary[@"status"] isEqualToNumber:@(401)] ? ERROR_CODE_ACCESSTOKEN_INVALID : ERROR_CODE_API;
            error                       = [NSError errorWithDomain:bundleIdentifier code:errorCode userInfo:userInfo];
        }
        
        if (failure) {
            failure(error);
        }
        }
    }];
    
    return self.operation;
}

- (NSOperation *)postRequestToURL:(NSString *)url
              parameters:(NSDictionary *)parameters
                    data:(NSData *)data
                dataName:(NSString *)dataName
                fileName:(NSString *)fileName
                mimeType:(NSString *)mimeType
                 success:(void (^)(NSDictionary *response))success
                 failure:(void (^)(NSError *error))failure
{
    AFHTTPRequestOperationManager *manager              = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes   = [NSSet setWithObjects:@"text/html", @"application/json", @"multipart/form-data", nil];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.securityPolicy.allowInvalidCertificates     = YES;
    manager.securityPolicy = securityPolicy;
    
    self.operation = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:dataName fileName:fileName mimeType:mimeType];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary = (NSDictionary *)responseObject;
        if (![self.operation isCancelled]) {
        if (success) {
            success(dictionary);
        }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        /*if (operation.responseObject) {
            NSDictionary *dictionary    = (NSDictionary *)operation.responseObject;
            NSString *bundleIdentifier  = [NSBundle mainBundle].bundleIdentifier;
            NSString *errorMessage      = dictionary[API_ERROR_MESSAGE] ? dictionary[API_ERROR_MESSAGE] : API_ERROR_UNKNOWN;
            NSDictionary *userInfo      = @{NSLocalizedDescriptionKey : errorMessage};
            error                       = [NSError errorWithDomain:bundleIdentifier code:ERROR_CODE_API userInfo:userInfo];
        }
        
        if (failure) {
            failure(error);
        }*/
        if (![self.operation isCancelled]) {
        [self retryPostRequestToURL:url
                         parameters:parameters
                               data:data
                           dataName:dataName
                           fileName:fileName
                           mimeType:mimeType
                            success:success
                            failure:failure];
        }
    }];
        
    return self.operation;
    
}

- (void)retryPostRequestToURL:(NSString *)url
                   parameters:(NSDictionary *)parameters
                         data:(NSData *)data
                     dataName:(NSString *)dataName
                     fileName:(NSString *)fileName
                     mimeType:(NSString *)mimeType
                      success:(void (^)(NSDictionary *response))success
                      failure:(void (^)(NSError *error))failure
{
    //AFHTTPRequestOperationManager *manager              = [AFHTTPRequestOperationManager manager];
    NSURLSessionConfiguration *configuration        = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager                   = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.securityPolicy.allowInvalidCertificates     = YES;
    manager.securityPolicy = securityPolicy;
    
    manager.responseSerializer.acceptableContentTypes   = [NSSet setWithObjects:@"text/html", @"application/json", @"multipart/form-data", nil];
    
    //Work around instead of using POST method of AFHTTPSessionManager. to access reponseObject in the event of an error 
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:url relativeToURL:manager.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:dataName fileName:fileName mimeType:mimeType];
    } error:nil];
    
    NSURLSessionDataTask *task = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (responseObject) {
                NSDictionary *dictionary    = (NSDictionary *)responseObject;
                NSString *bundleIdentifier  = [NSBundle mainBundle].bundleIdentifier;
                NSString *errorMessage      = dictionary[API_ERROR_MESSAGE] ? dictionary[API_ERROR_MESSAGE] : API_ERROR_UNKNOWN;
                NSDictionary *userInfo      = @{NSLocalizedDescriptionKey : errorMessage};
                NSInteger errorCode         = [dictionary[@"status"] isEqualToNumber:@(401)] ? ERROR_CODE_ACCESSTOKEN_INVALID : ERROR_CODE_API;
                error                       = [NSError errorWithDomain:bundleIdentifier code:errorCode userInfo:userInfo];
            }
            if (failure) {
                failure(error);
            }
        } else {
            NSDictionary *dictionary = (NSDictionary *)responseObject;
            if (success) {
                success(dictionary);
            }
        }
    }];
    [task resume];
}

- (void)cancelOperation
{
    if (self.operation) {
        [self.operation cancel];
    }
}

@end
