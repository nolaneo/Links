//
//  UserFilterViewController.h
//  Links
//
//  Created by Eoin Nolan on 12/03/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragAndDropTableView.h"
#import "BookCollection.h"
#import "WordTableViewController.h"
#import "VisualisationTabBarController.h"

@interface UserFilterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DragAndDropTableViewDataSource, DragAndDropTableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property VisualisationTabBarController * parent;
@property BookCollection * collection;
@end
