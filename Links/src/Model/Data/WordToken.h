//
//  WordToken.h
//  Links
//
//  Created by Eoin Nolan on 18/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface WordToken : NSObject

@property NSString * word;
@property WordType type;
@property NSNumber * position;
@property NSUInteger wordNumber;

+ (instancetype)tokenWithWord:(NSString *)word type:(NSString *)type position:(NSNumber *)position wordNumber:(NSUInteger)wordNumber;

+ (NSString *)wordTypeToString:(WordType)wordType;
+ (UIColor *)wordTypeToColor:(WordType)wordType;
@end
