//
//  JDACoreData.h
//  WomensCircle
//
//  Created by John Dwaine Alingarog on 11/2/13.
//  Copyright (c) 2013 John Dwaine Alingarog. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SORT_TYPE_STRING,
    SORT_TYPE_NUMBER,
    SORT_TYPE_DATE,
    SORT_TYPE_NOTHING
}SORT_TYPE;

@interface JDACoreData : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;

//Shared
+ (JDACoreData *)sharedManager;
+ (JDACoreData *)managerWithContext:(NSManagedObjectContext *)context;

//Constructors
- (id)initWithContext:(NSManagedObjectContext *)context;

//Delete methods
- (void)deleteStoreURLWithString:(NSString *)storeURLString;
- (void)deleteEntityObjectsWithEntityName:(NSString *)entityName;
- (void)deleteEntityObjectWithEntityName:(NSString *)entityName
                               predicate:(NSPredicate *)predicate;
- (void)deleteEntityObjectWithObject:(id)object;


//Insert methods
- (id)insertNewObjectWithEntityName:(NSString *)entityName;

//Select methods
- (NSArray *)fetchEntityWithEntityName:(NSString *)entityName;
- (NSArray *)fetchEntityWithEntityName:(NSString *)entityName
                                 limit:(NSInteger)limit;
- (NSArray *)fetchEntityWithEntityName:(NSString *)entityName
                             predicate:(NSPredicate *)predicate;
- (NSArray *)fetchEntityWithEntityName:(NSString *)entityName
                             predicate:(NSPredicate *)predicate
                                 limit:(NSInteger)limit;
- (NSArray *)fetchEntityWithEntityName:(NSString *)entityName
                             predicate:(NSPredicate *)predicate
                           sortWithKey:(NSString *)sortDescriptorKey
                             ascending:(BOOL)ascending
                              sortType:(SORT_TYPE)sortType;
- (NSArray *)fetchEntityWithEntityName:(NSString *)entityName
                             predicate:(NSPredicate *)predicate
                           sortWithKey:(NSString *)sortDescriptorKey
                                 limit:(NSInteger)limit
                             ascending:(BOOL)ascending
                              sortType:(SORT_TYPE)sortType;

//Save method
- (void)save;

@end
