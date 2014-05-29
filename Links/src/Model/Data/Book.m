//
//  Book.m
//  Links
//
//  Created by Eoin Nolan on 17/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import "Book.h"
#import "BookInfo.h"
#import "Node.h"
#import "Edge.h"
#import "EdgeList.h"
#import "Logger.h"
#import "WordToken.h"
#import "Library.h"
#import "ParsingResult.h"
#import "Definitions.h"

#define ADJACENCY 5
#define NUM_THREADS 2

@interface Book ()
@property NSDictionary * sentimentData;
@property NSSet * chapterLabels;
@property _Atomic(int) adjectives;
@property _Atomic(int) nouns;
@property _Atomic(int) verbs;
@property _Atomic(int) totalOffset;
@property float textLength;
@end


@implementation Book

+ (instancetype)bookWithInfo:(BookInfo *)info {
    Book * book = [[Book alloc] init];
    book.nodes = [NSMutableDictionary dictionary];
    book.edges = [NSMutableDictionary dictionary];
    book.text = [NSMutableString stringWithString:[info.text copy]];
    book.bookInfo = info;
    return book;
}

+ (instancetype)bookWithFilename:(NSString *)filename filetype:(NSString *)filetype{
    Book * book = [[Book alloc] init];
    book.nodes = [NSMutableDictionary dictionary];
    book.edges = [NSMutableDictionary dictionary];
    book.bookInfo = [[BookInfo alloc] init];
    NSString * path = [[NSBundle mainBundle] pathForResource:filename ofType:filetype];
    NSString * content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    book.bookInfo.text = content;
    book.text = [NSMutableString stringWithString:content];
    NSLog(@"Created Book with UUID : %@", book.bookInfo.UUID.UUIDString);
    return book;
}

+ (instancetype)bookTestInit {
    Book * book = [[Book alloc] init];
    book.nodes = [NSMutableDictionary dictionary];
    book.edges = [NSMutableDictionary dictionary];
    book.text = [NSMutableString stringWithString:@""];
    return book;
}

- (void)setDelegate:(UIViewController<BookProcessingDelegate> *)delegateIn {
    delegate = delegateIn;
}

// Single Threaded implementation for reference
- (void)processBookWithCompletion:(BookProcessCompleteBlock)completionBlock {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    @autoreleasepool {
        [self updateStatusLabel:@"Classifying Words"];
        [self loadSentimentData];
        [self loadChapterLabels];
        
        NSDate * methodBegin = [NSDate date];
        _chapterNames = [NSMutableArray array];
        _chapterLocations = [NSMutableArray array];
        NSArray * stringsArray = [self.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        self.text = [stringsArray componentsJoinedByString:@"\n"];
        
        NSLinguisticTaggerOptions options =
        NSLinguisticTaggerOmitWhitespace  |
        NSLinguisticTaggerOmitPunctuation |
        NSLinguisticTaggerJoinNames;
        
        NSLinguisticTagger * tagger = [[NSLinguisticTagger alloc]
                                       initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"]
                                       options:options];
        
        
        float textLength = [self.text length];
        NSMutableArray * tokens = [NSMutableArray array];
        NSMutableArray * totalPositiveSentiment = [NSMutableArray array];
        NSMutableArray * totalNegativeSentiment = [NSMutableArray array];
        
        __block int totalWordCount = 0;
        __block int totalOffset = 0;
        __block float positiveSentiment = 0;
        __block float negativeSentiment = 0;
        __block int count = 0;
        __block float maxSentiment = -1.0;
        __block float minSentiment = 1.0;
        
        __block float sentimentWords = 0.00001;
        
        __block int wordNumber = 0;
        
        __block struct ProcessingUpdate processingUpdate = {0,0,0,0,0,0,0};
        
        __block float averageSentiment = 0;
        __block float senimentCount = 0;
        
        NSMutableArray * segmentPositiveSentiment = [NSMutableArray array];
        NSMutableArray * segmentNegativeSentiment = [NSMutableArray array];
        
        self.sentimentOffsets = [NSMutableArray arrayWithObject:@(0)];
        
        for (NSString * sentence in stringsArray) {
            @autoreleasepool {
                tagger.string = sentence;
                [tagger enumerateTagsInRange:NSMakeRange(0, [sentence length])
                                      scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass
                                     options:options
                                  usingBlock:^(NSString * tag, NSRange tokenRange, NSRange sentenceRange, BOOL * stop) {
                                      
                                      NSString * token = [sentence substringWithRange:tokenRange];
                                      
                                      if ([_chapterLabels containsObject:token]) {
                                          [_chapterLocations addObject:@(totalOffset)];
                                          [_chapterNames addObject:token];
                                      }
                                      
                                      WordToken * wordToken = [WordToken tokenWithWord:token type:tag position:@(totalOffset + tokenRange.location) wordNumber:-1]; //set word number to -1, change it to real number if type not unknown
                                      
                                      if (wordToken.type != UNKNOWN) {
                                          NSLog(@"%@ - %@", token, tag);
                                          wordToken.wordNumber = wordNumber++;
                                          [tokens addObject:wordToken];
                                          NSNumber * wordSentiment = [_sentimentData objectForKey:[token lowercaseString]];
                                          if (wordSentiment != nil) {
                                              if ([wordSentiment floatValue] > 0) {
                                                  positiveSentiment += [wordSentiment floatValue];
                                              } else {
                                                  negativeSentiment += [wordSentiment floatValue];
                                              }
                                              
                                              sentimentWords += 1;
                                          }
                                          switch (wordToken.type) {
                                              case NOUN:
                                                  processingUpdate.nouns++;
                                                  break;
                                              case PROPERNOUN:
                                                  processingUpdate.propernouns++;
                                                  break;
                                              case ADJECTIVE:
                                                  processingUpdate.adjectives++;
                                                  break;
                                              case ADVERB:
                                                  processingUpdate.adverbs++;
                                                  break;
                                              case VERB:
                                                  processingUpdate.verbs++;
                                                  break;
                                              case IDIOM:
                                                  processingUpdate.idioms++;
                                                  break;
                                              case CLASSIFIER:
                                                  processingUpdate.classifiers++;
                                                  break;
                                              default:
                                                  [NSException raise:NSGenericException format:@"Unexpected WordType."];
                                                  break;
                                          }
                                      }
                                      
                                      if (++count == 100) {
                                          float thisPositiveSentiment = positiveSentiment/sentimentWords;
                                          float thisNegativeSentiment = negativeSentiment/sentimentWords;
                                          
                                          NSNumber * sectionPositiveSentiment = [NSNumber numberWithFloat:thisPositiveSentiment];
                                          NSNumber * sectionNegativeSentiment = [NSNumber numberWithFloat:thisNegativeSentiment];
                                          
                                          
                                          [segmentPositiveSentiment addObject:sectionPositiveSentiment];
                                          [segmentNegativeSentiment addObject:sectionNegativeSentiment];
                                          
                                          if ([segmentPositiveSentiment count] == 3) {
                                              float psegment = ([[segmentPositiveSentiment objectAtIndex:0] floatValue] + [[segmentPositiveSentiment objectAtIndex:1] floatValue] +[[segmentPositiveSentiment objectAtIndex:2] floatValue]) / 3;
                                              
                                              float nsegment = ([[segmentNegativeSentiment objectAtIndex:0] floatValue] + [[segmentNegativeSentiment objectAtIndex:1] floatValue] +[[segmentNegativeSentiment objectAtIndex:2] floatValue]) / 3;
                                              
                                              [segmentPositiveSentiment removeLastObject];
                                              [segmentNegativeSentiment removeLastObject];
                                              
                                              averageSentiment += (psegment + nsegment);
                                              senimentCount++;
                                              
                                              [totalPositiveSentiment addObject:@(psegment)];
                                              [totalNegativeSentiment addObject:@(nsegment)];
                                              
                                              [self.sentimentOffsets addObject:@(totalOffset + tokenRange.location)];
                                              
                                              maxSentiment = MAX(maxSentiment, psegment);
                                              minSentiment = MIN(minSentiment, nsegment);

                                          }

                                          
                                          positiveSentiment = 0;
                                          negativeSentiment = 0;
                                          sentimentWords = 0.00001;
                                          count = 0;
                                      }
                                      
                                      totalWordCount ++;
                                  }];
                totalOffset += [sentence length] + 1;
                [self updateTokenizationProgress:(float)(totalOffset)/(float)textLength];

                [self updateWordProcessingTotal:processingUpdate];
            }
        }
        [self updateWordProcessingTotal:processingUpdate];
        
        NSLog(@"NOUNS : %d, PROPER NOUNS : %d, VERBS : %d, ADJECTIVES : %d, ADVERBS : %d", processingUpdate.nouns, processingUpdate.propernouns, processingUpdate.verbs, processingUpdate.adjectives, processingUpdate.adverbs);
        
        self.wordCount = totalWordCount;
        self.positiveSentiment = totalPositiveSentiment;
        self.negativeSentiment = totalNegativeSentiment;
        self.minSentiment = minSentiment;
        self.maxSentiment = maxSentiment;
    
        
        NSDate * methodEnd = [NSDate date];
        NSTimeInterval executionTime = [methodEnd timeIntervalSinceDate:methodBegin];
        LOG_i(@"Tokenization Time : %f : Words processed : %lu. Tokens Retained : %d", executionTime, (unsigned long)self.wordCount, [tokens count]);
        [self generateGraphFromTokens:tokens];
        
        self.bookInfo.sentiment = averageSentiment / senimentCount;
        self.bookInfo.nodeCount = self.nodes.count;
        self.bookInfo.edgeCount = self.edges.count;
        NSLog(@"Average Sentiment = %f", self.bookInfo.sentiment);
        
        completionBlock(@"Completed");
        
        methodEnd = [NSDate date];
        executionTime = [methodEnd timeIntervalSinceDate:methodBegin];
        LOG_i(@"Total Time : %f", executionTime)
        
        _sentimentData = nil;
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
}

- (void)processTestBookWithCompletion:(BookProcessCompleteBlock)completionBlock {
    NSDate * methodBegin = [NSDate date];
    [self updateStatusLabel:@"Classifying Words"];
    
    self.wordCount = 100000;
    NSMutableArray * tokens = [NSMutableArray array];
    
    for (int i = 0; i < self.wordCount; ++i) {
        WordToken * wordToken = [WordToken tokenWithWord:[NSString stringWithFormat:@"%d", i] type:NSLinguisticTagNoun position:@(i) wordNumber:i];
        [tokens addObject:wordToken];
    }
    
    NSDate * methodEnd = [NSDate date];
    NSTimeInterval executionTime = [methodEnd timeIntervalSinceDate:methodBegin];
    
    LOG_i(@"Tokenization Time : %f : Words processed : %lu", executionTime, (unsigned long)self.wordCount);
    [self generateGraphFromTokens:tokens];
    completionBlock(@"Completed");
}

- (void)generateGraphFromTokens:(NSArray *)tokens {
    
    [self updateTokenizationProgress:0];
    [self updateStatusLabel:@"Generating Graph Structure"];
    
    NSDate * methodBegin = [NSDate date];
    
    for (int i = 0; i < [tokens count]; ++i) {
        @autoreleasepool {
            WordToken * wt = [tokens objectAtIndex:i];
            Node * node = [Node nodeWithWordToken:wt inc:YES book:self];
            for (int j = i + 1, weight = ADJACENCY; j < [tokens count] && j <= i + ADJACENCY; ++j, --weight) {
                WordToken * adjacent = [tokens objectAtIndex:j];
                if (j == i+1 || (node.wordType == PROPERNOUN && adjacent.type == PROPERNOUN) ) {
                    [node addEdgeToWordWithToken:adjacent weight:weight];
                }
            }
            [self updateGraphCreationProgress:(float)i/(float)[tokens count]];
        }
    }
    
    NSDate * methodEnd = [NSDate date];
    NSTimeInterval executionTime = [methodEnd timeIntervalSinceDate:methodBegin];
    LOG_i(@"Graph Construction Time : %f :: Nodes : %lu -- Edges : %d", executionTime, (unsigned long)[self.nodes count], [self.edges count]);
    NSString * result = [NSString stringWithFormat:@"Nodes : %lu -- Edges : %lu", (unsigned long)[self.nodes count], (unsigned long)[self.edges count]];
    [self updateStatusLabel:@"Saving to disk"];
    [self updateStatusLabel:result];
}

- (void)loadSentimentData {
    NSString * filePath = [[NSBundle mainBundle] pathForResource:SENTIMENT_DATASET ofType:@"data"];
    _sentimentData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

//These chapter names are for demonstration purposes only
- (void)loadChapterLabels {
    _chapterLabels = [NSSet setWithObjects:@"PROLOGUE",@"EDDARD",@"JON",@"TYRION",@"CATELYN",@"BRAN",@"DAENERYS",@"ARYA",@"SANSA",
                    @"Chapter1", @"Chapter2", @"Chapter3", @"Chapter4", @"Chapter5", @"Chapter6", @"Chapter7", @"Chapter8", @"Chapter9", @"Chapter10", @"Chapter11", @"Chapter12", @"Chapter13", @"Chapter14", @"Chapter15", @"Chapter16", @"Chapter17", @"Chapter18", @"Chapter19", @"Chapter20", @"Chapter21", @"Chapter22", @"Chapter23", @"Chapter24", @"Chapter25", @"Chapter26", @"Chapter27", @"Chapter28", @"Chapter29", @"Chapter30", @"Chapter31", @"Chapter32", @"Chapter33", @"Chapter34", @"Chapter35", @"Chapter36", @"Chapter37", @"Chapter38", @"Chapter39", @"Chapter40", @"Chapter41", @"Chapter42", @"Chapter43", @"Chapter44", @"Chapter45", @"Chapter46", @"Chapter47", @"Chapter48", @"Chapter49", @"Chapter50", @"Chapter51", @"Chapter52", @"Chapter53", @"Chapter54", @"Chapter55", @"Chapter56", @"Chapter57", @"Chapter58", @"Chapter59", @"Chapter60", @"Chapter61", @"Chapter62", @"Chapter63", @"Chapter64", @"Chapter65", @"Chapter66", @"Chapter67", @"Chapter68", @"Chapter69",nil];
}

//--------------------------------------

- (NSArray *)getNodeFrequencies {
    if (nodeFrequencies == nil) {
        NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(compare:)];
        nodeFrequencies = [self.nodes.allValues sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    return nodeFrequencies;
}
- (NSArray *)getEdgeFrequencies {
    if (edgeFrequencies == nil) {
        NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(compare:)];
        edgeFrequencies = [self.edges.allValues sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    return edgeFrequencies;
}

//------------------- UI Update Operations --------------------

- (void)updateTokenizationProgress:(float)progress {
    [delegate performSelectorOnMainThread:@selector(updateTokenizationProgress:)
                               withObject:[NSNumber numberWithFloat:progress]
                            waitUntilDone:NO];
}

- (void)updateGraphCreationProgress:(float)progress {
    [delegate performSelectorOnMainThread:@selector(updateGraphCreationProgress:)
                               withObject:[NSNumber numberWithFloat:progress]
                            waitUntilDone:NO];
    [delegate updateGraphProcessingWithNodes:self.nodes.count edges:self.edges.count];
}

- (void)updateStatusLabel:(NSString *)status {
    [delegate performSelectorOnMainThread:@selector(updateStatusLabel:)
                               withObject:status
                            waitUntilDone:NO];
}

- (void)updateProcessingCountsWithNouns:(NSUInteger)nouns verbs:(NSUInteger)verbs adjectives:(NSUInteger)adjectives {
    [delegate updateWordProcessingTotalNouns:nouns verbs:verbs adjectives:adjectives];
}

- (void)updateWordProcessingTotal:(struct ProcessingUpdate)update {
    [delegate updateWordProcessingTotal:update];
}
 
//------------------- Encoding/Decoding --------------------

- (void)encodeWithCoder:(NSCoder *)enCoder {
    [enCoder encodeObject:self.text forKey:@"text"];
    [enCoder encodeInteger:self.wordCount forKey:@"wordCount"];
    [enCoder encodeObject:self.bookInfo forKey:@"bookInfo"];
    [enCoder encodeObject:self.nodes forKey:@"nodes"];
    [enCoder encodeObject:self.edges forKey:@"edges"];
    [enCoder encodeObject:self.positiveSentiment forKey:@"positiveSentiment"];
    [enCoder encodeObject:self.negativeSentiment forKey:@"negativeSentiment"];
    [enCoder encodeObject:self.chapterLocations forKey:@"chapterLocations"];
    [enCoder encodeObject:self.chapterNames forKey:@"chapterNames"];
    [enCoder encodeFloat:self.maxSentiment forKey:@"maxSentiment"];
    [enCoder encodeFloat:self.minSentiment forKey:@"minSentiment"];
    [enCoder encodeObject:self.sentimentOffsets forKey:@"sentimentOffsets"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        @autoreleasepool {

            self.text = [aDecoder decodeObjectForKey:@"text"];
            self.wordCount = [aDecoder decodeIntegerForKey:@"wordCount"];
            self.bookInfo = [aDecoder decodeObjectForKey:@"bookInfo"];
            self.nodes = [aDecoder decodeObjectForKey:@"nodes"];
            self.edges = [aDecoder decodeObjectForKey:@"edges"];
            self.positiveSentiment = [aDecoder decodeObjectForKey:@"positiveSentiment"];
            self.negativeSentiment = [aDecoder decodeObjectForKey:@"negativeSentiment"];
            self.chapterLocations = [aDecoder decodeObjectForKey:@"chapterLocations"];
            self.chapterNames = [aDecoder decodeObjectForKey:@"chapterNames"];
            self.maxSentiment = [aDecoder decodeFloatForKey:@"maxSentiment"];
            self.minSentiment = [aDecoder decodeFloatForKey:@"minSentiment"];
            self.sentimentOffsets = [aDecoder decodeObjectForKey:@"sentimentOffsets"];

            for (Edge * edge in [self.edges allValues]) {
                [edge reloadEdgeInBook:self];
            }

        }
            
    }
    return self;
}

- (void)save {
    [Library cacheBook:self withUUID:self.bookInfo.UUID];
    NSString * fileName = [NSString stringWithFormat:@"book-%@.archive", self.bookInfo.UUID.UUIDString];
    NSString * filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
    if ([NSKeyedArchiver archiveRootObject:self toFile:filePath]) {
        NSLog(@"Book sucessfully saved to file.");
    } else {
        NSLog(@"ERROR: Book not saved to file.");
    }
}

+ (instancetype)load:(NSUUID *)uuid {
    NSString * fileName = [NSString stringWithFormat:@"book-%@.archive", uuid.UUIDString];
    NSString * filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
    Book * book = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (book == nil) {
        NSLog(@"ERROR: Book was not loaded from file");
    }
    [Library cacheBook:book withUUID:uuid];
    return book;
}

//A Multithreaded implementation. Not used just testing the speedup possibilities. NSLingusitic tagger heavily influences speed as is single threaded at the OS level (i assume) therefore mulithreading only achieves around a ~7% speedup.
//- (void)processBookWithCompletionMT:(BookProcessCompleteBlock)completionBlock {
//    @autoreleasepool {
//        [self updateStatusLabel:@"Classifying Words"];
//        [self loadSentimentData];
//        [self loadChapterLabels];
//        
//        NSDate * methodBegin = [NSDate date];
//        _chapterNames = [NSMutableArray array];
//        _chapterLocations = [NSMutableArray array];
//        
//        _nouns = 0;
//        _verbs = 0;
//        _adjectives = 0;
//        _totalOffset = 0;
//        
//        NSArray * stringsArray = [self.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
//        
//        self.text = [stringsArray componentsJoinedByString:@"\n"];
//        
//        NSArray * stringsForThreadA = [stringsArray subarrayWithRange:NSMakeRange(0, [stringsArray count]/2)];
//        NSArray * stringsForThreadB = [stringsArray subarrayWithRange:NSMakeRange([stringsArray count]/2, [stringsArray count] - [stringsArray count]/2)];
//        
//        _textLength = [self.text length];
//        
//        dispatch_group_t d_group = dispatch_group_create();
//        dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//        
//        __block ParsingResult * threadAResults, * threadBResults;
//        dispatch_group_async(d_group, bg_queue, ^{
//            NSLog(@"START THREAD A");
//            threadAResults = [self runTokenizationThreadWithText:stringsForThreadA startOffset:0];
//            NSLog(@"FINISH THREAD A");
//        });
//        
//        dispatch_group_async(d_group, bg_queue, ^{
//            NSLog(@"START THREAD B");
//            threadBResults = [self runTokenizationThreadWithText:stringsForThreadB startOffset:[stringsForThreadA componentsJoinedByString:@"\n"].length];
//            NSLog(@"FINISH THREAD B");
//        });
//        
//        // you can do this to synchronously wait on the current thread:
//        dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
//        
//        NSLog(@"All background tasks are done!!");
//        
//        self.wordCount = threadAResults.thread_wordCount + threadBResults.thread_wordCount;
//        //self.sentiment = totalSentiment;
//        //self.minSentiment = minSentiment;
//        //self.maxSentiment = maxSentiment;
//        NSArray * tokens = [threadAResults.thread_wordTokens arrayByAddingObjectsFromArray:threadBResults.thread_wordTokens];
//        NSDate * methodEnd = [NSDate date];
//        NSTimeInterval executionTime = [methodEnd timeIntervalSinceDate:methodBegin];
//        LOG_i(@"Tokenization Time : %f : Words processed : %lu. Tokens Retained : %d", executionTime, (unsigned long)self.wordCount, [tokens count]);
//        [self generateGraphFromTokens:tokens];
//        completionBlock(@"Completed");
//        _sentimentData = nil;
//    }
//}
//
//- (ParsingResult *)runTokenizationThreadWithText:(NSArray *)stringsArray startOffset:(NSUInteger)startOffset {
//    
//    NSLinguisticTaggerOptions options =
//    NSLinguisticTaggerOmitWhitespace  |
//    NSLinguisticTaggerOmitPunctuation |
//    NSLinguisticTaggerJoinNames;
//    
//    NSLinguisticTagger * tagger = [[NSLinguisticTagger alloc] initWithTagSchemes: [NSLinguisticTagger availableTagSchemesForLanguage:@"en"] options:options];
//    
//    NSMutableArray * tokens = [NSMutableArray array];
//    NSMutableArray * totalSentiment = [NSMutableArray array];
//    NSMutableArray * localChapterLocations = [NSMutableArray array];
//    NSMutableArray * localChapterNames = [NSMutableArray array];
//    
//    __block int totalWordCount = 0;
//    __block int localOffset = 0;
//    __block float sentiment = 0;
//    __block int count = 0;
//    __block float maxSentiment = 0;
//    __block float minSentiment = 0;
//    __block float sentimentWords = 0.00001;
//    __block int wordNumber = 0;
//    NSMutableArray * localSentimentOffsets = [NSMutableArray arrayWithObject:@(startOffset)];
//    for (NSString * sentence in stringsArray) {
//        @autoreleasepool {
//            tagger.string = sentence;
//            [tagger enumerateTagsInRange:NSMakeRange(0, [sentence length])
//                                  scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass
//                                 options:options
//                              usingBlock:^(NSString * tag, NSRange tokenRange, NSRange sentenceRange, BOOL * stop) {
//                                  
//                                  NSString * token = [sentence substringWithRange:tokenRange];
//                                  
//                                  if ([_chapterLabels containsObject:token]) {
//                                      [localChapterLocations addObject:@(totalWordCount)];
//                                      [localChapterNames addObject:token];
//                                  }
//                                  
//                                  WordToken * wordToken = [WordToken tokenWithWord:token type:tag position:@(localOffset + tokenRange.location) wordNumber:-1];
//                                  
//                                  if (wordToken.type != UNKNOWN) {
//                                      wordToken.wordNumber = wordNumber++;
//                                      [tokens addObject:wordToken];
//                                      NSNumber * wordSentiment = [_sentimentData objectForKey:[token lowercaseString]];
//                                      if (wordSentiment != nil) {
//                                          sentiment += [wordSentiment floatValue];
//                                          sentimentWords += 1;
//                                      }
//                                      if (wordToken.type == ADJECTIVE) {
//                                          _adjectives++;
//                                      } else if (wordToken.type == VERB) {
//                                          _verbs++;
//                                      } else {
//                                          _nouns++;
//                                      }
//                                  }
//                                  
//                                  if (++count == 250) {
//                                      NSNumber * sectionSentiment = [NSNumber numberWithFloat:sentiment/sentimentWords];
//                                      [totalSentiment addObject:sectionSentiment];
//                                      maxSentiment = MAX(maxSentiment, [sectionSentiment floatValue]);
//                                      minSentiment = MIN(minSentiment, [sectionSentiment floatValue]);
//                                      sentiment = 0;
//                                      sentimentWords = 0.00001;
//                                      count = 0;
//                                      [localSentimentOffsets addObject:@(localOffset + tokenRange.location)];
//                                  }
//                                  
//                                  totalWordCount ++;
//                              }];
//            localOffset += [sentence length] + 1;
//            [self updateProcessingCountsWithNouns:_nouns verbs:_verbs adjectives:_adjectives];
//            _totalOffset += [sentence length] + 1;
//            [self updateTokenizationProgress:(float)_totalOffset/(float)_textLength];
//        }
//    }
//    
//    
//    ParsingResult * result = [[ParsingResult alloc] init];
//    result.thread_wordTokens = tokens;
//    result.thread_sentimentOffsets = localSentimentOffsets;
//    result.thread_chapterLocations = localChapterLocations;
//    result.thread_chapterNames = localChapterNames;
//    result.thread_wordCount = totalWordCount;
//    return result;
//}


@end
