#import <Foundation/Foundation.h>

@class Library;
@class NSFetchedResultsController;

@interface Store : NSObject

@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;

- (Library *)rootItem;

@end