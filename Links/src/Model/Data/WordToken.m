//
//  WordToken.m
//  Links
//
//  Created by Eoin Nolan on 18/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import "WordToken.h"
#import "Definitions.h"

@implementation WordToken

+ (instancetype)tokenWithWord:(NSString *)word type:(NSString *)type position:(NSNumber *)position wordNumber:(NSUInteger)wordNumber{
    WordToken * wordToken = [[WordToken alloc] init];
    wordToken.word = word;
    wordToken.position = position;
    wordToken.wordNumber = wordNumber;
    
    //TODO : Use lookup here? // NOT USING PRONOUNS/DETERMINERS/ADVERBS
    if ([type isEqualToString:NSLinguisticTagNoun]) {
        char c = [word characterAtIndex:0];
        if (c >= 'A' && c <= 'Z') {
            wordToken.type = PROPERNOUN;
        } else {
            wordToken.type = NOUN;
        }
    } else
    if ([type isEqualToString:NSLinguisticTagVerb]) {
        wordToken.type = VERB;
    } else
    if ([type isEqualToString:NSLinguisticTagAdjective]) {
        wordToken.type = ADJECTIVE;
    } else
    if ([type isEqualToString:NSLinguisticTagPersonalName]) {
        wordToken.type = PROPERNOUN;
    } else
    if ([type isEqualToString:NSLinguisticTagPlaceName]) {
        wordToken.type = PROPERNOUN;
    } else
    if ([type isEqualToString:NSLinguisticTagOrganizationName]) {
        wordToken.type = PROPERNOUN;
    } else
    if ([type isEqualToString:NSLinguisticTagAdverb]) {
        wordToken.type = ADVERB;
    } else
    if ([type isEqualToString:NSLinguisticTagClassifier]) {
        wordToken.type = CLASSIFIER;
    } else
    if ([type isEqualToString:NSLinguisticTagIdiom]) {
        wordToken.type = IDIOM;
    } else {
        wordToken.type = UNKNOWN;
    }
    return wordToken;
}

+ (NSString *)wordTypeToString:(WordType)wordType {
    NSString * result = nil;
    
    switch(wordType) {
        case NOUN:
            result = @"NOUN";
            break;
        case VERB:
            result = @"VERB";
            break;
        case ADJECTIVE:
            result = @"ADJECTIVE";
            break;
        case ADVERB:
            result = @"ADVERB";
            break;
        case CLASSIFIER:
            result = @"CLASSIFIER";
            break;
        case IDIOM:
            result = @"IDIOM";
            break;
        case PROPERNOUN:
            result = @"PROPER NOUN";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected WordType."];
    }
    
    return result;
}

+ (UIColor *)wordTypeToColor:(WordType)wordType {
    UIColor * result = nil;
    
    switch(wordType) {
        case NOUN:
            result = UIColorFromRGB(0xe74c3c);
            break;
        case PROPERNOUN:
            result = UIColorFromRGB(0xc0392b);
            break;
        case VERB:
            result = UIColorFromRGB(0x16a085);
            break;
        case ADJECTIVE:
            result = UIColorFromRGB(0x27ae60);
            break;
        case IDIOM:
            result = UIColorFromRGB(0x2980b9);
            break;
        case ADVERB:
            result = UIColorFromRGB(0x8e44ad);
            break;
        case CLASSIFIER:
            result = UIColorFromRGB(0xf39c12);
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected WordType."];
    }
    
    return result;
}

@end
