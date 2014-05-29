//
//  Edge.m
//  Links
//
//  Created by Eoin Nolan on 17/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import "Edge.h"
#import "Node.h"
#import "Book.h"

#define ADJACENCY 5

@interface Edge()
+ (NSUInteger)generateKey:(Node *)a node:(Node *)b;
@property NSNumber * l;
@property NSNumber * r;
@end

@implementation Edge

+ (instancetype)edgeWithNode:(Node *)left node:(Node *)right weight:(NSUInteger)weight {
    @autoreleasepool {
    Book * book = left.book;
    NSUInteger key = [self generateKey:left node:right];
    Edge * edge = [book.edges objectForKey:@(key)];
    if (edge == NULL) {
        edge = [[Edge alloc] init];
        edge.left = left;
        edge.right = right;
        edge.weight = weight;
        // EDGE POSITIONS WERE A NICE IDEA BUT TAKE UP TOO MUCH MEMORY! CALCULATE EDGE LOCATION AS NEEDED FROM NODE POSITIONS
        //edge.positions = [NSMutableArray arrayWithObject:position];
        [book.edges setObject:edge forKey:@(key)];
    } else {
        edge.weight += weight;
        //[edge.positions addObject:position];
    }
    
    return edge;
    }
}

- (BOOL)adjacentNodeTo:(Node *)node hasWordType:(WordType)wordType {
    if (self.left.key == node.key) {
        return self.right.wordType == wordType;
    } else {
        return self.left.wordType == wordType;
    }
}

- (Node *)getAdjacentNodeTo:(Node *)node {
    if (self.left.key == node.key) {
        return self.right;
    } else {
        return self.left;
    }
}

- (NSComparisonResult)compare:(Edge *)other {
    return [@(self.weight) compare:@(other.weight)];
}

//-----------------------------------

- (NSNumber *)key {
    return @([Edge generateKey:self.left node:self.right]);
}

+ (NSUInteger)generateKey:(Node *)a node:(Node *)b {
    long long key = MIN(a.key, b.key);
    key = (key << 32) | MAX(a.key, b.key);
    return [[NSNumber numberWithLongLong:key] hash];
}

//------------------- Encoding/Decoding --------------------

- (void)encodeWithCoder:(NSCoder *)enCoder {
    @autoreleasepool {
        [enCoder encodeObject:@(self.left.key) forKey:@"left"];
        [enCoder encodeObject:@(self.right.key) forKey:@"right"];
        //[enCoder encodeObject:self.positions forKey:@"positions"];
        [enCoder encodeInteger:self.weight forKey:@"weight"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    @autoreleasepool {
    
    self = [super init];
    if (self) {
        _l = [aDecoder decodeObjectForKey:@"left"];
        _r = [aDecoder decodeObjectForKey:@"right"];
        self.left = nil;
        self.right = nil;
        //self.positions = [aDecoder decodeObjectForKey:@"positions"];
        self.weight = [aDecoder decodeIntegerForKey:@"weight"];
    }
    }
    return self;
        
}

- (void)reloadEdgeInBook:(Book *)book {
    _left = [book.nodes objectForKey:_l];
    _right = [book.nodes objectForKey:_r];
    _l = nil;
    _r = nil;
}

- (NSArray *)getEdgeLocations {
    NSMutableArray * locations = [NSMutableArray array];
    int matched = 0;
    int skipped = 0;
    for (int i = 1; i < [self.left.positions count]; i+=2) {

        for (int j = 1 + (matched*2) + (skipped*2), k = 0; j < [self.right.positions count] && k < ADJACENCY; j+=2) {
            int left  = [[self.left.positions objectAtIndex:i] integerValue];
            int right = [[self.right.positions objectAtIndex:j] integerValue];
            //NSLog(@"%d vs %d", left, right);
            if (left > right + ADJACENCY) {
                skipped++;
                continue;
            } else if (left < right - ADJACENCY) {
                break;
            }
            if (left >= right-ADJACENCY && left <= right+ADJACENCY) {
                [locations addObject:[self.left.positions objectAtIndex:i-1]];
                matched++;
                k++;
            }
        }
    }
    NSLog(@"Found %d pair locations", matched) ;
    return locations;
}

@end
