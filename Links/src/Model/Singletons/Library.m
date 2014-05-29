//
//  Library.m
//  Links
//
//  Created by Eoin Nolan on 18/02/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "Library.h"
#import "BookInfo.h"
#import "Book.h"
#import "Annotation.h"

@implementation Library

static Library * singleton;

- (id)init {
    Library * lib = [super init];
    lib.library = [NSMutableArray array];
    lib.edgeAnnotations = [NSMutableDictionary dictionary];
    lib.nodeAnnotations = [NSMutableDictionary dictionary];
    lib.bookAnnotations = [NSMutableDictionary dictionary];
    lib.books = [NSMutableDictionary dictionary];
    return lib;
    
}

+ (void)addBookInfo:(BookInfo *)info {
    [singleton.library addObject:info];
    [Library saveLibrary];
}

+ (void)deleteBookInfo:(BookInfo *)info {
    [singleton.library removeObject:info];
}


+ (void)saveLibrary {
    NSString * libraryPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"library.archive"];
    
    if ([NSKeyedArchiver archiveRootObject:singleton toFile:libraryPath]) {
        NSLog(@"Library sucessfully saved to file.");
    } else {
        NSLog(@"ERROR: Library not saved to file.");
    }
}

+ (NSArray *)loadLibrary {
    
    if (singleton == nil) {
        NSString * libraryPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"library.archive"];
        
        singleton = [NSKeyedUnarchiver unarchiveObjectWithFile:libraryPath];
        if (singleton == nil) {
            NSLog(@"WARNING : Library did not exist.");
            singleton = [[Library alloc] init];
        }
    }
    return singleton.library;
}

+ (Book *)loadBookWithInfo:(BookInfo *)info {
    Book * book = [singleton.books objectForKey:info.UUID];
    if (book == nil) {
        book = [Book load:info.UUID];
    }
    return book;
}

+ (void)cacheBook:(Book *)book withUUID:(NSUUID *)UUID {
    [singleton.books setObject:book forKey:UUID];
}


+ (NSSet *)annotationsForEdge:(NSNumber *)edgeKey
{
    return [singleton.edgeAnnotations objectForKey:edgeKey];
}

+ (NSSet *)annotationsForNode:(NSNumber *)nodeKey {
    return [singleton.nodeAnnotations objectForKey:nodeKey];
}

+ (NSSet *)annotationsForBook:(NSUUID *)bookUUID {
    return [singleton.bookAnnotations objectForKey:bookUUID];
}

+ (Annotation *)annotationsForEdge:(NSNumber *)edgeKey setKey:(NSNumber *)key {
    NSSet * annotations = [singleton.edgeAnnotations objectForKey:edgeKey];
    for (Annotation * annotation in annotations) {
        if ([annotation.books isEqual:key]) {
            return annotation;
        }
    }
    return nil;
}

+ (Annotation *)annotationsForNode:(NSNumber *)nodeKey setKey:(NSNumber *)key {
    NSSet * annotations = [singleton.nodeAnnotations objectForKey:nodeKey];
    for (Annotation * annotation in annotations) {
        if ([annotation.books isEqual:key]) {
            return annotation;
        }
    }
    return nil;
}

+ (void)addEdgeAnnotation:(Annotation *)annotation key:(NSNumber *)edgeKey books:(NSSet *)books {
    NSMutableSet * annotations = [singleton.edgeAnnotations objectForKey:edgeKey];
    if (annotations == nil) {
        annotations = [NSMutableSet set];
    }
    [annotations addObject:annotation];
    [singleton.edgeAnnotations setObject:annotations forKey:edgeKey];
    
    for (BookInfo * info in books) {
        [Library addBookAnnotation:annotation key:info.UUID];
    }
}

+ (void)addNodeAnnotation:(Annotation *)annotation key:(NSNumber *)nodeKey books:(NSSet *)books {
    NSMutableSet * annotations = [singleton.nodeAnnotations objectForKey:nodeKey];
    if (annotations == nil) {
        annotations = [NSMutableSet set];
    }
    [annotations addObject:annotation];
    [singleton.nodeAnnotations setObject:annotations forKey:nodeKey];
    
    for (BookInfo * info in books) {
        [Library addBookAnnotation:annotation key:info.UUID];
    }
}

+ (void)addBookAnnotation:(Annotation *)annotation key:(NSUUID *)uuid {
    NSMutableSet * annotations = [singleton.bookAnnotations objectForKey:uuid];
    if (annotations == nil) {
        annotations = [NSMutableSet set];
    }
    [annotations addObject:annotation];
    [singleton.bookAnnotations setObject:annotations forKey:uuid];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.library forKey:@"library"];
    [aCoder encodeObject:self.nodeAnnotations forKey:@"nodeAnnotations"];
    [aCoder encodeObject:self.edgeAnnotations forKey:@"edgeAnnotations"];
    [aCoder encodeObject:self.bookAnnotations forKey:@"bookAnnotations"];
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.books = [NSMutableDictionary dictionary];
        self.library = [aDecoder decodeObjectForKey:@"library"];
        self.nodeAnnotations = [aDecoder decodeObjectForKey:@"nodeAnnotations"];
        self.edgeAnnotations = [aDecoder decodeObjectForKey:@"edgeAnnotations"];
        self.bookAnnotations = [aDecoder decodeObjectForKey:@"bookAnnotations"];
    }
    return self;
}

+ (void)clearCache {
    for (Book * b in singleton.books.allValues) {
        NSLog(@"%@",NSStringFromClass([b class]));
        b.bookInfo = nil;
        [b.nodes removeAllObjects];
        [b.edges removeAllObjects];
        b.text = nil;
    }
    [singleton.books removeAllObjects];
}

@end
