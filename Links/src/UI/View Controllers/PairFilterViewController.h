//
//  PairFilterViewController.h
//  Links
//
//  Created by Eoin Nolan on 11/05/2014.
//  Copyright (c) 2014 Nolaneo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordDetailViewController.h"


@interface PairFilterViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (unsafe_unretained) WordDetailViewController * delegate;
@property NSMutableSet * lexicalCategories;
@end
