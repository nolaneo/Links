//
//  Annotation.m
//  Links
//
//  Created by Eoin Nolan on 06/05/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "Annotation.h"
#import "BookInfo.h"
#import "Book.h"
@implementation Annotation

- (void)encodeWithCoder:(NSCoder *)enCoder {
    [enCoder encodeObject:self.text forKey:@"text"];
    [enCoder encodeInteger:self.type forKey:@"type"];
    [enCoder encodeObject:self.books forKey:@"books"];
    [enCoder encodeObject:self.bookTitles forKey:@"titles"];
    [enCoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.books = [aDecoder decodeObjectForKey:@"books"];
        self.type = [aDecoder decodeIntegerForKey:@"type"];
        self.bookTitles = [aDecoder decodeObjectForKey:@"titles"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

+ (NSNumber *)getKey:(NSSet *)books {
    NSUInteger key = 0;
    
    for (Book * book in books) {
        key ^= [book.bookInfo.UUID hash];
    }
    
    return @(key);
}

@end
