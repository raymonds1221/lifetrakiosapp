//
//  SFAServerManager+RefreshAccessToken.m
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 7/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAServerManager+RefreshAccessToken.h"
#import "SFAServerAccountManager.h"
#import "NSDictionary+String.h"


@implementation SFAServerManager (RefreshAccessToken)


- (NSOperation *)getRequestWithRefreshAccessTokenToURL:(NSString *)url
                                            parameters:(NSDictionary *)parameters
                                               success:(void (^)(NSDictionary *response))success
                                               failure:(void (^)(NSError *error))failure
{
    __block SFAServerAccountManager *accountManager = [SFAServerAccountManager sharedManager];
    
    NSDictionary *accessTokenParameters        = @{API_ACCESSTOKEN_GRANT      : API_REFRESH_TOKEN_GRANT_TYPE,
                                                   API_OAUTH_REFRESH_TOKEN    : accountManager.refreshToken,
                                                   API_OAUTH_CLIENT_ID        : API_CLIENT_ID,
                                                   API_OAUTH_CLIENT_SECRET    : API_CLIENT_SECRET};
    __weak typeof(self) weakSelf = self;
    
    //success block for refresh token request
    void (^refreshSuccess)(NSDictionary *response) = ^(NSDictionary *response) {
        NSString *errorString = [response objectForKey:API_ERROR_CODE];
        
        if (errorString) {
            NSString *bundleIdentifier  = [NSBundle mainBundle].bundleIdentifier;
            NSString *errorMessage      = [response objectForKey:API_ERROR_MESSAGE];
            NSDictionary *userInfo      = @{NSLocalizedDescriptionKey : errorMessage};
            NSError *error              = [NSError errorWithDomain:bundleIdentifier code:ERROR_CODE_API userInfo:userInfo];
            
            if (failure) {
                failure(error);
            }
        } else {
            NSInteger timeStamp = [[response objectForKey:API_OAUTH_EXPIRATION] integerValue];
            accountManager.accessToken    = [response stringObjectForKey:API_OAUTH_ACCESS_TOKEN];
            accountManager.expiration     = [NSDate dateWithTimeIntervalSince1970:timeStamp];
            accountManager.refreshToken   = [response stringObjectForKey:API_OAUTH_REFRESH_TOKEN];
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:parameters];
            params[API_OAUTH_ACCESS_TOKEN] = accountManager.accessToken;
            
            [weakSelf getRequestToURL:url parameters:params success:success failure:failure];
        }
    };
    
    if (![accountManager isAccessTokenExpired]){
        return [self getRequestToURL:url parameters:parameters success:success failure:^(NSError *error) {
            //if error is due to access code validity, refresh token and retry request

            if (error.code == ERROR_CODE_ACCESSTOKEN_INVALID){
                [weakSelf postRequestToURL:API_REFRESH_ACCESS_TOKEN_URL parameters:accessTokenParameters success:refreshSuccess failure:failure];
            }else{
                if (failure){
                    failure(error);
                }
            }
        }];
    }
    
    return [self postRequestToURL:API_REFRESH_ACCESS_TOKEN_URL parameters:accessTokenParameters success:refreshSuccess failure:^(NSError *error) {
        if (failure){
            failure(error);
        }
        /*
         if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
            [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_TOKEN_INVALID_NOTIFICATION object:nil];
        }else{
            if (failure) {
                failure(error);
            }
        }*/
    }];
}

- (NSOperation *)postRequestWithRefreshAccessTokenToURL:(NSString *)url
                                             parameters:(NSDictionary *)parameters
                                                success:(void (^)(NSDictionary *response))success
                                                failure:(void (^)(NSError *error))failure
{
    
    __block SFAServerAccountManager *accountManager = [SFAServerAccountManager sharedManager];
    
    NSDictionary *accessTokenParameters        = @{API_ACCESSTOKEN_GRANT      : API_REFRESH_TOKEN_GRANT_TYPE,
                                                   API_OAUTH_REFRESH_TOKEN    : accountManager.refreshToken,
                                                   API_OAUTH_CLIENT_ID        : API_CLIENT_ID,
                                                   API_OAUTH_CLIENT_SECRET    : API_CLIENT_SECRET};

    __weak typeof(self) weakSelf = self;
    void (^refreshSuccess)(NSDictionary *response) = ^(NSDictionary *response) {
        NSString *errorString = [response objectForKey:API_ERROR_CODE];
        
        if (errorString) {
            NSString *bundleIdentifier  = [NSBundle mainBundle].bundleIdentifier;
            NSString *errorMessage      = [response objectForKey:API_ERROR_MESSAGE];
            NSDictionary *userInfo      = @{NSLocalizedDescriptionKey : errorMessage};
            NSError *error              = [NSError errorWithDomain:bundleIdentifier code:ERROR_CODE_API userInfo:userInfo];
            
            if (failure) {
                failure(error);
            }
        } else {
            NSInteger timeStamp = [[response objectForKey:API_OAUTH_EXPIRATION] integerValue];
            accountManager.accessToken    = [response stringObjectForKey:API_OAUTH_ACCESS_TOKEN];
            accountManager.expiration     = [NSDate dateWithTimeIntervalSince1970:timeStamp];
            accountManager.refreshToken   = [response stringObjectForKey:API_OAUTH_REFRESH_TOKEN];
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:parameters];
            params[API_OAUTH_ACCESS_TOKEN] = accountManager.accessToken;
            
            [self postRequestToURL:url parameters:params success:success failure:failure];
        }
    };
    
    if (![accountManager isAccessTokenExpired]){
    
        return [self postRequestToURL:url parameters:parameters success:success failure:^(NSError *error) {
            //if error is due to access code validity, refresh token and retry request
            
            if (error.code == ERROR_CODE_ACCESSTOKEN_INVALID){
                [weakSelf postRequestToURL:API_REFRESH_ACCESS_TOKEN_URL parameters:accessTokenParameters success:refreshSuccess failure:failure];
            }else{
                if (failure){
                    failure(error);
                }
            }
        }];
    }
    
    return [self postRequestToURL:API_REFRESH_ACCESS_TOKEN_URL parameters:accessTokenParameters success:refreshSuccess failure:^(NSError *error) {
        if (failure){
            failure(error);
        }
        /*
        if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
            [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_TOKEN_INVALID_NOTIFICATION object:nil];
        }else{
            if (failure) {
                failure(error);
            }
        }*/
    }];
}


- (NSOperation *)postRequestWithRefreshAccessTokenToURL:(NSString *)url
                                             parameters:(NSDictionary *)parameters
                                                   data:(NSData *)data
                                               dataName:(NSString *)dataName
                                               fileName:(NSString *)fileName
                                               mimeType:(NSString *)mimeType
                                                success:(void (^)(NSDictionary *response))success
                                                failure:(void (^)(NSError *error))failure
{
    
    __block SFAServerAccountManager *accountManager = [SFAServerAccountManager sharedManager];
    
    NSDictionary *accessTokenParameters        = @{API_ACCESSTOKEN_GRANT      : API_REFRESH_TOKEN_GRANT_TYPE,
                                                   API_OAUTH_REFRESH_TOKEN    : accountManager.refreshToken,
                                                   API_OAUTH_CLIENT_ID        : API_CLIENT_ID,
                                                   API_OAUTH_CLIENT_SECRET    : API_CLIENT_SECRET};
    __weak typeof(self) weakSelf = self;
    
    void (^refreshSuccess)(NSDictionary *response) =^(NSDictionary *response) {
        NSString *errorString = [response objectForKey:API_ERROR_CODE];
        
        if (errorString) {
            NSString *bundleIdentifier  = [NSBundle mainBundle].bundleIdentifier;
            NSString *errorMessage      = [response objectForKey:API_ERROR_MESSAGE];
            NSDictionary *userInfo      = @{NSLocalizedDescriptionKey : errorMessage};
            NSError *error              = [NSError errorWithDomain:bundleIdentifier code:ERROR_CODE_API userInfo:userInfo];
            
            if (failure) {
                failure(error);
            }
        } else {
            NSInteger timeStamp = [[response objectForKey:API_OAUTH_EXPIRATION] integerValue];
            accountManager.accessToken    = [response stringObjectForKey:API_OAUTH_ACCESS_TOKEN];
            accountManager.expiration     = [NSDate dateWithTimeIntervalSince1970:timeStamp];
            accountManager.refreshToken   = [response stringObjectForKey:API_OAUTH_REFRESH_TOKEN];
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:parameters];
            params[API_OAUTH_ACCESS_TOKEN] = accountManager.accessToken;
            
            [self postRequestToURL:url parameters:params data:data dataName:dataName fileName:fileName mimeType:mimeType success:success failure:failure];
        }
    };
    
    if (![accountManager isAccessTokenExpired]){
        return [self postRequestToURL:url parameters:parameters data:data dataName:dataName fileName:fileName mimeType:mimeType success:success failure:^(NSError *error) {
            //if error is due to access code validity, refresh token and retry request
            if (error.code == ERROR_CODE_ACCESSTOKEN_INVALID){
                [weakSelf postRequestToURL:API_REFRESH_ACCESS_TOKEN_URL parameters:accessTokenParameters success:refreshSuccess failure:failure];
            }else{
                if (failure){
                    failure(error);
                }
            }
        }];
    }
    
    return [self postRequestToURL:API_REFRESH_ACCESS_TOKEN_URL parameters:accessTokenParameters success:refreshSuccess failure:^(NSError *error) {
        if (failure){
            failure(error);
        }
        /*
        if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
            [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_TOKEN_INVALID_NOTIFICATION object:nil];
        }else{
            if (failure) {
                failure(error);
            }
        }*/
    }];
}

@end
