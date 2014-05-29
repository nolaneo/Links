//
//  BookInfo.m
//  Links
//
//  Created by Eoin Nolan on 14/02/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import "BookInfo.h"

@implementation BookInfo

- (id)init {
    self = super.init;
    if (self) {
        self.UUID = [NSUUID UUID];
    }
    return self;
}

//+ (id)bookWithAuthor:(NSString *)author title:(NSString *)title imageURL:(NSString *)imageURL year:(NSString *)year description:(NSString *)description ISBN:(NSString *)ISBN {
//    BookInfo * bookInfo = [[BookInfo alloc] init];
//    
//    bookInfo.author = author;
//    bookInfo.title = title;
//    bookInfo.imageURL = imageURL;
//    bookInfo.publicationYear = year;
//    bookInfo.description = description;
//    bookInfo.ISBN = ISBN;
//    
//    return bookInfo;
//}

- (void)encodeWithCoder:(NSCoder *)enCoder {
    NSLog(@"SAVING BOOKINFO : Title : %@, Words : %d, Edges : %d, Sentiment : %f", self.title, self.nodeCount, self.edgeCount, self.sentiment);
    [enCoder encodeBool:self.processed forKey:@"processed"];
    [enCoder encodeObject:self.text forKey:@"text"];
    [enCoder encodeObject:self.author forKey:@"author"];
    [enCoder encodeObject:self.title forKey:@"title"];
    [enCoder encodeObject:self.imageURL forKey:@"imageURL"];
    [enCoder encodeObject:self.publicationYear forKey:@"publicationYear"];
    [enCoder encodeObject:self.description forKey:@"description"];
    [enCoder encodeObject:self.ISBN forKey:@"ISBN"];
    [enCoder encodeObject:self.UUID forKey:@"UUID"];
    [enCoder encodeFloat:self.sentiment forKey:@"sentiment"];
    [enCoder encodeInt:self.nodeCount forKey:@"nodeCount"];
    [enCoder encodeInt:self.edgeCount forKey:@"edgeCount"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.processed = [aDecoder decodeBoolForKey:@"processed"];
        self.author = [aDecoder decodeObjectForKey:@"author"];
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
        self.publicationYear = [aDecoder decodeObjectForKey:@"publicationYear"];
        self.description = [aDecoder decodeObjectForKey:@"description"];
        self.ISBN = [aDecoder decodeObjectForKey:@"ISBN"];
        self.UUID = [aDecoder decodeObjectForKey:@"UUID"];
        self.sentiment = [aDecoder decodeFloatForKey:@"sentiment"];
        self.nodeCount = [aDecoder decodeIntForKey:@"nodeCount"];
        self.edgeCount = [aDecoder decodeIntForKey:@"edgeCount"];
    }
    return self;
}

- (BOOL)isEqual:(BookInfo *)object {
    return [self.UUID isEqual:object.UUID];
}

- (NSUInteger)hash {
    return [self.UUID hash];
}

@end
