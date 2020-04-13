//
//  Logger.h
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 5/28/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOGINFO() QLog(@"LOGINFO : %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd))
#define LOGINFOWITHPARAM(...) LOGINFO(); QLog(__VA_ARGS__)
#define LOG(...) QLog(__VA_ARGS__)

@interface Logger : NSObject

extern NSString * const Status_toString[];
void QLog (NSString *format, ...);

@end
