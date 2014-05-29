//
//  GraphViewController.h
//  Links
//
//  Created by Eoin Nolan on 27/04/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
@interface GraphViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UICollectionViewDataSource>

@property BOOL isSentimentGraph;
@property Book * book;

- (void)reloadData;

@end
