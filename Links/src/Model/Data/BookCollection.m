//
//  BookCollection.m
//  Links
//
//  Created by Eoin Nolan on 06/03/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "Book.h"
#import "Node.h"
#import "BookCollection.h"

@implementation BookCollection
+ (instancetype)collectionWithBooks:(NSSet *)books {
    BookCollection * collection = [[BookCollection alloc] init];
    collection.books = books;
    collection.retainSet = [NSMutableSet setWithSet:books];
    collection.discardSet = [NSMutableSet set];
    collection.lexicalClasses = [NSMutableSet setWithObjects:@(NOUN), @(PROPERNOUN), @(ADJECTIVE), @(ADVERB), @(VERB), @(CLASSIFIER), @(IDIOM), nil];
    collection.proportionalSubtraction = false; collection.words = true; collection.ascending = false; collection.join = false;
    return collection;
}

- (NSArray *)applyFilters {
    NSArray * result = [self booksIn:self.retainSet booksNotIn:self.discardSet proportional:self.proportionalSubtraction lexicalClasses:self.lexicalClasses];
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL compare = self.proportionalSubtraction ? @selector(compareProportional:) : @selector(compare:);
    #pragma clang diagnostic pop
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:self.ascending selector:compare];
    
    self.lastResults = [result sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    return self.lastResults;
}

- (NSArray *)booksIn:(NSSet *)retainSet booksNotIn:(NSSet *)discardSet filterWithArguments:(NSString *)arg1, ... NS_REQUIRES_NIL_TERMINATION {
    
    NSArray * result = [NSArray array];
    
    va_list args;
    va_start(args, arg1);
    BOOL ascending, words, proportionalSubtraction;
    proportionalSubtraction = false; words = true; ascending = false;
    NSMutableSet * lexicalClasses;
    for(NSString * filterArg = arg1; filterArg != nil; filterArg = va_arg(args, NSString *)) {
        if ([filterArg isEqualToString:@"ASCENDING"]) {
            ascending = true;
        }
        else if ([filterArg isEqualToString:@"DESCENDING"]) {
            ascending = false;
        }
        else if ([filterArg isEqualToString:@"PROPORTIONAL"]) {
            proportionalSubtraction = true;
        }
        else if ([filterArg isEqualToString:@"WORDS"]) {
            words = true;
        }
        else if ([filterArg isEqualToString:@"LINKS"]) {
            words = false;
        }
        else if ([filterArg isEqualToString:@"NOUN"]) {
            if (lexicalClasses == nil) {lexicalClasses = [NSMutableSet set];}
            [lexicalClasses addObject:@(NOUN)];
        }
        else if ([filterArg isEqualToString:@"ADJECTIVE"]) {
            if (lexicalClasses == nil) {lexicalClasses = [NSMutableSet set];}
            [lexicalClasses addObject:@(ADJECTIVE)];
        }
        else if ([filterArg isEqualToString:@"VERB"]) {
            if (lexicalClasses == nil) {lexicalClasses = [NSMutableSet set];}
            [lexicalClasses addObject:@(VERB)];
        }
        //MORE LEXICAL CLASSES COULD GO HERE
        else {
            [NSException raise:NSInvalidArgumentException format:@"Invalid argument string : %@", filterArg];
        }
        
    }
    va_end(args);
    
    result = [self booksIn:retainSet booksNotIn:discardSet proportional:proportionalSubtraction lexicalClasses:lexicalClasses];
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL compare = proportionalSubtraction ? @selector(compareProportional:) : @selector(compare:);
    #pragma clang diagnostic pop
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:ascending selector:compare];
    
    return [result sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

}

- (NSArray *)allWords {
    NSLog(@"Get All Words. %d books in collection", [self.books count]);
    NSMutableDictionary * combinedWords = [self getCombinedFrequenciesFromSet:self.books join:NO lexicalClasses:nil];
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(compare:)];
    return [[combinedWords allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (NSMutableDictionary *)getCombinedFrequenciesFromSet:(NSSet *)bookSet join:(BOOL)join lexicalClasses:(NSSet *)lexicalClasses {
    NSMutableDictionary * allWords = [NSMutableDictionary dictionary];

    float totalWordCount = 0;
    for (Book * book in bookSet) {
        totalWordCount += book.wordCount;
    }
    
    NSMutableSet * joinSet = [NSMutableSet set];
    
    for (Book * book in bookSet) {
        NSArray * words = [book getNodeFrequencies];
        for (Node * node in words) {
            if (lexicalClasses != nil && ![lexicalClasses containsObject:@(node.wordType)]) {
                continue;
            }
            Node * existingNode = [allWords objectForKey:@(node.key)];
            if (existingNode == nil) {
                existingNode = [node copy];
                if (join) [joinSet addObject:@(node.key)];
            } else {
                existingNode.frequency += node.frequency;
                if (join) [joinSet removeObject:@(node.key)];
            }
            
            [allWords setObject:existingNode forKey:@(existingNode.key)];
        }
    }
    
    //If using AND join then remove all nodes which only appeared once
    if (join) {
        for (NSNumber * key in joinSet) {
            [allWords removeObjectForKey:key];
        }
    }
    
    //Calculate node proportion, i.e. a fractional value 0.0 -> 1.0 of how often it appears in the text. 0.5 meaning it would be every second word.
    for (Node * node in [allWords allValues]) {
        node.proportional = (float)node.frequency / totalWordCount;
    }
    
    return allWords;
}

- (NSArray *)booksIn:(NSSet *)retainSet booksNotIn:(NSSet *)discardSet proportional:(BOOL)proportional lexicalClasses:(NSSet *)lexicalClasses{
    
    NSMutableDictionary * retainedWords = [self getCombinedFrequenciesFromSet:retainSet join:self.join lexicalClasses:lexicalClasses];
    NSMutableDictionary * discardedWords = [self getCombinedFrequenciesFromSet:discardSet join:self.join lexicalClasses:lexicalClasses];
    
    if (proportional) {
        for (Node * node in [discardedWords allValues]) {
            @autoreleasepool {
                Node * targetNode = [retainedWords objectForKey:@(node.key)];
                if (targetNode != nil) {
                    targetNode.proportional = targetNode.proportional - node.proportional;
                    if (targetNode.proportional < 0) {
                        [retainedWords removeObjectForKey:@(node.key)];
                    }
                }
            }
        }
    } else {
        for (Node * node in [discardedWords allValues]) {
            [retainedWords removeObjectForKey:@(node.key)];
        }
    }
    return [retainedWords allValues];
}

- (NSArray *)applySearch {
    if (self.searchString == nil || [self.searchString isEqualToString:@""]) {
        return self.lastResults;
    }
    NSArray * searchResults = [NSArray array];
    NSPredicate * resultPredicate = [NSPredicate predicateWithFormat:@"word BEGINSWITH[c] %@", self.searchString];
    searchResults = [self.lastResults filteredArrayUsingPredicate:resultPredicate];
    return searchResults;
}

@end
