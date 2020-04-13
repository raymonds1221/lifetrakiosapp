//
//  NoteEntity.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/5/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NoteEntity : NSManagedObject

@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSDate *date;

@end
