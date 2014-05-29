//
//  Node.h
//  Links
//
//  Created by Eoin Nolan on 17/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WordToken;
@class EdgeList;
@class Book;
@class Edge;
//typedef enum {
//	VERB,
//	NOUN,
//    ADVERB,
//    PRONOUN,
//    DETERMINER,
//	PLACENAME,
//	PERSONALNAME,
//    ORGANIZATIONNAME,
//	ADJECTIVE,
//    UNKNOWN
//} WordType;

typedef NS_OPTIONS(NSUInteger, WordType) {
	VERB = 0,
	NOUN = 1,
    ADVERB = 2,
    PRONOUN = 3,
    DETERMINER = 4,
	PLACENAME = 5,
	PERSONALNAME = 6,
    ORGANIZATIONNAME = 7,
	ADJECTIVE = 8,
    UNKNOWN = 9,
    PROPERNOUN = 10,
    IDIOM = 11,
    CLASSIFIER = 12
};

@interface Node : NSObject <NSCoding>

@property (unsafe_unretained) Book * book;
@property NSUInteger key;
@property NSString * word;
@property WordType wordType;
@property EdgeList * edges;
@property NSUInteger frequency;
@property float proportional; //Calculated as needed, do not rely on this to contain relevant data.
@property NSMutableArray * positions; // To save on space, this array is doubled up. This means the first number in the array is the offset into the text, the second is the word number. This is to be able to find edge positions between words that are separated by stripped words in the text. i.e. location1 != location1 but wordNumber1 == wordNumber2


+ (instancetype)nodeWithWordToken:(WordToken *)wordToken inc:(BOOL)inc book:(Book *)book;

- (void)incrementFrequency;
- (void)addEdgeToWordWithToken:(WordToken *)wordToken weight:(NSUInteger)weight;
- (void)addEdge:(Edge *)edge;
- (NSArray *)getAllEdges; //Sort by frequency
- (NSArray *)getEdgesByWordType:(WordType)wordType;
- (NSComparisonResult)compare:(Node *)other;
@end
