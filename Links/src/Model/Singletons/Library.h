//
//  Library.h
//  Links
//
//  Created by Eoin Nolan on 18/02/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BookInfo;
@class Book;
@class Annotation;

@interface Library : NSObject <NSCoding>

@property NSMutableArray * library;
@property NSMutableDictionary * books;
@property NSMutableDictionary * edgeAnnotations;
@property NSMutableDictionary * nodeAnnotations;
@property NSMutableDictionary * bookAnnotations;

+ (void)addBookInfo:(BookInfo *)info;
+ (void)deleteBookInfo:(BookInfo *)info;
+ (void)saveLibrary;
+ (NSArray *)loadLibrary;
+ (Book *)loadBookWithInfo:(BookInfo *)info;
+ (void)clearCache;
+ (void)cacheBook:(Book *)book withUUID:(NSUUID *)UUID;

+ (NSSet *)annotationsForEdge:(NSNumber *)edgeKey;
+ (NSSet *)annotationsForNode:(NSNumber *)nodeKey;
+ (NSSet *)annotationsForBook:(NSUUID *)bookUUID;

+ (Annotation *)annotationsForEdge:(NSNumber *)edgeKey setKey:(NSNumber *)key;
+ (Annotation *)annotationsForNode:(NSNumber *)nodeKey setKey:(NSNumber *)key;

+ (void)addEdgeAnnotation:(Annotation *)annotation key:(NSNumber *)edgeKey books:(NSSet *)books;
+ (void)addNodeAnnotation:(Annotation *)annotation key:(NSNumber *)nodeKey books:(NSSet *)books;
+ (void)addBookAnnotation:(Annotation *)annotation key:(NSUUID *)uuid;

@end
