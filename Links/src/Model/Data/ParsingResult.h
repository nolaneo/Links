//
//  ParsingResult.h
//  Links
//
//  Created by Eoin Nolan on 02/05/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParsingResult : NSObject
@property NSArray * thread_wordTokens;
@property NSArray * thread_sentimentOffsets;
@property NSArray * thread_chapterLocations;
@property NSArray * thread_chapterNames;
@property int thread_wordCount;
@end
