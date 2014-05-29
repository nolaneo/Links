//
//  BookInfo.h
//  Links
//
//  Created by Eoin Nolan on 14/02/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookInfo : NSObject <NSCoding>
@property BOOL processed;
@property NSString * author;
@property NSString * title;
@property NSString * imageURL;
@property NSString * publicationYear;
@property NSString * description;
@property NSString * ISBN;
@property NSUUID * UUID;
@property NSString * text;

@property float sentiment;
@property int nodeCount;
@property int edgeCount;

//+ (id)bookWithAuthor:(NSString *)author title:(NSString *)title imageURL:(NSString *)imageURL year:(NSString *)year description:(NSString *)description ISBN:(NSString *)ISBN;

@end
