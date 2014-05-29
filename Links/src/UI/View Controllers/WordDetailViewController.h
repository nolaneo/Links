//
//  WordDetailViewController.h
//  Links
//
//  Created by Eoin Nolan on 30/04/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"
#import "BookCollection.h"
#import "AnnotationsViewController.h"
@interface WordDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AnnotationProtocol>
@property Node * node;
@property BookCollection * collection;

- (void)applyFilters:(NSMutableSet *)filters;

@end
