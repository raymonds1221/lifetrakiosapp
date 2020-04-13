//
//  JDACoreData.m
//  WomensCircle
//
//  Created by John Dwaine Alingarog on 11/2/13.
//  Copyright (c) 2013 John Dwaine Alingarog. All rights reserved.
//

#import "JDACoreData.h"

@implementation JDACoreData

static JDACoreData *sharedJDACoreData;

#pragma mark - Shared
+ (JDACoreData *)sharedManager
{
    @synchronized(self)
    {
        if (!sharedJDACoreData) sharedJDACoreData = [[JDACoreData alloc] init];
        return sharedJDACoreData;
    }
}

+ (JDACoreData *)managerWithContext:(NSManagedObjectContext *)context
{
    @synchronized(self)
    {
        if (!sharedJDACoreData) sharedJDACoreData = [[JDACoreData alloc] initWithContext:context];
        
        return sharedJDACoreData;
    }
}

#pragma mark - Constructors
- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self)
    {
        self.context = context;
    }
    return self;
}

#pragma mark - Public instance delete methods
- (void)deleteStoreURLWithString:(NSString *)storeURLString
{
    NSError *error;
    NSFileManager *_defaultManager          = [NSFileManager defaultManager];
    NSURL *_applicationDocumentsDirectory   = [[_defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *_storeURL                        = [_applicationDocumentsDirectory URLByAppendingPathComponent:storeURLString];
    [[NSFileManager defaultManager] removeItemAtPath:_storeURL.path error:&error];
}

- (void)deleteEntityObjectsWithEntityName:(NSString *)entityName
{
    NSArray *_fetchedObjects    =  [self fetchEntityWithEntityName:entityName];
    
    for (NSManagedObject *_object in _fetchedObjects)
    {
        [self deleteEntityObjectWithObject:_object];
    }
    [self save];
}

- (void)deleteEntityObjectWithEntityName:(NSString *)entityName
                               predicate:(NSPredicate *)predicate
{
    NSArray *_fetchedObjects    = [self fetchEntityWithEntityName:entityName predicate:predicate];
    
    for (NSManagedObject *_object in _fetchedObjects)
    {
        [self deleteEntityObjectWithObject:_object];
    }
}

- (void)deleteEntityObjectWithObject:(id)object
{
    [self.context deleteObject:object];
}

#pragma mark - Public instance insert methods
- (id)insertNewObjectWithEntityName:(NSString *)entityName
{
    return  [NSEntityDescription insertNewObjectForEntityForName:entityName
                                          inManagedObjectContext:self.context];
}

#pragma mark - Public instance select methods
// TODO: Add codes here
- (NSArray *)fetchEntityWithEntityName:(NSString *)entityName
{
    return [self fetchEntityWithEntityName:entityName predicate:nil sortWithKey:nil limit:0 ascending:NO sortType:SORT_TYPE_NOTHING];
}

- (NSArray *)fetchEntityWithEntityName:(NSString *)entityName
                                 limit:(NSInteger)limit
{
    return [self fetchEntityWithEntityName:entityName predicate:nil sortWithKey:nil limit:limit ascending:NO sortType:SORT_TYPE_NOTHING];
}

- (NSArray *)fetchEntityWithEntityName:(NSString *)entityName
                             predicate:(NSPredicate *)predicate
{
    return [self fetchEntityWithEntityName:entityName predicate:predicate sortWithKey:nil limit:0 ascending:NO sortType:SORT_TYPE_NOTHING];
}

- (NSArray *)fetchEntityWithEntityName:(NSString *)entityName
                             predicate:(NSPredicate *)predicate
                                 limit:(NSInteger)limit
{
    return [self fetchEntityWithEntityName:entityName predicate:predicate sortWithKey:nil limit:0 ascending:NO sortType:SORT_TYPE_NOTHING];
}

- (NSArray *)fetchEntityWithEntityName:(NSString *)entityName
                             predicate:(NSPredicate *)predicate
                           sortWithKey:(NSString *)sortDescriptorKey
                             ascending:(BOOL)ascending
                              sortType:(SORT_TYPE)sortType
{
    return [self fetchEntityWithEntityName:entityName predicate:predicate sortWithKey:sortDescriptorKey limit:0 ascending:ascending sortType:sortType];
}

- (NSArray *)fetchEntityWithEntityName:(NSString *)entityName
                             predicate:(NSPredicate *)predicate
                           sortWithKey:(NSString *)sortDescriptorKey
                                 limit:(NSInteger)limit
                             ascending:(BOOL)ascending
                              sortType:(SORT_TYPE)sortType
{
    //set entity
    NSError *_error;
    NSFetchRequest *_fetchRequest           = [[NSFetchRequest alloc] init];
    NSEntityDescription *_entity            = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];
    _fetchRequest.entity                    = _entity;
    
    //limit returned data
    if (limit > 0 ) [_fetchRequest setFetchLimit:limit];
    
    if (predicate != nil)
        _fetchRequest.predicate = predicate;
    
    //sort ascending or descending
    if (sortDescriptorKey != nil)
    {
        NSArray *_sortDescriptorStringArray;
        
        //Explode string by commas and insert descriptor keys strings to array
        if ([sortDescriptorKey rangeOfString:@","].location != NSNotFound)
        {
            sortDescriptorKey           = [sortDescriptorKey stringByReplacingOccurrencesOfString:@" " withString:@""];
            _sortDescriptorStringArray  = [[sortDescriptorKey componentsSeparatedByString:@","] mutableCopy];
        }
        else
        {
            _sortDescriptorStringArray  = @[sortDescriptorKey];
        }

        
        NSMutableArray *_sortDescriptorsArray   = [NSMutableArray array];
        
        //Convert string descriptor keys to nssortdesciptors and insert in array
        for (NSString *_key in _sortDescriptorStringArray)
        {
            NSSortDescriptor *_sortDescriptor;
            switch (sortType) {
                case SORT_TYPE_STRING:
                    _sortDescriptor   = [[NSSortDescriptor alloc] initWithKey:_key
                                                                    ascending:ascending
                                                                     selector:@selector(localizedCaseInsensitiveCompare:)];
                    break;
                default:
                    _sortDescriptor   = [[NSSortDescriptor alloc] initWithKey:_key
                                                                    ascending:ascending];
                    break;
            }
            
            [_sortDescriptorsArray addObject:_sortDescriptor];
        }
        
        _fetchRequest.sortDescriptors = [NSArray arrayWithArray:_sortDescriptorsArray];
    }
    
    //return fetched array
    NSArray *_fetchedArray  = [self.context executeFetchRequest:_fetchRequest error:&_error];
    return _fetchedArray;
}

#pragma mark - Public instance save methods
- (void)save
{
    NSError *_error;
    [self.context save:&_error];
}

@end
