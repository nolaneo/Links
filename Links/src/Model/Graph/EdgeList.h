//
//  EdgeList.h
//  Links
//
//  Created by Eoin Nolan on 17/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"
@class Edge;
@interface EdgeList : NSObject <NSCoding>

@property NSMutableSet * edges;
@property (unsafe_unretained) Node * parent;


+ (instancetype)edgeListForNode:(Node *)node;

- (void)addEdgeToNode:(Node *)node weight:(NSUInteger)weight;
- (void)addEdge:(Edge *)edge;
- (NSArray *)getAllEdges;
- (NSArray *)getEdgesByWordType:(WordType)wordType;
//- (void)mergeEdgelist:(EdgeList *)other book:(Book *)book;

@end
