//
//  Edge.h
//  Links
//
//  Created by Eoin Nolan on 17/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface Edge : NSObject <NSCoding>

@property (unsafe_unretained) Node * left;
@property (unsafe_unretained) Node * right;
@property NSUInteger weight;


+ (instancetype)edgeWithNode:(Node *)left node:(Node *)right weight:(NSUInteger)weight;
- (Node *)getAdjacentNodeTo:(Node *)node;
- (BOOL)adjacentNodeTo:(Node *)node hasWordType:(WordType)wordType;
- (NSComparisonResult)compare:(Edge *)other;
- (void)reloadEdgeInBook:(Book *)book;
- (NSArray *)getEdgeLocations;
- (NSNumber *)key;
@end