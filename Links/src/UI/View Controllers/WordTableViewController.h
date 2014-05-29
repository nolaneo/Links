//
//  WordTableViewController.h
//  Links
//
//  Created by Eoin Nolan on 05/03/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@class BookCollection;

@interface WordTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property BookCollection * collection;
- (void)reloadData;
- (void)searchText;
@end
