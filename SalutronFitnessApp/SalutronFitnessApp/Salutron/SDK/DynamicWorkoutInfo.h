//
//  DynamicWorkoutInfo.h
//  BLEManager
//
//  Created by Leo Bellotindos on 2/10/15.
//  Copyright © 2015 Salutron Inc. All rights reserved.
//

#ifndef DynamicWorkoutInfo_h
#define DynamicWorkoutInfo_h


#import <Foundation/Foundation.h>
#import "WorkoutHeader.h"

@interface DynamicWorkoutInfo : NSObject

@property (nonatomic, retain) WorkoutHeader *header;
@property (nonatomic, retain) NSMutableArray *records;
@property (nonatomic, retain) NSMutableArray *stopDatabase;
@property (nonatomic, retain) NSMutableArray *hrData;


@end


#endif /* DynamicWorkoutInfo_h */
