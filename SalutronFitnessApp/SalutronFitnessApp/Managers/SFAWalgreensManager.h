//
//  SFAWalgreensManager.h
//  SalutronFitnessApp
//
//  Created by Angela Cartagena on 6/17/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFAWalgreensManager : NSObject

+ (SFAWalgreensManager *)sharedManager;

- (void)getConnectURLWithSuccess:(void (^)(NSURL *url, BOOL isConnected, BOOL isSynced))success
                         failure:(void (^)(NSError *error))failure;
- (void)disconnectWithSuccess:(void (^)())success
                      failure:(void (^)(NSError *error))failure;
- (void)cancelCurrentOperation;

@end
