//
//  AnnotationsViewController.h
//  Links
//
//  Created by Eoin Nolan on 06/05/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookInfo.h"
#import "Node.h"
#import "Edge.h"

@protocol AnnotationProtocol

- (void)reloadAnnotations;

@end

@interface AnnotationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property BookInfo * bookInfo;
@property Node * node;
@property Edge * edge;
@property NSMutableSet * books;
@property (unsafe_unretained) id<AnnotationProtocol>delegate;
@end
