#import <CoreData/CoreData.h>
#import "Store.h"
#import "Library.h"


@implementation Store

- (Library *)rootItem
{
    // todo: use a cache?
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = [NSPredicate predicateWithFormat:@"parent = %@", nil];
    NSArray* objects = [self.managedObjectContext executeFetchRequest:request error:NULL];
    Item* rootItem = [objects lastObject];
    if (rootItem == nil) {
        rootItem = [Item insertItemWithTitle:nil parent:nil inManagedObjectContext:self.managedObjectContext];
    }
    return rootItem;
}

@end