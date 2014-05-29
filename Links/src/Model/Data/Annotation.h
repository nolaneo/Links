//
//  Annotation.h
//  Links
//
//  Created by Eoin Nolan on 06/05/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Annotation : NSObject <NSCoding>

typedef NS_OPTIONS(NSUInteger, AnnotationType) {
	NODE = 0,
	EDGE = 1,
    BOOK = 2
};

@property NSString * text;
@property NSNumber * books; //Hashed UUID XORed of retained set
@property AnnotationType type;
@property NSString * bookTitles;
@property NSString * name;

+ (NSNumber *)getKey:(NSSet *)books;

@end
