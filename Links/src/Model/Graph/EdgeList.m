//
//  EdgeList.m
//  Links
//
//  Created by Eoin Nolan on 17/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import "EdgeList.h"
#import "Book.h"
#import "Edge.h"


@implementation EdgeList

+ (instancetype)edgeListForNode:(Node *)node {
    EdgeList * edgeList = [[EdgeList alloc] init];
    edgeList.edges = [NSMutableSet set];
    edgeList.parent = node;
    return edgeList;
}

- (void)addEdgeToNode:(Node *)node weight:(NSUInteger)weight {
    Edge * edge = [Edge edgeWithNode:self.parent node:node weight:weight];
    [node addEdge:edge];
    [self.edges addObject:edge];
}

- (void)addEdge:(Edge *)edge {
    [self.edges addObject:edge];
}

- (NSArray *)getAllEdges {
    return [self.edges allObjects];
}

- (NSArray *)getEdgesByWordType:(WordType)wordType {
    NSMutableArray * edgesWithType = [NSMutableArray array];
    for (Edge * edge in self.edges) {
        if ([edge adjacentNodeTo:self.parent hasWordType:wordType]) {
            [edgesWithType addObject:edge];
        }
    }
    return edgesWithType;
}

//- (void)mergeEdgelist:(EdgeList *)other book:(Book *)book {
//    @autoreleasepool {
//        NSMutableSet * keys = [NSMutableSet set];
//        for (Edge * e in self.edges) {
//            Edge * other = [book.edges objectForKey:[e key]];
//            if (other != Nil) {
//                e.weight += other.weight;
//                [keys addObject:[e key]];
//            }
//        }
//        for (Edge * e in other) {
//            e.
//        }
//    }
//}

//------------------- Encoding/Decoding --------------------

- (void)encodeWithCoder:(NSCoder *)enCoder {
        [enCoder encodeObject:self.edges forKey:@"edges"];
        [enCoder encodeObject:self.parent forKey:@"parent"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.edges = [aDecoder decodeObjectForKey:@"edges"];
        self.parent = [aDecoder decodeObjectForKey:@"parent"];
    }
    return self;
}


@end
