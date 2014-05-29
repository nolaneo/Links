//
//  Node.m
//  Links
//
//  Created by Eoin Nolan on 17/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import "Node.h"
#import "EdgeList.h"
#import "Book.h"
#import "WordToken.h"

@implementation Node

+ (instancetype)nodeWithWordToken:(WordToken *)wordtoken inc:(BOOL)inc book:(Book *)book {
    @autoreleasepool {
    NSUInteger key = [[NSString stringWithFormat:@"%@%d", [wordtoken.word lowercaseString], wordtoken.type] hash];
    Node * node = [book.nodes objectForKey:@(key)];
    if (node == NULL) {
        node = [[Node alloc] init];
        node.book = book;
        node.wordType = wordtoken.type;
        node.key = key;
        node.word = wordtoken.word;
        node.positions = [NSMutableArray arrayWithObjects:wordtoken.position, @(wordtoken.wordNumber), nil];
        node.edges = [EdgeList edgeListForNode:node];
        node.frequency = inc ? 1 : 0; //If this node is being fetched as part of an edge operation, do not start at 1. The next iteration to this node will increase the count to the correct size.
        node.proportional = 0;
        [book.nodes setObject:node forKey:@(key)];
    } else if (inc) {
        [node.positions addObject:wordtoken.position];
        [node.positions addObject:@(wordtoken.wordNumber)];
        [node incrementFrequency];
    }
    return node;
    }
}

- (void)incrementFrequency {
    self.frequency ++;
}

- (void)addEdgeToWordWithToken:(WordToken *)wordToken weight:(NSUInteger)weight{
    Node * other = [Node nodeWithWordToken:wordToken inc:NO book:self.book];
    [self.edges addEdgeToNode:other weight:weight];
}

- (void)addEdge:(Edge *)edge {
    [self.edges addEdge:edge];
}

- (NSArray *)getAllEdges {
    NSArray * allEdges = [self.edges getAllEdges];
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(compare:)];
    return [allEdges sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (NSArray *)getEdgesByWordType:(WordType)wordType {
    NSArray * edgesWithType = [self.edges getEdgesByWordType:wordType];
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(compare:)];
    return [edgesWithType sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (NSComparisonResult)compare:(Node *)other {
    return [@(self.frequency) compare:@(other.frequency)];
}

- (NSComparisonResult)compareProportional:(Node *)other {
    return [@(self.proportional) compare:@(other.proportional)];
}

//------------------- Encoding/Decoding --------------------

- (void)encodeWithCoder:(NSCoder *)enCoder {
    @autoreleasepool {
        [enCoder encodeObject:self.book forKey:@"book"];
        [enCoder encodeInteger:self.key forKey:@"key"];
        [enCoder encodeObject:self.word forKey:@"word"];
        [enCoder encodeInteger:self.wordType forKey:@"wordType"];
        [enCoder encodeObject:self.edges forKey:@"edges"];
        [enCoder encodeInteger:self.frequency forKey:@"frequency"];
        [enCoder encodeObject:self.positions forKey:@"positions"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    @autoreleasepool {
    self = [super init];
    if(self) {
        self.book = [aDecoder decodeObjectForKey:@"book"];
        self.key = [aDecoder decodeIntegerForKey:@"key"];
        self.word = [aDecoder decodeObjectForKey:@"word"];
        self.wordType = [aDecoder decodeIntegerForKey:@"wordType"];
        self.edges = [aDecoder decodeObjectForKey:@"edges"];
        self.frequency = [aDecoder decodeIntegerForKey:@"frequency"];
        self.positions = [aDecoder decodeObjectForKey:@"positions"];
    }
    }
    return self;
}

//------------------- Copying --------------------

- (id)copy {
    Node * node = [[Node alloc] init];
    node.frequency = self.frequency;
    node.key = self.key;
    node.wordType = self.wordType;
    node.word = self.word;
    node.edges = self.edges;
    node.book = self.book;
    node.positions = self.positions;
    return node;
}

@end
