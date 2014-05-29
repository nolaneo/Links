//
//  Book.h
//  Links
//
//  Created by Eoin Nolan on 17/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Node;
@class Edge;
@class BookInfo;

struct ProcessingUpdate {
    __block int nouns;
    __block int propernouns;
    __block int verbs;
    __block int adjectives;
    __block int adverbs;
    __block int classifiers;
    __block int idioms;
};

@protocol BookProcessingDelegate <NSObject>

- (void)updateStatusLabel:(NSString *)status;
- (void)updateTokenizationProgress:(NSNumber *)progress;
- (void)updateGraphCreationProgress:(NSNumber *)progress;
- (void)updateWordProcessingTotalNouns:(NSUInteger)nouns verbs:(NSUInteger)verbs adjectives:(NSUInteger)adjectives;
- (void)updateWordProcessingTotal:(struct ProcessingUpdate)update;
- (void)updateGraphProcessingWithNodes:(NSUInteger)nodes edges:(NSUInteger)edges;

@end

typedef void (^BookProcessCompleteBlock)(NSString * result);

@interface Book : NSObject <NSCoding> {
    UIViewController<BookProcessingDelegate> * delegate;
    NSArray * nodeFrequencies; //Array of nodes sorted by frequency
    NSArray * edgeFrequencies; //Array of edges sorted by frequency
}
@property BookInfo * bookInfo;
@property NSUInteger wordCount;
@property NSMutableDictionary * nodes; // (Word -> Node)
@property NSMutableDictionary * edges; // ((Node, Node) -> Edge)
@property NSString * text;

@property NSArray * positiveSentiment;
@property NSArray * negativeSentiment;
@property NSMutableArray * sentimentOffsets;
@property float maxSentiment;
@property float minSentiment;

@property NSMutableArray * chapterNames;
@property NSMutableArray * chapterLocations;

+ (instancetype)bookWithInfo:(BookInfo *)info;
+ (instancetype)bookWithFilename:(NSString *)filename filetype:(NSString *)filetype;
+ (instancetype)bookTestInit;

- (void)setDelegate:(id<BookProcessingDelegate>)delegateIn;
- (void)setWordCount:(NSUInteger)wordCountIn;
- (void)processBookWithCompletion:(BookProcessCompleteBlock)completionBlock;
- (void)processTestBookWithCompletion:(BookProcessCompleteBlock)completionBlock;
- (NSArray *)getNodeFrequencies;
- (NSArray *)getEdgeFrequencies;
- (void)save;
+ (instancetype)load:(NSUUID *)uuid;

@end
