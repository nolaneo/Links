//
//  BookCollection.h
//  Links
//
//  Created by Eoin Nolan on 06/03/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, FilterArgument) {
    ASCENDING = 1
};

@interface BookCollection : NSObject
@property NSSet * books;

@property NSString * searchString;
@property BOOL ascending, words, proportionalSubtraction, join;
@property NSMutableSet * lexicalClasses, * retainSet, * discardSet;
@property NSArray * lastResults;

+ (instancetype)collectionWithBooks:(NSSet *)books;
- (NSArray *)applyFilters;
- (NSArray *)applySearch;
- (NSArray *)allWords;
- (NSArray *)booksIn:(NSSet *)retainSet booksNotIn:(NSSet *)discardSet filterWithArguments:(NSString *)arg1, ... NS_REQUIRES_NIL_TERMINATION;
@end
